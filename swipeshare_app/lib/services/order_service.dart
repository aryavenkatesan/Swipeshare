import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';

class OrderService extends ChangeNotifier {
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //POST LISTING
  Future<void> postOrder(
    String sellerId,
    String buyerId,
    String location,
    DateTime transactionDate,
  ) async {
    MealOrder newOrder = MealOrder(
      sellerId: sellerId,
      buyerId: buyerId,
      location: location,
      transactionDate: transactionDate,
    );

    try {
      await _fireStore.collection('orders').add(newOrder.toMap());
    } catch (e, s) {
      // Handle the error and stack trace
      print('Error: $e');
      print('Stack: $s');
    }
  }
}
