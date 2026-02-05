import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/message.dart';
import 'package:swipeshare_app/models/report.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/services/notification_service.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/services/user_service.dart';

class ChatService extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _userService = UserService.instance;
  final _notificationService = NotificationService.instance;
  final _orderService = OrderService.instance;
  final String orderId;

  UserModel? _cachedCurrentUser;

  ChatService(this.orderId);

  DocumentReference<MealOrder> get _orderDoc =>
      _orderService.orderCol.doc(orderId);

  CollectionReference<Map<String, dynamic>> get _chatRef =>
      _orderDoc.collection('messages');

  CollectionReference<Message> get chatCol => _chatRef.withConverter(
    fromFirestore: (snap, _) => Message.fromFirestore(snap),
    toFirestore: (message, _) => message.toMap(),
  );

  Future<UserModel> _getCurrentUser() async {
    if (_cachedCurrentUser != null) {
      return _cachedCurrentUser!;
    }
    _cachedCurrentUser = await _userService.getCurrentUser();
    return _cachedCurrentUser!;
  }

  Future<UserModel> getReceivingUser() async {
    final order = await _orderDoc.get().then(MealOrder.fromFirestore);

    final receivingUserId = (_auth.currentUser!.uid == order.buyerId)
        ? order.sellerId
        : order.buyerId;

    return await _userService.getUserData(receivingUserId);
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
        final proposalDoc = chatCol.doc(proposalId);
        final proposal = await transaction
            .get(proposalDoc)
            .then((s) => s.data());

        if (proposal == null || proposal is! TimeProposal) {
          throw Exception('Proposal not found or invalid');
        }

        transaction.update(proposalDoc, {"status": newStatus.name});
        await _orderService.updateOrderTime(
          orderId,
          proposal.proposedTime,
          transaction: transaction,
        );
      });
    } else {
      final proposalDoc = chatCol.doc(proposalId);
      await proposalDoc.update({"status": newStatus.name});
    }
  }

  Future<void> reportUser(String message) async {
    final (otherUser, thisUser) = await (
      getReceivingUser(),
      _getCurrentUser(),
    ).wait;

    final report = Report(
      reporterId: _auth.currentUser!.uid,
      reporterEmail: thisUser.email,
      reportedId: otherUser.id,
      reportedEmail: otherUser.email,
      reason: message,
      timestamp: DateTime.now(),
    );

    final reportData = report.toMap();
    reportData['timestamp'] = FieldValue.serverTimestamp();

    await _firestore.collection('reports').add(reportData);
  }

  Future<void> readNotifications() async {
    final currentUserId = _auth.currentUser!.uid;
    final order = await _orderService.getOrderById(orderId);

    if (currentUserId == order.buyerId && order.buyerHasNotifs) {
      await _orderDoc.update({'buyerHasNotifs': false});
    } else if (currentUserId == order.sellerId && order.sellerHasNotifs) {
      await _orderDoc.update({'sellerHasNotifs': false});
    }

    await _notificationService.updateBadgeCount();
  }
}
