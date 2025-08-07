import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.grey[400],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/dogwalk.svg",
                      width: 200,
                      height: 200,
                    ),
                  ],
                ),
                SizedBox(height: 60),
                Text("Walk da dawg"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
