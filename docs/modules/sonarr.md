# Sonarr module

Integration with [Sonarr](https://sonarr.tv/) — TV series management.

- Path: `lib/modules/sonarr/`
- Barrel: `lib/modules/sonarr.dart`
- API base URL: configured per profile in `LunaDatabase`
- API key: stored in `SonarrSettings` Hive box

## API surface

See `lib/modules/sonarr/src/api/sonarr_api.dart` for the Retrofit interface.
Endpoints covered: series, episodes, calendar, queue, history, commands,
quality profiles, etc.

## State

`SonarrState` (ChangeNotifier) holds the active profile, current series
cache, and recent activity. Read it from widgets; never call the API
directly from a widget.

## Adding a Sonarr feature

1. Add the endpoint method to `SonarrAPI` (Retrofit).
2. Run `npm run generate:build_runner`.
3. If it needs persistence, add a Hive type (see [../api/hive.md](../api/hive.md)).
4. Build the UI under `lib/modules/sonarr/src/widgets/`.
5. Register any new route in `lib/modules/sonarr/src/router.dart`.
