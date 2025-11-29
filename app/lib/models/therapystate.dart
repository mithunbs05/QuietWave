import 'package:flutter/material.dart';

class TherapyState extends ChangeNotifier {
  double frequency = 5030;
  bool isPlaying = false;
  String mode = "headphone";
  int bpm = 0;
  String stage = "Normal";
  double adviceFreq = 0;

  void setFrequency(double f) {
    frequency = f;
    notifyListeners();
  }

  void adjustFrequency(double step) {
    frequency += step;
    notifyListeners();
  }

  void setPlay(bool value) {
    isPlaying = value;
    notifyListeners();
  }

  void setMode(String m) {
    mode = m;
    notifyListeners();
  }

  void setPulse(int p) {
    bpm = p;
    notifyListeners();
  }

  void setStage(String s) {
    stage = s;
    notifyListeners();
  }

  void setAdvice(double a) {
    adviceFreq = a;
    notifyListeners();
  }
}
