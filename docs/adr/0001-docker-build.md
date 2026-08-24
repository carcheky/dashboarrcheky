# ADR-0001: Docker-based Android builds

## Context

The WSL2 host didn't have Flutter, JDK, or Android SDK installed. Installing
them directly pollutes the host with ~5 GB of toolchain, drifts from project
versions over time, and complicates reproducibility.

## Decision

Build Android APKs inside a Docker image (`Dockerfile.android` at repo root).
The image bundles Flutter 3.27.4, Android SDK 35, OpenJDK 17, and Node 20.
The build is orchestrated by `docker-compose.android.yml` and writes the APK
to a bind-mounted volume that the WSL host can read.

`adb` stays on the WSL host (not in the container) so it can talk to the
USB-passthrough Android device via `usbipd-win`.

## Consequences

### Positive
- Host stays clean. ~5 MB of `adb` vs ~5 GB of toolchain.
- Reproducible — anyone with Docker can build the same APK.
- Fast rebuilds via persistent Gradle / pub / npm cache volumes.
- Easy to bump Flutter / SDK versions in one place (`Dockerfile.android`).

### Negative
- First build pulls a ~1.5 GB image.
- Docker bind-mount performance on Windows / WSL can be slow for many small
  files (mitigated by the cache volumes).
- adb has to run on the host, so the workflow is "container builds, host
  installs" — two steps.

### Rejected alternatives
- Install Flutter + SDK directly on WSL — host pollution, drift.
- Install on Windows and call from WSL — known path-translation bugs.
- Use a remote CI (GitHub Actions) — overkill for solo iteration.
