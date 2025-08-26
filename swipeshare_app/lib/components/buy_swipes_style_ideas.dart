import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// // Style Preset 1: Current Clean Style
// class BuySwipesCurrentStyle {
//   // Constants
//   static const List<String> locations = ["Chase", "Lenoir"];
//   static const double borderRadius = 12.0;
//   static const Color primaryTextColor = Color(0xFF111827);
//   static const Color greyBackground = Color(0xFFD9D9D9);
//   static const Color borderColor = Color(0xFFE7E7E7);
  
//   // Background
//   static Color? get backgroundColor => Colors.grey[50];
  
//   // Text Styles
//   static TextStyle getTitleStyle(BuildContext context) => const TextStyle(
//     fontSize: 36,
//     fontFamily: 'Instrument Sans',
//     fontWeight: FontWeight.w600,
//     letterSpacing: -1.44,
//     color: primaryTextColor,
//     decoration: TextDecoration.none,
//   );
  
//   static TextStyle bodyTextStyle(BuildContext context, {double? baseFontSize}) => TextStyle(
//     fontSize: baseFontSize ?? 16,
//     fontFamily: 'Instrument Sans',
//     fontWeight: FontWeight.w400,
//     color: Colors.black,
//     letterSpacing: -0.64,
//     decoration: TextDecoration.none,
//   );
  
//   // Location selector style
//   static BoxDecoration getLocationDecoration(BuildContext context, {required bool isSelected}) => BoxDecoration(
//     color: isSelected ? Colors.grey[800] : Colors.white,
//     borderRadius: BorderRadius.circular(borderRadius),
//     border: Border.all(color: Colors.black26),
//   );
  
//   static TextStyle getLocationTextStyle(BuildContext context, {required bool isSelected}) => TextStyle(
//     color: isSelected ? Colors.white : Colors.black,
//     fontWeight: FontWeight.w500,
//   );
  
//   // Date pill style
//   static BoxDecoration getDatePillDecoration(BuildContext context, {required bool isSelected}) => BoxDecoration(
//     color: isSelected ? borderColor : CupertinoColors.systemGrey6,
//     borderRadius: BorderRadius.circular(4),
//   );
  
//   static TextStyle getDatePillTextStyle(BuildContext context) => const TextStyle(
//     fontSize: 12,
//     fontFamily: 'Instrument Sans',
//     fontWeight: FontWeight.w500,
//     color: primaryTextColor,
//     letterSpacing: -0.48,
//     decoration: TextDecoration.none,
//   );
  
//   // Time selection container style
//   static BoxDecoration getTimeContainerDecoration(BuildContext context) => BoxDecoration(
//     color: greyBackground,
//     borderRadius: BorderRadius.circular(10),
//   );
  
//   static Color? get timeIndicatorColor => Colors.grey[800];
  
//   // Time picker text colors
//   static Color getTimePickerTextColor({required bool isHighlighted}) {
//     return isHighlighted ? Colors.white : Colors.black;
//   }
  
//   // Time selector sizing
//   static double getTimeSelectorWidth(BuildContext context) {
//     return 140.0; // Fixed width for simple style
//   }
  
//   static EdgeInsets getTimeSelectorMargin(BuildContext context) {
//     return const EdgeInsets.symmetric(horizontal: 4.0);
//   }
  
//   // Button style
//   static BoxDecoration getButtonDecoration(BuildContext context) => BoxDecoration(
//     color: Colors.white,
//     border: Border.all(color: borderColor),
//     borderRadius: BorderRadius.circular(borderRadius),
//   );
  
//   // Find Seller Button Style
//   static ButtonStyle getFindSellerButtonStyle(BuildContext context) {
//     return ElevatedButton.styleFrom(
//       backgroundColor: Colors.grey[800],
//       foregroundColor: Colors.white,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(borderRadius),
//       ),
//       padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
//     );
//   }
  
//   static TextStyle getFindSellerButtonTextStyle(BuildContext context) {
//     return const TextStyle(
//       fontSize: 18,
//       fontFamily: 'Instrument Sans',
//       fontWeight: FontWeight.w600,
//       color: Colors.white,
//       decoration: TextDecoration.none,
//     );
//   }
  
//   static const TextStyle buttonMainTextStyle = TextStyle(
//     fontSize: 24,
//     fontFamily: 'Instrument Sans',
//     fontWeight: FontWeight.w400,
//     color: primaryTextColor,
//     letterSpacing: -0.96,
//     decoration: TextDecoration.none,
//   );
  
