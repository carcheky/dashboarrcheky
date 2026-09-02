# Spec — `add-pending-imports-tile` — Tasks

> Ordered work breakdown. One row per agent step. Same shape as `todo`.
> Cross out a row when done.

**Status:** draft
**Pairs with:** `requirements.md`, `design.md`
**Branch:** `feature/add-pending-imports-tile`

## Order

1. [ ] Spec files committed
2. [ ] Verify API state (queue, system, manualimport exist for both)
3. [ ] Create Sonarr models (mirror RadarrManualImport*)
4. [ ] Create Sonarr controllers (mirrors Radarr)
5. [ ] Add LuminaPendingImport value type
6. [ ] Extend DashboardState with pendingImports slice + timer
7. [ ] Build tile_pending_imports widget (shell)
8. [ ] Build pending_import_row widget
9. [ ] Build pending_import_modal (folder picker + mode selector + confirm)
10. [ ] Wire modal cancel-on-open + lifecycle pause/resume
11. [ ] Localization
12. [ ] dart analyze + build APK + smoke test on device
13. [ ] Commit + PR + merge to beta
14. [ ] Flip row 8 in roadmap.md, add timeline.md entry, create feature doc

## Tasks

| # | Task | Files | Sub-agent |
|---|------|-------|-----------|
| 1 | Re-read design.md to internalize the file list | — | `feature-builder` |
| 2 | Verify Sonarr `GET /api/v3/queue` already mapped in `controllers/queue.dart` | `lunasea/lib/api/sonarr/controllers/queue.dart` | `feature-builder` |
| 3 | Verify Radarr `GET /api/v3/queue`, `GET /api/v3/manualimport`, `POST /api/v3/manualimport` already mapped | `lunasea/lib/api/radarr/commands/queue.dart`, `commands/manual_import.dart`, `commands/command.dart` | `feature-builder` |
| 4 | Write `SonarrImportMode` enum (COPY, MOVE) + extension (mirror `RadarrImportMode`) | `lunasea/lib/api/sonarr/types/import_mode.dart` | `feature-builder` |
| 5 | Write `SonarrManualImport` (mirror Radarr — fields: path, relativePath, folderName, name, size, series, episode, quality, languages, qualityWeight, rejections, id) | `lunasea/lib/api/sonarr/models/manual_import/manual_import.dart` | `feature-builder` |
| 6 | Write `SonarrManualImportFile` (path, seriesId?, episodeIds[], quality, languages) | `.../models/manual_import/manual_import_file.dart` | `feature-builder` |
| 7 | Write `SonarrManualImportUpdate` (response, mirrors Radarr) | `.../models/manual_import/manual_import_update.dart` | `feature-builder` |
| 8 | Write `SonarrManualImportUpdateData` (request: id, path, seriesId?, episodeIds[], quality, languages) | `.../models/manual_import/manual_import_update_data.dart` | `feature-builder` |
| 9 | Write `SonarrManualImportRejection` (mirrors Radarr) | `.../models/manual_import/manual_import_rejection.dart` | `feature-builder` |
| 10 | Run `dart run build_runner build --delete-conflicting-outputs` to generate `.g.dart` files | — | `feature-builder` |
| 11 | Write `_commandGetManualImport(Dio client, folder)` (GET /api/v3/manualimport) | `lunasea/lib/api/sonarr/commands/manual_import/get_manual_import.dart` | `feature-builder` |
| 12 | Write `SonarrCommandHandlerManualImport.get(folder)` facade | `lunasea/lib/api/sonarr/commands/manual_import.dart` | `feature-builder` |
| 13 | Write `_commandManualImport(Dio client, files, importMode)` (POST /api/v3/command body=`{name:"ManualImport", importMode, files}`) | `lunasea/lib/api/sonarr/commands/command/manual_import.dart` | `feature-builder` |
| 14 | Add `manualImport(files, importMode)` method to `SonarrControllerCommand` | `lunasea/lib/api/sonarr/controllers/command.dart` | `feature-builder` |
| 15 | Add `SonarrControllerManualImport.get(folder)` facade | `lunasea/lib/api/sonarr/controllers/manual_import.dart` | `feature-builder` |
| 16 | Verify `SonarrAPI` getter in `sonarr.dart` exposes the new handlers (add if missing) | `lunasea/lib/api/sonarr/sonarr.dart` | `feature-builder` |
| 17 | Commit Sonarr API additions: `feat(sonarr): add manualImport + importMode endpoints` | — | `feature-builder` |
| 18 | Write `LunaPendingImport` value type in dashboard/core/types | `lunasea/lib/modules/dashboard/core/types/pending_import.dart` | `feature-builder` |
| 19 | Extend `DashboardState`: add `pendingImports` map + `refreshPendingImports()` method + 60s timer + lifecycle observer | `lunasea/lib/modules/dashboard/core/state.dart` | `feature-builder` |
| 20 | Wire timer into Dashboard page `initState`/`dispose` and `WidgetsBindingObserver` | `lunasea/lib/modules/dashboard/routes/dashboard/route.dart` (or page) | `feature-builder` |
| 21 | Build `tile_pending_imports.dart`: LunaBlock-like card, sectioned by service, LunaListView of rows, RefreshIndicator | `lunasea/lib/modules/dashboard/routes/dashboard/widgets/tile_pending_imports.dart` | `feature-builder` |
| 22 | Build `pending_import_row.dart`: title (series/movie), subtitle (episode), status pill, two trailing buttons | `lunasea/lib/modules/dashboard/routes/dashboard/widgets/pending_import_row.dart` | `feature-builder` |
| 23 | Build `pending_import_modal.dart`: folder picker (LunaListView) + importMode radio (Copy-Hardlink default) + Confirm button + error banner | `lunasea/lib/modules/dashboard/routes/dashboard/widgets/pending_import_modal.dart` | `feature-builder` |
| 24 | In modal: on confirm, call `SonarrAPI.command.manualImport(...)` or `RadarrAPI.commandHandler.command.manualImport(...)`, handle errors | — | `feature-builder` |
| 25 | In tile: on "Abrir en web", use `url_launcher` to open `<baseUrl>/activity/queue` | — | `feature-builder` |
| 26 | Pause timer while modal is open; resume on dismiss | `state.dart` | `feature-builder` |
| 27 | Add i18n keys to `localization/dashboard/en.json`: `dashboard.PendingImports`, `dashboard.NoPendingImports`, `dashboard.ImportNow`, `dashboard.OpenInWeb`, `dashboard.ImportModeCopy`, `dashboard.ImportModeMove`, `dashboard.SelectFolder`, `dashboard.ConfirmImport`, `dashboard.ImportFailed` | `lunasea/localization/dashboard/en.json` | `feature-builder` |
| 28 | Run `dart analyze lib/` in Docker, fix any new warnings | — | `feature-builder` |
| 29 | Build APK debug: `docker compose -f docker-compose.android.yml run --rm build` | — | `lunasea-build` |
| 30 | Install on device: `adb -s <pixel> install -r lunasea/build/app/outputs/flutter-apk/app-debug.apk` | — | manual |
| 31 | Smoke test on Pixel 9: open Dashboard, see tile counts, tap a warning row, modal opens, folder picker shows, mode selector works, confirm, modal closes, row disappears | — | manual |
| 32 | Commit UI: `feat(dashboard): add pending imports tile` with footer `Docs: docs/specs/add-pending-imports-tile/design.md` and `Docs: docs/features/add-pending-imports-tile.md` | — | `feature-builder` |
| 33 | Open PR against `beta` | — | `feature-builder` |
| 34 | Merge PR after CI green | — | manual |
| 35 | Create `docs/features/add-pending-imports-tile.md` (user-facing doc, copy user stories + screenshots placeholders) | `docs/features/add-pending-imports-tile.md` | `docs-keeper` |
| 36 | Flip row 8 in `docs/roadmap.md` from `[ ]` to `[x]`; add row to `docs/timeline.md` | `docs/roadmap.md`, `docs/timeline.md` | `docs-keeper` |
| 37 | Update `docs/modules/dashboard.md` "Key files" section with new tile files | `docs/modules/dashboard.md` | `docs-keeper` |

## Done when

- [ ] All 37 rows above are checked.
- [ ] `dart analyze lib/` clean.
- [ ] APK installs and reproduces the happy path on Pixel 9.
- [ ] `docs/features/add-pending-imports-tile.md` created with all sections filled.
- [ ] Commit footer `Docs:` points to both the spec dir and the feature doc.
- [ ] Row 8 in `docs/roadmap.md` is `[x]` and `docs/timeline.md` has a new row.
- [ ] PR merged to `beta`.

## References

- Requirements: `requirements.md`
- Design: `design.md`
- Plan maestro: `.hermes/plans/2026-09-01_120124-dashboard-stack-widgets.md`
- Skill: `.agents/skills/spec-driven-feature/SKILL.md`
- Skill: `.agents/skills/plan/SKILL.md`
- Module docs: `../../modules/dashboard.md`, `../../modules/sonarr.md`,
  `../../modules/radarr.md`
- API docs: `../../api/http.md`, `../../api/hive.md`
