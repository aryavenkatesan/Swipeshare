import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeshare_app/services/dev_service.dart';

Future<void> signInAs(SeedEmail user) async {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: user.value,
    password: 'password',
  );
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

/// The blank pump before signOut disposes all StreamBuilders (and their
/// Firestore listeners) before auth is revoked, preventing permission-denied
/// errors from orphaned streams and BulkWriter cancellations in clearData().
Future<void> disposeAndSignout(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await signOut();
}
