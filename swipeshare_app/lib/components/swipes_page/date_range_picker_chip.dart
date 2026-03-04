import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/swipes_page/filter_chip.dart';

/// A chip that lets the user pick an "Other" date range.
/// When [value] is null it renders as a tappable "Other" text link.
/// When [value] is set it renders as a selected chip showing the date range;
/// tapping it clears the selection.
class DateRangePickerChip extends StatefulWidget {
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?> onChanged;

  const DateRangePickerChip({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<DateRangePickerChip> createState() => _DateRangePickerChipState();
}

class _DateRangePickerChipState extends State<DateRangePickerChip> {
  Future<void> _tap() async {
    if (widget.value != null) {
      widget.onChanged(null);
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
    );

    if (result != null && mounted) widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value != null) {
      final r = widget.value!;
      return SwipesFilterChip(
        label: '${r.start.month}/${r.start.day}–${r.end.month}/${r.end.day}',
        selected: true,
        onTap: _tap,
      );
    }

    return GestureDetector(
      onTap: _tap,
      child: Text(
        'Other',
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: SwipeshareColors.primary),
      ),
    );
  }
}
