# Fix: android-predictive-back

> One per bug fix. Same PR as code.

**Status:** in-progress (code implemented, on-device verify pending)
**Branch:** `fix/pixel9-launch-bug-hunt`
**PR:** not-yet
**Module:** core / build
**Severity:** cosmetic today → blocker at `targetSdk 36`
**Affected versions:** v11.0.0
**Shipped:** not-yet

## Symptom

Logcat warns on every launch, and again on every drawer interaction:

```
W WindowOnBackDispatcher: OnBackInvokedCallback is not enabled for the application.
W WindowOnBackDispatcher: Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
```

No crash. No user-visible breakage on `targetSdk 35`. On Android 16+
(`targetSdk 36`) the flag becomes mandatory and predictive back changes
behaviour; leaving this unfixed breaks the back button.

## Repro

1. `scripts/build-android.sh beta`
2. `adb install -r <apk>`
3. `adb shell am start -n app.lunasea.lunasea.debug/app.lunasea.lunasea.MainActivity`
4. `adb logcat -d | grep WindowOnBackDispatcher`

Observed on Pixel 9 (`tokay`), Android 17 / SDK 37, `targetSdkVersion 35`.

## Root cause

Two parts:

1. The manifest never opted into the Android 13+ (API 33) back-navigation API.
2. The app used the deprecated `WillPopScope` — the one widget Flutter's
   predictive-back migration forbids — wrapping the app-wide root scaffold.

```
lunasea/android/app/src/main/AndroidManifest.xml:3    <application> has no android:enableOnBackInvokedCallback
lunasea/lib/widgets/ui/scaffold.dart:41               WillPopScope on the root scaffold
```

## Fix

Both parts, in one change:

1. `AndroidManifest.xml`: add `android:enableOnBackInvokedCallback="true"`.
2. `scaffold.dart`: replace `WillPopScope` with `PopScope`.

The `WillPopScope`→`PopScope` migration is not 1:1 because `canPop` is resolved
at build time while `isDrawerOpen` mutates at runtime with no rebuild. To keep
the drawer-open/back behaviour correct, use `canPop: false` and drive
`Navigator.pop()` manually inside `onPopInvokedWithResult`, reading drawer state
at pop time (not build time). `LunaScaffold.android` changes from a getter to a
method taking `BuildContext` so the callback can reach the `Navigator`.

```dart
Widget android(BuildContext context) {
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (bool didPop, Object? result) {
      if (didPop) return;
      if (!LunaSeaDatabase.ANDROID_BACK_OPENS_DRAWER.read()) {
        Navigator.of(context).pop();
        return;
      }
      final state = scaffoldKey.currentState;
      if (state?.hasDrawer ?? false) {
        if (state!.isDrawerOpen) {
          Navigator.of(context).pop();
        } else {
          state.openDrawer();
        }
        return;
      }
      Navigator.of(context).pop();
    },
    child: scaffold,
  );
}
```

## Behaviour matrix (must survive)

With `ANDROID_BACK_OPENS_DRAWER` on:

| Situation | Expected | Implemented |
|---|---|---|
| Setting off | back pops normally | `Navigator.pop()` |
| Setting on, drawer closed, scaffold has drawer | back opens drawer, does not pop | `state.openDrawer()` |
| Setting on, drawer already open | back pops | `Navigator.pop()` |
| Scaffold without drawer | back pops | `Navigator.pop()` |

## Test

- [ ] Manual verify: 4-row matrix above + nested route back.
- [ ] Logcat clean: `adb logcat -d | grep WindowOnBackDispatcher` returns nothing.
- [ ] `dart analyze lib/` clean (run inside the build container).

## Regression risk

| Area | Why safe |
|------|----------|
| Non-Android platforms | `android(context)` only called when `LunaPlatform.isAndroid` |
| iOS/desktop/web back | unaffected — they use the `scaffold` getter, not `android` |
| Drawer open/close | logic copied verbatim from the old `onWillPop` branches |
| Predictive-back gesture | `PopScope` is the supported API; `WillPopScope` was the blocker |

## Related

- Flutter breaking change: <https://docs.flutter.dev/release/breaking-changes/android-predictive-back>
- Build & install: `../build.md`
- adb / device issues: `../troubleshooting.md`
