import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/pages/onboarding/forgot_password/set_new_password_page.dart';
import 'package:swipeshare_app/services/auth/email_code_verification_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _isCodeShowing = false;
  bool _isLoading = false;

  final emailController = TextEditingController();
  final codeController = TextEditingController();

  final EmailCodeVerificationService _verificationService =
      EmailCodeVerificationService();

  @override
  void initState() {
    super.initState();
    emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
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

  Future<void> handleAction() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SnackbarMessages.enterStudentEmail)),
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

        String? token = await _verificationService.verifyForgotPasswordCode(
          email: email,
          code: code,
        );

        if (token != null) {
          await safeVibrate(HapticsType.success);

          if (mounted) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: colorScheme.onSurface, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Title ---
              Text(
                "Forgot Password?",
                style: textTheme.headlineMedium!.copyWith(
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "We'll send a verification code to your email.",
                style: textTheme.bodyMedium!.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // --- Email field ---
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: colorScheme.outlineVariant),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // --- Code field (conditionally shown) ---
              if (_isCodeShowing) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontSize: 24, letterSpacing: 16),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "------",
                    hintStyle: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 16,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // --- Action button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : handleAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor: colorScheme.primary.withValues(
                      alpha: 0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    textStyle: textTheme.labelLarge,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(!_isCodeShowing ? "Send Code" : "Verify Code"),
                ),
              ),
              SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
