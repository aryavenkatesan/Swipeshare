import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/time_formatter.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/services/listing_service.dart';

class ActiveListingCard extends StatelessWidget {
  final Listing currentListing;
  final String listingId;

  ActiveListingCard({
    super.key,
    required this.currentListing,
    required this.listingId,
  });

  final ListingService _listingService = ListingService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          //popup for delete
          if (await Haptics.canVibrate()) {
            Haptics.vibrate(HapticsType.light);
          }
          _showDeleteDialog(context);
        },
        child: Container(
          width: 225,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12, width: 1),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Listing'),
          content: const Text('Are you sure you want to Delete this Listing?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                _listingService.deleteListing(listingId);
                if (await Haptics.canVibrate()) {
                  Haptics.vibrate(HapticsType.heavy);
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('The Listing has been deleted.'),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color.fromARGB(177, 96, 125, 139)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
