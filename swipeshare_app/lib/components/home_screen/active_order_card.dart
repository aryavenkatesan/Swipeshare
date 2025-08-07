import 'package:swipeshare_app/components/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActiveOrderCard extends StatelessWidget {
  final String title;
  final String time;

  const ActiveOrderCard({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.pushNamed(context, '/order_details');
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF98D2EB), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: HeaderStyle),
            const SizedBox(height: 4),
            Text(time, style: SubTextStyle),
          ],
        ),
      ),
    );
  }
}
