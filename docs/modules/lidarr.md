# Lidarr module

Integration with [Lidarr](https://lidarr.audio/) — music management.

- Path: `lib/modules/lidarr/`
- Barrel: `lib/modules/lidarr.dart` (exporta `lidarr/core.dart`,
  `lidarr/routes.dart`, `lidarr/widgets.dart`)
- HTTP: **`lib/modules/lidarr/core/api/api.dart`** — `LidarrAPI`
  factory, **Dio crudo, NO Retrofit**
- State: `lib/modules/lidarr/core/state.dart` (`LunaLidarrState`)
- Routes: `lib/modules/lidarr/routes.dart` (barrel) + `routes/<sub>/route.dart`

## ⚠ Asimetría estructural con Sonarr/Radarr

Lidarr **rompe** la convención de la mayoría de módulos:

| Capa | Sonarr / Radarr | Lidarr |
|------|----------------|--------|
| HTTP client | `lib/api/<svc>/<svc>.dart` (factory con controllers) | `lib/modules/lidarr/core/api/api.dart` (Dio crudo, data/ folder) |
| Models | `lib/api/<svc>/models/` | `lib/modules/lidarr/core/api/data/` |

**Razón histórica:** Lidarr viene de un fork temprano del código y
nunca se migró a la separación `api/`+`modules/`. Tautulli tiene la
misma peculiaridad (`lib/modules/tautulli/core/api/`).

**Implicación práctica:** si vas a añadir un endpoint a Lidarr,
edita `lib/modules/lidarr/core/api/api.dart` directamente y crea el
modelo en `lib/modules/lidarr/core/api/data/`. **No** busques
`lib/api/lidarr/` — no existe.

## Notable differences from Sonarr/Radarr

- Jerarquía: `artist` (top level) → `album` → `track`.
- Track files viven bajo albums, no directamente bajo artists.
- Tiene `metadataProfile` + `qualityProfile` (Sonarr solo tiene
  `qualityProfile`).
- API key en query string `apikey=`, base URL `/api/v1/` (no v3 como
  Sonarr/Radarr).

## Adding a Lidarr feature

1. Endpoint nuevo: método en `lib/modules/lidarr/core/api/api.dart` +
   modelo en `lib/modules/lidarr/core/api/data/`.
2. Exponer vía `lib/modules/lidarr/core/state.dart` (extender
   `LunaLidarrState`).
3. UI bajo `lib/modules/lidarr/routes/<sub>/widgets/`.
4. Ruta: añadir export a `lib/modules/lidarr/routes.dart` y el
   `GoRoute` en el `route.dart` correspondiente.
5. `npm run generate:build_runner` y `dart analyze lib/`.
