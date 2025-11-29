import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/therapy_state.dart';
import '../mqtt/mqtt_manager.dart';

class FrequencySlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TherapyState>(context);
    final mqtt = Provider.of<MQTTManager>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Frequency Tuner",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 10),

        // Slider widget
        Slider(
          value: state.frequency,
          min: 20,
          max: 20000,
          activeColor: Colors.blueAccent,
          onChanged: (v) {
            state.setFrequency(v);
            mqtt.publish("tinnitus/control/freq", v.toString());
          },
        ),

        SizedBox(height: 5),

        // Current frequency display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${state.frequency.toStringAsFixed(1)} Hz",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
          ],
        ),
      ],
    );
  }
}
