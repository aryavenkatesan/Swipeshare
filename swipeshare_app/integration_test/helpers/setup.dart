import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/components/theme_data.dart';
import 'package:swipeshare_app/emulator_config.dart';
import 'package:swipeshare_app/firebase_options.dart';
import 'package:swipeshare_app/services/auth/auth_gate.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:swipeshare_app/services/dev_service.dart';

import 'auth_helpers.dart';

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

/// Builds the app widget for integration tests.
/// Mirrors main_dev.dart's MyApp without NotificationService (FCM doesn't
/// work with the emulator) or navigatorKey (not needed in tests).
Widget buildTestApp() => ChangeNotifierProvider(
  create: (_) => AuthServices(),
  child: MaterialApp(theme: swipeshareTheme(), home: const AuthGate()),
);

/// Call at the top of every testWidgets body before any other steps.
///
/// These are helpers rather than setUp/setUpAll hooks because:
/// - setUp runs outside Flutter's FakeAsync zone, causing Futures that depend
///   on the binding to hang or behave unpredictably.
/// - Firebase Auth events (authStateChanges) fire immediately on subscription.
///   If sign-in happens before pumpWidget, the widget tree misses the event.
/// - Exceptions thrown in setUp are silently swallowed on device runners,
///   giving a false-green result with zero test coverage.
Future<void> testSetup() async {
  await setupFirebase();
  await DevService.instance.clearData();
}

/// Call at the end of every testWidgets body after all assertions.
///
/// Tears down the widget tree before signing out so that all StreamBuilders
/// dispose their Firestore listeners cleanly. Without this, active listeners
/// receive a permission-denied error when auth is revoked mid-stream, which
/// also causes BulkWriter cancellations in the next test's clearData call.
Future<void> testTeardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await signOut();
  await DevService.instance.clearData();
}
