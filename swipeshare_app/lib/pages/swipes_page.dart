import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/swipe_filter_sheet.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/pages/buy/view_listing_page.dart';
import 'package:swipeshare_app/pages/sell/create_swipe_listing_page.dart';
import 'package:swipeshare_app/services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

class SwipesPage extends StatefulWidget {
  const SwipesPage({super.key});

  @override
  State<SwipesPage> createState() => _SwipesPageState();
}

class _SwipesPageState extends State<SwipesPage> {
  SwipeFilterData _filterData = SwipeFilterData.defaults;

  List<Listing> _listings = [];
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
    // Prefetch blocked users once, then start the stream.
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

  void _processSnapshot(QuerySnapshot snapshot, DateTime today) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    List<Listing> listings = snapshot.docs
        .map((doc) => Listing.fromFirestore(doc))
        .where((l) {
          if (l.status != ListingStatus.active) return false;
          if (uid != null && l.sellerId == uid) return false;
          if (_blockedUsers.contains(l.sellerId)) return false;
          return true;
        })
        .toList();

    // Date filter
    final todaySelected = _filterData.dates.contains('Today');
    final tomorrow = today.add(const Duration(days: 1));
    final tomorrowSelected = _filterData.dates.contains('Tomorrow');
    final otherRange = _filterData.otherRange;
    final rangeStart = otherRange != null
        ? DateTime(
            otherRange.start.year,
            otherRange.start.month,
            otherRange.start.day,
          )
        : null;
    final rangeEnd = otherRange != null
        ? DateTime(
            otherRange.end.year,
            otherRange.end.month,
            otherRange.end.day,
          )
        : null;

    if (todaySelected || tomorrowSelected || otherRange != null) {
      listings = listings.where((l) {
        final d = DateTime(
          l.transactionDate.year,
          l.transactionDate.month,
          l.transactionDate.day,
        );
        if (todaySelected && d == today) return true;
        if (tomorrowSelected && d == tomorrow) return true;
        if (rangeStart != null &&
            rangeEnd != null &&
            !d.isBefore(rangeStart) &&
            !d.isAfter(rangeEnd)) return true;
        return false;
      }).toList();
    }

    // Location filter
    if (_filterData.locations.isNotEmpty) {
      listings = listings
          .where((l) => _filterData.locations.contains(l.diningHall))
          .toList();
    }

    // Time filter
    final startAt = _filterData.startAt;
    final endAt = _filterData.endAt;
    if (startAt != null || endAt != null) {
      listings = listings.where((l) {
        if (startAt != null) {
          final filterMin = startAt.hour * 60 + startAt.minute;
          final listingMin = l.timeStart.hour * 60 + l.timeStart.minute;
          if (listingMin < filterMin) return false;
        }
        if (endAt != null) {
          final filterMin = endAt.hour * 60 + endAt.minute;
          final listingMin = l.timeEnd.hour * 60 + l.timeEnd.minute;
          if (listingMin > filterMin) return false;
        }
        return true;
      }).toList();
    }

    // Payment filter
    final allPayNames = Set.from(PaymentOption.allPaymentTypeNames);
    final applyPayFilter = _filterData.paymentTypes.isNotEmpty &&
        !_filterData.paymentTypes.containsAll(allPayNames);
    if (applyPayFilter) {
      listings = listings
          .where(
            (l) => l.paymentTypes.any(_filterData.paymentTypes.contains),
          )
          .toList();
    }

    listings.sort(Listing.bySoonest);

    if (mounted) {
      setState(() {
        _listings = listings;
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
                      const Divider(height: 1, color: Color(0xFFE0E0E0), indent: 20, endIndent: 20,),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Text('Available Swipes', style: textTheme.headlineMedium),
                      ),
                      _FilterPillRow(
                        filterData: _filterData,
                        onToggleLocation: _toggleLocation,
                        onToggleDate: _toggleDate,
                        onOpenSheet: _openFilterSheet,
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
                _buildSliverBody(textTheme),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateSwipeListingPage(),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.add, color: Colors.white, size: 28,),
              label: const Text('Sell a Swipe'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverBody(TextTheme textTheme) {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
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
      );
    }

    if (_listings.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text('No listings available', style: textTheme.bodyLarge),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 90,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _SwipeListingCard(listing: _listings[index]),
          childCount: _listings.length,
        ),
      ),
    );
  }
}

/// Interactive pill row. Shows Lenoir, Chase, Today, Tomorrow always (in that
/// order) plus an otherRange chip when set. Tapping a pill toggles it directly;
/// the tune icon opens the full filter sheet for advanced options.
class _FilterPillRow extends StatelessWidget {
  final SwipeFilterData filterData;
  final ValueChanged<String> onToggleLocation;
  final ValueChanged<String> onToggleDate;
  final VoidCallback onOpenSheet;

  const _FilterPillRow({
    required this.filterData,
    required this.onToggleLocation,
    required this.onToggleDate,
    required this.onOpenSheet,
  });

  @override
  Widget build(BuildContext context) {
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
                  '${filterData.otherRange!.start.month}/${filterData.otherRange!.start.day}–'
                  '${filterData.otherRange!.end.month}/${filterData.otherRange!.end.day}',
              selected: true,
              onTap: onOpenSheet,
            ),
          ],
        ],
      ),
    );
  }
}

/// A pill chip matching Figma 621:1270.
/// Both states always have a black border; selected = blue bg, unselected = white bg.
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE2ECF9) : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

/// Swipe listing card matching Figma 621:1278.
/// Line 1: "{hall}" (Lexend Medium 20sp) + " {date}" (Lexend Light 20sp)
/// Line 2: "{startTime} to {endTime}" (Lexend Light 17sp)
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewListingPage(listing: listing),
          ),
        );
      },
      child: Container(
        // ── Card padding: adjust vertical value (8) to tweak spacing ──
        padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hall (medium) + date (light) — both 20sp, Figma 621:1278
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
            // Time range — Lexend Light 17sp, always shows fully
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(_formatDisplayTime(_timeRange), style: textTheme.bodyLarge?.copyWith(fontSize: 18.5, color: Colors.black, height: 1)),
            ),
          ],
        ),
      ),
    );
  }
}
