import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/user.dart';

class UserService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get user data once (static)
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _fireStore.collection('users').doc(uid).get();
      debugPrint('Fetched user data for UID $uid: ${doc.data()}');

      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Get current logged-in user
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return null;

    return await getUserData(currentUser.uid);
  }

  // Optional: Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _fireStore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  Future<void> updatePaymentTypes(String uid, List<String> paymentTypes) async {
    try {
      await _fireStore.collection('users').doc(uid).update({
        'payment_types': paymentTypes,
      });
    } catch (e) {
      print('Error updating payment types: $e');
    }
  }

  Future<void> updateStarRating(String uid, int incomingStar) async {
    try {
      final userDoc = await _fireStore.collection('users').doc(uid).get();
      final userData = userDoc.data()!;
      double calculatedStarRating =
          ((userData['transactions_completed'] * userData['stars']) +
              incomingStar) /
          (userData['transactions_completed'] + 1);
      //this is the true raw score, the initial 5 is not considered
      //also yes there are edge cases depending on who rates first,
      await _fireStore.collection('users').doc(uid).update({
        'stars': calculatedStarRating,
      });
    } catch (e) {
      print('Error updating star rating: $e');
    }
  }

  Future<void> incrementTransactionCount() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await _fireStore
          .collection('users')
          .doc(currentUserId)
          .get();
      final userData = userDoc.data()!;
      int incrementedTransactionNumber =
          (userData['transactions_completed'] + 1);
      await _fireStore.collection('users').doc(currentUserId).update({
        'transactions_completed': incrementedTransactionNumber,
      });
    } catch (e) {
      print('Error updating star rating: $e');
    }
  }

  Future<void> blockUser(MealOrder orderData) async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final String otherUserId = orderData.buyerId != currentUserId
          ? orderData.buyerId
          : orderData.sellerId;
      final userDoc = await _fireStore
          .collection('users')
          .doc(currentUserId)
          .get();
      final userData = userDoc.data()!;
      int appendedBlockList = (userData['blocked_users'].add(otherUserId));
      await _fireStore.collection('users').doc(currentUserId).update({
        'blocked_users': appendedBlockList,
      });
    } catch (e) {
      print('Error blocking user: $e');
      rethrow;
    }
  }
}
