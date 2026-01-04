import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/home_screen/deleting_account_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Required for re-authentication

class Hyperlinks extends StatelessWidget {
  const Hyperlinks({super.key});

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext dialogContext) {
        // We pass the main BuildContext to the dialog for navigation
        return _DeleteAccountDialog(parentContext: context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await launchUrl(
              Uri.parse(
                "https://docs.google.com/forms/d/e/1FAIpQLSfTmI3DIHP85a78MlNmQ9gUicQhjff5Tj34pWsUhvN6ATzGXg/viewform",
              ),
              mode: LaunchMode.inAppBrowserView,
            );
          },
          child: Center(child: Text("Give us Feedback!", style: SubTextStyle)),
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () => _showDeleteConfirmation(context),
          child: Center(
            child: Text(
              "Delete Account",
              style: SubTextStyle.copyWith(color: Colors.redAccent),
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () async {
                await launchUrl(
                  Uri.parse("https://swipeshare.app/privacy-policy"),
                  mode: LaunchMode.inAppBrowserView,
                );
              },
              child: Center(child: Text("Privacy Policy", style: SubTextStyle)),
            ),
            GestureDetector(
              onTap: () async {
                await launchUrl(
                  Uri.parse("https://swipeshare.app/terms-of-service"),
                  mode: LaunchMode.inAppBrowserView,
                );
              },
              child: Center(
                child: Text("Terms of Service", style: SubTextStyle),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A stateful widget to handle the logic inside the delete confirmation dialog
class _DeleteAccountDialog extends StatefulWidget {
  // We need the parent context to navigate to the DeletingAccountScreen
  final BuildContext parentContext;

  const _DeleteAccountDialog({required this.parentContext});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Re-authenticates the user and proceeds to deletion.
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
      // 1. Create the credential
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      // 2. Re-authenticate
      await user.reauthenticateWithCredential(cred);

      // 3. Success! Close the dialog
      if (mounted) Navigator.of(context).pop();

      // 4. Navigate to the deletion processing screen
      if (widget.parentContext.mounted) {
        Navigator.of(widget.parentContext).push(
          MaterialPageRoute(
            builder: (context) => DeletingAccountScreen(),
            fullscreenDialog: true,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 5. Handle failure
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
    return AlertDialog(
      title: Text('Delete Account'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'This will permanently delete your profile, listings, orders, and messages.',
            ),
            SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // --- NEW PASSWORD FIELD ---
            Text(
              'Please enter your password to confirm:',
              style: TextStyle(fontSize: 14),
            ),
            TextField(
              controller: _passwordController,
              obscureText: _isPasswordObscured,
              autofocus: true, // Automatically focus the password field
              decoration: InputDecoration(
                hintText: "Password",
                // Using Underline style from your login page
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 30, 88, 181),
                  ),
                ),
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
            // --- END NEW PASSWORD FIELD ---
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _errorText!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          // Disable button while loading
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          // Disable button while loading
          onPressed: _isLoading ? null : _handleDelete,
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Delete Account'),
        ),
      ],
    );
  }
}
