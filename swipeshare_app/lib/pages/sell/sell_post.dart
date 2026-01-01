import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/dates.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/dining_halls.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/payment_options_picker.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/post_listing_button.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/sell_validation.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/swipe_count_picker.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/time_picker.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/pages/sell/sell_order_confirm.dart';

class SellPostScreen extends StatefulWidget {
  final List<String> initialPaymentOptions;

  const SellPostScreen({super.key, required this.initialPaymentOptions});

  @override
  State<SellPostScreen> createState() => _SellPostScreenState();
}

class _SellPostScreenState extends State<SellPostScreen> {
  List<String> selectedLocations = [];
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int swipeCount = 7;
  late List<String> paymentOptions;

  @override
  void initState() {
    super.initState();
    paymentOptions = widget.initialPaymentOptions;
  }

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
                    Text(
                      'Set up your swipe listing with location, time, and payment preferences',
                      style: AppTextStyles.bodyText,
                    ),
                    const SizedBox(height: BuySwipesConstants.largeSpacing),
                    DiningHallsComponent(
                      selectedLocations: selectedLocations,
                      onLocationToggle: _toggleLocationSelection,
                      sellOrBuy: "sell",
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
                    const SizedBox(height: BuySwipesConstants.mediumSpacing),
                    SwipeCountComponent(
                      swipeCount: swipeCount,
                      onSwipeCountChanged: (count) =>
                          setState(() => swipeCount = count),
                      maxSwipes: 1,
                      enabled: false,
                    ),
                    const SizedBox(height: BuySwipesConstants.mediumSpacing),
                    PaymentOptionsComponent(
                      selectedPaymentOptions: paymentOptions,
                      onPaymentOptionsChanged: (options) =>
                          setState(() => paymentOptions = options),
                      fromHomeScreen: false,
                    ),
                    const SizedBox(height: BuySwipesConstants.mediumSpacing),
                    SellValidationComponent(
                      selectedLocations: selectedLocations,
                      startTime: startTime,
                      endTime: endTime,
                      swipeCount: swipeCount,
                      selectedPaymentOptions: paymentOptions,
                    ),
                    const SizedBox(height: BuySwipesConstants.largeSpacing),
                  ],
                ),
              ),
            ),
            _buildPostListingButton(),
            const SizedBox(height: BuySwipesConstants.mediumSpacing),
          ],
        ),
      ),
    );
  }

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
                child: Text('Sell Swipes', style: AppTextStyles.pageTitle),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: BuySwipesConstants.smallSpacing),
      ],
    );
  }

  Widget _buildPostListingButton() {
    return PostListingButton(
      onPressed: _canPostListing() ? _navigateToConfirmation : null,
    );
  }

  void _toggleLocationSelection(String location) {
    setState(() {
      if (selectedLocations.contains(location)) {
        selectedLocations.remove(location);
      } else {
        selectedLocations.clear();
        selectedLocations.add(location);
      }
    });
  }

  bool _canPostListing() {
    return startTime != null &&
        endTime != null &&
        selectedLocations.isNotEmpty &&
        swipeCount > 0 &&
        paymentOptions.isNotEmpty &&
        !_isEndTimeBeforeStartTime();
  }

  void _navigateToConfirmation() async {
    if (await Haptics.canVibrate()) {
      Haptics.vibrate(HapticsType.medium);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellOrderConfirmScreen(
          location: selectedLocations.first,
          date: selectedDate,
          startTime: startTime!,
          endTime: endTime!,
          swipeCount: swipeCount,
          paymentOptions: paymentOptions,
        ),
      ),
    );
  }

  bool _isEndTimeBeforeStartTime() {
    if (startTime == null || endTime == null) return false;

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;

    return endMinutes <= startMinutes;
  }
}
