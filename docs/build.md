# Build & Install

## TL;DR

From the repo root on WSL2, with an adb-reachable device (USB or wireless):

```bash
# One-time setup (only on a fresh machine):
docker compose -f docker-compose.android.yml build   # ~5-10 min first time

# Build the debug APK (stamps real commit/build metadata):
scripts/build-android.sh                             # edge | beta | stable
# First APK build: ~8-10 min (Gradle pulls extra SDK platforms).
# Later builds are much faster once the gradle-cache volume is warm.

# Install on the connected device:
adb devices -l                                       # confirm device is listed
adb install -r lunasea/build/app/outputs/flutter-apk/app-debug.apk

# Launch the app:
adb shell am start -n app.lunasea.lunasea.debug/app.lunasea.lunasea.MainActivity
```

> **`adb` must be the Windows binary**, not Debian's. A shim in
> `~/.zsh_lunasea_adb.zsh` handles this (and path translation) automatically.
> See [troubleshooting.md](troubleshooting.md#adb-wifi).

Plain `docker compose -f docker-compose.android.yml run --rm build` also builds,
but leaves placeholder build metadata — see [Build metadata](#build-metadata).

That's it. Everything else in this doc is detail.

## Prerequisites

| Tool                      | Where         | Why                                      |
|---------------------------|---------------|------------------------------------------|
| Docker 24+                | WSL2          | Runs the entire Android toolchain        |
| adb (platform-tools 30+)  | Windows host  | Installs the APK; **not** Debian's adb   |
| Android device            | USB or Wi-Fi  | Target device                            |

**adb version matters.** Debian's `adb` is 1.0.41 / platform-tools ~28: it has no
`pair` and no `mdns` host service, so it cannot do Android 11+ wireless
debugging. Worse, WSL2 shares `localhost`, so if the old Linux server claims port
5037 the modern Windows client talks to it and USB devices stop appearing
entirely. Use `/mnt/c/Program Files/platform-tools/adb.exe` (v36+ here); the
`~/.zsh_lunasea_adb.zsh` shim routes `adb` there and translates paths via
`wslpath`.

**`usbipd-win` is not required** and is not installed here — USB works directly
through the Windows adb, and wireless debugging needs no USB bridge at all.

The device needs **Developer Options → USB debugging** (USB) or **Wireless
debugging** (LAN). USB prompts once to authorize the host RSA key; wireless
requires an explicit pairing code. Both are covered in
[troubleshooting.md](troubleshooting.md).

## What the Docker image contains

The `Dockerfile.android` image bundles everything needed to build APKs:

- Debian 12 (bookworm) slim base
- OpenJDK 17 headless (required by Android Gradle Plugin)
- Flutter 3.27.4 (pinned to satisfy `pubspec.lock` minimum of `>=3.27.0`)
- Android SDK: platform 35, build-tools 35.0.0, platform-tools, cmdline-tools
- Node 20 (for `npm run generate` codegen scripts)
- Dart (bundled with Flutter)

The image is **~7.1 GB** (Flutter SDK + Android SDK dominate). After the first
build, rebuilds are fast because Gradle and pub caches are persisted in named
Docker volumes.

## Caches

Three Docker volumes persist across rebuilds — never delete them unless you
want a clean rebuild:

| Volume                | Contents                        | Speed-up   |
|-----------------------|---------------------------------|------------|
| `lunasea-gradle-cache` | `~/.gradle` (deps, daemons)     | ~5× faster |
| `lunasea-pub-cache`    | `~/.pub-cache` (Dart packages)  | ~3× faster |
| `lunasea-npm-cache`    | `~/.npm` (Node packages)        | ~2× faster |

To force a clean rebuild:

```bash
docker compose -f docker-compose.android.yml down --volumes
```

## What the build pipeline runs (in order)

1. `npm install --ignore-scripts` — installs `husky`, `commitizen`, `commitlint`,
   etc. (tooling, not runtime deps — Dart packages come from `flutter pub get`).
   `--ignore-scripts` is required: the `prepare` hook runs `husky install`, which
   fails because `.git/` is not inside the container.
2. `npm run generate` — 4-stage codegen chain:
   1. `generate:environment` — generates `lib/system/environment.dart` from `environment_config.yaml`
   2. `generate:assets` — `spider build` produces typed asset constants
   3. `generate:build_runner` — generates `*.g.dart` for Hive, json_serializable, retrofit
   4. `generate:localization` — runs `scripts/generate_localization.dart`
3. `flutter build apk --debug` — produces `app-debug.apk`
4. APK is written to `lunasea/build/app/outputs/flutter-apk/app-debug.apk` via
   the bind-mounted volume, where the WSL host can grab it.

The output is a **fat debug APK of ~196 MB** — unstripped and carrying four ABIs
(`arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`). That size is normal; don't treat it
as a bug.

> **Divergence from upstream CI.** `lunasea/.github/workflows/prepare.yml` runs
> codegen as environment → **localization → build_runner** and never runs
> `spider`; `build_android.yml` builds via `bundle exec fastlane build_apk` with
> release signing (`KEY_JKS` / `KEY_PROPERTIES`). Our order and our direct
> `flutter build apk --debug` are a local-iteration simplification. Both produce a
> working APK — but check the workflows before debugging a codegen discrepancy.

## Build metadata

`environment_config.yaml` declares three fields fed by environment variables,
each with a fallback:

| Field    | Env var  | Default        |
|----------|----------|----------------|
| `build`  | `BUILD`  | `9999999999`   |
| `commit` | `COMMIT` | `master`       |
| `flavor` | `FLAVOR` | `edge`         |

Upstream CI exports all three before codegen. Plain
`docker compose ... run --rm build` does not, so the app's About screen shows
those placeholder defaults.

`scripts/build-android.sh` supplies real values, mirroring upstream's formula
(`BUILD = 1000000000 + commit count`):

```bash
scripts/build-android.sh          # edge (default)
scripts/build-android.sh beta
scripts/build-android.sh stable
```

Verified result of a run at commit `6ee0bf9a`:

```dart
class LunaEnvironment {
  static const int build = 1000001070;
  static const String commit = '6ee0bf9a';
  static const String flavor = 'beta';
}
```

To override manually, export the vars yourself — `docker-compose.android.yml`
passes them through:

```bash
FLAVOR=beta COMMIT=$(git rev-parse --short HEAD) BUILD=1000001070 \
  docker compose -f docker-compose.android.yml run --rm build
```

## Debug APK vs Release APK

| Build type | applicationId                     | versionName  | Signed        |
|------------|-----------------------------------|--------------|---------------|
| Debug      | `app.lunasea.lunasea.debug`       | `11.0.0-dev` | Auto (debug)  |
| Release    | `app.lunasea.lunasea`             | `11.0.0`     | Needs `key.properties` |

To build release (only once signing is configured), edit
`docker-compose.android.yml` and change `--debug` to `--release`. The release
APK lives at `app-release.apk` in the same folder.

## Common pitfalls

See [troubleshooting.md](troubleshooting.md) for the full list.

- **`adb devices` shows nothing** → most often a stale Debian adb server owning
  port 5037. `/usr/bin/adb kill-server`, then start the Windows server. Also
  check the cable is data-capable and USB debugging is on. `usbipd` is **not**
  needed.
- **Device shows `offline`** → wireless debugging isn't paired. Pair with
  `adb.exe pair <ip>:<pair-port> <code>` using the Windows binary.
- **`sh: 1: dart: not found` during codegen** → host PATH leaked into the
  container via Compose interpolation. Never `export PATH="...:$PATH"` in
  `command:`; verify with
  `docker compose -f docker-compose.android.yml config | grep -c /mnt/c/` → `0`.
- **`flutter pub get` fails inside container** → The volume mount for
  `pub-cache` may be corrupt. `docker compose -f docker-compose.android.yml down --volumes` and rebuild.
- **`pub get` complains about Dart SDK mismatch** → The locked `dart` SDK is
  `>=3.7.0 <4.0.0`. Flutter 3.27.4 ships with Dart 3.6+, satisfying the floor.
  See `pubspec.lock` `sdks:` section.
