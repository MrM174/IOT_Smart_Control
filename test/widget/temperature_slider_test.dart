import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_device_tester/thermostat.dart';
import 'package:smart_device_tester/widgets/temperature_slider.dart';

void main() {
  group('TemperatureSlider Widget Tests', () {
    late Thermostat thermostat;

    setUp(() {
      thermostat = Thermostat();
    });

    testWidgets('should render slider widget correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TemperatureSlider(
              thermostat: thermostat,
            ),
          ),
        ),
      );

      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Temperatura Objetivo: 20.0°C'), findsOneWidget);
    });

    testWidgets('should update target temperature when slider is moved', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TemperatureSlider(
              thermostat: thermostat,
            ),
          ),
        ),
      );

      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(thermostat.targetTemperature, greaterThan(20.0));
    });

    testWidgets('should display button to update temperature', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TemperatureSlider(
              thermostat: thermostat,
            ),
          ),
        ),
      );

      expect(find.text('Actualizar Temperatura'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}

