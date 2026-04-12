import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/services/notification_service.dart';
import 'package:swipeshare_app/services/user_service.dart';

class AuthServices extends ChangeNotifier {
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //sign user in
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
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

      await FirebaseFunctions.instance.httpsCallable('createUserDocument').call(
        {'name': name, 'referralEmail': referralEmail},
      );

      // Wait until the Firestore doc is readable (Cloud Function write may not be
      // immediately visible to the client).
      const maxAttempts = 10;
      for (var i = 0; i < maxAttempts; i++) {
        try {
          await UserService.instance.getUserData(userCredential.user!.uid);
          break;
        } catch (_) {
          if (i == maxAttempts - 1) rethrow;
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  //sign user out
  Future<void> signOut() async {
    debugPrint('Signing out user: ${_firebaseAuth.currentUser?.uid}');
    await NotificationService.instance.removeTokenFromFirestore();
    await FirebaseAuth.instance.signOut();
    debugPrint('User signed out successfully.');
  }

  //convert Firebase auth error codes to user-friendly messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
