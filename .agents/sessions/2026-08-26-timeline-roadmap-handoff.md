# Session: 2026-08-26 — timeline-roadmap-handoff

> Latest session. Read first when picking up.

## Goal

1. Make the repo "0 changes" (everything either committed or gitignored).
2. Add `docs/timeline.md` (chronological history + present + future) and
   `docs/roadmap.md` (prioritised future work).
3. Reframe the future-feature research (Seerr / Jellyfin / Bazarr /
   qBittorrent / 4K profiles) so each feature opens as its own
   `docs/features/<slug>.md` per ADR-0005 — one feature per session, not
   five in one.
4. Refresh the session handoff so a new conversation starting with "continua"
   knows exactly where to pick up.

## Done

- [x] Committed `.github/workflows/docs.yml` + `docs/stylesheets/extra.css`
      (left untracked since 2026-08-24 docs-system-bootstrap). Commit
      `0a370ed9`.
- [x] Researched online: Seerr (Overseerr+Jellyseerr unification, Feb 2026),
      Jellyfin API surface, qBittorrent WebUI v2.15.1 / cookie auth, Bazarr
      Sonarr/Radarr integration. No code changes — proposals only.
- [x] Wrote `docs/timeline.md` — past / present / future rows; one row per
      shipped commit; ADR cross-refs.
- [x] Wrote `docs/roadmap.md` — 12-item prioritised future list with
      effort, dependencies, spec pointers. **Decided not to open five
      feature specs at once.** Per-feature specs will be created when the
      feature is picked up, one at a time, per ADR-0005.
- [x] Updated this handoff.

## Touched

| File | Why |
|------|-----|
| `.github/workflows/docs.yml` | track (CI workflow) |
| `docs/stylesheets/extra.css` | track (mkdocs extra_css) |
| `docs/timeline.md` | new — chronological view |
| `docs/roadmap.md` | new — prioritised future work |
| `.agents/sessions/2026-08-26-timeline-roadmap-handoff.md` | new — handoff refresh |

## Tests

| Type | Result |
|------|--------|
| Working tree status | only `site/` + `.venv-docs/` untracked, both gitignored (legitimate) |
| Branch sync with `origin/beta` | 1 commit ahead locally (the chore commit `0a370ed9`), needs push |

## Pending

- [ ] **Push the local-ahead commit** `0a370ed9` to `origin/beta`.
- [ ] **Commit + push this batch** (timeline + roadmap + handoff).
- [ ] Verify `git status` is clean except the two gitignored dirs.
- [ ] Update `mkdocs.yml` to surface `timeline.md` and `roadmap.md` in nav
      (currently unlinked — agent only surfaced them as `?? docs/` files).
- [ ] User to pick the next feature from `docs/roadmap.md`. Suggested order:
      1 (16 KB Phase 1) → 2 (back-button matrix verify) → 3 (Overseerr/Seerr key decision) → 4 (Seerr module) → 5 (Jellyfin) → …
- [ ] Original export/import bug between release and debug APKs (signatures
      differ — Android blocks by design) — deferred, see roadmap item #11
      for the signing-key unification fix.

## Decisions

- **Don't open five feature specs at once.** Roadmap contains the list;
      per-feature `docs/features/<slug>.md` opens when the feature is
      picked up. Rationale: per ADR-0005 the spec requires a requirements
      pass that needs user sign-off; doing five at once burns a session
      on nothing else.
- **Overseerr → Seerr path.** Today `modules.dart` declares
      `MODULE_OVERSEERR_KEY = 'overseerr'`. Seerr is the unified fork
      (Overseerr + Jellyseerr merged Feb 2026). Decision: when the Seerr
      module lands, rename the key to `seerr` (matches upstream
      container image `ghcr.io/seerr-team/seerr`). Migration of existing
      users is a separate doc.
- **Do not change `.gitignore` blindly.** Two of the four untracked dirs
      (`.github/workflows/docs.yml`, `docs/stylesheets/extra.css`) were
      legitimate untracked files left by the docs-system-bootstrap agent.
      They got committed, not ignored.
- **Timeline + Roadmap live in `docs/`, not `.agents/`.** The repo
      already has a session handoff convention (`.agents/sessions/`).
      Timeline is the public-readable history; sessions are private
      to the dev/agent loop.

## Blockers

- None on documentation.
- Item #1 (16 KB Phase 1) and #2 (back-button matrix) are blocked on
  the user, not on tech.

## Next session starts here

Run, in order:

```bash
cd /home/user/mediacheky/dashboarrcheky
git push origin beta            # publish the chore commit + this batch
cat docs/timeline.md | head -50 # remember what's done
cat docs/roadmap.md  | head -50 # pick the next item
```

If the user says "continua" or "sigue con el roadmap":

1. Read the latest session (this file) for any new blockers.
2. Open `docs/features/<slug>.md` from `docs/specs/TEMPLATE/` per the
   `spec-driven-feature` skill.
3. Execute on `feature/<slug>` or `fix/<slug>` per `WORKFLOW.md`.
4. Update `docs/timeline.md` Past section when shipped.

## See also

- `docs/timeline.md` — chronological history
- `docs/roadmap.md` — prioritised future
- `docs/specs/TEMPLATE/{requirements,design,tasks}.md` — per-feature skeleton
- `.agents/skills/spec-driven-feature/SKILL.md` — workflow
- `.agents/skills/todo-discipline/SKILL.md` — in-session contract
- `.agents/skills/worktree-isolation/SKILL.md` — parallel runs
- ADR-0004 — 16 KB page-size plan
- ADR-0005 — spec-driven workflow