import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_device_tester/sensor_interface.dart';
import 'package:smart_device_tester/thermostat.dart';
import 'package:smart_device_tester/widgets/temperature_slider.dart';

class MockSensor extends Mock implements SensorInterface {}

void main() {
  group('Thermostat E2E/Integration Tests', () {
    late Thermostat thermostat;
    late MockSensor mockSensor;

    setUp(() {
      thermostat = Thermostat();
      mockSensor = MockSensor();
    });

    testWidgets(
      'should display current temperature when sensor responds successfully',
      (WidgetTester tester) async {
        // Arrange: Configurar mock para responder con éxito
        when(() => mockSensor.readValue()).thenAnswer((_) async => 22.5);

        // Act: Construir widget y simular interacción
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TemperatureSlider(
                thermostat: thermostat,
                sensor: mockSensor,
              ),
            ),
          ),
        );

        // Esperar a que se cargue la temperatura inicial
        await tester.pumpAndSettle();

        // Assert: Verificar que la temperatura actual se muestra correctamente
        expect(find.text('Temperatura Actual: 22.5°C'), findsOneWidget);
        expect(thermostat.currentTemperature, 22.5);
        expect(find.text('Error al leer sensor'), findsNothing);
      },
    );

    testWidgets(
      'should handle sensor failure gracefully and return safe value',
      (WidgetTester tester) async {
        // Arrange: Configurar mock para lanzar excepción
        when(() => mockSensor.readValue())
            .thenThrow(Exception('Sensor connection failed'));

        // Act: Construir widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TemperatureSlider(
                thermostat: thermostat,
                sensor: mockSensor,
              ),
            ),
          ),
        );

        // Esperar a que se intente cargar y falle
        await tester.pumpAndSettle();

        // Assert: Verificar que se maneja la excepción elegantemente
        expect(find.text('Error al leer sensor'), findsOneWidget);
        expect(thermostat.currentTemperature, 0.0);
        expect(find.text('Temperatura Actual: 0.0°C'), findsOneWidget);
      },
    );

    testWidgets(
      'should update temperature when button is pressed',
      (WidgetTester tester) async {
        // Arrange: Configurar mock para responder con diferentes valores
        var callCount = 0;
        when(() => mockSensor.readValue()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return 20.0;
          return 23.5;
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TemperatureSlider(
                thermostat: thermostat,
                sensor: mockSensor,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verificar temperatura inicial
        expect(find.text('Temperatura Actual: 20.0°C'), findsOneWidget);

        // Act: Presionar botón de actualizar
        await tester.tap(find.text('Actualizar Temperatura'));
        await tester.pumpAndSettle();

        // Assert: Verificar que se actualizó la temperatura
        expect(find.text('Temperatura Actual: 23.5°C'), findsOneWidget);
        expect(thermostat.currentTemperature, 23.5);
      },
    );

    testWidgets(
      'should update target temperature when slider is moved',
      (WidgetTester tester) async {
        when(() => mockSensor.readValue()).thenAnswer((_) async => 20.0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TemperatureSlider(
                thermostat: thermostat,
                sensor: mockSensor,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Act: Mover el slider
        final slider = find.byType(Slider);
        await tester.drag(slider, const Offset(50, 0));
        await tester.pumpAndSettle();

        // Assert: Verificar que la temperatura objetivo cambió
        expect(thermostat.targetTemperature, greaterThan(20.0));
        expect(thermostat.targetTemperature, lessThanOrEqualTo(30.0));
      },
    );

    testWidgets(
      'should show loading indicator while fetching temperature',
      (WidgetTester tester) async {
        // Arrange: Configurar mock con delay para ver el loading
        when(() => mockSensor.readValue()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return 22.0;
        });

        // Act: Construir widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TemperatureSlider(
                thermostat: thermostat,
                sensor: mockSensor,
              ),
            ),
          ),
        );

        // Assert: Verificar que aparece el indicador de carga
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Esperar a que termine la carga
        await tester.pumpAndSettle();

        // Verificar que desaparece el loading
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Temperatura Actual: 22.0°C'), findsOneWidget);
      },
    );
  });
}

