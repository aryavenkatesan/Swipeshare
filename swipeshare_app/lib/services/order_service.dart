import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/services/chat_service.dart';
import 'package:swipeshare_app/services/listing_service.dart';
import 'package:swipeshare_app/services/user_service.dart';

class OrderService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final ListingService _listingService = ListingService();

  //POST ORDER
  Future<MealOrder> postOrder(Listing listing) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final user = await _userService.getUserData(currentUserId);

    if (user == null) {
      throw Exception(
        'User data not found for current user ID: $currentUserId',
      );
    }

    MealOrder newOrder = MealOrder(
      sellerId: listing.sellerId,
      buyerId: currentUserId,
      diningHall: listing.diningHall,
      transactionDate: listing.transactionDate,
      sellerName: listing.sellerName,
      buyerName: user.name,
      sellerStars: listing.sellerRating,
      buyerStars: user.stars,
      sellerHasNotifs: true,
      buyerHasNotifs: true,
    );

    try {
      await _fireStore.runTransaction((transaction) async {
        final orderRef = _fireStore
            .collection('orders')
            .doc(newOrder.getRoomName());

        // Check if listing still exists (prevents race conditions)
        final listingData = await _listingService.getListingById(
          listing.id,
          transaction: transaction,
        );
        if (listingData == null) {
          throw Exception('Listing no longer exists');
        }

        await _listingService.deleteListing(
          listing.id,
          transaction: transaction,
        );
        transaction.set(orderRef, newOrder.toMap());
      });

      // Send message after transaction to ensure order exists
      await ChatService(newOrder.getRoomName()).newOrderSystemMessage();

      return newOrder;
    } catch (e, s) {
      debugPrint('Error: $e');
      debugPrint('Stack: $s');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getOrders(String userId) {
    return _fireStore
        .collection('orders')
        .where(
          Filter.or(
            Filter.and(
              Filter('sellerId', isEqualTo: userId),
              Filter('sellerVisibility', isEqualTo: true),
            ),
            Filter.and(
              Filter('buyerId', isEqualTo: userId),
              Filter('buyerVisibility', isEqualTo: true),
            ),
          ),
        )
        .snapshots();
  }

  Future<MealOrder?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await _fireStore
          .collection('orders')
          .doc(orderId)
          .get();

      if (doc.exists) {
        return MealOrder.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        debugPrint('No such order with id: $orderId');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching order by id: $e');
      return null;
    }
  }

  Future<void> updateOrderTime(
    String orderId,
    TimeOfDay? newTime, {
    Transaction? transaction,
  }) async {
    final String? timeString = newTime?.toString();

    final docRef = _fireStore.collection('orders').doc(orderId);

    if (transaction != null) {
      transaction.update(docRef, {"displayTime": timeString});
    } else {
      await docRef.update({"displayTime": timeString});
    }
  }

  Future<void> updateVisibility(
    MealOrder orderData, {
    bool deletedChat = false,
  }) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final updateMap = <String, dynamic>{};

    if (currentUserId == orderData.buyerId) {
      //set buyer visibility to false
      updateMap['buyerVisibility'] = false;
      updateMap['buyerHasNotifs'] = false;
    } else {
      //set seller visibility to false
      updateMap['sellerVisibility'] = false;
      updateMap['sellerHasNotifs'] = false;
    }

    if (deletedChat) {
      updateMap['chatDeleted'] = true;
    }

    await _fireStore
        .collection('orders')
        .doc(orderData.getRoomName())
        .update(updateMap);
  }
}
