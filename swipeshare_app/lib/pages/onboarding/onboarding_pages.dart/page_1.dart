import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swipeshare_app/components/text_styles.dart';

class Page1 extends StatelessWidget {
  final bool tutorial;
  const Page1({super.key, required this.tutorial});

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: vh > 767 ? (vh * 0.03) : 0),
          Image.asset(
            'assets/onboarding1.png',
            width: vh,
            fit: BoxFit.fitWidth,
          ),

          SizedBox(height: vh > 767 ? 60 : 0),
          tutorial
              ? Text(
                  "Welcome to the Tutorial!",
                  style: AppTextStyles.subHeaderStyle,
                )
              : Text(
                  "Welcome to Swipeshare!",
                  style: AppTextStyles.subHeaderStyle,
                ),
        ],
      ),
    );
  }
}
