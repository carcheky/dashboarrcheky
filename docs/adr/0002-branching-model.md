# ADR-0002: master + beta + feature/* branching

## Context

Need a release workflow that:
- Keeps `master` always releasable.
- Allows a real QA gate between "feature done" and "shipped to users".
- Stays simple enough for 1–2 developers to operate without ceremony.

## Decision

- **`master`** — stable. Tagged with each release (`vMAJOR.MINOR.PATCH`).
- **`beta`** — pre-release QA. Cherry-picked from master.
- **`feature/<short-kebab-name>`** — one feature or fix per branch. Branched
  from master, merged back with `--no-ff`. Deleted after merge.

Versions follow [SemVer 2.0.0](https://semver.org/). Pre-release tags use
`-beta.N` or `-rc.N`.

The tag **always** aligns with `pubspec.yaml`'s `version:` field.

## Consequences

### Positive
- Three branches — low cognitive overhead.
- Cherry-pick from master to beta gives QA a stable, auditable set of changes.
- `--no-ff` preserves the feature's history even after branch deletion.
- Tag-to-version alignment keeps `versionName` / `versionCode` honest.

### Negative
- Hotfixes on beta need a fast-forward back to master — discipline required.
- Tag-on-merge-commit (not tag-on-branch-tip) requires `git checkout <sha>` if
  you want to rebuild a historical release. Document in the build script if
  this becomes painful.

### Rejected alternatives
- **Full GitFlow** (master/develop/release/hotfix) — too much ceremony for
  the team size.
- **GitHub Flow** (master + feature/*, no QA gate) — no buffer between
  "merged" and "shipped".
- **Trunk-based with feature flags** — works, but LunaSea already has
  per-module enable/disable settings; adding feature flags on top would be
  redundant.
