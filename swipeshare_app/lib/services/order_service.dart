import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/services/chat_service.dart';

class OrderService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  //POST ORDER
  Future<MealOrder> postOrder(Listing listing) async {
    try {
      final result = await _functions.httpsCallable('createOrderFromListing').call({
        'listingId': listing.id,
      });

      final orderData = result.data as Map<String, dynamic>;
      final newOrder = MealOrder.fromMap(orderData);

      await ChatService(newOrder.getRoomName()).newOrderSystemMessage();

      return newOrder;
    } catch (e, s) {
      debugPrint('Error creating order: $e');
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
