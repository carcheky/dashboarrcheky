# Sonarr module

Integration with [Sonarr](https://sonarr.tv/) — TV series management.

- Path: `lib/modules/sonarr/`
- Barrel: `lib/modules/sonarr.dart` (no existe como archivo, lo exporta `lib/modules/sonarr/core.dart` desde `lib/modules.dart` via `export 'modules/sonarr/...';` en `lib/modules.dart`)
- HTTP: `lib/api/sonarr/sonarr.dart` (`SonarrAPI` factory) + `lib/api/sonarr/controllers/*.dart`
- State: `lib/modules/sonarr/core/state.dart` (`LunaSonarrState`, ChangeNotifier)
- Routes: `lib/modules/sonarr/routes.dart` (barrel) + `lib/modules/sonarr/routes/<sub>/route.dart`
- Per-profile config: `lib/database/tables/sonarr.dart` + `lib/database/models/profile.dart` (`sonarrHost`, `sonarrKey`, `sonarrHeaders`)

## HTTP surface

Sonarr usa **Dio crudo + controllers**, no Retrofit. Cada controller
(`SonarrControllerQueue`, `SonarrControllerCommand`, etc.) envuelve
llamadas tipadas sobre el `Dio` de `SonarrAPI`.

Endpoints cubiertos: series, episodes, calendar, queue, history,
commands, quality profiles, etc. — ver
`lib/api/sonarr/controllers/`.

Auth: API key como query string `apikey=`. Inyectada por `SonarrAPI`
factory leyendo `LunaProfile.current`.

## State

`LunaSonarrState` (`lib/modules/sonarr/core/state.dart`) es un
`ChangeNotifier` que mantiene el profile activo + caché + datos
derivados. La UI **lee del state**, nunca llama al API directamente.

## Adding a Sonarr feature

1. Si hace falta un endpoint nuevo: añadir método en
   `lib/api/sonarr/sonarr.dart` (factory) + un nuevo controller en
   `lib/api/sonarr/controllers/`. Si solo es lógica nueva, saltar este
   paso.
2. Si necesita persistencia: añadir Hive field (ver
   [../api/hive.md](../api/hive.md)). **Nunca** reordenar `@HiveField`.
3. Exponer vía `lib/modules/sonarr/core/state.dart` (extender
   `LunaSonarrState`) — la UI no llama al API directamente.
4. UI: nuevo widget bajo `lib/modules/sonarr/routes/<sub>/widgets/`.
5. Ruta: añadir un export a `lib/modules/sonarr/routes.dart` y el
   `GoRoute` en el `route.dart` correspondiente. Registrar en
   `lib/router/routes/sonarr.dart` si es un entry point nuevo.
6. `npm run generate:build_runner` y `dart analyze lib/`.
