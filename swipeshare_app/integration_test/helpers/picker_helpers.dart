import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/adaptive/adaptive_time_picker.dart';

/// Sets the value returned by the next [AdaptiveTimePicker.showAdaptiveTimePicker]
/// call, bypassing all picker UI. Platform-independent.
void setTimePickerValue(TimeOfDay value) {
  AdaptiveTimePicker.testTimeOverride = value;
}

/// Sets the value returned by the next [AdaptiveTimePicker.showAdaptiveDatePicker]
/// call, bypassing all picker UI. Platform-independent.
void setDatePickerValue(DateTime value) {
  AdaptiveTimePicker.testDateOverride = value;
}
