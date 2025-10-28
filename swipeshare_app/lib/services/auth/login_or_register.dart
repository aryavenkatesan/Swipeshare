import 'package:flutter/material.dart';
import 'package:swipeshare_app/pages/onboarding/login_page.dart';
import 'package:swipeshare_app/pages/onboarding/signup_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      child: showLoginPage
          ? LoginPage(key: const ValueKey('login'), onTap: togglePages)
          : RegisterPage(key: const ValueKey('register'), onTap: togglePages),
    );
  }
}
