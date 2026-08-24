# Architecture

## High-level

```
┌──────────────────────────────────────────────────────────┐
│                    Flutter UI (lib/)                      │
│  ┌─────────┐ ┌─────────┐ ┌─────────� ┌─────────┐         │
│  │Dashboard│ │Search   │ │Settings │ │Modules  │         │
│  └─────────┘ └─────────┘ └─────────┘ └────┬────┘         │
│                                            │              │
│  ┌─────────────────────────────────────────▼───────────� │
│  │              Modules (one per service)              │ │
│  │  Sonarr │ Radarr │ Lidarr │ SABnzbd │ NZBGet │ Tautulli │
│  └────┬────────────────────────────────────┬───────────┘ │
│       │                                    │             │
│  ┌────▼─────────┐                    ┌─────▼─────────┐   │
│  │  go_router   │                    │  Dio/Retrofit │   │
│  │  navigation  │                    │  HTTP client  │   │
│  └──────────────┘                    └───────┬───────┘   │
│                                              │           │
│  ┌──────────────�  ┌──────────────┐   ┌──────▼────────┐  │
│  │     Hive     │  │  Memory cache│   │ External APIs │  │
│  │  local DB    │  │   (stash)    │   │ (Sonarr etc.) │  │
│  └──────────────┘  └──────────────┘   └───────────────┘  │
└──────────────────────────────────────────────────────────┘
```

## `lib/` directory layout

```
lib/
├── main.dart                 # Entry point + bootstrap
├── core.dart                 # Re-exports core classes
├── vendor.dart               # Re-exports external service modules
├── modules.dart              # Re-exports all modules
│
├── api/                      # Generic HTTP layer
│   ├── dio.dart              # Dio instance + interceptors
│   └── ...
│
├── core/                     # Core abstractions
│   ├── luna_sea.dart         # Top-level facade
│   ├── router/               # go_router config (see api/routing.md)
│   ├── system/               # Logging, theme, environment, recovery mode
│   ├── platform/             # Platform detection
│   └── ...
│
├── database/                 # Hive boxes + adapters (see api/hive.md)
│   └── database.dart
│
├── extensions/               # Dart extensions on built-in types
│
├── modules/                  # Feature modules (see modules/index.md)
│   ├── dashboard/
│   ├── sonarr/  radarr/  lidarr/
│   ├── sabnzbd/  nzbget/  tautulli/
│   ├── search/
│   ├── settings/
│   └── external_modules/     # User-added integrations
│
├── router/                   # Route definitions
│
├── system/                   # Generated + cross-cutting
│   ├── environment.dart      # ← GENERATED from environment_config.yaml
│   ├── cache/                # Memory + image cache
│   ├── network/              # Connectivity checks
│   ├── recovery_mode/        # Crash UI
│   └── window_manager/
│
├── types/                    # Shared value types
│
├── utils/                    # Generic utilities
│
└── widgets/                  # Shared UI widgets (Luna-prefixed)
```

## Naming conventions at a glance

- **Classes / types:** `LunaPascalCase` — every public class is prefixed with
  `Luna` (e.g. `LunaRouter`, `LunaLogger`, `LunaDatabase`).
- **Files:** `snake_case.dart`. Generated files end in `.g.dart`.
- **Modules:** one folder per service under `lib/modules/`, with a matching
  barrel file at `lib/modules/<service>.dart` exporting its public surface.

For full conventions, see [conventions.md](conventions.md).

## Cross-cutting concerns

- **Generated code:** anything ending in `.g.dart` is from `build_runner`. Never
  edit by hand; re-run `npm run generate:build_runner`.
- **Environment values:** `LunaEnvironment.build`, `LunaEnvironment.commit`,
  `LunaEnvironment.flavor` come from `environment_config.yaml` and are injected
  at build time.
- **Error handling:** main runs in `runZonedGuarded` and falls back to
  `LunaRecoveryMode` on bootstrap failure. Uncaught errors are logged via
  `LunaLogger.critical()`.
- **i18n:** strings live under `assets/localization/`. Regenerate after adding
  keys with `npm run generate:localization`.
