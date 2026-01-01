import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class DateSelectorComponent extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelectorComponent({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _buildDatePills(),
      ),
    );
  }

  /// Generates list of date pill widgets for the next 7 days
  List<Widget> _buildDatePills() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = today.add(Duration(days: i));
      final isSelected = _isSameDate(date, selectedDate);
      final label = _getDateLabel(i, date);

      return Padding(
        padding: const EdgeInsets.only(right: BuySwipesConstants.mediumSpacing),
        child: GestureDetector(
          onTap: () async {
            await safeVibrate(HapticsType.selection);
            onDateSelected(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BuySwipesConstants.mediumSpacing,
              vertical: BuySwipesConstants.smallSpacing,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentBlueMedium
                  : AppColors.whiteTransparent,
              borderRadius: BorderRadius.circular(
                BuySwipesConstants.borderRadius,
              ),
              border: Border.all(
                color: isSelected ? AppColors.accentBlue : AppColors.borderGrey,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(label, style: AppTextStyles.datePillText),
            ),
          ),
        ),
      );
    });
  }

  /// Checks if two DateTime objects represent the same date
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }

  /// Returns formatted label for date pill based on day index
  String _getDateLabel(int dayIndex, DateTime date) {
    switch (dayIndex) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      default:
        return '${date.month}/${date.day}';
    }
  }
}
