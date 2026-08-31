# SABnzbd module

Integration with [SABnzbd](https://sabnzbd.org/) — Usenet downloader.

- Path: `lib/modules/sabnzbd/`
- Barrel: `lib/modules/sabnzbd.dart`
- API: `SABnzbdAPI`
- State: `SABnzbdState`

## Notable

- Uses the legacy JSON API (`/api?mode=...&output=json`) wrapped in Retrofit.
- Auth is API key in query string, not header.
- Speed/queue state is polled on a timer (no push notifications).
