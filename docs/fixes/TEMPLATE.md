# Fix: <slug>

> One per bug fix. Same PR as code.

**Status:** triaged | in-progress | shipped | wontfix
**Branch:** `fix/<slug>`
**PR:** #<n>
**Module:** <name | core | build>
**Severity:** blocker | major | minor | cosmetic
**Affected versions:** <vA.B.C to vX.Y.Z>
**Shipped:** v<MAJOR.MINOR.PATCH> | not-yet

## Symptom

<What user sees. Exact error string if any.>

## Repro

1. <step>
2. <step>
3. <broken>

## Root cause

<File:line. Why it broke.>

```
lib/modules/<name>/path/file.dart:L42
```

## Fix

<What changed. Why this approach. Trade-offs considered.>

```
<diff or summary>
```

## Test

- [ ] Regression test: `<test_file>:<test_name>` covers repro.
- [ ] Manual verify: <steps> → passes.

## Regression risk

| Area | Why safe |
|------|----------|
| <area> | <reason> |

## Related

- Module doc: `../modules/<name>.md`
- Issue: #<n>
- Similar past fix: `../fixes/<slug>.md`
