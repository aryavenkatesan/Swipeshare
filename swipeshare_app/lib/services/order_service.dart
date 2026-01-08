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
  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;

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

  Stream<QuerySnapshot> getOrders(String userId) {
    return _firestore
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

  Widget orderStreamBuilder({
    required Widget Function(
      BuildContext context,
      List<MealOrder> orders,
      bool isLoading,
      Object? error,
    )
    builder,
    Filter? filter,
  }) {
    Query query = _firestore.collection('orders');
    if (filter != null) {
      query = query.where(filter);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final error = snapshot.error;

        List<MealOrder> orders = [];
        if (snapshot.hasData) {
          orders = snapshot.data!.docs
              .map((doc) => MealOrder.fromFirestore(doc))
              .toList();
        }

        return builder(context, orders, isLoading, error);
      },
    );
  }

  Future<MealOrder> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('orders')
          .doc(orderId)
          .get();

      return MealOrder.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching order by id: $e');
      rethrow;
    }
  }

  Future<void> updateOrderTime(
    String orderId,
    TimeOfDay? newTime, {
    Transaction? transaction,
  }) async {
    final String? timeString = newTime?.toString();

    final docRef = _firestore.collection('orders').doc(orderId);

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

    await _firestore
        .collection('orders')
        .doc(orderData.getRoomName())
        .update(updateMap);
  }
}
