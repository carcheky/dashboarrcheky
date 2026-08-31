# API & Data

> HTTP, local DB, routes. Shared by all modules.

| Layer | Doc |
|-------|-----|
| HTTP client (Dio + Retrofit) | [http.md](http.md) |
| Local DB (Hive) | [hive.md](hive.md) |
| Routing (go_router) | [routing.md](routing.md) |

## Pattern (all modules follow this)

```
lib/modules/<name>/
├── api/           # Retrofit interface. Per-endpoint DTOs.
├── database/      # Hive boxes + adapters.
├── state/         # Notifiers / blocs.
├── widgets/       # Shared widgets.
└── views/         # Screens.
```

API = network layer. DB = persistence. State = runtime model. Views = UI.

## Cross-cutting

| Concern | Where |
|---------|-------|
| Auth headers | `lunasea/lib/api/lunasea_dio.dart` |
| Logging | `lunasea/lib/logger.dart` |
| Error → UI | `lunasea/lib/modules/<m>/widgets/error.dart` |
| Loading state | `lunasea/lib/modules/<m>/widgets/loading.dart` |

## Touch rules

| If you change… | Also update |
|----------------|-------------|
| HTTP endpoint shape | `http.md` + module doc |
| Hive field | `hive.md` + module doc + bump schema version |
| Route | `routing.md` + module doc |
| Auth flow | `http.md` + module doc |

Never reorder Hive fields. Always add at end with `defaultValue:`. See `hive.md`.
