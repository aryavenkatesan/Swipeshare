import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/services/user_service.dart';

class ListingService {
  ListingService._();
  static final instance = ListingService._();

  final UserService _userService = UserService.instance;
  CollectionReference<Listing> get listingCol => FirebaseFirestore.instance
      .collection("listings")
      .withConverter(
        fromFirestore: (snap, _) => Listing.fromFirestore(snap),
        toFirestore: (listing, _) => listing.toMap(),
      );

  Future<void> postListing(
    String diningHall,
    TimeOfDay timeStart,
    TimeOfDay timeEnd,
    DateTime transactionDate,
    List<String> paymentTypes,
  ) async {
    final currentUser = await _userService.getCurrentUser();
    final currentUserName = currentUser.name;
    final currentUserRating = currentUser.stars;

    final now = DateTime.now();
    final listingDateTime = DateTime(
      transactionDate.year,
      transactionDate.month,
      transactionDate.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    );

    final newListing = Listing(
      id: '',
      sellerId: currentUser.id,
      sellerName: currentUserName,
      diningHall: diningHall,
      timeStart: timeStart,
      timeEnd: timeEnd,
      transactionDate: listingDateTime,
      sellerRating: currentUserRating,
      paymentTypes: paymentTypes,
      status: ListingStatus.active,
    );

    await listingCol.add(newListing);
  }

  Future<Listing> getListingById(
    String docId, {
    Transaction? transaction,
  }) async {
    final docRef = listingCol.doc(docId);

    final snapshot = transaction != null
        ? await transaction.get(docRef)
        : await docRef.get();

    return snapshot.data()!;
  }

  Future<void> updateListingStatus(
    String docId,
    ListingStatus newStatus, {
    Transaction? transaction,
  }) async {
    final docRef = listingCol.doc(docId);
    final updateMap = {'status': newStatus.name};
    if (transaction != null) {
      transaction.update(docRef, updateMap);
    } else {
      await docRef.update(updateMap);
    }
  }
}
