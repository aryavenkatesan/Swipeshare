import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/services/user_service.dart';

class ListingService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserService _userService = UserService.instance;

  //POST LISTING
  Future<void> postListing(
    String diningHall,
    TimeOfDay timeStart,
    TimeOfDay timeEnd,
    DateTime transactionDate,
    List<String> paymentTypes,
  ) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final user = await _userService.getUserData(currentUserId);
    final String currentUserName = user.name;
    final double currentUserRating = user.stars;

    final DateTime now = DateTime.now();
    final DateTime listingDateTime = DateTime(
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
      sellerId: currentUserId,
      sellerName: currentUserName,
      diningHall: diningHall,
      timeStart: timeStart,
      timeEnd: timeEnd,
      transactionDate: listingDateTime,
      sellerRating: currentUserRating,
      paymentTypes: paymentTypes,
    );

    await _fireStore.collection('listings').add(newListing.toMap());
  }

  //GET ALL LISTINGS
  Stream<QuerySnapshot> getListings() {
    return _fireStore.collection('listings').snapshots();
  }

  //GET USER'S LISTINGS
  Stream<QuerySnapshot> getUserListings() {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    return _fireStore
        .collection('listings')
        .where(Filter('sellerId', isEqualTo: currentUserId))
        .snapshots();
  }

  //GET LISTING BY ID
  Future<Map<String, dynamic>?> getListingById(
    String docId, {
    Transaction? transaction,
  }) async {
    final docRef = _fireStore.collection('listings').doc(docId);
    if (transaction != null) {
      final docSnapshot = await transaction.get(docRef);
      return docSnapshot.data();
    }

    final doc = await docRef.get();
    return doc.data();
  }

  //DELETE LISTING
  Future<void> deleteListing(String docId, {Transaction? transaction}) async {
    final docRef = _fireStore.collection('listings').doc(docId);
    if (transaction != null) {
      transaction.delete(docRef);
    } else {
      await docRef.delete();
    }
  }
}
