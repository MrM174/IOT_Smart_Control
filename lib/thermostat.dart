class Thermostat {
  double _targetTemperature = 20.0; // Default initial temperature
  
  double get targetTemperature => _targetTemperature;

  //unit to test: adjust temperature and returns status message
  String setTargetTemperature(double newTemp) {
    if (newTemp < 15.0) {
      _targetTemperature = 15.0;
      return 'WARNING: Temperature tool low. Maintained at 15.0°C';
    }
    if (newTemp > 30.0) {
      _targetTemperature = 30.0;
      return 'WARNING: Temperature too high. Maintained at 30.0°C';
    }
    _targetTemperature = newTemp;
    return 'Temperature set to ${newTemp.toStringAsFixed(1)}°C';
    }
  } 