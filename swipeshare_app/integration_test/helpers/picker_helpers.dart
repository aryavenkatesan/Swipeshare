import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

/// Directly invokes the [CupertinoDatePicker]'s onDateTimeChanged callback
/// with [value], bypassing the need to physically scroll the drum roll.
///
/// Only works on iOS/macOS. For Android, pickers fall back to Material dialogs
/// and need platform-conditional interaction logic instead.
void setPickerValue(WidgetTester tester, DateTime value) {
  final picker = tester.widget<CupertinoDatePicker>(
    find.byType(CupertinoDatePicker),
  );
  picker.onDateTimeChanged(value);
}
