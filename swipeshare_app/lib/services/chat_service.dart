import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/message.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/services/notification_service.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/services/user_service.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService.instance;
  final OrderService _orderService = OrderService();
  final String orderId;

  UserModel? _cachedCurrentUser;

  ChatService(this.orderId);

  DocumentReference<Map<String, dynamic>> get _orderDoc =>
      _firestore.collection('orders').doc(orderId);

  CollectionReference<Map<String, dynamic>> get _chatRef =>
      _orderDoc.collection('messages');

  Future<UserModel> _getCurrentUser() async {
    if (_cachedCurrentUser != null) {
      return _cachedCurrentUser!;
    }
    _cachedCurrentUser = await _userService.getCurrentUser();

    if (_cachedCurrentUser == null) {
      throw Exception('No user is currently signed in');
    }

    return _cachedCurrentUser!;
  }

  Future<UserModel> getReceivingUser() async {
    final order = await _orderDoc.get().then(MealOrder.fromFirestore);

    final receivingUserId = (_auth.currentUser!.uid == order.buyerId)
        ? order.sellerId
        : order.buyerId;

    final userData = await _userService.getUserData(receivingUserId);
    if (userData == null) {
      throw Exception('User data not found for user ID: $receivingUserId');
    }
    return userData;
  }

  Future<TextMessage> sendTextMessage(String content) async {
    final user = await _getCurrentUser();
    final chatDoc = _chatRef.doc();

    final message = TextMessage(
      id: chatDoc.id,
      content: content,
      senderId: _auth.currentUser!.uid,
      senderEmail: user.email,
      senderName: user.name,
    );

    final messageData = message.toMap();
    messageData['timestamp'] = FieldValue.serverTimestamp();
    await chatDoc.set(messageData);
    return message;
  }

  Future<SystemMessage> sendSystemMessage(
    String content, {
    Transaction? transaction,
  }) async {
    final chatDoc = _chatRef.doc();

    final message = SystemMessage(id: chatDoc.id, content: content);

    final messageData = message.toMap();
    messageData['timestamp'] = FieldValue.serverTimestamp();

    if (transaction != null) {
      transaction.set(chatDoc, messageData);
      return message;
    }

    await chatDoc.set(messageData);
    return message;
  }

  Future<TimeProposal> sendTimeProposal(
    TimeOfDay proposedTime, {
    ProposalStatus status = ProposalStatus.pending,
  }) async {
    final user = await _getCurrentUser();
    final chatDoc = _chatRef.doc();

    final message = TimeProposal(
      id: chatDoc.id,
      status: status,
      proposedTime: proposedTime,
      senderId: _auth.currentUser!.uid,
      senderEmail: user.email,
      senderName: user.name,
    );

    final messageData = message.toMap();
    messageData['timestamp'] = FieldValue.serverTimestamp();
    await chatDoc.set(messageData);
    return message;
  }

  Future<void> updateTimeProposal(
    String proposalId,
    ProposalStatus newStatus,
  ) async {
    if (newStatus == ProposalStatus.accepted) {
      await _firestore.runTransaction((transaction) async {
        final proposalDoc = _chatRef.doc(proposalId);
        final proposalSnapshot = await transaction.get(proposalDoc);

        if (!proposalSnapshot.exists) {
          throw Exception('Proposal not found');
        }

        final proposal = TimeProposal.fromDoc(proposalSnapshot);

        transaction.update(proposalDoc, {"status": newStatus.name});
        await _orderService.updateOrderTime(
          orderId,
          proposal.proposedTime,
          transaction: transaction,
        );
      });
    } else {
      final proposalDoc = _chatRef.doc(proposalId);
      await proposalDoc.update({"status": newStatus.name});
    }
  }

  Stream<QuerySnapshot> getMessages() => _firestore
      .collection('orders')
      .doc(orderId)
      .collection("messages")
      .orderBy('timestamp', descending: false)
      .snapshots();

  Future<void> reportUser(String message) async {
    final (otherUser, thisUser) = await (
      getReceivingUser(),
      _userService.getCurrentUser(),
    ).wait;

    if (thisUser == null) {
      throw Exception('No user is currently signed in');
    }

    await _firestore.collection('reports').add({
      'reporterId': _auth.currentUser!.uid,
      'reporterEmail': thisUser.email,
      'reportedId': otherUser.email,
      'reportedEmail': otherUser.email,
      'reason': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<SystemMessage> newOrderSystemMessage({
    Transaction? transaction,
  }) async {
    final message = """
Welcome to the chat room!

Feel free to discuss things like the time you'd want to meet up, identifiers like shirt color, or maybe the movie that came out last week :) 

Remember swipes are \$7 and should be paid before the seller swipes you in.

Happy Swiping!
""";
    return await sendSystemMessage(message, transaction: transaction);
  }

  Future<void> deleteChat(MealOrder orderData) async {
    final currentUserName = _auth.currentUser!.uid == orderData.buyerId
        ? orderData.buyerName
        : orderData.sellerName;
    final String message =
        "$currentUserName has deleted the chat and left.\nPlease click the menu options above to delete the chat.";
    //TODO: Have to stop the other user from closing the order if someone deletes the chat
    await sendSystemMessage(message);
    await OrderService().updateVisibility(orderData, deletedChat: true);
  }

  Future<void> readNotifications() async {
    final currentUserId = _auth.currentUser!.uid;
    final order = await _orderDoc.get().then(MealOrder.fromFirestore);

    if (currentUserId == order.buyerId && order.buyerHasNotifs) {
      await _orderDoc.update({'buyerHasNotifs': false});
    } else if (currentUserId == order.sellerId && order.sellerHasNotifs) {
      await _orderDoc.update({'sellerHasNotifs': false});
    }

    await _notificationService.updateBadgeCount();
  }
}
