# Spec — <slug> — Tasks

> Ordered work breakdown. One row per agent step. Same shape as `todo`.
> Cross out a row when done.

**Status:** draft | approved | in-progress | shipped
**Pairs with:** `requirements.md`, `design.md`
**Branch:** `feature/<slug>` | `fix/<slug>`

## Order

1. [ ] `<verb>` <thing> — `path:line`
2. [ ] `<verb>` <thing> — `path:line`
3. [ ] Verify <observable thing>
4. [ ] Commit: `feat(<module>): <what>` with `Docs: docs/specs/<slug>/...` and `Docs: docs/features/<slug>.md` footers.

## Tasks

| # | Task | Files | Sub-agent |
|---|------|-------|-----------|
| 1 | … | `lunasea/lib/...` | `feature-builder` |
| 2 | … | `lunasea/lib/...` | `feature-builder` |
| 3 | Tests | `lunasea/test/...` | `feature-builder` |
| 4 | Build APK | `Dockerfile` | `lunasea-build` |
| 5 | Install on device | `adb` | manual |
| 6 | Doc | `docs/features/<slug>.md` | `docs-keeper` |

## Done when

- [ ] All rows above are checked.
- [ ] `dart analyze lib/` clean.
- [ ] APK installs and reproduces the happy path.
- [ ] `docs/features/<slug>.md` (or `docs/fixes/`) created with all sections filled.
- [ ] Commit footer `Docs:` points to both the spec dir and the feature/fix doc.

## References

- Requirements: `requirements.md`
- Design: `design.md`