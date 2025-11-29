import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../models/therapy_state.dart';

class MQTTManager {
  late MqttServerClient client;

  MQTTManager() {
    client = MqttServerClient('broker.hivemq.com', 'quietwave_app');
    client.port = 1883;
    client.logging(on: false);
    client.keepAlivePeriod = 20;

    client.onConnected = () => print("MQTT Connected");
    client.onDisconnected = () => print("MQTT Disconnected");

    connect();
  }

  Future<void> connect() async {
    final connMessage = MqttConnectMessage().startClean();
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print("MQTT Error: $e");
      client.disconnect();
    }

    client.subscribe("tinnitus/status/pulse", MqttQos.atLeastOnce);
    client.subscribe("tinnitus/status/freq", MqttQos.atLeastOnce);
    client.subscribe("tinnitus/status/stage", MqttQos.atLeastOnce);
    client.subscribe("tinnitus/status/mode", MqttQos.atLeastOnce);
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void listen(BuildContext context) {
    client.updates?.listen((events) {
      final rec = events.first.payload as MqttPublishMessage;
      final msg = MqttPublishPayload.bytesToStringAsString(rec.payload.message);

      final state = Provider.of<TherapyState>(context, listen: false);

      switch (events.first.topic) {
        case "tinnitus/status/pulse":
          state.setPulse(int.tryParse(msg) ?? 0);
          break;

        case "tinnitus/status/stage":
          state.setStage(msg);
          break;

        case "tinnitus/status/freq":
          state.setFrequency(double.tryParse(msg) ?? state.frequency);
          break;

        case "tinnitus/status/mode":
          state.setMode(msg);
          break;
      }
    });
  }
}
