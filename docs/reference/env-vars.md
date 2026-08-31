# Environment Variables

## Build-time (injected by `environment_config`)

From `lunasea/environment_config.yaml`:

| Field    | Env var  | Default          | Purpose                                      |
|----------|----------|------------------|----------------------------------------------|
| `build`  | `BUILD`  | `9999999999`     | Build number (CI)                            |
| `commit` | `COMMIT` | `master`         | Git commit SHA / branch                      |
| `flavor` | `FLAVOR` | `edge`           | `edge` / `beta` / `stable`                   |

These surface in code as `LunaEnvironment.build`, etc. Regenerate after
changes:

```bash
npm run generate:environment
```

## Runtime (read by the app)

The app itself reads almost nothing from env at runtime. Configuration is
stored in Hive (see [../api/hive.md](../api/hive.md)).

## Docker build env

In `docker-compose.android.yml`:

| Var                        | Purpose                                       |
|----------------------------|-----------------------------------------------|
| `FLUTTER_HOME`             | `/opt/flutter`                                |
| `ANDROID_HOME` / `_ROOT`   | `/opt/android-sdk`                            |
| `JAVA_HOME`                | `/usr/lib/jvm/java-17-openjdk-amd64`          |
| `GIT_AUTHOR_*` / `_COMMITTER_*` | Mirrored from host so commits inside the container keep your identity |
