import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/old_components/home_screen/deleting_account_screen.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final user = FirebaseAuth.instance.currentUser;
    final password = _passwordController.text;

    if (user == null || user.email == null) {
      setState(
        () => _errorText = "User not found. Please log out and log in again.",
      );
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorText = "Please enter your password.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(cred);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DeletingAccountScreen(),
            fullscreenDialog: true,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = "Incorrect password. Please try again.";
      }
      setState(() {
        _isLoading = false;
        _errorText = errorMessage;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = "An unknown error occurred.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: colorScheme.onSurface,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delete Account",
              style: textTheme.headlineMedium!.copyWith(
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Are you sure you want to delete your account?",
              style: textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This will permanently delete your profile, listings, orders, and messages.",
              style: textTheme.bodyMedium!.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This action cannot be undone.",
              style: textTheme.bodyMedium!.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Enter your password to confirm:",
              style: textTheme.bodyMedium!.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _isPasswordObscured,
              decoration: InputDecoration(
                hintText: "Password",
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
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscured
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(
                      () => _isPasswordObscured = !_isPasswordObscured,
                    );
                  },
                ),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.red.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  textStyle: textTheme.labelLarge,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Delete Account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
