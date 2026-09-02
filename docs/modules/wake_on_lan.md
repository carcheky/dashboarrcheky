# Wake-on-LAN

Envía un "magic packet" a una MAC address para encender un dispositivo
en la LAN. No es un módulo navegable — es una **acción** que vive
como tile especial en el Dashboard.

- Path: `lib/api/wake_on_lan/` (HTTP abstraction NO; es system-level)
- Barrel: **N/A** (no es un módulo en el sentido de `lib/modules/`)
- Impl: `lib/api/wake_on_lan/wake_on_lan.dart` (`LunaWakeOnLAN`
  abstract factory)
- Per-platform: `lib/api/wake_on_lan/platform/`
  - `wake_on_lan_io.dart` — implementación Dart/IO (sockets UDP)
  - `wake_on_lan_html.dart` — noop en web
  - `wake_on_lan_stub.dart` — fallback
- DB: target MAC + opcional broadcast address viven en
  `LunaSeaDatabase` (tabla global)

## Cómo se usa (real)

`lib/modules/dashboard/routes/dashboard/pages/modules.dart:55-57` —
excepción del bucle de módulos:

```dart
if (module == LunaModule.WAKE_ON_LAN) {
  modules.add(_buildWakeOnLAN(context, index));
} else {
  modules.add(_buildFromLunaModule(module, index));
}
```

`_buildWakeOnLAN` (líneas 94-104 del mismo archivo) monta un
`LunaBlock` cuyo `onTap` es:

```dart
onTap: () async => LunaWakeOnLAN().wake(),
```

Sin navegación, sin abrir ruta. Dispara el magic packet y listo.

## Adding a new system-level action

Si necesitas otra acción cross-cutting (reinicio remoto, etc.) que
**no** sea un módulo navegable:

1. Crear `lib/api/<action>/` con el patrón platform-aware
   (factory + `platform/*_io.dart` + `platform/*_html.dart` +
   `platform/*_stub.dart`).
2. Crear entrada en `LunaModule` enum con `isEnabled` siempre true
   (o false por defecto si requiere config).
3. Tratar como excepción en `modules.dart` del Dashboard.
4. **No** añadir ruta en `lib/router/`.
