# Modules

> One section per self-hosted service. Same shape each.

## Map

| Module | Service | Path |
|--------|---------|------|
| [dashboard](dashboard.md) | Home + recent activity | `lib/modules/dashboard/` |
| [sonarr](sonarr.md) | Series manager | `lib/modules/sonarr/` |
| [radarr](radarr.md) | Movie manager | `lib/modules/radarr/` |
| [lidarr](lidarr.md) | Music manager | `lib/modules/lidarr/` |
| [sabnzbd](sabnzbd.md) | Usenet downloader | `lib/modules/sabnzbd/` |
| [nzbget](nzbget.md) | Usenet downloader (alt) | `lib/modules/nzbget/` |
| [tautulli](tautulli.md) | Plex stats | `lib/modules/tautulli/` |
| [search](search.md) | Cross-service search | `lib/modules/search/` |
| [settings](settings.md) | Global config | `lib/modules/settings/` |

## Per-module shape

Each module doc covers:

1. **Purpose** — what service, what user does.
2. **API surface** — endpoints consumed, auth, headers.
3. **Local state** — Hive boxes, keys, schema version.
4. **Routes** — screens, deep links.
5. **Known issues** — broken behavior, workarounds.
6. **Recent features / fixes** — link to `../features/` and `../fixes/`.

## Adding a feature to a module

1. Create `feature/<slug>` branch.
2. Edit code under `lib/modules/<name>/`.
3. Create `docs/features/<slug>.md` (template in `../features/TEMPLATE.md`).
4. Update this module's `docs/modules/<name>.md` if shape changed (new routes, new Hive fields, etc).
5. Conventional Commit with `Docs:` footer pointing to the new doc.
6. PR → merge to master → cherry-pick to beta.

## Adding a new module

1. Create `lib/modules/<name>/` mirroring existing layout.
2. Create `docs/modules/<name>.md`.
3. Add nav entry in `mkdocs.yml`.
4. Wire into dashboard / search.
5. ADR if architectural decision involved.
