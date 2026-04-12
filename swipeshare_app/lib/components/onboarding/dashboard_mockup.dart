import 'package:flutter/material.dart';

class OnboardingDashboardMockup extends StatelessWidget {
  final int? selectedCard;
  final ValueChanged<int> onCardTap;

  const OnboardingDashboardMockup({
    super.key,
    required this.selectedCard,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Orders',
          style: (textTheme.headlineMedium ?? const TextStyle()).copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _MockDashboardCard(
          location: 'Chase',
          date: '1/13',
          time: 'From 3:30 PM to 4:00 PM',
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
          isTapped: selectedCard == 0,
          onTap: () => onCardTap(0),
          primaryColor: colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Your Listings',
          style: (textTheme.headlineMedium ?? const TextStyle()).copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _MockDashboardCard(
          location: 'Chase',
          date: '1/13',
          time: 'From 3:30 PM to 4:00 PM',
          trailing: Icon(Icons.more_horiz, color: Colors.grey.shade600),
          isTapped: selectedCard == 1,
          onTap: () => onCardTap(1),
          primaryColor: colorScheme.primary,
        ),
      ],
    );
  }
}

class _MockDashboardCard extends StatelessWidget {
  final String location;
  final String date;
  final String time;
  final Widget trailing;
  final bool isTapped;
  final VoidCallback onTap;
  final Color primaryColor;

  const _MockDashboardCard({
    required this.location,
    required this.date,
    required this.time,
    required this.trailing,
    required this.isTapped,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isTapped ? primaryColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTapped ? primaryColor : const Color(0xFFE0E0E0),
            width: isTapped ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        location,
                        style: (textTheme.bodyLarge ?? const TextStyle())
                            .copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Text(date, style: textTheme.labelMedium),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: (textTheme.labelMedium ?? const TextStyle())
                        .copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
