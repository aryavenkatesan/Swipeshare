import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/buy_swipes_style_ideas.dart';
import 'package:swipeshare_app/pages/listing_selection_page.dart';

class BuySwipeScreen extends StatefulWidget {
  const BuySwipeScreen({super.key});

  @override
  State<BuySwipeScreen> createState() => _BuySwipeScreenState();
}

class _BuySwipeScreenState extends State<BuySwipeScreen> {
  List<String> selectedLocations = [];
  DateTime selectedDate = DateTime.now();
  bool showStartPicker = false;
  bool showEndPicker = false;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuySwipesCurrentStyle.backgroundColor,
      body: BuySwipesCurrentStyle.wrapWithContainer(
        context: context,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 100,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildLocationSelector(),
                  const SizedBox(height: 20),
                  _buildDatePillSelector(),
                  const SizedBox(height: 24),
                  _buildTimeSelectionContainer(),
                  _buildTimePickers(),
                  const SizedBox(height: 12),
                  _buildTimeValidationMessage(),
                  const Spacer(),
                  Center(child: _buildFindSellerButton()),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header with back button, title, and subtitle
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + 16),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Find a Swipe',
                  style: BuySwipesCurrentStyle.getTitleStyle(context),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select a dining hall, date, and time to find available swipes',
          style: BuySwipesCurrentStyle.bodyTextStyle(context),
        ),
      ],
    );
  }

  /// Builds the location selector for dining halls
  Widget _buildLocationSelector() {
    return Row(
      children: BuySwipesCurrentStyle.locations.map((location) {
        final isSelected = selectedLocations.contains(location);
        return Expanded(
          child: GestureDetector(
            onTap: () => _toggleLocationSelection(location),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BuySwipesCurrentStyle.getLocationDecoration(
                context, 
                isSelected: isSelected,
              ),
              child: Center(
                child: Text(
                  location,
                  style: BuySwipesCurrentStyle.getLocationTextStyle(
                    context, 
                    isSelected: isSelected,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds the horizontal scrollable date selector
  Widget _buildDatePillSelector() {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _buildDatePills(),
      ),
    );
  }

  /// Builds the time selection container with start and end time selectors
  Widget _buildTimeSelectionContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BuySwipesCurrentStyle.getTimeContainerDecoration(context),
      child: Stack(
        children: [
          if (showStartPicker || showEndPicker) _buildTimeIndicator(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: _buildTimeSelector(
                  "Start at", 
                  startTime, 
                  () => _setPickerState(start: true), 
                  isHighlighted: showStartPicker,
                ),
              ),
              Flexible(
                child: _buildTimeSelector(
                  "End at", 
                  endTime, 
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
    return AnimatedAlign(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: showStartPicker 
          ? Alignment.centerLeft 
          : Alignment.centerRight,
      child: Container(
        width: BuySwipesCurrentStyle.getTimeSelectorWidth(context),
        height: 48,
        margin: showStartPicker
            ? EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02)
            : EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
        decoration: BoxDecoration(
          color: BuySwipesCurrentStyle.timeIndicatorColor,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Builds the stacked time pickers for start and end time selection
  Widget _buildTimePickers() {
    return Stack(
      children: [
        _buildTimePicker(
          isVisible: showStartPicker,
          time: startTime,
          defaultHour: 9,
          onTimeChanged: (time) => setState(() => startTime = time),
        ),
        _buildTimePicker(
          isVisible: showEndPicker,
          time: endTime,
          defaultHour: 17,
          onTimeChanged: (time) => setState(() => endTime = time),
        ),
      ],
    );
  }

  /// Builds an individual time picker with animation
  Widget _buildTimePicker({
    required bool isVisible,
    required TimeOfDay? time,
    required int defaultHour,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: Visibility(
        visible: isVisible,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: Container(
          height: 200,
          margin: const EdgeInsets.only(top: 12),
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            use24hFormat: false,
            minuteInterval: 5,
            initialDateTime: DateTime(
              2023, 1, 1, 
              time?.hour ?? defaultHour, 
              time?.minute ?? 0,
            ),
            onDateTimeChanged: (DateTime dateTime) {
              onTimeChanged(TimeOfDay(
                hour: dateTime.hour,
                minute: dateTime.minute,
              ));
            },
          ),
        ),
      ),
    );
  }

  /// Builds validation messages and available time display
  Widget _buildTimeValidationMessage() {
    if (selectedLocations.isEmpty) {
      return _buildCenteredMessage('⚠️ Please select a location first ⚠️');
    }
    
    if (startTime == null || endTime == null) {
      return _buildCenteredMessage('⚠️ No Time Selected, pick a start and end time ⚠️');
    }
    
    if (_isEndTimeBeforeStartTime()) {
      return _buildCenteredMessage('⚠️ End time cannot be before start time ⚠️');
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: Text(
          'Available ${_formatTimeOfDay(startTime!)} to ${_formatTimeOfDay(endTime!)}',
          style: BuySwipesCurrentStyle.bodyTextStyle(context, baseFontSize: 16),
        ),
      ),
    );
  }

  /// Builds a centered validation message
  Widget _buildCenteredMessage(String message) {
    return Center(
      child: Text(
        message,
        style: BuySwipesCurrentStyle.bodyTextStyle(context, baseFontSize: 14),
      ),
    );
  }

  /// Builds the find seller button with proper styling and state
  Widget _buildFindSellerButton() {
    return ElevatedButton(
      onPressed: _canProceedToNextScreen() ? _navigateToListingSelection : null,
      style: BuySwipesCurrentStyle.getFindSellerButtonStyle(context),
      child: Text(
        "Find Swipe Seller",
        style: BuySwipesCurrentStyle.getFindSellerButtonTextStyle(context),
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
        width: BuySwipesCurrentStyle.getTimeSelectorWidth(context),
        height: 48,
        margin: BuySwipesCurrentStyle.getTimeSelectorMargin(context),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label, 
              style: BuySwipesCurrentStyle.bodyTextStyle(context, baseFontSize: 14).copyWith(
                color: BuySwipesCurrentStyle.getTimePickerTextColor(isHighlighted: isHighlighted),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time?.format(context) ?? '--:--',
              style: BuySwipesCurrentStyle.bodyTextStyle(context, baseFontSize: 16).copyWith(
                color: BuySwipesCurrentStyle.getTimePickerTextColor(isHighlighted: isHighlighted),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: () => setState(() => selectedDate = date),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BuySwipesCurrentStyle.getDatePillDecoration(
              context, 
              isSelected: isSelected,
            ),
            child: Text(
              label,
              style: BuySwipesCurrentStyle.getDatePillTextStyle(context),
            ),
          ),
        ),
      );
    });
  }

  /// Toggles location selection (add/remove from selected list)
  void _toggleLocationSelection(String location) {
    setState(() {
      selectedLocations.contains(location)
          ? selectedLocations.remove(location)
          : selectedLocations.add(location);
    });
  }

  /// Sets the active time picker state
  void _setPickerState({bool start = false, bool end = false}) {
    setState(() {
      showStartPicker = start;
      showEndPicker = end;
    });
  }

  /// Validates if user can proceed to next screen
  bool _canProceedToNextScreen() {
    return startTime != null && 
           endTime != null && 
           selectedLocations.isNotEmpty &&
           !_isEndTimeBeforeStartTime();
  }

  /// Navigates to listing selection page with current selections
  void _navigateToListingSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingSelectionPage(
          locations: selectedLocations,
          date: selectedDate,
          startTime: startTime!,
          endTime: endTime!,
        ),
      ),
    );
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
