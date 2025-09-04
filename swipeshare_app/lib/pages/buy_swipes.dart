import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/time_picker.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/dining_halls.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/dates.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/time_picker_validation.dart';
import 'package:swipeshare_app/pages/listing_selection_page.dart';

class BuySwipeScreen extends StatefulWidget {
  const BuySwipeScreen({super.key});

  @override
  State<BuySwipeScreen> createState() => _BuySwipeScreenState();
}

class _BuySwipeScreenState extends State<BuySwipeScreen> {
  List<String> selectedLocations = [];
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BuySwipesConstants.wrapWithContainer(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: BuySwipesConstants.largeSpacing),
            DiningHallsComponent(
              selectedLocations: selectedLocations,
              onLocationToggle: _toggleLocationSelection,
            ),
            const SizedBox(height: BuySwipesConstants.mediumSpacing),
            DateSelectorComponent(
              selectedDate: selectedDate,
              onDateSelected: (date) => setState(() => selectedDate = date),
            ),
            const SizedBox(height: BuySwipesConstants.largeSpacing),
            TimePickerComponent(
              startTime: startTime,
              endTime: endTime,
              onStartTimeChanged: (time) => setState(() => startTime = time),
              onEndTimeChanged: (time) => setState(() => endTime = time),
            ),
            const SizedBox(height: BuySwipesConstants.mediumSpacing),
            TimePickerValidationComponent(
              selectedLocations: selectedLocations,
              startTime: startTime,
              endTime: endTime,
            ),
            const Spacer(),
            Center(child: _buildFindSellerButton()),
            const SizedBox(height: BuySwipesConstants.mediumSpacing),
          ],
        ),
      ),
    );
  }

  /// Builds the header with back button, title, and subtitle
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Find a Swipe',
                  style: AppTextStyles.pageTitle,
                ),
              ),
            ),
            const SizedBox(width: 48), // Balance the back button
          ],
        ),
        const SizedBox(height: BuySwipesConstants.smallSpacing),
        Text(
          'Select a dining hall, date, and time to find available swipes',
          style: AppTextStyles.bodyText,
        ),
      ],
    );
  }

  /// Builds the find seller button with proper styling and state
  Widget _buildFindSellerButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canProceedToNextScreen() ? _navigateToListingSelection : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BuySwipesConstants.borderRadius),
          ),
          padding: BuySwipesConstants.buttonPadding,
        ),
        child: Text(
          "Find Swipe Seller",
          style: AppTextStyles.buttonText,
        ),
      ),
    );
  }

  /// Toggles location selection (add/remove from selected list)
  void _toggleLocationSelection(String location) {
    setState(() {
      selectedLocations.contains(location)
          ? selectedLocations.remove(location)
          : selectedLocations.add(location);
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

  /// Validates if end time is before start time
  bool _isEndTimeBeforeStartTime() {
    if (startTime == null || endTime == null) return false;
    
    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;
    
    return endMinutes <= startMinutes;
  }
}
