import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/time_picker.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/dining_halls.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/dates.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/time_picker_validation.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/post_listing_button.dart';
import 'package:swipeshare_app/pages/sell_order_confirm.dart';

class SellPostScreen extends StatefulWidget {
  const SellPostScreen({super.key});

  @override
  State<SellPostScreen> createState() => _SellPostScreenState();
}

class _SellPostScreenState extends State<SellPostScreen> {
  List<String> selectedLocations = [];
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int swipeCount = 1;
  List<String> selectedPaymentOptions = [];

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
                    _SwipeCountComponent(
                      swipeCount: swipeCount,
                      onSwipeCountChanged: (count) => setState(() => swipeCount = count),
                    ),
                    const SizedBox(height: BuySwipesConstants.mediumSpacing),
                    _PaymentOptionsComponent(
                      selectedPaymentOptions: selectedPaymentOptions,
                      onPaymentOptionsChanged: (options) => setState(() => selectedPaymentOptions = options),
                    ),
                    const SizedBox(height: BuySwipesConstants.mediumSpacing),
                    _SellValidationComponent(
                      selectedLocations: selectedLocations,
                      startTime: startTime,
                      endTime: endTime,
                      swipeCount: swipeCount,
                      selectedPaymentOptions: selectedPaymentOptions,
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
                  'Sell Swipes',
                  style: AppTextStyles.pageTitle,
                ),
              ),
            ),
            const SizedBox(width: 48), // Balance the back button
          ],
        ),
        const SizedBox(height: BuySwipesConstants.smallSpacing),
        Text(
          'Set up your swipe listing with location, time, and payment preferences',
          style: AppTextStyles.bodyText,
        ),
      ],
    );
  }

  /// Builds the post listing button
  Widget _buildPostListingButton() {
    return PostListingButton(
      onPressed: _canPostListing() ? _navigateToConfirmation : null,
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

  /// Validates if user can post listing
  bool _canPostListing() {
    return startTime != null && 
           endTime != null && 
           selectedLocations.isNotEmpty &&
           swipeCount > 0 &&
           selectedPaymentOptions.isNotEmpty &&
           !_isEndTimeBeforeStartTime();
  }

  /// Navigates to confirmation page
  void _navigateToConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellOrderConfirmScreen(
          location: selectedLocations.first,
          date: selectedDate,
          startTime: startTime!,
          endTime: endTime!,
          swipeCount: swipeCount,
          paymentOptions: selectedPaymentOptions,
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

/// Component for selecting swipe count
class _SwipeCountComponent extends StatelessWidget {
  final int swipeCount;
  final Function(int) onSwipeCountChanged;

  const _SwipeCountComponent({
    required this.swipeCount,
    required this.onSwipeCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: BuySwipesConstants.containerPadding,
      decoration: BoxDecoration(
        color: AppColors.whiteTransparent,
        borderRadius: BorderRadius.circular(BuySwipesConstants.borderRadius),
        border: Border.all(color: AppColors.borderGrey, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of Swipes',
                style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'How many swipes to sell?',
                style: AppTextStyles.validationText.copyWith(color: AppColors.subText),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: swipeCount > 1 ? () => onSwipeCountChanged(swipeCount - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: swipeCount > 1 ? AppColors.accentBlue : AppColors.borderGrey,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentBlueLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  swipeCount.toString(),
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                onPressed: swipeCount < 10 ? () => onSwipeCountChanged(swipeCount + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: swipeCount < 10 ? AppColors.accentBlue : AppColors.borderGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Component for selecting payment options
class _PaymentOptionsComponent extends StatefulWidget {
  final List<String> selectedPaymentOptions;
  final Function(List<String>) onPaymentOptionsChanged;

  const _PaymentOptionsComponent({
    required this.selectedPaymentOptions,
    required this.onPaymentOptionsChanged,
  });

  @override
  State<_PaymentOptionsComponent> createState() => _PaymentOptionsComponentState();
}

class _PaymentOptionsComponentState extends State<_PaymentOptionsComponent> {
  bool isExpanded = false;
  
  final List<PaymentOption> paymentOptions = [
    PaymentOption('Cash', Icons.attach_money),
    PaymentOption('Venmo', Icons.payment),
    PaymentOption('Zelle', Icons.account_balance),
    PaymentOption('Apple Pay', Icons.apple),
    PaymentOption('PayPal', Icons.paypal),
    PaymentOption('CashApp', Icons.money),
  ];

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
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Container(
              padding: BuySwipesConstants.containerPadding,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Options',
                          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.selectedPaymentOptions.isEmpty 
                              ? 'Tap to select payment methods'
                              : '${widget.selectedPaymentOptions.length} method${widget.selectedPaymentOptions.length > 1 ? 's' : ''} selected',
                          style: AppTextStyles.validationText.copyWith(
                            color: widget.selectedPaymentOptions.isEmpty 
                                ? AppColors.subText 
                                : AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded 
                ? Column(
                    children: [
                      const Divider(height: 1, color: AppColors.borderGrey),
                      ...paymentOptions.map((option) => _buildPaymentOption(option)),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(PaymentOption option) {
    final isSelected = widget.selectedPaymentOptions.contains(option.name);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () => _togglePaymentOption(option.name),
        child: Container(
          padding: BuySwipesConstants.containerPadding,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentBlue.withOpacity(0.05) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                color: AppColors.accentBlue,
                size: 20,
              ),
              const SizedBox(width: BuySwipesConstants.mediumSpacing),
              Expanded(
                child: Text(
                  option.name,
                  style: AppTextStyles.bodyText,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  key: ValueKey(isSelected),
                  color: isSelected ? AppColors.accentBlue : AppColors.borderGrey,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _togglePaymentOption(String option) {
    final currentOptions = List<String>.from(widget.selectedPaymentOptions);
    if (currentOptions.contains(option)) {
      currentOptions.remove(option);
    } else {
      currentOptions.add(option);
    }
    widget.onPaymentOptionsChanged(currentOptions);
  }
}

/// Payment option data class
class PaymentOption {
  final String name;
  final IconData icon;

  PaymentOption(this.name, this.icon);
}

/// Custom validation component for sell screen
class _SellValidationComponent extends StatelessWidget {
  final List<String> selectedLocations;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int swipeCount;
  final List<String> selectedPaymentOptions;

  const _SellValidationComponent({
    required this.selectedLocations,
    required this.startTime,
    required this.endTime,
    required this.swipeCount,
    required this.selectedPaymentOptions,
  });

  @override
  Widget build(BuildContext context) {
    // Check for various validation conditions
    if (selectedLocations.isEmpty) {
      return _buildMessage('Please select a dining hall first');
    }
    
    if (startTime == null || endTime == null) {
      return _buildMessage('Please select start and end times');
    }
    
    if (_isEndTimeBeforeStartTime()) {
      return _buildMessage('End time cannot be before start time');
    }

    if (swipeCount <= 0) {
      return _buildMessage('Please select at least 1 swipe to sell');
    }

    if (selectedPaymentOptions.isEmpty) {
      return _buildMessage('Please select at least one payment method');
    }
    
    // All validations passed
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: Column(
          children: [
            Text(
              'Ready to post!',
              style: AppTextStyles.successText.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Selling $swipeCount swipe${swipeCount > 1 ? 's' : ''} • ${_formatTimeOfDay(startTime!)} to ${_formatTimeOfDay(endTime!)}',
              style: AppTextStyles.validationText.copyWith(
                color: AppColors.subText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a centered validation message
  Widget _buildMessage(String message) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.validationText,
        textAlign: TextAlign.center,
      ),
    );
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
