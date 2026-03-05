import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/adaptive/adaptive_dialog.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/components/listing_detail_card.dart';
import 'package:swipeshare_app/components/page_app_bar.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/pages/dashboard/edit_listing_page.dart';
import 'package:swipeshare_app/services/listing_service.dart';

class ListingDetailPage extends StatelessWidget {
  final Listing listing;

  const ListingDetailPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    void onEdit() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EditListingPage(listing: listing)),
      );
    }

    Future<void> onDelete() async {
      final confirmed = await AdaptiveDialog.showConfirmation(
        context: context,
        title: 'Delete Listing',
        content:
            'Are you sure you want to delete this listing? This cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDestructive: true,
      );
      if (confirmed == true) {
        await ListingService.instance.deleteListing(listing.id);
        if (context.mounted) Navigator.of(context).pop();
      }
    }

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const PageAppBar(title: 'Your Listing'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListingDetailCard(listing: listing),
            const SizedBox(height: 16),
            _ListingActionButton(
              icon: Icons.edit_outlined,
              label: 'Edit Listing',
              onPressed: onEdit,
            ),
            const SizedBox(height: 12),
            _ListingActionButton(
              icon: Icons.delete_outline,
              label: 'Delete Listing',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ListingActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await safeVibrate(HapticsType.selection);
          onPressed();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: onSurface),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 17,
                  color: onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
