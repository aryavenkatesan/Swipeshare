import 'package:flutter/material.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

/// A card that previews a sell listing before posting.
/// Similar to [ListingDetailCard] but without the "Sold by" section.
class SellListingPreviewCard extends StatelessWidget {
  final String diningHall;
  final DateTime date;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;
  final List<String> paymentTypes;
  final double price;

  const SellListingPreviewCard({
    super.key,
    required this.diningHall,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.paymentTypes,
    required this.price,
  });

  String get _timeRange {
    final start = TimeFormatter.formatTimeOfDay(
      TimeFormatter.productionToString(timeStart),
    );
    final end = TimeFormatter.formatTimeOfDay(
      TimeFormatter.productionToString(timeEnd),
    );
    return 'From $start to $end';
  }

  String get _date {
    return '${date.month}/${date.day}/${date.year % 100}';
  }

  String get _price {
    return '\$${price % 1 == 0 ? price.toInt() : price.toStringAsFixed(2)}';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(diningHall, style: hallStyle),
                Text(_date, style: valueStyle),
              ],
            ),
            const SizedBox(height: 4),

            Text('Time:', style: labelStyle),
            Text(_timeRange, style: valueStyle),
            const SizedBox(height: 8),

            const Divider(height: 1, color: Color(0xFFD9D9D9)),
            const SizedBox(height: 8),

            Text('Payment Types:', style: labelStyle),
            Text(paymentTypes.join(', '), style: valueStyle),
            const SizedBox(height: 4),

            Text('Price:', style: labelStyle),
            Text(_price, style: valueStyle),
          ],
        ),
      ),
    );
  }
}
