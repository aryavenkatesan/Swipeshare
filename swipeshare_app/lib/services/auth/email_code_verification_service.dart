import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailCodeVerificationService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get _currentUser => _auth.currentUser;

  /// Generates a 6-digit code, saves it to the user's Firestore doc,
  /// and triggers an email to be sent via the "Trigger Email" extension.
  Future<void> sendVerificationCode() async {
    final user = _currentUser;
    if (user == null || user.email == null) {
      throw Exception("No user logged in or user has no email.");
    }

    // 1. Generate a 6-digit code
    final String code = (100000 + Random().nextInt(900000)).toString();

    // 2. Set an expiration time
    final DateTime expires = DateTime.now().add(const Duration(hours: 10));

    try {
      // 3. Save the code and expiration to the user's document
      // Make sure your firestore.rules allow this write
      await _firestore.collection('users').doc(user.uid).update({
        'verificationCode': code,
        'verificationCodeExpires': Timestamp.fromDate(expires),
      });

      // 4. Trigger the email to be sent by a backend extension
      // This writes to a new collection (e.g., "mail")
      // Make sure your firestore.rules allow this create
      await _firestore.collection('mail').add({
        'to': [user.email],
        'template': {
          'name':
              'verification', // This must match the name of your email template in SendGrid/Zoho
          'data': {
            'code': code, // Pass the code into the template
          },
        },
      });
    } on FirebaseException catch (e) {
      debugPrint("Error sending code: $e");
      // Provide a more user-friendly error
      if (e.code == 'permission-denied') {
        throw Exception("An error occurred. Please contact support.");
      }
      throw Exception("Failed to send code. Please try again later.");
    }
  }

  Future<void> sendForgotPasswordCode({required String targetEmail}) async {
    try {
      // Call the 'requestPasswordReset' function we just wrote
      await FirebaseFunctions.instance
          .httpsCallable('requestPasswordReset')
          .call({'email': targetEmail});
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? "Failed to send code.");
    }
  }

  Future<String?> verifyForgotPasswordCode({
    required String email,
    required String code,
  }) async {
    try {
      // Note: Ensure your region here matches your Firebase Console (us-central1)
      final result = await FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('verifyResetCode').call({'email': email, 'code': code});

      // Return the token provided by the updated TypeScript function
      return result.data['token'] as String?;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? "Invalid or expired code.");
    } catch (e) {
      throw Exception("Verification failed. Please try again.");
    }
  }

  /// Checks the user-provided code against the one in Firestore.
  /// If it matches, it updates the user doc to mark them as verified.
  Future<void> checkVerificationCode(String code) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception("No user logged in.");
    }

    // 1. Get the user's document
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists || doc.data() == null) {
      throw Exception("User data not found.");
    }

    final data = doc.data()!;
    final String? storedCode = data['verificationCode'] as String?;
    final Timestamp? expires = data['verificationCodeExpires'] as Timestamp?;

    // 2. Validate the code
    if (storedCode == null || expires == null) {
      throw Exception("No verification code found. Please resend.");
    }

    if (expires.toDate().isBefore(DateTime.now())) {
      throw Exception("Verification code has expired. Please resend.");
    }

    if (storedCode != code) {
      throw Exception("Invalid verification code.");
    }

    // 3. On success, update the user's profile to mark as verified
    // We use our own flag, not the built-in Firebase Auth one.
    await docRef.update({
      'isEmailVerified': true, // Your new custom verification flag
      'verificationCode': FieldValue.delete(), // Clean up
      'verificationCodeExpires': FieldValue.delete(), // Clean up
    });
  }

  // No polling timer is needed, so dispose() is empty.
  void dispose() {
    // No-op
  }
}
