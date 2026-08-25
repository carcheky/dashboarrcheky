# Session: 2026-08-25 — pixel9-launch-bug-hunt + 16kb-docs

> Append at session end. Next session reads latest first.

## Goal

Two things:

1. Install LunaSea debug on the Pixel 9, identify one bug, fix it, document it.
2. After a separate user request, document the 16 KB page-size warning that
   appeared on the Pixel 9 and propose a phased fix without touching the
   toolchain yet.

## Done

- [x] Installed `app.lunasea.lunasea.debug` on Pixel 9 via wireless adb.
- [x] Identified `WindowOnBackDispatcher: OnBackInvokedCallback is not enabled`
      warning as the documented bug in `docs/fixes/android-predictive-back.md`.
- [x] Fixed `WillPopScope` → `PopScope` in
      `lunasea/lib/widgets/ui/scaffold.dart`.
- [x] Added `android:enableOnBackInvokedCallback="true"` to
      `lunasea/android/app/src/main/AndroidManifest.xml`.
- [x] Rewrote `docs/fixes/android-predictive-back.md` with full template
      fields (root cause, fix, behaviour matrix).
- [x] Verified on device: warning count = 0 after install + launch.
- [x] `dart analyze lib/widgets/ui/scaffold.dart` → No issues found.
- [x] Researched online (developer.android.com + Flutter migration guide)
      and documented the 16 KB page-size situation.
- [x] Drafted ADR-0004: toolchain + 16 KB page-size plan (two phases).
- [x] Wrote `docs/reference/toolchain.md` (versions matrix + how to verify).
- [x] Wrote three `.agents/skills/` for AI-driven execution of the plan:
      `toolchain-upgrade`, `ndk-page-size-audit`, `adb-page-size-toggle`.

## Touched

| File | Why |
|------|-----|
| `lunasea/lib/widgets/ui/scaffold.dart` | PopScope migration |
| `lunasea/android/app/src/main/AndroidManifest.xml` | opt into predictive back |
| `docs/fixes/android-predictive-back.md` | full template |
| `docs/adr/0004-toolchain-and-16kb-page-size.md` | new ADR |
| `docs/adr/index.md` | link the new ADR |
| `docs/reference/toolchain.md` | new reference doc |
| `.agents/skills/toolchain-upgrade/SKILL.md` | new skill |
| `.agents/skills/ndk-page-size-audit/SKILL.md` | new skill |
| `.agents/skills/adb-page-size-toggle/SKILL.md` | new skill |

## Tests

| Type | Result |
|------|--------|
| `dart analyze lib/widgets/ui/scaffold.dart` | clean (No issues found) |
| On-device: PID alive after back-press | pass |
| On-device: warning `OnBackInvokedCallback is not enabled` count | 0 |
| On-device: 4-row back behaviour matrix | not fully verified (device was locked mid-session) |

## Pending

- [ ] Decide Phase 1 vs Phase 2 of ADR-0004 (user to approve).
- [ ] If Phase 1: apply `useLegacyPackaging=true` + `enableUncompressedNativeLibs=false`, rebuild, install on Pixel 9, confirm dialog gone.
- [ ] If Phase 2: open `fix/android-16kb-page-size-phase-2` branch, follow `toolchain-upgrade` skill steps 1-6.
- [ ] When Phase 2 lands: re-verify back-button matrix on the device.
- [ ] Original export/import bug between `app.lunasea.lunasea` and `app.lunasea.lunasea.debug` was sidelined; signatures differ (`5cbecb4d` vs `6b2cf23f`) — Android blocks cross-package data import by design. Possible workarounds documented elsewhere if user returns to it.
- [ ] Clean up `.claude/tmp/build*.log` (they got bloated during the long SDK download) — not blocking but noise.

## Decisions

- Bug = documented predictive-back warning (already triaged in fix doc).
  No new bug discovered in this session; the PageSizeMismatchDialog on
  Pixel 9 / Android 17 is a separate, larger workstream.
- Use a **two-phase** approach for 16 KB: Phase 1 (compressed packaging,
  zero-toolchain-change) ships fast; Phase 2 (real alignment via toolchain
  bump) is a separate PR with its own risk surface. Reasoning in ADR-0004.
- Skill names follow the existing `.agents/skills/<kebab-name>/SKILL.md`
  shape used by `accessibility` and `frontend-design` in this repo.
- Three skills, each one job:
  - `toolchain-upgrade` — the actual bump
  - `ndk-page-size-audit` — visibility into which `.so` is misaligned
  - `adb-page-size-toggle` — Pixel dev-options shortcut

## Blockers

- None on the back-button fix.
- 16 KB Phase 1 not yet started (waiting on user approval).
- 16 KB Phase 2 needs Phase 1 first OR a separate QA gate before touching
  the release signing chain.

## Next session starts here

Run `cat .agents/sessions/2026-08-25-pixel9-launch-bug-hunt.md` first
(that's this file). If the user picks Phase 1: read
`.agents/skills/adb-page-size-toggle/SKILL.md` to test the current APK on
both 4 KB and 16 KB modes for a quick reality check, then apply the two-line
edit in ADR-0004 Phase 1. If they pick Phase 2: load
`.agents/skills/toolchain-upgrade/SKILL.md` and follow steps 1-6 in order.