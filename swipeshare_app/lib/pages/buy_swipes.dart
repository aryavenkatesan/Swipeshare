import 'package:swipeshare_app/pages/listing_selection_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BuySwipeScreen extends StatefulWidget {
  const BuySwipeScreen({super.key});

  @override
  State<BuySwipeScreen> createState() => _BuySwipesScreenState();
}

class _BuySwipesScreenState extends State<BuySwipeScreen> {
  int selectedLocation = 0;
  List<String> selectedLocations = [];
  DateTime selectedDate = DateTime.now();
  bool showStartPicker = false;
  bool showEndPicker = false;

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Buy Swipe',
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: 'Instrument Sans',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.44,
                      color: Color(0xFF111827),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: ["Chase", "Lenoir"].map((location) {
                      final isSelected = selectedLocations.contains(location);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isSelected
                                  ? selectedLocations.remove(location)
                                  : selectedLocations.add(location);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.grey[800]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: Center(
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _buildDatePills(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _timeSelector("Start at", startTime, () {
                          setState(() {
                            showStartPicker = true;
                            showEndPicker = false;
                          });
                        }),
                        _timeSelector("End at", endTime, () {
                          setState(() {
                            showStartPicker = false;
                            showEndPicker = true;
                          });
                        }),
                      ],
                    ),
                  ),

                  // ✅ Swappable pickers (final fix)
                  Stack(
                    children: [
                      AnimatedOpacity(
                        opacity: showStartPicker ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Visibility(
                          visible: showStartPicker,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Container(
                            height: 200,
                            margin: const EdgeInsets.only(top: 12),
                            child: CupertinoTimerPicker(
                              mode: CupertinoTimerPickerMode.hm,
                              initialTimerDuration: Duration(
                                hours: startTime?.hour ?? 9,
                                minutes: startTime?.minute ?? 0,
                              ),
                              onTimerDurationChanged: (duration) {
                                setState(() {
                                  startTime = TimeOfDay(
                                    hour: duration.inHours,
                                    minute: duration.inMinutes % 60,
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: showEndPicker ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Visibility(
                          visible: showEndPicker,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Container(
                            height: 200,
                            margin: const EdgeInsets.only(top: 12),
                            child: CupertinoTimerPicker(
                              mode: CupertinoTimerPickerMode.hm,
                              initialTimerDuration: Duration(
                                hours: endTime?.hour ?? 17,
                                minutes: endTime?.minute ?? 0,
                              ),
                              onTimerDurationChanged: (duration) {
                                setState(() {
                                  endTime = TimeOfDay(
                                    hour: duration.inHours,
                                    minute: duration.inMinutes % 60,
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  if (startTime == null || endTime == null)
                    const Text(
                      '⚠️ No Time Selected, pick a start and end time ⚠️',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Instrument Sans',
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        letterSpacing: -0.64,
                        decoration: TextDecoration.none,
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: Text(
                          'Available 9:00 am to 5:00 pm',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Instrument Sans',
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            letterSpacing: -0.64,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (startTime != null &&
                          endTime != null &&
                          selectedLocations.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListingSelectionPage(
                              locations: selectedLocations,
                              date: selectedDate,
                              startTime: startTime!,
                              endTime: endTime!,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE7E7E7)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Find Swipe Seller',
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Instrument Sans',
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF111827),
                                letterSpacing: -0.96,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Times may vary.',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Instrument Sans',
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF111827),
                                letterSpacing: -0.4,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDatePills() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = today.add(Duration(days: i));
      final isSelected =
          date.day == selectedDate.day &&
          date.month == selectedDate.month &&
          date.year == selectedDate.year;
      final label = i == 0
          ? 'Today'
          : i == 1
          ? 'Tomorrow'
          : '${date.month}/${date.day}';

      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: () => setState(() => selectedDate = date),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE7E7E7)
                  : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
                letterSpacing: -0.48,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _timeSelector(String label, TimeOfDay? time, VoidCallback onTap) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Instrument Sans',
            fontWeight: FontWeight.w400,
            color: Colors.black,
            letterSpacing: -0.64,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 129,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              time?.format(context) ?? '--:--',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Instrument Sans',
                fontWeight: FontWeight.w400,
                color: Colors.black,
                letterSpacing: -0.64,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
