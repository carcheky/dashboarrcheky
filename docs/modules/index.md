# Modules

> One section per self-hosted service. Same shape each.

## Map

| Module | Service | Path |
|--------|---------|------|
| [dashboard](dashboard.md) | Home + launcher | `lib/modules/dashboard/` |
| [sonarr](sonarr.md) | Series manager | `lib/modules/sonarr/` |
| [radarr](radarr.md) | Movie manager | `lib/modules/radarr/` |
| [lidarr](lidarr.md) | Music manager | `lib/modules/lidarr/` (API dentro del módulo) |
| [sabnzbd](sabnzbd.md) | Usenet downloader | `lib/modules/sabnzbd/` (Retrofit) |
| [nzbget](nzbget.md) | Usenet downloader (alt) | `lib/modules/nzbget/` (Retrofit + JSON-RPC) |
| [tautulli](tautulli.md) | Plex stats | `lib/modules/tautulli/` (API dentro del módulo) |
| [search](search.md) | Newznab/Torznab indexer search | `lib/modules/search/` |
| [settings](settings.md) | Global config | `lib/modules/settings/` |
| [external_modules](external_modules.md) | User-added launcher tiles | `lib/modules/external_modules/` |
| [wake_on_lan](wake_on_lan.md) | Magic-packet action (no es módulo) | `lib/api/wake_on_lan/` |

## Per-module shape

Each module doc covers:

1. **Purpose** — what service, what user does.
2. **API surface** — endpoints consumed, auth, headers.
3. **Local state** — Hive boxes, keys, schema version.
4. **Routes** — screens, deep links.
5. **Known issues** — broken behavior, workarounds.
6. **Recent features / fixes** — link to `../features/` and `../fixes/`.

## Adding a feature to a module

1. Create `feature/<slug>` branch desde `master`.
2. **Antes de tocar código**, abrir spec en
   `docs/specs/<slug>/{requirements,design,tasks}.md` (template en
   `../specs/TEMPLATE/`). Ver [../adr/0005-spec-driven-workflow.md](../adr/0005-spec-driven-workflow.md).
3. Edit code under `lib/modules/<name>/` (y `lib/api/<name>/` si hace
   falta).
4. Cuando el código se mergea, crear `docs/features/<slug>.md` (template
   en `../features/TEMPLATE.md`) — este es el doc user-facing.
5. Actualizar `docs/modules/<name>.md` si cambió la forma del módulo
   (rutas nuevas, Hive fields nuevos, etc).
6. Flip del row correspondiente en `../roadmap.md` + entrada nueva en
   `../timeline.md` "Past — shipped".
7. Conventional Commit con footer `Docs: docs/features/<slug>.md`.
8. PR → `beta` → cherry-pick / merge a `master`.

> ⚠ **Doble doc por feature:** `docs/specs/<slug>/` (técnico, 3 archivos,
> antes de codear) + `docs/features/<slug>.md` (user-facing, al
> mergear). `docs/specs/` es el proceso; `docs/features/` es el
> entregable. Ver [../SUMMARY.md](../SUMMARY.md) § "Specs vs Features".

## Adding a new module

1. Spec en `docs/specs/<slug>-module/{requirements,design,tasks}.md`
   siguiendo el template.
2. Crear `lib/api/<name>/` con factory + controllers + models
   (Dio crudo por defecto; Retrofit solo si la API es muy regular).
   Excepción: si el módulo es "dentro-del-módulo" como Lidarr/Tautulli,
   todo va en `lib/modules/<name>/core/api/`.
3. Crear `lib/modules/<name>/` con `core/state.dart` (ChangeNotifier) +
   `routes.dart` (barrel) + `routes/<sub>/route.dart` por entry-point.
4. Añadir barrel `lib/modules/<name>.dart` (los módulos nuevos SÍ
   deben llevarlo — `dashboard` y `external_modules` son excepciones
   históricas).
5. Registrar en `lib/modules.dart` `LunaModule` enum + `case` en
   `LunaModuleAdapter`. Regenerar con `npm run generate:build_runner`.
6. Crear `docs/modules/<name>.md` siguiendo el patrón de los existentes.
7. Nav entry en `mkdocs.yml`.
8. Si es un módulo navegable, el Dashboard lo recoge automáticamente
   (ver [dashboard.md](dashboard.md) § "Patrón tile"). Si es una
   acción cross-cutting (estilo Wake-on-LAN), tratar como excepción
   en `pages/modules.dart`.
9. ADR si la decisión arquitectónica lo merece.
