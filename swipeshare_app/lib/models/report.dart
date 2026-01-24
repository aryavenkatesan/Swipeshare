import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String? id;
  final String reason;
  final String reportedId;
  final String reportedEmail;
  final String reporterId;
  final String reporterEmail;
  final DateTime timestamp;

  Report({
    this.id,
    required this.reason,
    required this.reportedId,
    required this.reportedEmail,
    required this.reporterId,
    required this.reporterEmail,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final docData = doc.data() as Map<String, dynamic>?;
    if (!doc.exists || docData == null || docData.isEmpty) {
      throw Exception('Report document (id: ${doc.id}) does not exist or has no data');
    }

    return Report(
      id: doc.id,
      reason: doc['reason'],
      reportedId: doc['reportedId'],
      reportedEmail: doc['reportedEmail'],
      reporterId: doc['reporterId'],
      reporterEmail: doc['reporterEmail'],
      timestamp: (doc['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reason': reason,
      'reportedId': reportedId,
      'reportedEmail': reportedEmail,
      'reporterId': reporterId,
      'reporterEmail': reporterEmail,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
