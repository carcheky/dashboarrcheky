# Settings module

App-wide settings + per-module enable/disable + per-service profile
configuration.

- Path: `lib/modules/settings/`
- Barrel: `lib/modules/settings.dart`
- Entry: `SettingsPage`

## Sub-screens

- `SettingsPage` — top-level list
- `SettingsConfigurationProfilesPage` — add/edit/delete service profiles
- `SettingsConfigurationModulesPage` — enable/disable modules
- `<Service>SettingsPage` — one per service (Sonarr, Radarr, …)

## Adding a new top-level setting

1. Add the tile to `SettingsPage`.
2. If it needs a sub-screen, create it under `src/screens/`.
3. If the value persists, use `LunaDatabase` (Hive) — never SharedPreferences.
