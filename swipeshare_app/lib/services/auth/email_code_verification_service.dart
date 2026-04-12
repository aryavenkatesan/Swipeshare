import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailCodeVerificationService {
  final _auth = FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  /// Calls the `sendVerificationCode` Cloud Function, which generates a
  /// 6-digit code server-side and sends it via email.
  Future<void> sendVerificationCode() async {
    if (_currentUser == null) {
      throw Exception("No user logged in.");
    }

    // Retry once to handle cold-start failures on first invocation.
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        await FirebaseFunctions.instance
            .httpsCallable('sendVerificationCode')
            .call();
        return;
      } on FirebaseFunctionsException catch (e) {
        debugPrint("Error sending verification code (attempt ${attempt + 1}): $e");
        if (attempt == 1) {
          throw Exception(e.message ?? "Failed to send code. Please try again later.");
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<void> sendForgotPasswordCode({required String targetEmail}) async {
    try {
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
      final result = await FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('verifyResetCode').call({'email': email, 'code': code});

      return result.data['token'] as String?;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? "Invalid or expired code.");
    } catch (e) {
      throw Exception("Verification failed. Please try again.");
    }
  }

  /// Calls the `verifyEmailCode` Cloud Function, which validates the code
  /// and marks the user as verified server-side.
  Future<void> checkVerificationCode(String code) async {
    if (_currentUser == null) {
      throw Exception("No user logged in.");
    }

    try {
      await FirebaseFunctions.instance
          .httpsCallable('verifyEmailCode')
          .call({'code': code});
    } on FirebaseFunctionsException catch (e) {
      debugPrint("Error verifying code: $e");
      throw Exception(e.message ?? "Invalid verification code.");
    }
  }

  void dispose() {
    // No-op
  }
}
