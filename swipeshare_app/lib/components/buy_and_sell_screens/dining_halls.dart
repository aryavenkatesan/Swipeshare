import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';

class DiningHallsComponent extends StatelessWidget {
  final List<String> selectedLocations;
  final Function(String) onLocationToggle;

  const DiningHallsComponent({
    super.key,
    required this.selectedLocations,
    required this.onLocationToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: BuySwipesConstants.locations.map((location) {
        final isSelected = selectedLocations.contains(location);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: BuySwipesConstants.smallSpacing),
            child: GestureDetector(
              onTap: () => onLocationToggle(location),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: BuySwipesConstants.mediumSpacing),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.accentBlueLight 
                      : AppColors.whiteTransparent,
                  borderRadius: BorderRadius.circular(BuySwipesConstants.borderRadius),
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
