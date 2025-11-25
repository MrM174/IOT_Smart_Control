class BatteryMonitor {
  bool isCritical(int level) {
    if (level < 0 || level > 100) {
      throw ArgumentError('Battery level must be between 0 and 100');
    }
    return level <= 10;
  }
}

