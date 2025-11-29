import 'package:flutter/material.dart';
import 'therapy_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final screens = [
    CategoryScreen(),
    TherapyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: Container(
        height: 75,
        padding: EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: Color(0xFF111316),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navButton("Music", Icons.music_note, 0),
            navButton("Tuner", Icons.tune, 1),
          ],
        ),
      ),
    );
  }

  Widget navButton(String label, IconData icon, int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: selectedIndex == index
                  ? Colors.blueAccent
                  : Colors.grey,
              size: 28),
          SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                color: selectedIndex == index
                    ? Colors.blueAccent
                    : Colors.grey,
                fontSize: 12,
              ))
        ],
      ),
    );
  }
}
