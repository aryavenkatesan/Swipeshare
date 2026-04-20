import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/theme_data.dart';
import 'package:swipeshare_app/pages/shutdown_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();
bool isDevMode = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: swipeshareTheme(),
      home: const ShutdownPage(),
    );
  }
}
