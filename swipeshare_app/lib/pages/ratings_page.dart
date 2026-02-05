import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

class RatingsPage extends StatefulWidget {
  final String recieverId;
  final MealOrder orderData;
  const RatingsPage({
    super.key,
    required this.recieverId,
    required this.orderData,
  });

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  String? selectedFace;
  final TextEditingController _feedbackController = TextEditingController();
  final _orderService = OrderService.instance;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        title: Text("Rate your experience!"),
        automaticallyImplyLeading: true, //removes back button
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withValues(
              alpha: 0.3,
            ), // Customize color as needed
            height: 1.0,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 48),
                  // Pyramid arrangement of faces
                  Column(
                    children: [
                      // Top middle button
                      _buildFaceButton(
                        Icons.sentiment_neutral_rounded,
                        'neutral',
                      ),
                      const SizedBox(height: 0),
                      // Bottom row with left and right buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFaceButton(
                            Icons.sentiment_dissatisfied_rounded,
                            'sad',
                          ),
                          const SizedBox(width: 80),

                          _buildFaceButton(
                            Icons.sentiment_very_satisfied_rounded,
                            'happy',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _feedbackController,
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
                  const SizedBox(height: 72),
                  ElevatedButton(
                    onPressed: selectedFace == null
                        ? null
                        : () async {
                            // sends the rating information to update the other person's star rating
                            int stars = switch (selectedFace) {
                              'happy' => 5,
                              'neutral' => 3,
                              'sad' => 1,
                              _ => throw StateError('No face selected'),
                            };

                            await _orderService.closeOrder(
                              widget.orderData,
                              rating: Rating(
                                stars: stars,
                                extraInfo:
                                    _feedbackController.text.trim().isEmpty
                                    ? null
                                    : _feedbackController.text,
                              ),
                            );

                            await safeVibrate(HapticsType.success);

                            if (!context.mounted) return;

                            // navigate back to the homescreen
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();

                            // congratulations popup?
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(SnackbarMessages.orderPlaced),
                              ),
                            );
                          },
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
          ),
        ),
      ),
    );
  }

  Widget _buildFaceButton(IconData icon, String value) {
    final isSelected = selectedFace == value;

    return GestureDetector(
      onTap: () async {
        await safeVibrate(HapticsType.light);
        setState(() {
          selectedFace = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 3,
          ),
        ),
        child: Icon(
          icon,
          size: 60,
          color: isSelected ? Colors.blue : Colors.grey.shade700,
        ),
      ),
    );
  }
}
