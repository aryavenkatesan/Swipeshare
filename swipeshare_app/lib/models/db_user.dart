import 'package:cloud_firestore/cloud_firestore.dart';

class DbUser {
  final String uid;
  final String email;
  final String? fcmToken;
  final DateTime? lastTokenUpdate;

  DbUser({
    required this.uid,
    required this.email,
    this.fcmToken,
    this.lastTokenUpdate,
  });

  factory DbUser.fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) {
      throw Exception("Document does not exist");
    }
    return DbUser(
      uid: doc.id,
      email: doc['email'],
      fcmToken: doc['fcmToken'],
      lastTokenUpdate: (doc['lastTokenUpdate'] as Timestamp?)?.toDate(),
    );
  }
}
