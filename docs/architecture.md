# Architecture

> Big picture. What runs, what talks to what, what lives where.
> This is *explanation*. How-to lives in `build.md` / `api/*.md` / `modules/*.md`.

## Layers at a glance

```
┌────────────────────────────────────────────────────────────────────┐
│                          UI  (lib/widgets,  lib/modules)          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────────┐   │
│  │ Dashboard│ │  Search  │ │ Settings │ │ Module <service> UI  │   │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └───────────┬──────────┘   │
│       │            │            │                    │              │
│       └────────────┴────────────┴────────────────────┘              │
│                                │  reads state / fires calls         │
│  ┌─────────────────────────────▼─────────────────────────────────┐ │
│  │            State  (ChangeNotifier per module)                  │ │
│  │   SonarrState  RadarrState  LidarrState  ...  DashboardState  │ │
│  └────┬──────────────────────┬──────────────────────┬────────────┘ │
│       │                      │                      │              │
│  ┌────▼─────────┐    ┌───────▼────────┐    ┌────────▼─────────┐    │
│  │  HTTP layer  │    │  Local storage │    │  In-memory cache │    │
│  │  Dio +       │    │  Hive boxes    │    │  LunaMemoryStore │    │
│  │  Retrofit    │    │  (LunaDatabase)│    │  image cache     │    │
│  └────┬─────────┘    └───────┬────────┘    └──────────────────┘    │
│       │                      │                                      │
└───────┼──────────────────────┼──────────────────────────────────────┘
        │                      │
        ▼                      ▼
   External services       Disk (Hive files)
   (Sonarr / Radarr /      app docs dir
    Lidarr / SAB /         per platform
    NZBGet / Tautulli)
```

Reading guide:

- **UI never calls HTTP or DB directly.** It reads a `ChangeNotifier`
  and asks for an action; the notifier owns the side effect.
- **HTTP and DB don't know about each other.** A state notifier glues
  them together when a feature needs both.
- **Cache is best-effort.** The disk-backed Hive box is the source of
  truth for any persisted setting.

## `lib/` layout (as it actually is)

```
lib/
├── main.dart                 # Bootstrap + runZonedGuarded (see entry point below)
├── core.dart                 # Barrel: re-exports core surfaces
├── vendor.dart               # Barrel: re-exports third-party service modules
├── modules.dart              # Barrel: re-exports every in-app module
│
├── api/                      # Network layer, one folder per service
│   ├── sonarr/               # controllers/, models/, types/, sonarr.dart
│   ├── radarr/
│   ├── lidarr/
│   ├── sabnzbd/
│   ├── nzbget/
│   ├── tautulli/
│   └── wake_on_lan/
│
├── database/                 # Hive (local KV + typed tables)
│   ├── database.dart         # LunaDatabase entry point
│   ├── box.dart              # Box accessors
│   ├── config.dart
│   ├── table.dart            # Base HiveObject + table registration
│   ├── models/               # @HiveType types: profile, external_module, indexer, log...
│   └── tables/               # Per-feature tables (search, dashboard, ...)
│
├── modules/                  # Feature modules — one folder per service
│   ├── dashboard/
│   ├── sonarr/
│   │   ├── core/             # state, extensions, types
│   │   ├── routes/           # go_route definitions (catalogue, queue, history, ...)
│   │   └── sonarr.dart       # module barrel
│   ├── radarr/   lidarr/   sabnzbd/   nzbget/   tautulli/
│   ├── search/   settings/
│   └── external_modules/     # User-added integrations
│
├── router/
│   ├── router.dart           # LunaRouter + LunaRouterDelegate
│   └── routes/               # One file per module (sonarr.dart, radarr.dart, ...)
│
├── system/                   # Cross-cutting, generated, and platform glue
│   ├── environment.dart      # GENERATED from environment_config.yaml (BUILD/COMMIT/FLAVOR)
│   ├── flavor.dart
│   ├── logger.dart
│   ├── network/              # LunaNetwork (Dio factory, interceptors, connectivity)
│   ├── platform.dart         # LunaPlatform (isAndroid / isWindows / ...)
│   ├── cache/                # Memory store + image cache
│   ├── filesystem/
│   ├── recovery_mode/        # Crash UI (see entry point below)
│   ├── state.dart            # App-wide state holder
│   ├── webhooks.dart
│   ├── quick_actions/
│   └── window_manager/
│
├── types/                    # Shared value types and enums
├── extensions/               # Dart extensions (string / int / duration / double)
├── utils/                    # Generic helpers
└── widgets/                  # Shared widgets (Luna-prefixed)
    ├── pages/
    ├── sheets/
    └── ui/
```

Three things to internalize:

1. **`api/<service>/` is the network surface.** Not `modules/<service>/api/`.
   The HTTP layer is decoupled from the UI/state layer so each can be
   tested and replaced independently.
2. **`modules/<service>/` owns UI + state + routes.** It consumes the
   matching `api/<service>/` and writes through `LunaDatabase`.
3. **`router/` knows about every module.** Each module exports a
   `routes/<module>.dart` file under `lib/router/routes/`; `router.dart`
   composes them.

## Entry point and failure mode

`lib/main.dart` is short on purpose:

```dart
runZonedGuarded(() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await bootstrap();           // LunaDatabase.initialize + LunaNetwork + recovery
    runApp(const LunaBIOS());    // → BIOS splash → go_router → module screens
  } catch (error, stack) {
    LunaLogger.critical(error, stack);
    runApp(LunaRecoveryMode(error, stack));  // shown when bootstrap itself fails
  }
});
```

So the app either boots and you land in a route, or you land in
recovery mode. There is no third state. Any uncaught error in a
`ChangeNotifier` flows back through `LunaLogger` and gets surfaced via
the per-module `widgets/error.dart` (see [api/index.md](api/index.md)).

## Where things are documented

| Concern              | Doc                              |
|----------------------|----------------------------------|
| Build / install / adb | [build.md](build.md)            |
| Branching / release  | [workflow.md](workflow.md)        |
| Conventions / commits | [conventions.md](conventions.md)|
| HTTP (Dio + Retrofit) | [api/http.md](api/http.md)      |
| Local DB (Hive)      | [api/hive.md](api/hive.md)       |
| Routing (go_router)  | [api/routing.md](api/routing.md) |
| Per-module details   | [modules/](modules/index.md)     |
| Why a decision       | [adr/](adr/index.md)             |
| Why this doc system  | [adr/0003](adr/0003-docs-strategy.md) |

## Naming at a glance

- **Public classes:** `LunaPascalCase`. Every class exposed across
  module boundaries is prefixed `Luna` (e.g. `LunaRouter`,
  `LunaDatabase`, `LunaNetwork`). Enforced by code review.
- **Files:** `snake_case.dart`. Generated files end in `.g.dart` —
  never hand-edit those.
- **Module barrels:** each module exports a `<module>.dart` next to
  the folder (e.g. `lib/modules/sonarr/sonarr.dart`).

Full style table in [conventions.md](conventions.md).

## See also

- [modules/index.md](modules/index.md) — what each module does.
- [api/index.md](api/index.md) — the four cross-cutting layers (HTTP,
  DB, routes, concerns) and the per-module pattern.
- [adr/0003-docs-strategy.md](adr/0003-docs-strategy.md) — why the doc
  set is shaped the way it is.
