import 'package:flutter/material.dart';

class OnboardingSlideScaffold extends StatelessWidget {
  final double topSpacing;
  final Widget topContent;
  final double spacingBeforeDivider;
  final double spacingAfterDivider;
  final String? infoTitle;
  final Widget infoBody;
  final EdgeInsetsGeometry infoPadding;

  const OnboardingSlideScaffold({
    super.key,
    required this.topSpacing,
    required this.topContent,
    required this.spacingBeforeDivider,
    required this.spacingAfterDivider,
    this.infoTitle,
    required this.infoBody,
    required this.infoPadding,
  });

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.of(context).size.height;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: topSpacing),
            topContent,
            SizedBox(height: spacingBeforeDivider),
            Divider(
              height: vh * 0.02,
              color: const Color.fromRGBO(197, 197, 197, 1),
              indent: 24,
              endIndent: 24,
            ),
            SizedBox(height: spacingAfterDivider),
            Padding(
              padding: infoPadding,
              child: Column(
                children: [
                  if (infoTitle != null) ...[
                    Text(infoTitle!, style: textTheme.headlineMedium),
                    SizedBox(height: vh * 0.02),
                  ],
                  DefaultTextStyle.merge(
                    style: textTheme.bodyLarge ?? const TextStyle(),
                    child: infoBody,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
