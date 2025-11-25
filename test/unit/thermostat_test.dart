import 'package:flutter_test/flutter_test.dart';
import 'package:smart_device_tester/sensor_interface.dart';
import 'package:smart_device_tester/thermostat.dart';
import 'package:mocktail/mocktail.dart';

class MockSensor extends Mock implements SensorInterface {}

void main() {
  group('Thermostat - Unit Tests', () {
    late Thermostat thermostat;

    setUp(() {
      thermostat = Thermostat();
    });

    group('setTargetTemperature - Límites', () {
      test('should clamp to minimum when value is below allowed range', () {
        final result = thermostat.setTargetTemperature(5.0);

        expect(result, Thermostat.minTemperature);
        expect(thermostat.targetTemperature, Thermostat.minTemperature);
      });

      test('should clamp to maximum when value is above allowed range', () {
        final result = thermostat.setTargetTemperature(35.0);

        expect(result, Thermostat.maxTemperature);
        expect(thermostat.targetTemperature, Thermostat.maxTemperature);
      });

      test('should accept value at minimum boundary', () {
        final result = thermostat.setTargetTemperature(15.0);

        expect(result, 15.0);
        expect(thermostat.targetTemperature, 15.0);
      });

      test('should accept value at maximum boundary', () {
        final result = thermostat.setTargetTemperature(30.0);

        expect(result, 30.0);
        expect(thermostat.targetTemperature, 30.0);
      });

      test('should accept value within valid range', () {
        final result = thermostat.setTargetTemperature(22.5);

        expect(result, 22.5);
        expect(thermostat.targetTemperature, 22.5);
      });

      test('should clamp negative values to minimum', () {
        final result = thermostat.setTargetTemperature(-10.0);

        expect(result, Thermostat.minTemperature);
        expect(thermostat.targetTemperature, Thermostat.minTemperature);
      });

      test('should clamp very high values to maximum', () {
        final result = thermostat.setTargetTemperature(100.0);

        expect(result, Thermostat.maxTemperature);
        expect(thermostat.targetTemperature, Thermostat.maxTemperature);
      });
    });

    group('Conversiones de Unidades', () {
      test('should convert Celsius to Fahrenheit correctly', () {
        final fahrenheit = thermostat.celsiusToFahrenheit(20.0);

        expect(fahrenheit, 68.0);
      });

      test('should convert Fahrenheit to Celsius correctly', () {
        final celsius = thermostat.fahrenheitToCelsius(68.0);

        expect(celsius, 20.0);
      });

      test('should get target temperature in Fahrenheit', () {
        thermostat.setTargetTemperature(25.0);
        final fahrenheit = thermostat.getTargetTemperatureFahrenheit();

        expect(fahrenheit, 77.0);
      });

      test('should set target temperature from Fahrenheit', () {
        final result = thermostat.setTargetTemperatureFromFahrenheit(77.0);

        expect(result, 25.0);
        expect(thermostat.targetTemperature, 25.0);
      });

      test('should clamp Fahrenheit values when converting', () {
        thermostat.setTargetTemperatureFromFahrenheit(32.0);

        expect(thermostat.targetTemperature, Thermostat.minTemperature);
      });
    });

    group('Estado de Calefacción/Refrigeración', () {
      test('should set heating when current is below target', () async {
        final mockSensor = MockSensor();
        when(() => mockSensor.readValue()).thenAnswer((_) async => 18.0);
        thermostat.setTargetTemperature(22.0);

        await thermostat.checkCurrentTemperature(mockSensor);

        expect(thermostat.isHeating, isTrue);
        expect(thermostat.isCooling, isFalse);
      });

      test('should set cooling when current is above target', () async {
        final mockSensor = MockSensor();
        when(() => mockSensor.readValue()).thenAnswer((_) async => 25.0);
        thermostat.setTargetTemperature(22.0);

        await thermostat.checkCurrentTemperature(mockSensor);

        expect(thermostat.isHeating, isFalse);
        expect(thermostat.isCooling, isTrue);
      });

      test('should set neither when current equals target', () async {
        final mockSensor = MockSensor();
        when(() => mockSensor.readValue()).thenAnswer((_) async => 22.0);
        thermostat.setTargetTemperature(22.0);

        await thermostat.checkCurrentTemperature(mockSensor);

        expect(thermostat.isHeating, isFalse);
        expect(thermostat.isCooling, isFalse);
      });
    });

    group('Diferencia de Temperatura', () {
      test('should calculate temperature difference correctly', () async {
        final mockSensor = MockSensor();
        when(() => mockSensor.readValue()).thenAnswer((_) async => 23.0);
        thermostat.setTargetTemperature(20.0);

        await thermostat.checkCurrentTemperature(mockSensor);
        final diff = thermostat.getTemperatureDifference();

        expect(diff, 3.0);
      });

      test('should return null when current temperature is not set', () {
        final diff = thermostat.getTemperatureDifference();

        expect(diff, isNull);
      });
    });

    group('Validación de Rango Aceptable', () {
      test('should return true when temperature is within ±2°C', () async {
        final mockSensor = MockSensor();
        when(() => mockSensor.readValue()).thenAnswer((_) async => 21.5);
        thermostat.setTargetTemperature(20.0);

        await thermostat.checkCurrentTemperature(mockSensor);

        expect(thermostat.isTemperatureAcceptable(), isTrue);
      });

      test('should return false when temperature is outside ±2°C', () async {
        final mockSensor = MockSensor();
        when(() => mockSensor.readValue()).thenAnswer((_) async => 25.0);
        thermostat.setTargetTemperature(20.0);

        await thermostat.checkCurrentTemperature(mockSensor);

        expect(thermostat.isTemperatureAcceptable(), isFalse);
      });

      test('should return false when current temperature is null', () {
        expect(thermostat.isTemperatureAcceptable(), isFalse);
      });
    });

    group('Reset', () {
      test('should reset to default temperature', () async {
        final mockSensor = MockSensor();
        when(() => mockSensor.readValue()).thenAnswer((_) async => 25.0);
        thermostat.setTargetTemperature(28.0);
        await thermostat.checkCurrentTemperature(mockSensor);

        thermostat.reset();

        expect(thermostat.targetTemperature, 20.0);
        expect(thermostat.currentTemperature, isNull);
        expect(thermostat.isHeating, isFalse);
        expect(thermostat.isCooling, isFalse);
      });
    });
  });
}

