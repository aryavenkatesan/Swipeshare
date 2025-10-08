import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

sealed class Message {
  final String id;
  final String senderId;
  final String senderEmail;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap();

  factory Message.fromDoc(DocumentSnapshot doc) {
    switch (doc["messageType"]) {
      case 'text':
        return TextMessage.fromDoc(doc);
      case 'timeProposal':
        return TimeProposal.fromDoc(doc);
      default:
        throw StateError("Unknown message type: ${doc['messageType']}");
    }
  }
}

class TextMessage extends Message {
  final String content;

  TextMessage({
    required this.content,
    required super.id,
    required super.senderId,
    required super.senderEmail,
    super.timestamp,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'messageType': 'text',
      'senderId': senderId,
      'senderEmail': senderEmail,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory TextMessage.fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) {
      throw StateError("Document does not exist");
    }

    if (doc["messageType"] != 'text') {
      throw StateError("Not a TextMessage doc");
    }

    return TextMessage(
      id: doc.id,
      senderId: doc['senderId'],
      senderEmail: doc['senderEmail'],
      content: doc['content'],
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
    );
  }
}

enum ProposalStatus { pending, accepted, rejected }

class TimeProposal extends Message {
  final TimeOfDay proposedTime;
  final ProposalStatus status;

  TimeProposal({
    required this.proposedTime,
    this.status = ProposalStatus.pending,
    required super.id,
    required super.senderId,
    required super.senderEmail,
    super.timestamp,
  });

  factory TimeProposal.fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) {
      throw StateError("Document does not exist");
    }

    if (doc["messageType"] != 'timeProposal') {
      throw StateError("Not a TimeProposal doc");
    }

    return TimeProposal(
      id: doc.id,
      senderId: doc['senderId'],
      senderEmail: doc['senderEmail'],
      proposedTime: TimeOfDay(
        hour: doc['proposedTime'] ~/ 60,
        minute: doc['proposedTime'] % 60,
      ),
      status: ProposalStatus.values.firstWhere((e) => e.name == doc['status']),
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'messageType': 'timeProposal',
      'senderId': senderId,
      'senderEmail': senderEmail,
      'proposedTime': proposedTime.hour * 60 + proposedTime.minute,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
