import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/listing_form/listing_form.dart';
import 'package:swipeshare_app/components/page_app_bar.dart';
import 'package:swipeshare_app/components/sell_listing_preview_card.dart';
import 'package:swipeshare_app/services/listing_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class ConfirmListingPage extends StatelessWidget {
  final ListingFormData data;

  const ConfirmListingPage({super.key, required this.data});

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
                    diningHall: data.diningHall,
                    date: data.transactionDate,
                    timeStart: data.timeStart,
                    timeEnd: data.timeEnd,
                    paymentTypes: data.paymentTypes,
                    price: data.price,
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
      data.diningHall,
      data.timeStart,
      data.timeEnd,
      data.transactionDate,
      data.paymentTypes,
      data.price,
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Successfully Placed Listing!'),
        content: const Text(
          'Check back again soon once someone contacts you for the order!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
