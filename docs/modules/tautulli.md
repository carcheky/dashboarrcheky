# Tautulli module

Integration with [Tautulli](https://tautulli.com/) — Plex/Jellyfin
statistics companion.

- Path: `lib/modules/tautulli/`
- Barrel: `lib/modules/tautulli.dart`
- API: `TautulliAPI`
- State: `TautulliState`

## Notable

- Returns a flat list of activity events; rendering groups by user/library
  is done in the widget layer.
- Charts use `fl_chart` — see `lib/widgets/charts/`.
