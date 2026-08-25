# Timeline

> Chronological view of the fork. Past (shipped) + present + planned.
> Single source of truth for "what's done, what's next". Use with `roadmap.md`
> (which adds priority, owner, and rough horizon).

## Past — shipped

Ordered by merge date. Tag = SemVer tag. Branch = integration branch.

| Date | Tag / Commit | What | Why | Docs |
|------|--------------|------|-----|------|
| baseline | `v11.0.0` (`6ee0bf9a`) | Forked from upstream LunaSea monorepo. 9 modules: dashboard, external_modules, lidarr, nzbget, radarr, sabnzbd, search, settings, sonarr, tautulli. Overseerr declared in `modules.dart` but no module folder yet. | Carrying the public repos under `carcheky/dashboarrcheky` | — |
| 2026-08-24 | `df320181` | Token-efficient doc system: caveman mode, llms.txt, sub-agents. `CLAUDE.md`/router + `.agents/skills/{accessibility,frontend-design}` + `.claude/agents/{fix-investigator,feature-builder,docs-keeper}`. | Humans and AI agents read the same docs; minimum tokens | ADR-0003 |
| 2026-08-25 | `7f6746f0` | **fix(core)**: migrate `WillPopScope` → `PopScope` in `luna_sea/lib/widgets/ui/scaffold.dart` + opt into `enableOnBackInvokedCallback="true"` in `AndroidManifest.xml`. Predictive-back warning gone on Pixel 9 / Android 17. | Android 13+ back-nav API requires no `WillPopScope` | `docs/fixes/android-predictive-back.md` |
| 2026-08-25 | `98c647a6` | **docs(adr-0004)**: toolchain + 16 KB page-size plan. Phase 1 (compressed packaging, 5-line edit) + Phase 2 (AGP/Gradle/Kotlin/NDK bump). Three skills: `toolchain-upgrade`, `ndk-page-size-audit`, `adb-page-size-toggle`. Reference `docs/reference/toolchain.md`. | Pixel 9 / Android 17 shows `PageSizeMismatchDialog` on debug APK; AGP 8.1.0 + Gradle 8.0 predate 16 KB tooling | ADR-0004 |
| 2026-08-25 | `05b9c26d` | **docs(adr-0005)**: spec-driven workflow. `docs/specs/<slug>/{requirements,design,tasks}.md` committed before code for any change >1 file. Three skills: `spec-driven-feature`, `todo-discipline`, `worktree-isolation`. | Stop wasting tokens on misaligned vibe-coding sessions | ADR-0005 |
| 2026-08-25 | `61770766` | **docs**: nav refresh (Specs section, Reference/Toolchain, ADR-0004/0005) + landing hero + expanded `architecture.md`. | Make new docs discoverable | — |
| 2026-08-25 | `353e5d98` | **docs**: session handoff for pixel9-launch-bug-hunt + 16 KB. | Next session reads latest first | `.agents/sessions/` |
| 2026-08-25 | `06f93724` | Merge `fix/pixel9-launch-bug-hunt` into beta. All five above commits + the merge commit. | First beta cut with predictive-back fix | — |
| 2026-08-26 | `0a370ed9` | **chore**: track `.github/workflows/docs.yml` + `docs/stylesheets/extra.css` (left untracked from docs-system-bootstrap). | Stop the "0 changes" drift | — |

## Present — in flight

| Item | Status | Owner | Doc |
|------|--------|-------|-----|
| 16 KB Phase 1 (compressed packaging) | proposed, awaiting user OK | n/a | ADR-0004 § Phase 1 |
| 16 KB Phase 2 (AGP/Gradle/Kotlin/NDK bump) | proposed, blocked on Phase 1 | n/a | ADR-0004 § Phase 2 |
| Back-button matrix verify (4 rows) | partial — device was locked mid-test | next session | `docs/fixes/android-predictive-back.md` § Test |

## Future — planned

See `docs/roadmap.md` for the prioritised list with horizon and effort.
Files in `docs/features/<slug>.md` carry the per-feature spec once each
moves out of `proposed` (per ADR-0005).

## How to add a row

When you ship something:

1. Add a row under **Past — shipped** with date, commit/tag, what, why, doc link.
2. If it's a feature, the commit footer is `Docs: docs/features/<slug>.md` per `conventions.md`.
3. If it's a bug fix, the commit footer is `Docs: docs/fixes/<slug>.md`.
4. If it's a decision, the commit footer references the ADR (`Refs: docs/adr/<id>-*.md`).
5. If it kills an in-flight item, move it out of **Present** into **Past**.

## See also

- `docs/roadmap.md` — prioritised future list
- `.agents/sessions/<latest>.md` — current session, what to do next
- `docs/adr/index.md` — every decision
- `docs/fixes/` — one per shipped fix
- `docs/features/` — one per shipped feature