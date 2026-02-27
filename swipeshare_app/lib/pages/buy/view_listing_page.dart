import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/listing_detail_card.dart';
import 'package:swipeshare_app/components/page_app_bar.dart';
import 'package:swipeshare_app/models/listing.dart';

class ViewListingPage extends StatelessWidget {
  final Listing listing;

  const ViewListingPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageAppBar(title: 'View Listing'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: ListingDetailCard(listing: listing),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9D9D9),
                disabledBackgroundColor: const Color(0xFFD9D9D9),
              ),
              child: const Text('Select Listing'),
            ),
          ),
        ],
      ),
    );
  }
}
