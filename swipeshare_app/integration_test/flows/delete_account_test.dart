import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for FirebaseAuthException
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:swipeshare_app/services/dev_service.dart';

import '../helpers/adaptive_helpers.dart';
import '../helpers/async_helpers.dart';
import '../helpers/auth_helpers.dart';
import '../helpers/nav_helpers.dart';
import '../helpers/setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'deleteAccount anonymizes all user data and removes Firebase Auth record',
    (tester) async {
      await testSetup();

      // testUser3 is used here because deleteAccount removes the Firebase Auth
      // record — a destructive operation clearData() cannot restore. testUser3
      // is not referenced in any other test file, so its deletion is safe when
      // this test runs in isolation (as all integration test files should).
      const deletedUser = SeedEmail.testUser3;
      const otherUser = SeedEmail.testUser1;

      // ── Setup ────────────────────────────────────────────────────────────────

      await signInAs(deletedUser);
      await signOut();

      // Order where deletedUser is seller and otherUser is buyer.
      await DevService.instance.createOrder(
        sellerEmail: deletedUser,
        buyerEmail: otherUser,
      );

      // Active listing by deletedUser — should be cancelled and sellerName
      // anonymized after deletion.
      final activListingId = await DevService.instance.createListing(
        sellerEmail: deletedUser,
      );

      // Sign in as deletedUser, send a message so senderName can be verified
      // as anonymized from the other participant's perspective.
      await switchUser(tester, deletedUser);
      await goToChat(tester, otherUser.displayName);
      await tester.enterText(
        findTextField(),
        'This message will be anonymized',
      );
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();
      await waitForText(tester, 'This message will be anonymized');

      // ── Delete account via the UI ─────────────────────────────────────────

      // Back out of the chat page before switching tabs.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Navigate to Profile tab.
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Tap the "Delete Account" settings tile in the Danger Zone section.
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      // DeleteAccountPage: enter password and confirm.
      // The page requires reauthentication before proceeding.
      await tester.enterText(findTextField(), 'password');
      await tester.pumpAndSettle();
      // Use .last to target the ElevatedButton text, not the page heading.
      await tester.tap(find.text('Delete Account').last);
      await tester.pumpAndSettle();

      // DeletingAccountScreen runs the CF and then navigates to AuthGate.
      // UserService.deleteAccount() calls signOut() after the CF returns, which
      // triggers authStateChanges → AuthGate shows the login screen.
      await waitForText(tester, 'Login');

      // ── Verify as otherUser ───────────────────────────────────────────────

      // switchUser signs out (no-op since already signed out) then signs in.
      await switchUser(tester, otherUser);

      // Inbox: embedded seller.name in the order should now be "Deleted User".
      await goToChat(tester, 'Deleted User');

      // Chat: the senderName shown above the message bubble from deletedUser
      // should be "Deleted User".
      await waitForText(tester, 'Deleted User');

      // ── Verify listing anonymization (Firestore) ──────────────────────────

      // Any verified user can read the listings collection.
      // Check the explicitly-created active listing by ID — the listing created
      // internally by createOrder() is already 'claimed' and stays that way;
      // only 'active' listings are cancelled by deleteAccount.
      final activeListingDoc = await FirebaseFirestore.instance
          .collection('listings')
          .doc(activListingId)
          .get();

      expect(
        activeListingDoc.data()?['sellerName'],
        equals('Deleted User'),
        reason: 'Listing sellerName must be anonymized',
      );
      expect(
        activeListingDoc.data()?['status'],
        equals('cancelled'),
        reason: 'Active listing must be cancelled on account deletion',
      );

      // ── Verify Firebase Auth record is gone ───────────────────────────────

      await expectLater(
        FirebaseAuth.instance.signInWithEmailAndPassword(
          email: deletedUser.value,
          password: 'password',
        ),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.code,
            'code',
            'user-not-found',
          ),
        ),
      );

      // ── Teardown ──────────────────────────────────────────────────────────

      await testTeardown(tester);
    },
  );
}
