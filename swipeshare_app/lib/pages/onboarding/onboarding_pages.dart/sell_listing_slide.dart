import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/onboarding/listing_form_mockup.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_layout.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_slide_scaffold.dart';

class OnboardingSellListingSlide extends StatelessWidget {
  const OnboardingSellListingSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.of(context).size.height;
    final layout = OnboardingLayout.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return OnboardingSlideScaffold(
      topSpacing: layout.topSpacing(vh * 0.06, vh * 0.03),
      topContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Sell a Swipe',
                    style: (textTheme.labelLarge ?? const TextStyle()).copyWith(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: OnboardingListingFormMockup(),
          ),
        ],
      ),
      spacingBeforeDivider: layout.sectionSpacing(20, 8),
      spacingAfterDivider: layout.sectionSpacing(24, 12),
      infoTitle: 'Sell Swipes',
      infoIcon: Icons.attach_money_rounded,
      infoPadding: EdgeInsets.symmetric(
        horizontal: layout.horizontalBodyPadding,
      ),
      infoBody: const Text(
        'Select your preferences: dining hall, time, price, and payment - then post it!',
        textAlign: TextAlign.center,
      ),
    );
  }
}
