import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';

class SwipeCountComponent extends StatelessWidget {
  final int swipeCount;
  final Function(int) onSwipeCountChanged;
  final int maxSwipes;
  final bool enabled;

  const SwipeCountComponent({
    super.key,
    required this.swipeCount,
    required this.onSwipeCountChanged,
    this.maxSwipes = 10,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: BuySwipesConstants.containerPadding,
      decoration: BoxDecoration(
        color: AppColors.whiteTransparent,
        borderRadius: BorderRadius.circular(BuySwipesConstants.borderRadius),
        border: Border.all(color: AppColors.borderGrey, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // By wrapping the Column in Expanded, it fills the available space
          // and forces the Text widgets inside it to wrap.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Number of Swipes',
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  enabled
                      ? 'How many swipes to sell?'
                      : 'Feature under construction :)',
                  style: AppTextStyles.validationText.copyWith(
                    color: AppColors.subText,
                  ),
                ),
              ],
            ),
          ),

          // This Row takes only the space it needs for the buttons.
          Row(
            children: [
              IconButton(
                onPressed: swipeCount > 1 && enabled
                    ? () => onSwipeCountChanged(swipeCount - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: swipeCount > 1 && enabled
                    ? AppColors.accentBlue
                    : AppColors.borderGrey,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentBlueLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  swipeCount.toString(),
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                onPressed: swipeCount < maxSwipes && enabled
                    ? () => onSwipeCountChanged(swipeCount + 1)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: swipeCount < maxSwipes && enabled
                    ? AppColors.accentBlue
                    : AppColors.borderGrey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
