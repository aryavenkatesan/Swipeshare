import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:swipeshare_app/services/dev_service.dart';

import '../helpers/adaptive_helpers.dart';
import '../helpers/async_helpers.dart';
import '../helpers/nav_helpers.dart';
import '../helpers/setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full order lifecycle', (tester) async {
    await testSetup();

    const seller = SeedEmail.testUser1;
    const buyer = SeedEmail.testUser2;

    // Seed a real order via the dev function — mirrors the actual purchase flow
    // without re-testing listing creation (that's create_listing_test's job).
    await DevService.instance.createOrder(
      sellerEmail: seller,
      buyerEmail: buyer,
    );
    await switchUser(tester, buyer);

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // --- B sends a message ---
    await goToChat(tester, seller.displayName);
    await tester.enterText(findTextField(), 'Hey!');
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();
    await waitForText(tester, 'Hey!');

    // --- A proposes a time ---
    await switchUser(tester, buyer);
    await goToChat(tester, seller.displayName);
    setTimePickerValue(const TimeOfDay(hour: 14, minute: 0)); // 2 PM
    await tester.tap(find.byIcon(Icons.more_time));
    await tester.pumpAndSettle();
    await waitForText(tester, 'Pending...');

    // --- B declines ---
    await switchUser(tester, seller);
    await goToChat(tester, buyer.displayName);
    await tester.tap(find.text('Decline'));
    await tester.pumpAndSettle();
    await waitForText(tester, 'Declined');

    // --- B proposes a different time ---
    setTimePickerValue(const TimeOfDay(hour: 15, minute: 0)); // 3 PM
    await tester.tap(find.byIcon(Icons.more_time));
    await tester.pumpAndSettle();
    await waitForText(tester, 'Pending...');

    // --- A accepts ---
    await switchUser(tester, buyer);
    await goToChat(tester, seller.displayName);
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    await waitForText(tester, 'Accepted');

    // --- B marks order complete and rates ---
    await switchUser(tester, seller);
    await goToChat(tester, buyer.displayName);
    await tester.tap(find.text('Mark Complete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await waitForText(tester, 'Rate your Experience');
    await tester.tap(find.byIcon(Icons.star_border_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // --- A confirms completion and rates ---
    await switchUser(tester, buyer);
    await goToChat(tester, seller.displayName);
    // The bar is sticky when the other party has already marked complete
    await waitForText(tester, 'Confirm Complete');
    await tester.tap(find.text('Confirm Complete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await waitForText(tester, 'Rate your Experience');
    await tester.tap(find.byIcon(Icons.star_border_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    await testTeardown(tester);
  });
}
