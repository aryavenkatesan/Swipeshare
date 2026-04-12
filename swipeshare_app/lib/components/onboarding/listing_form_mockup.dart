import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/listing_form/date_selector_field.dart';
import 'package:swipeshare_app/components/listing_form/dining_hall_selector.dart';
import 'package:swipeshare_app/components/listing_form/payment_options_field.dart';
import 'package:swipeshare_app/components/listing_form/price_stepper_field.dart';
import 'package:swipeshare_app/components/listing_form/time_range_selector.dart';

class OnboardingListingFormMockup extends StatelessWidget {
  const OnboardingListingFormMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      width: double.infinity,
      child: IgnorePointer(
        ignoring: true,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
          child: SizedBox(width: 430, child: _TutorialListingFormBody()),
        ),
      ),
    );
  }
}

class _TutorialListingFormBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DiningHallSelector(selected: 'Lenoir', onChanged: (_) {}),
          const SizedBox(height: 10),
          DateSelectorField(selectedDate: tomorrow, onChanged: (_) {}),
          const SizedBox(height: 10),
          TimeRangeSelector(
            timeStart: const TimeOfDay(hour: 13, minute: 0),
            timeEnd: const TimeOfDay(hour: 14, minute: 0),
            onStartChanged: (_) {},
            onEndChanged: (_) {},
          ),
          const SizedBox(height: 10),
          PriceStepperField(price: 5, onChanged: (_) {}),
          const SizedBox(height: 10),
          PaymentOptionsField(
            selected: const ['Venmo', 'Cash App', 'Zelle'],
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}
