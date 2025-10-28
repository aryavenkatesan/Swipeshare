import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/text_styles.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: (vh * 0.1)),
          // The Row is no longer needed
          Image.asset(
            'assets/onboarding2.png',
            // 1. Set the width to the full screen width
            width: vh,

            // 2. Tell the image to scale to fill that width,
            // maintaining its aspect ratio.
            fit: BoxFit.fitWidth,
          ),

          SizedBox(height: vh > 767 ? 100 : 50),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
            child: Column(
              children: [
                Text("Buy Swipes", style: AppTextStyles.subHeaderStyle),
                SizedBox(height: vh * 0.02),
                Text(
                  "If you want to be swiped in, select your availability and connect with a seller!",
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
