# Search module

Búsqueda sobre **indexadores Newznab / Torznab**. **No** busca en
Sonarr/Radarr/Lidarr — esa funcionalidad de "buscar para añadir" vive
dentro de cada módulo (ej. `SonarrAddSeriesSearchPage`).

- Path: `lib/modules/search/`
- Barrel: `lib/modules/search.dart`
- HTTP: `NewznabAPI` (definido en `lib/vendor/`, no en `lib/api/search/`)
- State: `lib/modules/search/core/state.dart` (`LunaSearchState`,
  ChangeNotifier)
- API data: `lib/modules/search/core/api.dart` + `core/models/`
  (category, subcategory, result)
- DB: `lib/database/models/indexer.dart` (configuración de indexadores)
- Routes: `lib/modules/search/routes.dart` (barrel) + `routes/<sub>/route.dart`
  - `categories/` — árbol de categorías
  - `subcategories/` — subcategoría seleccionada
  - `results/` — resultados de la búsqueda
  - `search.dart` — entry

## Cómo funciona (real)

1. El usuario configura uno o más indexadores Newznab/Torznab en
   Settings → Indexers (modelo `Indexer` en Hive).
2. `LunaIndexer` mantiene la lista activa.
3. Al buscar, `LunaSearchState` crea un `NewznabAPI` por indexador y
   fan-out en paralelo.
4. Los resultados se devuelven como `NewznabResultData` y se renderizan
   en `routes/results/`.

**No existe** un mixin `SearchableItem` ni un `SearchCoordinator`.
Tampoco hay un `SearchPage` global; el flujo es
`Search → Categories → Subcategory → Indexer → Results`.

## Adding an indexer protocol

1. Si el protocolo es Newznab-compatible, no hace falta código — solo
   añadir el indexer desde Settings.
2. Si necesitas un protocolo distinto (Torznab-only sin fallback
   Newznab), añadir un `*API` paralelo a `NewznabAPI` en
   `lib/vendor/` + un `*ResultData` en `lib/modules/search/core/models/`.

## Adding a category type

1. Añadir el modelo en `lib/modules/search/core/models/`.
2. Actualizar el árbol en `routes/categories/` y
   `routes/subcategories/`.
3. `npm run generate:build_runner` y `dart analyze lib/`.
