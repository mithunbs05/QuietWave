# QuietWave

##  **Abstract**

**Quiet Wave** is an embedded, IoT-based therapeutic system designed to help users manage tinnitus through customizable sound waves and safe electrical stimulation.

The device is built entirely on the **ESP32-C6**, which performs:

- **AI-assisted tinnitus frequency estimation**
- **Heart-rate analysis**
- **Real-time sine-wave audio synthesis (PCM5102A DAC)**
- **Low-amplitude PWM stimulation for electrode pads**
- **Secure IoT communication via MQTT**
- **Full user interaction through a Flutter mobile app**

Users adjust their tinnitus frequency through a mobile app using a slider and fine-tuning controls (**+1, +5, +10 Hz**), monitor their heart rate, select therapy modes, and analyze tinnitus severity.

---

#  Key Features

##  **Personalized Frequency Therapy**
- User-defined tinnitus frequency using the app slider
- Pure sine wave generated via **PCM5102A**
- **AI algorithm** determines tinnitus stage (Normal / Abnormal) and also predicts the frequency
- Reverse-frequency cancellation option

##  **Real-Time Heart Rate Monitoring**
- Pulse sensor input to ESP32-C6
- Live BPM displayed in the app
- AI evaluates tinnitus reaction and stress stage

##  **Dual Therapy Outputs**

### **Headphone Mode**
- High-quality audio output through **PCM5102A → 3.5mm jack**

### **Electrode Pad Mode**
- Safe, ultra-low-amplitude PWM stimulation output

##  **Flutter Mobile App**
- Slider + fine control buttons (**+1, +5, +10**)
- **Play / Pause / Stop** controls
- **Save** frequency presets
- Category tabs: **Coloured**, **Natural**, **Binaural**, **Vehicle**
- Displays **BPM**, **tinnitus stage**, **advice frequency**
- Mode selection: **Headphone** or **Electrode Pads**
- MQTT-based real-time updates

---

#  MQTT Topics

### **Control Topics**
tinnitus/control/freq  
tinnitus/control/play  
tinnitus/control/pause  
tinnitus/control/stop  
tinnitus/control/mode  
tinnitus/control/adjust  
tinnitus/control/vol  

### **Status Topics**
tinnitus/status/pulse  
tinnitus/status/stage  
tinnitus/status/freq  
tinnitus/status/mode  

---

#  Hardware Used

| Component | Purpose |
|----------|---------|
| **ESP32-C6 DevKit** | Main controller for audio generation, AI logic, and IoT |
| **PCM5102A DAC** | High-quality sine wave output |
| **Pulse Sensor** | Heart rate input |
| **Snap-Type Electrode Pads** | Skin-contact electrical stimulation |
| **3.5mm Audio Jack** | Wired headphones output |
| **5-inch TFT Display (Optional)** | Optional visual UI |
| **5V Power Module** | Power supply |

---

#  Software Stack

### **ESP32-C6 Firmware**
- Arduino / ESP-IDF
- I2S digital audio generation
- PWM stimulation control
- ADC pulse sensing
- MQTT client
- AI analysis logic

### **Flutter Mobile App**
- MQTT client
- Real-time UI updates
- Custom therapy tuner widgets
- Health and status monitoring

---

# 🚀 Setup and Installation

## **1. Flash ESP32-C6**
1. Install ESP32 board support inside Arduino IDE
2. Open the /firmware folder
3. Flash firmware to ESP32-C6
4. Device automatically initializes MQTT

## **2. Install and Run the Flutter App**
flutter pub get  
flutter run  

Set your MQTT broker IP inside settings_screen.dart.

---

#  How to Use

1. Launch the Flutter App  
2. Adjust tinnitus tone using slider or fine buttons  
3. Tap **Play**  
4. Select output mode: Headphones / Electrode Pads  
5. Monitor:  
   - **BPM**  
   - **Tinnitus Stage**  
   - **Advice Frequency**  
6. Save therapy presets

---

# ⚠️ Safety Notes
- Electrode stimulation is limited to **5% amplitude** for safe skin-contact use
- This is **not a medical device**
- For research, prototype, and competition use only

---

#  Contributing
Pull requests are welcome to improve:
- **AI models**
- **Sound libraries**
- **Custom enclosures**
- **Advanced audio waveforms**

---

#  License
This project is licensed under:

**GNU General Public License v3.0 (GPLv3)**

