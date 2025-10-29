enum DeviceType { led, sensor, servo }

class SmartDevice {
  final String id;
  final String name;
  final DeviceType type;
  bool isOn;

  SmartDevice({
    required this.id,
    required this.name,
    required this.type,
    this.isOn = false,
  });
}
