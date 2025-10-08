import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/pages/chat_page.dart';

class ActiveOrderCard extends StatelessWidget {
  final MealOrder order;

  const ActiveOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatPage(order: order)),
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
              Text(order.diningHall, style: HeaderStyle),
              const SizedBox(height: 6),
              Text(
                (order.time != null)
                    ? "${order.time!.hour}:${order.time!.minute.toString().padLeft(2, '0')}"
                    : "TBD",
                style: GreyHeaderStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
