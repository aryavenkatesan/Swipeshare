import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_layout.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_slide_scaffold.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class OnboardingStarsFeedbackSlide extends StatefulWidget {
  const OnboardingStarsFeedbackSlide({super.key});

  @override
  State<OnboardingStarsFeedbackSlide> createState() =>
      _OnboardingStarsFeedbackSlideState();
}

class _OnboardingStarsFeedbackSlideState
    extends State<OnboardingStarsFeedbackSlide> {
  int _selectedStars = 0;

  Future<void> _onStarTap(int stars) async {
    await safeVibrate(HapticsType.light);
    if (!mounted) return;
    setState(() => _selectedStars = stars);
  }

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.of(context).size.height;
    final layout = OnboardingLayout.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return OnboardingSlideScaffold(
      topSpacing: layout.topSpacing(vh * 0.03, vh * 0.015),
      topContent: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How did your swipe go?',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                _StarsRow(
                  selectedStars: _selectedStars,
                  onStarTap: _onStarTap,
                ),
                const SizedBox(height: 16),
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Tell us more (optional)',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.surfaceTint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      spacingBeforeDivider: layout.sectionSpacing(36, 22),
      spacingAfterDivider: layout.sectionSpacing(28, 16),
      infoTitle: 'Stars',
      infoIcon: Icons.star_rounded,
      infoPadding: EdgeInsets.symmetric(horizontal: layout.horizontalBodyPadding),
      infoBody: Text(
        'After each completed order, leave a quick star rating and optional feedback to help keep the community safe and reliable.',
        textAlign: TextAlign.center,
        style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(height: 1.25),
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final int selectedStars;
  final ValueChanged<int> onStarTap;

  const _StarsRow({
    required this.selectedStars,
    required this.onStarTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final starSize = (constraints.maxWidth / 6).clamp(32.0, 50.0);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            final filled = starNumber <= selectedStars;
            return GestureDetector(
              onTap: () => onStarTap(starNumber),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                color: colors.onSurface,
                size: starSize,
              ),
            );
          }),
        );
      },
    );
  }
}