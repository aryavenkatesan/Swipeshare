
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/pages/onboarding/forgot_password/forgot_password_page.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  bool _isPasswordObscured = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      await safeVibrate(HapticsType.error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(SnackbarMessages.enterEmailAndPassword)),
        );
      }
      return;
    }

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
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final double vh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Logo clipped inside grey circle ---
              Container(
                width: vh > 767 ? 120 : 90,
                height: vh > 767 ? 120 : 90,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/logo.png',
                  width: vh > 767 ? 120 : 90,
                  height: vh > 767 ? 120 : 90,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: vh > 767 ? 16 : 8),

              // --- "Login" title ---
              Text(
                "Login",
                style: textTheme.titleLarge!.copyWith(
                  color: colorScheme.primary,
                ),
              ),

              SizedBox(height: vh > 767 ? 32 : 16),

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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: vh > 767 ? 20 : 10,
                    vertical: vh > 767 ? 18 : 9,
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

              SizedBox(height: vh > 767 ? 16 : 10),

              // --- Password field ---
              TextField(
                controller: passwordController,
                obscureText: _isPasswordObscured,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: colorScheme.outlineVariant),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: vh > 767 ? 20 : 10,
                    vertical: vh > 767 ? 18 : 9,
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // --- Remember me + Forgot password row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(color: colorScheme.outlineVariant),
                          activeColor: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Remember me",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(color: colorScheme.primary, fontSize: 14),
                    ),
                  ),
                ],
              ),

              SizedBox(height: vh > 767 ? 24 : 24),

              // --- Log in button ---
              SizedBox(
                width: double.infinity,
                height: vh > 767 ? 56 : 44,
                child: ElevatedButton(
                  onPressed: () async {
                    signIn();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    textStyle: textTheme.labelLarge,
                  ),
                  child: const Text("Log in"),
                ),
              ),

              SizedBox(height: vh > 767 ? 16 : 10),

              // --- "or Sign up" ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "or ",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
