import 'package:swipeshare_app/pages/home_page.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_1.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_2.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_3.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_4.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';

//TODO: Clean this code and conduct edge case checking

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  PageController _controller = PageController();
  bool onLastPage = false;
  final auth = FirebaseAuth.instance;
  late User user;
  bool didSendEmail = false;

  Timer? _emailVerificationTimer;
  bool _isCheckingVerification = false;

  @override
  void dispose() {
    // Cancel timer when widget is disposed
    _emailVerificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = auth.currentUser!;
    if (!didSendEmail) {
      print("=== INITIAL EMAIL SEND ===");
      print("didSendEmail flag: $didSendEmail");
      _sendVerificationEmail();
      didSendEmail = true;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text("Welcome!"),
        actions: [
          //signout button
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 500,
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  onLastPage = (index == 3);
                });
              },
              children: [Page1(), Page2(), Page3(), Page4()],
            ),
          ),
          SizedBox(height: 30),
          Container(
            height: 50,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                !onLastPage
                    ? GestureDetector(
                        onTap: () {
                          _controller.jumpToPage(3);
                        },
                        child: Text("skip"),
                      )
                    : GestureDetector(
                        onTap: () {
                          _sendVerificationEmail();
                        },
                        child: Text("    resend "),
                      ),

                SmoothPageIndicator(
                  controller: _controller,
                  count: 4,
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
                        child: Text("next"),
                      )
                    : GestureDetector(
                        onTap: () {
                          checkEmailVerified();
                        },
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
                          child: Text(
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
          SizedBox(height: 50),
        ],
      ),
    );
  }

  void _startEmailVerificationLoop() {
    if (_isCheckingVerification) return; // Prevent multiple timers

    setState(() {
      _isCheckingVerification = true;
    });

    // Show snackbar to inform user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checking for email verification...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    // Check immediately first
    checkEmailVerified();

    // Then start the timer for periodic checks
    _emailVerificationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        checkEmailVerified();
      } else {
        timer.cancel();
      }
    });

    // Stop checking after 5 minutes (60 checks)
    Timer(Duration(minutes: 2), () {
      if (_emailVerificationTimer?.isActive == true) {
        _emailVerificationTimer?.cancel();
        if (mounted) {
          setState(() {
            _isCheckingVerification = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification check timed out. Please try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    });
  }

  Future<void> checkEmailVerified() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.reload();

      print("Checking email verification status: ${user.emailVerified}");

      if (user.emailVerified) {
        // Cancel the timer
        _emailVerificationTimer?.cancel();

        if (mounted) {
          setState(() {
            _isCheckingVerification = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    } catch (e) {
      print("Error checking email verification: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking verification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      print("=== SENDING VERIFICATION EMAIL ===");
      print("Attempting to send email to: ${user.email}");
      print("Current time: ${DateTime.now()}");

      await user.sendEmailVerification();

      print("✅ Email verification sent successfully!");
      print("================================");

      // Show success snackbar
      if (mounted & onLastPage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print("❌ ERROR SENDING VERIFICATION EMAIL");
      print("Error Type: ${e.runtimeType}");
      print("Error Message: $e");
      print("Stack Trace: $stackTrace");

      // Check for specific Firebase Auth errors
      if (e is FirebaseAuthException) {
        print("Firebase Auth Error Code: ${e.code}");
        print("Firebase Auth Error Message: ${e.message}");

        // Handle specific error codes
        String userMessage = "Failed to send email";
        switch (e.code) {
          case 'too-many-requests':
            userMessage = "Too many requests. Please try again later.";
            break;
          case 'user-not-found':
            userMessage = "User not found.";
            break;
          case 'invalid-email':
            userMessage = "Invalid email address.";
            break;
        }

        // Show error snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userMessage), backgroundColor: Colors.red),
          );
        }
      }
      print("================================");
    }
  }

  void signOut() {
    //get auth service
    final authService = Provider.of<AuthServices>(context, listen: false);

    authService.signOut();
  }
}
