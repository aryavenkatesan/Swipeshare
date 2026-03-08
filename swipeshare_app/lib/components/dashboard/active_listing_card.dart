import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
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
          padding: const EdgeInsets.only(
            left: 16,
            top: 13,
            bottom: 13,
            right: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text column
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Chase 1/13"
                    RichText(
                      text: TextSpan(
                        style: textTheme.titleMedium,
                        children: [
                          TextSpan(text: '${listing.diningHall} '),
                          TextSpan(
                            text:
                                '${listing.transactionDate.month}/${listing.transactionDate.day}',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // "From 3:30 PM to 4:00 PM"
                    Text(timeRangeText, style: textTheme.bodyLarge),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.more_horiz,
                  size: 24,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
