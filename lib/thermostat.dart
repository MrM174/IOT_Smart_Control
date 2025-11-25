import 'sensor_interface.dart';

class Thermostat {
  static const double minTemperature = 15.0;
  static const double maxTemperature = 30.0;

  double _targetTemperature = 20.0;
  double? _currentTemperature;
  bool _isHeating = false;
  bool _isCooling = false;

  double get targetTemperature => _targetTemperature;
  double? get currentTemperature => _currentTemperature;
  bool get isHeating => _isHeating;
  bool get isCooling => _isCooling;

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
    _updateHeatingCoolingState();
    return _targetTemperature;
  }

  /// Checks current temperature from sensor and updates internal state
  /// Returns safe value (0.0) on error instead of throwing
  Future<double> checkCurrentTemperature(SensorInterface sensor) async {
    try {
      _currentTemperature = await sensor.readValue();
      _updateHeatingCoolingState();
      return _currentTemperature!;
    } catch (e) {
      _currentTemperature = 0.0;
      _isHeating = false;
      _isCooling = false;
      return 0.0;
    }
  }

  /// Converts Celsius to Fahrenheit
  double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  /// Converts Fahrenheit to Celsius
  double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  /// Gets target temperature in Fahrenheit
  double getTargetTemperatureFahrenheit() {
    return celsiusToFahrenheit(_targetTemperature);
  }

  /// Sets target temperature from Fahrenheit
  double setTargetTemperatureFromFahrenheit(double fahrenheit) {
    final celsius = fahrenheitToCelsius(fahrenheit);
    return setTargetTemperature(celsius);
  }

  /// Returns the temperature difference between current and target
  double? getTemperatureDifference() {
    if (_currentTemperature == null) return null;
    return (_currentTemperature! - _targetTemperature).abs();
  }

  /// Checks if temperature is within acceptable range (±2°C)
  bool isTemperatureAcceptable() {
    if (_currentTemperature == null) return false;
    final diff = getTemperatureDifference()!;
    return diff <= 2.0;
  }

  /// Resets to default temperature
  void reset() {
    _targetTemperature = 20.0;
    _currentTemperature = null;
    _isHeating = false;
    _isCooling = false;
  }

  void _updateHeatingCoolingState() {
    if (_currentTemperature == null) {
      _isHeating = false;
      _isCooling = false;
      return;
    }

    if (_currentTemperature! < _targetTemperature) {
      _isHeating = true;
      _isCooling = false;
    } else if (_currentTemperature! > _targetTemperature) {
      _isHeating = false;
      _isCooling = true;
    } else {
      _isHeating = false;
      _isCooling = false;
    }
  }
}
