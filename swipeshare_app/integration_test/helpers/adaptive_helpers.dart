import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Finds a text input field regardless of platform.
/// iOS uses [CupertinoTextField]; Android uses [TextField].
Finder findTextField() => find.byWidgetPredicate(
      (w) => w is TextField || w is CupertinoTextField,
    );

/// Taps the "Done" button that dismisses a Cupertino picker on iOS.
/// On Android, pickers are Material dialogs with different dismiss patterns.
Future<void> tapPickerDone(WidgetTester tester) async {
  await tester.tap(find.text('Done'));
}

/// Polls until [text] appears in the widget tree, then asserts it exists.
///
/// Use this instead of a bare [expect] after any Firestore write whose result
/// arrives via a stream — [pumpAndSettle] only drains the Dart event loop and
/// does not wait for the emulator round-trip.
Future<void> waitForText(
  WidgetTester tester,
  String text, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 300),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (find.text(text).evaluate().isNotEmpty) break;
    await tester.pump(interval);
  }
  expect(find.text(text), findsOneWidget);
}
