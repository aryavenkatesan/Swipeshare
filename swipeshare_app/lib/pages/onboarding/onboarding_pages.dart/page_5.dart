import 'package:flutter/material.dart';
import 'package:swipeshare_app/old_components/text_styles.dart';

class Page5 extends StatefulWidget {
  const Page5({super.key});

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _bubble1;
  late Animation<double> _bubble2;
  late Animation<double> _bubble3;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _bubble1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _bubble2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );
    _bubble3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;
    final double vw = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: vh > 767 ? (vh * 0.06) : (vh * 0.03)),

          // Interactive chat bubbles
          SizedBox(
            width: vw * 0.85,
            height: vh * 0.32,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Column(
                  children: [
                    // Bubble 1 — sent (right aligned)
                    _buildBubble(
                      animation: _bubble1,
                      text: "Hey! Want to meet at Lenoir at 1?",
                      isSent: true,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    // Bubble 2 — received (left aligned)
                    _buildBubble(
                      animation: _bubble2,
                      text: "Sounds good! I'll be by the entrance",
                      isSent: false,
                      color: const Color(0xFFE8E8EA),
                    ),
                    const SizedBox(height: 12),
                    // Bubble 3 — sent
                    _buildBubble(
                      animation: _bubble3,
                      text: "Perfect, see you there!",
                      isSent: true,
                      color: colorScheme.primary,
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: vh > 767 ? 60 : 30),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
            child: Column(
              children: [
                Text("Communicate", style: AppTextStyles.subHeaderStyle),
                SizedBox(height: vh * 0.02),
                Text(
                  "Coordinate a time and place to meet with your partner.\nPay before you get swiped in!",
                  style: AppTextStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble({
    required Animation<double> animation,
    required String text,
    required bool isSent,
    required Color color,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: Align(
          alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isSent ? 18 : 4),
                bottomRight: Radius.circular(isSent ? 4 : 18),
              ),
            ),
            child: Text(
              text,
              style: AppTextStyles.bodyText.copyWith(
                color: isSent ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
