import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/old_components/text_styles.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  bool _showForm = false;

  void _onButtonTap() async {
    await safeVibrate(HapticsType.selection);
    setState(() => _showForm = !_showForm);
  }

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: vh > 767 ? (vh * 0.06) : (vh * 0.03)),

            // Interactive "+ Sell a Swipe" button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: _onButtonTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: _showForm
                        ? colorScheme.primary.withValues(alpha: 0.85)
                        : colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _showForm
                        ? []
                        : [
                            BoxShadow(
                              color: colorScheme.primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "Sell a Swipe",
                        style:
                            AppTextStyles.buttonText.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mock listing form that appears when tapped
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showForm
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _MockListingForm(colorScheme: colorScheme),
              ),
            ),

            SizedBox(height: _showForm ? 12 : (vh > 767 ? 20 : 8)),

            Divider(
              height: vh * 0.02,
              color: const Color.fromRGBO(197, 197, 197, 1),
              indent: 24,
              endIndent: 24,
            ),

            SizedBox(height: vh > 767 ? 24 : 12),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
              child: Column(
                children: [
                  if (!_showForm) ...[
                    Text("How to Sell Swipes",
                        style: AppTextStyles.subHeaderStyle),
                    SizedBox(height: vh * 0.015),
                  ],
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: _showForm
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Text(
                      "Tap the button to create a new listing!",
                      style: AppTextStyles.bodyText,
                      textAlign: TextAlign.center,
                    ),
                    secondChild: Text(
                      "Select your preferences — dining hall, time,\nprice, and payment — then post it!",
                      style: AppTextStyles.bodyText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A static mock of the listing form fields (not interactive).
class _MockListingForm extends StatelessWidget {
  final ColorScheme colorScheme;

  const _MockListingForm({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dining hall toggle
        Row(
          children: [
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Center(
                  child: Text("Lenoir", style: textTheme.bodyLarge),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Center(
                  child: Text("Chase", style: textTheme.bodyLarge),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Date field
        _MockFieldCard(
          icon: Icons.calendar_today,
          label: "Today",
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 10),

        // Time range
        Row(
          children: [
            Expanded(
              child: _MockFieldCard(
                icon: Icons.access_time,
                label: "1:00 PM",
                colorScheme: colorScheme,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text("to", style: textTheme.bodyMedium),
            ),
            Expanded(
              child: _MockFieldCard(
                icon: Icons.access_time,
                label: "2:00 PM",
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Price
        _MockFieldCard(
          icon: Icons.attach_money,
          label: "\$5",
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MockStepperButton(icon: Icons.remove, colorScheme: colorScheme),
              const SizedBox(width: 8),
              _MockStepperButton(icon: Icons.add, colorScheme: colorScheme),
            ],
          ),
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 10),

        // Payment options
        _MockFieldCard(
          icon: Icons.payment,
          label: "Payment Options",
          trailing: Text(
            "3 selected",
            style: textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _MockFieldCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final ColorScheme colorScheme;

  const _MockFieldCard({
    required this.icon,
    required this.label,
    this.trailing,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _MockStepperButton extends StatelessWidget {
  final IconData icon;
  final ColorScheme colorScheme;

  const _MockStepperButton({
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Icon(icon, size: 16, color: Colors.grey.shade600),
    );
  }
}
