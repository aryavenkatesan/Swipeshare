import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/home_screen/deleting_account_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class Hyperlinks extends StatelessWidget {
  Hyperlinks({super.key});

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext dialogContext) {
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
                Text('This will permanently delete:'),
                SizedBox(height: 8),
                Text('• Your profile'),
                Text('• All your listings'),
                Text('• All your orders'),
                Text('• All your messages'),
                SizedBox(height: 12),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Close dialog first
                Navigator.of(dialogContext).pop();

                // Then navigate to deletion screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DeletingAccountScreen(),
                    fullscreenDialog: true,
                  ),
                );
              },
              child: Text('Delete Account'),
            ),
          ],
        );
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
