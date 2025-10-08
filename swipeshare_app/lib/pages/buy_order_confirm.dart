import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/services/order_service.dart';

class BuyOrderConfirmScreen extends StatefulWidget {
  final String sellerName;
  final String location;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String sellerId;
  final int overlapMinutes;

  const BuyOrderConfirmScreen({
    super.key,
    required this.sellerName,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.sellerId,
    this.overlapMinutes = 30,
  });

  @override
  _BuyOrderConfirmScreenState createState() => _BuyOrderConfirmScreenState();
}

class _BuyOrderConfirmScreenState extends State<BuyOrderConfirmScreen> {
  String _formatTime(TimeOfDay time) {
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

              // Expanded scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: BuySwipesConstants.largeSpacing),
                      _buildConfirmContent(),
                    ],
                  ),
                ),
              ),
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
            child: Text('Confirm Order', style: AppTextStyles.pageTitle),
          ),
        ),
        const SizedBox(width: 48), // Balance the back button
      ],
    );
  }

  Widget _buildConfirmContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Center(
          child: Column(
            children: [
              Text(
                'Confirm Your Order',
                style: AppTextStyles.pageTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Review your swipe purchase details',
                style: AppTextStyles.subText,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: BuySwipesConstants.largeSpacing),

        // Seller
        _buildInfoCard(
          icon: Icons.person,
          title: widget.sellerName,
          subtitle: 'Seller',
        ),

        const SizedBox(height: BuySwipesConstants.mediumSpacing),

        // Location
        _buildInfoCard(
          icon: Icons.location_on,
          title: widget.location,
          subtitle: 'Dining Hall',
        ),

        const SizedBox(height: BuySwipesConstants.mediumSpacing),

        // Date and Time
        _buildInfoCard(
          icon: Icons.schedule,
          title:
              "${formatDate(widget.date)} • ${_formatTime(widget.startTime)} - ${_formatTime(widget.endTime)}",
          subtitle: 'Meeting Time',
        ),

        const SizedBox(height: BuySwipesConstants.mediumSpacing),

        // Time Overlap
        _buildInfoCard(
          icon: Icons.access_time,
          title: '${widget.overlapMinutes} minutes',
          subtitle: 'Available Window',
        ),

        const SizedBox(height: BuySwipesConstants.largeSpacing * 2),

        // Confirm button
        _buildPlaceOrderButton(),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: BuySwipesConstants.containerPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BuySwipesConstants.borderRadius),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: AppTextStyles.validationText.copyWith(
                    color: AppColors.subText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _placeOrder();
        },
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
        child: Text("Place Order", style: AppTextStyles.buttonText),
      ),
    );
  }

  Future<void> _placeOrder() async {
    try {
      final orderService = OrderService();
      await orderService.createOrder(
        sellerId: widget.sellerId,
        diningHall: widget.location,
        date: widget.date,
        time: TimeOfDay(
          hour: widget.startTime.hour,
          minute: widget.startTime.minute,
        ),
      );

      // Show success message and navigate back
      _showSuccessDialog();
    } catch (e) {
      // Show error message
      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                BuySwipesConstants.borderRadius,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.accentBlue, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Order Placed!',
                  style: AppTextStyles.headerStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order has been placed successfully.',
                  style: AppTextStyles.subText,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.popUntil(
                        context,
                        (route) => route.isFirst,
                      ); // Go back to home
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          BuySwipesConstants.borderRadius,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Back to Home",
                      style: AppTextStyles.buttonText,
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

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Failed'),
          content: Text('There was an error placing your order: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
