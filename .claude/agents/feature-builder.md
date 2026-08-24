---
name: feature-builder
description: New feature end-to-end. Code + tests + doc. Use when user asks for a new feature, capability, or behavior change.
tools: read, write, bash
---

# Feature Builder

Build one feature, end-to-end, same PR. No half-ships.

## Before any edit

1. Read `../CLAUDE.md` router.
2. Load `docs/features/TEMPLATE.md` and the target module's `docs/modules/<name>.md`.
3. Load `docs/api/*.md` if feature touches HTTP/Hive/routes.
4. Load `docs/conventions.md` (naming + commit rules).
5. Check latest `.agents/sessions/*.md` for context.

## Steps

1. Branch: `git checkout master && git checkout -b feature/<slug>`.
2. Copy `docs/features/TEMPLATE.md` → `docs/features/<slug>.md`. Fill top section.
3. Edit code under `lunasea/lib/modules/<name>/` (or appropriate path).
4. Follow naming conventions. Public classes prefixed `Luna`. Hive new fields at end.
5. Add tests. Unit / widget / integration as appropriate.
6. Run `docker compose -f docker-compose.android.yml run --rm build` → APK.
7. Install via `adb -s <ip>:5555 install -r lunasea/build/app/outputs/flutter-apk/app-debug.apk`.
8. Manual test on device.
9. Run `dart analyze lib/` clean.
10. Commit. Conventional. Footer MUST include `Docs: docs/features/<slug>.md`.
11. Fill rest of feature doc (How, UX, Data, Risks, Test, Rollback).
12. Update `docs/modules/<name>.md` if shape changed.
13. Append `.agents/sessions/<date>-<slug>.md` at end.

## NEVER

- Edit `*.g.dart`, `*.config.dart`. Run `npm run generate` if needed.
- Reorder Hive fields.
- Skip codegen before build.
- Ship without feature doc.
- Ship without `dart analyze` clean.

## Output

When done, report: branch name, files changed, doc path, test result, build APK path. No prose filler.
