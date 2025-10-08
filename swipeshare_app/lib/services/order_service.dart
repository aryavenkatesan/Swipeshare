import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/services/listing_service.dart';

class OrderService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _listingService = ListingService();

  Future<MealOrder> createOrder({
    required String sellerId,
    required String diningHall,
    required DateTime date,
    required TimeOfDay? time,
    Transaction? transaction,
  }) async {
    final uid = _auth.currentUser!.uid;
    final newOrderRef = _firestore.collection('orders').doc();

    final newOrder = MealOrder(
      id: newOrderRef.id,
      sellerId: sellerId,
      buyerId: uid,
      diningHall: diningHall,
      date: DateTime(date.year, date.month, date.day),
      time: time,
    );

    if (transaction != null) {
      transaction.set(newOrderRef, newOrder.toMap());
      return newOrder;
    } else {
      await newOrderRef.set(newOrder.toMap());
      return newOrder;
    }
  }

  Future<MealOrder> makeTransaction({
    required String listingId,
    required DateTime date,
    required TimeOfDay? time,
    Transaction? transaction,
  }) async {
    final uid = _auth.currentUser!.uid;
    final listingRef = _firestore.collection('listings').doc(listingId);
    final newOrderRef = _firestore.collection('orders').doc();

    Future<MealOrder> handleTransaction(Transaction t) async {
      final listing = await _listingService.getListingById(
        listingRef.id,
        transaction: t,
      );

      final newOrder = MealOrder(
        id: newOrderRef.id,
        sellerId: listing.sellerId,
        buyerId: uid,
        diningHall: listing.diningHall,
        date: date,
        time: time,
      );

      t.set(newOrderRef, newOrder.toMap());
      t.delete(listingRef);

      return newOrder;
    }

    return await ((transaction != null)
        ? handleTransaction(transaction)
        : _firestore.runTransaction<MealOrder>(handleTransaction));
  }

  Future<MealOrder> getOrderById(
    String orderId, {
    Transaction? transaction,
  }) async {
    final doc = await (transaction != null
        ? transaction.get(_firestore.collection('orders').doc(orderId))
        : _firestore.collection('orders').doc(orderId).get());
    if (!doc.exists) {
      throw Exception("Order with id $orderId not found");
    }
    return MealOrder.fromDoc(doc);
  }

  Future<MealOrder> cancelOrder(
    String orderId, {
    Transaction? transaction,
  }) async {
    final orderRef = _firestore.collection('orders').doc(orderId);

    Future<MealOrder> executeTransaction(Transaction t) async {
      final orderDoc = await getOrderById(orderId, transaction: t);
      t.delete(orderRef);
      return orderDoc;
    }

    return await ((transaction != null)
        ? executeTransaction(transaction)
        : _firestore.runTransaction<MealOrder>(executeTransaction));
  }

  Widget orderStream({
    required Widget Function(
      BuildContext context,
      List<MealOrder> orders,
      bool isLoading,
      Object? error,
    )
    builder,
  }) {
    final uid = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('orders')
          .where(
            Filter.or(
              Filter('sellerId', isEqualTo: uid),
              Filter('buyerId', isEqualTo: uid),
            ),
          )
          .snapshots(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final error = snapshot.error;

        List<MealOrder> orders = [];
        if (snapshot.hasData) {
          orders = snapshot.data!.docs
              .map((doc) => MealOrder.fromDoc(doc))
              .toList();
        }

        return builder(context, orders, isLoading, error);
      },
    );
  }
}
