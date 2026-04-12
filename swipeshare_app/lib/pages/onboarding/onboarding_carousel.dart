import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swipeshare_app/pages/home_page.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/browse_swipes_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/communication_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/dashboard_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/final_step_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/payment_methods_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/sell_listing_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/stars_feedback_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/welcome_slide.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:swipeshare_app/services/auth/email_code_verification_service.dart';
import 'package:swipeshare_app/services/notification_service.dart';
import 'package:swipeshare_app/services/user_service.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  static const int _lastPageIndex = 7;
  static const int _paymentPageIndex = 6;

  final PageController _controller = PageController();
  // Controller for the code input
  final TextEditingController _codeController = TextEditingController();
  // Use the new service
  final _verificationService = EmailCodeVerificationService();
  final _userService = UserService.instance;

  int _currentPage = 0;
  bool _isPageTransitioning = false;
  bool _isCheckingVerification = false;
  bool _isResending = false;
  bool _didFinishFlow = false;
  List<String> _selectedPaymentOptions = [];

  bool get onLastPage => _currentPage == _lastPageIndex;
  bool get onPaymentPage => _currentPage == _paymentPageIndex;

  @override
  void initState() {
    super.initState();
    // Send the first verification code when the page loads
    _resendCode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _codeController.dispose();
    _verificationService.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_isPageTransitioning) return;

    // Block advancing past payment page if no options selected
    if (onPaymentPage && _selectedPaymentOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one payment method"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentPage >= _lastPageIndex) return;

    _animateToPage(_currentPage + 1);
  }

  void _jumpToLastPage() {
    if (_isPageTransitioning || !_controller.hasClients) return;
    _controller.jumpToPage(_lastPageIndex);
  }

  Future<void> _animateToPage(int index) async {
    if (!_controller.hasClients) return;
    if (_isPageTransitioning) return;

    _isPageTransitioning = true;
    await _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
    if (mounted) {
      _isPageTransitioning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final double vh = MediaQuery.of(context).size.height;
    final double vw = MediaQuery.of(context).size.width;
    final double dotSize = (vw / 22).clamp(10.0, 20.0);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFEF8FF),
        title: Text("Hello!", style: textTheme.displayLarge),
        actions: [
          //signout button
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      backgroundColor: const Color(0xFFFEF8FF),
      resizeToAvoidBottomInset: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                if (!mounted) return;
                setState(() {
                  _currentPage = index;
                });
                _isPageTransitioning = false;
              },
              children: [
                const OnboardingWelcomeSlide(tutorial: false),
                const OnboardingBrowseSwipesSlide(),
                const OnboardingSellListingSlide(),
                const OnboardingDashboardSlide(),
                const OnboardingCommunicationSlide(),
                const OnboardingStarsFeedbackSlide(),
                OnboardingPaymentMethodsSlide(
                  selectedPaymentOptions: _selectedPaymentOptions,
                  onPaymentOptionsChanged: (options) {
                    if (!mounted) return;
                    setState(() => _selectedPaymentOptions = options);
                  },
                ),
                // Pass the code controller to the final step slide
                OnboardingFinalStepSlide(
                  tutorial: false,
                  codeController: _codeController,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 50,
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: vh > 767 ? 8.0 : 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Resend / Skip Button ---
                  !onLastPage
                      ? GestureDetector(
                          onTap: _jumpToLastPage,
                          child: const Text("skip"),
                        )
                      : _isResending
                      // Show a small spinner while resending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : GestureDetector(
                          onTap: _resendCode,
                          child: const Text("    resend "),
                        ),

                  SmoothPageIndicator(
                    controller: _controller,
                    count: 8,
                    effect: WormEffect(
                      dotHeight: dotSize,
                      dotWidth: dotSize,
                      activeDotColor: Colors.black,
                      dotColor: Colors.grey,
                    ),
                  ),

                  // --- Next / Enter Button ---
                  !onLastPage
                      ? GestureDetector(
                          onTap: _onNextPressed,
                          child: const Text("next"),
                        )
                      : GestureDetector(
                          onTap: _checkCode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: _isCheckingVerification
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "enter",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  /// New function to check the code from the TextField
  Future<void> _checkCode() async {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();

    if (_isCheckingVerification) return;

    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(SnackbarMessages.enterAllDigits),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final code = _codeController.text.trim();
    final digitsOnly = RegExp(r'^\d{6}$').hasMatch(code);
    if (!digitsOnly) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit code.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCheckingVerification = true);

    try {
      await _verificationService.checkVerificationCode(code);

      // Save payment preferences if any were selected
      if (_selectedPaymentOptions.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('You are no longer signed in. Please log in again.');
        }
        final uid = user.uid;
        await _userService.updatePaymentTypes(uid, _selectedPaymentOptions);
      }

      // Email verified — request notification permissions before entering the app
      await NotificationService.instance.requestPermissions();

      if (mounted && !_didFinishFlow) {
        _didFinishFlow = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SnackbarMessages.emailVerified),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingVerification = false);
      }
    }
  }

  /// New function to resend the code
  Future<void> _resendCode() async {
    if (_isResending) return;
    if (!mounted) return;
    setState(() => _isResending = true);

    try {
      await _verificationService.sendVerificationCode();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SnackbarMessages.verificationCodeSent),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void signOut() {
    final authService = context.read<AuthServices>();
    authService.signOut();
  }
}
