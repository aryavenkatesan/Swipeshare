import 'package:flutter/material.dart';
import 'package:swipeshare_app/services/auth/auth_gate.dart';
import 'package:swipeshare_app/services/user_service.dart';

class DeletingAccountScreen extends StatefulWidget {
  const DeletingAccountScreen({super.key});

  @override
  State<DeletingAccountScreen> createState() => _DeletingAccountScreenState();
}

class _DeletingAccountScreenState extends State<DeletingAccountScreen> {
  final UserService _userService = UserService();
  String _statusMessage = 'Preparing to delete account...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _deleteAccount();
  }

  // In _DeletingAccountScreenState

  Future<void> _deleteAccount() async {
    try {
      setState(() {
        _statusMessage = 'Preparing to delete account...';
      });
      await Future.delayed(Duration(milliseconds: 300));

      setState(() {
        _statusMessage = 'Deleting listings...';
      });
      await Future.delayed(Duration(milliseconds: 300));

      setState(() {
        _statusMessage = 'Deleting orders and messages...';
      });

      await _userService.deleteAccount();

      setState(() {
        _statusMessage = 'Account deleted successfully!';
      });

      // Wait a moment before navigating
      await Future.delayed(Duration(milliseconds: 500));

      if (mounted) {
        // Navigate to login screen - replace with your actual LoginScreen widget
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                AuthGate(), // Replace with your actual login screen
          ),
          (route) => false, // This removes all previous routes
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusMessage = 'Error: ${e.toString()}';
      });

      // Show error for 3 seconds, then go back
      await Future.delayed(Duration(seconds: 3));

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button during deletion
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_hasError) ...[
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF98D2EB),
                      ),
                    ),
                    SizedBox(height: 32),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Please wait, this may take a moment...',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Icon(Icons.error_outline, color: Colors.red, size: 64),
                    SizedBox(height: 24),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Returning to settings...',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
