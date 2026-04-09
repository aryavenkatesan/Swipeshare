import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_layout.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_mock_controllers.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_slide_scaffold.dart';
import 'package:swipeshare_app/components/onboarding/swipes_marketplace_mockup.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class OnboardingBrowseSwipesSlide extends StatefulWidget {
  const OnboardingBrowseSwipesSlide({super.key});

  @override
  State<OnboardingBrowseSwipesSlide> createState() =>
      _OnboardingBrowseSwipesSlideState();
}

class _OnboardingBrowseSwipesSlideState
    extends State<OnboardingBrowseSwipesSlide> {
  late final OnboardingPage2Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingPage2Controller();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLocationFilter(String location) async {
    await safeVibrate(HapticsType.selection);
    if (!mounted) return;
    _controller.toggleLocation(location);
  }

  void _onCardTap(int index) async {
    await safeVibrate(HapticsType.selection);
    if (!mounted) return;
    _controller.selectListing(index);
  }

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.of(context).size.height;
    final layout = OnboardingLayout.of(context);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final detailsText = _controller.selectedListingIndex == null
            ? 'Tap a listing to coordinate with the seller.\nUse filters to narrow your search!'
            : 'These are active listings posted by other users.\nIn the real app, you can open one to view details and coordinate.';

        return OnboardingSlideScaffold(
          topSpacing: layout.topSpacing(vh * 0.03, vh * 0.01),
          topContent: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: OnboardingSwipesMarketplaceMockup(
              activeLocationFilters: _controller.activeLocationFilters,
              onToggleLocation: _toggleLocationFilter,
              selectedListingIndex: _controller.selectedListingIndex,
              onListingTap: _onCardTap,
            ),
          ),
          spacingBeforeDivider: layout.sectionSpacing(40, 24),
          spacingAfterDivider: layout.sectionSpacing(40, 24),
          infoTitle: 'How to Buy Swipes',
          infoPadding: EdgeInsets.symmetric(
            horizontal: layout.horizontalBodyPadding,
          ),
          infoBody: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              detailsText,
              key: ValueKey(detailsText),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
