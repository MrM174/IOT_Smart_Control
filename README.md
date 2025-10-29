# 🏠 IoT Smart Control

Aplicación móvil Flutter para control de dispositivos IoT vía Bluetooth con ESP32.

## ✨ Características

### 📱 Interfaz Moderna
- Diseño profesional con Material Design 3
- Tema oscuro con gradientes personalizados
- Animaciones suaves y feedback visual

### 🎛️ Control de Dispositivos
- **Monitor Ambiental**: Temperatura y humedad en tiempo real
- **Calidad del Aire**: Sensor MQ-135 con clasificación por niveles
- **Control de LEDs**: 2 LEDs con switches animados
- **Servomotor**: Control de ángulo 0-180° con indicador circular

### 📊 Sistema de Perfiles
- Crear perfiles personalizados ilimitados
- Configurar intervalos de actualización independientes por sensor
- Cambio rápido entre perfiles
- Presets predefinidos (Rápido, Normal, Ahorro)

### 📈 Historial
- Almacenamiento local con SQLite
- Vista completa expandible
- Estadísticas y formato de tiempo relativo
- Filtrado por tipo de sensor

## 🔧 Tecnologías

- **Framework**: Flutter 3.x
- **Lenguaje**: Dart
- **Comunicación**: Bluetooth Serial (flutter_bluetooth_serial)
- **Base de Datos**: SQLite (sqflite)
- **State Management**: Provider
- **Gráficos**: Syncfusion Flutter Gauges
- **Persistencia**: SharedPreferences

## 📋 Requisitos

- Flutter SDK >= 3.4.1
- Android SDK 34+
- Dispositivo Android con Bluetooth

## 🚀 Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/tu-usuario/IOT_Smart_Control.git
cd IOT_Smart_Control
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Compilar APK:
```bash
flutter build apk --release
```

## 📦 Hardware Requerido

- ESP32 (38 pines)
- Sensor DHT11/DHT22 (Temperatura y Humedad)
- Sensor MQ-135 (Calidad del Aire)
- 2x LEDs
- Servomotor SG90
- LCD 16x2 I2C (opcional)
- Fuente de alimentación 5V para servo

## 🔌 Conexiones ESP32

| Componente | GPIO | Pin |
|------------|------|-----|
| LED Principal | GPIO2 | 24 |
| LED Secundario | GPIO4 | 26 |
| DHT11/22 | GPIO5 | 29 |
| Servomotor | GPIO13 | 15 |
| MQ-135 | GPIO34 | 5 |
| LCD SDA | GPIO21 | 33 |
| LCD SCL | GPIO22 | 36 |

## 📱 Capturas


## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

## 👨‍💻 Autor

Desarrollado con ❤️ para el control de dispositivos IoT

---

**Nota**: Recuerda alimentar el servomotor con una fuente externa de 5V para un funcionamiento correcto.
