# Index

> 30-line map. Start here.

## Repo

Fork LunaSea. Flutter app. Controls Sonarr/Radarr/Lidarr/SABnzbd/NZBGet/Tautulli.

## Quick links

| Want | Read |
|------|------|
| Build APK / install via adb-wifi | [build.md](build.md) |
| Git branching + releases | [workflow.md](workflow.md) |
| Code organization | [architecture.md](architecture.md) |
| Style + naming rules | [conventions.md](conventions.md) |
| One specific module | [modules/index.md](modules/index.md) |
| HTTP / DB / routes | [api/index.md](api/index.md) |
| Broken build / runtime | [troubleshooting.md](troubleshooting.md) |
| Why a decision | [adr/index.md](adr/index.md) |
| New feature template | [features/TEMPLATE.md](features/TEMPLATE.md) |
| Bug fix template | [fixes/TEMPLATE.md](fixes/TEMPLATE.md) |
| Session handoff | `.agents/sessions/TEMPLATE.md` |
| Agent entry (AI tools) | `../CLAUDE.md` (outside mkdocs — repo root) |

## Layout

```
dashboarrcheky/
├── lunasea/                    # Flutter app. Active dev.
│   ├── lib/                    # All Dart
│   ├── android/ ios/ linux/ macos/ windows/ web/
│   ├── assets/                 # images, l10n, fonts
│   ├── scripts/                # codegen (l10n, etc)
│   └── pubspec.yaml
├── lunasea-cloud-functions/    # Firebase. Don't touch.
├── lunasea-notification-service/  # Don't touch.
├── lunasea-docs/               # Old docs site. Don't touch.
├── docs/                       # ← This site. mkdocs source.
│   ├── features/               # One .md per feature PR.
│   ├── fixes/                  # One .md per bug fix.
│   ├── modules/                # Per-module living docs.
│   ├── api/                    # HTTP, Hive, routing.
│   ├── reference/              # env, gradle, codegen.
│   ├── adr/                    # Why decisions.
│   └── ...
├── .agents/
│   ├── skills/                 # AI skills (frontend-design, accessibility, lunasea-build...)
│   └── sessions/               # Per-session handoffs.
├── .claude/
│   ├── skills/                 # Claude-specific skills.
│   └── agents/                 # Sub-agents (feature-builder, fix-investigator, docs-keeper).
├── docker-compose.android.yml
├── Dockerfile.android
├── WORKFLOW.md                 # Git branching + SemVer.
├── CLAUDE.md                   # AI router.
└── AGENTS.md                   # Cross-tool agent router.
```

## Status

- Version: 11.0.0+1 (baseline from upstream).
- Branch: beta (active). master stable.
- Build: Docker. APK → phone via adb-wifi.

## Rule

Humans AND agents read same files. No separate "AI docs". No duplicate.
