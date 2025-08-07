import 'package:swipeshare_app/models/listing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListingService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //POST LISTING
  Future<void> postListing(
    String diningHall,
    TimeOfDay timeStart,
    TimeOfDay timeEnd,
    DateTime transactionDate,
  ) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    Listing newListing = Listing(
      sellerId: currentUserId,
      diningHall: diningHall,
      timeStart: timeStart,
      timeEnd: timeEnd,
      transactionDate: transactionDate,
      //rating
      //payment types
    );

    await _fireStore.collection('listings').add(newListing.toMap());
  }

  //GET ALL LISTINGS
  Stream<QuerySnapshot> getListings() {
    return _fireStore.collection('listings').snapshots();
  }

  //DELETE LISTING
}
