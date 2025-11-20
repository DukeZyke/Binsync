import 'package:flutter/material.dart';
import 'collector_home_screen.dart';
import 'collector_map_screen.dart';

class CollectorMainScreen extends StatefulWidget {
  const CollectorMainScreen({super.key});

  @override
  State<CollectorMainScreen> createState() => _CollectorMainScreenState();
}

class _CollectorMainScreenState extends State<CollectorMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    CollectorHomeScreen(),
    CollectorMapScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF00A86B),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Map',
            ),
          ],
        ),
      ),
    );
  }
}
