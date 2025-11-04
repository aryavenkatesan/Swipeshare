import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swipeshare_app/pages/home_page.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_1.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_2.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_3.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_4.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_5.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_6.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
// Import the new code service
import 'package:swipeshare_app/services/auth/email_code_verification_service.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final PageController _controller = PageController();
  // Use the new service
  final _verificationService = EmailCodeVerificationService();
  // Add a controller for the code input
  final _codeController = TextEditingController();

  bool onLastPage = false;
  bool _isCheckingVerification = false;
  bool _isResending = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFEF8FF),
        title: Text("Hello!"),
        actions: [
          //signout button
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      backgroundColor: Color(0xFFFEF8FF),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.69,
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  onLastPage = (index == 5);
                });
              },
              children: [
                Page1(tutorial: false),
                Page2(),
                Page3(),
                Page4(),
                Page5(),
                // Pass the code controller to the new Page6
                Page6(tutorial: false, codeController: _codeController),
              ],
            ),
          ),
          SizedBox(height: 30),
          Container(
            height: 50,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Resend Button ---
                  !onLastPage
                      ? GestureDetector(
                          onTap: () {
                            _controller.jumpToPage(5);
                          },
                          child: Text("skip"),
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
                          child: Text("    resend "),
                        ),

                  SmoothPageIndicator(
                    controller: _controller,
                    count: 6,
                    effect: WormEffect(
                      dotHeight: 20,
                      dotWidth: 20,
                      activeDotColor: Colors.black,
                      dotColor: Colors.grey,
                    ),
                  ),

                  // --- Next / Enter Button ---
                  !onLastPage
                      ? GestureDetector(
                          onTap: () {
                            _controller.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            );
                          },
                          child: const Text("next"),
                        )
                      : GestureDetector(
                          onTap: _checkCode, // Point to the new check function
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(
                                30,
                              ), // Capsule shape
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
          SizedBox(height: 50),
        ],
      ),
    );
  }

  /// New function to check the code from the TextField
  Future<void> _checkCode() async {
    if (_isCheckingVerification) return;

    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCheckingVerification = true);

    try {
      await _verificationService.checkVerificationCode(_codeController.text);

      // Email verified
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully!'),
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
    setState(() => _isResending = true);

    try {
      await _verificationService.sendVerificationCode();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New verification code sent!'),
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

  // This function is no longer needed and can be removed
  // void _stopEmailVerification() { ... }

  void signOut() {
    final authService = context.read<AuthServices>();
    authService.signOut();
  }
}
