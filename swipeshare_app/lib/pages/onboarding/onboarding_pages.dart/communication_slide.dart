import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/onboarding/chat_mockup.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_layout.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_slide_scaffold.dart';

class OnboardingCommunicationSlide extends StatelessWidget {
  const OnboardingCommunicationSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.of(context).size.height;
    final layout = OnboardingLayout.of(context);

    return OnboardingSlideScaffold(
      topSpacing: layout.topSpacing(vh * 0.06, vh * 0.03),
      topContent: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: const OnboardingChatMockup(),
      ),
      spacingBeforeDivider: layout.sectionSpacing(60, 30),
      spacingAfterDivider: layout.sectionSpacing(30, 16),
      infoTitle: 'Communicate',
      infoIcon: Icons.chat_outlined,
      infoPadding: EdgeInsets.symmetric(
        horizontal: layout.horizontalBodyPadding,
      ),
      infoBody: const Text(
        'Coordinate a time and place to meet with your partner.\nPay before you get swiped in!',
        textAlign: TextAlign.center,
      ),
    );
  }
}
