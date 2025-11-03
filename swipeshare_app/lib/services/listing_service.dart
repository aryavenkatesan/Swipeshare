import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/services/user_service.dart';

class ListingService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

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
    final String currentUserName = user!.name;
    final double currentUserRating = user.stars;

    final newListing = {
      "sellerId": currentUserId,
      "diningHall": diningHall,
      "timeStart": timeStart,
      "timeEnd": timeEnd,
      "transactionDate": transactionDate,
      "sellerName": currentUserName,
      "sellerRating": currentUserRating,
      "paymentTypes": paymentTypes,
    };

    await _fireStore.collection('listings').add(newListing);
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

  //DELETE LISTING
  Future<void> deleteListing(String docId) async {
    await _fireStore.collection('listings').doc(docId).delete();
  }
}
