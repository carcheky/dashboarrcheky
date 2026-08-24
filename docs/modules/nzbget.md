# NZBGet module

Integration with [NZBGet](https://nzbget.net/) — Usenet downloader.

- Path: `lib/modules/nzbget/`
- Barrel: `lib/modules/nzbget.dart`
- API: `NZBGetAPI` (JSON-RPC over HTTP)
- State: `NZBGetState`

## Notable

- Uses JSON-RPC (`/jsonrpc`); not Retrofit-friendly. Calls are hand-rolled
  with `dio` rather than generated code.
- Has pause/resume groups separate from individual downloads.
