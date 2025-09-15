import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/core/network/api_client.dart';
import 'package:swipeshare_app/models/listing.dart';

class ListingService {
  final Dio _apiClient;

  ListingService({Dio? dio}) : _apiClient = dio ?? apiClient;

  //POST LISTING
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

  //GET ALL LISTINGS
  Future<List<Listing>> fetchListings() async {
    final response = await _apiClient.get('/listings');
    return (response.data as List)
        .map((listing) => Listing.fromJson(listing))
        .toList();
  }

  //DELETE LISTING
  Future<Listing> deleteListing(String docId) async {
    final response = await _apiClient.delete('/listings/$docId');
    return Listing.fromJson(response.data);
  }
}
