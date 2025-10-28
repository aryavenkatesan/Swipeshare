import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';

class TimePickerComponent extends StatefulWidget {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final Function(TimeOfDay) onStartTimeChanged;
  final Function(TimeOfDay) onEndTimeChanged;

  const TimePickerComponent({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  State<TimePickerComponent> createState() => _TimePickerComponentState();
}

class _TimePickerComponentState extends State<TimePickerComponent> {
  bool showStartPicker = false;
  bool showEndPicker = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.whiteTransparent,
        borderRadius: BorderRadius.circular(BuySwipesConstants.borderRadius),
        border: Border.all(color: AppColors.borderGrey, width: 2),
      ),
      child: Column(
        children: [
          _buildTimeSelectionContainer(),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: (showStartPicker || showEndPicker)
                ? _buildTimePickers()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Builds the time selection container with start and end time selectors
  Widget _buildTimeSelectionContainer() {
    return Container(
      width: double.infinity,
      padding: BuySwipesConstants.containerPadding,
      child: Stack(
        children: [
          if (showStartPicker || showEndPicker) _buildTimeIndicator(),
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector(
                  "Start at",
                  widget.startTime,
                  () => _setPickerState(start: true),
                  isHighlighted: showStartPicker,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _setTimesToNow,
                child: Text("Now", style: AppTextStyles.subText),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTimeSelector(
                  "End at",
                  widget.endTime,
                  () => _setPickerState(end: true),
                  isHighlighted: showEndPicker,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the animated sliding indicator for active time picker
  Widget _buildTimeIndicator() {
    final double vw = MediaQuery.of(context).size.width;

    const double minWidth = 375.0;
    const double maxWidth = 430.0;
    const double minMultiplier = 0.25;
    const double maxMultiplier = 0.28;

    // Calculate slope
    final slope = (maxMultiplier - minMultiplier) / (maxWidth - minWidth);

    // Linear function: y = mx + b
    final multiplier = minMultiplier + slope * (vw - minWidth);

    return AnimatedAlign(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      alignment: showStartPicker ? Alignment.centerLeft : Alignment.centerRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        width: vw * multiplier,
        height: 48,
        margin: EdgeInsets.only(
          left: showStartPicker ? 8 : 0,
          right: showEndPicker ? 8 : 0,
        ),
        decoration: BoxDecoration(
          color: AppColors.accentBlueIndicator,
          borderRadius: BorderRadius.circular(BuySwipesConstants.smallSpacing),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the stacked time pickers for start and end time selection
  Widget _buildTimePickers() {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          const Divider(height: 1, color: AppColors.borderGrey),
          Expanded(
            child: Stack(
              children: [
                AnimatedOpacity(
                  opacity: showStartPicker ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _buildTimePicker(
                    isVisible: showStartPicker,
                    time: widget.startTime,
                    defaultHour: 9,
                    onTimeChanged: widget.onStartTimeChanged,
                  ),
                ),
                AnimatedOpacity(
                  opacity: showEndPicker ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _buildTimePicker(
                    isVisible: showEndPicker,
                    time: widget.endTime,
                    defaultHour: 17,
                    onTimeChanged: widget.onEndTimeChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an individual time picker with animation
  Widget _buildTimePicker({
    required bool isVisible,
    required TimeOfDay? time,
    required int defaultHour,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return Visibility(
      visible: isVisible,
      child: SizedBox(
        width: double.infinity,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: false,
          minuteInterval: 5,
          initialDateTime: DateTime(
            2023,
            1,
            1,
            time?.hour ?? defaultHour,
            time?.minute ?? 0,
          ),
          onDateTimeChanged: (DateTime dateTime) {
            onTimeChanged(
              TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
            );
          },
        ),
      ),
    );
  }

  /// Builds an individual time selector with label and time display
  Widget _buildTimeSelector(
    String label,
    TimeOfDay? time,
    VoidCallback onTap, {
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BuySwipesConstants.smallSpacing),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: AppTextStyles.timeLabelText),
            const SizedBox(height: 2),
            Text(
              time?.format(context) ?? '--:--',
              style: AppTextStyles.timeValueText,
            ),
          ],
        ),
      ),
    );
  }

  /// Sets the active time picker state
  void _setPickerState({bool start = false, bool end = false}) {
    setState(() {
      // If tapping the same picker that's already open, close it
      if ((start && showStartPicker) || (end && showEndPicker)) {
        showStartPicker = false;
        showEndPicker = false;
      } else {
        showStartPicker = start;
        showEndPicker = end;
      }
    });
  }

  /// Sets start time to one minute from now and end time to 30 minutes after start time
  void _setTimesToNow() {
    final now = DateTime.now();
    final oneMinuteFromNow = now.add(const Duration(minutes: 1));

    // Round to nearest 5-minute interval
    final roundedMinute = ((oneMinuteFromNow.minute / 5).round() * 5) % 60;
    final hourAdjustment = (oneMinuteFromNow.minute + 5) >= 60 ? 1 : 0;

    final startTime = TimeOfDay(
      hour: (oneMinuteFromNow.hour + hourAdjustment) % 24,
      minute: roundedMinute,
    );

    // Add 30 minutes to the rounded start time
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );
    final thirtyMinutesAfterStart = startDateTime.add(
      const Duration(minutes: 30),
    );

    final endTime = TimeOfDay(
      hour: thirtyMinutesAfterStart.hour,
      minute: thirtyMinutesAfterStart.minute,
    );

    widget.onStartTimeChanged(startTime);
    widget.onEndTimeChanged(endTime);

    // Close any open pickers
    setState(() {
      showStartPicker = false;
      showEndPicker = false;
    });
  }
}
