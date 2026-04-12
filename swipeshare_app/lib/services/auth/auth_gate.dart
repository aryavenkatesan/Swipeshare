import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/pages/bottom_bar.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_carousel.dart';
import 'package:swipeshare_app/services/auth/login_or_register.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Timer? _noDocTimer;
  String? _timerUid;

  @override
  void dispose() {
    _noDocTimer?.cancel();
    super.dispose();
  }

  void _startNoDocTimer(String uid) {
    if (_timerUid == uid) return; // already running for this user
    _noDocTimer?.cancel();
    _timerUid = uid;
    _noDocTimer = Timer(const Duration(seconds: 10), () {
      FirebaseAuth.instance.signOut();
    });
  }

  void _cancelNoDocTimer() {
    _noDocTimer?.cancel();
    _noDocTimer = null;
    _timerUid = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          // Show loading while checking auth state
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildCurrentScreen(authSnapshot.data),
          );
        },
      ),
    );
  }

  Widget _buildCurrentScreen(User? user) {
    // Not logged in - show login/register
    if (user == null) {
      _cancelNoDocTimer();
      return const LoginOrRegister(key: ValueKey('auth'));
    }

    // Logged in - check Firestore for email verification status
    return StreamBuilder<DocumentSnapshot>(
      key: ValueKey('user-${user.uid}'),
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .handleError((error, stackTrace) {
            debugPrint(
              'Firestore error in auth_gate.dart: $error\nThis is expected during logout (auth token race condition)',
            );
          }),
      builder: (context, userSnapshot) {
        // Show loading while fetching user data
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            key: ValueKey('loading'),
            child: CircularProgressIndicator(),
          );
        }

        // Handle errors from Firestore
        if (userSnapshot.hasError) {
          return const Center(
            key: ValueKey('auth-transition'),
            child: CircularProgressIndicator(),
          );
        }

        // Doc doesn't exist yet — transient state during signup while the Cloud
        // Function is creating it. Start a timeout; if the doc never appears,
        // sign the user out so they don't spin forever.
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          _startNoDocTimer(user.uid);
          return const Center(
            key: ValueKey('loading'),
            child: CircularProgressIndicator(),
          );
        }

        // Doc appeared — cancel any pending timeout.
        _cancelNoDocTimer();

        // Get user data from Firestore
        final userData = UserModel.fromFirestore(userSnapshot.data!);

        // Check if user is banned
        if (userData.status == UserStatus.banned) {
          // Sign out the banned user and show login screen
          FirebaseAuth.instance.signOut();
          return const LoginOrRegister(key: ValueKey('auth'));
        }

        // Route based on verification status
        if (userData.isEmailVerified) {
          return const BottomBar(key: ValueKey('home'));
        } else {
          return const OnboardingCarousel(key: ValueKey('onboarding'));
        }
      },
    );
  }
}
