# Session: 2026-08-24 — docs-system-bootstrap

## Goal

Stand up token-efficient doc system for human + AI use. Caveman. llms.txt. Sub-agents. Per-change docs.

## Done

- [x] Rewrote `CLAUDE.md` as caveman router.
- [x] Added `AGENTS.md` (cross-tool mirror).
- [x] Rewrote `docs/index.md`, `conventions.md`, `workflow.md`, `troubleshooting.md`, `modules/index.md`, `api/index.md` in caveman.
- [x] Updated ADR `0003-docs-strategy.md` with full strategy.
- [x] Added `docs/features/TEMPLATE.md` + `docs/fixes/TEMPLATE.md`.
- [x] Added `mkdocs-llmstxt` plugin → generates `/llms.txt` + `/llms-full.txt`.
- [x] Added 3 sub-agents: feature-builder, fix-investigator, docs-keeper.
- [x] Added `.agents/sessions/TEMPLATE.md`.

## Touched

| File | Why |
|------|-----|
| `CLAUDE.md` | caveman router |
| `AGENTS.md` | cross-tool entry |
| `docs/**/*.md` | rewrite caveman + new structure |
| `mkdocs.yml` | llmstxt plugin |
| `.claude/agents/*.md` | new sub-agents |
| `.agents/sessions/TEMPLATE.md` | session handoff convention |

## Tests

| Type | Result |
|------|--------|
| `mkdocs build --strict` | pending (next session) |
| Manual `llms.txt` check | pending |

## Pending

- [ ] Run `mkdocs build` locally → verify `llms.txt` + `llms-full.txt` generated.
- [ ] Optionally publish docs site (GitHub Pages).
- [ ] When code lands: first feature using this system end-to-end.

## Decisions

- Caveman > HADS `[SPEC]` tags. Simpler, similar savings.
- AICaC YAML rejected: overhead for solo dev.
- One `CLAUDE.md` + `AGENTS.md` mirror. No drift if kept short.
- Sub-agents in `.claude/agents/` only (Claude-specific). Skills already cross-tool in `.agents/skills/`.

## Blockers

None.

## Next session starts here

Pick the next user-visible feature to ship. Use `feature-builder` sub-agent. Create `docs/features/<slug>.md` from template. Commit with `Docs:` footer. Build APK → install via adb-wifi → test on device. Update `.agents/sessions/<date>-<slug>.md` at end.
