import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/adaptive/adaptive_dialog.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/pages/chat_page.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

class ActiveOrderCard extends StatefulWidget {
  final MealOrder order;

  const ActiveOrderCard({super.key, required this.order});

  @override
  State<ActiveOrderCard> createState() => _ActiveOrderCardState();
}

class _ActiveOrderCardState extends State<ActiveOrderCard>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  double _snapFrom = 0;
  late final AnimationController _snapController;

  // Drag this far to trigger the cancel dialog on release.
  static const double _triggerThreshold = 80.0;
  // Exposed panel width at which the label slides to the left side.
  static const double _labelFlipThreshold = 197.0;

  bool get _canCancel => widget.order.status == OrderStatus.active;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(() {
        final t = Curves.easeOut.transform(_snapController.value);
        setState(() => _dragOffset = _snapFrom * (1 - t));
      });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _snapBack() {
    _snapFrom = _dragOffset;
    _snapController.forward(from: 0);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_canCancel) return;
    if (_snapController.isAnimating) _snapController.stop();
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(-300.0, 0.0);
    });
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (!_canCancel) return;
    final triggered = -_dragOffset >= _triggerThreshold;
    _snapBack();
    if (triggered) await _confirmCancel();
  }

  Future<void> _confirmCancel() async {
    final confirmed = await AdaptiveDialog.showConfirmation(
      context: context,
      title: 'Cancel Order',
      content: 'Are you sure you want to cancel this order?',
      confirmText: 'Cancel Order',
      cancelText: 'Close',
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      await safeVibrate(HapticsType.heavy);
      await OrderService.instance.cancelOrder(
        widget.order.getRoomName(),
        widget.order.currentUserRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: SizedBox(
        height: 80,
        child: Stack(
          children: [
            // Red cancel panel — full-width, sits behind the card, revealed as card slides left.
            // A SizedBox matching the still-covered portion pushes the label into the visible area.
            if (_canCancel && _dragOffset < 0)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final hiddenWidth =
                        (constraints.maxWidth + _dragOffset).clamp(0.0, constraints.maxWidth);
                    final exposedWidth = constraints.maxWidth - hiddenWidth;
                    final showLabel = exposedWidth >= _triggerThreshold;
                    final labelOnLeft = exposedWidth >= _labelFlipThreshold;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ColoredBox(
                        color: Colors.red,
                        child: Row(
                          children: [
                            SizedBox(width: hiddenWidth),
                            Expanded(
                              child: AnimatedOpacity(
                                opacity: showLabel ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: AnimatedAlign(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                alignment: labelOnLeft
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Cancel',
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Card — slides left on drag, revealing the panel behind it.
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(_dragOffset, 0),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () async {
                      await safeVibrate(HapticsType.selection);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(orderData: widget.order),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        // Left accent bar – 7 px wide, full height
                        Container(width: 7, color: colors.surfaceTint),
                        // Content area
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 17,
                              right: 17,
                              top: 5,
                              bottom: 5,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Text column
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: widget.order.diningHall,
                                              style: textTheme.titleMedium,
                                            ),
                                            TextSpan(
                                              text:
                                                  ' ${widget.order.transactionDate.month}/${widget.order.transactionDate.day}',
                                              style: textTheme.labelMedium
                                                  ?.copyWith(
                                                fontSize: 15,
                                                color:
                                                    SwipeshareColors.subtleText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 0),
                                      Text(
                                        widget.order.displayTime != null
                                            ? TimeFormatter
                                                .formatTimeOfDayString(
                                                widget.order.displayTime!,
                                              )
                                            : "TBD",
                                        style: textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                                // Chevron forward icon
                                Icon(
                                  Icons.chevron_right,
                                  size: 24,
                                  color: colors.onSurface,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
