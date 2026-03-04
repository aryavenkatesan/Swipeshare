import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/listing_detail_card.dart';
import 'package:swipeshare_app/components/page_app_bar.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/pages/chat_page.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

class ViewListingPage extends StatefulWidget {
  final Listing listing;

  const ViewListingPage({super.key, required this.listing});

  @override
  State<ViewListingPage> createState() => _ViewListingPageState();
}

class _ViewListingPageState extends State<ViewListingPage> {
  final _orderService = OrderService.instance;
  bool _isLoading = false;

  Future<void> _handleListingSelection() async {
    setState(() => _isLoading = true);
    try {
      await safeVibrate(HapticsType.success);
      final newOrder = await _orderService.postOrder(widget.listing);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(SnackbarMessages.orderPlaced)),
        );
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(orderData: newOrder),
          ),
        );
      }
    } catch (e, s) {
      debugPrint('Error: $e');
      debugPrint('Stack: $s');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(SnackbarMessages.orderFailed(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageAppBar(title: 'View Listing'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: ListingDetailCard(listing: widget.listing),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleListingSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                splashFactory: InkRipple.splashFactory,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Select Listing'),
            ),
          ),
        ],
      ),
    );
  }
}