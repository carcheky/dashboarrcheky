# Roadmap

> Prioritised list of future work. Ordered by horizon (Now → Next → Later),
> ties broken by dependency. Each item references the per-feature spec file
> (status: `proposed`) per ADR-0005. Time horizons are advisory, not
> commitments — they only encode intended order.

## How to read this

| Symbol | Meaning |
|--------|---------|
| `[ ]` | not started |
| `[~]` | spec drafted, awaiting approval |
| `[x]` | merged |

Status field comes from the linked `docs/features/<slug>.md`.

## Now — short horizon

What's blocking daily use on Pixel 9 / Android 17.

| # | Item | Effort | Depends on | Spec |
|---|------|--------|------------|------|
| 1 | 16 KB page-size Phase 1 (compressed packaging, 5-line Gradle edit) | XS | — | ADR-0004 § Phase 1 |
| 2 | Verify back-button 4-row behaviour matrix on device | XS | phone unlocked | `docs/fixes/android-predictive-back.md` § Test |
| 3 | Validate Overseerr key in `modules.dart` against current Overseerr API (still 1.x?). Decide: rename to `seerr`, keep `overseerr`, or split. | S | research | (proposed) — see "Services" section |

## Next — medium horizon

New module work. Each is its own branch + spec + fix/feature doc.

| # | Item | Effort | Depends on | Spec |
|---|------|--------|------------|------|
| 4 | **Seerr module** — replace Overseerr/Jellyseerr stub with the unified Seerr API (Plex + Jellyfin + Emby). Includes request workflow UI, discovery, integrations with Sonarr/Radarr. | L | 1 (debug APK must install) | `docs/features/seerr.md` (proposed) |
| 5 | **Jellyfin module** — sessions, libraries, now-playing, user management, server dashboard. Exposes data Seerr reads to gate requests. | L | 4 (shared types) | `docs/features/jellyfin.md` (proposed) |
| 6 | **qBittorrent module** — torrent list, add/remove/pause/resume, alternative-speed-limits, per-torrent and global rate limits. Cookie-based auth (no API key). | M | — | `docs/features/qbittorrent.md` (proposed) |
| 7 | **Bazarr module** — wanted/missing subtitles per series/movie, manual search, language profile filter, sync status. Pairs with existing Sonarr/Radarr modules. | M | — | `docs/features/bazarr.md` (proposed) |

## Later — long horizon

| # | Item | Effort | Depends on | Spec |
|---|------|--------|------------|------|
| 8 | **4K / HDR quality profile awareness** — unified quality-profile field across Sonarr/Radarr, surfaces 4K/HDR/Atmos flags, "auto-pick best for my display" toggle. | L | 4, 5 | `docs/features/4k-quality-profiles.md` (proposed) |
| 9 | 16 KB page-size Phase 2 (AGP 8.1→8.7, Gradle 8.0→8.10, Kotlin 1.8→1.9.22, NDK r28) | L | 1 (validate Phase 1 works) | ADR-0004 § Phase 2 |
| 10 | Test infrastructure (`lunasea/test/`, `flutter_test` in `pubspec.yaml`, CI workflow). Today: zero tests. | M | 9 | (no spec yet — start with `docs/features/test-infra.md` when picked) |
| 11 | Signing-key unification — same release keystore for debug and release so cross-package data import becomes possible. Resolves the export/import bug we hit on day 1. | M | — | (no spec yet) |
| 12 | Hive schema v2 — migration framework + audits. | M | 10 | (no spec yet) |

## Services coverage — what's already there

| Service | Module | Notes |
|---------|--------|-------|
| Sonarr | `lib/modules/sonarr/` | full module, v3/v4 aware |
| Radarr | `lib/modules/radarr/` | full module |
| Lidarr | `lib/modules/lidarr/` | full module |
| SABnzbd | `lib/modules/sabnzbd/` | full module |
| NZBGet | `lib/modules/nzbget/` | full module |
| Tautulli | `lib/modules/tautulli/` | full module, Plex stats |
| Overseerr | stub in `modules.dart` | no module folder, no API client |
| Search | `lib/modules/search/` | cross-service indexer search |
| Settings | `lib/modules/settings/` | profiles, configuration |
| Dashboard | `lib/modules/dashboard/` | home screen |
| External modules | `lib/modules/external_modules/` | placeholder for one-off services |

## Services — what's missing (future)

| Service | Why it matters | Spec |
|---------|----------------|------|
| Seerr (Overseerr+Jellyseerr merge) | modern request workflow for Plex/Jellyfin/Emby | `docs/features/seerr.md` |
| Jellyfin | sessions + library data + is the user-asked-for server backend | `docs/features/jellyfin.md` |
| Bazarr | subtitles (no service does this today) | `docs/features/bazarr.md` |
| qBittorrent | the *arr stacks usually pair *arr with a torrent client; today only usenet | `docs/features/qbittorrent.md` |
| 4K / HDR profile awareness | today you juggle quality profiles per service | `docs/features/4k-quality-profiles.md` |

## How to use this

When you pick the next item:

1. Copy `docs/features/TEMPLATE` → `docs/features/<slug>.md`. Fill `requirements.md` first per `spec-driven-feature` skill.
2. Open branch `feature/<slug>` or `fix/<slug>` per `WORKFLOW.md`.
3. Sub-agent (or human) executes; commit footer carries `Docs:` line.
4. Merge to beta per ADR-0002.
6. The new feature moves from `proposed` → `shipped`, gets a row in `docs/timeline.md`.

## See also

- `docs/timeline.md` — chronological history + present + future
- `docs/specs/TEMPLATE/` — requirements / design / tasks
- `.agents/skills/spec-driven-feature/SKILL.md` — workflow
- ADR-0005 — why specs exist
- ADR-0004 — 16 KB page-size plan
- `docs/architecture.md` — current modules + layers