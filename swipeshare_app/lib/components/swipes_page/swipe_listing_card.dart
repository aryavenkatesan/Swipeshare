import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/pages/buy/view_listing_page.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

/// Swipe listing card matching Figma 621:1278.
/// Line 1: "{hall}" (Lexend Medium 23sp) + " {date}" (Lexend Light 23sp)
/// Line 2: "{startTime} to {endTime}" (Lexend Light 18.5sp)
class SwipeListingCard extends StatelessWidget {
  final Listing listing;

  const SwipeListingCard({super.key, required this.listing});

  String get _date {
    final d = listing.transactionDate;
    return '${d.month}/${d.day}';
  }

  String get _timeRange {
    return '${TimeFormatter.formatTOD(listing.timeStart)} to '
        '${TimeFormatter.formatTOD(listing.timeEnd)}';
  }

  String _formatDisplayTime(String timeRange) {
    return timeRange.replaceAllMapped(
      RegExp(r'(\d+):00\s*([AP]M)'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewListingPage(listing: listing),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${listing.diningHall} ',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w500,
                        fontSize: 23,
                        height: 1,
                        color: textTheme.titleMedium?.color,
                      ),
                    ),
                    TextSpan(
                      text: _date,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w300,
                        fontSize: 23,
                        height: 1,
                        color: textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatDisplayTime(_timeRange),
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 18.5,
                    color: Colors.black,
                    height: 1,
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
