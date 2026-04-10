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
