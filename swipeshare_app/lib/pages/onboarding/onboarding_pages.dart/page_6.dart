import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/onboarding/onboarding_layout.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class Page6 extends StatelessWidget {
  final List<String> selectedPaymentOptions;
  final ValueChanged<List<String>> onPaymentOptionsChanged;

  const Page6({
    super.key,
    required this.selectedPaymentOptions,
    required this.onPaymentOptionsChanged,
  });

  void _toggleOption(BuildContext context, String option) async {
    await safeVibrate(HapticsType.selection);
    if (!context.mounted) return;
    final updated = List<String>.from(selectedPaymentOptions);
    if (updated.contains(option)) {
      updated.remove(option);
    } else {
      updated.add(option);
    }
    onPaymentOptionsChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.of(context).size.height;
    final layout = OnboardingLayout.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SizedBox(height: layout.topSpacing(vh * 0.02, 8)),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: layout.horizontalBodyPadding,
            ),
            child: Column(
              children: [
                Text('Payment', style: textTheme.headlineMedium),
                SizedBox(height: vh * 0.01),
                Text(
                  'Select your preferred payment methods.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Divider(height: 1, color: Color(0xFFE0E0E0)),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: PaymentOption.allPaymentOptions.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
              itemBuilder: (context, index) {
                final option = PaymentOption.allPaymentOptions[index];
                final isSelected = selectedPaymentOptions.contains(option.name);
                return _PaymentOptionTile(
                  option: option,
                  isSelected: isSelected,
                  primaryColor: colorScheme.primary,
                  onTap: () => _toggleOption(context, option.name),
                );
              },
            ),
          ),

          if (selectedPaymentOptions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Select at least one to continue',
                style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                  color: Colors.red.shade400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final PaymentOption option;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.option,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      splashColor: primaryColor.withValues(alpha: 0.08),
      highlightColor: primaryColor.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 22,
              color: isSelected ? primaryColor : Colors.grey.shade500,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.name,
                style: textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                key: ValueKey(isSelected),
                size: 22,
                color: isSelected ? primaryColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
