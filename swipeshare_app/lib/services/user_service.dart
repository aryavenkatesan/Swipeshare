import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> updatePaymentTypes(
    String uid,
    List<String> paymentTypes,
  ) async => await updateUserData(uid, {'payment_types': paymentTypes});

  Future<void> updateStarRating(
    String uid,
    int incomingStar, {
    Transaction? transaction,
  }) async {
    final user = await getUserData(uid, transaction: transaction);
    double calculatedStarRating =
        ((user.transactionsCompleted * user.stars) + incomingStar) /
        (user.transactionsCompleted + 1);
    //this is the true raw score, the initial 5 is not considered
    //also yes there are edge cases depending on who rates first,
    await updateUserData(uid, {'stars': calculatedStarRating}, transaction: transaction);
  }

  Future<void> incrementTransactionCount({Transaction? transaction}) async {
    final currentUser = await getCurrentUser(transaction: transaction);
    int incrementedTransactionNumber = (currentUser.transactionsCompleted + 1);
    await updateUserData(
      currentUser.id,
      {'transactions_completed': incrementedTransactionNumber},
      transaction: transaction,
    );
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

    await _firestore.collection('feedback').add({
      'userId': currentUser.uid,
      'userEmail': currentUser.email,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAccount() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      final currentUserId = currentUser.uid;
      const deletedName = 'Deleted User';
      const deletedEmail = 'deleted@deleted.com';

      // 1. Anonymize listings (set to cancelled only if currently active)
      final listingsSnapshot = await _firestore
          .collection('listings')
          .where('sellerId', isEqualTo: currentUserId)
          .get();

      if (listingsSnapshot.docs.isNotEmpty) {
        final listingsBatch = _firestore.batch();
        for (final doc in listingsSnapshot.docs) {
          final data = doc.data();
          final isActive = data['status'] == ListingStatus.active.name;
          listingsBatch.update(doc.reference, {
            'sellerName': deletedName,
            if (isActive) 'status': ListingStatus.cancelled.name,
          });
        }
        await listingsBatch.commit();
      }

      // 2. Anonymize orders as seller and their messages
      final ordersAsSellerSnapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: currentUserId)
          .get();

      for (final doc in ordersAsSellerSnapshot.docs) {
        // Anonymize messages from this user
        final messagesSnapshot = await doc.reference
            .collection('messages')
            .where('senderId', isEqualTo: currentUserId)
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          final messagesBatch = _firestore.batch();
          for (final msgDoc in messagesSnapshot.docs) {
            messagesBatch.update(msgDoc.reference, {
              'senderName': deletedName,
              'senderEmail': deletedEmail,
            });
          }
          await messagesBatch.commit();
        }

        // Anonymize the order
        await doc.reference.update({'sellerName': deletedName});
      }

      // 3. Anonymize orders as buyer and their messages
      final ordersAsBuyerSnapshot = await _firestore
          .collection('orders')
          .where('buyerId', isEqualTo: currentUserId)
          .get();

      for (final doc in ordersAsBuyerSnapshot.docs) {
        // Anonymize messages from this user
        final messagesSnapshot = await doc.reference
            .collection('messages')
            .where('senderId', isEqualTo: currentUserId)
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          final messagesBatch = _firestore.batch();
          for (final msgDoc in messagesSnapshot.docs) {
            messagesBatch.update(msgDoc.reference, {
              'senderName': deletedName,
              'senderEmail': deletedEmail,
            });
          }
          await messagesBatch.commit();
        }

        // Anonymize the order
        await doc.reference.update({'buyerName': deletedName});
      }

      // 4. Anonymize reports where user is reporter
      final reportsAsReporterSnapshot = await _firestore
          .collection('reports')
          .where('reporterId', isEqualTo: currentUserId)
          .get();

      if (reportsAsReporterSnapshot.docs.isNotEmpty) {
        final reportsBatch = _firestore.batch();
        for (final doc in reportsAsReporterSnapshot.docs) {
          reportsBatch.update(doc.reference, {'reporterEmail': deletedEmail});
        }
        await reportsBatch.commit();
      }

      // 5. Anonymize reports where user is reported
      final reportsAsReportedSnapshot = await _firestore
          .collection('reports')
          .where('reportedId', isEqualTo: currentUserId)
          .get();

      if (reportsAsReportedSnapshot.docs.isNotEmpty) {
        final reportsBatch = _firestore.batch();
        for (final doc in reportsAsReportedSnapshot.docs) {
          reportsBatch.update(doc.reference, {'reportedEmail': deletedEmail});
        }
        await reportsBatch.commit();
      }

      // 6. Anonymize feedback
      final feedbackSnapshot = await _firestore
          .collection('feedback')
          .where('userId', isEqualTo: currentUserId)
          .get();

      if (feedbackSnapshot.docs.isNotEmpty) {
        final feedbackBatch = _firestore.batch();
        for (final doc in feedbackSnapshot.docs) {
          feedbackBatch.update(doc.reference, {'userEmail': deletedEmail});
        }
        await feedbackBatch.commit();
      }

      // 7. Archive user document with anonymized PII
      await _firestore.collection('users').doc(currentUserId).update({
        'status': UserStatus.deleted.name,
        'name': deletedName,
        'email': deletedEmail,
        'referral_email': '',
        'verificationCode': null,
        'payment_types': [],
        'blocked_users': [],
      });

      // 8. Delete Firebase Auth user (absolute last)
      await currentUser.delete();

      debugPrint('Account successfully archived');
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
      debugPrint('Error archiving account: $e');
      throw Exception('Failed to delete account: $e');
    }
  }
}
