import 'package:flutter/cupertino.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  // ⭐ Cache the listings data in state
  List<DocumentSnapshot>? _cachedListings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  // ⭐ Load listings once on init
  Future<void> _loadListings() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('listings')
          .where(_buildListingsFilter())
          .get();

      if (mounted) {
        setState(() {
          _cachedListings = snapshot.docs;
          _isLoading = false;
        });
        debugPrint("Fetched ${snapshot.docs.length} listings");
      }
    } catch (e) {
      debugPrint("Error fetching listings: $e");
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Listings")),
      body: _buildBody(),
    );
  }

  // ⭐ Build body based on cached state (no StreamBuilder rebuilds)
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_cachedListings == null || _cachedListings!.isEmpty) {
      return const Center(child: Text('No listings found'));
    }

    return GestureDetector(
      onTap: () {
        if (_expandedListingId != null) {
          setState(() {
            _expandedListingId = null;
          });
        }
      },
      child: ListView.builder(
        itemCount: _cachedListings!.length,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final doc = _cachedListings![index];
          return _buildListingItem(doc, ValueKey(doc.id));
        },
      ),
    );
  }

  Widget _buildListingItem(DocumentSnapshot document, Key key) {
    Map<String, dynamic> listing = document.data()! as Map<String, dynamic>;
    final TimeOfDay listingStartTime = Listing.minutesToTOD(
      listing['timeStart'],
    );
    final TimeOfDay listingEndTime = Listing.minutesToTOD(listing['timeEnd']);
    final docId = document.id;
    final bool isExpanded = _expandedListingId == docId;

    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? Colors.black26 : Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // ========== CARD FRONT (Always Visible) ==========
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedListingId = isExpanded ? null : docId;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dining Hall and Star Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${listing['diningHall']}",
                          style: HeaderStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          children: [
                            const TextSpan(text: "⭑ "),
                            TextSpan(
                              text: listing['sellerRating'].toStringAsFixed(2),
                              style: const TextStyle(
                                color: Color.fromARGB(198, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Time Range
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.listingText,
                            children: [
                              const TextSpan(text: "From  "),
                              TextSpan(
                                text: _formatTime(listingStartTime),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 65, 137, 200),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(text: "  to  "),
                              TextSpan(
                                text: _formatTime(listingEndTime),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 65, 137, 200),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ========== EXPANDABLE CONTENT (Inside Card) ==========
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(height: 1, thickness: 1, color: Colors.black12),
                        const SizedBox(height: 12),

                        // Payment Types
                        Text(
                          "Payment Types:",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${listing['paymentTypes'].join(", ")}",
                          style: AppTextStyles.viewListingSubText,
                        ),

                        const SizedBox(height: 12),

                        // Price
                        Text(
                          "Price:",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "\$${listing['price'] ?? '6'}",
                          style: AppTextStyles.viewListingSubText,
                        ),

                        const SizedBox(height: 16),

                        // Select Button
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            color: const Color.fromARGB(192, 131, 199, 255),
                            borderRadius: BorderRadius.circular(8),
                            onPressed: () async {
                              if (await Haptics.canVibrate()) {
                                Haptics.vibrate(HapticsType.success);
                              }
                              _handleListingSelection(docId, listing);
                            },
                            child: Flexible(
                              child: Text(
                                "Select This Listing",
                                style: AppTextStyles.viewListingSubText
                                    .copyWith(
                                      color: const Color.fromARGB(
                                        255,
                                        61,
                                        61,
                                        61,
                                      ),
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
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
          const SnackBar(content: Text('Order was placed successfully!')),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e, s) {
      print('Error: $e');
      print('Stack: $s');
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
      Filter(
        'transactionDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      ),
      Filter('transactionDate', isLessThan: Timestamp.fromDate(endDate)),
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
