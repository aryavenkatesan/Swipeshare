import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/payment_options_picker.dart';
import 'package:swipeshare_app/components/home_screen/active_listing_card.dart';
import 'package:swipeshare_app/components/home_screen/active_order_card.dart';
import 'package:swipeshare_app/components/home_screen/hyperlinks.dart';
import 'package:swipeshare_app/components/home_screen/place_order_card.dart';
import 'package:swipeshare_app/components/star_container.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/pages/buy_swipes.dart';
import 'package:swipeshare_app/pages/onboarding/tutorial_carousel.dart';
import 'package:swipeshare_app/pages/sell_post.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:swipeshare_app/services/listing_service.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<MealOrder> orders = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final OrderService _orderService = OrderService();
  final UserService _userService = UserService();
  final ListingService _listingService = ListingService();

  UserModel? userData;
  bool isLoading = true;
  List<String> _paymentTypes = [];

  late AnimationController _animationController;
  late Animation<double>? _fadeAnimation;

  final ScrollController _scrollController = ScrollController();

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
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
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await _userService.getUserData(_auth.currentUser!.uid);

    print('DEBUG: User data loaded: ${user?.name}, ${user?.email}');

    if (user != null) {
      setState(() {
        userData = user;
        _paymentTypes = user.paymentTypes;
        isLoading = false;
      });

      print('DEBUG: State updated, userData.name: ${userData?.name}');

      // Start fade-in animation after data is loaded
      _animationController.forward();
    }
  }

  void signOut() {
    //get auth service
    final authService = Provider.of<AuthServices>(context, listen: false);

    authService.signOut();
  }

  void _onRefresh() async {
    // monitor network fetch
    var random = Random();
    int sheaintevenknowit = 100 + random.nextInt(1200);
    await Future.delayed(Duration(milliseconds: sheaintevenknowit));

    // Reset animation and reload data
    setState(() {
      isLoading = true;
    });

    _animationController.reset();
    await _loadUserData();

    // Complete the refresh
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 500));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    // final double vh = MediaQuery.of(context).size.height;
    final double vw = MediaQuery.of(context).size.width;

    // Show logo while loading
    if (isLoading) {
      return Scaffold(
        body: Center(
          // child: Image.asset('assets/logo.png', width: 150, height: 150),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0.0,
          actions: [
            //star display
            StarContainer(stars: userData?.stars),
            //signout button
            IconButton(onPressed: signOut, icon: const Icon(Icons.logout)),
          ],
          // bottom: PreferredSize(
          //   preferredSize: Size.fromHeight(1.0),
          //   child: Container(
          //     color: Colors.grey.withOpacity(0.3), // Customize color as needed
          //     height: 1.0,
          //   ),
          // ),
          //This is the grey bar below the header, only looks nice when scrolled
        ),
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
              right: vw > 400 ? 30.0 : 18.0,
              left: vw > 400 ? 30.0 : 18.0,
              bottom: 12.0,
            ),
            child: SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              header: WaterDropHeader(),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  return Text("");
                },
              ),

              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [Color(0xFF98D2EB), Color(0xFFA2A0DD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Hi, ${userData?.name ?? 'null'}",
                          style: GoogleFonts.instrumentSans(
                            fontSize: 48,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1.6,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text("Active Orders", style: HeaderStyle),
                    SizedBox(height: 12),
                    //Handles both orders and no orders
                    _buildOrderSection(),
                    SizedBox(height: 20),
                    Text("Place Order", style: HeaderStyle),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PlaceOrderCard(
                            label: "Buy",
                            iconPath: "assets/fork_and_knife.svg",
                            onTap: () async {
                              if (await Haptics.canVibrate()) {
                                Haptics.vibrate(HapticsType.light);
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BuySwipeScreen(
                                    paymentOptions: _paymentTypes,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 22),
                        Expanded(
                          child: PlaceOrderCard(
                            label: "Sell",
                            iconPath: "assets/wallet.svg",
                            onTap: () async {
                              if (await Haptics.canVibrate()) {
                                Haptics.vibrate(HapticsType.light);
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SellPostScreen(
                                    paymentOptions: _paymentTypes,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    Text("Active Listings", style: HeaderStyle),

                    SizedBox(height: 12),

                    _buildListingSection(),

                    SizedBox(height: 24),

                    Text("Settings", style: HeaderStyle),

                    SizedBox(height: 12),

                    PaymentOptionsComponent(
                      selectedPaymentOptions: _paymentTypes,
                      onPaymentOptionsChanged: (options) {
                        setState(() => _paymentTypes = options);
                      },
                      fromHomeScreen: true,
                      onUpdatePreferredMethods: () {
                        _userService.updatePaymentTypes(
                          _auth.currentUser!.uid,
                          _paymentTypes,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Preferred payment methods updated succesfully!',
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24),

                    Text(
                      "Replay Tutorial",
                      style: HeaderStyle,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 12),

                    //tutorial widget
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TutorialCarousel(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(105, 255, 255, 255),
                          border: Border.all(
                            color: const Color(0x6998D2EB),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Swipeology 101",
                              // "Replay Tutorial",
                              style: SubHeaderStyle.copyWith(fontSize: 20),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Help yourself or a friend learn the ropes!",
                              style: SubTextStyle,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 48),
                    Hyperlinks(),
                    SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _orderService.getOrders(_auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        final docs = snapshot.data?.docs ?? [];
        final hasOrders = docs.isNotEmpty;

        if (!hasOrders) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Orders will show up here—tap the buttons below to buy a swipe from someone or sell a swipe to someone else!",
              style: SubTextStyle,
              textAlign: TextAlign.center,
            ),
          );
        }

        // Has orders -> show horizontally scrollable cards
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: docs.map((doc) => _buildOrderCard(doc)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    MealOrder order = MealOrder.fromMap(data);

    return ActiveOrderCard(orderData: order);
  }

  Widget _buildListingSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _listingService.getUserListings(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        final docs = snapshot.data?.docs ?? [];
        final hasOrders = docs.isNotEmpty;

        if (!hasOrders) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Listings will show up here to keep track of when you're selling! Once placed, you can tap to delete :)",
              style: SubTextStyle,
              textAlign: TextAlign.center,
            ),
          );
        }

        // Has orders -> show horizontally scrollable cards
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: docs.map((doc) => _buildListingCard(doc)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildListingCard(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    Listing currentlisting = Listing.fromMap(data);

    return ActiveListingCard(
      currentListing: currentlisting,
      listingId: document.id,
    );
  }
}
