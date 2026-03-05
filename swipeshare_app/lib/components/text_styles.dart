import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshare_app/components/colors.dart';

TextTheme swipeshareTextTheme = TextTheme(
  // ------------------------------------------------------------------
  // Display / Page greeting  →  "Hi, Arya"
  // League Spartan Bold | 34sp | tracking 0.4
  // ------------------------------------------------------------------
  displayLarge: GoogleFonts.leagueSpartan(
    fontWeight: FontWeight.w700,
    fontSize: 34,
    letterSpacing: 0.4,
    color: SwipeshareColors.primary,
  ),

  // ------------------------------------------------------------------
  // Section headings  →  "Active Orders", "Your Listings"
  // League Spartan SemiBold | 28sp | tracking 0.38
  // ------------------------------------------------------------------
  headlineMedium: GoogleFonts.leagueSpartan(
    fontWeight: FontWeight.w600,
    fontSize: 28,
    letterSpacing: 0.38,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // Screen / nav bar title  →  "Sell Swipes", "Your Listing"
  // League Spartan Bold | 34sp | tracking 0.4
  // ------------------------------------------------------------------
  titleLarge: GoogleFonts.leagueSpartan(
    fontWeight: FontWeight.w700,
    fontSize: 34,
    letterSpacing: 0.4,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // Card primary text  →  "Chase 1/13" (bold part)
  // Lexend Medium | 20sp | leading 34 | tracking 0.38
  // ------------------------------------------------------------------
  titleMedium: GoogleFonts.lexend(
    fontWeight: FontWeight.w500,
    fontSize: 20,
    height: 34 / 20,
    letterSpacing: 0.38,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // Card secondary / form field label  →  "From 3:30 PM to 4:00 PM",
  //                                       "Select a day", "Payment Options"
  // Lexend Light | 17sp | leading 34 | tracking 0.38
  // ------------------------------------------------------------------
  bodyLarge: GoogleFonts.lexend(
    fontWeight: FontWeight.w300,
    fontSize: 17,
    height: 34 / 17,
    letterSpacing: 0.38,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // General body / form hints  →  "Tap to select payment methods",
  //                                description text on listing creation
  // Lexend Regular | 17sp
  // ------------------------------------------------------------------
  bodyMedium: GoogleFonts.lexend(
    fontWeight: FontWeight.w400,
    fontSize: 17,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // Dropdown / expandable row label  →  "View Past Listings"
  // Lexend Regular | 20sp
  // ------------------------------------------------------------------
  bodySmall: GoogleFonts.lexend(
    fontWeight: FontWeight.w400,
    fontSize: 20,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // Button label  →  "Next", "Post Listing", "Send Feedback"
  // Lexend Regular | 20sp | white on primary
  // ------------------------------------------------------------------
  labelLarge: GoogleFonts.lexend(
    fontWeight: FontWeight.w400,
    fontSize: 20,
    color: SwipeshareColors.onPrimary,
  ),

  // ------------------------------------------------------------------
  // Tab bar label  →  "Dashboard", "Swipes", "Inbox", "Profile"
  // Lexend Regular | 10sp
  // ------------------------------------------------------------------
  labelSmall: GoogleFonts.lexend(
    fontWeight: FontWeight.w400,
    fontSize: 10,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // Inline secondary label  →  date stamp "1/6/25", form sub-labels
  // Lexend Light | 17sp | tracking 0.38
  // ------------------------------------------------------------------
  labelMedium: GoogleFonts.lexend(
    fontWeight: FontWeight.w300,
    fontSize: 17,
    letterSpacing: 0.38,
    color: SwipeshareColors.onBackground,
  ),
);
