# Codegen Pipeline

The 4-stage chain run by `npm run generate`:

```
environment_config  ──►  lib/system/environment/environment.config.dart
spider              ──►  lib/system/environment/spider.generated.dart
build_runner        ──►  *.g.dart  (Hive, json_serializable, retrofit)
localization script ──►  lib/system/localization.g.dart  (if used)
```

## Stage 1 — `environment_config`

Source: `lunasea/environment_config.yaml`
Output: `lunasea/lib/system/environment/environment.config.dart`
Run: `npm run generate:environment`

## Stage 2 — `spider` (assets)

Source: `lunasea/spider.yaml`
Output: `lunasea/lib/system/environment/spider.generated.dart`
Run: `npm run generate:assets`

Generates typed constants for every asset path declared in `spider.yaml`.
Use them in code as `Assets.images.logo` instead of `'assets/images/logo.png'`.

## Stage 3 — `build_runner`

Source: anything annotated (`@HiveType`, `@JsonSerializable`, `@RestApi`)
Output: `*.g.dart` next to each source file
Run: `npm run generate:build_runner`

Configured in `lunasea/build.yaml`. Uses:

- `hive_generator` — type adapters
- `json_serializable` — JSON encoders/decoders
- `retrofit_generator` — Dio API client impls

## Stage 4 — Localization

Source: `lunasea/assets/localization/*.json` + `lunasea/scripts/generate_localization.dart`
Output: localization code (varies by version)
Run: `npm run generate:localization`

## Running everything

```bash
cd lunasea
npm run generate           # all 4 stages
npm run generate:build_runner:watch   # rebuild on change during dev
```

## Common failures

See [../troubleshooting.md](../troubleshooting.md#build).
