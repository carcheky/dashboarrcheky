# AGENTS.md

> Router for AI coding agents (Claude Code, Cursor, Codex, Copilot, Zed, ...).
> Read first. Load only what matches task. Caveman mode.

## Project

Fork LunaSea. Flutter app. Controls Sonarr, Radarr, Lidarr, SABnzbd, NZBGet, Tautulli from one UI.

- Lang: Dart. SDK >=3.7 <4.0. Flutter >=3.27.
- Android: minSdk 24, targetSdk 35. appId `app.lunasea.lunasea` (debug `.debug`).
- Build: Docker. See `docs/build.md`.
- Branching: master + beta + feature/*. SemVer. See `docs/workflow.md`.
- Active dev: `lunasea/`. Other top-level dirs are separate codebases. Don't touch.

## Mode

Caveman. Short words. No filler. Tables > prose. Code blocks > explanations.
Skip pleasantries. Lead with answer.

## Router — load by task

| Task | Load |
|------|------|
| Build APK / install / adb wifi | `docs/build.md` |
| **Spec a new feature (>1 file, behavior change)** | `docs/specs/TEMPLATE/` + `docs/SUMMARY.md` + `docs/adr/0005-spec-driven-workflow.md` |
| **Shipped feature doc (user-facing)** | `docs/features/TEMPLATE.md` + el `docs/modules/<name>.md` afectado |
| Bug fix | `docs/fixes/TEMPLATE.md` + `docs/troubleshooting.md` |
| HTTP endpoint | `docs/api/http.md` |
| Hive schema change | `docs/api/hive.md` |
| Route change | `docs/api/routing.md` |
| Git / release / tag | `docs/workflow.md` |
| Code style / naming | `docs/conventions.md` |
| Pick AI model per task | `docs/reference/models.md` + `.agents/skills/model-routing/SKILL.md` |
| Big picture / layout | `docs/architecture.md` |
| Why a decision | `docs/adr/index.md` |
| Lost / orientation | `docs/index.md` |
| **Spec vs Feature doc confusion** | `docs/SUMMARY.md` |
| Close session / handoff | `.agents/sessions/TEMPLATE.md` |

## Conventions (terse)

- ✅ Read router doc BEFORE editing module.
- ✅ Run `dart analyze lib/` in Docker after edit.
- ✅ Conventional Commits. Use `npm run commit` (walks you).
- ✅ New feature (>1 file, behavior change) → spec FIRST en `docs/specs/<slug>/{requirements,design,tasks}.md` (template en `docs/specs/TEMPLATE/`). Después, al mergear, `docs/features/<slug>.md`. Ver `docs/SUMMARY.md`.
- ✅ Bug fix → create `docs/fixes/<slug>.md` same PR.
- ✅ Session handoff → update `.agents/sessions/<date>-<slug>.md` before closing.
- ✅ Public Dart classes prefixed `Luna`.
- ✅ New Hive fields at end with `defaultValue:`. Never reorder.
- ✅ New module needs `docs/modules/<name>.md` + entry en `mkdocs.yml` + case en `lib/modules.dart` `LunaModule` enum (regenerar `modules.g.dart`).

## NEVER

- ❌ Edit `*.g.dart`, `*.config.dart`, `spider.generated.dart`. Run `npm run generate`.
- ❌ Reorder `@HiveField(N)`. Breaks user data.
- ❌ Skip `npm run generate` before `flutter build apk`. Crash on launch.
- ❌ Touch `lunasea-cloud-functions/`, `lunasea-notification-service/`, `lunasea-docs/` unless asked.
- ❌ Write prose where a table works.

## Build loop

```bash
docker compose -f docker-compose.android.yml run --rm build
adb install -r lunasea/build/app/outputs/flutter-apk/app-debug.apk
```

Or use skill `lunasea-build`.

## When lost

Read `docs/index.md` first. 30 lines. Maps the rest.
