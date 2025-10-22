import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';

class SellValidationComponent extends StatelessWidget {
  final List<String> selectedLocations;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int swipeCount;
  final List<String> selectedPaymentOptions;

  const SellValidationComponent({
    super.key,
    required this.selectedLocations,
    required this.startTime,
    required this.endTime,
    required this.swipeCount,
    required this.selectedPaymentOptions,
  });

  @override
  Widget build(BuildContext context) {
    // Check for various validation conditions
    if (selectedLocations.isEmpty) {
      return _buildMessage('Please select a dining hall');
    }

    if (startTime == null || endTime == null) {
      return _buildMessage('Please select start and end times');
    }

    if (_isEndTimeBeforeStartTime()) {
      return _buildMessage('End time cannot be before start time');
    }

    if (swipeCount <= 0) {
      return _buildMessage('Please select at least 1 swipe to sell');
    }

    if (selectedPaymentOptions.isEmpty) {
      return _buildMessage('Please select at least one payment method');
    }

    // All validations passed
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: Column(
          children: [
            Text(
              'Ready to post!',
              style: AppTextStyles.successText.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Selling $swipeCount swipe${swipeCount > 1 ? 's' : ''} • ${_formatTimeOfDay(startTime!)} to ${_formatTimeOfDay(endTime!)}',
              style: AppTextStyles.validationText.copyWith(
                color: AppColors.subText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.validationText,
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'am' : 'pm';
    return '$hour:$minute $period';
  }

  bool _isEndTimeBeforeStartTime() {
    if (startTime == null || endTime == null) return false;

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;

    return endMinutes <= startMinutes;
  }
}
