import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/components/home_screen/active_order_card.dart';
import 'package:swipeshare_app/components/home_screen/place_order_card.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/pages/buy_swipes.dart';
import 'package:swipeshare_app/pages/sell_post.dart';
import 'package:swipeshare_app/providers/auth_provider.dart';
import 'package:swipeshare_app/providers/order_provider.dart';
import 'package:swipeshare_app/providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void signOut(BuildContext context) => context.read<AuthProvider>().logout();

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, OrderProvider>(
      builder: (context, userProvider, orderProvider, child) {
        // Show loading state while user data is being fetched
        debugPrint("userProvider.isLoading: ${userProvider.isLoading}");
        debugPrint("orderProvider.isLoading: ${orderProvider.isLoading}");
        debugPrint(
          "userProvider.hasInitialized: ${userProvider.hasInitialized}",
        );
        debugPrint(
          "orderProvider.hasInitialized: ${orderProvider.hasInitialized}",
        );
        debugPrint("userProvider.error: ${userProvider.error}");
        debugPrint("orderProvider.error: ${orderProvider.error}");

        // Show error state if user data failed to load
        if (userProvider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading user data: ${userProvider.error}'),
                  ElevatedButton(
                    onPressed: () => userProvider.ensureInitialized(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show error state if orders failed to load
        if (orderProvider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading orders: ${orderProvider.error}'),
                  ElevatedButton(
                    onPressed: () => orderProvider.ensureInitialized(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (userProvider.isLoading ||
            orderProvider.isLoading ||
            !userProvider.hasInitialized ||
            !orderProvider.hasInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Main UI - user data is loaded
        debugPrint("userProvider.currentUser: ${userProvider.currentUser}");
        final user = userProvider.currentUser!;
        final orders = orderProvider.orders;

        debugPrint("orders: $orders");

        Widget buildOrderCard(MealOrder order) {
          return ActiveOrderCard(
            title: order.diningHall,
            time: (order.time != null)
                ? "${order.time!.hour}:${order.time!.minute.toString().padLeft(2, '0')}"
                : "TBD",
            receiverUserID: user.id == order.sellerId
                ? order.buyerId
                : order.sellerId,
          );
        }

        Widget buildOrderSection() {
          final hasOrders = orders.isNotEmpty;

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
              children: orders.map((order) => buildOrderCard(order)).toList(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xBF98D2EB), // 75% opacity blue
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset("assets/star.svg", width: 18, height: 18),
                    const SizedBox(
                      width: 5,
                    ), // Add some spacing between star and text
                    Text(
                      '5.00', //TODO: "{$_auth.currentUser!.rating}"
                      style: GoogleFonts.instrumentSans(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 27, 27, 27),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              //signout button
              IconButton(
                onPressed: () => signOut(context),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 12.0,
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
                          "Hi, ${user.email}",
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
                    buildOrderSection(),
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
                                  builder: (context) => SellPostScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
                    GestureDetector(
                      //This should always be at the bottom
                      onTap: () async {
                        await launchUrl(
                          Uri.parse(
                            "https://docs.google.com/forms/d/e/1FAIpQLSfTmI3DIHP85a78MlNmQ9gUicQhjff5Tj34pWsUhvN6ATzGXg/viewform",
                          ),
                          mode: LaunchMode.inAppBrowserView,
                        );
                      },
                      child: Center(
                        child: Text("Give us Feedback!", style: SubTextStyle),
                      ),
                    ),
                    SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
