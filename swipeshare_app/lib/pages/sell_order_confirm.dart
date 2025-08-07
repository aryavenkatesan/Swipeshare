import 'dart:ui';
import 'package:swipeshare_app/services/listings/listing_service.dart';
import 'package:flutter/material.dart';

class SellOrderConfirmScreen extends StatefulWidget {
  final String location;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String note;

  const SellOrderConfirmScreen({
    super.key,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.note,
  });

  @override
  _SellOrderConfirmScreenState createState() => _SellOrderConfirmScreenState();
}

class _SellOrderConfirmScreenState extends State<SellOrderConfirmScreen> {
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final args =
  //       ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

  //   location = args['location'] as String;
  //   date = args['date'] as DateTime;
  //   startTime = args['startTime'] as TimeOfDay;
  //   endTime = args['endTime'] as TimeOfDay;
  //   note = args['note'] as String;
  // }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final _listingService = ListingService();

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
                                  "Confirm Listing",
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

                        infoRow("Location", widget.location),
                        const SizedBox(height: 12),
                        infoRow(
                          "Date",
                          "${widget.date.month}/${widget.date.day}/${widget.date.year}",
                        ),
                        const SizedBox(height: 12),
                        infoRow(
                          "Time",
                          "${formatTime(widget.startTime)} – ${formatTime(widget.endTime)}",
                        ),
                        const SizedBox(height: 12),
                        if (widget.note.trim().isNotEmpty)
                          infoRow("Note", widget.note),

                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            _listingService.postListing(
                              widget.location,
                              widget.startTime,
                              widget.endTime,
                              widget.date,
                            );
                            Navigator.pop(context);
                            Navigator.pop(context);
                            //add a congratulations pop up with confetti  after returning home?
                          },
                          child: const Center(child: Text("Confirm Listing")),
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

  Widget infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
