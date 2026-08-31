---
name: spec-driven-feature
description: Drive a non-trivial feature or bug fix through a 3-file Markdown spec (requirements / design / tasks) before any code lands. Use when the user asks for a feature that touches >1 file, a module reshape, or any change where "what" needs to be settled before "how". Pairs with docs/specs/TEMPLATE/ and ADR-0005.
---

# Spec-Driven Feature Workflow

The cheapest way to avoid wasted code is to settle the spec first. This skill
turns a user request into three Markdown files in `docs/specs/<slug>/`, then
hands off to `feature-builder` or `fix-investigator` to execute.

## When to load

- "Add <feature>" (any non-trivial feature — touches >1 file)
- "Reshape the <module> page"
- "Refactor <thing>"
- Any change where you suspect the user has not fully decided **what** they
  want, or you cannot tell from one sentence what success looks like

Skip for one-line fixes, copy edits, dependency bumps — those go straight to
`fix-investigator`.

## Pre-flight

1. Read `docs/conventions.md` — commit rules, naming.
2. Read the module doc for the target: `docs/modules/<name>.md`.
3. Skim the latest session handoff: `ls -t .agents/sessions/ | head -1`.
4. Check the router for relevant constraints: `CLAUDE.md`.

## Steps

### 1. Pick a slug

`<verb>-<noun>-<qualifier>` in kebab-case. Examples:

- `add-quality-profile-filter`
- `fix-back-button-loop`
- `split-dio-client-by-service`

Avoid date prefixes; those belong in branch names (`fix/<slug>`) and session
files (`.agents/sessions/<date>-<slug>.md`).

### 2. Copy the templates

```bash
mkdir -p docs/specs/<slug>
cp docs/specs/TEMPLATE/requirements.md docs/specs/<slug>/requirements.md
cp docs/specs/TEMPLATE/design.md        docs/specs/<slug>/design.md
cp docs/specs/TEMPLATE/tasks.md         docs/specs/<slug>/tasks.md
```

### 3. Fill `requirements.md` first

Plain language. No tech choices. Acceptance criteria as
"Given … when … then …" rows. **Stop and ask** the user if any acceptance
criterion is ambiguous. Write "Out of scope" explicitly — scope creep kills
vibe-coding more than bugs do.

Commit the spec early — even before `design.md` is filled — so the
conversation history is preserved.

```bash
git add docs/specs/<slug>/requirements.md
git commit -m "spec(<slug>): capture requirements"
```

### 4. Fill `design.md` next

This is where the agent proposes **how**. File paths in
`lunasea/lib/...`. Affected Hive fields with their `@HiveField(N)` index.
Affected routes. Rejected alternatives at the bottom — even obvious ones.
This is the doc the agent reads before touching code.

Commit again:

```bash
git commit -am "spec(<slug>): capture design"
```

### 5. Fill `tasks.md` last

Order matters. Cross tasks out as you go. Sub-agent column tells the parent
who executes: `feature-builder`, `fix-investigator`, `docs-keeper`, or
`lunasea-build` for the APK step. "Done when" row is the acceptance gate —
do not mark the spec shipped until every checkbox is ticked.

### 6. Hand off

Once all three files exist and are committed on a `feature/<slug>` or
`fix/<slug>` branch, hand off to the relevant sub-agent:

- New feature → `feature-builder` reads the spec dir, executes `tasks.md`,
  creates `docs/features/<slug>.md` (same PR).
- Bug fix → `fix-investigator` reads the spec dir, repros, fixes, creates
  `docs/fixes/<slug>.md` (same PR).

The agent never writes to `docs/specs/` after design is approved — the spec
is read-only during execution.

### 7. Ship with two `Docs:` footer lines

```bash
git commit -m "feat(<module>): <what>

<Body.>

Docs: docs/specs/<slug>/design.md
Docs: docs/features/<slug>.md
"
```

The first footer points to the design (so future-you knows where the
discussion lives). The second points to the user-visible doc.

## Pitfalls (real ones)

- **Skipping `Out of scope`.** Every time. Fill it even if you write "none".
- **Letting design creep past `Out of scope`.** If "design" needs a new
  feature to work, that's a new spec, not a footnote.
- **Editing the spec mid-execution.** Don't. If the agent discovers the spec
  is wrong, stop, file a new commit `spec(<slug>): revise`, then continue.
- **One PR for two specs.** If a feature touches two unrelated areas,
  split into two PRs and two specs. The cost of merging wrong is higher
  than the cost of two PRs.

## Output

Report:

- Spec dir path: `docs/specs/<slug>/`
- Three commits minimum (one per file)
- Branch: `feature/<slug>` or `fix/<slug>`
- Sub-agent that will execute (or already did)

## See also

- `feature-builder` sub-agent — executes new-feature specs
- `fix-investigator` sub-agent — executes bug-fix specs
- `docs-keeper` sub-agent — audits spec vs reality
- `docs/conventions.md` — commit rules
- ADR-0005 — the spec-driven decision (this skill implements it)