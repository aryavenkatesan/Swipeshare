import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/listing_form/listing_field_card.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

const _minPrice = 1;
const _maxPrice = 20;

/// A row field with a dollar icon, a label, and +/- stepper buttons.
///
/// Price is always an integer dollar value between $_minPrice and $_maxPrice.
class PriceStepperField extends StatelessWidget {
  final int price;
  final ValueChanged<int> onChanged;

  const PriceStepperField({
    super.key,
    required this.price,
    required this.onChanged,
  });

  Future<void> _showInputDialog(BuildContext context) async {
    final controller = TextEditingController(text: '$price');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Swipe Price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: '\$ ',
            hintText: '$_minPrice – $_maxPrice',
          ),
          onSubmitted: (v) {
            final parsed = int.tryParse(v);
            Navigator.of(ctx).pop(parsed);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text);
              Navigator.of(ctx).pop(parsed);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null) {
      onChanged(result.clamp(_minPrice, _maxPrice));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return ListingFieldCard(
      child: Row(
        children: [
          Icon(Icons.attach_money, size: 24, color: colors.onSurface),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Swipe Price', style: textTheme.bodyMedium),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepButton(
                icon: Icons.remove_circle_outline,
                onPressed: price > _minPrice
                    ? () async {
                        await safeVibrate(HapticsType.selection);
                        onChanged(price - 1);
                      }
                    : null,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showInputDialog(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$price',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _StepButton(
                icon: Icons.add_circle_outline,
                onPressed: price < _maxPrice
                    ? () async {
                        await safeVibrate(HapticsType.selection);
                        onChanged(price + 1);
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Icon(
        icon,
        size: 30,
        color: onPressed != null ? colors.onSurface : colors.outlineVariant,
      ),
    );
  }
}
