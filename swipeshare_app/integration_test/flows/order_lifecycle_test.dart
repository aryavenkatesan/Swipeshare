import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:swipeshare_app/services/dev_service.dart';

import '../helpers/app_harness.dart';
import '../helpers/auth_helper.dart';
import '../helpers/picker_helpers.dart';
import '../helpers/setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebase();
  });

  setUp(() async {
    await DevService.instance.clearData();
    // Seed a real order via the dev function — mirrors the actual purchase flow
    // without re-testing listing creation (that's create_listing_test's job).
    await DevService.instance.createOrder(
      sellerEmail: SeedEmail.testUser1,
      buyerEmail: SeedEmail.testUser2,
    );
    await signInAs(SeedEmail.testUser2); // start as buyer
  });

  tearDown(() async {
    await signOut();
  });

  testWidgets('full order lifecycle', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // --- B sends a message ---
    await _goToChat(tester, 'Nick');
    await tester.enterText(find.byType(TextField), 'Hey!');
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();
    expect(find.text('Hey!'), findsOneWidget);

    // --- A proposes a time ---
    await _switchUser(tester, SeedEmail.testUser1);
    await _goToChat(tester, 'Test User 2');
    await tester.tap(find.byIcon(Icons.more_time));
    await tester.pumpAndSettle();
    setPickerValue(tester, DateTime(2000, 1, 1, 14, 0)); // 2 PM
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Pending...'), findsOneWidget);

    // --- B declines ---
    await _switchUser(tester, SeedEmail.testUser2);
    await _goToChat(tester, 'Nick');
    await tester.tap(find.text('Decline'));
    await tester.pumpAndSettle();
    expect(find.text('Declined'), findsOneWidget);

    // --- B proposes a different time ---
    await tester.tap(find.byIcon(Icons.more_time));
    await tester.pumpAndSettle();
    setPickerValue(tester, DateTime(2000, 1, 1, 15, 0)); // 3 PM
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Pending...'), findsOneWidget);

    // --- A accepts ---
    await _switchUser(tester, SeedEmail.testUser1);
    await _goToChat(tester, 'Test User 2');
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(find.text('Accepted'), findsOneWidget);

    // --- B marks order complete and rates ---
    await _switchUser(tester, SeedEmail.testUser2);
    await _goToChat(tester, 'Nick');
    await tester.tap(find.text('Mark Complete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Rate your Experience'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.star_border_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // --- A confirms completion and rates ---
    await _switchUser(tester, SeedEmail.testUser1);
    await _goToChat(tester, 'Test User 2');
    // The bar is sticky when the other party has already marked complete
    expect(find.text('Confirm Complete'), findsOneWidget);
    await tester.tap(find.text('Confirm Complete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Rate your Experience'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.star_border_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
  });
}

/// Navigates to the Inbox tab and taps the chat with [counterpartyName].
Future<void> _goToChat(WidgetTester tester, String counterpartyName) async {
  await tester.tap(find.text('Inbox'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(counterpartyName));
  await tester.pumpAndSettle();
}

/// Signs out, signs in as [user], and rebuilds the widget tree from scratch.
/// Rebuilding avoids stale navigation stack issues from the previous session.
Future<void> _switchUser(WidgetTester tester, SeedEmail user) async {
  await signOut();
  await signInAs(user);
  await tester.pumpWidget(buildTestApp());
  await tester.pumpAndSettle();
}
