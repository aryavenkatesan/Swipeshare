import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

class RatingsBottomSheet extends StatefulWidget {
  final List<MealOrder> ordersToRate;
  final VoidCallback? onComplete;

  const RatingsBottomSheet({
    super.key,
    required this.ordersToRate,
    this.onComplete,
  });

  static Future<void> show(
    BuildContext context,
    List<MealOrder> orders, {
    VoidCallback? onComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          RatingsBottomSheet(ordersToRate: orders, onComplete: onComplete),
    );
  }

  @override
  State<RatingsBottomSheet> createState() => _RatingsBottomSheetState();
}

class _RatingsBottomSheetState extends State<RatingsBottomSheet> {
  late PageController _pageController;
  final _orderService = OrderService.instance;

  int _currentPage = 0;
  final Map<int, int?> _selectedStars = {};
  final Map<int, TextEditingController> _feedbackControllers = {};

  ColorScheme get _colors => Theme.of(context).colorScheme;
  TextTheme get _textTheme => Theme.of(context).textTheme;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    for (int i = 0; i < widget.ordersToRate.length; i++) {
      _feedbackControllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _feedbackControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: _colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Title
              Center(
                child: Text(
                  'Rate your Experience',
                  style: _textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: _colors.outlineVariant),
              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const PageScrollPhysics(),
                  itemCount: widget.ordersToRate.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) =>
                      _buildRatingPage(index, widget.ordersToRate[index]),
                ),
              ),
              // Pagination dots (only when multiple orders)
              if (widget.ordersToRate.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.ordersToRate.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4.5),
                        width: 38,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _colors.surfaceTint
                              : _colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingPage(int index, MealOrder order) {
    final peerName = order.them.name;

    final date = order.transactionDate;
    final formattedDate =
        '${date.month}/${date.day}/${date.year.toString().substring(2)}';

    final isLastPage = index == widget.ordersToRate.length - 1;
    final allStarsSelected = widget.ordersToRate.asMap().keys.every(
      (i) => _selectedStars[i] != null,
    );
    final buttonEnabled = isLastPage
        ? allStarsSelected
        : _selectedStars[index] != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(15, 20, 15, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Text(
              'How did your order on $formattedDate with $peerName at ${order.diningHall} go?',
              style: _textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            // Star rating
            _buildStarRating(index),
            const SizedBox(height: 28),
            // Feedback text field
            Container(
              height: 130,
              decoration: BoxDecoration(
                border: Border.all(color: _colors.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _feedbackControllers[index],
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: _textTheme.bodySmall,
                decoration: InputDecoration(
                  hintText: 'Tell us more (optional)',
                  hintStyle: _textTheme.bodySmall?.copyWith(
                    color: _colors.surfaceTint,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(16, 16, 9, 4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Next / Submit button
            GestureDetector(
              onTap: buttonEnabled
                  ? () => isLastPage
                        ? _submitAllRatings()
                        : _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 55,
                decoration: BoxDecoration(
                  color: buttonEnabled
                      ? _colors.primary
                      : _colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  isLastPage ? 'Submit' : 'Next',
                  style: _textTheme.labelLarge?.copyWith(
                    color: buttonEnabled
                        ? _colors.onPrimary
                        : _colors.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int pageIndex) {
    final selectedStars = _selectedStars[pageIndex] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final starSize = (constraints.maxWidth / 6).clamp(32.0, 60.0);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (starIndex) {
            final starNumber = starIndex + 1;
            final isSelected = starNumber <= selectedStars;

            return GestureDetector(
              onTap: () async {
                await safeVibrate(HapticsType.light);
                setState(() => _selectedStars[pageIndex] = starNumber);
              },
              child: Icon(
                isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                color: _colors.onSurface,
                size: starSize,
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _submitAllRatings() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      for (int i = 0; i < widget.ordersToRate.length; i++) {
        final stars = _selectedStars[i];
        if (stars == null) continue;
        await _orderService.rateOrder(
          widget.ordersToRate[i],
          Rating(
            stars: stars,
            extraInfo: _feedbackControllers[i]?.text.isEmpty ?? true
                ? null
                : _feedbackControllers[i]!.text,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(SnackbarMessages.genericError(e.toString())),
        ),
      );
      return;
    }

    await safeVibrate(HapticsType.success);

    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onComplete?.call();
    messenger.showSnackBar(
      SnackBar(content: Text(SnackbarMessages.feedbackSubmitted)),
    );
  }
}
