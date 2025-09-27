import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/core/network/api_client.dart';
import 'package:swipeshare_app/models/listing.dart';

class ListingService {
  final Dio _apiClient;

  ListingService({Dio? dio}) : _apiClient = dio ?? apiClient;

  /// Create a new listing
  Future<Listing> postListing(
    String diningHall,
    TimeOfDay timeStart,
    TimeOfDay timeEnd,
    DateTime transactionDate,
  ) async {
    final newListing = ListingCreate(
      diningHall: diningHall,
      timeStart: timeStart,
      timeEnd: timeEnd,
      transactionDate: transactionDate,
    );

    final response = await _apiClient.post(
      '/listings',
      data: newListing.toMap(),
    );
    return Listing.fromJson(response.data);
  }

  /// Get all listings with optional filters
  Future<List<Listing>> fetchListings({Map<String, dynamic>? filters}) async {
    final response = await _apiClient.get(
      '/listings',
      queryParameters: filters,
    );
    return (response.data as List)
        .map((listing) => Listing.fromJson(listing))
        .toList();
  }

  /// Get a specific listing by ID
  Future<Listing> getListingById(String listingId) async {
    final response = await _apiClient.get('/listings/$listingId');
    return Listing.fromJson(response.data);
  }

  /// Update an existing listing
  Future<Listing> updateListing(
    String listingId,
    String diningHall,
    TimeOfDay timeStart,
    TimeOfDay timeEnd,
    DateTime transactionDate,
  ) async {
    final updatedListing = ListingCreate(
      diningHall: diningHall,
      timeStart: timeStart,
      timeEnd: timeEnd,
      transactionDate: transactionDate,
    );

    final response = await _apiClient.put(
      '/listings/$listingId',
      data: updatedListing.toMap(),
    );
    return Listing.fromJson(response.data);
  }

  /// Delete a listing (DELETE /api/listings/{id})
  Future<Listing> deleteListing(String listingId) async {
    final response = await _apiClient.delete('/listings/$listingId');
    return Listing.fromJson(response.data);
  }

  // Convenience methods for common filtering scenarios

  /// Get listings filtered by multiple criteria
  Future<List<Listing>> getFilteredListings({
    String? diningHall,
    DateTime? transactionDate,
    int? timeStart,
    int? timeEnd,
  }) async {
    final filters = <String, dynamic>{};

    if (diningHall != null) filters['dining_hall'] = diningHall;
    if (transactionDate != null) {
      filters['transaction_date'] = transactionDate.toIso8601String();
    }
    if (timeStart != null) filters['time_start'] = timeStart.toString();
    if (timeEnd != null) filters['time_end'] = timeEnd.toString();

    return fetchListings(filters: filters.isNotEmpty ? filters : null);
  }

  /// Get listings filtered by dining hall
  Future<List<Listing>> getListingsByDiningHall(String diningHall) async {
    return getFilteredListings(diningHall: diningHall);
  }

  /// Get listings filtered by transaction date
  Future<List<Listing>> getListingsByDate(DateTime date) async {
    return getFilteredListings(transactionDate: date);
  }
}
