import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Dashboard Page")),
      backgroundColor: const Color.fromARGB(104, 33, 149, 243),
    );
  }
}
