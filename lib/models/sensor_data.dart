// lib/models/sensor_data.dart
// Shows the lectures from different sensorsa connected to the ESP board
class SensorData {
  final double temperature;
  final double humidity;
  final String timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
} 