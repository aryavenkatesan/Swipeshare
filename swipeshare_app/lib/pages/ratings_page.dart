import 'package:flutter/material.dart';

class RatingsPage extends StatefulWidget {
  const RatingsPage({super.key});

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("This is the Ratings Page"),
            SizedBox(height: 48),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}
