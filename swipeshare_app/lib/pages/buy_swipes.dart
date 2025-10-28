import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/dates.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/dining_halls.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/payment_options_picker.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/time_picker.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/time_picker_validation.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/pages/listing_selection_page.dart';

class BuySwipeScreen extends StatefulWidget {
  List<String> paymentOptions;
  BuySwipeScreen({super.key, required this.paymentOptions});

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
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: BuySwipesConstants.largeSpacing),
                    DiningHallsComponent(
                      selectedLocations: selectedLocations,
                      onLocationToggle: _toggleLocationSelection,
                      sellOrBuy: "buy",
                    ),
                    const SizedBox(height: BuySwipesConstants.mediumSpacing),
                    DateSelectorComponent(
                      selectedDate: selectedDate,
                      onDateSelected: (date) =>
                          setState(() => selectedDate = date),
                    ),
                    const SizedBox(height: BuySwipesConstants.largeSpacing),
                    TimePickerComponent(
                      startTime: startTime,
                      endTime: endTime,
                      onStartTimeChanged: (time) =>
                          setState(() => startTime = time),
                      onEndTimeChanged: (time) =>
                          setState(() => endTime = time),
                    ),

                    const SizedBox(height: BuySwipesConstants.largeSpacing),
                    PaymentOptionsComponent(
                      selectedPaymentOptions: widget.paymentOptions,
                      onPaymentOptionsChanged: (options) =>
                          setState(() => widget.paymentOptions = options),
                      fromHomeScreen: false,
                    ),
                    const SizedBox(height: BuySwipesConstants.mediumSpacing),
                    TimePickerValidationComponent(
                      selectedLocations: selectedLocations,
                      startTime: startTime,
                      endTime: endTime,
                    ),
                  ],
                ),
              ),
            ),
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
                child: Text('Find a Swipe', style: AppTextStyles.pageTitle),
              ),
            ),
            const SizedBox(width: 48), // Balance the back button
          ],
        ),
        const SizedBox(height: BuySwipesConstants.smallSpacing),
        Text(
          'Select a dining hall, date, and time to find available swipes',
          style: AppTextStyles.bodyText, //TODO: center allign later
        ),
      ],
    );
  }

  /// Builds the find seller button with proper styling and state
  Widget _buildFindSellerButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canProceedToNextScreen()
            ? _navigateToListingSelection
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              BuySwipesConstants.borderRadius,
            ),
          ),
          padding: BuySwipesConstants.buttonPadding,
        ),
        child: Text("Find Swipe Seller", style: AppTextStyles.buttonText),
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
  void _navigateToListingSelection() async {
    if (await Haptics.canVibrate()) {
      Haptics.vibrate(HapticsType.medium);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingSelectionPage(
          locations: selectedLocations,
          date: selectedDate,
          startTime: startTime!,
          endTime: endTime!,
          paymentTypes: widget.paymentOptions,
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
