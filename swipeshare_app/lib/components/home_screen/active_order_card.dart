import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/time_formatter.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/pages/chat_page.dart';

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
            onPressed: () {
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
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF98D2EB), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(orderData.diningHall, style: HeaderStyle),
                  const SizedBox(height: 6),
                  Text(
                    orderData.displayTime != null
                        ? TimeFormatter.formatTimeOfDay(orderData.displayTime!)
                        : "TBD",
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
