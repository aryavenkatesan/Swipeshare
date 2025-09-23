import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshare_app/components/colors.dart';

/// App-wide text styles using consistent typography
class AppTextStyles {
  // Header styles
  static final headerStyle = GoogleFonts.instrumentSans(
    color: AppColors.headerText,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    decoration: TextDecoration.none,
  );

  static final greyHeaderStyle = GoogleFonts.instrumentSans(
    color: AppColors.greyText,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    decoration: TextDecoration.none,
  );

  static final subHeaderStyle = GoogleFonts.instrumentSans(
    color: AppColors.headerText,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    decoration: TextDecoration.none,
  );

  // Page title style
  static final pageTitle = GoogleFonts.instrumentSans(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.0,
    color: AppColors.primaryText,
    decoration: TextDecoration.none,
  );

  // Body text styles
  static final bodyText = GoogleFonts.instrumentSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
    decoration: TextDecoration.none,
  );

  static final subText = GoogleFonts.instrumentSans(
    color: AppColors.subText,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.56,
    decoration: TextDecoration.none,
  );

  // Button text styles
  static final buttonText = GoogleFonts.instrumentSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    decoration: TextDecoration.none,
  );

  // Component-specific styles
  static final locationText = GoogleFonts.instrumentSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
    decoration: TextDecoration.none,
  );

  static final locationTextSelected = GoogleFonts.instrumentSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    decoration: TextDecoration.none,
  );

  static final datePillText = GoogleFonts.instrumentSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
    decoration: TextDecoration.none,
  );

  static final timeLabelText = GoogleFonts.instrumentSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
    decoration: TextDecoration.none,
  );

  static final timeValueText = GoogleFonts.instrumentSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    decoration: TextDecoration.none,
  );

  static final validationText = GoogleFonts.instrumentSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
    decoration: TextDecoration.none,
  );

  static final successText = GoogleFonts.instrumentSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
    decoration: TextDecoration.none,
  );
}

// Legacy exports for backward compatibility
final HeaderStyle = AppTextStyles.headerStyle;
final GreyHeaderStyle = AppTextStyles.greyHeaderStyle;
final SubHeaderStyle = AppTextStyles.subHeaderStyle;
final SubTextStyle = AppTextStyles.subText;