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
          SizedBox(height: vh > 767 ? (vh * 0.14) : (vh * 0.12)),
          Image.asset(
            'assets/onboarding6.png',
            width: vw * 0.4,
            fit: BoxFit.fitWidth,
          ),

          SizedBox(height: vh > 767 ? 150 : 80),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
            child: Column(
              children: [
                Text("Cost", style: AppTextStyles.subHeaderStyle),
                SizedBox(height: vh * 0.02),
                Text(
                  "Using the payment method on the listing, buyers will pay before sellers swipe them in.",
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
