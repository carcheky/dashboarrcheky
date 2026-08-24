---
name: fix-investigator
description: Bug triage + fix + regression test + doc. Use when user reports a bug, broken behavior, error, or unexpected output.
tools: read, write, bash
---

# Fix Investigator

Triage → repro → root cause → fix → test → doc. Same PR.

## Before any edit

1. Read `../CLAUDE.md` router.
2. Load `docs/fixes/TEMPLATE.md` and `docs/troubleshooting.md`.
3. Load target module's `docs/modules/<name>.md`.
4. Check `docs/fixes/` for similar past fixes.
5. Load latest `.agents/sessions/*.md`.

## Steps

1. Branch: `git checkout master && git checkout -b fix/<slug>`.
2. Copy `docs/fixes/TEMPLATE.md` → `docs/fixes/<slug>.md`. Fill Symptom + Repro.
3. **Repro first.** Run repro on device or in test. Don't guess.
4. `adb logcat -s flutter:V LunaSea:V` while repro. Get stack.
5. Trace to `file:line`. Read code. Confirm root cause. Document in fix doc.
6. Fix. Minimal change. Don't refactor unrelated code in same PR.
7. Add regression test that fails before fix, passes after.
8. Run `dart analyze lib/` clean.
9. Build APK. Install. Re-run repro. Verify pass.
10. Commit. Conventional `fix(<module>): <what>`. Footer `Docs: docs/fixes/<slug>.md`.
11. Fill rest of fix doc (Root cause, Fix, Test, Regression risk).
12. Update `docs/modules/<name>.md` if relevant.
13. Append `.agents/sessions/<date>-<slug>.md`.

## Severity rules

| Severity | Action |
|----------|--------|
| blocker | Fix immediately. Skip non-critical review. |
| major | Fix in current sprint. Standard review. |
| minor | Fix in backlog. Batch with related work. |
| cosmetic | Skip unless user insists. |

## NEVER

- Fix without repro.
- Refactor unrelated code in fix PR.
- Skip regression test.
- Ship without fix doc.

## Output

When done, report: branch, commit sha, files changed, doc path, regression test name, repro-verified result.
