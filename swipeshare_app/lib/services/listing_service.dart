import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/services/user_service.dart';

class ListingService {
  ListingService._();
  static final instance = ListingService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService.instance;

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
    );

    await _firestore.collection('listings').add(newListing.toMap());
  }

  Widget listingStreamBuilder({
    required Widget Function(
      BuildContext context,
      List<Listing> listings,
      bool isLoading,
      Object? error,
    )
    builder,
    Filter? filter,
  }) {
    Query query = _firestore.collection('listings');
    if (filter != null) {
      query = query.where(filter);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final error = snapshot.error;

        List<Listing> listings = [];
        if (snapshot.hasData) {
          listings = snapshot.data!.docs
              .map((doc) => Listing.fromFirestore(doc))
              .toList();
        }

        return builder(context, listings, isLoading, error);
      },
    );
  }

  Future<Listing> getListingById(
    String docId, {
    Transaction? transaction,
  }) async {
    final docRef = _firestore.collection('listings').doc(docId);
    if (transaction != null) {
      final docSnapshot = await transaction.get(docRef);
      return Listing.fromFirestore(docSnapshot);
    }

    final doc = await docRef.get();
    return Listing.fromFirestore(doc);
  }

  Future<void> deleteListing(String docId, {Transaction? transaction}) async {
    final docRef = _firestore.collection('listings').doc(docId);
    if (transaction != null) {
      transaction.delete(docRef);
    } else {
      await docRef.delete();
    }
  }
}
