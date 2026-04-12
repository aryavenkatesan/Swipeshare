import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/user.dart';

class UserService {
  UserService._();
  static final instance = UserService._();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<UserModel> getUserData(String uid, {Transaction? transaction}) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final doc = transaction != null
          ? await transaction.get(docRef)
          : await docRef.get();
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      rethrow;
    }
  }

  Future<UserModel> getCurrentUser({Transaction? transaction}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently signed in');
    }
    return await getUserData(currentUser.uid, transaction: transaction);
  }

  Future<void> updateUserData(
    String uid,
    Map<String, dynamic> data, {
    Transaction? transaction,
  }) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);
      if (transaction != null) {
        transaction.update(docRef, data);
      } else {
        await docRef.update(data);
      }
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    }
  }

  Future<void> updatePaymentTypes(String uid, List<String> paymentTypes) =>
      updateUserData(uid, {'payment_types': paymentTypes});

  Future<void> updateNotificationPreferences(
    String uid,
    NotifSettings notifSettings,
  ) => updateUserData(uid, {'notifSettings': notifSettings.toMap()});

  Future<void> blockUser(MealOrder orderData) async {
    final currentUser = await getCurrentUser();
    final String otherUserId = orderData.them.id;

    if (currentUser.blockedUsers.contains(otherUserId)) {
      return;
    }

    final appendedBlockList = currentUser.blockedUsers..add(otherUserId);
    await updateUserData(currentUser.id, {'blocked_users': appendedBlockList});
  }

  Future<void> banUser(String uid) async {
    await updateUserData(uid, {'status': UserStatus.banned.name});

    // Cancel the banned user's active listings
    final listingsSnapshot = await _firestore
        .collection('listings')
        .where('sellerId', isEqualTo: uid)
        .where('status', isEqualTo: ListingStatus.active.name)
        .get();

    if (listingsSnapshot.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (final doc in listingsSnapshot.docs) {
        batch.update(doc.reference, {'status': ListingStatus.cancelled.name});
      }
      await batch.commit();
    }
  }

  Future<void> unbanUser(String uid) =>
      updateUserData(uid, {'status': UserStatus.active.name});

  Future<void> sendFeedback(String message) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    await _firestore.collection('feedback').add({
      'userId': currentUser.uid,
      'userEmail': currentUser.email,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Replace the entire deleteAccount() body with:
  Future<void> deleteAccount() async {
    try {
      await FirebaseFunctions.instance.httpsCallable('deleteAccount').call();
      // The CF deletes the Auth record server-side. Sign out explicitly so the
      // client state is cleared — calling reload() would throw user-not-found.
      await FirebaseAuth.instance.signOut();
    } on FirebaseFunctionsException catch (e) {
      if (e.message?.contains('requires-recent-login') ?? false) {
        throw Exception('Please sign in again before deleting your account');
      }
      throw Exception(e.message ?? 'Failed to delete account');
    }
  }
}
