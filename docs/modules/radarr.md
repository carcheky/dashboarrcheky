# Radarr module

Integration with [Radarr](https://radarr.video/) — movie management.

Same structure as Sonarr. See [sonarr.md](sonarr.md) for the general pattern.

- Path: `lib/modules/radarr/`
- Barrel: `lib/modules/radarr.dart`
- API: `RadarrAPI` (Retrofit)
- State: `RadarrState`

## Notable differences from Sonarr

- Has a `movie` concept instead of `series`.
- Has `qualityProfile` directly on movies (vs. per-series in Sonarr).
- Cutoff/unmonitored flags live on `Movie`, not `Episode`.
