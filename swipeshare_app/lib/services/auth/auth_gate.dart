import 'package:swipeshare_app/pages/onboarding/onboarding_carousel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/pages/home_page.dart';
import 'package:swipeshare_app/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildCurrentScreen(snapshot.data),
          );
        },
      ),
    );
  }

  Widget _buildCurrentScreen(User? user) {
    if (user != null) {
      if (user.emailVerified) {
        return const HomeScreen(key: ValueKey('home'));
      } else {
        return const OnboardingCarousel(key: ValueKey('onboarding'));
      }
    }
    return const LoginOrRegister(key: ValueKey('auth'));
  }
}
