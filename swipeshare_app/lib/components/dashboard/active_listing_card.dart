import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/pages/dashboard/your_listing_page.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

class ActiveListingCard extends StatelessWidget {
  final Listing listing;

  const ActiveListingCard({super.key, required this.listing});

  String get timeRangeText =>
      TimeFormatter.formatTimeRange(listing.timeStart, listing.timeEnd);

  void onTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListingDetailPage(listing: listing)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () async {
          await safeVibrate(HapticsType.selection);
          if (!context.mounted) return;
          onTap(context);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 9, bottom: 9, right: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: listing.diningHall,
                                    style: textTheme.titleMedium?.copyWith(),
                                  ),
                                  TextSpan(
                                    text:
                                        ' ${listing.transactionDate.month}/${listing.transactionDate.day}',
                                    style: textTheme.labelMedium?.copyWith(
                                      fontSize: 15,
                                      color: SwipeshareColors.subtleText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(timeRangeText, style: textTheme.bodyLarge),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1, top: 8, right: 8, left: 8),
                    child: Icon(
                      Icons.more_horiz,
                      size: 24,
                      color: colors.onSurface,
                    ),
                  ),
                  if (listing.price != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '\$${listing.price!.toStringAsFixed(listing.price! % 1 == 0 ? 0 : 2)}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: SwipeshareColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
