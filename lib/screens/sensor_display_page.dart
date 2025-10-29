// lib/screens/sensor_display_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../providers/settings_provider.dart';
import '../helpers/database_helper.dart';
import '../widgets/semi_circle_gauge.dart';
import 'history_detail_page.dart';
import 'dart:async';

class SensorDisplayPage extends StatefulWidget {
  const SensorDisplayPage({super.key});
  @override
  State<SensorDisplayPage> createState() => _SensorDisplayPageState();
}

class _SensorDisplayPageState extends State<SensorDisplayPage> with SingleTickerProviderStateMixin {
  Timer? _timer;
  StreamSubscription<void>? _dataSubscription;
  List<Map<String, dynamic>> _readings = [];
  double _lastTemp = 0.0;
  double _lastHum = 0.0;
  bool _isLoading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    _refreshReadings();
    _dataSubscription = bluetoothService.onNewData.listen((_) {
      print("New data received, refreshing Temp/Hum page.");
      _refreshReadings();
    });

    _startTimer(settingsProvider.temperatureInterval);
    
    // Escuchar cambios en el intervalo
    settingsProvider.addListener(() {
      _restartTimer(settingsProvider.temperatureInterval);
    });
  }
  
  void _startTimer(int seconds) {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    _timer = Timer.periodic(Duration(seconds: seconds), (Timer t) {
      if (mounted && bluetoothService.isConnected) {
        print("Auto-requesting Temp/Hum data...");
        bluetoothService.requestSensorData();
      }
    });
  }
  
  void _restartTimer(int seconds) {
    _timer?.cancel();
    _startTimer(seconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dataSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _refreshReadings() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getTempHumReadings();
    if (mounted) {
      setState(() {
        _readings = data;
        if (_readings.isNotEmpty) {
          _lastTemp = _readings.first['temperature'] ?? 0.0;
          _lastHum = _readings.first['humidity'] ?? 0.0;
        }
        _isLoading = false;
      });
    }
  }

  void _showIntervalSettings() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    int tempInterval = settingsProvider.updateInterval;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Intervalo de Actualización'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cada $tempInterval segundos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Slider(
                value: tempInterval.toDouble(),
                min: 1,
                max: 60,
                divisions: 59,
                label: '$tempInterval seg',
                onChanged: (value) {
                  setState(() {
                    tempInterval = value.round();
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1 seg', style: TextStyle(color: Colors.grey[600])),
                  Text('60 seg', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<SettingsProvider>(context, listen: false).setUpdateInterval(tempInterval);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Intervalo actualizado a $tempInterval segundos'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Monitor Ambiental', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            onPressed: _showIntervalSettings,
            tooltip: 'Configurar intervalo (${settingsProvider.temperatureInterval}s)',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => bluetoothService.requestSensorData(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F0F1E),
              const Color(0xFF1A1A2E),
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Gauges Section
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2A2A3E).withOpacity(0.6),
                      const Color(0xFF1A1A2E).withOpacity(0.6),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFF6B6B).withOpacity(0.2 + 0.1 * _pulseController.value),
                              ),
                              child: const Icon(Icons.sensors_rounded, color: Color(0xFFFF6B6B), size: 24),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Lecturas en Vivo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SemiCircleGauge(
                            title: 'Temperatura',
                            value: _lastTemp,
                            unit: '°C',
                            minimum: 0,
                            maximum: 50,
                            gaugeColor: const Color(0xFFFF6B6B),
                          ),
                        ),
                        Expanded(
                          child: SemiCircleGauge(
                            title: 'Humedad',
                            value: _lastHum,
                            unit: '%',
                            minimum: 0,
                            maximum: 100,
                            gaugeColor: const Color(0xFF4ECDC4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // History Section Header
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryDetailPage(type: 'temperature'),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Historial',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.open_in_full_rounded, size: 16, color: Colors.grey),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${_readings.length} registros',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // History List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _readings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[700]),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay historial',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                                ),
                              ],
                            ),
                          )
                    : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _readings.length,
                        itemBuilder: (context, index) {
                          final reading = _readings[index];
                          final timestamp = DateTime.parse(reading['timestamp']);
                              final temp = reading['temperature']?.toStringAsFixed(1) ?? '0.0';
                              final hum = reading['humidity']?.toStringAsFixed(1) ?? '0.0';
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF2A2A3E).withOpacity(0.4),
                                      const Color(0xFF1A1A2E).withOpacity(0.4),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.05),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.thermostat_auto_rounded, color: Color(0xFFFF6B6B)),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.device_thermostat, size: 16, color: Color(0xFFFF6B6B)),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$temp°C',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.water_drop_rounded, size: 16, color: Color(0xFF4ECDC4)),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$hum%',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _formatTimestamp(timestamp),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                          );
                        },
                      ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}