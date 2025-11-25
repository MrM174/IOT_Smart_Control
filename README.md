# Smart Device Tester

Proyecto Flutter que implementa un sistema de control y monitoreo para dispositivos IoT inteligentes, con un enfoque en la calidad del software mediante la implementación de la pirámide de pruebas (Unit Testing, Mocking y Widget Testing).

## Descripción

Este proyecto permite gestionar y probar dispositivos IoT mediante una aplicación Flutter que incluye control de temperatura, monitoreo de sensores, validación de datos y gestión de comandos. El proyecto está diseñado siguiendo buenas prácticas de testing para garantizar la confiabilidad y mantenibilidad del código.

## Características Implementadas

### Clases de Dominio (lib/)

- **Thermostat**: Control de temperatura con límites entre 15.0°C y 30.0°C
- **LEDController**: Control de LEDs con métodos turnOn() y turnOff()
- **DataValidator**: Validación de valores numéricos en rango 1-100
- **CommandProtocol**: Creación de comandos en formato 'ACTION:DATA'
- **BatteryMonitor**: Monitoreo de nivel de batería con detección de estado crítico (≤10%)
- **LogBuffer**: Almacenamiento circular que mantiene solo las últimas 5 entradas

### Sistema de Sensores

- **SensorInterface**: Interfaz base para sensores genéricos
- **HumiditySensor**: Interfaz para sensores de humedad
- **COxDetector**: Interfaz para detectores de monóxido de carbono con activación de ventilación
- **LightDetector**: Interfaz para sensores de iluminación
- **IotController**: Controlador principal que gestiona todos los sensores mediante inyección de dependencias

### Widgets de Interfaz

- **LEDWidget**: Widget que muestra un icono de color (Verde cuando está encendido, Gris cuando está apagado)
- **ControlPanelWidget**: Widget con contador interactivo y botón flotante para incrementar

## Estructura de Pruebas

El proyecto implementa la pirámide de pruebas completa:

### Unit Tests (9 tests)

Ubicación: `test/unit/domain_classes_test.dart`

- Tests para Thermostat: validación de límites mínimo y máximo
- Tests para LEDController: verificación de estados encendido/apagado
- Tests para DataValidator: validación de rangos válidos e inválidos
- Tests para CommandProtocol: formato correcto de comandos
- Tests para BatteryMonitor: detección de nivel crítico
- Tests para LogBuffer: capacidad limitada a 5 entradas

### Mocking Tests (5 tests)

Ubicación: `test/iot_controller_test.dart`

- Simulación de respuesta exitosa de sensores
- Manejo de excepciones y valores de fallback
- Verificación de llamadas a métodos (verify)
- Simulación de latencia y estados de carga
- Manejo de timeouts con TimeoutException

### Widget Tests (5 tests)

Ubicación: `test/widget/`

- Renderizado de LEDWidget en estados encendido/apagado
- Estado inicial de ControlPanelWidget
- Interacción con botón (1 tap y 5 taps)

**Total: 20 tests implementados, todos pasando**

## Tecnologías Utilizadas

- Flutter SDK 3.9.2+
- mocktail 1.0.4 para mocking de dependencias
- flutter_test para pruebas unitarias y de widgets
- Patrón Arrange-Act-Assert (AAA) en todos los tests
- Inyección de Dependencias para desacoplamiento

## Estructura del Proyecto

```
lib/
├── thermostat.dart
├── led_controller.dart
├── data_validator.dart
├── command_protocol.dart
├── battery_monitor.dart
├── log_buffer.dart
├── sensor_interface.dart
├── IotController.dart
└── widgets/
    ├── led_widget.dart
    └── control_panel_widget.dart

test/
├── unit/
│   └── domain_classes_test.dart
├── iot_controller_test.dart
├── mock_sensor.dart
└── widget/
    ├── led_widget_test.dart
    └── control_panel_widget_test.dart
```

## Cómo Ejecutar los Tests

Para ejecutar todos los tests:

```bash
flutter test
```

Para ejecutar tests con cobertura de código:

```bash
flutter test --coverage
```

Para ejecutar un archivo de test específico:

```bash
flutter test test/unit/domain_classes_test.dart
```

## Convenciones de Testing

- Todos los tests siguen el patrón AAA (Arrange-Act-Assert)
- Uso de setUp() para inicialización independiente de cada test
- Descripción de tests en formato: "should [expected behavior] when [condition]"
- Tests asíncronos para operaciones con sensores simulados
- Verificación de casos límite (edge cases) en todas las clases

## Última Actualización

Implementación completa de la pirámide de pruebas:
- 6 clases de dominio con lógica de negocio
- 9 pruebas unitarias cubriendo casos normales y límite
- Sistema de mocking con 4 interfaces de sensores
- 5 pruebas de mocking con simulación de éxito, fallos, latencia y timeouts
- 2 widgets de interfaz de usuario
- 5 pruebas de widgets para renderizado e interacción

Todos los tests pasan exitosamente y el proyecto cumple con los requisitos de calidad establecidos.
