import 'package:flutter/material.dart';

class ShutdownPage extends StatelessWidget {
  const ShutdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final double vh = MediaQuery.of(context).size.height;
    final logoSize = vh > 767 ? 120.0 : 90.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: vh > 767 ? 16 : 8),
                  Text(
                    "We're sad to go",
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: vh > 767 ? 64 : 48),
                  Text(
                    'The app is now shut down.',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: vh > 767 ? 14 : 10),
                  Text(
                    'Due to conflicts with UNC dining policy, the app is now shut down.',
                    style: textTheme.bodyLarge?.copyWith(
                      height: 1.55,
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: vh > 767 ? 20 : 14),
                  Divider(
                    color: colorScheme.outlineVariant,
                    thickness: 1,
                  ),
                  SizedBox(height: vh > 767 ? 20 : 14),
                  Text(
                    'Thank you for using Swipeshare.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
