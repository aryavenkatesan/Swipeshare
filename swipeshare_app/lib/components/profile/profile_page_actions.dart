import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/components/profile/delete_account_page.dart';
import 'package:swipeshare_app/components/profile/feedback_page.dart';
import 'package:swipeshare_app/components/profile/notifications_page.dart';
import 'package:swipeshare_app/components/profile/update_payment_page.dart';
import 'package:swipeshare_app/pages/onboarding/forgot_password/forgot_password_page.dart';
import 'package:swipeshare_app/pages/onboarding/tutorial_carousel.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePageActions {
  static void navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
  }

  static void navigateToChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordPage(isChangePassword: true),
      ),
    );
  }

  static void navigateToUpdatePayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpdatePaymentPage()),
    );
  }

  static void navigateToFeedback(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FeedbackPage()),
    );
  }

  static void navigateToDeleteAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeleteAccountPage()),
    );
  }

  static Future<void> signOut(BuildContext context) async {
    final authService = Provider.of<AuthServices>(context, listen: false);
    await authService.signOut();
  }

  static void navigateToTutorial(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TutorialCarousel()),
    );
  }

  static Future<void> launchPrivacyPolicy() async {
    await launchUrl(
      Uri.parse("https://swipeshare.app/privacy-policy"),
      mode: LaunchMode.inAppBrowserView,
    );
  }

  static Future<void> launchTermsOfService() async {
    await launchUrl(
      Uri.parse("https://swipeshare.app/terms-of-service"),
      mode: LaunchMode.inAppBrowserView,
    );
  }
}
