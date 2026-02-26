import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/adaptive/adaptive_time_picker.dart';
import 'package:swipeshare_app/components/listing_form/listing_field_card.dart';

/// A tappable field that opens an adaptive date picker.
///
/// Shows a calendar icon, a "Select a day" label, and the formatted
/// selected date underneath.
class DateSelectorField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onChanged;

  const DateSelectorField({
    super.key,
    required this.selectedDate,
    required this.onChanged,
  });

  String? get _formattedDate {
    if (selectedDate == null) return null;
    final d = selectedDate!;
    return '${d.month}/${d.day}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return ListingFieldCard(
      onTap: () => _pickDate(context),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, size: 24, color: colors.onSurface),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Select a day', style: textTheme.bodyMedium),
                if (_formattedDate != null)
                  Text(_formattedDate!, style: textTheme.bodyLarge),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down, size: 24, color: colors.onSurface),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final stored = selectedDate != null
        ? DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day)
        : today;
    // Clamp to today: Cupertino asserts initialDate >= firstDate.
    final initial = stored.isBefore(today) ? today : stored;

    final result = await AdaptiveTimePicker.showAdaptiveDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
    );

    if (result != null) onChanged(result);
  }
}
