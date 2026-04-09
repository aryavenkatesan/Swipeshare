import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/old_components/text_styles.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  int? _tappedIndex;

  final _allListings = const [
    {'location': 'Lenoir', 'date': '1/6', 'time': '1 PM to 2 PM'},
    {'location': 'Chase', 'date': '1/6', 'time': '2:45 PM to 3:30 PM'},
    {'location': 'Chase', 'date': '1/6', 'time': '7 PM to 8 PM'},
  ];

  final Set<String> _activeFilters = {'Lenoir', 'Chase'};

  List<Map<String, String>> get _filteredListings {
    return _allListings
        .where((l) => _activeFilters.contains(l['location']))
        .toList();
  }

  void _toggleFilter(String filter) async {
    await safeVibrate(HapticsType.selection);
    setState(() {
      if (_activeFilters.contains(filter)) {
        // Don't allow removing all filters
        if (_activeFilters.length > 1) {
          _activeFilters.remove(filter);
        }
      } else {
        _activeFilters.add(filter);
      }
    });
  }

  void _onCardTap(int index) async {
    await safeVibrate(HapticsType.selection);
    setState(() => _tappedIndex = index);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _tappedIndex = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final filtered = _filteredListings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: vh > 767 ? (vh * 0.03) : (vh * 0.01)),

            // Mock "Available Swipes" header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Available Swipes",
                    style: AppTextStyles.headerStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter chips
                  Row(
                    children: [
                      Icon(Icons.tune, color: colorScheme.primary, size: 22),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _toggleFilter('Lenoir'),
                        child: _FilterChip(
                          label: 'Lenoir',
                          isSelected: _activeFilters.contains('Lenoir'),
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _toggleFilter('Chase'),
                        child: _FilterChip(
                          label: 'Chase',
                          isSelected: _activeFilters.contains('Chase'),
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2-column grid of listing cards
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: GridView.builder(
                      key: ValueKey(_activeFilters.toString()),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.0,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final listing = filtered[index];
                        final isTapped = _tappedIndex == index;
                        return GestureDetector(
                          onTap: () => _onCardTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isTapped
                                  ? colorScheme.primary
                                      .withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isTapped
                                    ? colorScheme.primary
                                    : const Color(0xFFE0E0E0),
                                width: isTapped ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        listing['location']!,
                                        style:
                                            AppTextStyles.bodyText.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      listing['date']!,
                                      style: AppTextStyles.subText,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  listing['time']!,
                                  style: AppTextStyles.subText
                                      .copyWith(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: vh > 767 ? 40 : 24),

            Divider(
              height: vh * 0.02,
              color: const Color.fromRGBO(197, 197, 197, 1),
              indent: 24,
              endIndent: 24,
            ),

            SizedBox(height: vh > 767 ? 40 : 24),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
              child: Column(
                children: [
                  Text("How to Buy Swipes",
                      style: AppTextStyles.subHeaderStyle),
                  SizedBox(height: vh * 0.02),
                  Text(
                    "Tap a listing to coordinate with the seller.\nUse filters to narrow your search!",
                    style: AppTextStyles.bodyText,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? color : const Color(0xFFE0E0E0),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.subText.copyWith(
          color: isSelected ? color : null,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
