import 'package:flutter/material.dart';
import 'package:swipeshare_app/old_components/text_styles.dart';

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
          SizedBox(height: vh > 767 ? (vh * 0.20) : (vh * 0.1)),
          Image.asset(
            'assets/onboarding3.png',
            width: vh,
            fit: BoxFit.fitWidth,
          ),

          SizedBox(height: vh > 767 ? 20 : 8),

                Divider(height: vh * 0.02, color: Color.fromRGBO(197, 197, 197, 1), indent: 24, endIndent: 24,),

          SizedBox(height: vh > 767 ? 100 : 35),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
            child: Column(
              children: [
                Text("How to Sell Swipes", style: AppTextStyles.subHeaderStyle),
                SizedBox(height: vh * 0.02),
                Text(
                  "This button adds to the current listing pool!\nPut in all of your preferences and it's be up :)",
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
