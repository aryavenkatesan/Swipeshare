import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

sealed class Message {
  final String id;
  final String senderId;
  final String senderEmail;
  final String senderName;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.senderName,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final docData = doc.data() as Map<String, dynamic>?;
    if (!doc.exists || docData == null || docData.isEmpty) {
      throw Exception('Message document (id: ${doc.id}) does not exist or has no data');
    }

    switch (doc["messageType"]) {
      case 'text':
        return TextMessage.fromFirestore(doc);
      case 'timeProposal':
        return TimeProposal.fromFirestore(doc);
      case 'system':
        return SystemMessage.fromFirestore(doc);
      default:
        throw StateError("Unknown message type: ${doc['messageType']} for Message (id: ${doc.id})");
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
    required super.senderName,
    super.timestamp,
  });

  @override
  Map<String, dynamic> toMap() {
    return {'messageType': 'text', 'content': content, ...super.toMap()};
  }

  factory TextMessage.fromFirestore(DocumentSnapshot doc) {
    final docData = doc.data() as Map<String, dynamic>?;
    if (!doc.exists || docData == null || docData.isEmpty) {
      throw Exception('TextMessage document (id: ${doc.id}) does not exist or has no data');
    }

    if (doc["messageType"] != 'text') {
      throw StateError("Document (id: ${doc.id}) is not a TextMessage, got type: ${doc['messageType']}");
    }

    return TextMessage(
      id: doc.id,
      content: doc['content'],
      senderId: doc['senderId'],
      senderEmail: doc['senderEmail'],
      senderName: doc['senderName'],
      timestamp: (doc['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}

class SystemMessage extends Message {
  final String content;

  SystemMessage({required this.content, required super.id, super.timestamp})
    : super(senderId: "system", senderEmail: "system", senderName: "system");

  @override
  Map<String, dynamic> toMap() {
    return {'messageType': 'system', 'content': content, ...super.toMap()};
  }

  factory SystemMessage.fromFirestore(DocumentSnapshot doc) {
    final docData = doc.data() as Map<String, dynamic>?;
    if (!doc.exists || docData == null || docData.isEmpty) {
      throw Exception('SystemMessage document (id: ${doc.id}) does not exist or has no data');
    }

    if (doc["messageType"] != 'system') {
      throw StateError("Document (id: ${doc.id}) is not a SystemMessage, got type: ${doc['messageType']}");
    }

    return SystemMessage(
      id: doc.id,
      content: doc['content'],
      timestamp: (doc['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}

enum ProposalStatus { pending, accepted, declined }

class TimeProposal extends Message {
  final TimeOfDay proposedTime;
  final ProposalStatus status;

  TimeProposal({
    required this.proposedTime,
    this.status = ProposalStatus.pending,
    required super.id,
    required super.senderId,
    required super.senderEmail,
    required super.senderName,
    super.timestamp,
  });

  factory TimeProposal.fromFirestore(DocumentSnapshot doc) {
    final docData = doc.data() as Map<String, dynamic>?;
    if (!doc.exists || docData == null || docData.isEmpty) {
      throw Exception('TimeProposal document (id: ${doc.id}) does not exist or has no data');
    }

    if (doc["messageType"] != 'timeProposal') {
      throw StateError("Document (id: ${doc.id}) is not a TimeProposal, got type: ${doc['messageType']}");
    }

    return TimeProposal(
      id: doc.id,
      proposedTime: TimeFormatter.parseTimeOfDayString(doc['proposedTime']),
      status: ProposalStatus.values.firstWhere((e) => e.name == doc['status']),
      senderId: doc['senderId'],
      senderEmail: doc['senderEmail'],
      senderName: doc['senderName'],
      timestamp: (doc['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'messageType': 'timeProposal',
      'proposedTime': TimeFormatter.productionToString(proposedTime),
      'status': status.name,
      ...super.toMap(),
    };
  }
}
