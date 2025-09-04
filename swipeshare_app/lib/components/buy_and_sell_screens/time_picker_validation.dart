import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';

class TimePickerValidationComponent extends StatelessWidget {
  final List<String> selectedLocations;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  const TimePickerValidationComponent({
    super.key,
    required this.selectedLocations,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedLocations.isEmpty) {
      return _buildMessage('Please select a location first');
    }
    
    if (startTime == null || endTime == null) {
      return _buildMessage('No time selected, pick a start and end time');
    }
    
    if (_isEndTimeBeforeStartTime()) {
      return _buildMessage('End time cannot be before start time');
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: BuySwipesConstants.smallSpacing),
      child: Center(
        child: Text(
          'Available ${_formatTimeOfDay(startTime!)} to ${_formatTimeOfDay(endTime!)}',
          style: AppTextStyles.successText,
        ),
      ),
    );
  }

  /// Builds a centered validation message
  Widget _buildMessage(String message) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.validationText,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Formats TimeOfDay to 12-hour format string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'am' : 'pm';
    return '$hour:$minute $period';
  }

  /// Validates if end time is before start time
  bool _isEndTimeBeforeStartTime() {
    if (startTime == null || endTime == null) return false;
    
    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;
    
    return endMinutes <= startMinutes;
  }
}
