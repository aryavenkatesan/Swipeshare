import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/profanity_utils.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final referralController = TextEditingController();

  // State variables for password visibility
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  //sign up user
  void signUp() async {
    // make it unc email only
    if (!emailController.text.trim().toLowerCase().endsWith('unc.edu') ||
        (!referralController.text.trim().toLowerCase().endsWith('unc.edu') &&
            referralController.text.isNotEmpty)) {
      // Changed from != ''
      await safeVibrate(HapticsType.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please use a valid UNC email address (ending with @unc.edu)",
          ),
        ),
      );
      return;
    }

    //password matching check
    if (passwordController.text != confirmPasswordController.text) {
      await safeVibrate(HapticsType.error);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Passwords don't match")));
      return;
    }

    //make sure name isn't too long (18 characters or less)
    if (nameController.text.length > 18) {
      await safeVibrate(HapticsType.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Name is too long, consider using a nickname!")),
      );
      return;
    }

    //make sure name is appropriate
    if (ProfanityUtils.hasProfanityWord(nameController.text)) {
      await safeVibrate(HapticsType.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Name contains profanity, please change.")),
      );
      return;
    }

    //get auth service
    final authService = Provider.of<AuthServices>(context, listen: false);

    try {
      await authService.signUpWithEmailandPassword(
        emailController.text,
        passwordController.text,
        nameController.text,
        referralController.text,
      );
      if (mounted) {
        await safeVibrate(HapticsType.medium);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => OnboardingCarousel()),
        // );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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

          // Frosted glass card
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
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // child: Image.asset(
                              Image.asset(
                                'assets/logo.png',
                                width: 60,
                                height: 60,
                              ),
                              // SizedBox(width: 8),
                              // Text("Swipeshare", style: SubHeaderStyle),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Column(
                              children: const [
                                Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Create an account to continue!",
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- Name Field ---
                          TextField(
                            controller: nameController,
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
                              fillColor: const Color.fromARGB(0, 3, 168, 244),
                              filled: true,
                              hintText: "First Name*",
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- Email Field ---
                          TextField(
                            controller: emailController,
                            keyboardType:
                                TextInputType.emailAddress, // Email keyboard
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
                              fillColor: const Color.fromARGB(0, 3, 168, 244),
                              filled: true,
                              hintText: "Email*",
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // --- Password Field ---
                          TextField(
                            controller: passwordController,
                            obscureText:
                                _isPasswordObscured, // Use state variable
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
                              fillColor: const Color.fromARGB(0, 3, 168, 244),
                              filled: true,
                              hintText: "Password*",
                              hintStyle: const TextStyle(color: Colors.grey),
                              // Eye Icon Toggle
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordObscured = !_isPasswordObscured;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- Confirm Password Field ---
                          TextField(
                            controller: confirmPasswordController,
                            obscureText:
                                _isConfirmPasswordObscured, // Use state variable
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
                              fillColor: const Color.fromARGB(0, 3, 168, 244),
                              filled: true,
                              hintText: "Confirm Password*",
                              hintStyle: const TextStyle(color: Colors.grey),
                              // Eye Icon Toggle
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordObscured =
                                        !_isConfirmPasswordObscured;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- Referral Field ---
                          // TextField(
                          //   controller: referralController,
                          //   keyboardType:
                          //       TextInputType.emailAddress, // Email keyboard
                          //   decoration: InputDecoration(
                          //     enabledBorder: UnderlineInputBorder(
                          //       borderSide: BorderSide(
                          //         color: Colors.grey.shade400,
                          //       ),
                          //     ),
                          //     focusedBorder: const UnderlineInputBorder(
                          //       borderSide: BorderSide(
                          //         color: Color.fromARGB(255, 30, 88, 181),
                          //       ),
                          //     ),
                          //     fillColor: const Color.fromARGB(0, 3, 168, 244),
                          //     filled: true,
                          //     hintText: "Referral Email (Optional)",
                          //     hintStyle: const TextStyle(color: Colors.grey),
                          //   ),
                          // ),
                          // const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => signUp(),
                            child: const Center(child: Text("Register")),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: GestureDetector(
                              onTap: widget.onTap,
                              child: const Text(
                                "Login Now",
                                style: TextStyle(fontWeight: FontWeight.bold),
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
