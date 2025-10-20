import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeFormatter {
  static TimeOfDay parseTimeOfDayString(String timeOfDayString) {
    // Parse "TimeOfDay(14:30)" format to TimeOfDay object
    final timeString = timeOfDayString
        .replaceAll('TimeOfDay(', '')
        .replaceAll(')', '')
        .trim();

    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }

  static String formatTimeOfDay(String timeOfDayString) {
    // Parse "TimeOfDay(14:30)" format to h:mm a
    final timeString = timeOfDayString
        .replaceAll('TimeOfDay(', '')
        .replaceAll(')', '');
    final parts = timeString.split(':');

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, hour, minute);
    return DateFormat('h:mm a').format(dateTime);
  }
}
