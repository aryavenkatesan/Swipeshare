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
import 'package:swipeshare_app/services/email_verification_service.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final PageController _controller = PageController();
  final _verificationService = EmailVerificationService();

  bool onLastPage = false;
  bool _isCheckingVerification = false;

  @override
  void initState() {
    super.initState();
    _verificationService.sendVerificationEmail();
  }

  @override
  void dispose() {
    _verificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            //genuinly does not work on iphone se at 0.7 or 0.68
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                final newOnLastPage = (index == 5);
                if (newOnLastPage && newOnLastPage != onLastPage) {
                  _awaitEmailVerification();
                } else {
                  _stopEmailVerification();
                }

                setState(() {
                  onLastPage = newOnLastPage;
                });
              },
              children: [
                Page1(),
                Page2(),
                Page3(),
                Page4(),
                Page5(),
                Page6(tutorial: false),
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
                  !onLastPage
                      ? GestureDetector(
                          onTap: () {
                            _controller.jumpToPage(5);
                          },
                          child: Text("skip"),
                        )
                      : GestureDetector(
                          onTap: () {
                            _verificationService.sendVerificationEmail();
                            _awaitEmailVerification();
                          },
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
                          onTap: () => _awaitEmailVerification(),
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

  Future<void> _awaitEmailVerification() async {
    if (_isCheckingVerification) return;

    setState(() => _isCheckingVerification = true);

    try {
      await _verificationService.awaitVerification();

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
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification check timed out. Please try again.'),
            backgroundColor: Colors.orange,
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
        setState(() => _isCheckingVerification = false);
      }
    }
  }

  void _stopEmailVerification() {
    if (!_isCheckingVerification) return;

    _verificationService.dispose();
    setState(() => _isCheckingVerification = false);
  }

  void signOut() {
    final authService = context.read<AuthServices>();
    authService.signOut();
  }
}
