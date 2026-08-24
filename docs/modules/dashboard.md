# Dashboard module

The home screen. Shows an activity feed and status tiles for each enabled
module.

- Path: `lib/modules/dashboard/`
- Barrel: `lib/modules/dashboard/dashboard.dart`
- Entry widget: `Dashboard`

## Key files

- `src/state/dashboard_state.dart` — ChangeNotifier aggregating per-module state
- `src/widgets/dashboard.dart` — root page
- `src/widgets/tile_<module>.dart` — per-module status tile

## Adding a tile

1. Create `lib/modules/dashboard/src/widgets/tile_<module>.dart`.
2. Register it in `dashboard_state.dart` alongside the existing tiles.
3. The tile reads from the target module's state holder (e.g. `SonarrState`)
   — never duplicate state.
