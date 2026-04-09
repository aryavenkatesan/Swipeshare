import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/onboarding/listing_form_mockup.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_layout.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_mock_controllers.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_slide_scaffold.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  late final OnboardingPage3Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingPage3Controller();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onButtonTap() async {
    await safeVibrate(HapticsType.selection);
    if (!mounted) return;
    _controller.toggleForm();
  }

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.of(context).size.height;
    final layout = OnboardingLayout.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return OnboardingSlideScaffold(
          topSpacing: layout.topSpacing(vh * 0.06, vh * 0.03),
          topContent: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GestureDetector(
                  onTap: _onButtonTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: _controller.showForm
                          ? colorScheme.primary.withValues(alpha: 0.85)
                          : colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _controller.showForm
                          ? []
                          : [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
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
                          style: (textTheme.labelLarge ?? const TextStyle())
                              .copyWith(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.vertical,
                        axisAlignment: -1.0,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.08),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: _controller.showForm
                    ? const Padding(
                        key: ValueKey('sell-form'),
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: OnboardingListingFormMockup(),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty-form')),
              ),
            ],
          ),
          spacingBeforeDivider: _controller.showForm
              ? 12
              : layout.sectionSpacing(20, 8),
          spacingAfterDivider: layout.sectionSpacing(24, 12),
          infoTitle: _controller.showForm ? null : 'How to Sell Swipes',
          infoPadding: EdgeInsets.symmetric(
            horizontal: layout.horizontalBodyPadding,
          ),
          infoBody: AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _controller.showForm
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const Text(
              'Tap the button to create a new listing!',
              textAlign: TextAlign.center,
            ),
            secondChild: const Text(
              'Select your preferences — dining hall, time,\nprice, and payment — then post it!',
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
