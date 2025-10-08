import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';

class ListingService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<Listing> createListing({
    required String diningHall,
    required TimeOfDay timeStart,
    required TimeOfDay timeEnd,
    required DateTime transactionDate,
    Transaction? transaction,
  }) async {
    final newListingRef = _firestore.collection('listings').doc();

    final newListing = Listing(
      id: newListingRef.id,
      sellerId: _auth.currentUser!.uid,
      diningHall: diningHall,
      timeStart: timeStart,
      timeEnd: timeEnd,
      transactionDate: transactionDate,
    );

    if (transaction == null) {
      await newListingRef.set(newListing.toMap());
    } else {
      transaction.set(newListingRef, newListing.toMap());
    }

    return newListing;
  }

  Future<Listing> getListingById(
    String listngId, {
    Transaction? transaction,
  }) async {
    final doc = await (transaction != null
        ? transaction.get(_firestore.collection('listings').doc(listngId))
        : _firestore.collection('listings').doc(listngId).get());

    if (!doc.exists) {
      throw Exception("Listing with id $listngId not found");
    }

    return Listing.fromDoc(doc);
  }

  Widget listingStream({
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
              .map((doc) => Listing.fromDoc(doc))
              .toList();
        }

        return builder(context, listings, isLoading, error);
      },
    );
  }
}
