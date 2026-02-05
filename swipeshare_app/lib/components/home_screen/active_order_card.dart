import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/adaptive/adaptive_dialog.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/pages/chat_page.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

class ActiveOrderCard extends StatelessWidget {
  final MealOrder orderData;

  bool get hasNotifs => switch (orderData.currentUserRole) {
    OrderRole.buyer => orderData.buyerHasNotifs,
    OrderRole.seller => orderData.sellerHasNotifs,
  };

  bool get isCancelled => orderData.status == OrderStatus.cancelled;

  String get cancelledByName => orderData.cancelledBy == OrderRole.buyer
      ? orderData.buyerName
      : orderData.sellerName;

  const ActiveOrderCard({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Opacity(
            opacity: isCancelled ? 0.5 : 1.0,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await safeVibrate(HapticsType.medium);
                if (!context.mounted) return;
                if (isCancelled) {
                  _showCancelledDialog(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(orderData: orderData),
                    ),
                  );
                }
              },
              child: Container(
                width: 225,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCancelled
                        ? Colors.grey.shade400
                        : const Color(0xFF98D2EB),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: orderData.diningHall,
                            style: HeaderStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCancelled
                          ? 'Cancelled'
                          : orderData.displayTime != null
                          ? "${TimeFormatter.formatTimeOfDay(orderData.displayTime!)}    ${TimeFormatter.formatToMMDD(orderData.transactionDate)} "
                          : "${TimeFormatter.formatToMMDD(orderData.transactionDate)}, TBD",
                      style: GreyHeaderStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasNotifs && !isCancelled)
            Positioned(
              top: -5,
              right: -6,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelledDialog(BuildContext context) async {
    final confirmed = await AdaptiveDialog.showConfirmation(
      context: context,
      title: 'Order Cancelled',
      content: 'This order was cancelled by $cancelledByName.',
      confirmText: 'Clear',
      cancelText: 'Close',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await safeVibrate(HapticsType.medium);
      await OrderService.instance.acknowledgeCancellation(
        orderData.getRoomName(),
      );
    }
  }
}
