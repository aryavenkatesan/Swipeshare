import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_layout.dart';

class Page1 extends StatelessWidget {
  final bool tutorial;
  const Page1({super.key, required this.tutorial});

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.of(context).size.height;
    final layout = OnboardingLayout.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: layout.topSpacing(vh * 0.03, 0)),
          Image.asset(
            'assets/onboarding1.png',
            width: vh,
            fit: BoxFit.fitWidth,
          ),

          SizedBox(height: layout.sectionSpacing(60, 0)),
          Text(
            tutorial ? 'Welcome to the Tutorial!' : 'Welcome to Swipeshare!',
            style: textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
