# HTTP — Dio + Retrofit

## Stack

- **`dio` 5.x** — HTTP client, with interceptors for auth headers, logging,
  error transformation.
- **`retrofit` 4.x** — annotation-based API client generator. Generates
  `*_Impl.g.dart` classes from `@RestApi` interfaces.
- **`retrofit_generator` 9.x** — build_runner builder that produces the impls.

## Where it lives

- Generic Dio setup: `lib/api/dio.dart`
- Per-service Retrofit interfaces: `lib/modules/<service>/src/api/<service>_api.dart`
  + generated `lib/modules/<service>/src/api/<service>_api.g.dart`

## Adding a new endpoint to an existing service

1. Add the method + annotation to the abstract API class:

   ```dart
   @RestApi()
   abstract class SonarrAPI {
     @GET('/api/v3/series/{id}')
     Future<SonarrSeries> getSeriesById(@Path('id') int id);
   }
   ```

2. Run `npm run generate:build_runner` (or the full `npm run generate`).
3. Use it: `final series = await sonarrAPI.getSeriesById(123);`

## Adding a brand new service

1. Create the folder under `lib/modules/<service>/src/api/`.
2. Define `<service>_api.dart` with `@RestApi()` abstract class.
3. Add the matching URL base to `LunaNetwork` if it needs special routing.
4. Generate. See [../modules/index.md](../modules/index.md) for the rest.

## Auth

Most services use an API key in a header. The Dio interceptor reads the key
from the active profile in `LunaDatabase` (Hive) and injects it. No manual
header passing per call.
