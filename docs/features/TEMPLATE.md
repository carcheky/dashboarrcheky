# Feature: <slug>

> One per user-visible feature. Same PR as code.

**Status:** proposed | in-progress | shipped | reverted
**Branch:** `feature/<slug>`
**PR:** #<n>
**Module:** <sonarr | radarr | lidarr | sabnzbd | nzbget | tautulli | search | settings | dashboard | core>
**Shipped:** v<MAJOR.MINOR.PATCH> | not-yet

## What

<1-2 sentences. What user can now do.>

## Why

<Problem solved. Link issue: #N or motivation.>

## How

<Code path(s). New files. Changed files. Brief.>

```
lib/modules/<name>/...
```

## UX

<Wireframe ASCII if non-trivial. Or link to Figma. Or "no UI change".>

```
+--------------------+
| <field>            |
+--------------------+
```

## Data

| Change | Detail |
|--------|--------|
| Hive box | `<Box>` field N+1 `<Name>` type `<T>` default `<V>` |
| API endpoint | `GET /api/v3/<path>` |
| Route | `/<m>/<path>` |
| Settings key | `<dot.path>` |

## Risks

| Risk | Mitigation |
|------|-----------|
| <risk> | <mitigation> |

## Test

- [ ] Manual: <steps>
- [ ] Unit: <what> in `<test_file>`
- [ ] Widget: <what> in `<test_file>`
- [ ] Integration: <scenario> in `<test_file>`

## Rollback

`<git revert <sha>>` or delete branch + cherry-pick revert to beta.

## Related

- Module doc: `../modules/<name>.md`
- Issue: #<n>
- ADR: `../adr/<NNNN>-<slug>.md` (if any)
