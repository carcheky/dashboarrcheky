---
name: lunasea-build
description: Build the LunaSea Flutter Android APK inside Docker and install it on an adb-reachable Android device. Use when the user says "build it", "install it", "ship it to the phone", "/lunasea-build", or asks to test changes on Android. Requires Docker on the WSL host and a device reachable over USB or wireless debugging (usbipd is NOT required).
---

# Build & install the LunaSea Android APK

This skill runs the full build + install loop. For background on how the
toolchain fits together, see [`docs/build.md`](../../docs/build.md).
For troubleshooting, see [`docs/troubleshooting.md`](../../docs/troubleshooting.md).

## CRITICAL: use the Windows adb, never Debian's

WSL2 shares `localhost` with Windows, so both adb binaries compete for port
5037 — and whichever server starts first owns it. Debian's `adb` is
**1.0.41 / platform-tools ~28**: it has no `pair` and no `mdns` host service.
If it wins the race, the modern Windows client talks to that stale server and
every modern command fails with `error: unknown host service`, *and USB devices
stop appearing at all*.

Always drive adb through the Windows binary:

```bash
"/mnt/c/Program Files/platform-tools/adb.exe" devices
```

A shim at `~/.zsh_lunasea_adb.zsh` (sourced from `~/.zshrc`) already routes
`adb` there and auto-translates Linux paths via `wslpath`, so plain
`adb install ./app-debug.apk` works. `adb-linux` is the deliberate escape hatch
— using it re-breaks detection.

If devices vanish mid-session, someone ran Debian's adb. Recover with:

```bash
/usr/bin/adb kill-server
"/mnt/c/Program Files/platform-tools/adb.exe" start-server
```

## Live checks (run before anything else)

!`"/mnt/c/Program Files/platform-tools/adb.exe" devices -l`
!`docker info > /dev/null 2>&1 && echo "docker: OK" || echo "docker: NOT AVAILABLE"`

## When to STOP and ask the user

- **`adb devices` is empty** → no device is reachable. Do NOT reach for
  `usbipd`; it is not installed and not needed. Ask the user to either plug in
  via USB (then verify with the Windows adb) or enable
  Settings → System → Developer options → **Wireless debugging**.
- **A device shows `offline`** → wireless debugging is on but this host is not
  paired. Pairing needs a 6-digit code only the user can read off the phone;
  ask for it (see "Wireless debugging" below). Don't retry `connect` — it
  cannot succeed unpaired.
- **`docker info` failed** → Docker daemon isn't running. Tell the user to start
  Docker Desktop or `sudo systemctl start docker`.
- **Release build requested but `lunasea/android/key.properties` is missing** →
  stop and ask whether to generate a keystore or fall back to debug.

## Wireless debugging (Android 11+)

Port 5555 is **only** for the legacy `adb tcpip 5555` flow, which needs USB
first. Modern wireless debugging uses a **random high port**, and pairing uses a
**second, different, temporary port** that closes when the dialog does.

1. Phone: Developer options → Wireless debugging → **Pair device with pairing code**.
2. Read the `IP:PORT` and 6-digit code off that screen (ask the user — you can't
   see it). Both expire; work fast.
