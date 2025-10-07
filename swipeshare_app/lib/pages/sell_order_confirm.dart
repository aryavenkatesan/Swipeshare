import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/post_listing_button.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/services/listing_service.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: BuySwipesConstants.screenPadding,
          child: Column(
            children: [
              // Header with back button
              _buildHeader(),

              // Expanded content that fills remaining space
              _buildConfirmContent(),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildConfirmContent() {
    return Expanded(
      child: Column(
        children: [
          // Top spacing
          const SizedBox(height: 16),

          // Time section - top priority with elegant styling
          Expanded(
            flex: 4,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
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
              ),
            ),
          ),

          // Location section with icon
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.white,
                      size: 24,
                    ),
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
              ),
            ),
          ),

          // Payment methods section with enhanced styling
          Expanded(
            flex: 3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            ),
          ),

          // Swipe count section with badge style
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
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
                      Icons.restaurant,
                      color: AppColors.accentBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.swipeCount == 1
                          ? '1 Swipe'
                          : '${widget.swipeCount} Swipes',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Spacer before button
          const Spacer(flex: 1),

          // Button section with enhanced styling
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
            child: _buildConfirmButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return PostListingButton(
      onPressed: () {
        final listingService = ListingService();
        listingService.createListing(
          diningHall: widget.location,
          timeStart: widget.startTime,
          timeEnd: widget.endTime,
          transactionDate: widget.date,
        );
        _showSuccessDialog();
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentBlue,
                        AppColors.accentBlue.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentBlue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Listing Posted! 🎉',
                  style: AppTextStyles.headerStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your swipe listing is now live and ready for buyers.',
                  style: AppTextStyles.subText.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentBlue,
                        AppColors.accentBlue.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentBlue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to sell post
                      Navigator.pop(context); // Go back to home
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Back to Home",
                      style: AppTextStyles.buttonText.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
