// Test 3 of 3 — sample tests per ADR-0008, paso 2.
//
// Target: a primitive widget test for `LunaBlock`. Verifies that the
// title renders, and that an empty-state placeholder renders when no
// poster/title/body are provided.
//
// Run with:
//   cd lunasea && flutter test test/widget/luna_block_test.dart
//
// Strategy: pumpWidget under a Directionality + MaterialApp; query
// the tree by Text. No golden in this sample — golden comes in
// paso 4 of ADR-0008.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunasea/widgets/ui/block.dart';

void main() {
  group('LunaBlock', () {
    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LunaBlock(
              title: 'Hello',
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('does not throw on empty state', (tester) async {
      // No title, no body, no leading — should still render a
      // SizedBox-like container without crashing.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LunaBlock(),
          ),
        ),
      );

      // No assertion on specific widgets; the test passes if no
      // exception is thrown during pumpWidget.
      expect(tester.takeException(), isNull);
    });
  });
}
