import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/app_feedback_bottom_sheet.dart';
import 'package:swipeshare_app/components/ratings_bottom_sheet.dart';
import 'package:swipeshare_app/components/refreshable_page.dart';
import 'package:swipeshare_app/main.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/pages/dev/dev_page.dart';
import 'package:swipeshare_app/pages/inbox_page.dart';
import 'package:swipeshare_app/pages/profile_page.dart';
import 'package:swipeshare_app/pages/sell/create_swipe_listing_page.dart';
import 'package:swipeshare_app/pages/swipes_page.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/services/user_service.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dashboard/dashboard_page.dart';

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

  bool popupChecks({int transactions = 2}) {
    // True = show feedback popup, False = don't show
    return userData != null &&
        !userData!.hasSeenAppFeedback &&
        userData!.transactionsCompleted >= transactions;
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

  Future<void> _requestStoreReview() async {
    if (popupChecks() == false) return;
    final inAppReview = InAppReview.instance;
    if (!await inAppReview.isAvailable()) return;
    await UserService.instance.updateUserData(
      userData!.id,
      {'hasRequestedStoreReview': true},
    );
    await inAppReview.requestReview();
  }

  Future<void> _checkOrdersToRate() async {
    final ordersToRate = await _orderService.getOrdersToRate();
    if (ordersToRate.isNotEmpty && mounted) {
      final showFeedback = userData != null && !userData!.hasSeenAppFeedback;
      RatingsBottomSheet.show(
        context,
        ordersToRate,
        onComplete: showFeedback
            ? () {
                if (mounted) {
                  AppFeedbackBottomSheet.show(
                    context,
                    onComplete: _requestStoreReview,
                  );
                }
              }
            : () async => await _requestStoreReview(),
      );
    } else if (popupChecks(transactions: 1) &&
        mounted) {
      AppFeedbackBottomSheet.show(
        context,
        onComplete: _requestStoreReview,
      );
    } else if (popupChecks() &&
        mounted) {
      await _requestStoreReview();
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

    Widget swipesHeader() {
      final colors = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Swipes", style: textTheme.displayLarge),
              GestureDetector(
                onTap: () => launchUrl(
                  Uri.parse("https://dining.unc.edu/menu-hours/"),
                  mode: LaunchMode.inAppBrowserView,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "Menu",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                      fontWeight: FontWeight.w300,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      );
    }

    final headers = <Widget>[
      DashboardHeader(userData: userData!),
      swipesHeader(),
      pageHeader("Inbox"),
      pageHeader("Profile"),
      if (isDevMode) pageHeader("Dev Panel"),
    ];

    final bodies = <Widget>[
      DashboardContent(userData: userData!,),
      const SwipesPage(),
      const InboxPage(),
      const ProfilePage(),
      if (isDevMode) const DevPage(),
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        body: AnimatedSwitcher(
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          duration: const Duration(milliseconds: 140),
          child: RefreshablePage(
            key: ValueKey(_selectedIndex),
            header: headers[_selectedIndex],
            onRefresh: _loadUserData,
            stickyBottom: _selectedIndex == 1
                ? Padding(
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
                      icon: const Icon(
                        CupertinoIcons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                      label: const Text('Sell a Swipe'),
                    ),
                  )
                : null,
            child: bodies[_selectedIndex],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              height: 1,
              thickness: 1,
              color: Color.fromARGB(97, 158, 158, 158),
            ),
            BottomNavigationBar(
              selectedFontSize: 14,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Dashboard',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money_rounded),
                  label: 'Swipes',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.chat_outlined),
                  label: 'Inbox',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
                if (isDevMode)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.bug_report_outlined),
                    label: 'Dev',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
