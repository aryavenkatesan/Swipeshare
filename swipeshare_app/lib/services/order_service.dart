import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/message.dart';
import 'package:swipeshare_app/services/user_service.dart';

class OrderService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  //POST LISTING
  Future<void> postOrder(
    String sellerId,
    // String buyerId, We'll find it here instead of passing
    String diningHall,
    DateTime transactionDate,
    String sellerName,
    // String buyerName, We'll do it here also
  ) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final user = await _userService.getUserData(currentUserId);
    final String currentUserName = user!.name;
    MealOrder newOrder = MealOrder(
      sellerId: sellerId,
      buyerId: currentUserId,
      diningHall: diningHall,
      transactionDate: transactionDate,
      sellerName: sellerName,
      buyerName: currentUserName,
    );

    try {
      String customDocId = newOrder.getRoomName();

      await _fireStore
          .collection('orders')
          .doc(customDocId)
          .set(newOrder.toMap());

      //send message from system
      final Timestamp timeStamp = Timestamp.now();
      Message systemMessage = Message(
        message:
            'system message \n Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        receiverID: 'system',
        senderName: 'system',
        senderId: 'system',
        timestamp: timeStamp,
      );

      await _fireStore
          .collection('orders')
          .doc(customDocId)
          .collection('messages')
          .add(systemMessage.toMap());
    } catch (e, s) {
      // Handle the error and stack trace
      print('Error: $e');
      print('Stack: $s');
    }
  }

  Stream<QuerySnapshot> getOrders(String userId) {
    return _fireStore
        .collection('orders')
        .where(
          Filter.or(
            Filter('sellerId', isEqualTo: userId),
            Filter('buyerId', isEqualTo: userId),
          ),
        )
        .snapshots();
  }
}
