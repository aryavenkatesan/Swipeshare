import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/pages/home_page.dart';
import 'package:swipeshare_app/providers/auth_provider.dart';
import 'package:swipeshare_app/providers/util/provider_utils.dart';
import 'package:swipeshare_app/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.hasInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            initializeAuthBasedProviders(context);
          });
          return const HomeScreen();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            resetAuthBasedProviders(context);
          });
          return const LoginOrRegister();
        }
      },
    );
  }
}
