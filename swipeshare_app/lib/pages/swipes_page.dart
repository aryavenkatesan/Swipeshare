import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/swipes_page/swipe_filter_sheet.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/pages/buy/view_listing_page.dart';
import 'package:swipeshare_app/services/user_service.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

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
      final userPayments = currentUser.paymentTypes;
      final defaultPayments = userPayments.isNotEmpty
          ? Set<String>.from(userPayments)
          : Set<String>.from(PaymentOption.allPaymentTypeNames);
      if (mounted) {
        setState(() {
          _filterData = _filterData.copyWith(paymentTypes: defaultPayments);
        });
      }
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
          (snapshot) {
            _processSnapshot(snapshot, today);
          },
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

    // Time filter — listing [A,B] passes if A < filterEnd && B > filterStart.
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
    final applyPayFilter =
        _filterData.paymentTypes.isNotEmpty &&
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

  void _togglePayment(String name) {
    final newTypes = Set<String>.from(_filterData.paymentTypes);
    if (newTypes.contains(name)) {
      newTypes.remove(name);
    } else {
      newTypes.add(name);
    }
    setState(() => _filterData = _filterData.copyWith(paymentTypes: newTypes));
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text('Available Swipes', style: textTheme.headlineMedium),
        ),
        _FilterPillRow(
          filterData: _filterData,
          onToggleLocation: _toggleLocation,
          onToggleDate: _toggleDate,
          onOpenSheet: _openFilterSheet,
          onClearTime: _clearTime,
          onTogglePayment: _togglePayment,
        ),
        const SizedBox(height: 28),
        _buildBody(textTheme),
      ],
    );
  }

  Widget _buildBody(TextTheme textTheme) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
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
      );
    }

    if (_listings.isEmpty && _filteredOutListings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text('No listings available', style: textTheme.bodyLarge),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_listings.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'No listings match your filters',
              style: textTheme.bodyLarge,
            ),
          )
        else
          _listingsGrid(_listings),
        if (_filteredOutListings.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
            child: Text(
              'Filtered Out',
              style: textTheme.titleSmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Opacity(opacity: 0.4, child: _listingsGrid(_filteredOutListings)),
        ],
      ],
    );
  }

  Widget _listingsGrid(List<Listing> listings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 90,
        ),
        itemCount: listings.length,
        itemBuilder: (context, index) =>
            _SwipeListingCard(listing: listings[index]),
      ),
    );
  }
}

/// Interactive pill row. Shows Lenoir, Chase, Today, Tomorrow always, plus
/// date range, time, and individual payment pills when active.
/// The tune icon opens the full filter sheet.
class _FilterPillRow extends StatelessWidget {
  final SwipeFilterData filterData;
  final ValueChanged<String> onToggleLocation;
  final ValueChanged<String> onToggleDate;
  final VoidCallback onOpenSheet;
  final VoidCallback onClearTime;
  final ValueChanged<String> onTogglePayment;

  const _FilterPillRow({
    required this.filterData,
    required this.onToggleLocation,
    required this.onToggleDate,
    required this.onOpenSheet,
    required this.onClearTime,
    required this.onTogglePayment,
  });

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute == 0 ? '' : ':${t.minute.toString().padLeft(2, '0')}';
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour$min $period';
  }

  String get _timePillLabel {
    final start = filterData.startAt;
    final end = filterData.endAt;
    if (start != null && end != null) {
      return '${_formatTime(start)}–${_formatTime(end)}';
    } else if (start != null) {
      return 'After ${_formatTime(start)}';
    } else {
      return 'Before ${_formatTime(end!)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPayNames = Set.from(PaymentOption.allPaymentTypeNames);
    final hasTimePill = filterData.startAt != null || filterData.endAt != null;
    final hasPaymentPill =
        filterData.paymentTypes.isNotEmpty &&
        !filterData.paymentTypes.containsAll(allPayNames);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onOpenSheet,
            child: Icon(Icons.tune, color: SwipeshareColors.primary, size: 32),
          ),
          const SizedBox(width: 8),
          _Pill(
            label: ' Lenoir ',
            selected: filterData.locations.contains('Lenoir'),
            onTap: () => onToggleLocation('Lenoir'),
          ),
          const SizedBox(width: 8),
          _Pill(
            label: ' Chase ',
            selected: filterData.locations.contains('Chase'),
            onTap: () => onToggleLocation('Chase'),
          ),
          const SizedBox(width: 8),
          _Pill(
            label: ' Today ',
            selected: filterData.dates.contains('Today'),
            onTap: () => onToggleDate('Today'),
          ),
          const SizedBox(width: 8),
          _Pill(
            label: ' Tomorrow ',
            selected: filterData.dates.contains('Tomorrow'),
            onTap: () => onToggleDate('Tomorrow'),
          ),
          if (filterData.otherRange != null) ...[
            const SizedBox(width: 8),
            _Pill(
              label:
                  ' ${filterData.otherRange!.start.month}/${filterData.otherRange!.start.day}'
                  '–${filterData.otherRange!.end.month}/${filterData.otherRange!.end.day} ',
              selected: true,
              onTap: onOpenSheet,
            ),
          ],
          if (hasTimePill) ...[
            const SizedBox(width: 8),
            _Pill(
              label: ' $_timePillLabel ',
              selected: true,
              onTap: onClearTime,
            ),
          ],
          if (hasPaymentPill)
            for (final name in filterData.paymentTypes) ...[
              const SizedBox(width: 8),
              _Pill(
                label: ' $name ',
                selected: true,
                onTap: () => onTogglePayment(name),
              ),
            ],
        ],
      ),
    );
  }
}

/// A pill chip. Selected = blue bg, unselected = white bg, both with black border.
class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE2ECF9) : Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.w300,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeListingCard extends StatelessWidget {
  final Listing listing;

  const _SwipeListingCard({required this.listing});

  String get _date {
    final d = listing.transactionDate;
    return '${d.month}/${d.day}';
  }

  String get _timeRange {
    return '${TimeFormatter.formatTOD(listing.timeStart)} to '
        '${TimeFormatter.formatTOD(listing.timeEnd)}';
  }

  String _formatDisplayTime(String timeRange) {
    return timeRange.replaceAllMapped(
      RegExp(r'(\d+):00\s*([AP]M)'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewListingPage(listing: listing),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${listing.diningHall} ',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w500,
                        fontSize: 23,
                        height: 1,
                        color: textTheme.titleMedium?.color,
                      ),
                    ),
                    TextSpan(
                      text: _date,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w300,
                        fontSize: 23,
                        height: 1,
                        color: textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatDisplayTime(_timeRange),
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 18.5,
                    color: Colors.black,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
