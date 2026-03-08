import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/utils/haptics.dart';

/// An expandable payment options picker.
///
/// Tapping the header expands a list of all available payment methods with
/// check/uncheck toggles. At least one method must be selected for the form
/// to be considered complete.
class PaymentOptionsField extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const PaymentOptionsField({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<PaymentOptionsField> createState() => _PaymentOptionsFieldState();
}

class _PaymentOptionsFieldState extends State<PaymentOptionsField> {
  bool _expanded = false;

  String get _subtitle {
    if (widget.selected.isEmpty) return 'Select payment methods';
    final count = widget.selected.length;
    return '$count method${count > 1 ? 's' : ''} selected';
  }

  TextTheme get textTheme => Theme.of(context).textTheme;
  ColorScheme get colors => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (always visible)
          GestureDetector(
            onTap: () async {
              await safeVibrate(HapticsType.selection);
              setState(() => _expanded = !_expanded);
            },
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 75,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 9,
                  top: 4,
                  bottom: 4,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 24,
                      color: colors.onSurface,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Payment Options', style: textTheme.bodyMedium),
                          Text(
                            _subtitle,
                            style: textTheme.bodyLarge?.copyWith(
                              color: widget.selected.isEmpty
                                  ?  colors.onSurface
                                  : colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expandable options list
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(height: 1, color: colors.outlineVariant),
                      ...PaymentOption.allPaymentOptions.map(
                        (opt) => _OptionTile(
                          option: opt,
                          isSelected: widget.selected.contains(opt.name),
                          onToggle: () => _toggle(opt.name),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(String name) async {
    await safeVibrate(HapticsType.selection);
    final updated = List<String>.from(widget.selected);
    if (updated.contains(name)) {
      updated.remove(name);
    } else {
      updated.add(name);
    }
    widget.onChanged(updated);
  }
}

class _OptionTile extends StatelessWidget {
  final PaymentOption option;
  final bool isSelected;
  final VoidCallback onToggle;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isSelected
            ? colors.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(option.icon, size: 20, color: colors.primary),
            const SizedBox(width: 16),
            Expanded(child: Text(option.name, style: textTheme.bodyMedium)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                key: ValueKey(isSelected),
                size: 20,
                color: isSelected ? colors.primary : colors.outlineVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
