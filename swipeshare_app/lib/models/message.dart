import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String? documentId;
  final String senderId;
  final String senderName;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String? status;

  Message({
    this.documentId,
    required this.message,
    required this.receiverID,
    required this.senderName,
    required this.senderId,
    required this.timestamp,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverID,
      'message': message,
      'timestamp': timestamp,
      if (status != null) 'status': status,
    };
  }

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      documentId: doc.id,
      senderId: data['senderId'],
      senderName: data['senderName'],
      receiverID: data['receiverId'],
      message: data['message'],
      timestamp: data['timestamp'],
      status: data['status'],
    );
  }
}
