import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home.dart';
import 'models/therapy_state.dart';
import 'mqtt/mqtt_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TherapyState()),
        Provider(create: (_) => MQTTManager()),
      ],
      child: QuietWaveApp(),
    ),
  );
}

class QuietWaveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiet Wave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0B0D0F),
        primaryColor: Colors.blueAccent,
        fontFamily: "Roboto",
      ),
      home: HomeScreen(),
    );
  }
}
