import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/old_components/text_styles.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  // null = no card tapped, 0 = order, 1 = listing
  int? _tappedCard;

  void _onCardTap(int index) async {
    await safeVibrate(HapticsType.selection);
    setState(() => _tappedCard = index);
  }

  String get _title {
    switch (_tappedCard) {
      case 0:
        return "Active Orders";
      case 1:
        return "Your Listings";
      default:
        return "Dashboard";
    }
  }

  String get _description {
    switch (_tappedCard) {
      case 0:
        return "These are swipes you're buying.\nTap an order to view details or chat with the seller!";
      case 1:
        return "These are swipes you're selling.\nTap to edit or remove a listing!";
      default:
        return "View your current orders and active listings.\nTap them to see details or make edits!";
    }
  }

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: vh > 767 ? (vh * 0.03) : 8),

            // Active Orders section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Active Orders",
                    style: AppTextStyles.headerStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MockDashboardCard(
                    location: 'Chase',
                    date: '1/13',
                    time: 'From 3:30 PM to 4:00 PM',
                    trailing: Icon(Icons.chevron_right,
                        color: Colors.grey.shade600),
                    isTapped: _tappedCard == 0,
                    onTap: () => _onCardTap(0),
                    primaryColor: colorScheme.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Your Listings section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Listings",
                    style: AppTextStyles.headerStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MockDashboardCard(
                    location: 'Chase',
                    date: '1/13',
                    time: 'From 3:30 PM to 4:00 PM',
                    trailing: Icon(Icons.more_horiz,
                        color: Colors.grey.shade600),
                    isTapped: _tappedCard == 1,
                    onTap: () => _onCardTap(1),
                    primaryColor: colorScheme.primary,
                  ),
                ],
              ),
            ),

            SizedBox(height: vh > 767 ? 30 : 16),

            Divider(
              height: vh * 0.02,
              color: const Color.fromRGBO(197, 197, 197, 1),
              indent: 24,
              endIndent: 24,
            ),

            SizedBox(height: vh > 767 ? 30 : 16),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
              child: Center(
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _title,
                        key: ValueKey(_title),
                        style: AppTextStyles.subHeaderStyle,
                      ),
                    ),
                    SizedBox(height: vh * 0.02),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _description,
                        key: ValueKey(_description),
                        style: AppTextStyles.bodyText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockDashboardCard extends StatelessWidget {
  final String location;
  final String date;
  final String time;
  final Widget trailing;
  final bool isTapped;
  final VoidCallback onTap;
  final Color primaryColor;

  const _MockDashboardCard({
    required this.location,
    required this.date,
    required this.time,
    required this.trailing,
    required this.isTapped,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              isTapped ? primaryColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTapped ? primaryColor : const Color(0xFFE0E0E0),
            width: isTapped ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        location,
                        style: AppTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(date, style: AppTextStyles.subText),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: AppTextStyles.subText.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
