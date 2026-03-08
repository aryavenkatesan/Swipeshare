import 'package:flutter/material.dart';
import 'package:swipeshare_app/old_components/text_styles.dart';

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: vh > 767 ? (vh * 0.05) : 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Image.asset(
              'assets/onboarding4.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),

          SizedBox(height: 15),

          Divider(height: vh * 0.02, color: Color.fromRGBO(197, 197, 197, 1), indent: 24, endIndent: 24,),
          SizedBox(height: vh > 767 ? 48 : 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
            child: Column(
              children: [
                Text("Dashboard", style: AppTextStyles.subHeaderStyle),
                SizedBox(height: vh * 0.02),
                Text(
                  "View your current orders and active listings!\nMake edits to them by clicking!",
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
