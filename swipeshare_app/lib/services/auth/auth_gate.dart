import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/pages/home_page.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_carousel.dart';
import 'package:swipeshare_app/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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
      return const LoginOrRegister(key: ValueKey('auth'));
    }

    // Logged in - check Firestore for email verification status
    return StreamBuilder<DocumentSnapshot>(
      key: ValueKey('user-${user.uid}'),
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        // Show loading while fetching user data
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            key: ValueKey('loading'),
            child: CircularProgressIndicator(),
          );
        }

        // Handle user document not found
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(
            key: ValueKey('error'),
            child: Text('User data not found. Please contact support.'),
          );
        }

        // Get email verification status from Firestore
        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final isEmailVerified = userData['isEmailVerified'] ?? false;

        // Route based on verification status
        if (isEmailVerified) {
          return const HomeScreen(key: ValueKey('home'));
        } else {
          return const OnboardingCarousel(key: ValueKey('onboarding'));
        }
      },
    );
  }
}
