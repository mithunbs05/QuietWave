#include <WiFi.h>
#include <PubSubClient.h>
#include <driver/i2s.h>
const char* ssid = "YOUR_WIFI";
const char* password = "YOUR_PASSWORD";
const char* mqtt_server = "broker.hivemq.com";
WiFiClient espClient;
PubSubClient client(espClient);

// --------------------
// PCM5102A I2S PINS
// --------------------
#define I2S_BCK   4
#define I2S_WS    3
#define I2S_DOUT  2
#define SAMPLE_RATE 44100

// --------------------
// ELECTRODE OUTPUT PIN (PWM)
// --------------------
#define ELECTRODE_PIN 11

// --------------------
// PULSE SENSOR (ANALOG)
// --------------------
#define PULSE_PIN 1

// --------------------
// STATE VARIABLES
// --------------------
float currentFreq = 5000;
bool therapyRunning = false;
String outputMode = "headphone"; // "electrode", "headphone"
int volumeLevel = 80; // 0–100
unsigned long lastPulseReport = 0;

// --------------------
// AI LOGIC
// --------------------
String tinnitusStage = "Normal";

String analyzeStage(int bpm) {
  if (bpm > 95) return "Abnormal";
  return "Normal";
}

// --------------------
// I2S AUDIO SETUP
// --------------------
void initI2S() {
  i2s_config_t config;
  config.mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_TX);
  config.sample_rate = SAMPLE_RATE;
  config.bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT;
  config.channel_format = I2S_CHANNEL_FMT_ONLY_LEFT;
  config.communication_format = I2S_COMM_FORMAT_I2S;
  config.intr_alloc_flags = ESP_INTR_FLAG_LEVEL1;
  config.dma_buf_count = 4;
  config.dma_buf_len = 1024;
  config.use_apll = false;

  i2s_pin_config_t pin_config;
  pin_config.bck_io_num = I2S_BCK;
  pin_config.ws_io_num = I2S_WS;
  pin_config.data_out_num = I2S_DOUT;
  pin_config.data_in_num = -1;

  i2s_driver_install(I2S_NUM_0, &config, 0, NULL);
  i2s_set_pin(I2S_NUM_0, &pin_config);
}

// --------------------
// GENERATE SINE WAVE
// --------------------
void playTone(float freq) {
  int samples = SAMPLE_RATE / freq;
  int16_t buffer[samples];

  float amplitude = 20000 * (volumeLevel / 100.0);

  for (int i = 0; i < samples; i++)
    buffer[i] = (int16_t)(sin(2 * M_PI * i / samples) * amplitude);

  size_t written;
  i2s_write(I2S_NUM_0, buffer, sizeof(buffer), &written, portMAX_DELAY);
}

// --------------------
// ELECTRODE OUTPUT (SAFE 5% AMPLITUDE)
// --------------------
void playElectrode(float freq) {
  float pwmFreq = freq;
  int pwmValue = 13; // very low amplitude (SAFE)

  ledcSetup(0, pwmFreq, 8);
  ledcAttachPin(ELECTRODE_PIN, 0);
  ledcWrite(0, pwmValue);
}

// --------------------
// STOP ELECTRODE OUTPUT
// --------------------
void stopElectrode() {
  ledcDetachPin(ELECTRODE_PIN);
}

// --------------------
// READ PULSE SENSOR
// --------------------
int readPulse() {
  int val = analogRead(PULSE_PIN);
  return map(val, 0, 4095, 60, 120);
}

// --------------------
// MQTT CALLBACK
// --------------------
void callback(char* topic, byte* message, unsigned int len) {
  String msg;
  for (int i = 0; i < len; i++) msg += (char)message[i];

  if (String(topic) == "tinnitus/control/freq")
    currentFreq = msg.toFloat();

  if (String(topic) == "tinnitus/control/play")
    therapyRunning = true;

  if (String(topic) == "tinnitus/control/pause")
    therapyRunning = false;

  if (String(topic) == "tinnitus/control/stop")
    therapyRunning = false;

  if (String(topic) == "tinnitus/control/mode")
    outputMode = msg;

  if (String(topic) == "tinnitus/control/adjust")
    currentFreq += msg.toFloat();
}

// --------------------
// MQTT RECONNECT
// --------------------
void reconnect() {
  while (!client.connected()) {
    if (client.connect("QuietWaveESP32C6")) {
      client.subscribe("tinnitus/control/freq");
      client.subscribe("tinnitus/control/play");
      client.subscribe("tinnitus/control/pause");
      client.subscribe("tinnitus/control/stop");
      client.subscribe("tinnitus/control/mode");
      client.subscribe("tinnitus/control/adjust");
    }
    delay(1000);
  }
}

// --------------------
// SETUP
// --------------------
void setup() {
  Serial.begin(115200);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) delay(200);

  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  initI2S();
  pinMode(PULSE_PIN, INPUT);
}

// --------------------
// LOOP
// --------------------
void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  // Therapy running
  if (therapyRunning) {
    if (outputMode == "headphone") {
      playTone(currentFreq);
    } else {
      playElectrode(currentFreq);
    }
  } else {
    stopElectrode();
  }

  // Pulse every 1 second
  if (millis() - lastPulseReport > 1000) {
    int bpm = readPulse();
    tinnitusStage = analyzeStage(bpm);

    client.publish("tinnitus/status/pulse", String(bpm).c_str());
    client.publish("tinnitus/status/stage", tinnitusStage.c_str());
    client.publish("tinnitus/status/freq", String(currentFreq).c_str());
    client.publish("tinnitus/status/mode", outputMode.c_str());

    lastPulseReport = millis();
  }
}
