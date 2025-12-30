import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/services/listing_service.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/post_listing_button.dart';
import 'package:flutter/material.dart';

class SellOrderConfirmScreen extends StatefulWidget {
  final String location;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int swipeCount;
  final List<String> paymentOptions;

  const SellOrderConfirmScreen({
    super.key,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.swipeCount,
    required this.paymentOptions,
  });

  @override
  _SellOrderConfirmScreenState createState() => _SellOrderConfirmScreenState();
}

class _SellOrderConfirmScreenState extends State<SellOrderConfirmScreen> {
  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  String formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final listingService = ListingService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: BuySwipesConstants.screenPadding,
          // This is the main layout widget. It will hold the fixed header,
          // the expanded scrollable content, and the fixed button.
          child: Column(
            children: [
              // 1. FIXED HEADER: This will always be visible at the top.
              _buildHeader(),
              const SizedBox(height: 16),

              // 2. SCROLLABLE CONTENT: The Expanded widget makes this section
              // fill all the available vertical space between the header and the button.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // We've removed all 'Expanded' and 'Spacer' widgets from the content
                      // and replaced them with SizedBoxes for predictable spacing.

                      // Time section
                      _buildTimeSection(),
                      const SizedBox(height: 32),

                      // Location section
                      _buildLocationSection(),
                      const SizedBox(height: 32),

                      // Payment methods section
                      _buildPaymentMethodsSection(),
                      const SizedBox(height: 32),

                      // Swipe count section
                      _buildSwipeCountSection(),

                      // Added bottom padding so content doesn't abruptly end
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // 3. FIXED BUTTON: This will always be visible at the bottom.
              _buildConfirmButton(listingService),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for the header (no changes)
  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Center(
            child: Text('Confirm Listing', style: AppTextStyles.pageTitle),
          ),
        ),
        const SizedBox(width: 48), // Balance the back button
      ],
    );
  }

  // I've broken down your original content into separate, readable methods.
  // Notice there are NO Expanded or Spacer widgets here.

  Widget _buildTimeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentBlue.withOpacity(0.1),
            AppColors.accentBlue.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "${formatTime(widget.startTime)} - ${formatTime(widget.endTime)}",
              style: AppTextStyles.pageTitle.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              formatDate(widget.date),
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 14,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accentBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBlue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.location_on, color: AppColors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          widget.location,
          style: AppTextStyles.headerStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      children: [
        Text(
          "Payment Methods",
          style: AppTextStyles.validationText.copyWith(
            fontSize: 14,
            color: AppColors.subText,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: widget.paymentOptions
              .map(
                (method) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentBlue,
                        AppColors.accentBlue.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    method,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSwipeCountSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.accentBlue.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_money_rounded,
            color: AppColors.accentBlue,
            size: 24,
          ),
          const SizedBox(width: 2),
          Text(
            // widget.swipeCount == 1 ? '1 Swipe' : '${widget.swipeCount} Swipes',
            '7',
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(ListingService listingService) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: PostListingButton(
        onPressed: () async {
          listingService.postListing(
            widget.location,
            widget.startTime,
            widget.endTime,
            widget.date,
            widget.paymentOptions,
          );
          if (await Haptics.canVibrate()) {
            Haptics.vibrate(HapticsType.success);
          }
          Navigator.pop(context);
          Navigator.pop(context);

          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Sucessfully Placed Listing!')),
          // );
          showConfirmationDialog(context);
        },
      ),
    );
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Successfully Placed Listing!"),
          content: Text(
            "Check back again soon once someone contacts you for the order!",
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text("OK"),
              onPressed: () {
                // This closes the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
