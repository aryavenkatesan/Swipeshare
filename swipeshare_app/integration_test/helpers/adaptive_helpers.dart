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

/// Enters [text] into the text field and taps submit in the currently shown
/// [AdaptiveDialog.showTextInput]. Works for both Material and Cupertino variants.
Future<void> submitAdaptiveTextInput(
  WidgetTester tester,
  String text, {
  String submitText = 'Submit',
}) async {
  // Both TextField (Material) and CupertinoTextField wrap an EditableText.
  // Using .last picks the dialog's field over any fields obscured behind it.
  await tester.enterText(find.byType(EditableText).last, text);
  await tester.tap(find.text(submitText));
  await tester.pumpAndSettle();
}

/// Taps the cancel button of the currently shown [AdaptiveDialog.showTextInput].
Future<void> cancelAdaptiveTextInput(
  WidgetTester tester, {
  String cancelText = 'Cancel',
}) async {
  await tester.tap(find.text(cancelText));
  await tester.pumpAndSettle();
}
