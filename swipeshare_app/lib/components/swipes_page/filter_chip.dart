import 'package:flutter/material.dart';

/// A toggleable pill chip used in the swipes filter sheet.
/// Selected = blue bg, unselected = white bg. Always has a black border.
class SwipesFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SwipesFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE2ECF9) : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w300,
              ),
        ),
      ),
    );
  }
}
