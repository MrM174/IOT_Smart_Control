import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_device_tester/IotController.dart';
import 'package:smart_device_tester/sensor_interface.dart';

import 'mock_sensor.dart';

void main() {
  late MockSensor generalSensor;
  late MockSensor humiditySensor;
  late MockSensor coxDetector;
  late MockSensor lightDetector;
  late IotController controller;

  setUp(() {
    generalSensor = MockSensor();
    humiditySensor = MockSensor();
    coxDetector = MockSensor();
    lightDetector = MockSensor();

    controller = IotController(
      generalSensor: generalSensor,
      humiditySensor: humiditySensor,
      coxDetector: coxDetector,
      lightDetector: lightDetector,
    );
  });

  test('should return sensor value when general sensor succeeds', () async {
    when(() => generalSensor.readValue()).thenAnswer((_) async => 25.0);

    final result = await controller.fetchGeneralReading();

    expect(result, 25.0);
    expect(controller.lastReading, 25.0);
    expect(controller.isLoading, isFalse);
  });

  test('should return fallback value when humidity sensor throws exception', () async {
    when(() => humiditySensor.readHumidity()).thenThrow(Exception('sensor error'));

    final result = await controller.fetchHumidityWithFallback();

    expect(result, -1);
  });

  test('should trigger ventilation when COx level is critical', () async {
    when(() => coxDetector.readCOxLevel()).thenAnswer((_) async => 150.0);
    when(() => coxDetector.triggerVentilation()).thenReturn(null);

    await controller.monitorCriticalGas();

    verify(() => coxDetector.triggerVentilation()).called(1);
    expect(controller.alarmTriggered, isTrue);
  });

  test('should toggle loading indicator when light sensor responds slowly', () async {
    when(() => lightDetector.readLux()).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return 300.0;
    });

    final future = controller.fetchLightLevelWithLatency();
    expect(controller.isLoading, isTrue);

    final value = await future;

    expect(value, 300.0);
    expect(controller.isLoading, isFalse);
  });

  test('should throw TimeoutException when general sensor exceeds timeout', () async {
    when(() => generalSensor.readValue()).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(seconds: 10));
      return 42.0;
    });

    expect(
      () => controller.fetchGeneralReadingWithTimeout(
        timeout: const Duration(milliseconds: 100),
      ),
      throwsA(isA<TimeoutException>()),
    );
  });
}

