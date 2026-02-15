import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class StarContainer extends StatelessWidget {
  final double? stars;
  final bool background;
  const StarContainer({super.key, required this.stars, this.background = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 24,
      decoration: BoxDecoration(
        color: background
            ? Color(0xBF98D2EB)
            : Color.fromARGB(0, 152, 210, 235), // 75% opacity blue
        borderRadius: BorderRadius.circular(30),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset("assets/star.svg", width: 18, height: 18),
          const SizedBox(width: 5), // Add some spacing between star and text
          Text(
            stars?.toStringAsFixed(2) ?? '5.00',
            style: GoogleFonts.instrumentSans(
              fontSize: 16,
              color: const Color.fromARGB(255, 27, 27, 27),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
