import 'package:cloud_firestore/cloud_firestore.dart';

class DbUser {
  final String uid;
  final String email;

  DbUser({required this.uid, required this.email});

  factory DbUser.fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) {
      throw Exception("Document does not exist");
    }
    return DbUser(
      uid: doc.id,
      email: doc['email'],
    );
  }
}