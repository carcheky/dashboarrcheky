# ADR-0006: Plans in repo (`.hermes/plans/`) — team artifact, not per-machine state

## Status

Accepted. 2026-09-02.

## Context

The repo references `.hermes/plans/2026-09-01_120124-dashboard-stack-widgets.md`
from four places (`docs/specs/add-pending-imports-tile/{requirements,design,tasks}.md`).
The plan is the "plan maestro" that produced the spec — it is part of the
team's working memory for that feature.

The previous `.gitignore` had a blanket `.hermes/` rule. Under that rule,
`.hermes/plans/<file>` was untracked — the spec referenced a file the repo
couldn't even hold. This was a real bug: the spec was lying about its
provenance.

Three sources of practice exist:

1. **Hermes skill `plan`** (`~/.hermes/skills/software-development/plan/SKILL.md`,
   mirrored upstream at `github.com/NousResearch/hermes-agent`): "save the
   plan **inside the active workspace** under `.hermes/plans/`". Ambiguous
   about whether "workspace" means "git repo" or "scratch dir" — but the
   upstream Hermes issue #6203 + PR #1381 moved the default *away* from
   `$HOME/.hermes/plans/` *toward* workspace-relative precisely to keep the
   plan with the project, not with the user.

2. **Upstream Hermes `.gitignore`** blanket-ignores `.hermes/`. Treats
   plans as "not artifacts of the codebase".

3. **Community forks** (e.g. `nbiish/ainish-coder` commit
   `38b33a7893ebc47122561e61988170b8e9e9024f`): "None of these are
   intended to be committed." Also a blanket-ignore.

## Decision

We track `.hermes/plans/` and `.hermes/skills/` (skill content, not hub
state) in this repo. We ignore only the per-machine state subpaths
under `.hermes/`: `state.db`, `state.db-*`, `.env`, `auth.json`,
`sessions/`, `logs/`, `cache/`, and `skills/.hub/`. We also ignore
`.skills_prompt_snapshot.json` at the repo root (per-session cache,
regenerated each chat, ~54 KB).

| Path under `.hermes/` | Tracked? | Why |
|----------------------|----------|-----|
| `plans/` | yes | Team artifact. Specs reference these. |
| `skills/<name>/SKILL.md` and `references/` | yes | Skill content shared across the team. |
| `plugins/<name>/` | yes | Project plugins (`HERMES_ENABLE_PROJECT_PLUGINS`). |
| `state.db`, `state.db-*` | no | SQLite session store, large, regenerable. |
| `.env` | no | Secrets. |
| `auth.json` | no | OAuth tokens, credential pools. |
| `sessions/` | no | Gateway routing index, JSONL transcripts. |
| `logs/` | no | Gateway + error logs. |
| `cache/` | no | LLM response cache, image cache, etc. |
| `skills/.hub/` | no | Lock, quarantine, audit log, index cache. |
| `skills-lock.json` | n/a (removed) | Phantom path — the real lock is `skills/.hub/lock.json`. |

This is a **deliberate divergence** from upstream Hermes and the
community-majority practice. Reasons to diverge here, in this repo:

- `docs/specs/add-pending-imports-tile/{requirements,design,tasks}.md`
  reference the plan maestro by relative path. Tracking the plan keeps
  the spec honest.
- `AGENTS.md` already mandates that `.agents/sessions/<date>-<slug>.md`
  is committed ("Close session / handoff → `.agents/sessions/TEMPLATE.md`").
  The same logic applies to plans: process artifacts of the team go in
  the repo.
- The plan file is small (~20 KB), text, and stable. There is no
  per-machine data in it (no API keys, no session state, no PII).
- Drift risk: the plan is the source for the spec, which is the source
  for the code. Untracking the plan while tracking the spec creates a
  provenance gap.

Reasons **not** to track (rejected):

- **Upstream disagrees.** Acknowledged. We diverge consciously and
  document the rationale in the comment of `.gitignore` and in this
  ADR.
- **Risk of leaking machine-specific data into a plan.** Mitigated by
  the skill itself: the `plan` skill prohibits executing commands,
  reading secrets, or any side effect — the deliverable is a Markdown
  plan only. A plan that contains an API key is a skill violation, not
  a git tracking issue.

## Consequences

### Positive

- Specs can cite the plan by path; provenance is verifiable in CI.
- Future plans for new specs follow the same pattern; no second
  decision to make.
- New team members see the plan alongside the spec when they
  `git clone` — onboarding is one `git pull` deep.
- The gitignore now expresses the actual policy (per-path),
  not a blanket rule that broke provenance.

### Negative

- The repo carries ~20 KB per plan. Acceptable.
- If a future plan DOES contain sensitive data (a misbehaving agent),
  the damage is in git history, not just local. Mitigation: the
  `plan` skill is read-only; we audit plans on commit the same way
  we audit any `docs/` change.
- One more place to look during code review. Cheap.

### Reversibility

If upstream practice changes or this repo stops referencing plans from
specs, revert the rule: blanket `.hermes/` again. The cost is one
`.gitignore` change plus a `git rm` for any tracked plans.

## Open questions

- **Should `.hermes/skills/` be tracked when a future agent adds
  in-repo skills to this project?** Current gitignore allows it; the
  precedent (`.agents/skills/` already in repo) suggests yes. Deferred
  to first concrete case.

## References

- ADR-0005 (spec-driven workflow) — the plan maestro is the input
  that produces the spec dir.
- `docs/SUMMARY.md` — specs vs features doc routing.
- `docs/specs/add-pending-imports-tile/{requirements,design,tasks}.md`
  — concrete example of the plan-spec-code chain.
- `.hermes/plans/2026-09-01_120124-dashboard-stack-widgets.md` — the
  first tracked plan.
- Hermes skill `plan` — `~/.hermes/skills/software-development/plan/SKILL.md`
  and upstream mirror at
  `github.com/NousResearch/hermes-agent/blob/main/skills/software-development/plan/SKILL.md`.
- Hermes issue #6203 + PR #1381 — upstream move toward
  workspace-relative plan paths.
- Community fork `nbiish/ainish-coder` commit `38b33a7` — rejected
  alternative (blanket ignore) with rationale cited.
- DeepSeek V4-Pro external review, 2026-09-02 — surfaced
  `.hermes/skills-lock.json` as a phantom path and
  `.skills_prompt_snapshot.json` as an un-ignored cache root file.
