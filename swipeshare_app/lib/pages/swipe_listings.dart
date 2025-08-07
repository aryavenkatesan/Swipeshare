import 'dart:ui';
import 'package:flutter/material.dart';

class SwipeListingsScreen extends StatefulWidget {
  @override
  State<SwipeListingsScreen> createState() => _SwipeListingsScreenState();
}

class _SwipeListingsScreenState extends State<SwipeListingsScreen> {
  List<Map<String, dynamic>> allListings = [];
  List<Map<String, dynamic>> visibleListings = [];
  bool onlyShowOverlap = false;
  int? selectedIndex;

  TimeOfDay _toTimeOfDay(DateTime dt) =>
      TimeOfDay(hour: dt.hour, minute: dt.minute);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final buyerStart = args['startTime'] as TimeOfDay;
    final buyerEnd = args['endTime'] as TimeOfDay;
    final date = args['date'] as DateTime;
    final locations = args['locations'] as List<String>;

    // Mock data
    allListings = [
      {
        'seller': 'Alice',
        'location': 'Chase',
        'start': TimeOfDay(hour: 11, minute: 0),
        'end': TimeOfDay(hour: 13, minute: 0),
      },
      {
        'seller': 'Bob',
        'location': 'Lenoir',
        'start': TimeOfDay(hour: 14, minute: 0),
        'end': TimeOfDay(hour: 15, minute: 0),
      },
      {
        'seller': 'Cindy',
        'location': 'Chase',
        'start': TimeOfDay(hour: 12, minute: 30),
        'end': TimeOfDay(hour: 14, minute: 0),
      },
    ];

    allListings =
        allListings
            .where((listing) => locations.contains(listing['location']))
            .map((listing) {
              final overlap = _calculateOverlap(
                buyerStart,
                buyerEnd,
                listing['start'],
                listing['end'],
              );
              return {...listing, 'overlap': overlap};
            })
            .toList()
          ..sort((a, b) => b['overlap'].compareTo(a['overlap']));

    _filterListings();
  }

  void _filterListings() {
    setState(() {
      visibleListings = onlyShowOverlap
          ? allListings.where((l) => l['overlap'] > 0).toList()
          : allListings;
    });
  }

  int _calculateOverlap(
    TimeOfDay aStart,
    TimeOfDay aEnd,
    TimeOfDay bStart,
    TimeOfDay bEnd,
  ) {
    final aStartMin = aStart.hour * 60 + aStart.minute;
    final aEndMin = aEnd.hour * 60 + aEnd.minute;
    final bStartMin = bStart.hour * 60 + bStart.minute;
    final bEndMin = bEnd.hour * 60 + bEnd.minute;

    final overlapStart = aStartMin > bStartMin ? aStartMin : bStartMin;
    final overlapEnd = aEndMin < bEndMin ? aEndMin : bEndMin;

    return (overlapEnd > overlapStart) ? overlapEnd - overlapStart : 0;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  "Available Swipes",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Checkbox(
                              value: onlyShowOverlap,
                              onChanged: (val) {
                                onlyShowOverlap = val ?? false;
                                _filterListings();
                              },
                            ),
                            const Text("Only show overlap"),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: visibleListings.length,
                            itemBuilder: (context, index) {
                              final listing = visibleListings[index];
                              final isSelected = selectedIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            listing['seller'],
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            listing['location'],
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white70
                                                  : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${_formatTime(listing['start'])} - ${_formatTime(listing['end'])}",
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            "${listing['overlap']} min overlap",
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white70
                                                  : Colors.black54,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: selectedIndex != null
                              ? () {
                                  Navigator.pushNamed(
                                    context,
                                    '/buy_order_confirm',
                                    arguments: visibleListings[selectedIndex!],
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: Colors.black12,
                          ),
                          child: const Center(child: Text("Confirm")),
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
