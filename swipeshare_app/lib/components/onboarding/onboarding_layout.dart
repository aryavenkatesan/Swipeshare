import 'package:flutter/material.dart';

class OnboardingLayout {
  final bool isTall;
  final double horizontalBodyPadding;

  const OnboardingLayout._({
    required this.isTall,
    required this.horizontalBodyPadding,
  });

  factory OnboardingLayout.of(BuildContext context) {
    final vh = MediaQuery.of(context).size.height;
    return OnboardingLayout._(
      isTall: vh > 767,
      horizontalBodyPadding: vh * 0.03,
    );
  }

  double topSpacing(double tallValue, double compactValue) {
    return isTall ? tallValue : compactValue;
  }

  double sectionSpacing(double tallValue, double compactValue) {
    return isTall ? tallValue : compactValue;
  }
}
