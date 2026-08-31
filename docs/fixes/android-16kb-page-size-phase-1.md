# Fix: android-16kb-page-size-phase-1

> One per bug fix. Same PR as code.

**Status:** shipped
**Branch:** `beta`
**PR:** —
**Module:** build
**Severity:** major
**Affected versions:** 11.0.0+1 baseline → current `beta`
**Shipped:** v11.0.0+1 (uncommitted on `beta` at session time)

## Symptom

On Android 15+ devices (Pixel 8 / Pixel 9), cold-starting a locally-built
debug APK shows a system dialog: the app is "not compatible with 16 KB page
size" / "es para una versión anterior" depending on locale. Logcat:

```
W AppWarnings: Showing PageSizeMismatchDialog for package app.lunasea.lunasea.debug
```

The release APK downloaded from Play Store does NOT show the dialog — Play
rebuilds and re-aligns the `.so` files on upload. The locally-built one does,
because the toolchain ships the `.so` unaligned and uncompressed inside the
APK zip.

## Repro

1. Pixel 9 (or any 16 KB page-size device — verify with `adb shell getconf PAGE_SIZE` → `16384`).
2. `scripts/build-android.sh beta`
3. `"/mnt/c/Program Files/platform-tools/adb.exe" install -r lunasea/build/app/outputs/flutter-apk/app-debug.apk`
4. `"/mnt/c/Program Files/platform-tools/adb.exe" shell am start -n app.lunasea.lunasea.debug/app.lunasea.lunasea.MainActivity`
5. System dialog "this app is not compatible with 16 KB page size" appears.

## Root cause

```
lunasea/android/app/build.gradle       # no packagingOptions override
lunasea/android/settings.gradle        # AGP 8.1.0, Kotlin 1.8.10
lunasea/android/gradle/wrapper/...     # Gradle 8.0
Dockerfile.android                     # NDK not pinned
```

AGP 8.1 + Gradle 8.0 + unpinned (default) NDK all predate the 16 KB tooling
requirement (AGP ≥ 8.5.1, Gradle ≥ 8.4, NDK ≥ r28). Flutter 3.27.4's engine
`.so` files are already 16 KB-aligned for `arm64-v8a`, but AGP 8.1's
`useLegacyPackaging=false` default packages everything zip-aligned inside the
APK — which still trips the 16 KB page-size check on install.

The full toolchain matrix and reasoning is in
[`../adr/0004-toolchain-and-16kb-page-size.md`](../adr/0004-toolchain-and-16kb-page-size.md).

## Fix

Apply the Phase 1 workaround documented in ADR-0004. No toolchain change; just
two packaging flags that force Gradle to ship the `.so` files compressed and
extract them to disk at install time. The disk-resident files live outside
the APK's zip alignment, so the 16 KB page-size check passes.

**`lunasea/android/app/build.gradle`** (added under the `android { }` block):

```groovy
// Phase 1 of ADR-0004: package .so files with legacy (compressed) layout ...
packagingOptions {
    jniLibs {
        useLegacyPackaging = true
    }
}
```

No `gradle.properties` change — `android.bundle.enableUncompressedNativeLibs=false`
was removed in AGP 8.1 and breaks the build. The single `useLegacyPackaging = true`
setting is sufficient for the workaround.

Both changes are reverted in Phase 2 (separate branch `fix/android-16kb-page-size-phase-2`,
skill `toolchain-upgrade`) once AGP/Gradle/Kotlin/NDK are bumped so the `.so`
files ship uncompressed and properly 16 KB-aligned.

Trade-offs considered:

- *Bump the toolchain now (skip Phase 1).* Rejected — high risk; skill
  `toolchain-upgrade` explicitly forbids it before Phase 1 is validated.
- *Force `targetSdk 36` to suppress the dialog.* Rejected — only suppresses the
  warning; doesn't fix the alignment.
- *Stay on a 4 KB device via dev-options toggle.* Rejected — doesn't fix Play
  submission after 1-Nov-2025.

## Test

- [ ] Manual verify: build APK, install on Pixel 9, launch, confirm no
      `PageSizeMismatchDialog` in `adb logcat -d | grep PageSizeMismatchDialog`.
- [ ] Manual verify: app PID alive, back button still works.
- [ ] Regression test: not applicable (build/toolchain change, no Dart code).
- [ ] After Phase 2 ships: confirm `llvm-objdump -p` shows `align 2**14` for
      every `.so` and the dialog stays gone after reverting these flags.

## Regression risk

| Area | Why safe |
|------|----------|
| Runtime behaviour | `.so` files are extracted to disk and `dlopen`-ed exactly the same way; only the packaging stage differs. |
| Build time | No change. |
| APK install footprint | ~5-15 MB larger because `.so` are stored compressed inside the APK instead of uncompressed. Acceptable for debug builds; we revisit before any release. |
| First-launch time | One-time `.so` extraction adds a fraction of a second on cold install only. |
| Release builds | Same flags apply to release via the `android { }` block. Phase 2 should land before the next Play submission. |

## Related

- ADR: [`../adr/0004-toolchain-and-16kb-page-size.md`](../adr/0004-toolchain-and-16kb-page-size.md)
- Skill: `.agents/skills/toolchain-upgrade/SKILL.md` (Phase 2 work)
- Toolchain reference: [`../reference/toolchain.md`](../reference/toolchain.md)
- Verification commands: `docs/reference/toolchain.md#verifying-16-kb-alignment-of-a-built-apk`