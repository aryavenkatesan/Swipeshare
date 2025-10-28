import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
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

  //sign up user
  void signUp() async {
    // make it unc email only
    if (!emailController.text.trim().toLowerCase().endsWith('unc.edu') ||
        (!referralController.text.trim().toLowerCase().endsWith('unc.edu') &&
            referralController.text != '')) {
      if (await Haptics.canVibrate()) {
        Haptics.vibrate(HapticsType.error);
      }
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
      if (await Haptics.canVibrate()) {
        Haptics.vibrate(HapticsType.error);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Passwords don't match")));
      return;
    }

    //make sure name isn't too long (13 characters or less)
    if (nameController.text.length > 14) {
      if (await Haptics.canVibrate()) {
        Haptics.vibrate(HapticsType.error);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Name is too long, consider using a nickname!")),
      );
      return;
    }

    //make sure name is apropriate
    if (ProfanityUtils.hasProfanityWord(nameController.text)) {
      if (await Haptics.canVibrate()) {
        Haptics.vibrate(HapticsType.error);
      }
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
        if (await Haptics.canVibrate()) {
          Haptics.vibrate(HapticsType.medium);
        }
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
                  Color(0xFF98D2EB),
                  Color(0xFFDCEAFF),
                  Color(0xFFDCEAFF),
                  Color(0xFFA2A0DD),
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
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
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
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: 'First Name*',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              hintText: 'Email*',
                            ),
                          ),

                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              hintText: 'Password*',
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: confirmPasswordController,
                            decoration: const InputDecoration(
                              hintText: 'Confirm Password*',
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: referralController,
                            decoration: const InputDecoration(
                              hintText: 'Referral Email',
                            ),
                          ),
                          const SizedBox(height: 24),
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
