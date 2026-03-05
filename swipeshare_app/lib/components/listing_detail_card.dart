import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

class ListingDetailCard extends StatelessWidget {
  final Listing listing;

  const ListingDetailCard({super.key, required this.listing});

  String get _timeRangeText =>
      TimeFormatter.formatTimeRange(listing.timeStart, listing.timeEnd);

  String get _date {
    final d = listing.transactionDate;
    return '${d.month}/${d.day}/${d.year % 100}';
  }

  String get _price {
    if (listing.price == null) return 'N/A';
    final p = listing.price!;
    // `p % 1 == 0` checks if p is a whole number (e.g., 5.0)
    return '\$${p % 1 == 0 ? p.toInt() : p.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final labelStyle = textTheme.bodyLarge?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 34 / 13,
    );
    final valueStyle = textTheme.bodyLarge;
    final hallStyle = textTheme.titleMedium?.copyWith(fontSize: 28);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: dining hall + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(listing.diningHall, style: hallStyle),
                Text(_date, style: valueStyle),
              ],
            ),
            const SizedBox(height: 4),

            // Time
            Text('Time:', style: labelStyle),
            Text(_timeRangeText, style: valueStyle),
            const SizedBox(height: 8),

            const Divider(height: 1, color: Color(0xFFD9D9D9)),
            const SizedBox(height: 8),

            // Payment types
            Text('Payment Types:', style: labelStyle),
            Text(listing.paymentTypes.join(', '), style: valueStyle),
            const SizedBox(height: 4),

            // Price
            Text('Price:', style: labelStyle),
            Text(_price, style: valueStyle),
            const SizedBox(height: 8),

            const Divider(height: 1, color: Color(0xFFD9D9D9)),
            const SizedBox(height: 8),

            // Sold by
            Text('Sold by:', style: labelStyle),
            Row(
              children: [
                Text(listing.sellerName, style: valueStyle),
                const SizedBox(width: 4),
                Text(
                  '(\u2605 ${listing.sellerRating.toStringAsFixed(2)})',
                  style: valueStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
