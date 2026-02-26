import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/listing_form/listing_field_card.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

/// Two side-by-side time pickers for start and end times.
class TimeRangeSelector extends StatelessWidget {
  final TimeOfDay? timeStart;
  final TimeOfDay? timeEnd;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;

  const TimeRangeSelector({
    super.key,
    required this.timeStart,
    required this.timeEnd,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeTile(
            label: 'Start at',
            time: timeStart,
            onTap: () => _pick(
              context,
              timeStart ?? const TimeOfDay(hour: 9, minute: 0),
              onStartChanged,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TimeTile(
            label: 'End at',
            time: timeEnd,
            onTap: () => _pick(
              context,
              timeEnd ?? const TimeOfDay(hour: 17, minute: 0),
              onEndChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(
    BuildContext context,
    TimeOfDay initial,
    ValueChanged<TimeOfDay> onChanged,
  ) async {
    TimeOfDay? result;
    if (Platform.isIOS || Platform.isMacOS) {
      result = await _showCupertinoTimePicker(context, initial);
    } else {
      result = await showTimePicker(context: context, initialTime: initial);
    }
    if (result != null) onChanged(result);
  }

  Future<TimeOfDay?> _showCupertinoTimePicker(
    BuildContext context,
    TimeOfDay initial,
  ) async {
    TimeOfDay picked = initial;

    return showCupertinoModalPopup<TimeOfDay>(
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
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false,
                initialDateTime: DateTime(
                  2000,
                  1,
                  1,
                  initial.hour,
                  initial.minute,
                ),
                onDateTimeChanged: (dt) {
                  picked = TimeOfDay(hour: dt.hour, minute: dt.minute);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return ListingFieldCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.access_time, size: 24, color: colors.onSurface),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: textTheme.bodyMedium),
                if (time != null)
                  Text(
                    TimeFormatter.formatTOD(time!),
                    style: textTheme.bodyLarge,
                  ),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down, size: 24, color: colors.onSurface),
        ],
      ),
    );
  }
}
