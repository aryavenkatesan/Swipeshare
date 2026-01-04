import 'package:flutter/material.dart';

/// App-wide color constants
class AppColors {
  // Primary colors
  static const Color primaryText = Color.fromARGB(255, 27, 27, 27);
  static const Color accentBlue = Color(0xFF98D2EB);
  static const Color background = Color(0xFFFEF8FF);

  // Secondary colors
  static const Color borderGrey = Color(0xFFE7E7E7);
  static const Color subText = Color(0xFF6C7278);
  static const Color headerText = Color(0xFF111827);
  static const Color greyText = Color.fromARGB(108, 55, 58, 64);

  // Interactive colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Opacity variants
  static Color accentBlueLight = accentBlue.withValues(alpha: 0.1);
  static Color accentBlueMedium = accentBlue.withValues(alpha: 0.2);
  static Color accentBlueIndicator = accentBlue.withValues(alpha: 0.3);
  static Color whiteTransparent = white.withValues(alpha: 0.6);
  static Color primaryTextLight = primaryText.withValues(alpha: 0.7);
}
