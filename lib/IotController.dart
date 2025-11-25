import 'sensor_interface.dart';

class IotController {
  IotController({
    required this.generalSensor,
    required this.humiditySensor,
    required this.coxDetector,
    required this.lightDetector,
  });

  final SensorInterface generalSensor;
  final HumiditySensor humiditySensor;
  final COxDetector coxDetector;
  final LightDetector lightDetector;

  bool isLoading = false;
  double? lastReading;
  bool alarmTriggered = false;

  Future<double> fetchGeneralReading() async {
    isLoading = true;
    try {
      final reading = await generalSensor.readValue();
      lastReading = reading;
      return reading;
    } finally {
      isLoading = false;
    }
  }

  Future<double> fetchHumidityWithFallback() async {
    try {
      return await humiditySensor.readHumidity();
    } catch (_) {
      return -1;
    }
  }

  Future<void> monitorCriticalGas() async {
    final ppm = await coxDetector.readCOxLevel();
    if (ppm >= 100) {
      coxDetector.triggerVentilation();
      alarmTriggered = true;
    }
  }

  Future<double> fetchLightLevelWithLatency() async {
    isLoading = true;
    try {
      return await lightDetector.readLux();
    } finally {
      isLoading = false;
    }
  }

  Future<double> fetchGeneralReadingWithTimeout({
    Duration timeout = const Duration(seconds: 5),
  }) {
    return generalSensor.readValue().timeout(timeout);
  }
}

