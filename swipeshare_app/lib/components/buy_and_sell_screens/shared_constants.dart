import 'package:flutter/material.dart';

/// Shared constants for buy and sell screens
class BuySwipesConstants {
  // Locations
  static const List<String> locations = ["Chase", "Lenoir"];
  
  // Standard spacing values
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  
  // Standard border radius
  static const double borderRadius = 12.0;
  
  // Standard padding values
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
  static const EdgeInsets containerPadding = EdgeInsets.all(16.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
  
  // Layout Helper
  static Widget wrapWithContainer({required Widget child, required BuildContext context}) {
    return SafeArea(
      child: Padding(
        padding: screenPadding,
        child: child,
      ),
    );
  }
}
