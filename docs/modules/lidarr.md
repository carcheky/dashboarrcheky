# Lidarr module

Integration with [Lidarr](https://lidarr.audio/) — music management.

Same structure as Sonarr/Radarr. See [sonarr.md](sonarr.md) for the general
pattern.

- Path: `lib/modules/lidarr/`
- Barrel: `lib/modules/lidarr.dart`
- API: `LidarrAPI` (Retrofit)
- State: `LidarrState`

## Notable differences

- Has `artist` (top level) → `album` → `track`.
- Track files live under albums, not directly under artists.
- Has its own metadata profile + quality profile.
