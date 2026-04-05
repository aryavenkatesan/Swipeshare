import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Swipeshare 2026 – Design Tokens
// ---------------------------------------------------------------------------

class SwipeshareColors {
  SwipeshareColors._();

  static const Color primary = Color(0xFF5856D6);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF000000);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF000000);

  static const Color outline = Color(0xFF000000);
  static const Color outlineVariant = Color.fromARGB(255, 182, 182, 182);

  /// Grey left-bar accent used on active order cards.
  static const Color cardAccent = Color(0xFF999999);

  /// Darker grey for secondary/subdued text.
  static const Color subtleText = Color(0xFF4E4E4E);

  /// Rating chip / secondary container background.
  static const Color secondaryContainer = Color(0xFFDDDDDD);
  static const Color onSecondaryContainer = Color(0xFF000000);

  static const Color secondary = Color(0xFF21272A);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFB00020);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color shadow = Color(0x4D000000);
}

// ---------------------------------------------------------------------------
// ColorScheme
// ---------------------------------------------------------------------------

const ColorScheme swipeshareColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: SwipeshareColors.primary,
  onPrimary: SwipeshareColors.onPrimary,
  primaryContainer: SwipeshareColors.primary,
  onPrimaryContainer: SwipeshareColors.onPrimary,
  secondary: SwipeshareColors.secondary,
  onSecondary: SwipeshareColors.onSecondary,
  secondaryContainer: SwipeshareColors.secondaryContainer,
  onSecondaryContainer: SwipeshareColors.onSecondaryContainer,
  surface: SwipeshareColors.surface,
  onSurface: SwipeshareColors.onSurface,
  error: SwipeshareColors.error,
  onError: SwipeshareColors.onError,
  outline: SwipeshareColors.outline,
  outlineVariant: SwipeshareColors.outlineVariant,
  shadow: SwipeshareColors.shadow,
  surfaceTint: SwipeshareColors.cardAccent,
);
