import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshare_app/components/colors.dart';

class OnboardingSwipesMarketplaceMockup extends StatelessWidget {
  final Set<String> activeLocationFilters;
  final ValueChanged<String> onToggleLocation;
  final int? selectedListingIndex;
  final ValueChanged<int> onListingTap;

  const OnboardingSwipesMarketplaceMockup({
    super.key,
    required this.activeLocationFilters,
    required this.onToggleLocation,
    required this.selectedListingIndex,
    required this.onListingTap,
  });

  static const _allListings = <_TutorialListing>[
    _TutorialListing(
      location: 'Lenoir',
      date: '1/6',
      time: '1 PM to 2 PM',
      price: '\$5',
    ),
    _TutorialListing(
      location: 'Chase',
      date: '1/6',
      time: '2:45 PM to 3:30 PM',
      price: '\$8',
    ),
    _TutorialListing(
      location: 'Chase',
      date: '1/7',
      time: '7 PM to 8 PM',
      price: '\$6',
    ),
  ];

  static int filteredCountForFilters(Set<String> locationFilters) {
    return _allListings
        .where((listing) => locationFilters.contains(listing.location))
        .length;
  }

  List<_TutorialListing> get _filteredListings {
    return _allListings.where((listing) {
      return activeLocationFilters.contains(listing.location);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filteredListings = _filteredListings;
    final filterKeyParts = activeLocationFilters.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Swipes', style: textTheme.headlineMedium),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Icon(Icons.tune, size: 32, color: SwipeshareColors.primary),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onToggleLocation('Lenoir'),
                child: _Pill(
                  label: ' Lenoir ',
                  selected: activeLocationFilters.contains('Lenoir'),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onToggleLocation('Chase'),
                child: _Pill(
                  label: ' Chase ',
                  selected: activeLocationFilters.contains('Chase'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        GridView.builder(
          key: ValueKey(filterKeyParts.join(',')),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 18,
            mainAxisExtent: 85,
          ),
          itemCount: filteredListings.length,
          itemBuilder: (context, index) {
            final listing = filteredListings[index];
            return GestureDetector(
              onTap: () => onListingTap(index),
              child: _TutorialSwipeCard(
                location: listing.location,
                date: listing.date,
                time: listing.time,
                price: listing.price,
                isSelected: selectedListingIndex == index,
              ),
            );
          },
        ),
        if (filteredListings.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No listings match your filters',
              style: textTheme.bodyLarge,
            ),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;

  const _Pill({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE2ECF9) : Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          style: GoogleFonts.lexend(fontWeight: FontWeight.w300, fontSize: 20),
        ),
      ),
    );
  }
}

class _TutorialSwipeCard extends StatelessWidget {
  final String location;
  final String date;
  final String time;
  final String price;
  final bool isSelected;

  const _TutorialSwipeCard({
    required this.location,
    required this.date,
    required this.time,
    required this.price,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$location ',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.w500,
                              fontSize: 23,
                              height: 1,
                              color: textTheme.titleMedium?.color,
                            ),
                          ),
                          TextSpan(
                            text: date,
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
                  ),
                  Text(
                    price,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: SwipeshareColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  time,
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

class _TutorialListing {
  final String location;
  final String date;
  final String time;
  final String price;

  const _TutorialListing({
    required this.location,
    required this.date,
    required this.time,
    required this.price,
  });
}
