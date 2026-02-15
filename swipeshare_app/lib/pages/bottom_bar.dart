import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'swipes_page.dart';
import 'inbox_page.dart';
import 'profile_page.dart';
import 'home_page.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const DashboardPage(),
    const SwipesPage(),
    const InboxPage(),
    const ProfilePage(),
    HomeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This switches the view based on the current index
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 14,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // 'fixed' prevents the icons from shifting/hiding labels if you have more than 3 items
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_rounded),
            label: 'Swipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sunny_snowing),
            label: 'Old Home',
          ),
        ],
      ),
    );
  }
}
