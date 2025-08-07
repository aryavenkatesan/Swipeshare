import 'dart:ui';
import 'package:swipeshare_app/pages/home_page.dart';
import 'package:swipeshare_app/pages/sell_order_confirm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SellPostScreen extends StatefulWidget {
  @override
  State<SellPostScreen> createState() => _SellPostScreenState();
}

class _SellPostScreenState extends State<SellPostScreen> {
  String selectedLocation = "Chase";
  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String message = "";

  void _showCupertinoTimePicker(bool isStart) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.hm,
          initialTimerDuration: Duration(
            hours: (isStart ? startTime?.hour : endTime?.hour) ?? 12,
            minutes: (isStart ? startTime?.minute : endTime?.minute) ?? 0,
          ),
          onTimerDurationChanged: (Duration newTime) {
            final picked = TimeOfDay(
              hour: newTime.inHours,
              minute: newTime.inMinutes % 60,
            );
            setState(() {
              if (isStart) {
                startTime = picked;
              } else {
                endTime = picked;
              }
            });
          },
        ),
      ),
    );
  }

  void _showCupertinoDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: selectedDate,
          onDateTimeChanged: (newDate) {
            setState(() {
              selectedDate = newDate;
            });
          },
        ),
      ),
    );
  }

  bool get isFormComplete => startTime != null && endTime != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF98D2EB),
                  Color(0xFFDCEAFF),
                  Color(0xFFDCEAFF),
                  Color(0xFFA2A0DD),
                ],
                stops: [0.0, 0.3, 0.75, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Back + Title
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  "Sell Swipe",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Location toggle
                        Row(
                          children: ["Chase", "Lenoir"].map((location) {
                            final isSelected = selectedLocation == location;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => selectedLocation = location),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black
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

                        // Date picker
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Select Date:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _showCupertinoDatePicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Text(
                              "${selectedDate.month}/${selectedDate.day}/${selectedDate.year}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Time pickers
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Select Time Range:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showCupertinoTimePicker(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Text(
                                    startTime != null
                                        ? startTime!.format(context)
                                        : "Start",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showCupertinoTimePicker(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Text(
                                    endTime != null
                                        ? endTime!.format(context)
                                        : "End",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: isFormComplete
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SellOrderConfirmScreen(
                                            location: selectedLocation,
                                            date: selectedDate,
                                            startTime: startTime!,
                                            endTime: endTime!,
                                            note: message,
                                          ),
                                    ),
                                  );
                                }
                              : null,
                          child: const Center(child: Text("Post Listing")),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
