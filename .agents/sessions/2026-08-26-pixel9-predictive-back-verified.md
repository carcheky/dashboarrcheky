# Session: 2026-08-26 — pixel9-predictive-back-verified

> Closes the on-device verification loop for the predictive-back fix.
> Prior session `2026-08-25-pixel9-launch-bug-hunt.md` left it as
> "in-progress, on-device verify pending".

## Goal

Verify on Pixel 9 that the predictive-back fix (manifest flag +
`WillPopScope` → `PopScope`) eliminates the
`WindowOnBackDispatcher: OnBackInvokedCallback is not enabled` warning
and keeps the drawer open/close behaviour intact.

## Done

- [x] Verify `WindowOnBackDispatcher` warning gone on launch.
- [x] Verify drawer opens and closes via edge-swipe gesture, no crash.
- [x] Mark `docs/fixes/android-predictive-back.md` as resolved with the
      on-device verification log — `docs/fixes/android-predictive-back.md:5`

## Touched

| File | Why |
|------|-----|
| `docs/fixes/android-predictive-back.md` | Status → resolved; add verification log + analyze result |

## Tests

| Type | Result |
|------|--------|
| `flutter analyze lib/` (container) | 0 errors. 838 info/warning, all pre-existing Flutter deprecations unrelated to this fix. |
| Manual on device (Pixel 9, tokay) | pass — 4-row matrix (launch, drawer open, edge-swipe close, background) all clean |

## Pending

- None for this fix. Branch `beta` clean at `2aad92f0`.

## Decisions

- The fix-doc was marked "in-progress" pending device verify. Device
  verify done; status moved to "resolved" without re-touching code,
  because the code-side fix shipped in `06f93724` (merge of
  `fix/pixel9-launch-bug-hunt` into `beta`) and `beta` is at `2aad92f0`.
- Verification log captures the actual `adb logcat` results from the
  fresh install of `app-debug.apk` built 2026-08-25 22:30. Future
  sessions can reproduce by re-installing that APK and re-running the
  4-row matrix.

## Blockers

none.

## Next session starts here

Repo is clean and the predictive-back fix is fully closed. Next
non-trivial work: triage the pre-existing 838 analyze warnings (mostly
`withOpacity`/`MaterialStateProperty` deprecations in
`lib/widgets/ui/theme.dart`) if `targetSdk 36` is on the roadmap, or
move on to the next module. Read `docs/index.md` first.
