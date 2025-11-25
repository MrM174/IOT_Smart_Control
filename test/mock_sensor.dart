import 'package:mocktail/mocktail.dart';
import 'package:smart_device_tester/sensor_interface.dart';

class MockSensor extends Mock
    implements SensorInterface, HumiditySensor, COxDetector, LightDetector {}

