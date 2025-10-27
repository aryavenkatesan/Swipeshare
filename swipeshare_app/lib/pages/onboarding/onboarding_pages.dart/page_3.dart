import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/text_styles.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: vh > 767 ? (vh * 0.14) : (vh * 0.1)),
          Image.asset(
            'assets/onboarding3.png',
            width: vh,
            fit: BoxFit.fitWidth,
          ),

          SizedBox(height: vh > 767 ? 100 : 50),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
            child: Column(
              children: [
                Text("Sell Swipes", style: AppTextStyles.subHeaderStyle),
                SizedBox(height: vh * 0.02),
                Text(
                  "If you have too many meal swipes, click on the sell button to put up a listing!",
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
