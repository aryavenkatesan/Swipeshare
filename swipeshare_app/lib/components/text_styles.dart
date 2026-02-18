import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';

const String leagueSpartan = 'LeagueSpartan';
const String lexend = 'Lexend';

const TextTheme swipeshareTextTheme = TextTheme(
  // ------------------------------------------------------------------
  // Display / Page greeting  →  "Hi, Arya"
  // League Spartan Bold | 34sp | tracking 0.4
  // ------------------------------------------------------------------
  displayLarge: TextStyle(
    fontFamily: leagueSpartan,
    fontWeight: FontWeight.w700,
    fontSize: 34,
    letterSpacing: 0.4,
    color: Color(0xFF5856D6),
  ),

  // ------------------------------------------------------------------
  // Section headings  →  "Active Orders", "Your Listings"
  // League Spartan SemiBold | 28sp | tracking 0.38
  // ------------------------------------------------------------------
  headlineMedium: TextStyle(
    fontFamily: leagueSpartan,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    letterSpacing: 0.38,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // Screen / nav bar title  →  "Sell Swipes", "Your Listing"
  // League Spartan Bold | 34sp | tracking 0.4
  // Reuses displayLarge metrics; mapped to titleLarge for AppBar use.
  // ------------------------------------------------------------------
  titleLarge: TextStyle(
    fontFamily: leagueSpartan,
    fontWeight: FontWeight.w700,
    fontSize: 34,
    letterSpacing: 0.4,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // Card primary text  →  "Chase 1/13" (bold part)
  // Lexend Medium | 20sp | leading 34 | tracking 0.38
  // ------------------------------------------------------------------
  titleMedium: TextStyle(
    fontFamily: lexend,
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
  bodyLarge: TextStyle(
    fontFamily: lexend,
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
  bodyMedium: TextStyle(
    fontFamily: lexend,
    fontWeight: FontWeight.w400,
    fontSize: 17,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // Dropdown / expandable row label  →  "View Past Listings"
  // Lexend Regular | 20sp
  // ------------------------------------------------------------------
  bodySmall: TextStyle(
    fontFamily: lexend,
    fontWeight: FontWeight.w400,
    fontSize: 20,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // Button label  →  "Next", "Post Listing", "Send Feedback"
  // Lexend Regular | 20sp | white on primary
  // ------------------------------------------------------------------
  labelLarge: TextStyle(
    fontFamily: lexend,
    fontWeight: FontWeight.w400,
    fontSize: 20,
    color: SwipeshareColors.onPrimary,
  ),

  // ------------------------------------------------------------------
  // Tab bar label  →  "Dashboard", "Swipes", "Inbox", "Profile"
  // Lexend Regular | 10sp
  // ------------------------------------------------------------------
  labelSmall: TextStyle(
    fontFamily: lexend,
    fontWeight: FontWeight.w400,
    fontSize: 10,
    color: SwipeshareColors.onBackground,
  ),

  // ------------------------------------------------------------------
  // Inline secondary label  →  date stamp "1/6/25", form sub-labels
  // Lexend Light | 17sp | tracking 0.38
  // ------------------------------------------------------------------
  labelMedium: TextStyle(
    fontFamily: lexend,
    fontWeight: FontWeight.w300,
    fontSize: 17,
    letterSpacing: 0.38,
    color: SwipeshareColors.onBackground,
  ),
);
