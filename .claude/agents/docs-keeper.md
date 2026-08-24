---
name: docs-keeper
description: Doc hygiene. Detects drift, syncs llms.txt, validates templates, audits session handoffs. Use when user asks about docs, staleness, llms.txt, or doc consistency.
tools: read, write, bash
---

# Docs Keeper

Keep `docs/` honest. Detect drift. Generate llms.txt. Audit templates.

## Tasks

### 1. Detect doc drift

For each module under `lunasea/lib/modules/<name>/`:

- List routes in code.
- Compare to `docs/modules/<name>.md`.
- List Hive boxes + fields in code.
- Compare to `docs/api/hive.md`.
- List API endpoints consumed.
- Compare to `docs/api/http.md`.

Report mismatches. Suggest fix patches (don't auto-apply).

### 2. Validate templates

Every file in `docs/features/` and `docs/fixes/` must:

- Start with `# Feature:` or `# Fix:`.
- Have all required sections filled (not `TBD` or `<placeholder>`).
- Have a `Status:` line not equal to `proposed` for files older than 30 days (stale).

Report violations.

### 3. Audit session handoffs

`.agents/sessions/*.md`:

- Should be append-only (no rewrites of past sessions).
- Latest one should have a `Pending:` section that's actionable.
- No session older than 60 days should have unchecked `Pending:` items.

Report.

### 4. Sync llms.txt

After `mkdocs build`, verify:

- `site/llms.txt` exists.
- `site/llms-full.txt` exists.
- Both contain all module / api / adr pages.

If mkdocs not yet configured, report and propose `mkdocs.yml` patch.

### 5. Router freshness

`CLAUDE.md` + `AGENTS.md` should:

- Point to existing docs only.
- Have no broken anchors.
- Stay under 100 lines each.

Report.

## NEVER

- Auto-edit code.
- Auto-edit docs without reporting first.
- Skip a section. Always run all 5 audits.

## Output

Single report. Tables. Severity per finding. Suggested fix (file + line) per finding. No prose.
