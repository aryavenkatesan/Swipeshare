import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:swipeshare_app/services/user_service.dart';

import '../helpers/app_harness.dart';
import '../helpers/auth_helper.dart';
import '../helpers/test_lifecycle.dart';
import '../helpers/wait_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('new user can sign up', (tester) async {
    await testSetup();
    await signOut();

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // Navigate to sign up page
    expect(find.text('Login'), findsOneWidget);
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    // Fill in sign up form
    await tester.enterText(find.byKey(Key("first-name-field")), 'Test');
    await tester.enterText(find.byKey(Key("email-field")), 'test@unc.edu');
    await tester.enterText(find.byKey(Key("password-field")), 'password123');
    await tester.enterText(
      find.byKey(Key("confirm-password-field")),
      'password123',
    );

    // Submit form
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    // Navigate through the onboarding carousel
    expect(find.text("Welcome to Swipeshare!"), findsOneWidget);

    const numPages = 7;
    for (int i = 0; i < numPages - 1; i++) {
      await tester.tap(find.text('next'));
      await tester.pumpAndSettle();
    }

    // Assert user data is populated and verification code set
    final user = await UserService.instance.getCurrentUser();
    expect(user.name, 'Test');
    expect(user.email, 'test@unc.edu');
    expect(user.verificationCode, isNotNull);
    expect(user.verificationCodeExpires, isNotNull);
    expect(user.isEmailVerified, isFalse);

    // Enter verification code
    await tester.enterText(
      find.byKey(Key("verification-code-field")),
      user.verificationCode!,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.text('enter'));
    await tester.pumpAndSettle();

    // Assert that we're on the home page
    await waitForText(tester, 'No orders yet');
    await waitForText(tester, 'No listings yet');

    // Asser user is verified now
    final updatedUser = await UserService.instance.getUserData(user.id);
    expect(updatedUser.isEmailVerified, isTrue);

    await testTeardown(tester);
  });
}
