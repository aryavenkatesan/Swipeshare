import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/services/auth/auth_service.dart';
import 'package:swipeshare_app/pages/home_page.dart';
import 'package:swipeshare_app/services/auth/login_or_register.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authService = context.read<AuthService>();
    await authService.initializeAuthState();

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.isAuthenticated) {
            // TODO: Go to onboarding if email not verified
            return const HomeScreen();
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
