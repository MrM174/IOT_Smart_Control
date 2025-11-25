import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_device_tester/sensor_interface.dart';
import 'package:smart_device_tester/thermostat.dart';

import '../mock_sensor.dart';

/// Pruebas End-to-End (E2E) / Integración
/// Simulan el flujo completo: UI -> Firmware (Mock) -> UI
/// Verifican la comunicación bidireccional entre la interfaz y la capa de control
void main() {
  group('Thermostat E2E/Integration Tests', () {
    late Thermostat thermostat;
    late MockSensor mockSensor;

    setUp(() {
      thermostat = Thermostat();
      mockSensor = MockSensor();
    });

    test(
      'should complete full flow when UI sends command and hardware responds successfully',
      () async {
        // Arrange - Simular que la UI envía un comando para verificar temperatura
        // y el hardware (mock) responde con éxito
        const expectedTemperature = 23.5;
        when(() => mockSensor.readValue())
            .thenAnswer((_) async => expectedTemperature);

        // Act - La UI llama a checkCurrentTemperature (simulando interacción del usuario)
        final result = await thermostat.checkCurrentTemperature(mockSensor);

        // Assert - Verificar que el valor retornado se maneja correctamente
        expect(result, expectedTemperature);
        expect(thermostat.currentTemperature, expectedTemperature);
        expect(thermostat.targetTemperature, isNotNull);
        
        // Verificar que el estado interno se actualizó correctamente
        // Si la temperatura actual es diferente a la target, debe activar heating/cooling
        if (thermostat.currentTemperature! < thermostat.targetTemperature) {
          expect(thermostat.isHeating, isTrue);
        } else if (thermostat.currentTemperature! > thermostat.targetTemperature) {
          expect(thermostat.isCooling, isTrue);
        }
      },
    );

    test(
      'should handle exception gracefully and return safe value when sensor fails',
      () async {
        // Arrange - Simular que el hardware falla (lanza excepción)
        when(() => mockSensor.readValue())
            .thenThrow(Exception('Sensor hardware error'));

        // Act - La UI llama a checkCurrentTemperature
        final result = await thermostat.checkCurrentTemperature(mockSensor);

        // Assert - Verificar que la aplicación maneja la excepción de forma elegante
        // retornando un valor seguro (0.0) como se especifica en los requisitos
        expect(result, 0.0);
        expect(thermostat.currentTemperature, 0.0);
        
        // Verificar que el estado de heating/cooling se desactiva en caso de error
        expect(thermostat.isHeating, isFalse);
        expect(thermostat.isCooling, isFalse);
        
        // Verificar que la aplicación no crashea y puede continuar funcionando
        expect(thermostat.targetTemperature, isNotNull);
      },
    );

    test(
      'should update heating state correctly in full flow when current temp is below target',
      () async {
        // Arrange - Configurar temperatura objetivo y simular lectura del sensor
        thermostat.setTargetTemperature(25.0);
        const currentTempFromSensor = 20.0;
        when(() => mockSensor.readValue())
            .thenAnswer((_) async => currentTempFromSensor);

        // Act - Flujo completo: UI solicita lectura -> Sensor responde -> Estado se actualiza
        await thermostat.checkCurrentTemperature(mockSensor);

        // Assert - Verificar que el estado de calefacción se activó correctamente
        expect(thermostat.currentTemperature, currentTempFromSensor);
        expect(thermostat.isHeating, isTrue);
        expect(thermostat.isCooling, isFalse);
      },
    );

    test(
      'should update cooling state correctly in full flow when current temp is above target',
      () async {
        // Arrange
        thermostat.setTargetTemperature(20.0);
        const currentTempFromSensor = 25.0;
        when(() => mockSensor.readValue())
            .thenAnswer((_) async => currentTempFromSensor);

        // Act
        await thermostat.checkCurrentTemperature(mockSensor);

        // Assert
        expect(thermostat.currentTemperature, currentTempFromSensor);
        expect(thermostat.isCooling, isTrue);
        expect(thermostat.isHeating, isFalse);
      },
    );

    test(
      'should maintain stable state when current and target temperatures match',
      () async {
        // Arrange
        const targetTemp = 22.0;
        thermostat.setTargetTemperature(targetTemp);
        when(() => mockSensor.readValue())
            .thenAnswer((_) async => targetTemp);

        // Act
        await thermostat.checkCurrentTemperature(mockSensor);

        // Assert
        expect(thermostat.currentTemperature, targetTemp);
        expect(thermostat.isHeating, isFalse);
        expect(thermostat.isCooling, isFalse);
      },
    );
  });
}
