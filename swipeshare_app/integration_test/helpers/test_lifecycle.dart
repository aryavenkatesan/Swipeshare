import 'package:flutter_test/flutter_test.dart';
import 'package:swipeshare_app/services/dev_service.dart';

import 'auth_helpers.dart';
import 'setup.dart';

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
  await disposeAndSignout(tester);
  await DevService.instance.clearData();
}
