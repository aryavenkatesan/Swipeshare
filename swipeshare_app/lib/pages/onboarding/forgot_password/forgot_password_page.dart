import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/pages/onboarding/forgot_password/set_new_password_page.dart';
import 'package:swipeshare_app/services/auth/email_code_verification_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Logic states
  bool _isCodeShowing = false;
  bool _isLoading = false;

  // Controllers
  final emailController = TextEditingController();
  final codeController = TextEditingController();

  // Service instance
  final EmailCodeVerificationService _verificationService =
      EmailCodeVerificationService();

  @override
  void initState() {
    super.initState();
    // FIX: Listener to hide the code field if the user changes their email
    emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    // FIX: Clean up controllers to prevent memory leaks
    emailController.removeListener(_onEmailChanged);
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    if (_isCodeShowing) {
      setState(() {
        _isCodeShowing = false;
        codeController.clear();
      });
    }
  }

  // Inside _ForgotPasswordPageState in forgot_password_page.dart

  Future<void> handleAction() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your student email.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!_isCodeShowing) {
        await _verificationService.sendForgotPasswordCode(targetEmail: email);
        await safeVibrate(HapticsType.medium);
        setState(() => _isCodeShowing = true);
      } else {
        if (code.length < 6) {
          throw Exception("Please enter the full 6-digit code.");
        }

        // FIX: Call the service once and get the token
        String? token = await _verificationService.verifyForgotPasswordCode(
          email: email,
          code: code,
        );

        if (token != null) {
          await safeVibrate(HapticsType.success);

          if (mounted) {
            // Navigate to the final reset page with the email and token
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SetNewPasswordPage(email: email, token: token),
              ),
            );
          }
        } else {
          throw Exception("Verification failed. No security token received.");
        }
      }
    } catch (e) {
      await safeVibrate(HapticsType.error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB8E1F5),
                  Color(0xFFE8F2FF),
                  Color(0xFFE8F2FF),
                  Color(0xFFC4C1ED),
                ],
                stops: [0.0, 0.3, 0.75, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            "We'll send a verification code to your email.",
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: emailController,
                            obscureText: false,
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 30, 88, 181),
                                ),
                              ),
                              fillColor: Colors.transparent,
                              filled: true,
                              hintText: "Student Email",
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),

                          if (_isCodeShowing)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 32.0,
                                left: 16.0,
                                right: 16.0,
                              ),
                              child: TextField(
                                controller: codeController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 6,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(
                                  fontSize: 24,
                                  letterSpacing: 16,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "------",
                                  hintStyle: const TextStyle(
                                    fontSize: 24,
                                    letterSpacing: 16,
                                    color: Colors.grey,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 30, 88, 181),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 36),

                          ElevatedButton(
                            onPressed: _isLoading ? null : handleAction,
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      !_isCodeShowing
                                          ? "Send Code"
                                          : "Verify Code",
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
