import 'package:intl/intl.dart';

class TimeFormatter {
  static String formatTimeOfDay(String timeOfDayString) {
    // Parse "TimeOfDay(14:30)" format
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
