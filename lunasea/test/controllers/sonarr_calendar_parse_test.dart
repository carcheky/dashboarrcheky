// Test 2 of 3 — sample tests per ADR-0008, paso 2.
//
// Target: Dio response handling for Sonarr calendar. Verifies that
// a calendar JSON array (canned response) can be parsed via
// `SonarrCalendar.fromJson()` without throwing.
//
// Run with:
//   cd lunasea && flutter test test/controllers/sonarr_calendar_parse_test.dart
//
// Notes:
// - Sonarr controllers are top-level `_command*` functions in a
//   `sonarr_commands` library (part of pattern), not classes.
//   Test them via the underlying Dio response handler — same code
//   path, less coupling.
// - ADR-0008 paso 1 will introduce a `SonarrAPI.from(Dio)` seam for
//   better unit testability. Until then, we test the model parse
//   directly, which is what the controller's body does.

import 'package:flutter_test/flutter_test.dart';
import 'package:lunasea/api/sonarr/models.dart';

void main() {
  group('SonarrCalendar.fromJson', () {
    test('parses a minimal calendar record', () {
      final json = <String, dynamic>{
        'id': 1,
        'seriesId': 10,
        'episodeFileId': 100,
        'seasonNumber': 1,
        'episodeNumber': 1,
        'title': 'Pilot',
        'airDateUtc': '2026-09-02T10:00:00Z',
        'hasFile': false,
        'monitored': true,
      };

      final calendar = SonarrCalendar.fromJson(json);

      expect(calendar.id, 1);
      expect(calendar.seriesId, 10);
      expect(calendar.title, 'Pilot');
      expect(calendar.hasFile, isFalse);
      expect(calendar.monitored, isTrue);
    });

    test('parses a calendar record with null episodeFileId', () {
      final json = <String, dynamic>{
        'id': 2,
        'seriesId': 20,
        'episodeFileId': null,
        'seasonNumber': 2,
        'episodeNumber': 5,
        'title': 'Mid-season',
        'airDateUtc': '2026-09-15T10:00:00Z',
        'hasFile': false,
        'monitored': true,
      };

      // Should not throw on null episodeFileId.
      final calendar = SonarrCalendar.fromJson(json);
      expect(calendar.episodeFileId, isNull);
    });
  });
}
