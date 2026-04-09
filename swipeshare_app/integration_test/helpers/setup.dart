import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:swipeshare_app/emulator_config.dart';
import 'package:swipeshare_app/firebase_options.dart';

bool _initialized = false;

/// Call once in setUpAll before any tests run.
///
/// Prerequisites — emulator must be running and seeded:
///   firebase emulators:start
///   npx ts-node firebase/scripts/seed.ts
Future<void> setupFirebase() async {
  if (_initialized) return;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await connectToEmulators();
  _initialized = true;
}
