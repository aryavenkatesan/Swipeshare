import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/swipes_page/filter_pill_row.dart';
import 'package:swipeshare_app/components/swipes_page/swipe_filter_sheet.dart';
import 'package:swipeshare_app/components/swipes_page/swipe_listing_card.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/pages/sell/create_swipe_listing_page.dart';
import 'package:swipeshare_app/services/user_service.dart';

class SwipesPage extends StatefulWidget {
  const SwipesPage({super.key});

  @override
  State<SwipesPage> createState() => _SwipesPageState();
}

class _SwipesPageState extends State<SwipesPage> {
  SwipeFilterData _filterData = SwipeFilterData.defaults;

  List<Listing> _listings = [];
  List<Listing> _filteredOutListings = [];
  bool _isLoading = true;
  String? _error;

  StreamSubscription<QuerySnapshot>? _listingSub;
  List<String> _blockedUsers = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _listingSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final currentUser = await UserService.instance.getCurrentUser();
      _blockedUsers = currentUser.blockedUsers;
    } catch (_) {}
    _startListening();
  }

  void _startListening() {
    _listingSub?.cancel();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _listingSub = FirebaseFirestore.instance
        .collection('listings')
        .where(
          'transactionDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(today),
        )
        .snapshots()
        .listen(
      (snapshot) => _processSnapshot(snapshot, today),
      onError: (e) {
        debugPrint('SwipesPage stream error: $e');
        if (mounted) {
          setState(() {
            _error = 'Failed to load listings. Please try again.';
            _isLoading = false;
          });
        }
      },
    );
  }

  bool _passesFilters(Listing l, DateTime today) {
    final tomorrow = today.add(const Duration(days: 1));

    // Date filter
    final todaySelected = _filterData.dates.contains('Today');
    final tomorrowSelected = _filterData.dates.contains('Tomorrow');
    final otherRange = _filterData.otherRange;

    if (todaySelected || tomorrowSelected || otherRange != null) {
      final d = DateTime(
        l.transactionDate.year,
        l.transactionDate.month,
        l.transactionDate.day,
      );
      bool dateMatch = false;
      if (todaySelected && d == today) dateMatch = true;
      if (tomorrowSelected && d == tomorrow) dateMatch = true;
      if (otherRange != null) {
        final rangeStart = DateTime(
          otherRange.start.year,
          otherRange.start.month,
          otherRange.start.day,
        );
        final rangeEnd = DateTime(
          otherRange.end.year,
          otherRange.end.month,
          otherRange.end.day,
        );
        if (!d.isBefore(rangeStart) && !d.isAfter(rangeEnd)) dateMatch = true;
      }
      if (!dateMatch) return false;
    }

    // Location filter
    if (_filterData.locations.isNotEmpty &&
        !_filterData.locations.contains(l.diningHall)) {
      return false;
    }

    // Time filter — overlap: listing [A,B] passes if A < filterEnd && B > filterStart.
    final startAt = _filterData.startAt;
    final endAt = _filterData.endAt;
    if (startAt != null || endAt != null) {
      final listingStartMin = l.timeStart.hour * 60 + l.timeStart.minute;
      final listingEndMin = l.timeEnd.hour * 60 + l.timeEnd.minute;
      if (startAt != null) {
        final filterStartMin = startAt.hour * 60 + startAt.minute;
        if (listingEndMin <= filterStartMin) return false;
      }
      if (endAt != null) {
        final filterEndMin = endAt.hour * 60 + endAt.minute;
        if (listingStartMin >= filterEndMin) return false;
      }
    }

    // Payment filter
    final allPayNames = Set.from(PaymentOption.allPaymentTypeNames);
    final applyPayFilter = _filterData.paymentTypes.isNotEmpty &&
        !_filterData.paymentTypes.containsAll(allPayNames);
    if (applyPayFilter &&
        !l.paymentTypes.any(_filterData.paymentTypes.contains)) {
      return false;
    }

    return true;
  }

  void _processSnapshot(QuerySnapshot snapshot, DateTime today) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final candidates = snapshot.docs
        .map((doc) => Listing.fromFirestore(doc))
        .where((l) {
          if (l.status != ListingStatus.active) return false;
          if (uid != null && l.sellerId == uid) return false;
          if (_blockedUsers.contains(l.sellerId)) return false;
          return true;
        })
        .toList();

    final included = <Listing>[];
    final excluded = <Listing>[];
    for (final l in candidates) {
      (_passesFilters(l, today) ? included : excluded).add(l);
    }

    included.sort(Listing.bySoonest);
    excluded.sort(Listing.bySoonest);

    if (mounted) {
      setState(() {
        _listings = included;
        _filteredOutListings = excluded;
        _isLoading = false;
      });
    }
  }

  void _toggleLocation(String loc) {
    final newLocs = Set<String>.from(_filterData.locations);
    if (newLocs.contains(loc)) {
      newLocs.remove(loc);
    } else {
      newLocs.add(loc);
    }
    setState(() => _filterData = _filterData.copyWith(locations: newLocs));
    _startListening();
  }

  void _toggleDate(String date) {
    final newDates = Set<String>.from(_filterData.dates);
    if (newDates.contains(date)) {
      newDates.remove(date);
    } else {
      newDates.add(date);
    }
    setState(() => _filterData = _filterData.copyWith(dates: newDates));
    _startListening();
  }

  void _clearTime() {
    setState(
      () => _filterData = _filterData.copyWith(startAt: null, endAt: null),
    );
    _startListening();
  }

  void _clearPayment() {
    setState(
      () => _filterData = _filterData.copyWith(
        paymentTypes: Set.from(PaymentOption.allPaymentTypeNames),
      ),
    );
    _startListening();
  }

  Future<void> _openFilterSheet() async {
    final result = await showSwipeFilterSheet(context, _filterData);
    if (result != null) {
      setState(() => _filterData = result);
      _startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('Swipes', style: textTheme.displayLarge),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        height: 1,
                        color: Color(0xFFE0E0E0),
                        indent: 20,
                        endIndent: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Text(
                          'Available Swipes',
                          style: textTheme.headlineMedium,
                        ),
                      ),
                      FilterPillRow(
                        filterData: _filterData,
                        onToggleLocation: _toggleLocation,
                        onToggleDate: _toggleDate,
                        onOpenSheet: _openFilterSheet,
                        onClearTime: _clearTime,
                        onClearPayment: _clearPayment,
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
                ..._buildSliverBody(textTheme),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateSwipeListingPage(),
                ),
              ),
              icon: const Icon(CupertinoIcons.add, color: Colors.white, size: 28),
              label: const Text('Sell a Swipe'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSliverBody(TextTheme textTheme) {
    if (_isLoading) {
      return [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_error != null) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, style: textTheme.bodyLarge),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _startListening,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    if (_listings.isEmpty && _filteredOutListings.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Text('No listings available', style: textTheme.bodyLarge),
          ),
        ),
      ];
    }

    final slivers = <Widget>[];

    if (_listings.isEmpty) {
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            'No listings match your filters',
            style: textTheme.bodyLarge,
          ),
        ),
      ));
    } else {
      slivers.add(_listingsGrid(_listings));
    }

    if (_filteredOutListings.isNotEmpty) {
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
          child: Text(
            'Filtered Out',
            style: textTheme.titleSmall?.copyWith(color: Colors.grey.shade500),
          ),
        ),
      ));
      slivers.add(_listingsGrid(_filteredOutListings, opacity: 0.4));
    }

    return slivers;
  }

  Widget _listingsGrid(List<Listing> listings, {double opacity = 1.0}) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 90,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final card = SwipeListingCard(listing: listings[index]);
            return opacity < 1.0 ? Opacity(opacity: opacity, child: card) : card;
          },
          childCount: listings.length,
        ),
      ),
    );
  }
}
