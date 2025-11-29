import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/therapy_state.dart';
import '../mqtt/mqtt_manager.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late MQTTManager mqtt;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mqtt = Provider.of<MQTTManager>(context);
    mqtt.listen(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TherapyState>(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TITLE
            Text(
              "Settings",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30),

            // ---------------------------------------------------
            // OUTPUT MODE
            // ---------------------------------------------------
            Text(
              "Output Mode",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 12),

            Row(
              children: [
                modeButton("Headphone", "headphone", state),
                SizedBox(width: 12),
                modeButton("Electrode", "electrode", state),
              ],
            ),

            SizedBox(height: 25),

            // ---------------------------------------------------
            // VOLUME CONTROL
            // ---------------------------------------------------
            Text(
              "Volume",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Slider(
              value: state.volume,
              min: 0,
              max: 100,
              activeColor: Colors.blueAccent,
              onChanged: (v) {
                state.setVolume(v);
                mqtt.publish("tinnitus/control/vol", v.toString());
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${state.volume.toStringAsFixed(0)}%",
                  style: TextStyle(fontSize: 20, color: Colors.blueAccent),
                ),
              ],
            ),

            SizedBox(height: 25),

            // ---------------------------------------------------
            // SAVE CURRENT FREQUENCY
            // ---------------------------------------------------
            Text(
              "Save Current Frequency",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                // You can add local storage or cloud save logic later
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Frequency saved successfully!")),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Color(0xFF1B1E22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "Save Frequency (${state.frequency.toStringAsFixed(1)} Hz)",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // ---------------------------------------------------
            // SAFETY NOTICE
            // ---------------------------------------------------
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color(0xFF141619),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Safe Mode",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Electrode output is limited to safe 5% amplitude.\n"
                    "Do not increase system amplitude externally.\n"
                    "For demonstration and medical safety only.",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // ---------------------------------------------------
            // ABOUT SECTION
            // ---------------------------------------------------
            Text(
              "About Quiet Wave",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color(0xFF1B1E22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Quiet Wave is an AI-driven IoT system designed to help users identify and reduce tinnitus using personalized sound therapy.\n\n"
                "ESP32-C6 provides real-time audio generation, electrode output, "
                "heart-rate monitoring, and secure MQTT-based communication.\n\n"
                "Flutter app offers frequency tuning, therapy controls, safety monitoring, "
                "and cloud-enabled connectivity.",
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // Mode Button Widget (Headphone / Electrode)
  // ====================================================
  Widget modeButton(String label, String mode, TherapyState state) {
    bool active = (state.mode == mode);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          state.setMode(mode);
          mqtt.publish("tinnitus/control/mode", mode);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? Colors.blueAccent : Color(0xFF1B1E22),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: active ? Colors.white : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
