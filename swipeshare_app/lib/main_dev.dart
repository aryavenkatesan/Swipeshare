import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/components/theme_data.dart';
import 'package:swipeshare_app/emulator_config.dart';
import 'package:swipeshare_app/firebase_options.dart';
import 'package:swipeshare_app/services/auth/auth_gate.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';

import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await connectToEmulators();
  isDevMode = true;

  // Skip NotificationService: FCM does not work with local emulators.

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthServices(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: true,
      theme: swipeshareTheme(),
      home: AuthGate(),
    );
  }
}
