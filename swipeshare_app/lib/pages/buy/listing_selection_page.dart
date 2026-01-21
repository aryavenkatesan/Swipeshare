import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/services/user_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';

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
  final _orderService = OrderService.instance;

  String? _expandedListingId;

  // Cache the listings data in state
  List<Listing>? _cachedPerfectMatches;
  List<Listing>? _cachedImperfectMatches;
  bool _isLoading = true;
  String? _error;

  // Pull to refresh controller
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  // Load listings once on init
  Future<void> _loadListings() async {
    try {
      final listingsQuery = FirebaseFirestore.instance
          .collection('listings')
          .where(_buildListingsFilter());

      final (snapshot, currentUser) = await (
        listingsQuery.get(),
        UserService.instance.getCurrentUser(),
      ).wait;

      final (perfectMatches, imperfectMatches) = sortListingsByRelevance(
        snapshot.docs
            .map((doc) => Listing.fromFirestore(doc))
            .where(
              (listing) => !currentUser.blockedUsers.contains(listing.sellerId),
            )
            .toList(),
      );

      if (mounted) {
        setState(() {
          _cachedPerfectMatches = perfectMatches;
          _cachedImperfectMatches = imperfectMatches;
          _isLoading = false;
          _error = null;
        });
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

  // Pull to refresh handler
  void _onRefresh() async {
    // Add a small delay for better UX
    var random = Random();
    int sheaintevenknowit = 100 + random.nextInt(1200);
    await Future.delayed(Duration(milliseconds: sheaintevenknowit));

    // Reload listings
    await _loadListings();

    // Complete the refresh
    if (mounted) {
      _refreshController.refreshCompleted();
    }
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 500));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Listings"),
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
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

      body: _buildBody(),
    );
  }

  // Build body based on cached state (no StreamBuilder rebuilds)
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    final hasNoListings =
        (_cachedPerfectMatches == null || _cachedPerfectMatches!.isEmpty) &&
        (_cachedImperfectMatches == null || _cachedImperfectMatches!.isEmpty);

    if (hasNoListings) {
      return SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        header: const WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            return const Text("");
          },
        ),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No listings found',
                        style: HeaderStyle.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final perfectMatches = _cachedPerfectMatches ?? [];
    final imperfectMatches = _cachedImperfectMatches ?? [];
    final totalCount = perfectMatches.length + imperfectMatches.length;
    final hasDivider = perfectMatches.isNotEmpty && imperfectMatches.isNotEmpty;

    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      header: const WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          return const Text("");
        },
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 6),
        itemCount: totalCount + (hasDivider ? 1 : 0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          // Check if this is the divider position
          if (hasDivider && index == perfectMatches.length) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            );
          }

          // Determine which listing to show
          final Listing doc;
          if (index < perfectMatches.length) {
            doc = perfectMatches[index];
          } else {
            // Adjust index for imperfect matches (account for divider)
            final adjustedIndex = hasDivider
                ? index - perfectMatches.length - 1
                : index - perfectMatches.length;
            doc = imperfectMatches[adjustedIndex];
          }

          return GestureDetector(
            // Move the collapse-on-tap to each item
            onTap: () {
              if (_expandedListingId != null && _expandedListingId != doc.id) {
                setState(() {
                  _expandedListingId = null;
                });
              }
            },
            behavior: HitTestBehavior.translucent,
            child: _buildListingItem(doc, ValueKey(doc.id)),
          );
        },
      ),
    );
  }

  Widget _buildListingItem(Listing listing, Key key) {
    final bool isExpanded = _expandedListingId == listing.id;

    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
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
                _expandedListingId = isExpanded ? null : listing.id;
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
                          listing.diningHall,
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
                              text: listing.sellerRating.toStringAsFixed(2),
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
                                text: _formatTime(listing.timeStart),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 65, 137, 200),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(text: "  to  "),
                              TextSpan(
                                text: _formatTime(listing.timeEnd),
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
                          listing.paymentTypes.join(", "),
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
                          "\$${listing.price ?? '7'}",
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
                              await safeVibrate(HapticsType.success);
                              _handleListingSelection(listing);
                            },
                            child: Text(
                              "Select This Listing",
                              style: AppTextStyles.viewListingSubText.copyWith(
                                color: const Color.fromARGB(255, 61, 61, 61),
                                fontWeight: FontWeight.w400,
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

  Future<void> _handleListingSelection(Listing listing) async {
    try {
      await _orderService.postOrder(listing);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order was placed successfully!')),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e, s) {
      debugPrint('Error: $e');
      debugPrint('Stack: $s');
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
      // Exclude current user's listings
      Filter('sellerId', isNotEqualTo: _auth.currentUser!.uid),

      // Get listings only on the selected date (after current time if today)
      Filter(
        'transactionDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      ),
      Filter('transactionDate', isLessThan: Timestamp.fromDate(endDate)),

      // Get listings only with payment type overlap
      Filter('paymentTypes', arrayContainsAny: widget.paymentTypes),

      // Get only active listings
      Filter('status', isEqualTo: ListingStatus.active.name),
    );
  }

  (List<Listing>, List<Listing>) sortListingsByRelevance(
    List<Listing> allListings,
  ) {
    // Helper function to check time overlap
    bool hasTimeOverlap(Listing listing) {
      final listingStart = Listing.toMinutes(listing.timeStart);
      final listingEnd = Listing.toMinutes(listing.timeEnd);
      final selectedStart = Listing.toMinutes(widget.startTime);
      final selectedEnd = Listing.toMinutes(widget.endTime);

      return listingStart < selectedEnd && listingEnd > selectedStart;
    }

    // Helper function to check dining hall match
    bool hasDiningHallMatch(Listing listing) {
      return widget.locations.contains(listing.diningHall);
    }

    // Calculates how closely the listing's time matches the selected time range
    // Returns negative if overlapping, positive if non-overlapping,
    // with larger absolute values indicating further away from the range
    int calculateTimeMatch(Listing listing) {
      final listingStart = Listing.toMinutes(listing.timeStart);
      final listingEnd = Listing.toMinutes(listing.timeEnd);
      final selectedStart = Listing.toMinutes(widget.startTime);
      final selectedEnd = Listing.toMinutes(widget.endTime);

      if (listingEnd <= selectedStart) {
        // Listing ends before/at query start; positive
        return selectedStart - listingEnd;
      } else if (listingStart >= selectedEnd) {
        // Listing starts after/at query end; positive
        return listingStart - selectedEnd;
      } else if (listingStart < selectedStart) {
        // Listing overlaps and starts before query; negative
        return selectedStart - listingEnd;
      } else {
        // Listing overlaps and starts after query; negative
        return listingStart - selectedEnd;
      }
    }

    // Categorize listings into 4 groups
    final bucket1 =
        <Listing>[]; // Time overlap + Dining hall match (perfect matches)
    final bucket2 = <Listing>[]; // Time overlap + No dining hall match
    final bucket3 = <Listing>[]; // No time overlap + Dining hall match
    final bucket4 = <Listing>[]; // No time overlap + No dining hall match

    for (final listing in allListings) {
      final timeOverlap = hasTimeOverlap(listing);
      final hallMatch = hasDiningHallMatch(listing);

      if (timeOverlap && hallMatch) {
        bucket1.add(listing);
      } else if (timeOverlap && !hallMatch) {
        bucket2.add(listing);
      } else if (!timeOverlap && hallMatch) {
        bucket3.add(listing);
      } else {
        bucket4.add(listing);
      }
    }

    // Sort each group by time match (ascending)
    for (final group in [bucket1, bucket2, bucket3, bucket4]) {
      group.sort((a, b) {
        final distA = calculateTimeMatch(a);
        final distB = calculateTimeMatch(b);
        return distA.compareTo(distB);
      });
    }

    // Return perfect matches (bucket1) and imperfect matches (bucket2-4) separately
    return (bucket1, [...bucket2, ...bucket3, ...bucket4]);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
