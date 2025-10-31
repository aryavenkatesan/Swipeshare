import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/user.dart';

class UserService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get user data once (static)
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _fireStore.collection('users').doc(uid).get();

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

  Future<void> deleteAccount() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      final String currentUserId = currentUser.uid;

      // 1. Delete listings
      final QuerySnapshot listingsSnapshot = await _fireStore
          .collection('listings')
          .where('sellerId', isEqualTo: currentUserId)
          .get();

      if (listingsSnapshot.docs.isNotEmpty) {
        final WriteBatch listingsBatch = _fireStore.batch();
        for (final DocumentSnapshot doc in listingsSnapshot.docs) {
          listingsBatch.delete(doc.reference);
        }
        await listingsBatch.commit();
      }

      // 2. Delete orders as seller (with messages)
      final QuerySnapshot ordersAsSellerSnapshot = await _fireStore
          .collection('orders')
          .where('sellerId', isEqualTo: currentUserId)
          .get();

      for (final DocumentSnapshot doc in ordersAsSellerSnapshot.docs) {
        // Delete messages subcollection
        final messagesSnapshot = await doc.reference
            .collection('messages')
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          final messagesBatch = _fireStore.batch();
          for (final msgDoc in messagesSnapshot.docs) {
            messagesBatch.delete(msgDoc.reference);
          }
          await messagesBatch.commit();
        }

        // Delete the order
        await doc.reference.delete();
      }

      // 3. Delete orders as buyer (with messages)
      final QuerySnapshot ordersAsBuyerSnapshot = await _fireStore
          .collection('orders')
          .where('buyerId', isEqualTo: currentUserId)
          .get();

      for (final DocumentSnapshot doc in ordersAsBuyerSnapshot.docs) {
        // Delete messages subcollection
        final messagesSnapshot = await doc.reference
            .collection('messages')
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          final messagesBatch = _fireStore.batch();
          for (final msgDoc in messagesSnapshot.docs) {
            messagesBatch.delete(msgDoc.reference);
          }
          await messagesBatch.commit();
        }

        // Delete the order
        await doc.reference.delete();
      }

      // 4. Delete user document (second to last)
      await _fireStore.collection('users').doc(currentUserId).delete();

      // 5. Delete Firebase Auth user (absolute last)
      await currentUser.delete();

      print('Account successfully deleted');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Please sign in again before deleting your account');
      }
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw Exception('Authentication error: ${e.message}');
    } on FirebaseException catch (e) {
      print('Firestore Error: ${e.code} - ${e.message}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('Error deleting account: $e');
      throw Exception('Failed to delete account: $e');
    }
  }
}
