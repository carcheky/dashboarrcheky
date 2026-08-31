# Search module

Cross-service search: queries Sonarr, Radarr, Lidarr simultaneously and
merges results.

- Path: `lib/modules/search/`
- Barrel: `lib/modules/search.dart`
- Entry: `SearchPage`

## How it works

Each enabled module exposes a `SearchableItem` mixin. The search coordinator
fans out to all enabled modules in parallel, debounces input, and merges
results by type (series / movie / artist / etc.).

## Adding a module to search

1. Add `SearchableItem` mixin to the module's state holder.
2. Implement the search logic.
3. Register the result type in `SearchCoordinator`.
