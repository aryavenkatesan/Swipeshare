import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/onboarding/dashboard_mockup.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_layout.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_mock_controllers.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_slide_scaffold.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  late final OnboardingPage4Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingPage4Controller();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCardTap(int index) async {
    await safeVibrate(HapticsType.selection);
    if (!mounted) return;
    _controller.selectCard(index);
  }

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.of(context).size.height;
    final layout = OnboardingLayout.of(context);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return OnboardingSlideScaffold(
          topSpacing: layout.topSpacing(vh * 0.03, 8),
          topContent: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: OnboardingDashboardMockup(
              selectedCard: _controller.selectedCard,
              onCardTap: _onCardTap,
            ),
          ),
          spacingBeforeDivider: layout.sectionSpacing(30, 16),
          spacingAfterDivider: layout.sectionSpacing(30, 16),
          infoTitle: _controller.title,
          infoPadding: EdgeInsets.symmetric(
            horizontal: layout.horizontalBodyPadding,
          ),
          infoBody: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _controller.description,
              key: ValueKey(_controller.description),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
