# HTTP — Dio + Retrofit (selectivo)

## Stack

- **`dio` 5.x** — HTTP client base. Usado directamente en la mayoría de
  servicios (Sonarr, Radarr, Lidarr, Tautulli, dashboard, search).
- **`retrofit` 4.x** + **`retrofit_generator` 9.x** — solo en **SABnzbd**
  y **NZBGet**, donde la API es lo bastante simple para anotaciones.
  Genera `api.g.dart` (no `*_Impl.g.dart`) a partir de una clase
  abstracta `@RestApi()` en `lib/api/<svc>/api.dart`.
- **Lidarr** y **Tautulli** usan Dio crudo con controllers en
  `lib/modules/<svc>/core/api/`. Esta es la convención cuando la API
  tiene endpoints muy irregulares o modelos no triviales — los demás
  servicios (Sonarr, Radarr) también usan Dio crudo + controllers, NO
  Retrofit.

## Where it lives

| Capa | Ruta real | Notas |
|------|-----------|-------|
| Network abstract / factory | `lib/system/network/network.dart` + `lib/system/network/platform/*` | `LunaNetwork` |
| Per-service Dio (Sonarr, Radarr) | `lib/api/<svc>/<svc>.dart` | `SonarrAPI(...)`, `RadarrAPI(...)` con `Dio` inline |
| Per-service Retrofit (SABnzbd, NZBGet) | `lib/api/<svc>/api.dart` | `@RestApi()` + `api.g.dart` |
| Per-service Dio (Lidarr, Tautulli) | `lib/modules/<svc>/core/api/api.dart` | Excepción: API vive dentro del módulo |
| Controllers / commands | `lib/api/<svc>/controllers/...` o `lib/api/<svc>/commands/...` | Wrappers tipados por endpoint |
| Models | `lib/api/<svc>/models/...` o `lib/modules/<svc>/core/api/data/...` | `@JsonSerializable` + `.g.dart` |
| HTTP request al backend | cada `LunaProfile.current` (Hive) | `host` + `apiKey` + `headers` |

## Adding a new endpoint to an existing service

1. Localiza el controller o `api.dart` correspondiente.
2. Añade el método (Dio crudo si no usa Retrofit, `@RestApi()` si sí).
3. Si el modelo es nuevo, créalo bajo `models/` o `core/api/data/` con
   `@JsonSerializable` y `defaultValue:` donde corresponda.
4. Run `npm run generate:build_runner` (genera los `.g.dart`).
5. Usa el endpoint: `await sonarrAPI.queue.get(1)`.

## Adding a brand new service

Ver [../modules/index.md](../modules/index.md) § "Adding a new module".

## Auth

- **Sonarr / Radarr / Lidarr:** API key como query string `apikey=`.
- **SABnzbd:** API key + `output=json` en query string.
- **NZBGet:** JSON-RPC, auth en cuerpo del request (username/password).
- **Tautulli:** API key como query string `apikey=`.
- Los headers custom se leen de `LunaProfile.current` (per-service).

No hay un interceptor central que inyecte headers — cada `*API` factory
los pasa al `Dio(BaseOptions(...))` directamente.
