import 'package:swipeshare_app/components/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PlaceOrderCard extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onTap;

  const PlaceOrderCard({
    super.key,
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          border: Border.all(color: const Color(0xFFE7E7E7), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 60, height: 60),
            const SizedBox(height: 12),
            Text(label, style: HeaderStyle),
          ],
        ),
      ),
    );
  }
}
