import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/page_app_bar.dart';
import 'package:swipeshare_app/components/sell_listing_preview_card.dart';
import 'package:swipeshare_app/services/listing_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class ConfirmListingPage extends StatelessWidget {
  final String location;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double price;
  final List<String> paymentOptions;

  const ConfirmListingPage({
    super.key,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.paymentOptions,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const PageAppBar(title: 'Confirm Listing'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review your listing details before posting',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  SellListingPreviewCard(
                    diningHall: location,
                    date: date,
                    timeStart: startTime,
                    timeEnd: endTime,
                    paymentTypes: paymentOptions,
                    price: price,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton(
              onPressed: () => _postListing(context),
              child: const Text('Post Listing'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _postListing(BuildContext context) async {
    ListingService.instance.postListing(
      location,
      startTime,
      endTime,
      date,
      paymentOptions,
    );
    await safeVibrate(HapticsType.success);
    if (!context.mounted) return;
    Navigator.pop(context);
    Navigator.pop(context);
    _showConfirmationDialog(context);
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Successfully Placed Listing!'),
        content: const Text(
          'Check back again soon once someone contacts you for the order!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
