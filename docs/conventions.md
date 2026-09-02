# Conventions

> Style + rules. Apply on every change. No exceptions.

## Code style

| Rule | Why |
|------|-----|
| Dart stable channel | Matches CI |
| `dart format` before commit | No bikeshed in PR |
| `dart analyze lib/` clean | Blocks merge |
| Public classes prefixed `Luna` | Project-wide convention, enforced |
| `snake_case` files / dirs | Dart norm |
| `PascalCase` classes | Dart norm |
| `camelCase` vars / funcs | Dart norm |
| Immutability by default | Less state bugs |

## Naming

| What | Pattern | Example |
|------|---------|---------|
| Module folder | `lib/modules/<name>/` | `lib/modules/sonarr/` |
| State notifier | `<Module>State` | `LunaSonarrState` |
| API client | `<Module>API` | `LunaSonarrAPI` |
| Hive box | `<Module>Box` | `LunaSonarrBox` |
| Widget screen | `<Module>Home` | `SonarrHome` |
| Widget widget | `<Module>Widget` | `SonarrPoster` |

## Git

### Commits — Conventional Commits

```
feat(sonarr): add quality profile filter
fix(router): prevent back-button loop
docs(readme): document adb-wifi install
chore(deps): bump go_router to 14.8.1
refactor(api): split Dio client by service
test(sonarr): cover empty queue case
release: v11.1.0
```

Use `npm run commit` (walks you through).

### Branches

| Branch | Use |
|--------|-----|
| `master` | Stable. Tagged. |
| `beta` | Pre-release QA. |
| `feature/<slug>` | One feature or fix. From master. |
| `fix/<slug>` | Same as feature, scoped to bug. |

See `workflow.md` for full git lifecycle.

### Commit footer (mandatory for code changes)

```
feat(sonarr): add quality profile filter

Adds dropdown in Sonarr settings to filter series list
by quality profile. Stores selection in Hive box.

Docs: docs/features/sonarr-quality-profile-filter.md
Refs: #42
```

`Docs:` line points to `docs/features/<slug>.md` or `docs/fixes/<slug>.md`. Required when change ships user-visible behavior. Skip for pure refactor / chore.

## Doc hygiene

| When | Action |
|------|--------|
| New feature (>1 file, behavior change) | **Spec FIRST** en `docs/specs/<slug>/{requirements,design,tasks}.md`. Plantilla: `docs/specs/TEMPLATE/`. Al mergear: `docs/features/<slug>.md` (plantilla `docs/features/TEMPLATE.md`). Ver [SUMMARY.md](SUMMARY.md). |
| New module | `docs/modules/<name>.md` + nav entry en `mkdocs.yml` + case en `lib/modules.dart` `LunaModule` enum (regenerar `modules.g.dart`). |
| Bug fix | `docs/fixes/<slug>.md` same PR. Use template. |
| API / DB / route change | Update `docs/api/*.md`. |
| Architecture change | Write ADR in `docs/adr/`. |
| Session ends | Update `.agents/sessions/<date>-<slug>.md`. |
| Discover stale doc | Fix it in same PR. Don't defer. |

## Code-gen rules

| Rule | Why |
|------|-----|
| Never edit `*.g.dart`, `*.config.dart`, `spider.generated.dart` | Generated. Run `npm run generate`. |
| Hive: new fields at END | Reorder breaks user data. Use `defaultValue:`. |
| Run codegen BEFORE build | Missing = `MissingPluginException` at launch. |

## Forbidden

- ❌ Non-`Luna`-prefixed public classes.
- ❌ Generated files hand-edited.
- ❌ Hive field reorders.
- ❌ Skipping codegen.
- ❌ Prose where table works.
- ❌ Doc drift. If code changes, doc changes same PR.
