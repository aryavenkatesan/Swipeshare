import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/user.dart';

class UserService {
  UserService._();
  static final instance = UserService._();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      rethrow;
    }
  }

  Future<UserModel> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently signed in');
    }
    return await getUserData(currentUser.uid);
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    }
  }

  Future<void> updatePaymentTypes(
    String uid,
    List<String> paymentTypes,
  ) async => await updateUserData(uid, {'payment_types': paymentTypes});

  Future<void> updateStarRating(String uid, int incomingStar) async {
    final user = await getUserData(uid);
    double calculatedStarRating =
        ((user.transactionsCompleted * user.stars) + incomingStar) /
        (user.transactionsCompleted + 1);
    //this is the true raw score, the initial 5 is not considered
    //also yes there are edge cases depending on who rates first,
    await updateUserData(uid, {'stars': calculatedStarRating});
  }

  Future<void> incrementTransactionCount() async {
    final currentUser = await getCurrentUser();
    int incrementedTransactionNumber = (currentUser.transactionsCompleted + 1);
    await updateUserData(currentUser.id, {
      'transactions_completed': incrementedTransactionNumber,
    });
  }

  Future<void> blockUser(MealOrder orderData) async {
    final currentUser = await getCurrentUser();
    final String otherUserId = orderData.buyerId != currentUser.id
        ? orderData.buyerId
        : orderData.sellerId;

    if (currentUser.blockedUsers.contains(otherUserId)) {
      return;
    }

    final appendedBlockList = currentUser.blockedUsers..add(otherUserId);
    await updateUserData(currentUser.id, {'blocked_users': appendedBlockList});
  }

  Future<void> sendFeedback(String message) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    await _fireStore.collection('feedback').add({
      'userId': currentUser.uid,
      'userEmail': currentUser.email,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAccount() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      final String currentUserId = currentUser.uid;

      // 1. Delete listings
      final QuerySnapshot listingsSnapshot = await _firestore
          .collection('listings')
          .where('sellerId', isEqualTo: currentUserId)
          .get();

      if (listingsSnapshot.docs.isNotEmpty) {
        final WriteBatch listingsBatch = _firestore.batch();
        for (final DocumentSnapshot doc in listingsSnapshot.docs) {
          listingsBatch.delete(doc.reference);
        }
        await listingsBatch.commit();
      }

      // 2. Delete orders as seller (with messages)
      final QuerySnapshot ordersAsSellerSnapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: currentUserId)
          .get();

      for (final DocumentSnapshot doc in ordersAsSellerSnapshot.docs) {
        // Delete messages subcollection
        final messagesSnapshot = await doc.reference
            .collection('messages')
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          final messagesBatch = _firestore.batch();
          for (final msgDoc in messagesSnapshot.docs) {
            messagesBatch.delete(msgDoc.reference);
          }
          await messagesBatch.commit();
        }

        // Delete the order
        await doc.reference.delete();
      }

      // 3. Delete orders as buyer (with messages)
      final QuerySnapshot ordersAsBuyerSnapshot = await _firestore
          .collection('orders')
          .where('buyerId', isEqualTo: currentUserId)
          .get();

      for (final DocumentSnapshot doc in ordersAsBuyerSnapshot.docs) {
        // Delete messages subcollection
        final messagesSnapshot = await doc.reference
            .collection('messages')
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          final messagesBatch = _firestore.batch();
          for (final msgDoc in messagesSnapshot.docs) {
            messagesBatch.delete(msgDoc.reference);
          }
          await messagesBatch.commit();
        }

        // Delete the order
        await doc.reference.delete();
      }

      // 4. Delete user document (second to last)
      await _firestore.collection('users').doc(currentUserId).delete();

      // 5. Delete Firebase Auth user (absolute last)
      await currentUser.delete();

      debugPrint('Account successfully deleted');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Please sign in again before deleting your account');
      }
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      throw Exception('Authentication error: ${e.message}');
    } on FirebaseException catch (e) {
      debugPrint('Firestore Error: ${e.code} - ${e.message}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      debugPrint('Error deleting account: $e');
      throw Exception('Failed to delete account: $e');
    }
  }
}
