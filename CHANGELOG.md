# Changelog

> Format inspired by [Keep a Changelog](https://keepachangelog.com/),
> versions per [SemVer](https://semver.org/). This file was created
> retroactively on 2026-08-31 to fix a doc-vs-code drift: `docs/workflow.md`
> references `CHANGELOG.md` in the release flow but the file did not exist.

## [Unreleased]

### Added

- 16 KB page-size Phase 1 workaround for locally-built debug APKs on
  Android 15+ / Pixel 9. Forces compressed packaging of `.so` files so
  the system loader extracts them at install time, sidestepping
  `PageSizeMismatchDialog`. See ADR-0004 and
  `docs/fixes/android-16kb-page-size-phase-1.md`.

### Fixed

- Broken mkdocs link in `docs/reference/models.md` (link pointed outside
  the `docs/` tree). mkdocs build --strict was failing the `docs` CI job.
- Path drift in `docs/reference/codegen.md` — codegen outputs were
  documented under `lib/system/environment/` but actually live at
  `lib/system/environment.dart` per `environment_config.yaml`.
- Doc-vs-code drift around the `enableUncompressedNativeLibs` flag (the
  original Phase 1 plan called for it but AGP 8.1 rejects it). Removed
  the flag from code, corrected the ADR and the fix doc.

### Pending

- Phase 2 (ADR-0004): real toolchain bump — AGP 8.1→8.7.x, Gradle
  8.0→8.10.x, Kotlin 1.8.10→1.9.22, NDK pinned to r28+. See
  `.agents/skills/toolchain-upgrade/SKILL.md`.
- GitHub Pages first-time setup. See `docs/operations/github-pages.md`.

## [11.0.0+1] - 2026-08-25

Forked from upstream LunaSea monorepo. Baseline.