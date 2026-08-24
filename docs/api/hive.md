# Local DB — Hive

## Stack

- **`hive` 2.x** + **`hive_flutter`** for the local key/value store.
- **`hive_generator`** for type adapters (`@HiveType` / `@HiveField`).

## Where it lives

- `lib/database/database.dart` — opens all boxes, exposes typed accessors.
- Boxes are registered in `lib/modules/<service>/src/database/`.
- Type adapters are generated next to their `@HiveType` classes as `*.g.dart`.

## Schema migrations

Hive has **no automatic schema migration**. If you change a `@HiveField` number
or remove a field, existing user data will deserialize wrong.

Pattern for backward-compatible changes:

```dart
@HiveType(typeId: 42)
class SonarrSettings extends HiveObject {
  @HiveField(0)
  String url;

  @HiveField(1)
  String apiKey;

  @HiveField(2, defaultValue: '')
  String profileName;   // NEW — never insert before existing fields
}
```

Rules:

- ✅ Add new fields at the **end** with a `defaultValue:`.
- ✅ Bump `typeId` only when creating a brand new class.
- ❌ Never reorder existing `@HiveField` numbers.
- ❌ Never remove a field — mark it `@HiveField(N, defaultValue: null)` if you
  must, then ignore it in code.

## Common operations

```dart
// Open
await Hive.openBox<SonarrSettings>('sonarr_settings');

// Read
final settings = box.get(id);

// Write
await box.put(id, settings);

// Watch
settings.listenable().addListener(() => ...);
```

## Regenerating adapters

After editing a `@HiveType` class:

```bash
npm run generate:build_runner
```

The generated `*.g.dart` adapter is what Hive uses at runtime.