3. Pair with the **Windows** binary (Debian's has no `pair`):
   ```bash
   "/mnt/c/Program Files/platform-tools/adb.exe" pair 192.168.68.21:<PAIR_PORT> <CODE>
   ```
4. Then connect to the *connect* port (the persistent one, different from the
   pairing port). Discover it if unknown:
   ```bash
   nmap -Pn -T4 --open -p 30000-45000 192.168.68.21
   "/mnt/c/Program Files/platform-tools/adb.exe" connect 192.168.68.21:<CONNECT_PORT>
   ```

WSL and Windows share the same `adbkey` (fingerprint `carch@PORCHEKYTATIL`), so
pairing once authorises both.

## Steps

1. **Build the Docker image (cached after first time).**
   ```bash
   cd <repo-root>
   docker compose -f docker-compose.android.yml build
   ```
   First run takes 5–10 minutes (Flutter + Android SDK download). The image is
   ~7.1 GB. Subsequent runs are a cache hit.

2. **Run the codegen + APK build inside the container.**

   Preferred — stamps real build metadata into the About screen:
   ```bash
   scripts/build-android.sh            # edge (default) | beta | stable
   ```
   Plain compose also works but leaves placeholder metadata:
   ```bash
   docker compose -f docker-compose.android.yml run --rm build
   ```

   This runs:
   - `npm install --ignore-scripts` (~1 s warm; `--ignore-scripts` skips husky,
     which would fail because `.git/` isn't in the container)
   - `npm run generate` — 4-stage codegen (~1–2 min)
   - `flutter build apk --debug`

   **Timing reality:** the first APK build takes **~8–10 minutes** (Gradle
   alone was 492 s) because Gradle downloads extra SDK platforms (android-31,
   android-34) that plugin dependencies pull in. Those land in the
   `lunasea-gradle-cache` volume, so later builds are far quicker.

3. **Verify the APK exists and is non-trivial.**
   ```bash
   ls -lh lunasea/build/app/outputs/flutter-apk/app-debug.apk
   ```
   Expect **~196 MB**. This is a *fat debug* APK — unstripped and carrying four
   ABIs (`arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`). Anything under ~100 MB
   means the build didn't finish; re-run and read the container logs.

4. **Install on the device.**
   ```bash
   adb install -r lunasea/build/app/outputs/flutter-apk/app-debug.apk
   ```
   `-r` reinstalls, preserving user data. Prefer USB over Wi-Fi for 196 MB.
   Target a specific device with `-s <serial>` when several are connected.

5. **Launch the app.**
   ```bash
   adb shell am start \
     -n app.lunasea.lunasea.debug/app.lunasea.lunasea.MainActivity
   ```

6. **Verify it actually started** (install success ≠ running):
   ```bash
   adb shell pidof app.lunasea.lunasea.debug
   adb shell dumpsys activity activities | grep topResumedActivity
   adb logcat -d | grep -iE 'FATAL|MissingPlugin|E/flutter'
   ```
   Ignore `AndroidRuntime` lines from `uid 2000` / `com.android.commands.monkey`
   — those come from the launcher command, not the app.

7. **Report.**
   - Confirm "App installed and launched on <device-id>"
   - Offer logs: `adb logcat -d | tail -100`

## Common errors → fix recipes

| Symptom                                                  | Fix                                                                                                  |
|----------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| `sh: 1: dart: not found` during codegen                  | Host PATH leaked into the container. Never put `export PATH="...:$PATH"` in compose `command:` — Compose expands `$PATH` on the **host**. Verify: `docker compose -f docker-compose.android.yml config \| grep -c /mnt/c/` must be `0`. Literal `$` in compose is `$$`, not `\$` |
| `error: unknown host service` from adb                    | Stale Debian adb server owns port 5037. `/usr/bin/adb kill-server` then start the Windows server      |
| Device stuck `offline` over Wi-Fi                         | Not paired. Run `adb pair` with a fresh code — see "Wireless debugging"                               |
| `failed to connect ... :5555` on Android 11+              | 5555 is the legacy port. Wireless debugging uses a random high port; discover it with `nmap`          |
| `adb: unknown command pair` / `mdns`                      | You're on Debian's old adb. Use the Windows binary                                                   |
| `npm install` fails on husky `prepare`                    | `.git/` is excluded from the container — that's why the pipeline uses `--ignore-scripts`              |
| `spider: not found`                                       | `/root/.pub-cache/bin` must be in the image `ENV PATH` (already fixed in `Dockerfile.android`)        |
| `MissingPluginException` on first launch                  | Codegen didn't run. Re-run the build                                                                 |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE`                      | Previously installed release-signed: `adb uninstall app.lunasea.lunasea`                             |
| `INSTALL_FAILED_VERSION_DOWNGRADE`                        | Bump `versionCode` in `lunasea/android/local.properties` (`flutter.versionCode=2`)                    |
| Gradle OOM                                                | Edit `lunasea/android/gradle.properties`: `org.gradle.jvmargs=-Xmx3g`                                 |

If you hit something not in this table, jump to
[`docs/troubleshooting.md`](../../docs/troubleshooting.md).

## Gotchas worth knowing

- **Two packages can coexist:** `app.lunasea.lunasea.debug` (ours) and
  `app.lunasea.lunasea` (release / Play Store build). They don't conflict, but
  filter logs and `pm list packages` carefully so you inspect the right one.
- **Our pipeline diverges from upstream CI.** Upstream
  (`lunasea/.github/workflows/build_android.yml`) builds with
  `bundle exec fastlane build_apk` and release signing; `prepare.yml` runs
  codegen as environment → **localization → build_runner** and never runs
  `spider`. Our `npm run generate` order is environment → spider →
  build_runner → localization. Both work; know the difference before debugging
  a codegen discrepancy.
- **Without `scripts/build-android.sh`** the About screen shows the
  `environment_config.yaml` defaults: `build=9999999999`, `commit=master`,
  `flavor=edge`.

## After the build

- Iterating on code: edit under `lunasea/lib/`, then re-run this skill. The
  Docker + Gradle caches make rebuilds fast.
- Release APK: stop and ask about the keystore first — see
  [`docs/reference/gradle.md`](../../docs/reference/gradle.md#signing-release-builds).
- Something looked wrong visually: `adb logcat -d | grep -iE 'flutter|exception'`
  and surface the relevant lines. `adb exec-out screencap -p > /tmp/shot.png`
  captures the screen.
