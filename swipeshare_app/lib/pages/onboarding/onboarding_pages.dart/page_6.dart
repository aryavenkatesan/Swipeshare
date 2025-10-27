import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/text_styles.dart';

class Page6 extends StatelessWidget {
  final bool tutorial;
  const Page6({super.key, required this.tutorial});

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;
    final double vw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: vh > 767 ? (vh * 0.09) : (vh * 0.04)),
          Image.asset(
            'assets/onboarding6.png',
            width: vw * 0.8,
            fit: BoxFit.fitWidth,
          ),

          SizedBox(height: vh > 767 ? 100 : 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
            child: Column(
              children: [
                Text(
                  tutorial ? "Don't Forget!" : "Let's get started!",
                  style: AppTextStyles.subHeaderStyle,
                ),

                SizedBox(height: vh * 0.02),

                Text(
                  tutorial
                      ? "Whenever using the app, always make sure to be courteous and respectful!"
                      : "Please check your email inbox for the verification email- it may have gone to spam if you don't see it initially!",
                  style: AppTextStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
