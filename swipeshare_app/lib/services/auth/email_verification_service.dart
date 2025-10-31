import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationService {
  final _auth = FirebaseAuth.instance;
  Timer? _verificationTimer;

  get isVerified => _auth.currentUser!.emailVerified;

  get isChecking => _verificationTimer != null && _verificationTimer!.isActive;

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser!;

    if (user.emailVerified) {
      return;
    }
    try {
      await user.sendEmailVerification();
    } catch (e) {
      if (e is FirebaseAuthException) {
        String userMessage = "Failed to send email";
        switch (e.code) {
          case 'too-many-requests':
            userMessage = "Too many requests. Please try again later.";
            break;
          case 'user-not-found':
            userMessage = "User not found.";
            break;
          case 'invalid-email':
            userMessage = "Invalid email address.";
            break;
        }
        throw Exception(userMessage);
      }
    }
  }

  /// Begins a periodic check to see if the user's email has been verified.
  /// Throws an error upon timeout or other failure.
  Future<void> awaitVerification({
    Duration checkInterval = const Duration(seconds: 1),
    Duration checkTimeout = const Duration(minutes: 2),
  }) async {
    if (isChecking) {
      return;
    }

    final completer = Completer<void>();

    _checkVerification(completer);

    _verificationTimer = Timer.periodic(checkInterval, (timer) async {
      await _checkVerification(completer);

      if (completer.isCompleted) {
        timer.cancel();
        _verificationTimer = null;
      }
    });

    // Timeout
    Timer(checkTimeout, () {
      if (_verificationTimer?.isActive == true) {
        _verificationTimer?.cancel();
        _verificationTimer = null;
        if (!completer.isCompleted) {
          completer.completeError(
            TimeoutException('Email verification timed out', checkTimeout),
          );
        }
      }
    });

    return completer.future;
  }

  Future<void> _checkVerification(Completer<void> completer) async {
    if (completer.isCompleted) return;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        completer.completeError(Exception('No user logged in'));
        return;
      }

      await user.reload();

      if (user.emailVerified) {
        completer.complete();
      }
    } catch (e) {
      completer.completeError(e);
    }
  }

  void dispose() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
  }
}
