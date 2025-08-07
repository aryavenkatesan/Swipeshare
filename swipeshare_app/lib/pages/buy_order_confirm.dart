import 'dart:ui';
import 'package:swipeshare_app/models/listing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuyOrderConfirmScreen extends StatefulWidget {
  final List<String> location;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const BuyOrderConfirmScreen({
    super.key,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  @override
  _BuyOrderConfirmScreenState createState() => _BuyOrderConfirmScreenState();
}

class _BuyOrderConfirmScreenState extends State<BuyOrderConfirmScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late Map<String, dynamic> buyOrder;

  @override
  void initState() {
    final Listing arguments = Listing(
      sellerId: _firebaseAuth.currentUser!.uid,
      diningHall: widget.location[0],
      timeStart: widget.startTime,
      timeEnd: widget.endTime,
      transactionDate: widget.date,
    );
    buyOrder = arguments.toMap();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    // In case listing is empty, show a loading or empty state
    if (buyOrder.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No order details available')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
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

          // Frosted card
          SafeArea(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: double.infinity,
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
                        // Back button
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                          ],
                        ),

                        const SizedBox(height: 4),
                        const Text(
                          "Confirm Order",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Summary details
                        infoRow("Seller", buyOrder['seller']),
                        const SizedBox(height: 12),
                        infoRow("Location", buyOrder['location']),
                        const SizedBox(height: 12),
                        infoRow(
                          "Time",
                          "${_formatTime(buyOrder['start'])} - ${_formatTime(buyOrder['end'])}",
                        ),
                        const SizedBox(height: 12),
                        infoRow(
                          "Time Overlap",
                          "${buyOrder['overlap']} minutes",
                        ),

                        const SizedBox(height: 32),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (r) => false,
                            );
                          },
                          child: const Center(child: Text("Place Order")),
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
