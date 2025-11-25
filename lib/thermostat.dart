class Thermostat {
  static const double minTemperature = 15.0;
  static const double maxTemperature = 30.0;

  double _targetTemperature = 20.0;

  double get targetTemperature => _targetTemperature;

  /// Sets the target temperature while ensuring it respects the allowed range.
  /// Returns the applied temperature so tests can assert the clamp logic.
  double setTargetTemperature(double newTemperature) {
    if (newTemperature < minTemperature) {
      _targetTemperature = minTemperature;
    } else if (newTemperature > maxTemperature) {
      _targetTemperature = maxTemperature;
    } else {
      _targetTemperature = newTemperature;
    }
    return _targetTemperature;
  }
}