import 'package:flutter/material.dart';

class OnboardingSlideScaffold extends StatelessWidget {
  final double topSpacing;
  final Widget topContent;
  final double spacingBeforeDivider;
  final double spacingAfterDivider;
  final String? infoTitle;
  final IconData? infoIcon;
  final Widget infoBody;
  final EdgeInsetsGeometry infoPadding;

  const OnboardingSlideScaffold({
    super.key,
    required this.topSpacing,
    required this.topContent,
    required this.spacingBeforeDivider,
    required this.spacingAfterDivider,
    this.infoTitle,
    this.infoIcon,
    required this.infoBody,
    required this.infoPadding,
  });

  static const double _designWidth = 400;

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.of(context).size.height;
    final vw = MediaQuery.of(context).size.width;
    final textTheme = Theme.of(context).textTheme;
    final layoutWidth = vw > _designWidth ? vw : _designWidth;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: layoutWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                              Builder(
                                builder: (context) {
                                  final titleSize =
                                      textTheme.headlineMedium?.fontSize ?? 24;
                                  final iconBoxSize = titleSize * 1.5;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (infoIcon != null) ...[
                                        Container(
                                          width: iconBoxSize,
                                          height: iconBoxSize,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              iconBoxSize * 0.28,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            infoIcon,
                                            size: titleSize,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                      Flexible(
                                        child: Text(
                                          infoTitle!,
                                          style: textTheme.headlineMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
