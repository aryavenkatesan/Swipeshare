import 'package:flutter/material.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

const _diningHalls = ['Lenoir', 'Chase'];

/// A pair of toggle buttons for selecting a single dining hall.
class DiningHallSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;

  const DiningHallSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _diningHalls.asMap().entries.map((entry) {
        final index = entry.key;
        final hall = entry.value;
        final isSelected = selected == hall;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? 8 : 0,
              right: index < _diningHalls.length - 1 ? 8 : 0,
            ),
            child: _DiningHallButton(
              label: hall,
              isSelected: isSelected,
              onTap: () async {
                await safeVibrate(HapticsType.selection);
                onChanged(hall);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DiningHallButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DiningHallButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 45,
        decoration: BoxDecoration(
          color: isSelected ? colors.secondaryContainer : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline),
        ),
        child: Center(
          child: Text(label, style: textTheme.bodyLarge),
        ),
      ),
    );
  }
}
