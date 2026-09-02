# Spec — `add-pending-imports-tile` — Requirements

> **What** the user needs, in plain language. No tech choices here.
> Pair with `design.md` (how) and `tasks.md` (work breakdown).

**Status:** approved
**Owner:** cmartinezv
**Module:** dashboard
**Affects users:** yes
**Last updated:** 2026-09-02 — sign-off re-confirmed; design.md
también aprobado en la misma fecha.

## Problem

Today, when Sonarr or Radarr download a file but fail to auto-import it
(quality mismatch, weird filename, missing metadata, custom format
rejection, …), the file sits in the queue with `status = "warning"` or
`"completed"`. The user has to:

1. Open the *arr web UI.
2. Navigate to Activity → Queue.
3. Filter by warnings.
4. Click the manual-import icon.
5. Re-pick the right folder.
6. Confirm the import mode (Move vs Copy-Hardlink).

This is friction. It happens frequently for power users who download from
many indexers. LunaSea's existing Dashboard tile only shows the calendar —
no at-a-glance "things that need my attention".

## Who has it

- Users with Sonarr v3+ and/or Radarr v3+ instances.
- Users whose download workflow hits the import pipeline often (≥1
  manual import per week on average).
- Out of scope: users with Lidarr/Readarr (no module in this fork).

## What success looks like

When the user opens LunaSea's Dashboard, they see a new tile that shows
the count of pending imports per service (Sonarr + Radarr). Tapping it
opens a list of those items; each row has two buttons:

- **Importar ahora** — opens a modal that walks them through the same
  manual-import flow the *arr web UI offers (pick folder, choose mode,
  confirm). The modal calls the *arr API directly, no web view.
- **Abrir en web** — opens the *arr's `/activity/queue` page in the
  device's browser.

## User stories

| As a | I want to | so that |
|------|-----------|---------|
| Sonarr user | see at a glance how many downloads are stuck waiting for manual import | I don't have to open Sonarr to know there's something to do |
| Sonarr user | import a stuck item from inside LunaSea with one tap and a confirmation | I don't have to switch apps |
| Radarr user | use hardlink (Copy-Hardlink) as default because I seed torrents | I don't break my upload ratio by accidentally moving files |
| Sonarr user | see which series/episode the stuck item belongs to | I know if it's worth importing or skipping |
| Sonarr/Radarr user | open the *arr's queue view in my browser | I can do things LunaSea doesn't support yet |

## Acceptance criteria

- [ ] **Given** the Dashboard is open, **when** there are downloads with
      `status ∈ {completed, warning, failed, delay}` in Sonarr or Radarr,
      **then** a new tile shows the count per service and the total.
- [ ] **Given** the Dashboard is open, **when** there are no pending
      imports, **then** the tile shows "Todo limpio" or equivalent.
- [ ] **Given** the user taps a row's "Importar ahora", **when** the
      modal opens, **then** it lists the candidate folders the *arr
      detected in the download path of that item.
- [ ] **Given** the user has chosen a folder, **when** the modal shows
      the import mode selector, **then** it has two options: `Move` and
      `Copy-Hardlink`, with **Copy-Hardlink preseleccionado** by default.
- [ ] **Given** the user confirms, **when** the import completes
      successfully, **then** the modal closes and the row disappears from
      the list (or shows a success state for 3 seconds then disappears).
- [ ] **Given** the user confirms, **when** the import fails, **then** the
      modal shows the error message from the *arr and stays open so the
      user can retry.
- [ ] **Given** the user taps "Abrir en web", **when** the browser opens,
      **then** it goes to `<baseUrl>/activity/queue` of the corresponding
      *arr (Sonarr or Radarr).
- [ ] **Given** the Dashboard has been open for 60 seconds, **when** the
      timer fires, **then** the pending-imports list refreshes
      automatically.
- [ ] **Given** the app is in background, **when** the timer would fire,
      **then** the refresh is paused (no battery drain).
- [ ] **Given** the user pulls down on the tile, **when** the refresh
      gesture completes, **then** the list refreshes immediately.
- [ ] **Given** the API key is invalid or the *arr is offline, **when**
      the tile tries to refresh, **then** it shows an error state with a
      retry button (does not crash, does not block other tiles).
- [ ] **Given** the user has both Sonarr and Radarr enabled, **when**
      both have pending imports, **then** the tile groups them by
      service with a section header per service.

## Out of scope

- Lidarr / Readarr — not installed; no module exists for Lidarr/Readarr
  in this fork.
- Push notifications when a `warning` appears (planned future, separate
  spec, depends on Android 13+ POST_NOTIFICATIONS work).
- Bulk-import of multiple items at once (Premature: each item needs its
  own folder/mode choice; can be revisited if user feedback demands it).
- Editing quality / language / series metadata before import (premature;
  if needed, open in web).
- Configurable default import mode (Copy-Hardlink is hardcoded as the
  default in this spec; configurable is a separate future spec if
  requested).
- Configurable auto-refresh interval (60s hardcoded for now).

## Open questions

None. All questions resolved during planning, see plan maestro
`.hermes/plans/2026-09-01_120124-dashboard-stack-widgets.md`.

## References

- Plan maestro: `.hermes/plans/2026-09-01_120124-dashboard-stack-widgets.md`
- Module doc: `../../modules/dashboard.md`, `../../modules/sonarr.md`,
  `../../modules/radarr.md`
- Sonarr issue #8510: confirms `importMode: "move" | "copy"` API field;
  default in *arr UI is Move (not configurable upstream).
- Sonarr issue #8647: shows example `POST /api/v3/command` body with
  `ManualImport` + `importMode: "auto"` (verifies field exists, even
  if some versions reject "auto").
- Sonarr wiki: https://wiki.servarr.com/sonarr/activity (queue statuses).
- Radarr wiki: https://wiki.servarr.com/radarr/library (manual import).
- Related ADR: none yet; if this spec drives an architectural decision
  (e.g. timer location, state shape), file ADR-0006 after design
  approval.
