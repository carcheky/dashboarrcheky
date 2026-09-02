# External modules

Módulo "comodín" para servicios que no tienen integración nativa. El
usuario añade un módulo externo (un nombre + una URL) y el Dashboard lo
muestra como un tile con un `onTap` que abre esa URL en el navegador
del sistema (vía `url_launcher`).

- Path: `lib/modules/external_modules/`
- Barrel: **NO TIENE** `lib/modules/external_modules/external_modules.dart`
  (igual que `dashboard` — se exporta desde `lib/modules.dart`).
- Routes: `lib/modules/external_modules/routes/external_modules.dart` +
  `routes/external_modules/route.dart` + `widgets/module_tile.dart`
- DB: `lib/database/models/external_module.dart` (Hive type)

## Cómo funciona (real)

1. El usuario crea módulos externos en **Settings → Configuration →
   External Modules** (`lib/modules/settings/routes/configuration_external_modules/`).
2. Cada módulo externo es un `ExternalModule` Hive con: nombre, URL,
   descripción, headers opcionales.
3. `LunaModule.EXTERNAL_MODULES` es la entrada en el enum que abre
   la lista (`lib/modules/external_modules/routes/external_modules/route.dart`).
4. La lista renderiza `module_tile.dart` por cada uno, con `onTap` →
   `url_launcher.launchUrl(url)`.

## Diferencia con módulos nativos

- **No** llama a una API del servicio.
- **No** tiene state (`ChangeNotifier`).
- **No** se mete en Search (no es descubrible).
- **No** aparece en Quick Actions (configuración global).

## Adding an external module (user)

Settings → Configuration → External Modules → Add. Nombre, URL,
descripción. Listo. No requiere tocar código.

## Adding native support for a service (dev)

Si un servicio empieza a aparecer a menudo como módulo externo y
merece integración nativa:

1. Crear `lib/api/<svc>/` con `<svc>.dart` factory + `controllers/`
   + `models/` (ver [../api/http.md](../api/http.md)).
2. Crear `lib/modules/<svc>/` con `core/` + `routes/` (ver
   [./index.md](./index.md) § "Adding a new module").
3. Registrar en `lib/modules.dart` `LunaModule` enum + regenerar
   `modules.g.dart`.
4. mkdocs.yml + `docs/modules/<svc>.md`.
5. ADR si la decisión arquitectónica lo merece.
