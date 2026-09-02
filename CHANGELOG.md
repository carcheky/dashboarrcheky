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
- **docs(review)**: full doc-vs-code drift correction. Rewrote
  `docs/api/http.md` (Retrofit scope corrected, paths to real Dio
  layout), `docs/modules/sonarr.md` (no more `src/`), `dashboard.md`
  (no more `tile_<module>.dart` pattern), `search.md` (it's Newznab,
  not cross-service fan-out), `lidarr.md` (asymmetric API location
  documented). Created `docs/modules/external_modules.md` and
  `docs/modules/wake_on_lan.md`. Created `docs/SUMMARY.md`
  reconciling `docs/specs/` vs `docs/features/`. Updated `AGENTS.md`
  router, `docs/conventions.md`, `docs/roadmap.md` (typo + numbering
  + new See-also), `docs/timeline.md` (16KB Phase 1 moved Past→Present
  reorg), `docs/specs/add-pending-imports-tile/{requirements,design,
  tasks}.md` (status reconciled, "flip row 8" confusion corrected),
  `mkdocs.yml` (new entries in nav + llmstxt). No code touched.

### Fixed

- Broken mkdocs link in `docs/reference/models.md` (link pointed outside
  the `docs/` tree). mkdocs build --strict was failing the `docs` CI job.
- Path drift in `docs/reference/codegen.md` — codegen outputs were
  documented under `lib/system/environment/` but actually live at
  `lib/system/environment.dart` per `environment_config.yaml`.
- Doc-vs-code drift around the `enableUncompressedNativeLibs` flag (the
  original Phase 1 plan called for it but AGP 8.1 rejects it). Removed
  the flag from code, corrected the ADR and the fix doc.
- Doc-vs-code drift in 6 module docs (paths to `lib/modules/<svc>/src/`
  and `lib/api/dio.dart` that never existed). Routes for adding
  features, endpoints, and modules are now correct.
- Roadmap numbering skipped from "4" to "6" in "How to use this"
  section.
- Timeline said 16 KB Phase 1 was "in flight" but the code shipped
  2026-08-25. Moved to "Past — shipped".

### Pending

- Phase 2 (ADR-0004): real toolchain bump — AGP 8.1→8.7.x, Gradle
  8.0→8.10.x, Kotlin 1.8.10→1.9.22, NDK pinned to r28+. See
  `.agents/skills/toolchain-upgrade/SKILL.md`.
- GitHub Pages first-time setup. See `docs/operations/github-pages.md`.
- Decide: rename the app from "LunaSea" to "dashboarrcheky" in code
  (currently still `app.lunasea.lunasea`, `display_name: LunaSea`,
  `MaterialApp.title: 'LunaSea'`). Doc and APK diverge.

## [11.0.0+1] - 2026-08-25

Forked from upstream LunaSea monorepo. Baseline.