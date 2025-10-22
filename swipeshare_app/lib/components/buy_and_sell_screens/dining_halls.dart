import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';

class DiningHallsComponent extends StatelessWidget {
  final List<String> selectedLocations;
  final Function(String) onLocationToggle;

  final String sellOrBuy;

  const DiningHallsComponent({
    super.key,
    required this.selectedLocations,
    required this.onLocationToggle,
    required this.sellOrBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: BuySwipesConstants.locations.map((location) {
        final isSelected = selectedLocations.contains(location);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BuySwipesConstants.smallSpacing,
            ),
            child: GestureDetector(
              onTap: () {
                // If "sell" mode and this location is already selected, allow deselection
                // If "sell" mode and a different location is selected, this will replace it
                // If "buy" mode, toggle normally (allow multiple)
                if (sellOrBuy.toLowerCase() == "sell") {
                  // Single selection mode for sell
                  if (!isSelected) {
                    // Only trigger if selecting a new location
                    onLocationToggle(location);
                  } else {
                    // Allow deselection of current location
                    onLocationToggle(location);
                  }
                } else {
                  // Multiple selection mode for buy
                  onLocationToggle(location);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: BuySwipesConstants.mediumSpacing,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentBlueLight
                      : AppColors.whiteTransparent,
                  borderRadius: BorderRadius.circular(
                    BuySwipesConstants.borderRadius,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentBlue
                        : AppColors.borderGrey,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    location,
                    style: isSelected
                        ? AppTextStyles.locationTextSelected
                        : AppTextStyles.locationText,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
