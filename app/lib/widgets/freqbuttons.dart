import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/therapy_state.dart';
import '../mqtt/mqtt_manager.dart';

class FrequencyButtons extends StatelessWidget {
  final List<double> steps = [-10, -5, -1, 1, 5, 10];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TherapyState>(context);
    final mqtt = Provider.of<MQTTManager>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: steps.map((step) {
        return GestureDetector(
          onTap: () {
            state.adjustFrequency(step);
            mqtt.publish("tinnitus/control/adjust", step.toString());
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF1B1E22),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              step > 0 ? "+$step" : "$step",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        );
      }).toList(),
    );
  }
}
