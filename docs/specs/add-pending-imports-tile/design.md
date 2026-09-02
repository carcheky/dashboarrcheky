# Spec — `add-pending-imports-tile` — Design

> **How** the requirements are met. Tech choices, file paths, data shapes.
> Approved before any code lands.

**Status:** draft (awaiting requirements sign-off re-confirm)
**Pairs with:** `requirements.md`

## Approach

The Dashboard already has a `DashboardState` ChangeNotifier that aggregates
per-module state. We extend it with a new `pendingImports` slice that holds
a per-service list of queue records whose `status` is one of
`completed | warning | failed | delay` (the "needs my attention" set).

A new tile widget reads from this state, shows a per-service count + total,
and a `LunaListView` of rows. Each row opens the import modal (native
modal sheet, not a separate route) or fires the deep-link to the *arr web
UI.

The tile register itself in the existing `tile_<module>.dart` pattern
(see `lunasea/lib/modules/dashboard/routes/dashboard/pages/modules.dart`
for the per-module pattern, and the calendar page for the existing
dashboard page layout we extend).

We add the missing Sonarr endpoints by mirroring the existing Radarr
manual_import controller (same shape, just Sonarr-flavored names and
field types). Reuse Radarr's pattern verbatim where the API contract is
identical (`POST /api/v3/manualimport` accepts the same `files[]` array).

## Affected files

| Path | Status | Change | Why |
|------|--------|--------|-----|
| `lunasea/lib/api/sonarr/types/import_mode.dart` | NEW | enum + extension mirroring `RadarrImportMode` | spec calls for 2 modes in modal |
| `lunasea/lib/api/sonarr/models/manual_import/manual_import.dart` | NEW | `SonarrManualImport` mirror of `RadarrManualImport` | response model for `GET /manualimport` |
| `lunasea/lib/api/sonarr/models/manual_import/manual_import_file.dart` | NEW | `SonarrManualImportFile` mirror | per-file import payload |
| `lunasea/lib/api/sonarr/models/manual_import/manual_import_update.dart` | NEW | `SonarrManualImportUpdate` (response) | — |
| `lunasea/lib/api/sonarr/models/manual_import/manual_import_update_data.dart` | NEW | `SonarrManualImportUpdateData` (request) | — |
| `lunasea/lib/api/sonarr/models/manual_import/manual_import_rejection.dart` | NEW | `SonarrManualImportRejection` | — |
| `lunasea/lib/api/sonarr/models/manual_import/manual_import.g.dart` | GEN | `dart run build_runner build` | generated from `manual_import.dart` |
| `lunasea/lib/api/sonarr/commands/manual_import/get_manual_import.dart` | NEW | `_commandGetManualImport` mirror | `GET /api/v3/manualimport?folder=...` |
| `lunasea/lib/api/sonarr/commands/manual_import.dart` | NEW | `SonarrCommandHandlerManualImport.get(folder)` | facade |
| `lunasea/lib/api/sonarr/commands/command/manual_import.dart` | NEW | `_commandManualImport` (POST `/api/v3/command` with name=ManualImport) | Sonarr uses command endpoint, not /manualimport |
| `lunasea/lib/api/sonarr/controllers/command.dart` | MODIFY | add `manualImport(files, importMode)` method | wiring |
| `lunasea/lib/api/sonarr/controllers/manual_import.dart` | NEW | `SonarrControllerManualImport.get(folder)` | facade over the GET command |
| `lunasea/lib/api/sonarr/sonarr.dart` | MODIFY | register new handler in `_SonarrAPI` getter (verify) | facade export |
| `lunasea/lib/modules/dashboard/core/state.dart` | MODIFY | add `pendingImports` field + `refreshPendingImports()` | cache + refresh |
| `lunasea/lib/modules/dashboard/core/types/pending_import.dart` | NEW | `LunaPendingImport` value type wrapping `SonarrQueueRecord` / `RadarrQueueRecord` + service tag | UI doesn't depend on a specific service |
| `lunasea/lib/modules/dashboard/routes/dashboard/widgets/tile_pending_imports.dart` | NEW | the tile widget | the main deliverable |
| `lunasea/lib/modules/dashboard/routes/dashboard/widgets/pending_import_row.dart` | NEW | row widget per item | single line per record |
| `lunasea/lib/modules/dashboard/routes/dashboard/widgets/pending_import_modal.dart` | NEW | bottom-sheet modal: folder picker + importMode selector | the import flow |
| `lunasea/lib/router/routes/dashboard.dart` | MODIFY | verify no new route needed (modal is sheet) | — |
| `localization/dashboard/en.json` | MODIFY | add i18n keys | i18n |
| `docs/features/add-pending-imports-tile.md` | NEW | user-facing doc | per change-type convention |
| `docs/modules/dashboard.md` | MODIFY | update "Key files" section with new tile | doc hygiene |
| `docs/roadmap.md` | MODIFY | flip row 8 from `[ ]` to `[~]` (spec drafted) | status update |
| `docs/timeline.md` | MODIFY | add new row once shipped | per change-type convention |

## Data

### New Hive fields

**None.** All state for this tile is in-memory in `DashboardState`. The
refresh interval, default import mode, etc. are not persisted in this
spec (see Out of Scope in requirements.md).

### New API endpoints

