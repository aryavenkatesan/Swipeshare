import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipeshare_app/components/home_screen/active_order_card.dart';
import 'package:swipeshare_app/components/home_screen/place_order_card.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/pages/buy_swipes.dart';
import 'package:swipeshare_app/pages/sell_post.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MealOrder> orders = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  @override
  void initState() {
    super.initState();
    print("HomeScreen initState called");

    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print("User authenticated: ${user.email}");
        _listenToUserOrders();
      } else {
        print("User not authenticated");
        // Handle unauthenticated state
      }
    });
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  // Function to listen to real-time updates for orders
  void _listenToUserOrders() {
    print(_auth.currentUser == null);
    String currentUserId = "123089";
    try {
      currentUserId = _auth.currentUser!.uid;
    } catch (e, s) {
      print(e);
      print(s);
    }

    _ordersSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where(
          Filter.or(
            Filter('sellerId', isEqualTo: currentUserId),
            Filter('buyerId', isEqualTo: currentUserId),
          ),
        )
        .snapshots()
        .listen(
          (QuerySnapshot querySnapshot) {
            List<MealOrder> userOrders = [];
            for (QueryDocumentSnapshot doc in querySnapshot.docs) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              // Create MealOrder from the document data
              MealOrder order = MealOrder(
                docId: doc.id,
                sellerId: data['sellerId'],
                buyerId: data['buyerId'],
                location: data['location'],
                transactionDate: DateTime.parse(data['transactionDate']),
                time: data['time'],
              );
              userOrders.add(order);
            }

            setState(() {
              orders = userOrders;
            });
          },
          onError: (error) {
            print('Error listening to orders: $error');
          },
        );
  }

  void signOut() {
    //get auth service
    final authService = Provider.of<AuthServices>(context, listen: false);

    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
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
                    "Hi, ${_auth.currentUser!.email}",
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
              if (orders.isNotEmpty)
                //TODO: Change the conditional and the data population
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: orders.map((order) {
                      // Adjust these based on your MealOrder model properties
                      String location = order.location;
                      String time = (order.time != null)
                          ? "${order.time!.hour}:${order.time!.minute.toString().padLeft(2, '0')}"
                          : "TBD";
                      bool isActive = true; //change this

                      return Padding(
                        padding: EdgeInsets.only(
                          right: orders.last == order ? 0 : 12,
                        ),
                        child: ActiveOrderCard(title: location, time: time),
                      );
                    }).toList(),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Orders will show up here—tap the buttons below to buy a swipe from someone or sell a swipe to someone else!",
                    style: SubTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 20),
              Text("Place Order", style: HeaderStyle),
              SizedBox(height: 12),
              Row(
                children: [
                  PlaceOrderCard(
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
                  SizedBox(width: 22),
                  PlaceOrderCard(
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
                ],
              ),
              SizedBox(height: 24),
              Text("Rewards", style: HeaderStyle),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("50% off", style: SubHeaderStyle),
                    Text("After referring two friends", style: SubTextStyle),
                  ],
                ),
              ),

              //Feedback section, to be stuck at the bottom
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellPostScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Give us feedback!",
                      style: SubTextStyle,
                      textAlign: TextAlign.center,
                    ),
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