import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  Widget build(BuildContext context) {
    return Consumer3<ListingProvider, OrderProvider, UserProvider>(
      builder: (context, listingProvider, orderProvider, userProvider, child) {
        return Scaffold(
          appBar: AppBar(title: Text("View Listings")),
          body: _buildUserList(listingProvider, orderProvider, userProvider),
        );
      },
    );
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList(
    ListingProvider listingProvider,
    OrderProvider orderProvider,
    UserProvider userProvider,
  ) {
    if (listingProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle error state
    if (listingProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading listings: ${listingProvider.error}'),
            ElevatedButton(
              onPressed: () => listingProvider.ensureInitialized(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Filter listings based on your criteria
    final filteredListings = listingProvider.listings.where((listing) {
      // Only show listings that match the selected locations
      // TODO: Add other filtering logic here (PaymentType, date, etc.)
      return widget.locations.contains(listing.diningHall) &&
          listing.sellerId != userProvider.currentUser!.id &&
          DateTime(widget.date.year, widget.date.month, widget.date.day) ==
              DateTime(widget.date.year, widget.date.month, widget.date.day);
    }).toList();

    // Handle empty state
    if (filteredListings.isEmpty) {
      return const Center(
        child: Text('No listings found for the selected criteria'),
      );
    }

    // Build the list
    return ListView.builder(
      itemCount: filteredListings.length,
      itemBuilder: (context, index) {
        final listing = filteredListings[index];
        return _buildUserListItem(listing, orderProvider);
      },
    );
  }

  // build individual user list items
  Widget _buildUserListItem(Listing listing, OrderProvider orderProvider) {
    // display all listings with a selection location
    return ListTile(
      // change this from a listTile to a custom componenent that will take arguments and spit out smth beautiful
      // need to add ratings somehow, probably easiest to do it through the listing itself with another content field
      // TODO: find overlap% between the buyer and possible sellers
      title: Text(
        "${listing.timeStart.hour}:${listing.timeStart.minute.toString().padLeft(2, '0')} to ${listing.timeEnd.hour}:${listing.timeEnd.minute.toString().padLeft(2, '0')} @ ${listing.diningHall}",
      ),
      onTap: () async {
        try {
          await orderProvider.makeTransaction(listing.id, widget.date);
          if (mounted) {
            Navigator.pop(context);
            Navigator.pop(context);
          }
        } catch (e, s) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create order: $e')),
            );
          }
          print('Error: $e');
          print('Stack: $s');
        }
      },
    );
  }
}
