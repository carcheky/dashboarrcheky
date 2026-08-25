# ADR-0004: Android toolchain and 16 KB page-size compatibility

## Status

Proposed. 2026-08-25.

## Context

The Pixel 9 (and any device shipping Android 17 / page-size 16K) refuses to
launch our `app-debug.apk`: it shows `PageSizeMismatchDialog` for
`app.lunasea.lunasea.debug` and warns the user that the app "is not compatible
with 16 KB page size". Logcat confirms the dialog comes from `AppWarnings` on
every cold start:

```
W AppWarnings: Showing PageSizeMismatchDialog for package app.lunasea.lunasea.debug
```

The release `app.lunasea.lunasea` (downloaded from Play Store) is fine — Play
rebuilds and aligns the `.so` files on upload. Our locally-built APK is not.

Why this happens (verified against `developer.android.com/guide/practices/page-sizes`):

| Tool | Current pin | Required for 16 KB |
|------|-------------|---------------------|
| Android Gradle Plugin | 8.1.0 (settings.gradle line 12) | 8.5.1 minimum |
| Gradle wrapper | 8.0 (`gradle-wrapper.properties`) | 8.4 minimum, 8.10+ recommended |
| Kotlin Android | 1.8.10 (settings.gradle line 13) | 1.9.20+ (2.0+ for newest AGP) |
| Android NDK | not pinned (AGP default) | r28+ default-aligned |
| Flutter | 3.27.4 (Dockerfile.android) | 3.27+ ships ARM64 `.so` 16 KB-aligned |
| compileSdk / targetSdk | 35 | OK |

Google Play enforces 16 KB support for new apps and updates submitted after
**1 November 2025**. This is no longer a "warning on Pixel 8+" — it's a
submission hard requirement.

## Decision

We adopt a **two-phase plan**:

**Phase 1 (this PR / branch `fix/android-16kb-page-size`): minimum-effort,
zero-toolchain-change workaround.** Add
`android.packagingOptions.jniLibs.useLegacyPackaging = true` to
`lunasea/android/app/build.gradle` and
`android.bundle.enableUncompressedNativeLibs=false` to
`lunasea/android/gradle.properties`. This forces Gradle to ship `.so` files
**compressed inside the APK** and let the system loader extract them at
install time. The extracted files live on disk, not in the APK's zip
alignment, so the 16 KB page-size dialog goes away without requiring AGP/Gradle
upgrades.

Trade-off: bigger install footprint (~5-15 MB more per APK), slightly slower
first launch (one-time `.so` extraction). Worth it: the app becomes installable
and runnable on Pixel 9 / Android 17 today, with zero toolchain risk.

**Phase 2 (separate branch, separate PR): real 16 KB alignment.** Upgrade
the toolchain so the next APK ships uncompressed `.so` files aligned to 16 KB
boundaries:

- AGP 8.1.0 → 8.7.x (or whatever Flutter 3.27 supports without breaking the
  Flutter Gradle Plugin).
- Gradle 8.0 → 8.10.x.
- Kotlin 1.8.10 → 1.9.22 (2.0 once the Flutter toolchain supports it).
- Pin NDK to r28+ in `lunasea/android/app/build.gradle`.
- Update `Dockerfile.android` to install the matching NDK.
- Audit each plugin in `lunasea/pubspec.yaml` for a 16 KB-aligned release;
  pin or fork those that lag.

This is a **separate workstream** because bumping the toolchain without
checking every plugin risks a release-build regression that blocks the Play
release — that PR should not be merged on the same day as a routine fix.

## Consequences

### Positive

- Phase 1 unblocks Pixel 9 development today with a 5-line change.
- Phase 2 keeps the project future-proof for the Play 1-Nov-2025 deadline.
- Both phases are well-scoped: each fits in a single PR with its own
  regression-test plan.

### Negative

- Phase 1 APK is bigger than it needs to be. Acceptable for debug builds; we
  should revisit before any release.
- Phase 2 toolchain bump may require running
  `flutter pub upgrade --major-versions` and updating several plugins — risk
  of subtle behaviour changes. Mitigation: keep Phase 2 in a long-running
  branch, ship Phase 1 first, validate release flow on Phase 1 build before
  starting Phase 2.

### Rejected alternatives

- **Just keep using 4 KB devices** (developer-options toggle on the phone).
  Rejected because (a) it doesn't fix the Play submission deadline, (b) it
  hides the problem from us.
- **Skip Phase 1, go straight to Phase 2.** Rejected because Phase 2 is
  high-risk and slow; meanwhile we can't iterate on a real device.
- **Force `targetSdk 36`** to disable the dialog. Rejected: doesn't actually
  fix the underlying alignment, only suppresses the warning.

## References

- <https://developer.android.com/guide/practices/page-sizes>
- <https://docs.flutter.dev/release/breaking-changes/android-predictive-back>
  (related Flutter migration we already shipped in this repo)
- `docs/reference/toolchain.md` — versions matrix, how to verify
- `lunasea/android/app/build.gradle` — where Phase 1 lands
- `lunasea/android/gradle.properties` — where Phase 1's bundle flag lands