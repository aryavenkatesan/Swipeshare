import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/pages/chat_page.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

class ActiveOrderCard extends StatelessWidget {
  final MealOrder order;

  const ActiveOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 80,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () async {
            await safeVibrate(HapticsType.selection);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(orderData: order),
                ),
              );
            }
          },
          child: Row(
            children: [
              // Left accent bar – 7 px wide, full height
              Container(width: 7, color: colors.surfaceTint),
              // Content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 17,
                    right: 17,
                    top: 5,
                    bottom: 5,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text column
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "Chase 1/13" – medium + light inline
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: order.diningHall,
                                    style: textTheme.titleMedium,
                                  ),
                                  TextSpan(
                                    text:
                                        ' ${order.transactionDate.month}/${order.transactionDate.day}',
                                    style: textTheme.labelMedium?.copyWith(
                                      fontSize: 15,
                                      color: SwipeshareColors.subtleText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 0),
                            // "3:30 PM"
                            Text(
                              order.displayTime != null
                                  ? TimeFormatter.formatTimeOfDayString(
                                      order.displayTime!,
                                    )
                                  : "TBD",
                              style: textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      // Chevron forward icon
                      Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: colors.onSurface,
                      ),
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
}
