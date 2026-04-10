import 'package:flutter_test/flutter_test.dart';

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
