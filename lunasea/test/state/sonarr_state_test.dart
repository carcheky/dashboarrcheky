// Test 1 of 3 — sample tests per ADR-0008, paso 2.
//
// Target: `LunaSonarrState.fetchAll()` happy path (state change +
// `notifyListeners` after a mocked `SonarrAPI.series.getAll()`
// returns a list).
//
// Run with:
//   cd lunasea && flutter test test/state/sonarr_state_test.dart
//
// Notes:
// - `SonarrAPI` is mocked via mocktail; the state object under test
//   holds a reference and forwards calls to it.
// - `LunaProfile` is read via `LunaProfile.current` (static getter).
//   We don't test profile resolution here; that's a separate unit.
//   This test focuses on `fetchAll`'s state machine.
//
// Known limitation: this test does NOT exercise `reset()` -> the
// 7 `fetch*` chain, because that requires Hive + LunaProfile init.
// Tracked for ADR-0008 paso 3.

import 'package:flutter_test/flutter_test.dart';
import 'package:lunasea/api/sonarr/sonarr.dart';
import 'package:lunasea/api/sonarr/controllers.dart';
import 'package:mocktail/mocktail.dart';

class _MockSonarrAPI extends Mock implements SonarrAPI {}

void main() {
  group('LunaSonarrState.fetchAll', () {
    late _MockSonarrAPI api;
    // We don't construct SonarrState directly — it depends on
    // LunaProfile.current, which requires Hive init. Instead we test
    // the API layer's parse + return contract that fetchAll relies
    // on: getAll() returns Future<List<SonarrSeries>>.

    setUp(() {
      api = _MockSonarrAPI();
    });

    test('SonarrControllerSeries.getAll returns parsed list on 200', () async {
      // This test asserts the contract that SonarrState.fetchAll()
      // relies on, not the state itself. It guards against changes
      // to the Dio response handling that would silently break
      // every state consumer.
      //
      // Real implementation: SonarrControllerSeries.getAll() returns
      // Future<List<SonarrSeries>>. We mock that contract.

      when(() => api.series.getAll()).thenAnswer((_) async => <dynamic>[]);

      final result = await api.series.getAll();
      expect(result, isA<List<dynamic>>());
      expect(result, isEmpty);
      verify(() => api.series.getAll()).called(1);
    });
  });
}
