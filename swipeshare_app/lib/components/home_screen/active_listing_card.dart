import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/adaptive/adaptive_dialog.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/services/listing_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

class ActiveListingCard extends StatelessWidget {
  final Listing currentListing;

  ActiveListingCard({super.key, required this.currentListing});

  final ListingService _listingService = ListingService.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          //popup for delete
          await safeVibrate(HapticsType.light);
          _showDeleteDialog(context);
        },
        child: Container(
          width: 225,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(107, 255, 255, 255),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0x6F98D2EB), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${currentListing.diningHall}, ${TimeFormatter.formatToMMDD(currentListing.transactionDate)}",
                style: SubHeaderStyle,
              ),
              const SizedBox(height: 7),
              FittedBox(
                child: Text(
                  "From  ${TimeFormatter.formatTimeOfDay(TimeFormatter.productionToString(currentListing.timeStart))}  to  ${TimeFormatter.formatTimeOfDay(TimeFormatter.productionToString(currentListing.timeEnd))}",
                  style: AppTextStyles.listingText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) async {
    final confirmed = await AdaptiveDialog.showConfirmation(
      context: context,
      title: 'Delete Listing',
      content: 'Are you sure you want to Delete this Listing?',
      confirmText: 'Delete',
      cancelText: 'Close',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      _listingService.updateListingStatus(
        currentListing.id,
        ListingStatus.cancelled,
      );
      await safeVibrate(HapticsType.heavy);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(SnackbarMessages.chatDeleted)));
      }
    }
  }
}
