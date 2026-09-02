# Dashboard module

Home screen. Muestra calendario + lista de módulos activos. Es el
**launcher** de la app, no un agregador de tiles.

- Path: `lib/modules/dashboard/`
- Barrel: **NO TIENE** `lib/modules/dashboard/dashboard.dart` (es el
  único módulo sin barrel propio; se exporta vía `lib/modules.dart`
  directamente).
- State: `lib/modules/dashboard/core/state.dart` (`LunaDashboardState`,
  ChangeNotifier pequeño — solo maneja calendario)
- Routes: `lib/modules/dashboard/routes/dashboard/route.dart` (entry
  widget: `DashboardRoute`, no `Dashboard`)
- Páginas: `lib/modules/dashboard/routes/dashboard/pages/`
  - `modules.dart` — lista de módulos activos (launcher)
  - `calendar.dart` — vista calendario

## Patrón "tile" (real)

**No existe un patrón `tile_<module>.dart` en el dashboard.** El
"tile" de cada módulo es un `LunaBlock` generado dinámicamente en
`lib/modules/dashboard/routes/dashboard/pages/modules.dart` mediante
un `forEach` sobre `LunaModule.active`:

```dart
LunaModule.active.forEach((module) {
  if (module.isEnabled) {
    modules.add(_buildFromLunaModule(module, index));
    index++;
  }
});
```

Cada `_buildFromLunaModule(module, i)` devuelve un `LunaBlock`
estándar con `onTap: module.launch` (navega al módulo). La **única**
excepción es `WAKE_ON_LAN`, que dispara `LunaWakeOnLAN().wake()`
directo sin navegar (ver `modules.dart:55-57`).

→ Si añades un módulo nuevo, **NO** crees un `tile_<module>.dart`.
Solo necesita existir como `LunaModule` y el dashboard lo recoge
automáticamente.

## Añadir contenido al Dashboard que no sea un launcher

No hay patrón previo. Opciones:

1. **Página nueva en el Dashboard** (calendar, schedule_view ya lo
   hacen): crear `pages/<feature>.dart` + entrada en el
   `HomeNavigationBar`. Apropiado para vistas agregadas
   cross-módulo (calendario, "pendientes de importar" cross-Sonarr+Radarr).
2. **Widget en una pantalla de un módulo**: si el contenido es de un
   solo servicio, vive en `lib/modules/<svc>/routes/...`, no aquí.

La spec `add-pending-imports-tile` debe seguir la opción 1, no crear
un tile-per-module.

## Adding a new dashboard feature

1. Decide: ¿es launcher (LunaModule + LunaBlock automático) o vista
   agregada (página nueva)?
2. Para vista agregada: añadir `pages/<feature>.dart` +
   `widgets/<feature>.dart` + entrada en `navigation_bar.dart`.
3. Si necesita datos cross-módulo: extender `LunaDashboardState` con
   un `Future`/`Map` y un `refresh*()`. Suscribirse en
   `route.dart` (`initState`/`dispose`).
4. **No** crear `tile_<module>.dart`. No es un patrón del repo.
