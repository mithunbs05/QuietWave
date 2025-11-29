import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/therapy_state.dart';

class TopStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TherapyState>(context);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1B1E22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          statusRow("Now:", "${state.frequency.toStringAsFixed(1)} Hz"),
          statusRow("BPM:", "${state.bpm}"),
          statusRow("Advice:", "${state.adviceFreq.toStringAsFixed(1)} Hz"),
          statusRow("Stage:", state.stage),
        ],
      ),
    );
  }

  Widget statusRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            key,
            style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w400),
          ),
          SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
                fontSize: 16,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
