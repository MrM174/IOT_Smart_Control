import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_device_tester/sensor_interface.dart';
import 'package:smart_device_tester/thermostat.dart';

import '../mock_sensor.dart';

void main() {
  group('Thermostat - Unit Tests', () {
    late Thermostat thermostat;

    setUp(() {
      thermostat = Thermostat();
    });

    // Arrange-Act-Assert pattern tests for setTargetTemperature
    test('should set target temperature when value is within valid range', () {
      // Arrange
      const validTemperature = 22.5;

      // Act
      final result = thermostat.setTargetTemperature(validTemperature);

      // Assert
      expect(result, validTemperature);
      expect(thermostat.targetTemperature, validTemperature);
    });

    test('should clamp to minimum when value is below allowed range', () {
      // Arrange
      const belowMinimum = 10.0;

      // Act
      final result = thermostat.setTargetTemperature(belowMinimum);

      // Assert
      expect(result, Thermostat.minTemperature);
      expect(thermostat.targetTemperature, Thermostat.minTemperature);
    });

    test('should clamp to maximum when value is above allowed range', () {
      // Arrange
      const aboveMaximum = 35.0;

      // Act
      final result = thermostat.setTargetTemperature(aboveMaximum);

      // Assert
      expect(result, Thermostat.maxTemperature);
      expect(thermostat.targetTemperature, Thermostat.maxTemperature);
    });

    test('should accept exact minimum temperature', () {
      // Arrange
      const exactMinimum = Thermostat.minTemperature;

      // Act
      final result = thermostat.setTargetTemperature(exactMinimum);

      // Assert
      expect(result, exactMinimum);
      expect(thermostat.targetTemperature, exactMinimum);
    });

    test('should accept exact maximum temperature', () {
      // Arrange
      const exactMaximum = Thermostat.maxTemperature;

      // Act
      final result = thermostat.setTargetTemperature(exactMaximum);

      // Assert
      expect(result, exactMaximum);
      expect(thermostat.targetTemperature, exactMaximum);
    });

    test('should handle decimal temperature values correctly', () {
      // Arrange
      const decimalTemperature = 23.7;

      // Act
      final result = thermostat.setTargetTemperature(decimalTemperature);

      // Assert
      expect(result, decimalTemperature);
      expect(thermostat.targetTemperature, decimalTemperature);
    });

    // Tests for temperature conversion methods
    test('should convert Celsius to Fahrenheit correctly', () {
      // Arrange
      const celsius = 20.0;
      const expectedFahrenheit = 68.0;

      // Act
      final result = thermostat.celsiusToFahrenheit(celsius);

      // Assert
      expect(result, closeTo(expectedFahrenheit, 0.1));
    });

    test('should convert Fahrenheit to Celsius correctly', () {
      // Arrange
      const fahrenheit = 68.0;
      const expectedCelsius = 20.0;

      // Act
      final result = thermostat.fahrenheitToCelsius(fahrenheit);

      // Assert
      expect(result, closeTo(expectedCelsius, 0.1));
    });

    test('should get target temperature in Fahrenheit', () {
      // Arrange
      thermostat.setTargetTemperature(20.0);
      const expectedFahrenheit = 68.0;

      // Act
      final result = thermostat.getTargetTemperatureFahrenheit();

      // Assert
      expect(result, closeTo(expectedFahrenheit, 0.1));
    });

    test('should set target temperature from Fahrenheit and clamp correctly', () {
      // Arrange
      const fahrenheit = 86.0; // 30°C
      const expectedCelsius = 30.0;

      // Act
      final result = thermostat.setTargetTemperatureFromFahrenheit(fahrenheit);

      // Assert
      expect(result, closeTo(expectedCelsius, 0.1));
    });

    test('should clamp Fahrenheit input that exceeds maximum', () {
      // Arrange
      const highFahrenheit = 100.0; // Would be ~37.8°C, should clamp to 30°C

      // Act
      final result = thermostat.setTargetTemperatureFromFahrenheit(highFahrenheit);

      // Assert
      expect(result, Thermostat.maxTemperature);
    });

    // Tests for heating/cooling state
    test('should set heating state when current temperature is below target', () async {
      // Arrange
      thermostat.setTargetTemperature(25.0);
      final mockSensor = MockSensor();
      when(() => mockSensor.readValue()).thenAnswer((_) async => 20.0);

      // Act
      await thermostat.checkCurrentTemperature(mockSensor);

      // Assert
      expect(thermostat.isHeating, isTrue);
      expect(thermostat.isCooling, isFalse);
    });

    test('should set cooling state when current temperature is above target', () async {
      // Arrange
      thermostat.setTargetTemperature(20.0);
      final mockSensor = MockSensor();
      when(() => mockSensor.readValue()).thenAnswer((_) async => 25.0);

      // Act
      await thermostat.checkCurrentTemperature(mockSensor);

      // Assert
      expect(thermostat.isCooling, isTrue);
      expect(thermostat.isHeating, isFalse);
    });

    test('should set neither heating nor cooling when temperatures match', () async {
      // Arrange
      thermostat.setTargetTemperature(22.0);
      final mockSensor = MockSensor();
      when(() => mockSensor.readValue()).thenAnswer((_) async => 22.0);

      // Act
      await thermostat.checkCurrentTemperature(mockSensor);

      // Assert
      expect(thermostat.isHeating, isFalse);
      expect(thermostat.isCooling, isFalse);
    });

    // Tests for temperature difference
    test('should calculate temperature difference correctly', () async {
      // Arrange
      thermostat.setTargetTemperature(22.0);
      final mockSensor = MockSensor();
      when(() => mockSensor.readValue()).thenAnswer((_) async => 25.0);

      // Act
      await thermostat.checkCurrentTemperature(mockSensor);
      final difference = thermostat.getTemperatureDifference();

      // Assert
      expect(difference, 3.0);
    });

    test('should return null for temperature difference when current is not set', () {
      // Arrange
      thermostat.setTargetTemperature(22.0);

      // Act
      final difference = thermostat.getTemperatureDifference();

      // Assert
      expect(difference, isNull);
    });

    // Tests for acceptable temperature range
    test('should return true when temperature is within acceptable range', () async {
      // Arrange
      thermostat.setTargetTemperature(22.0);
      final mockSensor = MockSensor();
      when(() => mockSensor.readValue()).thenAnswer((_) async => 23.0); // Within ±2°C

      // Act
      await thermostat.checkCurrentTemperature(mockSensor);
      final isAcceptable = thermostat.isTemperatureAcceptable();

      // Assert
      expect(isAcceptable, isTrue);
    });

    test('should return false when temperature is outside acceptable range', () async {
      // Arrange
      thermostat.setTargetTemperature(22.0);
      final mockSensor = MockSensor();
      when(() => mockSensor.readValue()).thenAnswer((_) async => 25.0); // Outside ±2°C

      // Act
      await thermostat.checkCurrentTemperature(mockSensor);
      thermostat.checkCurrentTemperature(mockSensor);
      final isAcceptable = thermostat.isTemperatureAcceptable();

      // Assert
      expect(isAcceptable, isFalse);
    });

    test('should return false for acceptable temperature when current is not set', () {
      // Arrange
      thermostat.setTargetTemperature(22.0);

      // Act
      final isAcceptable = thermostat.isTemperatureAcceptable();

      // Assert
      expect(isAcceptable, isFalse);
    });

    // Test for reset functionality
    test('should reset to default values when reset is called', () {
      // Arrange
      thermostat.setTargetTemperature(28.0);
      final mockSensor = MockSensor();
      when(() => mockSensor.readValue()).thenAnswer((_) async => 25.0);
      thermostat.checkCurrentTemperature(mockSensor);

      // Act
      thermostat.reset();

      // Assert
      expect(thermostat.targetTemperature, 20.0);
      expect(thermostat.currentTemperature, isNull);
      expect(thermostat.isHeating, isFalse);
      expect(thermostat.isCooling, isFalse);
    });

    // Test for checkCurrentTemperature with successful sensor reading
    test('should update current temperature when sensor reading succeeds', () async {
      // Arrange
      const sensorReading = 23.5;
      final mockSensor = MockSensor();
      when(() => mockSensor.readValue()).thenAnswer((_) async => sensorReading);

      // Act
      final result = await thermostat.checkCurrentTemperature(mockSensor);

      // Assert
      expect(result, sensorReading);
      expect(thermostat.currentTemperature, sensorReading);
    });

    // Test for checkCurrentTemperature with sensor failure (returns safe value)
    test('should return safe value 0.0 when sensor throws exception', () async {
      // Arrange
      final mockSensor = MockSensor();
      when(() => mockSensor.readValue()).thenThrow(Exception('Sensor error'));

      // Act
      final result = await thermostat.checkCurrentTemperature(mockSensor);

      // Assert
      expect(result, 0.0);
      expect(thermostat.currentTemperature, 0.0);
      expect(thermostat.isHeating, isFalse);
      expect(thermostat.isCooling, isFalse);
    });
  });
}
