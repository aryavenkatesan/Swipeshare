import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/services/chat_service.dart';

class OrderService {
  OrderService._();
  static final instance = OrderService._();

  final _functions = FirebaseFunctions.instance;
  final _auth = FirebaseAuth.instance;

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

  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    Transaction? transaction,
  }) async {
    final docRef = orderCol.doc(orderId);
    final updateMap = {'status': newStatus.name};
    if (transaction != null) {
      transaction.update(docRef, updateMap);
    } else {
      await docRef.update(updateMap);
    }
  }

  Future<List<MealOrder>> getOrdersToRate() async {
    if (_auth.currentUser == null) return [];
    final currentUserId = _auth.currentUser!.uid;

    final ordersToRate = await orderCol
        .where('status', isEqualTo: OrderStatus.completed.name)
        .where(
          Filter.or(
            Filter("buyerId", isEqualTo: currentUserId),
            Filter("sellerId", isEqualTo: currentUserId),
          ),
        )
        .get();

    return ordersToRate.docs
        .map((doc) => doc.data())
        .where(
          (order) => switch (order.currentUserRole) {
            OrderRole.buyer => order.ratingByBuyer == null,
            OrderRole.seller => order.ratingBySeller == null,
          },
        )
        .toList();
  }

  Future<void> rateOrder(MealOrder orderData, Rating rating) async {
    final updateMap = rating.toMap();
    updateMap['timestamp'] = FieldValue.serverTimestamp();

    final field = switch (orderData.currentUserRole) {
      OrderRole.buyer => 'ratingByBuyer',
      OrderRole.seller => 'ratingBySeller',
    };

    await orderCol.doc(orderData.getRoomName()).update({field: updateMap});
    debugPrint("BOOOMMMMM");
  }

  // Future<void> closeOrder(MealOrder orderData, {required Rating rating}) async {
  //   final recieverId = switch (orderData.currentUserRole) {
  //     OrderRole.buyer => orderData.sellerId,
  //     OrderRole.seller => orderData.buyerId,
  //   };

  //   final updateMap = rating.toMap();
  //   updateMap['timestamp'] = FieldValue.serverTimestamp();

  //   final field = switch (orderData.currentUserRole) {
  //     OrderRole.buyer => 'ratingByBuyer',
  //     OrderRole.seller => 'ratingBySeller',
  //   };

  //   final docRef = orderCol.doc(orderData.getRoomName());

  //   await FirebaseFirestore.instance.runTransaction((transaction) async {
  //     // Update peer's star rating
  //     await _userService.updateStarRating(
  //       recieverId,
  //       rating.stars,
  //       transaction: transaction,
  //     );

  //     // Increment current user's transactions completed
  //     await _userService.incrementTransactionCount(transaction: transaction);

  //     // Update order document with rating
  //     transaction.update(docRef, {field: updateMap});
  //   });
  // }
}
