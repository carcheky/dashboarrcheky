# Troubleshooting

> Symptom → cause → fix. No prose filler.

## Build

### `npm run generate` missing before build

```
MissingPluginException: No implementation found for method ...
```

**Fix:** `cd lunasea && npm run generate`. Then rebuild.

### Docker build fails: Gradle OOM

```
Java heap space
```

**Fix:** `lunasea/android/gradle.properties`:

```
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m
```

### APK installs but crashes on launch

1. Check `adb logcat | grep -i luna` for stack.
2. Likely missing codegen — see above.
3. Likely Hive schema mismatch — see Hive section below.

## adb-wifi

### `adb connect <ip>:5555` fails

- Phone and laptop on same WiFi.
- `adb tcpip 5555` from USB first.
- Some routers block peer-to-peer. Use USB then switch to wifi.

### `adb install` times out

APK too big or wifi slow. `adb -s <ip>:5555 install -r lunasea/build/app/outputs/flutter-apk/app-debug.apk`. Or copy APK to phone and install via file manager.

## Hive

### App crashes opening a box

```
HiveError: The box <name> is already open
```

Already open in another isolate. Close first or reuse handle.

```
TypeError: type 'X' is not a subtype of type 'Y'
```

Schema mismatch. User's saved data uses old shape. Either:

- Bump Hive `schemaVersion` and migrate.
- Or add new field with `defaultValue:` and let old data stay.

Never reorder `@HiveField(N)`. Breaks users.

## go_router

### Back button loops on settings

Deep link loops to itself. Add `redirect` guard or unique parent route.

### Route not found after refactor

Check `mkdocs.yml`... no wait, check `lib/router.dart` and `lib/modules/<m>/routes.dart`. Name mismatch.

## Sonarr / Radarr / Lidarr API

### 401 Unauthorized

- API key wrong / changed.
- Module-level key in `lib/modules/<m>/state/keys.dart`.

### 404 on /api/v3/...

- Self-hosted service version too old. Upgrade.
- Or endpoint renamed in newer service version.

### Timeout

- Service unreachable. Check `host:port` in settings.
- HTTPS with self-signed cert: enable "skip TLS verify" in settings (insecure but works for local).

## Performance

### Long startup

- `lunasea/lib/startup.dart` shows init sequence. Comment out non-critical.
- Hive boxes reopen every launch — `await Hive.openBox` is sync-blocking.

### UI jank on list scroll

- Missing const constructors. Run `dart fix`.
- Images not cached. Check `cached_network_image` config.

## Linter / analyzer

### `dart analyze` complains after edit

- Read error line. Fix root cause.
- If noise (false positive), add `// ignore: <rule>` with reason comment.
- Never blanket-disable rules in `analysis_options.yaml` for one-off issues.

## Logs

```bash
adb logcat -s flutter:V LunaSea:V
```

Verbose. Pipe to `tee` if you need a trace.

## Still stuck

1. Check `docs/fixes/` for similar past issues.
2. Search upstream LunaSea issues (this is a fork).
3. Check `docs/adr/` for past decisions that may explain weird code.
