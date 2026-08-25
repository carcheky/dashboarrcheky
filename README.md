# LunaSea fork — `carcheky/dashboarrcheky`

Self-hosted media controller. One Flutter app to rule Sonarr, Radarr,
Lidarr, SABnzbd, NZBGet, Tautulli.

This is a fork of [LunaSea](https://github.com/LunaSeaCO/LunaSea) with a
token-efficient doc system, predictive-back fix, and 16 KB page-size
plan. The other top-level directories (`lunasea-cloud-functions`,
`lunasea-docs`, `lunasea-notification-service`) are upstream repos
archived for reference only — **active dev is in `lunasea/`**.

## At a glance

| What | Where |
|------|-------|
| App code | [`lunasea/`](lunasea/) |
| Documentation site | [`docs/`](docs/) → published at <https://carcheky.github.io/dashboarrcheky/> |
| Human-readable doc index | [`docs/index.md`](docs/index.md) |
| AI agent briefing | [`CLAUDE.md`](CLAUDE.md) (router) / [`AGENTS.md`](AGENTS.md) |
| Decisions (ADRs) | [`docs/adr/`](docs/adr/) |
| Per-feature specs | [`docs/specs/`](docs/specs/) |
| Roadmap | [`docs/roadmap.md`](docs/roadmap.md) |
| Timeline | [`docs/timeline.md`](docs/timeline.md) |
| Latest session handoff | [`.agents/sessions/`](.agents/sessions/) (latest mtime) |
| Build & install | [`docs/build.md`](docs/build.md) |
| Git workflow | [`docs/workflow.md`](docs/workflow.md) |
| Troubleshooting | [`docs/troubleshooting.md`](docs/troubleshooting.md) |

## Quick start

```bash
# 1. Build the APK (Docker; ~5-10 min cold, ~30 s warm)
docker compose -f docker-compose.android.yml build
scripts/build-android.sh beta

# 2. Install on the connected device
adb install -r lunasea/build/app/outputs/flutter-apk/app-debug.apk

# 3. Launch
adb shell am start -n app.lunasea.lunasea.debug/app.lunasea.lunasea.MainActivity
```

See [`docs/build.md`](docs/build.md) for the full loop and
[`.claude/skills/lunasea-build/SKILL.md`](.claude/skills/lunasea-build/SKILL.md)
for an agent-readable summary.

## Branches

| Branch | Purpose |
|--------|---------|
| `master` | Stable. Tagged `vMAJOR.MINOR.PATCH`. |
| `beta` | Pre-release QA. Cherry-picked from `master`. |
| `feature/<slug>` / `fix/<slug>` | One feature or fix per branch. From `master` or `beta`. |

See [`docs/workflow.md`](docs/workflow.md) and
[`docs/conventions.md`](docs/conventions.md) for the full branching
model and commit format (Conventional Commits).

## Status

- **Version:** `11.0.0` baseline + this fork's deltas (see [`docs/timeline.md`](docs/timeline.md))
- **Active branch:** `beta`
- **Stack:** Dart 3.7+ / Flutter 3.27+ / Android minSdk 24 / targetSdk 35

## Licence

The original LunaSea project is MIT-licensed — see
[`lunasea/LICENSE.md`](lunasea/LICENSE.md). This fork inherits the same
licence. No proprietary additions.