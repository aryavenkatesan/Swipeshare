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
          // user is logged in
          if (snapshot.hasData) {
            if (FirebaseAuth.instance.currentUser!.emailVerified) {
              return const HomeScreen(hasOrders: false);
            } else {
              return const OnboardingCarousel();
            }
          }
          //user is NOT logged in
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
