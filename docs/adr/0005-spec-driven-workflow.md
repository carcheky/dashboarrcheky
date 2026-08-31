# ADR-0005: Spec-driven workflow for non-trivial changes

## Status

Accepted. 2026-08-25.

## Context

The repo already mandates doc-per-change (`docs/features/<slug>.md` and
`docs/fixes/<slug>.md`, `conventions.md` § Doc hygiene). What's missing is a
**spec phase** between "user asked" and "agent writes code".

Today, an AI agent reads the router + relevant module doc, then dives in.
Works for one-line fixes. Breaks for:

- Multi-file features ("add quality profile filter") where the **what**
  needs to be settled before the **how**.
- Multi-agent runs (background sub-agent + foreground edits) where two
  agents must not collide on `AndroidManifest.xml`.
- Vibe-coding sessions that drift into the third hour and lose track of
  what was actually asked.

External systems that solve this (Task Master, Spec Kit, OpenSpec, GitHub
Spec Kit) all converge on the same shape: 3 Markdown files — requirements,
design, tasks — committed to the repo before code. The shape is sound; the
question is whether to install an external CLI or roll a minimal version.

## Decision

We add a **`docs/specs/<slug>/{requirements,design,tasks}.md`** workflow,
no external dependencies. Three Markdown files per non-trivial change,
committed in order. After design is approved, the spec is read-only and the
relevant sub-agent (`feature-builder`, `fix-investigator`) executes against
it.

External systems are **not installed**. Reasons:

- The repo's router (`AGENTS.md`) already names the sub-agents and skills
  that read these files. Adding a CLI would duplicate that router.
- `docs/conventions.md` already mandates `Docs:` footer on every commit;
  we extend it to also point at the spec dir.
- The Hermes native `todo` tool + `delegate_task` already cover the
  parallel-work problem. We just need to use them, not buy a new orchestrator.

Optional Phase 2 (separate decision): if vibe-coding with several external
agents becomes routine, layer **Vibe-Kanban** as the orchestrator. It does
not replace the spec; it drives parallel worktrees, each one a spec.

### Shape

| File | Question it answers | When written |
|------|---------------------|--------------|
| `requirements.md` | What does the user need? Who has it? | First. Committed alone. |
| `design.md` | How do we meet it? Which files? Which fields? | After requirements approved. |
| `tasks.md` | What's the ordered work breakdown? Who's executing? | Last, before code. |

### Lifecycle

| Phase | Owner | Output |
|-------|-------|--------|
| Spec drafting | Human + `spec-driven-feature` skill | 3 files committed on `feature/<slug>` or `fix/<slug>` |
| Spec approved | Human | Spec dir frozen (read-only) |
| Execution | `feature-builder` or `fix-investigator` | Code + `docs/features/<slug>.md` (or `docs/fixes/`) |
| Audit | `docs-keeper` | Drift report |

### Commit footer (extends conventions.md)

```bash
git commit -m "feat(<module>): <what>

<Body.>

Docs: docs/specs/<slug>/design.md
Docs: docs/features/<slug>.md
```

## Consequences

### Positive

- Spec forces the user to articulate acceptance criteria before code
  burns tokens.
- Committed spec preserves the conversation history even when the agent
  loses context (24h idle timeout, model switches).
- Spec dir is a natural hook for `docs-keeper` to detect drift later.
- No external dependency. The shape is portable; if you later adopt Spec
  Kit or OpenSpec, the migration is "rename the dir".

### Negative

- One more step before code lands. Worth it for >1-file changes; overhead
  for one-line fixes (those skip the spec and go straight to
  `fix-investigator`).
- The spec is human-maintained after approval. If the agent discovers the
  spec is wrong mid-execution, it must stop, file a `spec(<slug>): revise`
  commit, then continue. Discipline required.

### Rejected alternatives

- **Task Master** (`eyaltoledano/claude-task-master`) — external CLI, JSON
  state file, no Markdown. Brings 27k stars but adds a node dep we don't
  otherwise need.
- **GitHub Spec Kit** — four Markdown files + a `Specify` CLI. More
  ceremony than our 3-file shape; their `constitution.md` overlaps with
  our ADRs.
- **OpenSpec** — same shape as ours, but adds a CLI and a registration
  step. Net: more for the same benefit.
- **Vibe-Kanban** as primary orchestrator — right tool for parallel vibe
  coding sessions, but it's an orchestrator on top of our system, not a
  replacement. Adopt as Phase 2 only if needed.
- **LangGraph / CrewAI / AutoGen** — frameworks for general multi-agent
  apps. Multiple sources (incl. practitioner retrospectives) argue these
  are the wrong hammer for coding agents, which work best as
  one-model + tools + loop.

## References

- <https://agents.md/> — cross-tool briefing standard
- <https://github.com/eyaltoledano/claude-task-master> — rejected alternative
- <https://github.com/BloopAI/vibe-kanban> — Phase 2 candidate
- ADR-0003 (docs strategy) — already covers doc-per-change; this ADR
  extends it with a spec phase
- `docs/conventions.md` — extended by this ADR
- `.agents/skills/spec-driven-feature/SKILL.md` — implements this ADR
- `.agents/skills/todo-discipline/SKILL.md` — companion
- `.agents/skills/worktree-isolation/SKILL.md` — companion for parallel runs