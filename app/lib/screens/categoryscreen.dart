import 'package:flutter/material.dart';
import 'therapy_screen.dart';

class CategoryScreen extends StatelessWidget {
  final tabs = ["Coloured", "Natural", "Binaural", "Vehicle"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text("Tinnitus Frequencies",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),

          // Tabs
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: tabs.map((t) => tabButton(t, context)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget tabButton(String title, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => TherapyScreen(category: title)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Color(0xFF1B1E22),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(title, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
