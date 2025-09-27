import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/providers/util/async_provider.dart';
import 'package:swipeshare_app/services/listing_service.dart';

class ListingProvider extends AsyncProvider {
  final ListingService _listingService;
  List<Listing> _listings = [];

  ListingProvider({ListingService? listingService})
    : _listingService = listingService ?? ListingService();

  List<Listing> get listings => _listings;

  @override
  @protected
  Future<void> initialize() async {
    _listings = await _listingService.fetchListings();
  }

  @override
  @protected
  Future<void> reset() async {
    _listings.clear();
  }

  Future<Listing> postListing(
    String diningHall,
    TimeOfDay startTime,
    TimeOfDay endTime,
    DateTime transactionDate,
  ) async {
    return executeOperation(() async {
      final listing = await _listingService.postListing(
        diningHall,
        startTime,
        endTime,
        transactionDate,
      );
      _listings.add(listing);
      return listing;
    });
  }
}
