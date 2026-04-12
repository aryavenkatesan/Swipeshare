import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/profanity_utils.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final referralController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  void signUp() async {
    final authService = Provider.of<AuthServices>(context, listen: false);

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      await safeVibrate(HapticsType.error);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(SnackbarMessages.fillAllFields)));
      return;
    }

    if (!emailController.text.trim().toLowerCase().endsWith('unc.edu') ||
        (!referralController.text.trim().toLowerCase().endsWith('unc.edu') &&
            referralController.text.isNotEmpty)) {
      await safeVibrate(HapticsType.error);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SnackbarMessages.uncEmailRequired)),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      await safeVibrate(HapticsType.error);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SnackbarMessages.passwordsDontMatch)),
      );
      return;
    }

    if (nameController.text.length > 18) {
      await safeVibrate(HapticsType.error);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(SnackbarMessages.nameToolong)));
      return;
    }

    if (ProfanityUtils.hasProfanityWord(nameController.text)) {
      await safeVibrate(HapticsType.error);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(SnackbarMessages.profanityInName)));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await authService.signUpWithEmailandPassword(
        emailController.text,
        passwordController.text,
        nameController.text,
        referralController.text,
      );
      await safeVibrate(HapticsType.medium);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Reusable input decoration to keep fields consistent ---
  InputDecoration _outlinedInputDecoration({
    required String hintText,
    Widget? suffixIcon,
    required ColorScheme colorScheme,
    required double vh,
  }) {
    return InputDecoration(
      hintText: hintText,
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
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
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

              // --- "Sign Up" title ---
              Text(
                "Sign Up",
                style: textTheme.titleLarge!.copyWith(
                  color: colorScheme.primary,
                ),
              ),

              SizedBox(height: vh > 767 ? 32 : 16),

              // --- Name Field ---
              AutofillGroup(
                child: Column(
                  children: [
                    TextField(
                      key: Key("first-name-field"),
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: _outlinedInputDecoration(
                        hintText: "First Name",
                        colorScheme: colorScheme,
                        vh: vh,
                      ),
                    ),
                    SizedBox(height: vh > 767 ? 16 : 10),

                    // --- Email Field ---
                    TextField(
                      key: Key("email-field"),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: _outlinedInputDecoration(
                        hintText: "Email",
                        colorScheme: colorScheme,
                        vh: vh,
                      ),
                    ),
                    SizedBox(height: vh > 767 ? 16 : 10),

                    // --- Password Field ---
                    TextField(
                      key: Key("password-field"),
                      controller: passwordController,
                      obscureText: _isPasswordObscured,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: _outlinedInputDecoration(
                        hintText: "Password",
                        colorScheme: colorScheme,
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
                        vh: vh,
                      ),
                    ),
                    SizedBox(height: vh > 767 ? 16 : 10),

                    // --- Confirm Password Field ---
                    TextField(
                      key: Key("confirm-password-field"),
                      controller: confirmPasswordController,
                      obscureText: _isConfirmPasswordObscured,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onEditingComplete: () => signUp(),
                      decoration: _outlinedInputDecoration(
                        hintText: "Confirm Password",
                        colorScheme: colorScheme,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordObscured
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordObscured =
                                  !_isConfirmPasswordObscured;
                            });
                          },
                        ),
                        vh: vh,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: vh > 767 ? 24 : 24),

              // --- Register button ---
              SizedBox(
                width: double.infinity,
                height: vh > 767 ? 56 : 44,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => signUp(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    textStyle: textTheme.labelLarge,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Register"),
                ),
              ),

              SizedBox(height: vh > 767 ? 16 : 10),

              // --- "or Log in" link (not shown in screenshot but preserving existing functionality) ---
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
                      "Log in",
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
