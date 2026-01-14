import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/services/chat_service.dart';

class OrderService extends ChangeNotifier {
  OrderService._();
  static final instance = OrderService._();

  final _auth = FirebaseAuth.instance;
  final _functions = FirebaseFunctions.instance;

  CollectionReference<MealOrder> get orderCol => FirebaseFirestore.instance
      .collection('orders')
      .withConverter(
        fromFirestore: (snap, _) => MealOrder.fromFirestore(snap),
        toFirestore: (order, _) => order.toMap(),
      );

  Future<MealOrder> postOrder(Listing listing) async {
    try {
      final result = await _functions
          .httpsCallable('createOrderFromListing')
          .call({'listingId': listing.id});

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

  Future<MealOrder> getOrderById(String orderId) async =>
      await orderCol.doc(orderId).get().then((s) => s.data()!);

  Future<void> updateOrderTime(
    String orderId,
    TimeOfDay? newTime, {
    Transaction? transaction,
  }) async {
    final String? timeString = newTime?.toString();

    final docRef = orderCol.doc(orderId);

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
    final String currentUserId = _auth.currentUser!.uid;
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

    await orderCol
        .doc(orderData.getRoomName())
        .update(updateMap);
  }
}
