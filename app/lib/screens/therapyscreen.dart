import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/therapy_state.dart';
import '../mqtt/mqtt_manager.dart';

class TherapyScreen extends StatefulWidget {
  final String category;  

  TherapyScreen({this.category = "Custom"});

  @override
  State<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen> {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // PAGE TITLE
            Text(
              widget.category,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // ---------------------------
            // TOP STATUS BOX
            // ---------------------------
            topStatusBox(context, state),

            SizedBox(height: 20),

            // ---------------------------
            // SLIDER + FREQUENCY
            // ---------------------------
            sliderSection(context, state),

            SizedBox(height: 20),

            // ---------------------------
            // FINE ADJUST BUTTONS
            // ---------------------------
            fineAdjustButtons(context, state),

            SizedBox(height: 20),

            // ---------------------------
            // PLAY / PAUSE / STOP
            // ---------------------------
            playPauseButtons(context, state),

            SizedBox(height: 20),

            // ---------------------------
            // MODE SELECT (HEADPHONE / ELECTRODE)
            // ---------------------------
            modeSelector(context, state),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // TOP STATUS BAR
  // ================================================================
  Widget topStatusBox(BuildContext context, TherapyState state) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1B1E22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          statusRow("Now:.   ", state.frequency.toStringAsFixed(1) + " Hz"),
          statusRow("BPM:.  ", state.bpm.toString()),
          statusRow("Advice:", state.adviceFreq.toStringAsFixed(1) + " Hz"),
          statusRow("Stage: ", state.stage),
        ],
      ),
    );
  }

  Widget statusRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(key,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400)),
          SizedBox(width: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ================================================================
  // SLIDER SECTION
  // ================================================================
  Widget sliderSection(BuildContext context, TherapyState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Frequency Tuner",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 10),

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

  // ================================================================
  // FINE TUNE BUTTONS
  // ================================================================
  Widget fineAdjustButtons(BuildContext context, TherapyState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            adjustButton("-10", -10, state),
            adjustButton("-5", -5, state),
            adjustButton("-1", -1, state),
            adjustButton("+1", 1, state),
            adjustButton("+5", 5, state),
            adjustButton("+10", 10, state),
          ],
        )
      ],
    );
  }

  Widget adjustButton(String text, double step, TherapyState state) {
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
          text,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  // ================================================================
  // PLAY / PAUSE / STOP BUTTONS
  // ================================================================
  Widget playPauseButtons(BuildContext context, TherapyState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // STOP
        controlButton(
          Icons.stop,
          Colors.redAccent,
          () {
            state.setPlay(false);
            Provider.of<MQTTManager>(context, listen: false)
                .publish("tinnitus/control/stop", "1");
          },
        ),

        SizedBox(width: 20),

        // PLAY / PAUSE TOGGLE
        controlButton(
          state.isPlaying ? Icons.pause : Icons.play_arrow,
          Colors.greenAccent,
          () {
            state.setPlay(!state.isPlaying);
            Provider.of<MQTTManager>(context, listen: false).publish(
                state.isPlaying
                    ? "tinnitus/control/play"
                    : "tinnitus/control/pause",
                "1");
          },
        ),
      ],
    );
  }

  Widget controlButton(IconData icon, Color color, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Color(0xFF1B1E22),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  // ================================================================
  // MODE (HEADPHONE / ELECTRODE)
  // ================================================================
  Widget modeSelector(BuildContext context, TherapyState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Output Mode",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

        SizedBox(height: 10),

        Row(
          children: [
            modeButton("Headphone", "headphone", state),
            SizedBox(width: 10),
            modeButton("Electrode", "electrode", state),
          ],
        )
      ],
    );
  }

  Widget modeButton(String label, String mode, TherapyState state) {
    bool active = (state.mode == mode);

    return GestureDetector(
      onTap: () {
        state.setMode(mode);
        mqtt.publish("tinnitus/control/mode", mode);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.blueAccent : Color(0xFF1B1E22),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
