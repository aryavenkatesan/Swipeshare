import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A pill chip used in the swipes page filter row.
/// Selected = blue bg, unselected = white bg. Always has a black border.
class Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const Pill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE2ECF9) : Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.w300,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
