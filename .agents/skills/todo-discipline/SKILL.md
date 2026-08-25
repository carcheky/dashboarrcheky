---
name: todo-discipline
description: Use the structured `todo` tool correctly for multi-step work. Tracks steps, prevents silent drops, surfaces blockers. Use at the start of any change that takes >3 tool calls or >1 file edit.
---

# Todo Discipline

The `todo` tool is a structured checklist that survives across turns. It is
**not** a TODO comment in code. It is **not** a free-text plan in chat. It is
the contract between you and the user for "what I will do before claiming
done".

## When to load

- Any change touching >3 files
- Any change requiring >5 tool calls
- Any multi-stage work: install → build → test → doc → commit
- Any work the user will likely interrupt and come back to

Skip for trivial one-shot edits.

## Rules (the whole skill in 7 lines)

1. **One item in `in_progress` at a time.**
2. **Mark `completed` only after the work is verified done**, never based on intent.
3. **Mark `cancelled` (with a reason) when something fails**, and add a
   revised item rather than rewriting the list silently.
4. **For "do all N things" tasks, enumerate every instance** as its own row.
5. **Reference the artefact, not the action.** `Build APK` is bad; `Build APK (lunasea/build/...)` is good.
6. **Order by priority.** Do not sort by chronology; sort by "what blocks what".
7. **Always call `todo` at the start** of the session that touches this work, even if you're continuing from a prior session.

## Patterns

### Bootstrapping from a vague user request

```text
User: "Instala y depura lunasea en mi pixel 9, identifica un error,
       y documéntalo, diagnostícalo, y corrígelo"
```

Bad first reply: "OK, voy a empezar instalando..."

Good first reply: read the router, then a `todo` row per step the user asked
for, plus verification. Often the order is:

```
1. [in_progress] Read router (CLAUDE.md) + build skill (lunasea-build)
2. [pending]   Verify host env (docker, adb, device)
3. [pending]   Install debug APK on device
4. [pending]   Launch + capture logcat
5. [pending]   Identify one real bug with file:line
6. [pending]   Diagnose root cause (read code, confirm)
7. [pending]   Apply minimal fix
8. [pending]   Re-build, re-install, re-repro
9. [pending]   Write docs/fixes/<slug>.md
10. [pending]  Commit with Docs: footer
```

### Mid-session fork (branching the work)

User changes mind mid-flight ("actually just fix the warning, skip the
back-button"):

```text
mark item 7 as cancelled (reason: "user changed scope")
add item 7-new: apply one-line manifest fix
re-order: 7-new before 9
```

Do **not** delete the cancelled item silently. Future-you and the user
should see why item 7 was skipped.

### Multi-agent delegation

When handing work to a sub-agent (`feature-builder`, `fix-investigator`,
`docs-keeper`):

- Parent owns the top-level `todo`.
- Sub-agent gets its own internal checklist, not the parent's. The parent
  sees only "delegated to X" → "X reported done".
- On sub-agent failure: mark `cancelled` with the agent's failure message
  in the reason field. Don't paste the agent's full transcript into the
  todo — that's a session note.

## Pitfalls

- **Marking done without verification.** "I think the build succeeded" is
  not done. Wait for the actual exit code or artefact.
- **Hiding cancelled items.** Cancel + reason = audit trail. Rewrite = noise.
- **One item, ten steps.** Break apart. If a row takes >1 commit or >5 min
  of work, split.
- **No verification row.** Every meaningful change ends with "Verify
  <observable thing>". No verification = no done.

## Output

At session end, the `todo` list itself is the output. Optionally call
`session_search` to record the final state in the handoff:

```text
## Done
- (mirror the todo list here, in prose, with file:line refs)
```

## See also

- `.claude/agents/feature-builder.md` — uses this discipline for code work
- `.claude/agents/fix-investigator.md` — uses this discipline for bug work
- `spec-driven-feature` skill — wraps the todo in a 3-file spec for non-trivial work