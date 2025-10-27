import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swipeshare_app/components/text_styles.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: vh > 767 ? (vh * 0.03) : 0),
          // The Row is no longer needed
          Image.asset(
            'assets/onboarding1.png',
            // 1. Set the width to the full screen width
            width: vh,

            // 2. Tell the image to scale to fill that width,
            // maintaining its aspect ratio.
            fit: BoxFit.fitWidth,
          ),

          SizedBox(height: vh > 767 ? 60 : 0),
          Text("Welcome to Swipeshare!", style: AppTextStyles.subHeaderStyle),
        ],
      ),
    );
  }
}