//   static const TextStyle buttonSubTextStyle = TextStyle(
//     fontSize: 10,
//     fontFamily: 'Instrument Sans',
//     fontWeight: FontWeight.w400,
//     color: primaryTextColor,
//     letterSpacing: -0.4,
//     decoration: TextDecoration.none,
//   );
  
//   // Container and layout
//   static const EdgeInsets mainPadding = EdgeInsets.symmetric(horizontal: 24);
//   static Widget wrapWithContainer({required Widget child, required BuildContext context}) => SafeArea(
//     child: Padding(
//       padding: mainPadding,
//       child: child,
//     ),
//   );
// }

// Style Preset 2: Glassmorphism Style (like sell_post.dart) (ACTIVE)
class BuySwipesCurrentStyle {
  // Constants
  static const List<String> locations = ["Chase", "Lenoir"];
  static const Color primaryTextColor = Colors.black;
  
  // Adaptive values based on screen size
  static double getBorderRadius(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth * 0.05).clamp(16.0, 24.0);
  }
  
  static EdgeInsets getMainPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth * 0.06).clamp(20.0, 32.0);
    return EdgeInsets.symmetric(horizontal: horizontalPadding);
  }
  
  static EdgeInsets getContainerPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.05).clamp(16.0, 24.0);
    return EdgeInsets.all(padding);
  }
  
  // Background - transparent for gradient overlay
  static Color? get backgroundColor => Colors.transparent;
  
  // Adaptive Text Styles
  static TextStyle getTitleStyle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.075).clamp(24.0, 32.0);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: primaryTextColor,
      decoration: TextDecoration.none,
    );
  }
  
  static TextStyle bodyTextStyle(BuildContext context, {double? baseFontSize}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final defaultFontSize = screenWidth * 0.04;
    final fontSize = baseFontSize != null 
        ? (baseFontSize * (screenWidth / 375)).clamp(10.0, 24.0)
        : defaultFontSize.clamp(14.0, 18.0);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: primaryTextColor,
      decoration: TextDecoration.none,
    );
  }
  
  // Adaptive Location selector style
  static BoxDecoration getLocationDecoration(BuildContext context, {required bool isSelected}) {
    final borderRadius = getBorderRadius(context) * 0.6; // Smaller radius for location buttons
    return BoxDecoration(
      color: isSelected ? Colors.black : Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.black26),
    );
  }
  
  static TextStyle getLocationTextStyle(BuildContext context, {required bool isSelected}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.04).clamp(14.0, 18.0);
    return TextStyle(
      fontSize: fontSize,
      color: isSelected ? Colors.white : Colors.black,
      fontWeight: FontWeight.w500,
    );
  }
  
  // Adaptive Date pill style
  static BoxDecoration getDatePillDecoration(BuildContext context, {required bool isSelected}) {
    final borderRadius = getBorderRadius(context) * 0.4;
    return BoxDecoration(
      color: isSelected ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.4),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    );
  }
  
  static TextStyle getDatePillTextStyle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.03).clamp(10.0, 14.0);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: primaryTextColor,
      decoration: TextDecoration.none,
    );
  }
  
  // Adaptive Time selection container style
  static BoxDecoration getTimeContainerDecoration(BuildContext context) {
    final borderRadius = getBorderRadius(context) * 0.75;
    return BoxDecoration(
      color: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withOpacity(0.5)),
    );
  }
  
  static Color get timeIndicatorColor => Colors.black.withOpacity(0.7);
  
  // Time picker text colors (for glassmorphism, keep white when highlighted)
  static Color getTimePickerTextColor({required bool isHighlighted}) {
    return isHighlighted ? Colors.white : Colors.black;
  }
  
  // Adaptive Time selector sizing
  static double getTimeSelectorWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerMargins = getMainPadding(context).horizontal;
    final containerPadding = getContainerPadding(context).horizontal;
    final availableWidth = screenWidth - containerMargins - containerPadding;
    final selectorWidth = (availableWidth * 0.42).clamp(100.0, 180.0);
    return selectorWidth;
  }
  
  static EdgeInsets getTimeSelectorMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final marginSize = (screenWidth * 0.01).clamp(2.0, 6.0);
    return EdgeInsets.symmetric(horizontal: marginSize);
  }
  
  static double getTimeSelectorHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (screenHeight * 0.06).clamp(44.0, 56.0);
  }
  
  // Adaptive Button style
  static BoxDecoration getButtonDecoration(BuildContext context) {
    final borderRadius = getBorderRadius(context);
    return BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    );
  }
  
  static TextStyle getButtonMainTextStyle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.06).clamp(20.0, 28.0);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: primaryTextColor,
      decoration: TextDecoration.none,
    );
  }
  
  static TextStyle getButtonSubTextStyle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.025).clamp(8.0, 12.0);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: primaryTextColor,
      decoration: TextDecoration.none,
    );
  }
  
  // Find Seller Button Style (glassmorphism style)
  static ButtonStyle getFindSellerButtonStyle(BuildContext context) {
    final borderRadius = getBorderRadius(context);
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black.withOpacity(0.8),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.symmetric(
        vertical: (MediaQuery.of(context).size.width * 0.04).clamp(16.0, 20.0),
        horizontal: (MediaQuery.of(context).size.width * 0.06).clamp(24.0, 32.0),
      ),
    );
  }
  
  static TextStyle getFindSellerButtonTextStyle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.045).clamp(16.0, 20.0);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      decoration: TextDecoration.none,
    );
  }
  
  // Background with gradient
  static Widget get backgroundGradient => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF98D2EB),
          Color(0xFFDCEAFF),
          Color(0xFFDCEAFF),
          Color(0xFFA2A0DD),
        ],
        stops: [0.0, 0.3, 0.75, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );
  
  // Adaptive Glassmorphism container
  static Widget wrapWithContainer({required Widget child, required BuildContext context}) {
    final borderRadius = getBorderRadius(context);
    final containerMargin = getMainPadding(context);
    final containerPadding = getContainerPadding(context);
    
    return Stack(
      children: [
        backgroundGradient,
        SafeArea(
          child: Padding(
            padding: containerMargin,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  padding: containerPadding,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Adaptive Interactive elements
  static BoxDecoration getInteractiveDecoration(BuildContext context) {
    final borderRadius = getBorderRadius(context) * 0.6;
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.black12),
    );
  }
  
  static EdgeInsets getInteractivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final verticalPadding = (screenWidth * 0.035).clamp(12.0, 18.0);
    final horizontalPadding = (screenWidth * 0.04).clamp(14.0, 20.0);
    return EdgeInsets.symmetric(
      vertical: verticalPadding,
      horizontal: horizontalPadding,
    );
  }
}

// // Style Preset 3: Home Style
// class BuySwipesCurrentStyle {
//   static const List<String> locations = ["Chase", "Lenoir"];
//   static const Color primaryTextColor = Color.fromARGB(255, 27, 27, 27);
//   static const Color accentBlue = Color(0xFF98D2EB); // Blue accent like home page
//   static Color? get backgroundColor => const Color(0xFFFEF8FF);
  
//   // Adaptive values based on screen size
//   static double getBorderRadius(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return (screenWidth * 0.03).clamp(8.0, 12.0);
//   }
  
//   static EdgeInsets getMainPadding(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final horizontalPadding = (screenWidth * 0.08).clamp(24.0, 40.0);
//     return EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12.0);
//   }
  
//   static EdgeInsets getContainerPadding(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final padding = (screenWidth * 0.04).clamp(16.0, 20.0);
//     return EdgeInsets.all(padding);
//   }
  
//   static TextStyle getTitleStyle(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final fontSize = (screenWidth * 0.075).clamp(24.0, 32.0);
//     return GoogleFonts.instrumentSans(
//       fontSize: fontSize,
//       fontWeight: FontWeight.w600,
//       letterSpacing: -1.0,
//       color: primaryTextColor,
//       decoration: TextDecoration.none,
//     );
//   }
  
//   static TextStyle bodyTextStyle(BuildContext context, {double? baseFontSize}) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final fontSize = baseFontSize != null 
//         ? (baseFontSize * (screenWidth / 375)).clamp(12.0, 20.0)
//         : (screenWidth * 0.04).clamp(14.0, 18.0);
//     return GoogleFonts.instrumentSans(
//       fontSize: fontSize,
//       fontWeight: FontWeight.w400,
//       color: primaryTextColor,
//       decoration: TextDecoration.none,
//     );
//   }
  
//   static BoxDecoration getLocationDecoration(BuildContext context, {required bool isSelected}) {
//     final borderRadius = getBorderRadius(context);
//     return BoxDecoration(
//       color: isSelected ? accentBlue.withOpacity(0.1) : Colors.white.withOpacity(0.6),
//       borderRadius: BorderRadius.circular(borderRadius),
//       border: Border.all(
//         color: isSelected ? accentBlue : const Color(0xFFE7E7E7),
//         width: 2,
//       ),
//     );
//   }
  
//   static TextStyle getLocationTextStyle(BuildContext context, {required bool isSelected}) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final fontSize = (screenWidth * 0.04).clamp(14.0, 18.0);
//     return GoogleFonts.instrumentSans(
//       fontSize: fontSize,
//       color: isSelected ? primaryTextColor : primaryTextColor,
//       fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//     );
//   }
  
//   static BoxDecoration getDatePillDecoration(BuildContext context, {required bool isSelected}) {
//     final borderRadius = getBorderRadius(context);
//     return BoxDecoration(
//       color: isSelected ? accentBlue.withOpacity(0.2) : Colors.white.withOpacity(0.6),
//       borderRadius: BorderRadius.circular(borderRadius),
//       border: Border.all(
//         color: isSelected ? accentBlue : const Color(0xFFE7E7E7),
//         width: isSelected ? 2 : 1,
//       ),
//     );
//   }
  
//   static TextStyle getDatePillTextStyle(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final fontSize = (screenWidth * 0.03).clamp(12.0, 16.0);
//     return GoogleFonts.instrumentSans(
//       fontSize: fontSize,
//       fontWeight: FontWeight.w500,
//       color: primaryTextColor,
//       decoration: TextDecoration.none,
//     );
//   }
  
//   static BoxDecoration getTimeContainerDecoration(BuildContext context) {
//     final borderRadius = getBorderRadius(context);
//     return BoxDecoration(
//       color: Colors.white.withOpacity(0.6),
//       borderRadius: BorderRadius.circular(borderRadius),
//       border: Border.all(color: const Color(0xFFE7E7E7), width: 2),
//     );
//   }
  
//   static Color get timeIndicatorColor => accentBlue.withOpacity(0.3);
  
//   static Color getTimePickerTextColor({required bool isHighlighted}) {
//     return primaryTextColor;
//   }
  
//   static double getTimeSelectorWidth(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final containerMargins = getMainPadding(context).horizontal;
//     final containerPadding = getContainerPadding(context).horizontal;
//     final availableWidth = screenWidth - containerMargins - containerPadding;
//     final selectorWidth = (availableWidth * 0.42).clamp(120.0, 180.0);
//     return selectorWidth;
//   }
  
//   static EdgeInsets getTimeSelectorMargin(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final marginSize = (screenWidth * 0.01).clamp(4.0, 8.0);
//     return EdgeInsets.symmetric(horizontal: marginSize);
//   }
  
//   static BoxDecoration getButtonDecoration(BuildContext context) {
//     final borderRadius = getBorderRadius(context);
//     return BoxDecoration(
//       color: Colors.white.withOpacity(0.6),
//       borderRadius: BorderRadius.circular(borderRadius),
//       border: Border.all(color: accentBlue, width: 2),
//     );
//   }
  
//   static ButtonStyle getFindSellerButtonStyle(BuildContext context) {
//     final borderRadius = getBorderRadius(context);
//     return ElevatedButton.styleFrom(
//       backgroundColor: accentBlue,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(borderRadius),
//       ),
//       padding: EdgeInsets.symmetric(
//         vertical: (MediaQuery.of(context).size.width * 0.04).clamp(16.0, 20.0),
//         horizontal: (MediaQuery.of(context).size.width * 0.06).clamp(24.0, 32.0),
//       ),
//     );
//   }
  
//   static TextStyle getFindSellerButtonTextStyle(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final fontSize = (screenWidth * 0.045).clamp(16.0, 20.0);
//     return GoogleFonts.instrumentSans(
//       fontSize: fontSize,
//       fontWeight: FontWeight.w600,
//       color: Colors.white,
//       decoration: TextDecoration.none,
//     );
//   }
  
//   static TextStyle getButtonMainTextStyle(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final fontSize = (screenWidth * 0.045).clamp(16.0, 20.0);
//     return GoogleFonts.instrumentSans(
//       fontSize: fontSize,
//       fontWeight: FontWeight.w500,
//       color: primaryTextColor,
//       decoration: TextDecoration.none,
//     );
//   }
  
//   static TextStyle getButtonSubTextStyle(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final fontSize = (screenWidth * 0.025).clamp(10.0, 14.0);
//     return GoogleFonts.instrumentSans(
//       fontSize: fontSize,
//       fontWeight: FontWeight.w400,
//       color: primaryTextColor.withOpacity(0.7),
//       decoration: TextDecoration.none,
//     );
//   }
  
//   static Widget wrapWithContainer({required Widget child, required BuildContext context}) {
//     return SafeArea(
//       child: Padding(
//         padding: getMainPadding(context),
//         child: child,
//       ),
//     );
//   }
// }