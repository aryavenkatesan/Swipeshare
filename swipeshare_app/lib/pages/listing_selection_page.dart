import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/services/listing_service.dart';
import 'package:swipeshare_app/services/order_service.dart';

class ListingSelectionPage extends StatefulWidget {
  final List<String> locations;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  ListingSelectionPage({
    super.key,
    required this.locations,
    required this.date,
    required this.startTime,
    required this.endTime,
  }) {
    debugPrint(
      'Locations: $locations, Date: $date, Start: $startTime, End: $endTime',
    );
  }

  @override
  State<ListingSelectionPage> createState() => _ListingSelectionPageState();
}

class _ListingSelectionPageState extends State<ListingSelectionPage> {
  String? _expandedListingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Listings")),
      body: GestureDetector(
        // This will close the dropdown when tapping outside
        onTap: () {
          setState(() {
            _expandedListingId = null;
          });
        },
        child: _buildListingList(context),
      ),
    );
  }

  Widget _buildListingList(BuildContext context) {
    return ListingService().listingStream(
      // TODO: add PaymentType filtering here
      filter: _buildListingsFilter(),
      builder: (context, listings, isLoading, error) {
        if (error != null) {
          debugPrint('Error fetching listings: $error');
          return Text('error: $error');
        }

        if (isLoading) {
          return const Text('loading..');
        }

        return ListView(
          children: listings
              .map<Widget>((listing) => _buildListingItem(listing))
              .toList(),
        );
      },
    );
  }

  // build individual listing item
  Widget _buildListingItem(Listing listing) {
    final bool isExpanded = _expandedListingId == listing.id;

    // display all listings with a selection location
    return GestureDetector(
      // change this from a listTile to a custom componenent that will take arguments and spit out smth beautiful
      // need to add ratings somehow, probably easiest to do it through the listing itself with another content field
      // TODO: find overlap% between the buyer and possible sellers
      onTap: () {
        setState(() {
          // Toggle expansion - if it's already expanded, collapse it
          _expandedListingId = isExpanded ? null : listing.id;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main list tile content
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${listing.timeStart.hour}:${listing.timeStart.minute.toString().padLeft(2, '0')} to ${listing.timeEnd.hour}:${listing.timeEnd.minute.toString().padLeft(2, '0')} @ ${listing.diningHall}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            // Expandable dropdown content
            if (isExpanded)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 1),
                    SizedBox(height: 8),
                    // Add more listing details here
                    Text(
                      "Seller ID: ${listing.sellerId}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      // TODO: Get price from listing
                      "Price: \$N/A",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    // Add more fields as needed
                    SizedBox(height: 12),
                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleListingSelection(listing),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            192,
                            131,
                            199,
                            255,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text("Select This Listing", style: SubTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleListingSelection(Listing listing) async {
    try {
      final orderService = OrderService();
      await orderService.makeTransaction(
        listingId: listing.id,
        date: widget.date,
        time: null,
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e, s) {
      // Handle the error and stack trace
      print('Error: $e');
      print('Stack: $s');
      // You might want to show a SnackBar or dialog to inform the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to process order: ${e}')));
    }
  }

  Filter _buildListingsFilter() {
    final startDate = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
    );

    final endDate = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day + 1,
    );

    return Filter.and(
      Filter('diningHall', whereIn: widget.locations),
      Filter('sellerId', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid),
      // Date filtering
      Filter(
        'transactionDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      ),
      Filter('transactionDate', isLessThan: Timestamp.fromDate(endDate)),
      // Time overlap filtering
      Filter(
        'timeStart',
        isLessThanOrEqualTo: Listing.toMinutes(widget.endTime),
      ),
      Filter(
        'timeEnd',
        isGreaterThanOrEqualTo: Listing.toMinutes(widget.startTime),
      ),
    );
  }
}
