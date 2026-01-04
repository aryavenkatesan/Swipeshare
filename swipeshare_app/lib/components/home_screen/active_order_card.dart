import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/pages/chat_page.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

class ActiveOrderCard extends StatelessWidget {
  final MealOrder orderData;

  bool get hasNotifs =>
      FirebaseAuth.instance.currentUser!.uid == orderData.buyerId
      ? orderData.buyerHasNotifs
      : orderData.sellerHasNotifs;

  const ActiveOrderCard({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              await safeVibrate(HapticsType.medium);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(orderData: orderData),
                ),
              );
            },
            child: Container(
              width: 225,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF98D2EB), width: 2),
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
                        // TextSpan(
                        //   text:
                        //       '  ${TimeFormatter.formatToMMDD(orderData.transactionDate)}',
                        //   style: GreyHeaderStyle,
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    orderData.displayTime != null
                        ? "${TimeFormatter.formatTimeOfDay(orderData.displayTime!)}    ${TimeFormatter.formatToMMDD(orderData.transactionDate)} "
                        : "${TimeFormatter.formatToMMDD(orderData.transactionDate)}, TBD",
                    style: GreyHeaderStyle,
                  ),
                ],
              ),
            ),
          ),
          if (hasNotifs)
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
}
