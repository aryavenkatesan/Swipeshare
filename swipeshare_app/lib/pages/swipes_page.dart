import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/pages/sell/create_swipe_listing_page.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

class SwipesPage extends StatefulWidget {
  const SwipesPage({super.key});

  @override
  State<SwipesPage> createState() => _SwipesPageState();
}

class _SwipesPageState extends State<SwipesPage> {
  final Set<String> _selectedFilters = {'Lenoir', 'Today'};

  static const List<String> _filterOptions = [
    'Lenoir',
    'Today',
    'Chase',
    'Tomorrow',
  ];

  // TODO: replace with real Firestore data
  static final List<Listing> _mockListings = [
    Listing(
      id: '1',
      sellerId: 'seller1',
      sellerName: 'Alice',
      diningHall: 'Lenoir',
      timeStart: const TimeOfDay(hour: 13, minute: 0),
      timeEnd: const TimeOfDay(hour: 14, minute: 0),
      transactionDate: DateTime.now(),
      sellerRating: 4.8,
      paymentTypes: ['Venmo'],
      price: 7.0,
      status: ListingStatus.active,
    ),
    Listing(
      id: '2',
      sellerId: 'seller2',
      sellerName: 'Bob',
      diningHall: 'Lenoir',
      timeStart: const TimeOfDay(hour: 14, minute: 45),
      timeEnd: const TimeOfDay(hour: 15, minute: 30),
      transactionDate: DateTime.now(),
      sellerRating: 4.5,
      paymentTypes: ['Cash'],
      price: 7.0,
      status: ListingStatus.active,
    ),
    Listing(
      id: '3',
      sellerId: 'seller3',
      sellerName: 'Carol',
      diningHall: 'Lenoir',
      timeStart: const TimeOfDay(hour: 19, minute: 0),
      timeEnd: const TimeOfDay(hour: 20, minute: 0),
      transactionDate: DateTime.now(),
      sellerRating: 5.0,
      paymentTypes: ['Venmo', 'Cash'],
      price: 7.0,
      status: ListingStatus.active,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Swipes', style: textTheme.displayLarge),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Available Swipes', style: textTheme.headlineMedium),
          ),
          _FilterRow(
            options: _filterOptions,
            selected: _selectedFilters,
            onToggle: (label) => setState(() {
              if (_selectedFilters.contains(label)) {
                _selectedFilters.remove(label);
              } else {
                _selectedFilters.add(label);
              }
            }),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  mainAxisExtent: 85,
                ),
                itemCount: _mockListings.length,
                itemBuilder: (context, index) =>
                    _SwipeListingCard(listing: _mockListings[index]),
              ),
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
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Sell a Swipe'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _FilterRow({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.tune, color: SwipeshareColors.primary, size: 24),
          const SizedBox(width: 8),
          ...options.map(
            (label) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onToggle(label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected.contains(label)
                        ? const Color(0xFFE2ECF9)
                        : Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w300,
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

class _SwipeListingCard extends StatelessWidget {
  final Listing listing;

  const _SwipeListingCard({required this.listing});

  String get _date {
    final d = listing.transactionDate;
    return '${d.month}/${d.day}';
  }

  String get _timeRange {
    final start = TimeFormatter.formatTimeOfDay(
      TimeFormatter.productionToString(listing.timeStart),
    );
    final end = TimeFormatter.formatTimeOfDay(
      TimeFormatter.productionToString(listing.timeEnd),
    );
    return '$start to $end';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        // TODO: navigate to listing detail
      },
      child: Container(
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
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${listing.diningHall} ',
                    style: textTheme.titleMedium,
                  ),
                  TextSpan(
                    text: _date,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Text(_timeRange, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
