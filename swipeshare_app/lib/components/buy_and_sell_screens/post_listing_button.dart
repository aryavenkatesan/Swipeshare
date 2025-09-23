import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';

/// Base button component for consistent styling across the app
class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final bool isLoading;
  final Widget? icon;

  const MyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.textStyle,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.accentBlue,
          foregroundColor: textColor ?? AppColors.white,
          elevation: elevation ?? 0,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(BuySwipesConstants.borderRadius),
          ),
          padding: padding ?? BuySwipesConstants.buttonPadding,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: textColor ?? AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: textStyle ?? AppTextStyles.buttonText,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Specialized button component for "Post Listing" functionality
class PostListingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const PostListingButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return MyButton(
      text: "Post Listing",
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppColors.accentBlue,
      textColor: AppColors.white,
      elevation: 2,
      textStyle: AppTextStyles.buttonText.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        letterSpacing: 0.5,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    );
  }
}
