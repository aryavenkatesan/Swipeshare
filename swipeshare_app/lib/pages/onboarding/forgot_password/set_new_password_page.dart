import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class SetNewPasswordPage extends StatefulWidget {
  final String email;
  final String token;
  const SetNewPasswordPage({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleReset() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 8 characters."),
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Calling the new Cloud Function to update the password
      await FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('updateUserPassword').call({
        'email': widget.email, // Match: request.data.email
        'newPassword':
            password, // Match: request.data.newPassword (NOT 'password')
        'token': widget.token, // Match: request.data.token
      });

      await safeVibrate(HapticsType.success);
      if (mounted) {
        // Return to login screen
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Password updated! Please log in with your new password.",
            ),
          ),
        );
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
          // Fixed background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB8E1F5),
                  Color(0xFFE8F2FF),
                  Color(0xFFE8F2FF),
                  Color(0xFFC4C1ED),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Set Password",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Please enter and confirm your new password below.",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "New Password",
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "Confirm Password",
                          ),
                        ),
                        const SizedBox(height: 36),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleReset,
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Reset Password"),
                          ),
                        ),
                      ],
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