| Method | Path | Auth | Response |
|--------|------|------|----------|
| `GET` | `/api/v3/queue?page=1&pageSize=20` (Sonarr) | X-Api-Key | `SonarrQueuePage` (already mapped, filter client-side) |
| `GET` | `/api/v3/queue?page=1&pageSize=20` (Radarr) | X-Api-Key | same, Radarr-flavored |
| `GET` | `/api/v3/manualimport?folder=<path>` (Sonarr, NEW) | X-Api-Key | `List<SonarrManualImport>` |
| `GET` | `/api/v3/manualimport?folder=<path>` (Radarr, NEW facade) | X-Api-Key | `List<RadarrManualImport>` (already mapped, expose via `Sonarr`-style facade for symmetry) |
| `POST` | `/api/v3/command` body `{"name":"ManualImport","importMode":"copy","files":[{...}]}` (Sonarr, NEW) | X-Api-Key | `SonarrCommand` |
| `POST` | `/api/v3/manualimport` body `List<RadarrManualImportUpdateData>` (Radarr, already mapped) | X-Api-Key | `List<RadarrManualImportUpdate>` |

### New route

None. The import modal is a `showModalBottomSheet` (Luna pattern), not a
new go_route.

### State shape

```dart
// In DashboardState
Map<LunaModule, List<LunaPendingImport>> pendingImports;  // per-service
Timer? _pendingImportsTimer;

Future<void> refreshPendingImports() async { ... }
```

`LunaPendingImport` is a small value type:

```dart
class LunaPendingImport {
  final LunaModule service;          // SONARR or RADARR
  final String title;                // series/movie title
  final String subtitle;             // episode "SxxEyy - name" or empty
  final int queueId;                 // for delete from queue if needed
  final String downloadId;           // for manualImport command
  final String? downloadPath;        // candidate folder root
  final int? seriesId;               // Sonarr-only, for filter
  final int? episodeId;              // Sonarr-only
  final int? movieId;                // Radarr-only
  final String status;               // raw status string for color
}
```

## Behaviour

| Situation | Expected |
|-----------|----------|
| Dashboard opened, both services enabled, no pending imports | Tile shows "Todo limpio" with grey icon |
| Dashboard opened, 3 Sonarr + 2 Radarr pending | Tile shows "Sonarr (3) · Radarr (2)" header, list with section headers, total = 5 |
| User taps "Importar ahora" on a Sonarr row | Modal opens. If `downloadPath` is null, show "Open in web" hint instead |
| Modal: user picks folder | Selector for importMode appears below, "Copy-Hardlink" preselected |
| Modal: user confirms | Loading spinner; on success, modal closes, list refreshes, row disappears |
| Modal: API returns error | Modal stays open with error message in red, "Reintentar" button visible |
| User taps "Abrir en web" | `url_launcher` opens `<baseUrl>/activity/queue` in system browser |
| App goes to background | `WidgetsBindingObserver.didChangeAppLifecycleState(paused)` cancels the timer |
| App returns to foreground | Timer is restarted; first refresh happens immediately |
| API key invalid / service offline | Tile shows red error banner with "Reintentar" button (does not crash, does not block other tiles) |
| User pulls down on tile | `RefreshIndicator` triggers `refreshPendingImports()` immediately |

## Risks

| Risk | Mitigation |
|------|------------|
| `copyUsingHardlinks` is OFF in user's *arr → "Copy-Hardlink" preselection actually copies (duplicates space) | Document in modal: "Copy-Hardlink uses hardlink if the service has it enabled; otherwise copies." User can switch to Move. |
| User has many stuck items (50+) → UI lag | Page server-side: `pageSize=20`, "Ver más" button to fetch next page |
| Sonarr endpoint `/api/v3/manualimport` returns HTML on old versions | Defensive: try JSON parse, fall back to "Open in web" + message |
| Manual import takes a long time on big files | Modal stays open with spinner until command completes or 60s timeout; on timeout show "Import started, check service UI" |
| Cross-filesystem import (downloads on /mnt/downloads, library on /mnt/library) breaks hardlink | Out of our control; the *arr handles this correctly with copy fallback. Document in modal text. |
| Timer fires while modal is open | Cancel timer during modal open; restart on dismiss |

## Rejected alternatives

- **Use `url_launcher` to open the *arr web UI for everything (no
  in-app import modal).** Rejected because the user's pain is precisely
  the switching-app friction. Doing the import in-app is the whole
  point.
- **Build a separate "Stack Status" screen that contains this tile plus
  disk-space and health tiles.** Rejected in planning — tiles are
  independent and discoverable in the Dashboard.
- **Make the import mode configurable per-user in Settings.** Deferred —
  Copy-Hardlink hardcoded as default. Configurable is a future spec if
  the user requests it.
- **Use deep-link to the specific queue item (`/queue/{id}`).** Rejected —
  verified that no stable URL exists per item. Open `/activity/queue`.
- **Listen to *arr webhooks for instant refresh.** Out of scope —
  requires webhook setup on the *arr side. Polling at 60s is sufficient
  for the user's stated pain.
- **Use server-sent events (SSE) for live updates.** Overkill for a
  60s polling tile; revisit if user demands real-time.

## References

- Requirements: `requirements.md`
- Plan maestro: `.hermes/plans/2026-09-01_120124-dashboard-stack-widgets.md`
- Sonarr issue #8510 (not_planned, irrelevant to this spec)
- Sonarr issue #8647 (example body with `importMode: "auto"` — we use
  "copy" / "move" only)
- Existing Radarr manual_import pattern:
  `lunasea/lib/api/radarr/commands/manual_import.dart`,
  `lunasea/lib/api/radarr/commands/command/manual_import.dart`,
  `lunasea/lib/api/radarr/models/manual_import/manual_import_file.dart`
- Existing Dashboard state pattern:
  `lunasea/lib/modules/dashboard/core/state.dart`
- ADR-0005 (why we use this 3-file spec format)
