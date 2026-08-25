---
name: ndk-page-size-audit
description: Audit every `.so` inside a Flutter Android APK for 16 KB page-size ELF alignment, and report which plugins are still 4 KB. Use before any release build, after a plugin upgrade, or when a 16 KB page-size warning appears in Play Console or on a Pixel 8/9 device.
---

# NDK Page-Size Audit

Check whether the `.so` files inside a Flutter Android APK are aligned to
16 KB page boundaries. This is the fast version of the audit step in
[toolchain-upgrade](../toolchain-upgrade/SKILL.md) — no upgrade here, just
visibility.

## When to load

- "Audit this APK for 16 KB compatibility"
- "Which plugin is not 16 KB safe?"
- "Verify before uploading to Play"
- After adding a new plugin to `pubspec.yaml`
- Before cutting any release that targets Android 15+

## Pre-flight

1. Built APK exists. If not, run `scripts/build-android.sh` (debug) or the
   release build path.
2. Confirm `llvm-objdump` is available. Inside the Docker image it is at
   `$ANDROID_HOME/ndk/<version>/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-objdump`.
   Outside the container, install `llvm` package.

## Steps

### 1. List every .so in the APK

```bash
unzip -Z1 lunasea/build/app/outputs/flutter-apk/app-debug.apk | grep '\.so$'
```

You will see entries like:

```
lib/arm64-v8a/libflutter.so
lib/arm64-v8a/libapp.so
lib/armeabi-v7a/libflutter.so
lib/x86_64/libflutter.so
```

### 2. Extract and inspect each one

Run inside the Docker container (the host WSL doesn't ship `llvm-objdump`):

```bash
docker compose -f docker-compose.android.yml run --rm build bash -c '
  APK=/app/lunasea/build/app/outputs/flutter-apk/app-debug.apk
  OBJDUMP=$(find /opt/android-sdk -name llvm-objdump -print -quit)
  for so in $(unzip -Z1 "$APK" | grep "\.so$"); do
    unzip -p "$APK" "$so" > /tmp/x.so
    align=$("$OBJDUMP" -p /tmp/x.so 2>/dev/null | grep LOAD | head -1 | grep -oE "align 2\*\*[0-9]+")
    printf "%-50s %s\n" "$so" "$align"
    rm /tmp/x.so
  done
'
```

### 3. Interpret

| `align` value | Status |
|---------------|--------|
| `align 2**14` (= 16384) | 16 KB OK |
| `align 2**12` (= 4096) | 4 KB only — will trip Play Console + Pixel 9 |
| no output / error | the file is not ELF (probably a stripped stub) — re-check |

A "clean" run shows every line as `align 2**14`. Anything else is a hit.

### 4. Map hits to plugins

The plugin each `.so` comes from is roughly:

| `.so` name | Source |
|------------|--------|
| `libflutter.so` | Flutter engine |
| `libapp.so` | your Dart code (AOT) |
| `lib<plugin>*.so` | the named plugin |
| `libVkLayer_*.so` | Vulkan validation layers (debug builds only — not in release) |

For hits inside a plugin `.so`, search that plugin's pub.dev changelog for
"16 KB" or "page size" — usually a 1-line version bump fixes it.

## Output

Single report, table format:

```
| .so                                         | align       | source             | OK? |
|---------------------------------------------|-------------|--------------------|-----|
| lib/arm64-v8a/libflutter.so                 | 2**14       | Flutter 3.27.4     | yes |
| lib/arm64-v8a/libapp.so                     | 2**14       | this app           | yes |
| lib/armeabi-v7a/libflutter.so               | 2**12       | Flutter 3.27.4     | NO  |
| lib/arm64-v8a/libsomeplugin.so              | 2**12       | some_plugin 2.1.0  | NO  |
```

If anything is NO:

1. For Flutter engine binaries: check the Flutter release notes for the
   pinned version. If the pinned version is older than the 16 KB fix, bump
   `Dockerfile.android`.
2. For plugin binaries: pin a newer version, fork, or remove the plugin.
3. For app code (`libapp.so`): if it's your C/C++ code, add
   `-Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384` to its
   linker flags.

## Pitfalls

- **arm64-v8a vs armeabi-v7a mismatch.** arm64 is usually fine; the 32-bit
  ABIs lag. Check all ABIs the APK ships.
- **`useLegacyPackaging=true` masks the warning.** If Phase 1 of the 16 KB
  fix is in, the app installs fine but the underlying `.so` is still 4 KB.
  This audit still works — the alignment is independent of packaging.
- **Vulkan layers are debug-only.** `libVkLayer_khronos_validation.so` in
  debug builds is not in the release APK. Don't flag it.
- **`unzip -p` needs read permissions.** Running on the WSL host instead of
  inside the Docker container works, but `llvm-objdump` may not be on PATH.

## See also

- `docs/reference/toolchain.md` — versions matrix
- `toolchain-upgrade` skill — the fix, once the audit is done
- <https://developer.android.com/guide/practices/page-sizes>