import 'package:flutter_test/flutter_test.dart';
import 'package:smart_device_tester/battery_monitor.dart';
import 'package:smart_device_tester/command_protocol.dart';
import 'package:smart_device_tester/data_validator.dart';
import 'package:smart_device_tester/led_controller.dart';
import 'package:smart_device_tester/log_buffer.dart';
import 'package:smart_device_tester/thermostat.dart';

void main() {
  group('Thermostat', () {
    late Thermostat thermostat;

    setUp(() {
      thermostat = Thermostat();
    });

    test('should clamp to maximum when value is above allowed range', () {
      final result = thermostat.setTargetTemperature(35);

      expect(result, Thermostat.maxTemperature);
      expect(thermostat.targetTemperature, Thermostat.maxTemperature);
    });

    test('should clamp to minimum when value is below allowed range', () {
      final result = thermostat.setTargetTemperature(5);

      expect(result, Thermostat.minTemperature);
      expect(thermostat.targetTemperature, Thermostat.minTemperature);
    });
  });

  group('LEDController', () {
    late LEDController controller;

    setUp(() {
      controller = LEDController();
    });

    test('should report on when turnOn is called', () {
      controller.turnOn();

      expect(controller.isOn, isTrue);
    });

    test('should report off when turnOff is called', () {
      controller.turnOn();

      controller.turnOff();

      expect(controller.isOn, isFalse);
    });
  });

  group('DataValidator', () {
    late DataValidator validator;

    setUp(() {
      validator = DataValidator();
    });

    test('should return true when value is within inclusive range', () {
      expect(validator.isValid(50), isTrue);
    });

    test('should return false when value is outside allowed range', () {
      expect(validator.isValid(150), isFalse);
    });
  });

  group('CommandProtocol', () {
    late CommandProtocol protocol;

    setUp(() {
      protocol = CommandProtocol();
    });

    test('should format command when action and data are provided', () {
      final command = protocol.createCommand(' set ', 'value ');

      expect(command, 'SET:value');
    });
  });

  group('BatteryMonitor', () {
    late BatteryMonitor monitor;

    setUp(() {
      monitor = BatteryMonitor();
    });

    test('should detect critical level when percentage is less or equal to ten', () {
      expect(monitor.isCritical(10), isTrue);
      expect(monitor.isCritical(11), isFalse);
    });
  });

  group('LogBuffer', () {
    late LogBuffer buffer;

    setUp(() {
      buffer = LogBuffer();
    });

    test('should keep only last five entries when capacity exceeded', () {
      for (var i = 0; i < 7; i++) {
        buffer.add('log $i');
      }

      final logs = buffer.getLogs();

      expect(logs.length, 5);
      expect(logs.first, 'log 2');
      expect(logs.last, 'log 6');
    });
  });
}

