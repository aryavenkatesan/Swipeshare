import 'package:swipeshare_app/components/home_screen/place_order_card.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/pages/buy_swipes.dart';
import 'package:swipeshare_app/pages/sell_post.dart';
import 'package:swipeshare_app/services/auth/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final bool hasOrders;

  const HomeScreen({super.key, required this.hasOrders});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool hasOrders;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    hasOrders = widget.hasOrders;
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
              if (hasOrders)
                //TODO: Change the conditional and the data population
                Row(
                  children: [
                    orderCard("Chase", "11:00 AM", active: true),
                    SizedBox(width: 12),
                    orderCard("Lenoir", "12:00 PM"),
                  ],
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
            ],
          ),
        ),
      ),
    );
  }

  Widget orderCard(String title, String time, {bool active = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: active ? Colors.red : Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: [Text(title), Text(time)]),
    );
  }
}
