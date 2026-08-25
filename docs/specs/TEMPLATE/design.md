# Spec — <slug> — Design

> **How** the requirements are met. Tech choices, file paths, data shapes.
> Approved before any code lands.

**Status:** draft | approved | in-progress | shipped
**Pairs with:** `requirements.md`

## Approach

<1 paragraph. Why this shape. Rejected alternatives at the bottom.>

## Affected files

| Path | Change | Why |
|------|--------|-----|
| `lunasea/lib/modules/<name>/...` | new / modify / delete | reason |
| `lunasea/lib/...` | modify | reason |
| `docs/modules/<name>.md` | update | doc hygiene |
| `docs/features/<slug>.md` | new | doc per change |

## Data

- New Hive box / field: `<name>` with `@HiveField(N)` where `N` is the next free index. **Never reorder.** Use `defaultValue:` for new fields.
- New API endpoint: `<METHOD> <path>` (Dio + Retrofit).
- New route: `/<name>/<sub>` in `lib/router.dart`.

## Behaviour

| Situation | Expected |
|-----------|----------|
| normal | … |
| edge case | … |
| error | … |

## Risks

| Risk | Mitigation |
|------|------------|
| … | … |

## Rejected alternatives

- **Option X** — rejected because Y.
- **Option Z** — rejected because W.

## References

- Requirements: `requirements.md`
- ADR (if formal): `../adr/<id>-<slug>.md`