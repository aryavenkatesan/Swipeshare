import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/old_components/colors.dart';

/// Utility class for platform-adaptive time picking.
/// Uses Cupertino-style pickers on iOS/macOS, Material-style on Android.
class AdaptiveTimePicker {
  /// Returns true if the current platform should use Cupertino-style pickers.
  static bool get useCupertino => Platform.isIOS || Platform.isMacOS;

  /// In integration tests, set this before tapping the trigger widget.
  /// [showAdaptiveTimePicker] will return this value immediately without
  /// showing any UI, then clear it. Avoids platform-specific picker interaction.
  static TimeOfDay? testTimeOverride;

  /// In integration tests, set this before tapping the trigger widget.
  /// [showAdaptiveDatePicker] will return this value immediately without
  /// showing any UI, then clear it. Avoids platform-specific picker interaction.
  static DateTime? testDateOverride;

  /// Shows a platform-appropriate time picker dialog.
  /// Returns the selected TimeOfDay, or null if cancelled.
  static Future<TimeOfDay?> showAdaptiveTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    TimeOfDay? minTime,
    TimeOfDay? maxTime,
    String? helpText,
    String confirmText = 'Done',
  }) async {
    final clampedInitial = _clampTime(
      initialTime,
      minTime: minTime,
      maxTime: maxTime,
    );
    if (testTimeOverride != null) {
      final value = testTimeOverride;
      testTimeOverride = null;
      return value == null
          ? null
          : _clampTime(value, minTime: minTime, maxTime: maxTime);
    }
    if (useCupertino) {
      return _showCupertinoTimePicker(
        context: context,
        initialTime: clampedInitial,
        minTime: minTime,
        maxTime: maxTime,
        helpText: helpText,
        confirmText: confirmText,
      );
    } else {
      final result = await _showMaterialTimePicker(
        context: context,
        initialTime: clampedInitial,
        helpText: helpText,
      );
      return result == null
          ? null
          : _clampTime(result, minTime: minTime, maxTime: maxTime);
    }
  }

  /// Shows a Cupertino-style time picker in a modal popup
  static Future<TimeOfDay?> _showCupertinoTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    TimeOfDay? minTime,
    TimeOfDay? maxTime,
    String? helpText,
    String confirmText = 'Done',
  }) async {
    TimeOfDay selectedTime = initialTime;
    const refDate = (year: 2023, month: 1, day: 1);

    final minimumDate = minTime == null
        ? null
        : DateTime(
            refDate.year,
            refDate.month,
            refDate.day,
            minTime.hour,
            minTime.minute,
          );
    final maximumDate = maxTime == null
        ? null
        : DateTime(
            refDate.year,
            refDate.month,
            refDate.day,
            maxTime.hour,
            maxTime.minute,
          );

    final helpTextStyle = Theme.of(context).textTheme.labelMedium;

    final result = await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (context) => Container(
        height: helpText != null ? 320 : 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            if (helpText != null)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(helpText, style: helpTextStyle),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                  CupertinoButton(
                    child: Text(confirmText),
                    onPressed: () => Navigator.of(context).pop(selectedTime),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                initialDateTime: DateTime(
                  refDate.year,
                  refDate.month,
                  refDate.day,
                  initialTime.hour,
                  initialTime.minute,
                ),
                onDateTimeChanged: (dateTime) {
                  selectedTime = TimeOfDay(
                    hour: dateTime.hour,
                    minute: dateTime.minute,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  static int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  static TimeOfDay _clampTime(
    TimeOfDay time, {
    TimeOfDay? minTime,
    TimeOfDay? maxTime,
  }) {
    int minutes = _toMinutes(time);
    if (minTime != null) {
      minutes = minutes.clamp(_toMinutes(minTime), 1439);
    }
    if (maxTime != null) {
      minutes = minutes.clamp(0, _toMinutes(maxTime));
    }
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  /// Shows a Material-style time picker dialog with app theming
  static Future<TimeOfDay?> _showMaterialTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    String? helpText,
  }) async {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
      builder: (context, child) {
        return Theme(data: buildMaterialTimePickerTheme(), child: child!);
      },
      barrierColor: const Color.fromARGB(142, 72, 81, 97),
    );
  }

  // ---------------------------------------------------------------------------
  // Date picker
  // ---------------------------------------------------------------------------

  /// Shows a platform-appropriate date picker dialog.
  ///
  /// [initialDate] must be >= [firstDate]. Callers are responsible for
  /// clamping before passing (e.g. use today when the stored date is past).
  /// Returns the selected [DateTime] (time zeroed to midnight), or null if
  /// the user cancelled.
  static Future<DateTime?> showAdaptiveDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    assert(
      !initialDate.isBefore(firstDate),
      'initialDate must be >= firstDate',
    );
    if (testDateOverride != null) {
      final value = testDateOverride;
      testDateOverride = null;
      return value;
    }
    if (useCupertino) {
      return _showCupertinoDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    } else {
      return _showMaterialDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    }
  }

  static Future<DateTime?> _showCupertinoDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    DateTime picked = initialDate;

    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(ctx).pop(null),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(ctx).pop(picked),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate,
                minimumDate: firstDate,
                maximumDate: lastDate,
                onDateTimeChanged: (dt) => picked = dt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<DateTime?> _showMaterialDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  // ---------------------------------------------------------------------------

  /// Builds a Material theme for time pickers that matches the app's design
  static ThemeData buildMaterialTimePickerTheme() {
    return ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: AppColors.accentBlue,
        surface: AppColors.background,
        onSurface: AppColors.primaryText,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accentBlue),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.background,
        hourMinuteTextColor: AppColors.primaryText,
        dayPeriodTextColor: AppColors.primaryText,
        dialHandColor: AppColors.accentBlue,
        dialBackgroundColor: AppColors.accentBlueLight,
        entryModeIconColor: AppColors.accentBlue,
      ),
    );
  }
}
