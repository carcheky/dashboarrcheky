# Git Workflow

> Branches, tags, releases. TL;DR at top.

**TL;DR:** `master` stable. `beta` QA. Work on `feature/<name>`. SemVer tags.

## Branches

| Branch | Purpose | Tagged | Lifespan |
|--------|---------|--------|----------|
| `master` | Stable. Always deployable. | Yes | Permanent |
| `beta` | Pre-release QA. | Yes | Permanent |
| `feature/<name>` | One feature / fix. From master. | No | Deleted on merge |
| `fix/<name>` | Same as feature, scoped to bug. | No | Deleted on merge |

Why 3 branches not GitFlow: 1-2 devs. Low cognitive load. Real QA gate. Can grow later.

## Day-to-day

### New feature

```bash
git checkout master
git pull
git checkout -b feature/<short-kebab>
# work, commit with Conventional Commits
# create docs/features/<slug>.md same PR
```

### Merge to master

```bash
git checkout master
git merge --no-ff feature/<name>   # keep merge commit
git branch -d feature/<name>
```

### Promote to beta

```bash
git checkout beta
git cherry-pick <sha-from-master>
# QA tests
# when approved:
git checkout master
git merge --ff-only beta
```

## Versioning (SemVer)

Tag = `v<MAJOR>.<MINOR>.<PATCH>` + optional suffix.

| Tag | When |
|-----|------|
| `v1.0.0` | First stable |
| `v1.2.3` | Backwards-compat fix/feat |
| `v1.0.0-beta.1` | Beta QA |
| `v1.0.0-rc.1` | Release candidate |
| `v2.0.0` | Breaking (SDK bump, schema migration) |

Tag sits on commit that bumps `pubspec.yaml` `version:`. `+N` (build) auto-incremented by build script.

```
pubspec.yaml:    version: 1.2.3+45
git tag:         v1.2.3
apk versionName: 1.2.3-dev   (debug adds -dev)
apk versionCode: 45
```

## Releases

### Stable (master)

```bash
# 1. Bump pubspec.yaml
# 2. Update CHANGELOG.md
git checkout master
git commit -am "release: v1.2.3"
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin master --tags
```

### Beta (beta)

```bash
git checkout beta
# bump pubspec.yaml to 1.2.4-beta.1
git commit -am "release: v1.2.4-beta.1"
git tag -a v1.2.4-beta.1 -m "Beta 1 for v1.2.4"
git push origin beta --tags
```

## Commits — Conventional

Enforced by Husky + Commitlint + Commitizen (in `lunasea/package.json`). Use `npm run commit`.

```
feat(lidarr): add quality profile filter
fix(router): prevent back-button loop
docs(readme): document docker workflow
chore(deps): bump go_router to 14.8.1
refactor(api): split Dio client by service
test(sonarr): cover empty queue
release: v11.0.0
```

Required footer for user-visible changes:

```
Docs: docs/features/<slug>.md
Refs: #42
```

See `conventions.md` for full commit rules.

## Branch protection (recommended)

GitHub Settings → Branches:

- `master` — PR review required. CI must pass. No direct push.
- `beta` — Same as master. Allow force-push for hotfixes.

Until pushed, work locally + `git push` when ready.

## Initial state of this fork

- `master` and `beta` exist locally, both at upstream `6ee0bf9a monorepo: consolidate all public LunaSea repositories`.
- Baseline tag `v11.0.0` = fork start.
- Push to `origin` only when ready.
