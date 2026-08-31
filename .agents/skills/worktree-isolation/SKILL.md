---
name: worktree-isolation
description: Run multiple AI coding agents (or one agent on multiple tasks) in parallel without them stepping on each other's files. Each task gets its own git worktree; the parent merges verified work back into the integration branch. Use when vibe-coding several features or running parallel investigations (e.g. "fix 16 KB page size" + "audit plugins" + "ship the next release").
---

# Worktree Isolation

When more than one agent is editing the same repo at the same time, they
will collide on `git add`, on `dart analyze`, and on the APK output path.
The fix is the same as for human pair work: each task gets its own
**working tree** (filesystem view) backed by its own **branch**. The parent
merges them in a known order.

## When to load

- Running ≥2 agents in parallel (e.g. background sub-agent + foreground
  edits, or two `delegate_task` calls at once).
- Vibe-coding several features without serialising.
- Investigating two unrelated bugs at the same time.
- Testing a risky change against the current state without touching it.

Skip when you only have one linear task. That's a normal branch, not a
worktree.

## Pre-flight

- `git status` clean. If not, commit or stash first.
- `git fetch` so remote-tracking branches are current (if you have a remote).
- Decide the integration branch (usually `master` or `beta` in this repo).

## Steps

### 1. Create the worktree

```bash
git worktree add ../dashboarrcheky-<task-slug> -b <branch-type>/<slug> <integration>
```

Examples:

```bash
git worktree add ../dashboarrcheky-fix-16kb -b fix/android-16kb-page-size beta
git worktree add ../dashboarrcheky-audit-plugins -b chore/audit-16kb-plugins beta
```

Each worktree is a separate directory with its own `lunasea/build/` (Gradle
cache survives across worktrees because the cache is in `~/.gradle`, not
the project, but each worktree has its own APK output).

### 2. Hand off the task

For each worktree, the agent gets:

- The worktree path (not the original repo path).
- The spec dir if you have one: `docs/specs/<slug>/`.
- The branch name to commit on.
- The exit criteria: "build clean, install on Pixel 9, repro the fix, write
  doc, push branch, report SHA".

```bash
delegate_task(
    goal="Run the 16 KB Phase 1 plan in worktree ../dashboarrcheky-fix-16kb on branch fix/android-16kb-page-size.",
    context="Read ADR-0004 Phase 1 + docs/reference/toolchain.md + .agents/skills/adb-page-size-toggle/SKILL.md. Apply the two-line packaging fix, rebuild, install on Pixel 9, verify PageSizeMismatchDialog is gone, write docs/fixes/android-16kb-page-size.md. Report APK sha1, dialog count, branch SHA, doc path."
)
```

### 3. Watch the worktrees

```bash
git worktree list
```

shows what's open. While one agent works in `../dashboarrcheky-fix-16kb`, you
can edit in the main `dashboarrcheky/` without colliding.

### 4. Verify before merging

For each completed worktree:

```bash
cd ../dashboarrcheky-fix-16kb
git log --oneline -5            # what landed
git diff <integration> --stat    # scope
git diff <integration>           # review
```

If the agent's claims don't match the diff, the agent lied or had a partial
failure. Reject the merge; fix the task list; iterate.

### 5. Merge in dependency order

```bash
cd <main-repo>
git merge --no-ff <branch-from-worktree>
```

If two branches touch the same file (`AndroidManifest.xml`, `pubspec.yaml`),
merge the smaller one first, then resolve in the larger. Don't try to
rebase across worktrees — that's how parallel work dies.

### 6. Clean up

```bash
git worktree remove ../dashboarrcheky-fix-16kb
git branch -d <merged-branch>
```

## Pitfalls (real ones)

- **Shared output dirs.** If two worktrees both write to
  `lunasea/build/app/outputs/flutter-apk/`, the host's `adb install` sees
  whichever was written last, not necessarily the one you meant. Always
  install from the worktree that produced the APK.
- **Docker bind-mounts.** `docker-compose.android.yml` bind-mounts
  `./lunasea` from the current directory. Each worktree has its own
  `./lunasea`, so the build container sees the right one — but only if you
  run `docker compose` from inside the worktree directory, not the parent.
- **Shared Gradle cache is fine.** Gradle cache lives in `~/.gradle` outside
  the repo; concurrent builds coordinate via Gradle's own locking. No
  collision.
- **Stale worktrees.** After `git worktree remove`, the directory still
  exists until you delete it. Use `git worktree prune` after manual deletes.
- **Background agents still run in the original cwd.** If you launch a
  background build (e.g. `terminal(background=true)`) from inside a
  worktree, the build process keeps that cwd even after you `cd` back.
  Track session IDs with `process(action='list')` and clean them up.

## Output

At end, a single integration branch on `master` (or `beta`) containing the
verified commits from each worktree. Report:

- Worktree paths created and removed
- Branches merged (with SHAs)
- Merge order
- Any unresolved conflicts (should be zero; if not, escalate)

## See also

- `spec-driven-feature` skill — what to put in each worktree
- `todo-discipline` skill — what the parent tracks while worktrees run
- `.claude/agents/feature-builder.md` — the typical worktree-resident agent
- `WORKFLOW.md` — repo branching model (works inside a worktree too)