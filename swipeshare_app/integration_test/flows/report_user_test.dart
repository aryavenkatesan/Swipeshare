import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:swipeshare_app/old_components/chat_screen/chat_settings.dart';
import 'package:swipeshare_app/services/dev_service.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

import '../helpers/adaptive_helpers.dart';
import '../helpers/async_helpers.dart';
import '../helpers/nav_helpers.dart';
import '../helpers/setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can report another user', (tester) async {
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

    await goToChat(tester, seller.displayName);

    // Open chat settings
    await tester.tap(find.byType(PopupMenuButton<SettingsItems>));
    await tester.pumpAndSettle();

    // Tap report user option
    expect(find.text('Report This User'), findsOneWidget);
    await tester.tap(find.text('Report This User').last);
    await tester.pumpAndSettle();

    // Submit the report
    await submitAdaptiveTextInput(
      tester,
      "Inappropriate messages",
      submitText: "Report",
    );

    // Wait for snackbar
    await waitForText(tester, SnackbarMessages.reportSubmitted);

    await testTeardown(tester);
  });
}
