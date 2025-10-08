import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/db_user.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String orderId;

  ChatService(this.orderId);

  Future<CollectionReference> _getChatRef() async {
    final orderRef = _firestore.collection("orders").doc(orderId);
    final doc = await orderRef.get();
    if (!doc.exists) {
      throw Exception("Order with id $orderId not found");
    }

    return orderRef.collection('messages');
  }

  Future<DbUser> getReceivingUser() async {
    final user = _auth.currentUser!;
    final orderDoc = await _firestore.collection('orders').doc(orderId).get();
    final order = MealOrder.fromDoc(orderDoc);
    final receivingUserId = (user.uid == order.buyerId)
        ? order.sellerId
        : order.buyerId;
    final userDoc = await _firestore
        .collection('users')
        .doc(receivingUserId)
        .get();
    return DbUser.fromDoc(userDoc);
  }

  Future<TextMessage> sendTextMessage(String content) async {
    final user = _auth.currentUser!;
    final chatDoc = await _getChatRef().then((ref) => ref.doc());
    final message = TextMessage(
      id: chatDoc.id,
      content: content,
      senderId: user.uid,
      senderEmail: user.email!,
      timestamp: DateTime.now(),
    );
    await chatDoc.set(message.toMap());
    return message;
  }

  Future<TimeProposal> sendTimeProposal(TimeOfDay proposedTime) async {
    final user = _auth.currentUser!;
    final chatDoc = await _getChatRef().then((ref) => ref.doc());
    final message = TimeProposal(
      id: chatDoc.id,
      proposedTime: proposedTime,
      senderId: user.uid,
      senderEmail: user.email!,
      timestamp: DateTime.now(),
    );
    await chatDoc.set(message.toMap());
    return message;
  }

  Future<TimeProposal> updateTimeProposal(
    String proposalId,
    ProposalStatus newStatus,
  ) async {
    final chatRef = await _getChatRef();
    final proposalDoc = chatRef.doc(proposalId);
    final proposalSnapshot = await proposalDoc.get();
    if (!proposalSnapshot.exists) {
      throw Exception("Proposal with id $proposalId not found");
    }
    final proposal = TimeProposal.fromDoc(proposalSnapshot);
    final updatedProposal = TimeProposal(
      id: proposal.id,
      proposedTime: proposal.proposedTime,
      status: newStatus,
      senderId: proposal.senderId,
      senderEmail: proposal.senderEmail,
      timestamp: proposal.timestamp,
    );
    await proposalDoc.set(updatedProposal.toMap());
    return updatedProposal;
  }

  Widget messageStream({
    required Widget Function(
      BuildContext context,
      List<Message> messages,
      bool isLoading,
      Object? error,
    )
    builder,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('orders')
          .doc(orderId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final error = snapshot.error;

        List<Message> messages = [];
        if (snapshot.hasData) {
          messages = snapshot.data!.docs.map(Message.fromDoc).toList();
        }

        return builder(context, messages, isLoading, error);
      },
    );
  }

  Future<void> reportUser(String userId, String otherUserId) async {}

  Future<void> blockUser(String userId, String otherUserId) async {}
}
