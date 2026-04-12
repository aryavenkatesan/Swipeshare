import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/dashboard/active_listing_card.dart';
import 'package:swipeshare_app/components/dashboard/active_order_card.dart';
import 'package:swipeshare_app/components/refreshable_page.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/services/listing_service.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/pages/dashboard/star_rating_page.dart';
import 'package:swipeshare_app/utils/haptics.dart';

// Thin wrapper — use DashboardHeader + DashboardContent directly via BottomBar
class DashboardPage extends StatelessWidget {
  final UserModel userData;
  final Future<void> Function() onRefresh;

  const DashboardPage({
    super.key,
    required this.userData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshablePage(
      header: DashboardHeader(userData: userData),
      onRefresh: onRefresh,
      child: DashboardContent(userData: userData),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  final UserModel userData;

  const DashboardHeader({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Hi, ${userData.name}", style: textTheme.displayLarge),
            _RatingChip(
              rating: userData.stars,
              transactionsCompleted: userData.transactionsCompleted,
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}

class DashboardContent extends StatelessWidget {
  final UserModel userData;

  const DashboardContent({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (userData.moneySaved + userData.moneyEarned > 0) ...[
            const SizedBox(height: 0),
            _ValueBanner(total: userData.moneySaved + userData.moneyEarned),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 8),
          ],
          Text("Active Orders", style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          const _OrdersList(),
          const SizedBox(height: 16),
          Text("Your Listings", style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          const _ListingsList(),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;
  final int transactionsCompleted;

  const _RatingChip({
    required this.rating,
    required this.transactionsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StarRatingPage(
              rating: rating,
              transactionsCompleted: transactionsCompleted,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          "\u2605 ${rating.toStringAsFixed(2)}",
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot<MealOrder>>(
      stream: OrderService.instance.orderCol
          .where(
            Filter.or(
              Filter('seller.id', isEqualTo: userId),
              Filter('buyer.id', isEqualTo: userId),
            ),
          )
          .where(
            'status',
            whereIn: [OrderStatus.active.name, OrderStatus.cancelled.name],
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.error != null) {
          return Text('Error: ${snapshot.error.toString()}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        final orders =
            (snapshot.data?.docs.map((doc) => doc.data()) ?? <MealOrder>[])
                .where((order) => order.isActiveOrUnacknowledged())
                .toList();

        if (orders.isEmpty) {
          return _EmptyMessage(
            message: "No orders yet",
            colors: colors,
            textTheme: textTheme,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: (orders..sort(MealOrder.bySoonest))
              .map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ActiveOrderCard(order: order),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ListingsList extends StatefulWidget {
  const _ListingsList();

  @override
  State<_ListingsList> createState() => _ListingsListState();
}

class _ListingsListState extends State<_ListingsList> {
  bool _showPastListings = false;
  late final Stream<QuerySnapshot<Listing>> _listingsStream;

  @override
  void initState() {
    super.initState();
    _listingsStream = ListingService.instance.listingCol
        .where("sellerId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<QuerySnapshot<Listing>>(
      stream: _listingsStream,
      builder: (context, snapshot) {
        if (snapshot.error != null) {
          return Text('Error: ${snapshot.error.toString()}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        final listings =
            snapshot.data?.docs.map((doc) => doc.data()).toList() ?? [];

        final activeListings =
            listings
                .where((listing) => listing.status == ListingStatus.active)
                .toList()
              ..sort(Listing.bySoonest);

        final pastListings =
            listings
                .where((listing) => listing.status != ListingStatus.active)
                .toList()
              ..sort(Listing.bySoonest);

        if (activeListings.isEmpty && pastListings.isEmpty) {
          return _EmptyMessage(
            message: "No listings yet",
            colors: colors,
            textTheme: textTheme,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (activeListings.isEmpty)
              _EmptyMessage(
                message: "No active listings",
                colors: colors,
                textTheme: textTheme,
              )
            else
              ...activeListings.map(
                (listing) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ActiveListingCard(listing: listing),
                ),
              ),

            if (pastListings.isNotEmpty) ...[
              const SizedBox(height: 8),
              _PastListingsDropdown(
                pastListings: pastListings,
                isExpanded: _showPastListings,
                onToggle: () =>
                    setState(() => _showPastListings = !_showPastListings),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PastListingsDropdown extends StatelessWidget {
  final List<Listing> pastListings;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _PastListingsDropdown({
    required this.pastListings,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () async {
              await safeVibrate(HapticsType.selection);
              onToggle();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("View Past Listings", style: textTheme.bodySmall),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(Icons.expand_more, color: colors.onSurface),
                  ),
                ],
              ),
            ),
          ),
        ),

        ClipRect(
          child: AnimatedAlign(
            heightFactor: isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                ...pastListings.map(
                  (listing) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ActiveListingCard(listing: listing),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ValueBanner extends StatelessWidget {
  final double total;

  const _ValueBanner({required this.total});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'saved ',
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: textTheme.headlineMedium?.copyWith(color: colors.primary, fontSize: 24),
        ),
        Text(
          ' on campus dining',
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}


class _EmptyMessage extends StatelessWidget {
  final String message;
  final ColorScheme colors;
  final TextTheme textTheme;

  const _EmptyMessage({
    required this.message,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: textTheme.bodyMedium?.copyWith(color: colors.outlineVariant),
        textAlign: TextAlign.center,
      ),
    );
  }
}
