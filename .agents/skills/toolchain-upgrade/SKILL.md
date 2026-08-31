---
name: toolchain-upgrade
description: Plan and execute a phased bump of AGP / Gradle / Kotlin / NDK so a Flutter Android app ships 16 KB page-size aligned `.so` files. Use when the user asks to fix PageSizeMismatchDialog, make LunaSea Android 15+ compatible, or upgrade any of those four toolchain pins. Always pairs with docs/reference/toolchain.md and ADR-0004.
---

# Toolchain Upgrade (Phase 2 of 16 KB migration)

Bump AGP / Gradle / Kotlin / NDK so future APKs ship uncompressed `.so`
aligned to 16 KB boundaries. This is the long-form version of Phase 2 in
[ADR-0004](../../../docs/adr/0004-toolchain-and-16kb-page-size.md).

## When to load

- "Fix the 16 KB page size warning on Android 15+"
- "Upgrade Gradle / AGP"
- "Bump NDK"
- "Make the release Play-ready for Android 15+"

Do **not** load for Phase 1 (compressed legacy packaging) — that needs only a
5-line edit, not this skill.

## Pre-flight (always)

1. Read `docs/reference/toolchain.md` — current pins and how to verify.
2. Read `docs/adr/0004-toolchain-and-16kb-page-size.md` — decision context.
3. Confirm the user has accepted Phase 1 already and Phase 2 is the agreed
   next step. If not, **stop and ask** — Phase 2 is high-risk.

## Phase 2 plan

Bump in this order, one commit per step, with a full build + install + smoke
test between each. Stop at the first failure and diagnose before continuing.

### Step 1 — Gradle wrapper

`lunasea/android/gradle/wrapper/gradle-wrapper.properties`:

```
distributionUrl=https\://services.gradle.org/distributions/gradle-8.10.2-all.zip
```

Build + smoke. Gradle 8.10 supports the rest of the chain.

### Step 2 — AGP

`lunasea/android/settings.gradle`:

```
id "com.android.application" version "8.7.3" apply false
```

Build + smoke. AGP 8.7 aligns 16 KB by default.

### Step 3 — Kotlin

`lunasea/android/settings.gradle`:

```
id "org.jetbrains.kotlin.android" version "1.9.22" apply false
```

Build + smoke. 1.9.22 is the highest 1.9.x; 2.0+ breaks the Flutter 3.27
toolchain in our experience.

### Step 4 — Pin NDK in app/build.gradle

```groovy
android {
    ndkVersion "28.2.13676358"
}
```

Update `Dockerfile.android` to install the matching NDK:

```
yes | sdkmanager --install "ndk;28.2.13676358"
```

Build + smoke. NDK r28 aligns 16 KB by default.

### Step 5 — Remove Phase 1 workarounds

Once the toolchain is bumped and the app launches without the
`PageSizeMismatchDialog`:

- Revert `packagingOptions { jniLibs { useLegacyPackaging = true } }`
  (in `app/build.gradle`) to false / remove.
- Remove `android.bundle.enableUncompressedNativeLibs=false` from
  `gradle.properties`.

Now the `.so` files ship uncompressed and 16 KB-aligned, exactly what Play
expects from Nov 2025.

### Step 6 — Audit each Flutter plugin

For every plugin in `lunasea/pubspec.yaml`:

```bash
grep -E '^\s+[a-z_]+:' lunasea/pubspec.yaml | grep -v '^#'
```

For each, check upstream issue tracker / changelog for "16 KB" or "page size".
Pin or fork the laggards.

## Verification at each step

```bash
# 1. Build clean
scripts/build-android.sh beta

# 2. Install
"/mnt/c/Program Files/platform-tools/adb.exe" install -r \
  lunasea/build/app/outputs/flutter-apk/app-debug.apk

# 3. Launch
"/mnt/c/Program Files/platform-tools/adb.exe" shell am start \
  -n app.lunasea.lunasea.debug/app.lunasea.lunasea.MainActivity

# 4. Confirm no dialog
"/mnt/c/Program Files/platform-tools/adb.exe" logcat -d | grep PageSizeMismatchDialog
# should be empty

# 5. Confirm 16 KB alignment of every .so in the APK
docker compose -f docker-compose.android.yml run --rm build bash -c '
  OBJDUMP=$(find /opt/android-sdk -name llvm-objdump -print -quit)
  for so in $(unzip -Z1 /app/lunasea/build/app/outputs/flutter-apk/app-debug.apk | grep "\.so$"); do
    unzip -p /app/lunasea/build/app/outputs/flutter-apk/app-debug.apk "$so" > /tmp/x.so
    "$OBJDUMP" -p /tmp/x.so | grep LOAD | head -1 | \
      awk -v so="$so" '"'"'{print so": "$0}'"'"'
    rm /tmp/x.so
  done
'
# every line should show align 2**14
```

## Pitfalls (real ones we hit)

- **Flutter Gradle Plugin lag.** Newer AGP versions occasionally break the
  Flutter Gradle Plugin until Flutter ships a compatible version. If you see
  `FlutterPluginExtension not found`, you've bumped AGP past what the pinned
  Flutter supports — pin lower, or bump Flutter.
- **Hard-coded 4 KB in native code.** If a plugin's C/C++ does
  `sysconf(_SC_PAGESIZE) == 4096` and refuses to load otherwise, no toolchain
  bump will help. Audit by reading the plugin's source.
- **Mixed alignment per ABI.** arm64-v8a tends to be 16 KB OK; armeabi-v7a
  and x86 (32-bit) lag behind. Our `app-debug.apk` ships four ABIs; check
  all four, not just arm64.
- **Play Console warning vs hard reject.** Google Play shows the 16 KB
  warning before Nov 2025, then hard-rejects after. Don't use "warning only"
  as a reason to delay.

## Output

When done, report:

- Branch name (`fix/android-16kb-page-size-phase-2`)
- Commits (one per step)
- Final APK path + sha1
- 16 KB alignment check result (should show `align 2**14` for every `.so`)
- On-device smoke test (PID alive, no PageSizeMismatchDialog, back button
  still works)
- Updated `docs/reference/toolchain.md` with new pins
- Updated `docs/adr/0004-toolchain-and-16kb-page-size.md` status to "shipped"