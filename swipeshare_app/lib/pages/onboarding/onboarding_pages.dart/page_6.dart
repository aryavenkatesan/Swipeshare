import 'package:flutter/material.dart';
import 'package:swipeshare_app/old_components/text_styles.dart';

class Page6 extends StatelessWidget {
  const Page6({super.key});

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;
    final double vw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: vh > 767 ? (vh * 0.10) : (vh * 0.04)),
          Image.asset(
            'assets/onboarding6.png',
            width: vw * 0.75,
            fit: BoxFit.fitWidth,
          ),

          SizedBox(height: vh > 767 ? 30 : 0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
            child: Column(
              children: [
                Text("Cost", style: AppTextStyles.subHeaderStyle),
                SizedBox(height: vh * 0.02),
                Text(
                  "Using the payment method on the listing, buyers will pay in person before sellers swipe them in.",
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
