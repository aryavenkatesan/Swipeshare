import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  // controls whether the password is obscured
  bool _isPasswordObscured = true;
  //text controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //sign in user
  void signIn() async {
    //get the auth service
    final authService = Provider.of<AuthServices>(context, listen: false);

    try {
      await authService.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
      await safeVibrate(HapticsType.medium);
    } catch (e) {
      await safeVibrate(HapticsType.error);
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
      // This property is true by default, which is what we want
      // when using a SingleChildScrollView.
      // resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Gradient background (remains fixed)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB8E1F5), // Lightened from 0xFF98D2EB
                  Color(0xFFE8F2FF), // Lightened from 0xFFDCEAFF
                  Color(0xFFE8F2FF), // Lightened from 0xFFDCEAFF
                  Color(0xFFC4C1ED),
                ],
                stops: [0.0, 0.3, 0.75, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // This makes the card scrollable when the keyboard appears
          Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              //scrollview is important so when the onscreen keyboard comes up, the app doesn't blow up
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
                          const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Enter your email and password to log in.",
                            style: TextStyle(color: Colors.black87),
                            textAlign: TextAlign.center, // Good for aesthetics
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: emailController,
                            obscureText: false,
                            // THIS IS THE FIX for the email keyboard
                            keyboardType: TextInputType.emailAddress,
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
                              hintText: "Email",
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: _isPasswordObscured,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 30, 88, 181),
                                ), // Highlight when focused
                              ),
                              // --- End of UI Change ---
                              fillColor: const Color.fromARGB(0, 3, 168, 244),
                              filled: true,
                              hintText: "Password",
                              hintStyle: const TextStyle(color: Colors.grey),
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
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value ?? false;
                                      });
                                    },
                                  ),
                                  const Text("Remember me"),
                                ],
                              ),
                              Flexible(
                                // Using Flexible is better here
                                child: TextButton(
                                  onPressed: () {
                                    //TODO: Forgot Password
                                  },
                                  child: const Text(
                                    "Forgot Password?",
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () async {
                              signIn();
                            },
                            child: const Center(child: Text("Log In")),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Or",
                            style: TextStyle(color: Colors.black45),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              "Register Now",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
