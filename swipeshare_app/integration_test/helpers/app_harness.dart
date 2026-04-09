import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/components/theme_data.dart';
import 'package:swipeshare_app/services/auth/auth_gate.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';

/// Builds the app widget for integration tests.
/// Mirrors main_dev.dart's MyApp without NotificationService (FCM doesn't
/// work with the emulator) or navigatorKey (not needed in tests).
Widget buildTestApp() => ChangeNotifierProvider(
      create: (_) => AuthServices(),
      child: MaterialApp(
        theme: swipeshareTheme(),
        home: const AuthGate(),
      ),
    );
