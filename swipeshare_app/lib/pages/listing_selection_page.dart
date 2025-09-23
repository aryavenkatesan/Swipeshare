import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/auth.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/providers/listing_provider.dart';
import 'package:swipeshare_app/providers/order_provider.dart';
import 'package:swipeshare_app/providers/user_provider.dart';

class ListingSelectionPage extends StatefulWidget {
  final List<String> locations;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const ListingSelectionPage({
    super.key,
    required this.locations,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

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
        child: _buildUserList(context),
      ),
    );
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList(BuildContext context) {
    return Consumer3<ListingProvider, UserProvider, OrderProvider>(
      builder: (context, listingProvider, userProvider, orderProvider, child) {
        if (listingProvider.error != null || userProvider.error != null) {
          return const Text('error');
        }

        if (listingProvider.isLoading || userProvider.isLoading) {
          return const Text('loading..');
        }

        return ListView(
          children: listingProvider.listings
              .map<Widget>(
                (listing) =>
                    _buildUserListItem(listing, userProvider.currentUser!),
              )
              .toList(),
        );
      },
    );
  }

  // build individual user list items
  Widget _buildUserListItem(Listing listing, User user) {
    final bool isExpanded = _expandedListingId == listing.id;

    // display all listings with a selection location
    // TODO: add PaymentType filtering here
    // TODO: add a date selector and only display the listings on that date
    if (widget.locations.contains(listing.diningHall) &&
        user.id != listing.sellerId &&
        DateTime(widget.date.year, widget.date.month, widget.date.day) ==
            DateTime(
              listing.transactionDate.year,
              listing.transactionDate.month,
              listing.transactionDate.day,
            )) {
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
                          child: Text(
                            "Select This Listing",
                            style: SubTextStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> _handleListingSelection(
    Listing listing,
    OrderProvider orderProvider,
  ) async {
    try {
      await orderProvider.makeTransaction(listing.id, widget.date);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e, s) {
      // Handle the error and stack trace
      print('Error: $e');
      print('Stack: $s');
      // You might want to show a SnackBar or dialog to inform the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to process order: $e')));
    }
  }
}
