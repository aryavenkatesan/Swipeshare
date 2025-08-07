import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/firebase_options.dart';
import 'package:swipeshare_app/services/auth/auth_gate.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
