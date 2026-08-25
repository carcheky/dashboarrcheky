---
name: adb-page-size-toggle
description: Toggle a Pixel device between 4 KB and 16 KB memory page-size mode for testing. Use when validating that a Flutter Android APK works on both page sizes without touching the toolchain. Pairs with docs/reference/toolchain.md.
---

# ADB Page-Size Toggle (Pixel dev-options)

Pixel 8 and newer ship with 16 KB memory pages by default. You can flip them
to 4 KB mode from Developer options to test an app that isn't 16 KB-aligned
yet (or to confirm a fix works on both). This skill does it via ADB so you
don't have to tap through Settings.

## When to load

- "Test on 4 KB page size"
- "Disable the 16 KB warning"
- "Toggle page size on the phone"
- Quick smoke-test of an APK before deciding whether to start the full
  toolchain upgrade

## Pre-flight

- Device connected: `"/mnt/c/Program Files/platform-tools/adb.exe" devices`
- Developer options unlocked on the phone (tap Build Number 7 times)
- USB or wireless debugging authorised

## Steps

### 1. Read current mode

```bash
"/mnt/c/Program Files/platform-tools/adb.exe" shell getconf PAGE_SIZE
```

- `4096` → 4 KB mode
- `16384` → 16 KB mode

### 2. Toggle via the secure settings table

Android exposes the toggle through `Settings.Global`, not `Settings.Secure`,
but the actual underlying system property is read-only from a normal shell.
The right way to flip it:

```bash
"/mnt/c/Program Files/platform-tools/adb.exe" shell settings put global force_non_16_by_16 1   # force 4 KB
"/mnt/c/Program Files/platform-tools/adb.exe" shell settings put global force_non_16_by_16 0   # back to default (16 KB on supported hardware)
```

Then reboot for it to take effect:

```bash
"/mnt/c/Program Files/platform-tools/adb.exe" reboot
```

After reboot, verify:

```bash
"/mnt/c/Program Files/platform-tools/adb.exe" shell getconf PAGE_SIZE
```

### 3. Alternative — UI toggle

If ADB refuses (some Pixel builds), toggle manually:

Settings → System → Developer options → **"Use 16 KB memory pages"** → off.

Reboot.

### 4. Sanity-check on the app

```bash
"/mnt/c/Program Files/platform-tools/adb.exe" install -r \
  lunasea/build/app/outputs/flutter-apk/app-debug.apk
"/mnt/c/Program Files/platform-tools/adb.exe" shell am start \
  -n app.lunasea.lunasea.debug/app.lunasea.lunasea.MainActivity
"/mnt/c/Program Files/platform-tools/adb.exe" logcat -d | grep PageSizeMismatchDialog
```

If the dialog is gone after toggling to 4 KB, you've confirmed the only
blocker is page-size alignment. Proceed to either Phase 1 (compressed
packaging — see ADR-0004) or the full toolchain upgrade.

## Pitfalls

- **Setting name varies by Android version.** `force_non_16_by_16` works on
  Android 14 QPR3 and later. On older builds there is no ADB path — only the
  UI toggle works.
- **The setting is per-device, not per-app.** Don't use it as a workaround
  in shipped code.
- **Reboot is required.** Reading `getconf PAGE_SIZE` immediately after the
  `settings put` returns the old value. Reboot, then read.
- **Toggle off → 4 KB disables future-ready behaviour.** Once the toolchain
  is fixed, flip back to 16 KB to confirm the fix works on the real target.

## Output

Report what you observed:

- Mode before toggle
- Mode after reboot
- APK install + launch result (PID, topResumedActivity)
- Whether PageSizeMismatchDialog appeared

## See also

- `docs/reference/toolchain.md` — versions matrix and verification
- `ndk-page-size-audit` skill — `.so`-level audit (independent of device
  mode)
- `toolchain-upgrade` skill — Phase 2 fix
- <https://developer.android.com/guide/practices/page-sizes>