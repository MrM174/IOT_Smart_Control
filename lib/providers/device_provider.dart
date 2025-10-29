// lib/providers/device_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../models/smart_device.dart';
import '../services/bluetooth_service.dart';

class DeviceProvider extends ChangeNotifier {
  final BluetoothService _bluetoothService;
  List<SmartDevice> _devices = [];

  // This provider now listens to the service for changes.
  DeviceProvider(this._bluetoothService) {
    _initializeDevices();
    _bluetoothService.addListener(_onServiceUpdate);
  }

  // Getters now proxy the state directly from the BluetoothService.
  List<SmartDevice> get devices => List.unmodifiable(_devices);
  bool get isConnected => _bluetoothService.isConnected;
  String get statusMessage => _bluetoothService.statusMessage;

  void _initializeDevices() {
    _devices = [
      SmartDevice(id: 'led1', name: 'Main LED', type: DeviceType.led),
      // You can add more predefined devices here
    ];
  }

  // This method is called whenever BluetoothService calls notifyListeners().
  void _onServiceUpdate() {
    notifyListeners(); // This notifies the UI to rebuild.
  }

  // --- Actions ---

  // The connect method now delegates directly to the service.
  Future<void> connect(BluetoothDevice device) async {
    await _bluetoothService.connect(device);
  }

  // The disconnect method delegates directly to the service.
  Future<void> disconnect() async {
    _bluetoothService.disconnect();
  }

  // Updated to use the structured JSON command from the service.
  Future<void> toggleLed(String id) async {
    final device = _devices.firstWhere((d) => d.id == id);
    device.isOn = !device.isOn;
    // We assume the ledId is 1 for the 'Main LED'
    await _bluetoothService.controlLED(1, device.isOn);
    // The status message will be updated automatically by the service.
    notifyListeners();
  }

  // Now correctly calls the method defined in the service.
  Future<List<BluetoothDevice>> scanForDevices() async {
    return await _bluetoothService.getPairedDevices();
  }

  @override
  void dispose() {
    // Important: remove the listener to avoid memory leaks.
    _bluetoothService.removeListener(_onServiceUpdate);
    super.dispose();
  }
}