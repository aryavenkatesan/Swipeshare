import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/payment_options_picker.dart';
import 'package:swipeshare_app/components/chat_screen/time_formatter.dart';
import 'package:swipeshare_app/components/home_screen/active_order_card.dart';
import 'package:swipeshare_app/components/home_screen/hyperlinks.dart';
import 'package:swipeshare_app/components/home_screen/place_order_card.dart';
import 'package:swipeshare_app/components/star_container.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/pages/buy_swipes.dart';
import 'package:swipeshare_app/pages/sell_post.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/services/user_service.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

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

  UserModel? userData;
  bool isLoading = true;
  List<String> _paymentTypes = [];

  late AnimationController _animationController;
  late Animation<double>? _fadeAnimation;

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
    _animationController?.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await _userService.getUserData(_auth.currentUser!.uid);
    setState(() {
      userData = user;
      isLoading = false;
    });

    _paymentTypes = user!.paymentTypes;

    // Start fade-in animation after data is loaded
    _animationController.forward();
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
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 30.0,
              left: 30.0,
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
                          "Hi, ${userData?.name ?? ''}",
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BuySwipeScreen(),
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
                            onTap: () {
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

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Active Listings Go Here",
                            style: SubHeaderStyle,
                          ),
                          Text("Trust the process", style: SubTextStyle),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),
                    Text("Rewards", style: HeaderStyle),
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("50% off", style: SubHeaderStyle),
                          Text(
                            "After referring two friends",
                            style: SubTextStyle,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 48),
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
    final String recieverName = userData?.name != order.buyerName
        ? order.buyerName
        : order.sellerName;

    return ActiveOrderCard(
      title: data['diningHall'],
      time: data['displayTime'] != null
          ? TimeFormatter.formatTimeOfDay(data['displayTime'])
          : "TBD",
      receiverUserID: _auth.currentUser!.uid == data['sellerId']
          ? data['buyerId']
          : data['sellerId'],
      orderData: order,
      receiverName: recieverName,
    );
  }
}
