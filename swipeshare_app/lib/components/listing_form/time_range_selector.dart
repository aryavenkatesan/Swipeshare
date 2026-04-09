import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/listing_form/listing_field_card.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

/// Two side-by-side time pickers for start and end times.
class TimeRangeSelector extends StatefulWidget {
  final TimeOfDay? timeStart;
  final TimeOfDay? timeEnd;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;
  final VoidCallback? onNow;
  final TimeOfDay? minTime;
  final TimeOfDay? maxTime;

  const TimeRangeSelector({
    super.key,
    required this.timeStart,
    required this.timeEnd,
    required this.onStartChanged,
    required this.onEndChanged,
    this.onNow,
    this.minTime,
    this.maxTime,
  });

  @override
  State<TimeRangeSelector> createState() => _TimeRangeSelectorState();
}

class _TimeRangeSelectorState extends State<TimeRangeSelector> {
  bool _nowCollapsed = false;
  bool _nowFaded = false;

  static int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay _clamp(TimeOfDay t) {
    int mins = _toMinutes(t);
    if (widget.minTime != null) mins = mins.clamp(_toMinutes(widget.minTime!), 1439);
    if (widget.maxTime != null) mins = mins.clamp(0, _toMinutes(widget.maxTime!));
    return TimeOfDay(hour: mins ~/ 60, minute: mins % 60);
  }

  bool get _hasRangeError =>
      widget.timeStart != null &&
      widget.timeEnd != null &&
      _toMinutes(widget.timeStart!) >= _toMinutes(widget.timeEnd!);

  TimeOfDay _initialEndTime() {
    if (widget.timeStart == null) return widget.timeEnd ?? const TimeOfDay(hour: 17, minute: 0);
    if (widget.timeEnd != null && _toMinutes(widget.timeEnd!) > _toMinutes(widget.timeStart!)) return widget.timeEnd!;
    return widget.timeStart!;
  }

  bool get _shouldShowNow =>
      widget.onNow != null &&
      widget.timeStart == null &&
      widget.timeEnd == null;

  @override
  void didUpdateWidget(TimeRangeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasShowing = oldWidget.onNow != null &&
        oldWidget.timeStart == null &&
        oldWidget.timeEnd == null;
    if (wasShowing && !_shouldShowNow && !_nowCollapsed) {
      // Fade out first, then collapse.
      setState(() => _nowFaded = true);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _nowCollapsed = true);
      });
    } else if (_shouldShowNow && _nowCollapsed) {
      setState(() {
        _nowCollapsed = false;
        _nowFaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rangeError = _hasRangeError;
    final showNow = !_nowCollapsed && widget.onNow != null;

    return Row(
      children: [
        Expanded(
          child: _TimeTile(
            label: 'Start at',
            time: widget.timeStart,
            onTap: () => _pick(
              context,
              widget.timeStart ?? const TimeOfDay(hour: 9, minute: 0),
              widget.onStartChanged,
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: showNow
              ? GestureDetector(
                  onTap: widget.onNow,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AnimatedOpacity(
                      opacity: _nowFaded ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Text(
                        'now',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: 12),
        ),
        Expanded(
          child: _TimeTile(
            label: 'End at',
            time: widget.timeEnd,
            hasError: rangeError,
            onTap: () => _pick(
              context,
              _initialEndTime(),
              widget.onEndChanged,
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
    final clampedInitial = _clamp(initial);
    TimeOfDay? result;
    if (Platform.isIOS || Platform.isMacOS) {
      result = await _showCupertinoTimePicker(context, clampedInitial);
    } else {
      result = await showTimePicker(context: context, initialTime: clampedInitial);
    }
    if (result != null) onChanged(_clamp(result));
  }

  Future<TimeOfDay?> _showCupertinoTimePicker(
    BuildContext context,
    TimeOfDay initial,
  ) async {
    TimeOfDay picked = initial;
    const refDate = (year: 2000, month: 1, day: 1);

    final minDt = widget.minTime != null
        ? DateTime(refDate.year, refDate.month, refDate.day, widget.minTime!.hour, widget.minTime!.minute)
        : null;
    final maxDt = widget.maxTime != null
        ? DateTime(refDate.year, refDate.month, refDate.day, widget.maxTime!.hour, widget.maxTime!.minute)
        : null;

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
                minimumDate: minDt,
                maximumDate: maxDt,
                initialDateTime: DateTime(
                  refDate.year,
                  refDate.month,
                  refDate.day,
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
  final bool hasError;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final iconColor = hasError ? colors.error : colors.onSurface;

    return ListingFieldCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.access_time, size: 24, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: hasError ? colors.error : null),
                ),
                if (time != null)
                  Text(
                    TimeFormatter.formatTOD(time!),
                    style: textTheme.bodyLarge
                        ?.copyWith(color: hasError ? colors.error : null),
                  ),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down, size: 24, color: iconColor),
        ],
      ),
    );
  }
}
