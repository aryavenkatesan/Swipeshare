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
    double price,
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
      price: price,
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
  }) => updateListing(docId, status: newStatus, transaction: transaction);

  Future<void> deleteListing(String docId, {Transaction? transaction}) =>
      updateListing(
        docId,
        status: ListingStatus.cancelled,
        transaction: transaction,
      );

  Future<void> updateListing(
    String docId, {
    String? diningHall,
    TimeOfDay? timeStart,
    TimeOfDay? timeEnd,
    DateTime? transactionDate,
    List<String>? paymentTypes,
    double? price,
    ListingStatus? status,
    Transaction? transaction,
  }) async {
    final updates = <String, dynamic>{};
    if (diningHall != null) updates['diningHall'] = diningHall;
    if (timeStart != null) updates['timeStart'] = Listing.toMinutes(timeStart);
    if (timeEnd != null) updates['timeEnd'] = Listing.toMinutes(timeEnd);
    if (transactionDate != null) {
      updates['transactionDate'] = Timestamp.fromDate(
        DateTime(
          transactionDate.year,
          transactionDate.month,
          transactionDate.day,
        ),
      );
    }
    if (paymentTypes != null) updates['paymentTypes'] = paymentTypes;
    if (price != null) updates['price'] = price;
    if (status != null) updates['status'] = status.name;

    final docRef = listingCol.doc(docId);
    if (transaction != null) {
      transaction.update(docRef, updates);
    } else {
      await docRef.update(updates);
    }
  }
}
