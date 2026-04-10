import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipeshare_app/services/dev_service.dart';

import 'app_harness.dart';
import 'auth_helper.dart';

/// Navigates to the Inbox tab and taps the chat with [counterpartyName].
Future<void> goToChat(WidgetTester tester, String counterpartyName) async {
  await tester.tap(find.text('Inbox'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(counterpartyName));
  await tester.pumpAndSettle();
}

/// Signs out, signs in as [user], and rebuilds the widget tree from scratch.
/// Rebuilding avoids stale navigation stack issues from the previous session.
///
/// The blank pump before signOut disposes all StreamBuilders (and their
/// Firestore listeners) before auth is revoked, preventing permission-denied
/// errors from orphaned streams and BulkWriter cancellations in clearData().
Future<void> switchUser(WidgetTester tester, SeedEmail user) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await signOut();
  await signInAs(user);
  await tester.pumpWidget(buildTestApp());
  await tester.pumpAndSettle();
}
