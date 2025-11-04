import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/text_styles.dart';

class Page6 extends StatelessWidget {
  final bool tutorial;
  // Controller to get the code from the text field
  final TextEditingController? codeController;

  const Page6({super.key, required this.tutorial, this.codeController});

  @override
  Widget build(BuildContext context) {
    final double vh = MediaQuery.of(context).size.height;
    final double vw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      // Use SingleChildScrollView to prevent keyboard overflow
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: vh * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: vh > 767 ? (vh * 0.065) : (vh * 0.01)),
            Image.asset(
              'assets/onboarding6.png',
              width: vw * 0.8,
              fit: BoxFit.fitWidth,
            ),
            SizedBox(height: vh > 767 ? 30 : 0), // Adjusted spacing
            Column(
              children: [
                Text(
                  tutorial ? "Don't Forget!" : "Let's get started!",
                  style: AppTextStyles.subHeaderStyle,
                ),
                SizedBox(height: vh * 0.02),
                Text(
                  tutorial
                      ? "Whenever using the app, always make sure to be courteous and respectful!"
                      : "Please check your email inbox for the 6-digit verification code. It may be in your spam folder.",
                  style: AppTextStyles.bodyText,
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // --- ADDED: Verification Code Input Field ---
            if (!tutorial)
              Padding(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 24, letterSpacing: 16),
                  decoration: InputDecoration(
                    counterText: "", // Hide the "0/6" counter
                    hintText: "------",
                    hintStyle: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 16,
                      color: Colors.grey,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 30, 88, 181),
                      ),
                    ),
                  ),
                ),
              ),
            // --- End of Added Section ---
          ],
        ),
      ),
    );
  }
}
