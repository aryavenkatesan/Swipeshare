import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices extends ChangeNotifier {
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //sign user in
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //add a new document for the user in users collection if it doesn't already exist
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      //catch errors
      // print('Error code: ${e.code}');
      // print('Error message: ${e.message}');
      // print('Error details: ${e.stackTrace}');

      throw Exception(e.code);
    }
  }

  //create a new user
  Future<UserCredential> signUpWithEmailandPassword(
    String email,
    String password,
    String name,
    String referralEmail,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //after creating the user, create a collection for the user
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'payment_types': [],
        'stars': 5,
        'transactions_completed': 0,
        'refferal_email': referralEmail,
        'blocked_users': [],
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      //catch errors
      // print('Error code: ${e.code}');
      // print('Error message: ${e.message}');
      // print('Error details: ${e.stackTrace}');

      throw Exception(e.code);
    }
  }

  //sign user out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
