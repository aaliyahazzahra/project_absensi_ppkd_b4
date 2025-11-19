import 'package:flutter/material.dart';
import 'package:project_absensi_ppkd_b4/core/app_color.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/auth/profile_page.dart';
import 'package:project_absensi_ppkd_b4/presentation/view/history_page.dart';

import 'home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(), // Tab 1
    HistoryPage(), // Tab 2
    ProfilePage(), // Tab 3
    // Center(child: Text('More Page')), // Tab 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.more_horiz_outlined),
          //   activeIcon: Icon(Icons.more_horiz),
          //   label: 'More',
          // ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColor.retroDarkRed,
        selectedItemColor: AppColor.retroCream,
        unselectedItemColor: AppColor.retroCream.withOpacity(0.6),
        showUnselectedLabels: false,
        showSelectedLabels: true,
      ),
    );
  }
}
