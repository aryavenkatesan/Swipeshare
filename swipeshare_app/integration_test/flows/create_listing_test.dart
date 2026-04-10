import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:swipeshare_app/services/dev_service.dart';

import '../helpers/app_harness.dart';
import '../helpers/auth_helper.dart';
import '../helpers/nav_helpers.dart';
import '../helpers/picker_helpers.dart';
import '../helpers/test_lifecycle.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can create and post a listing', (tester) async {
    await testSetup();
    await signInAs(SeedEmail.testUser1);

    await tester.pumpWidget(buildTestApp());
    // Wait for AuthGate's two StreamBuilders (auth state + Firestore user doc)
    // and BottomBar's user-loading fade-in to settle.
    await tester.pumpAndSettle();

    // Auth gate should have routed to the main app
    expect(find.text('Dashboard'), findsOneWidget);

    // --- Navigate to CreateSwipeListingPage ---

    await tester.tap(find.text('Swipes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sell a Swipe'));
    await tester.pumpAndSettle();
    // CreateSwipeListingPage loads the user's payment types from Firestore
    // before rendering the form. pumpAndSettle waits for that to finish.

    expect(find.text('Sell Swipes'), findsOneWidget);

    // --- Fill in the listing form ---

    // Dining hall
    await tester.tap(find.text('Lenoir'));
    await tester.pumpAndSettle();

    // Date: pick tomorrow so that default times (10 AM / 12 PM) are in the future
    await tester.tap(find.text('Select a day'));
    await tester.pumpAndSettle();
    setPickerValue(tester, DateTime.now().add(const Duration(days: 1)));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Start time: 10 AM
    await tester.tap(find.text('Start at'));
    await tester.pumpAndSettle();
    setPickerValue(tester, DateTime(2000, 1, 1, 10, 0));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // End time: 12 PM (must be > start time)
    await tester.tap(find.text('End at'));
    await tester.pumpAndSettle();
    setPickerValue(tester, DateTime(2000, 1, 1, 12, 0));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Payment methods: testUser1's profile has Cash + Venmo, pre-filled automatically.
    // No UI interaction needed.

    // --- Submit ---

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Listing'), findsOneWidget);

    await tester.tap(find.text('Post Listing'));
    await tester.pumpAndSettle();

    expect(find.text('Successfully Placed Listing!'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // --- Verify the listing is visible to another user ---

    // Switch to a buyer account — testUser1's own listing is hidden from
    // themselves on the Swipes page, so we need a different user to see it.
    await switchUser(tester, SeedEmail.testUser2);

    await tester.tap(find.text('Swipes'));
    await tester.pumpAndSettle();

    // The listing card renders the price as a plain Text widget.
    // $5 is the default price and clearData() ensures no other listings exist,
    // so this unambiguously identifies the card we just created.
    expect(find.text('\$5'), findsOneWidget);

    await testTeardown(tester);
  });
}
