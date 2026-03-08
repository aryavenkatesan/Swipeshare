import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/ratings_bottom_sheet.dart';
import 'package:swipeshare_app/components/refreshable_page.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/pages/inbox_page.dart';
import 'package:swipeshare_app/pages/profile_page.dart';
import 'package:swipeshare_app/pages/swipes_page.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/services/user_service.dart';

import 'dashboard/dashboard_page.dart';
import 'home_page.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final OrderService _orderService = OrderService.instance;

  UserModel? userData;
  bool isLoading = true;
  String? error;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      UserModel user = await UserService.instance.getCurrentUser();

      final deadline = DateTime.now().add(const Duration(seconds: 5));

      // Retry fetching to address post-login delay issues
      while (user.name.isEmpty && DateTime.now().isBefore(deadline)) {
        debugPrint('DEBUG: User name is empty, retrying...');
        user = await UserService.instance.getCurrentUser();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (user.name.isEmpty) {
        debugPrint('DEBUG: User name is still empty after retries.');
        setState(() {
          error =
              'Unable to load your profile details. Please try again later.';
          isLoading = false;
        });
        return;
      }

      setState(() {
        userData = user;
        isLoading = false;
      });

      _animationController.forward();

      // Check for orders that need rating
      _checkOrdersToRate();
    } catch (e) {
      debugPrint('ERROR loading user data: $e');
      setState(() {
        error = 'Something went wrong. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> _checkOrdersToRate() async {
    // final ordersToRate = [
    //   MealOrder(
    //     sellerId: userData!.id,
    //     buyerId: "bruh",
    //     sellerName: "bruh",
    //     buyerName: "bruh",
    //     diningHall: "Chase",
    //     sellerStars: 5,
    //     buyerStars: 5,
    //     transactionDate: DateTime.now(),
    //     sellerHasNotifs: false,
    //     buyerHasNotifs: false,
    //     status: OrderStatus.completed,
    //   ),
    // ];
    final ordersToRate = await _orderService.getOrdersToRate();
    if (ordersToRate.isNotEmpty && mounted) {
      RatingsBottomSheet.show(context, ordersToRate);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(error!),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUserData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    Widget pageHeader(String title) {
      final textTheme = Theme.of(context).textTheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.displayLarge),
          const Divider(),
        ],
      );
    }

    final headers = <Widget>[
      DashboardHeader(userData: userData!),
      pageHeader("Swipes"),
      pageHeader("Inbox"),
      pageHeader("Profile"),
    ];

    final bodies = <Widget>[
      const DashboardContent(),
      const SwipesPage(),
      const InboxPage(),
      const ProfilePage(),
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        body: AnimatedSwitcher(
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          duration: const Duration(milliseconds: 140),
          child: _selectedIndex == 4
              ? HomeScreen(key: const ValueKey(4))
              : RefreshablePage(
                  key: ValueKey(_selectedIndex),
                  header: headers[_selectedIndex],
                  onRefresh: _loadUserData,
                  child: bodies[_selectedIndex],
                ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1, thickness: 1, color: Color.fromARGB(97, 158, 158, 158)),
            BottomNavigationBar(
          selectedFontSize: 14,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_rounded),
              label: 'Swipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sunny_snowing),
              label: 'Old Home',
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }
}
