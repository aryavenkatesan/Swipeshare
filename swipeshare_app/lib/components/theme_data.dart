import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';

ThemeData swipeshareTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: swipeshareColorScheme,
    textTheme: swipeshareTextTheme,
    scaffoldBackgroundColor: SwipeshareColors.background,
    dividerColor: SwipeshareColors.outlineVariant,
    dividerTheme: const DividerThemeData(
      color: SwipeshareColors.outlineVariant,
      thickness: 1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: SwipeshareColors.background,
      foregroundColor: SwipeshareColors.onBackground,
      elevation: 0,
      titleTextStyle: swipeshareTextTheme.titleLarge?.copyWith(
        color: SwipeshareColors.primary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SwipeshareColors.primary,
        foregroundColor: SwipeshareColors.onPrimary,
        minimumSize: const Size.fromHeight(55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: swipeshareTextTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SwipeshareColors.onBackground,
        side: const BorderSide(color: SwipeshareColors.outline),
        minimumSize: const Size(93, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: swipeshareTextTheme.bodyMedium,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: SwipeshareColors.outline),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: SwipeshareColors.outline),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: SwipeshareColors.primary, width: 2),
      ),
      labelStyle: swipeshareTextTheme.bodySmall,
      hintStyle: swipeshareTextTheme.bodyLarge,
    ),
    cardTheme: const CardThemeData(
      color: SwipeshareColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: SwipeshareColors.outline),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: SwipeshareColors.secondaryContainer,
      labelStyle: swipeshareTextTheme.bodySmall?.copyWith(
        color: SwipeshareColors.onSecondaryContainer,
      ),
      shape: const StadiumBorder(),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: SwipeshareColors.background,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll(swipeshareTextTheme.labelSmall!),
    ),
  );
}
