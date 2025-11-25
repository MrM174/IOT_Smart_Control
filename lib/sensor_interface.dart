abstract class SensorInterface {
  Future<double> readValue();
}

abstract class HumiditySensor {
  Future<double> readHumidity();
}

abstract class COxDetector {
  Future<double> readCOxLevel();

  void triggerVentilation();
}

abstract class LightDetector {
  Future<double> readLux();
}

