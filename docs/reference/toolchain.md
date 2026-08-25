# Toolchain

Versions of every tool that produces an APK, plus how to verify each one
matches what this repo expects.

## Current pins (as of this branch)

| Tool | Where pinned | Version |
|------|--------------|---------|
| Flutter SDK | `Dockerfile.android` `ARG FLUTTER_VERSION=3.27.4` | 3.27.4 |
| Android Gradle Plugin | `lunasea/android/settings.gradle` `id "com.android.application" version "8.1.0"` | 8.1.0 |
| Gradle wrapper | `lunasea/android/gradle/wrapper/gradle-wrapper.properties` `distributionUrl=...gradle-8.0-all.zip` | 8.0 |
| Kotlin Android | `lunasea/android/settings.gradle` `id "org.jetbrains.kotlin.android" version "1.8.10"` | 1.8.10 |
| compileSdk | `lunasea/android/app/build.gradle` `compileSdkVersion 35` | 35 |
| targetSdk | `lunasea/android/app/build.gradle` `targetSdkVersion 35` | 35 |
| minSdk | `lunasea/android/app/build.gradle` `minSdkVersion 24` | 24 |
| Java source/target | `lunasea/android/app/build.gradle` `sourceCompatibility VERSION_1_8` | 1.8 |
| Node | `Dockerfile.android` (Debian nodesource setup_20.x) | 20 |
| Android SDK Build-Tools | `Dockerfile.android` `sdkmanager --install "build-tools;35.0.0"` | 35.0.0 |
| Android SDK platforms | `Dockerfile.android` `sdkmanager --install "platforms;android-35"` | 35 (others auto-pulled by plugins) |
| Android NDK | not pinned (uses AGP default) | unknown |

## Verifying the pins

```bash
# Flutter
docker compose -f docker-compose.android.yml run --rm build flutter --version

# AGP / Gradle / Kotlin — read the file
grep -E 'com.android.application|kotlin.android' lunasea/android/settings.gradle
cat lunasea/android/gradle/wrapper/gradle-wrapper.properties

# Gradle JVM args
cat lunasea/android/gradle.properties

# What actually ran last build
grep -E 'Gradle [0-9]|AGP|Compatible with' .claude/tmp/build.log | tail -20
```

## 16 KB page-size compatibility

Android 15+ devices (Pixel 8+, anything shipping Android 17) require apps to
ship native libraries (`.so` files) aligned to 16 KB boundaries. The
`PageSizeMismatchDialog` shows when this is violated.

Why we currently fail:

- AGP 8.1.0 + Gradle 8.0 + NDK (default) all predate the 16 KB tooling
  requirement (AGP 8.5.1, Gradle 8.4, NDK r28).
- Flutter 3.27.4's engine `.so` are 16 KB-aligned for arm64-v8a, but the
  unaligned `useLegacyPackaging=false` default in AGP 8.1 puts everything in
  the APK zip-aligned, which still trips the dialog.

The two-phase plan lives in [ADR-0004](../adr/0004-toolchain-and-16kb-page-size.md):

- **Phase 1** (this branch): `packagingOptions.jniLibs.useLegacyPackaging=true`
  + `android.bundle.enableUncompressedNativeLibs=false`. Forces the `.so` files
  to be extracted at install time, sidestepping alignment checks.
- **Phase 2** (separate branch): bump AGP/Gradle/Kotlin/NDK so the `.so` are
  properly aligned and shipped uncompressed.

## Verifying 16 KB alignment of a built APK

After build, run:

```bash
unzip -l lunasea/build/app/outputs/flutter-apk/app-debug.apk | grep '\.so$'
```

For each `.so` listed, check its ELF alignment with `llvm-objdump`:

```bash
find /opt/android-sdk -name 'llvm-objdump' -print -quit
OBJDUMP=$(find /opt/android-sdk -name 'llvm-objdump' -print -quit)
"$OBJDUMP" -p path/to/libfoo.so | grep LOAD
```

16 KB-aligned segments look like `LOAD ... align 2**14` (`2**14 == 16384`).
4 KB-aligned look like `align 2**12`.

Inside the Docker container:

```bash
docker compose -f docker-compose.android.yml run --rm build bash -c '
  OBJDUMP=$(find /opt/android-sdk -name llvm-objdump -print -quit) &&
  "$OBJDUMP" -p lib/arm64-v8a/libflutter.so | grep LOAD
'
```

## Verifying the running device's page size

```bash
adb shell getconf PAGE_SIZE
# 4096  → 4 KB device (debug APK works fine today)
# 16384 → 16 KB device (Pixel 8/9 with dev-options toggle, Android emulator
#         system images configured for 16 KB)
```

The Pixel 9 in this repo ships 16 KB. Toggle in
**Settings → System → Developer options → Use 16 KB memory pages**.

## When to bump versions

- AGP, Gradle, Kotlin: when Phase 2 of ADR-0004 starts. Don't bump casually —
  each bump can require a matching Flutter or plugin update.
- Flutter SDK: tied to `pubspec.lock` minimum `>=3.27.0`. Bumping
  `Dockerfile.android` requires running `flutter pub upgrade` first.
- NDK: bump to r28+ as part of Phase 2 only.

## See also

- [ADR-0004](../adr/0004-toolchain-and-16kb-page-size.md) — the decision
- [Gradle reference](gradle.md) — signing + JVM args
- [Build doc](../build.md) — full build loop