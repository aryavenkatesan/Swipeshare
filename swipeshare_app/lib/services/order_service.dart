import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/services/chat_service.dart';
import 'package:swipeshare_app/services/user_service.dart';

class OrderService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();

  //POST LISTING
  Future<void> postOrder(
    String sellerId,
    // String buyerId, We'll find it here instead of passing
    String diningHall,
    DateTime transactionDate,
    String sellerName,
    double sellerstars,
    // String buyerName, We'll do it here also
  ) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final user = await _userService.getUserData(currentUserId);
    final String currentUserName = user!.name;
    final double currentUserStars = user.stars;
    MealOrder newOrder = MealOrder(
      sellerId: sellerId,
      buyerId: currentUserId,
      diningHall: diningHall,
      transactionDate: transactionDate,
      sellerName: sellerName,
      buyerName: currentUserName,
      sellerVisibility: true,
      buyerVisibility: true,
      sellerStars: sellerstars,
      buyerStars: currentUserStars,
      sellerHasNotifs: false,
      buyerHasNotifs: false,
      isChatDeleted: false,
    );

    try {
      String customDocId = newOrder.getRoomName();

      await _fireStore
          .collection('orders')
          .doc(customDocId)
          .set(newOrder.toMap());

      //send message from system
      final String message =
          "Welcome to the chat room!\n\nFeel free to discuss things like the time you'd want to meet up, identifiers like shirt color, or maybe the movie that came out last week :) \n\n Remember swipes are \$7 and should be paid before the seller swipes you in. \n\n Happy Swiping!";
      _chatService.systemMessage(message, customDocId);
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

  Future<void> updateVisibility(MealOrder orderData, bool deletedChat) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    if (currentUserId == orderData.buyerId) {
      //set buyer visibility to false
      await _fireStore.collection('orders').doc(orderData.getRoomName()).update(
        {'buyerVisibility': false, 'buyerHasNotifs': false},
      );
    } else {
      await _fireStore.collection('orders').doc(orderData.getRoomName()).update(
        {'sellerVisibility': false, 'sellerHasNotifs': false},
      );
    }
    if (!deletedChat) {
      //send system message that the other person left
      final UserModel? currentUser = await _userService.getUserData(
        currentUserId,
      );
      final String message =
          "${currentUser?.name ?? 'User'} has closed the order and left the chat.\nClick the check button above to close the order :)";
      _chatService.systemMessage(message, orderData.getRoomName());
    } else {
      await _fireStore.collection('orders').doc(orderData.getRoomName()).update(
        {'isChatDeleted': true},
      );
    }
  }
}
