// lib/bluetooth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../helpers/database_helper.dart';

class BluetoothService extends ChangeNotifier {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  StreamSubscription<BluetoothState>? _stateSubscription;
  BluetoothConnection? connection;
  bool get isConnected => connection != null && connection!.isConnected;
  String _statusMessage = 'Disconnected';

  final StreamController<void> _newDataController = StreamController<void>.broadcast();
  Stream<void> get onNewData => _newDataController.stream;

  String get statusMessage => _statusMessage;
  BluetoothState get bluetoothState => _bluetoothState;

  String _buffer = '';

  BluetoothService() {
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
      notifyListeners();
    });
    _stateSubscription = FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      _bluetoothState = state;
      notifyListeners();
    });
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print("Error getting paired devices: $e");
      return []; 
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    if (isConnected) await disconnect();
    try {
      _statusMessage = 'Connecting...';
      notifyListeners();
      connection = await BluetoothConnection.toAddress(device.address);
      _statusMessage = 'Connected to ${device.name}';
      notifyListeners();
      _listenToBluetoothData();
    } catch (e) {
      _statusMessage = 'Error connecting: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await connection?.close();
    connection = null;
    _buffer = ''; // Limpia el buffer al desconectar
    _statusMessage = 'Disconnected';
    notifyListeners();
  }

  void _listenToBluetoothData() {
    connection?.input?.listen((Uint8List data) {
      _buffer += utf8.decode(data);
      while (_buffer.contains('\n')) {
        final messageIndex = _buffer.indexOf('\n');
        final message = _buffer.substring(0, messageIndex).trim();
        _buffer = _buffer.substring(messageIndex + 1);
        if (message.isEmpty) continue;
        try {
          final jsonData = json.decode(message);
          _processJsonData(jsonData);
        } catch (e) {
          print('Error parsing JSON: "$message" - Error: $e');
        }
      }
    }).onDone(() {
      _statusMessage = 'Disconnected by device';
      notifyListeners();
    });
  }

  void _processJsonData(Map<String, dynamic> jsonData) async {
    bool dataUpdated = false;
    if (jsonData['type'] == 'sensor') {
      await DatabaseHelper.instance.createReading(
        temperature: (jsonData['temperature'] as num).toDouble(),
        humidity: (jsonData['humidity'] as num).toDouble(),
        timestamp: DateTime.now().toIso8601String(),
      );
      _statusMessage = 'Temp/Hum data updated!';
      dataUpdated = true;
    } 
    else if (jsonData['type'] == 'air_quality') {
      await DatabaseHelper.instance.createReading(
        airQuality: (jsonData['value'] as num).toDouble(),
        timestamp: DateTime.now().toIso8601String(),
      );
      _statusMessage = 'Air Quality data updated!';
      dataUpdated = true;
    }
    
    // La notificación a la UI y a los listeners ahora está aquí.
    if (dataUpdated) {
      _newDataController.add(null);
      notifyListeners();
    }
  }
  
  Future<void> sendCommand(String command) async {
    print("Attempting to send command: $command");
    if (isConnected) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode("$command\r\n")));
        await connection!.output.allSent;
        print("Command sent successfully!");
      } catch (e) {
        _statusMessage = 'Error sending command: ${e.toString()}';
        print("!!! ERROR in sendCommand: ${e.toString()}");
        notifyListeners();
      }
    } else {
      _statusMessage = 'Cannot send command. No connection.';
      print("SendCommand failed: Not connected.");
      notifyListeners();
    }
  }

  Future<void> requestSensorData() async {
    final command = {'action': 'read_sensors'};
    await sendCommand(json.encode(command));
  }

  Future<void> requestAirQualityData() async {
    final command = {'action': 'read_air_quality'};
    await sendCommand(json.encode(command));
  }

  Future<void> controlLED(int ledId, bool isOn) async {
    final command = {'action': 'control_led', 'led_id': ledId, 'state': isOn ? 'on' : 'off'};
    await sendCommand(json.encode(command));
  }

  Future<void> setServoAngle(int angle) async {
    final command = {'action': 'angle', 'value': angle};
    await sendCommand(json.encode(command));
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _newDataController.close();
    disconnect();
    super.dispose();
  }
}