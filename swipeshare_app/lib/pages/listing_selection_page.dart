import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/services/listing_service.dart';
import 'package:swipeshare_app/services/order_service.dart';

class ListingSelectionPage extends StatefulWidget {
  final List<String> locations;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<String> paymentTypes;

  const ListingSelectionPage({
    super.key,
    required this.locations,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.paymentTypes,
  });

  @override
  State<ListingSelectionPage> createState() => _ListingSelectionPageState();
}

class _ListingSelectionPageState extends State<ListingSelectionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _listingService = ListingService();
  final _orderService = OrderService();

  String? _expandedListingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Listings")),
      body: GestureDetector(
        // This will close the dropdown when tapping outside
        onTap: () {
          setState(() {
            _expandedListingId = null;
          });
        },
        child: _buildItemList(),
      ),
    );
  }

  // build a list of listings except for the current logged in user
  Widget _buildItemList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where(_buildListingsFilter())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Error fetching listings: ${snapshot.error}");
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading..');
        }

        debugPrint("Fetched ${snapshot.data!.docs.length} listings");

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildListingItem(doc))
              .toList(),
        );
      },
    );
  }

  // build individual listing items
  Widget _buildListingItem(DocumentSnapshot document) {
    Map<String, dynamic> listing = document.data()! as Map<String, dynamic>;
    final TimeOfDay listingStartTime = Listing.minutesToTOD(
      listing['timeStart'],
    );
    final TimeOfDay listingEndTime = Listing.minutesToTOD(listing['timeEnd']);
    final docId = document.id;
    final bool isExpanded = _expandedListingId == docId;

    // This structure now EXACTLY matches the PaymentOptionsComponent.
    // 1. The root is an AnimatedContainer.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: isExpanded ? 2 : 1,
            blurRadius: isExpanded ? 6 : 3,
            offset: Offset(0, isExpanded ? 2 : 1),
          ),
        ],
      ),
      // 2. Its child is a Column containing the header and the expandable content.
      child: Column(
        children: [
          // 3. The TAPPABLE HEADER is a GestureDetector.
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedListingId = isExpanded ? null : docId;
              });
            },
            // This makes the entire padded area tappable, including whitespace.
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: "${listing['diningHall']}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text:
                                " @ ${_formatTime(listingStartTime)} to ${_formatTime(listingEndTime)}",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        const TextSpan(text: "⭑ "),
                        TextSpan(
                          text:
                              "${listing['sellerRating'].toStringAsFixed(2)}  ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // The rotating arrow is inside the tappable header.
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.expand_more, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child: isExpanded
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Text(
                          "Payment Types: ${listing['paymentTypes'].join(", ")}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Price: \$${listing['price'] ?? '6'}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (await Haptics.canVibrate()) {
                                Haptics.vibrate(HapticsType.success);
                              }
                              _handleListingSelection(docId, listing);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                192,
                                131,
                                199,
                                255,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              "Select This Listing",
                              style: SubTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleListingSelection(
    String docId,
    Map<String, dynamic> listing,
  ) async {
    try {
      await _listingService.deleteListing(docId);
      await _orderService.postOrder(
        listing['sellerId'],
        listing['diningHall'],
        widget.date,
        listing['sellerName'],
        listing['sellerRating'],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order was placed successfully!')),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e, s) {
      // Handle the error and stack trace
      print('Error: $e');
      print('Stack: $s');
      // You might want to show a SnackBar or dialog to inform the user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to process order: $e')));
      }
    }
  }

  Filter _buildListingsFilter() {
    final startDate = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
    );

    final endDate = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day + 1,
    );

    return Filter.and(
      Filter('diningHall', whereIn: widget.locations),
      Filter('sellerId', isNotEqualTo: _auth.currentUser!.uid),
      // Filter('paymentTypes', arrayContainsAny: widget.paymentTypes),
      // Date filtering
      Filter(
        'transactionDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      ),
      Filter('transactionDate', isLessThan: Timestamp.fromDate(endDate)),
      // Time overlap filtering
      Filter(
        'timeStart',
        isLessThanOrEqualTo: Listing.toMinutes(widget.endTime),
      ),
      Filter(
        'timeEnd',
        isGreaterThanOrEqualTo: Listing.toMinutes(widget.startTime),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
