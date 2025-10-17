import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class Hyperlinks extends StatelessWidget {
  const Hyperlinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          //This should always be at the bottom
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
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              //This should always be at the bottom
              onTap: () async {
                await launchUrl(
                  Uri.parse("https://swipeshare.app/privacy-policy"),
                  mode: LaunchMode.inAppBrowserView,
                );
              },
              child: Center(child: Text("Privacy Policy", style: SubTextStyle)),
            ),
            GestureDetector(
              //This should always be at the bottom
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
