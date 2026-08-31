# Navigation — go_router

## Where it lives

- `lib/router/router.dart` — top-level `LunaRouter` and `LunaRouterDelegate`.
- Per-module routes live in the module's `src/router.dart`.

## Adding a new route

1. Define the route in the relevant module:

   ```dart
   // lib/modules/lidarr/src/router.dart
   GoRoute(path: '/lidarr/artists', builder: (_, __) => const ArtistsPage()),
   ```

2. Register it in the parent navigation graph in
   `lib/modules/lidarr/lidarr.dart` (the module barrel).

3. Deep-link it via `go_router`'s URL-based navigation — no manual page pushing.

## Shell routes

`go_router` `ShellRoute` is used to keep persistent navigation chrome (bottom
nav, app bar) while swapping the inner content. Don't add a new `ShellRoute` —
extend the existing one.

## Web URLs

The same route strings double as URLs in the web build. Pick paths that read
clean: `/sonarr/series/123`, not `/sonarr/series_detail`.
