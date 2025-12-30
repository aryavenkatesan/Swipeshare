import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/message.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/services/user_service.dart';

class ChatService extends ChangeNotifier {
  //get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  //SEND MESSAGE
  Future<void> sendMessage(
    String receiverId,
    String message,
    MealOrder orderData,
  ) async {
    //get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final user = await _userService.getUserData(currentUserId);
    final String currentUserName = user!.name;
    final Timestamp timeStamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderName: currentUserName,
      receiverId: receiverId,
      timestamp: timeStamp,
      message: message,
    );

    String chatRoomId = orderData.getRoomName();

    //add new message to database
    await _fireStore
        .collection('orders') //orders
        .doc(chatRoomId) //orderId
        .collection('messages')
        .add(newMessage.toMap());
  }

  //GET MESSAGES
  Stream<QuerySnapshot> getMessages(
    String userId,
    String otherUserId,
    MealOrder orderData,
  ) {
    String chatRoomId = orderData.getRoomName();

    return _fireStore
        .collection('orders')
        .doc(chatRoomId)
        .collection("messages")
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  //SEND TIME WIDGET
  Future<void> timeWidget(String chatRoomId, String pickedTimeToString) async {
    try {
      final Timestamp timeStamp = Timestamp.now();
      final String currentUserId = _firebaseAuth.currentUser!.uid;
      final user = await _userService.getUserData(currentUserId);
      final String currentUserName = user!.name;
      Message systemMessage = Message(
        message: pickedTimeToString,
        receiverId: currentUserId, //THIS IS THE SENDER ID!!!
        senderName: currentUserName,
        senderId: 'time widget',
        timestamp: timeStamp,
      );

      await _fireStore
          .collection('orders')
          .doc(chatRoomId)
          .collection('messages')
          .add(systemMessage.toMap());
    } catch (e) {
      debugPrint('Error sending time widget: $e');
      rethrow;
    }
  }

  //UPDATE TIME WIDGET
  Future<void> updateTimeWidgetStatus(
    MealOrder orderData,
    String messageDocId,
    String status, // 'accepted' or 'declined'
    String? time,
  ) async {
    try {
      await _fireStore
          .collection('orders')
          .doc(orderData.getRoomName())
          .collection('messages')
          .doc(messageDocId)
          .update({'status': status});

      if (status == 'accepted') {
        await _fireStore
            .collection('orders')
            .doc(orderData.getRoomName())
            .update({'displayTime': time!});
      }
    } catch (e) {
      debugPrint('Error updating time widget status: $e');
      rethrow;
    }
  }

  Future<void> reportUser(
    String userId,
    String userEmail,
    String otherUserId,
    String otherUserEmail,
    String message,
  ) async {
    try {
      final Timestamp timestamp = Timestamp.now();

      await _fireStore.collection('reports').add({
        'reporterId': userId,
        'reporterEmail': userEmail,
        'reportedId': otherUserId,
        'reportedEmail': otherUserEmail,
        'reason': message,
        'timestamp': timestamp,
      });

      //notifyListeners();
    } catch (e) {
      debugPrint('Error reporting user: $e');
      rethrow;
    }
  }

  Future<void> systemMessage(
    String messageContent,
    String orderId, {
    Transaction? transaction,
  }) async {
    final Timestamp timeStamp = Timestamp.now();
    Message systemMessage = Message(
      message: messageContent,
      receiverId: 'system',
      senderName: 'system',
      senderId: 'system',
      timestamp: timeStamp,
    );

    final messagesCollection = _fireStore
        .collection('orders')
        .doc(orderId)
        .collection('messages');

    if (transaction != null) {
      transaction.set(messagesCollection.doc(), systemMessage.toMap());
      return;
    }

    await messagesCollection.add(systemMessage.toMap());
  }

  Future<void> newOrderSystemMessage(
    String orderId, {
    Transaction? transaction,
  }) async {
    final message =
        "Welcome to the chat room!\n\nFeel free to discuss things like the time you'd want to meet up, identifiers like shirt color, or maybe the movie that came out last week :) \n\n Remember swipes are \$7 and should be paid before the seller swipes you in. \n\n Happy Swiping!";
    await systemMessage(message, orderId, transaction: transaction);
  }

  Future<void> deleteChat(MealOrder orderData) async {
    try {
      final String message =
          "${_firebaseAuth.currentUser!.uid == orderData.buyerId ? orderData.buyerName : orderData.sellerName} has deleted the chat and left.\nPlease click the menu options above to delete the chat.";
      //TODO: Have to stop the other user from closing the order if someone deletes the chat
      systemMessage(message, orderData.getRoomName());
      OrderService().updateVisibility(orderData, true);
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  Future<void> readNotifications(MealOrder orderData) async {
    try {
      final String currentUserId = _firebaseAuth.currentUser!.uid;

      if (currentUserId == orderData.buyerId && orderData.buyerHasNotifs) {
        await _fireStore
            .collection('orders')
            .doc(orderData.getRoomName())
            .update({'buyerHasNotifs': false});
      } else if (currentUserId == orderData.sellerId &&
          orderData.sellerHasNotifs) {
        await _fireStore
            .collection('orders')
            .doc(orderData.getRoomName())
            .update({'sellerHasNotifs': false});
      }
    } catch (e) {
      debugPrint('Error reading notifications: $e');
      rethrow;
    }
  }

  Future<void> readNotificationsById(String orderId) async {
    try {
      DocumentSnapshot doc = await _fireStore
          .collection('orders')
          .doc(orderId)
          .get();

      if (doc.exists) {
        MealOrder orderData = MealOrder.fromMap(
          doc.data() as Map<String, dynamic>,
        );

        await readNotifications(orderData);
      }
    } catch (e) {
      debugPrint('Error reading notifications by order id: $e');
      rethrow;
    }
  }
}
