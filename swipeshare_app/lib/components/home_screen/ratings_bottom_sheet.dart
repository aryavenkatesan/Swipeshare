import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

class RatingsBottomSheet extends StatefulWidget {
  final List<MealOrder> ordersToRate;

  const RatingsBottomSheet({super.key, required this.ordersToRate});

  static Future<void> show(BuildContext context, List<MealOrder> orders) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => RatingsBottomSheet(ordersToRate: orders),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rate your experience!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (widget.ordersToRate.length > 1)
                  Text(
                    '${_currentPage + 1} / ${widget.ordersToRate.length}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // PageView for orders
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.ordersToRate.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return _buildRatingPage(index, widget.ordersToRate[index]);
              },
            ),
          ),
          // Page indicator dots
          if (widget.ordersToRate.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.ordersToRate.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.blue
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingPage(int index, MealOrder order) {
    final peerName = switch (order.currentUserRole) {
      OrderRole.buyer => order.sellerName,
      OrderRole.seller => order.buyerName,
    };

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'How was your experience with $peerName?',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              order.diningHall,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            // Star rating
            _buildStarRating(index),
            const SizedBox(height: 32),
            // Feedback text field
            SizedBox(
              width: 300,
              child: TextField(
                controller: _feedbackControllers[index],
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Anything you want to add?...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            ElevatedButton(
              onPressed: _selectedStars[index] == null
                  ? null
                  : () => _submitRating(index, order),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Send Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int pageIndex) {
    final selectedStars = _selectedStars[pageIndex] ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (starIndex) {
        final starNumber = starIndex + 1;
        final isSelected = starNumber <= selectedStars;

        return GestureDetector(
          onTap: () async {
            await safeVibrate(HapticsType.light);
            setState(() {
              _selectedStars[pageIndex] = starNumber;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 48,
              color: isSelected ? Colors.amber : Colors.grey.shade400,
            ),
          ),
        );
      }),
    );
  }

  Future<void> _submitRating(int index, MealOrder order) async {
    final stars = _selectedStars[index];
    if (stars == null) return;

    await _orderService.rateOrder(
      order,
      Rating(
        stars: stars,
        extraInfo: _feedbackControllers[index]?.text.isEmpty ?? true
            ? null
            : _feedbackControllers[index]!.text,
      ),
    );

    await safeVibrate(HapticsType.success);

    if (!mounted) return;

    // If more orders to rate, go to next page
    if (index < widget.ordersToRate.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SnackbarMessages.feedbackSubmitted)),
      );
    } else {
      // Last order, close the bottom sheet
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SnackbarMessages.feedbackSubmitted)),
      );
    }
  }
}
