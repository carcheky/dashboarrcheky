# LunaSea — Git Workflow

This document describes the branching model, versioning, and release process for the
LunaSea fork at `github.com/carcheky/dashboarrcheky`.

> **TL;DR:** `master` is stable (tagged with versions). `beta` is for QA. Work happens
> on `feature/<name>` branches. Tags follow [SemVer 2.0.0](https://semver.org/).

---

## Branches

| Branch    | Purpose                                         | Tagged? | Lifespan      |
|-----------|-------------------------------------------------|---------|---------------|
| `master`  | Stable releases. Always deployable.             | Yes     | Permanent     |
| `beta`    | Pre-release QA. Cherry-picked from `master`.    | Yes     | Permanent     |
| `feature/<name>` | One feature or fix. Branched from `master`. | No      | Deleted on merge |

### Why three branches and not full GitFlow?

`master + beta + feature/*` keeps the cognitive load low for 1–2 devs while still
giving us a real QA gate. You can always grow this into full GitFlow
(`develop`, `release/*`, `hotfix/*`) later if the team scales.

---

## Day-to-day

### Start a new feature

```bash
git checkout master
git pull
git checkout -b feature/<short-kebab-name>
# … do work, commit often with conventional commits
```

Naming examples:
- `feature/add-wake-on-lan-toggle`
- `feature/lidarr-quality-profiles`
- `fix/sonarr-404-on-empty-list`

### Merge a feature into master

```bash
git checkout master
git merge --no-ff feature/<name>   # --no-ff preserves the merge commit / history
git branch -d feature/<name>
```

### Promote a feature to beta for QA

If a feature needs QA before the next stable release:

```bash
git checkout beta
git cherry-pick <commit-sha-from-master>
# … QA team tests this build
```

When `beta` is approved, fast-forward `master` to `beta`:

```bash
git checkout master
git merge --ff-only beta
```

---

## Versioning (SemVer)

Tags follow `v<MAJOR>.<MINOR>.<PATCH>` and optional pre-release suffixes:

| Tag                  | When                                                  |
|----------------------|-------------------------------------------------------|
| `v1.0.0`             | First stable release                                  |
| `v1.2.3`             | Backwards-compatible bug fixes / features             |
| `v1.0.0-beta.1`      | Beta build for QA                                     |
| `v1.0.0-rc.1`        | Release candidate                                     |
| `v2.0.0`             | Breaking change (Flutter SDK bump, schema migration)  |

The tag is always created on the merge commit that updates `pubspec.yaml`'s `version:`
field. `+N` (build number) is incremented automatically by the build script.

### How `pubspec.yaml` aligns with tags

```
pubspec.yaml:    version: 1.2.3+45
git tag:         v1.2.3
apk versionName: 1.2.3-dev   (debug builds add -dev suffix)
apk versionCode: 45
```

---

## Releases

### Cutting a stable release (on `master`)

```bash
# 1. Bump version in pubspec.yaml (and android/app/build.gradle if needed)
# 2. Update CHANGELOG.md
git checkout master
git commit -am "release: v1.2.3"
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin master --tags
```

### Cutting a beta (on `beta`)

```bash
git checkout beta
# bump pubspec.yaml to 1.2.4-beta.1
git commit -am "release: v1.2.4-beta.1"
git tag -a v1.2.4-beta.1 -m "Beta 1 for v1.2.4"
git push origin beta --tags
```

---

## Commit messages (Conventional Commits)

Enforced by Husky + Commitlint + Commitizen (already wired in `lunasea/package.json`).

Use `npm run commit` instead of `git commit` — it walks you through the format.

```
feat(lidarr): add quality profile filter
fix(router): prevent back-button loop on settings
docs(readme): document docker workflow
chore(deps): bump go_router to 14.8.1
release: v11.0.0
```

---

## Branch protection (recommended on GitHub)

Once you push `beta` and `master` to `origin`, configure in GitHub Settings → Branches:

- **`master`** — Require pull request reviews before merging, require status checks
  (CI build) to pass, disallow direct pushes.
- **`beta`** — Same as master, but allow force-pushes for emergency hotfixes.

Until then, work directly on local branches and `git push` when ready.

---

## Initial state of this fork

- `master` and `beta` exist locally, both pointing at upstream commit
  `6ee0bf9a monorepo: consolidate all public LunaSea repositories`.
- Baseline tag `v11.0.0` marks the starting point of the fork.
- Push to `origin` only when you're ready — see command in [Releases](#cutting-a-stable-release-on-master).
