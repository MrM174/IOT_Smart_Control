// lib/screens/air_quality_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../providers/settings_provider.dart';
import '../helpers/database_helper.dart';
import '../widgets/semi_circle_gauge.dart';
import 'history_detail_page.dart';
import 'dart:async';

class AirQualityPage extends StatefulWidget {
  const AirQualityPage({super.key});
  @override
  State<AirQualityPage> createState() => _AirQualityPageState();
}

class _AirQualityPageState extends State<AirQualityPage> with SingleTickerProviderStateMixin {
  Timer? _timer;
  StreamSubscription<void>? _dataSubscription;
  List<Map<String, dynamic>> _readings = [];
  double _lastValue = 0.0;
  bool _isLoading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    _refreshReadings();
    _dataSubscription = bluetoothService.onNewData.listen((_) {
      print("New data received, refreshing Air Quality page.");
      _refreshReadings();
    });

    _startTimer(settingsProvider.airQualityInterval);
    
    // Escuchar cambios en el intervalo
    settingsProvider.addListener(() {
      _restartTimer(settingsProvider.airQualityInterval);
    });
  }
  
  void _startTimer(int seconds) {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    _timer = Timer.periodic(Duration(seconds: seconds), (Timer t) {
      if (mounted && bluetoothService.isConnected) {
        print("Auto-requesting Air Quality data...");
        bluetoothService.requestAirQualityData();
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
    final data = await DatabaseHelper.instance.getAirQualityReadings();
    if (mounted) {
      setState(() {
        _readings = data;
        if (_readings.isNotEmpty) {
          _lastValue = _readings.first['airQuality'] ?? 0.0;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _requestDataAndRefresh() async {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    await bluetoothService.requestAirQualityData();
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

  String _getQualityLevel(double value) {
    if (value < 800) return 'Excelente';
    if (value < 1500) return 'Bueno';
    if (value < 2500) return 'Moderado';
    if (value < 3500) return 'Malo';
    return 'Muy Malo';
  }

  Color _getQualityColor(double value) {
    if (value < 800) return const Color(0xFF4ECDC4);
    if (value < 1500) return const Color(0xFF44A08D);
    if (value < 2500) return const Color(0xFFFFC837);
    if (value < 3500) return const Color(0xFFFF8E53);
    return const Color(0xFFFF5252);
  }

  IconData _getQualityIcon(double value) {
    if (value < 800) return Icons.sentiment_very_satisfied_rounded;
    if (value < 1500) return Icons.sentiment_satisfied_rounded;
    if (value < 2500) return Icons.sentiment_neutral_rounded;
    if (value < 3500) return Icons.sentiment_dissatisfied_rounded;
    return Icons.sentiment_very_dissatisfied_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Calidad del Aire', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            onPressed: _showIntervalSettings,
            tooltip: 'Configurar intervalo (${settingsProvider.airQualityInterval}s)',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _requestDataAndRefresh,
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
              _getQualityColor(_lastValue).withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Main Gauge Section
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
                    color: _getQualityColor(_lastValue).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getQualityColor(_lastValue).withOpacity(0.2),
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
                                color: _getQualityColor(_lastValue).withOpacity(0.2 + 0.1 * _pulseController.value),
                              ),
                              child: Icon(Icons.air_rounded, color: _getQualityColor(_lastValue), size: 24),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Monitor de Aire',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SemiCircleGauge(
                      title: 'Calidad del Aire',
              value: _lastValue,
              unit: '',
              minimum: 0,
              maximum: 4095,
                      gaugeColor: _getQualityColor(_lastValue),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getQualityColor(_lastValue).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getQualityColor(_lastValue).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getQualityIcon(_lastValue),
                            color: _getQualityColor(_lastValue),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getQualityLevel(_lastValue),
                                style: TextStyle(
                                  color: _getQualityColor(_lastValue),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Nivel: ${_lastValue.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: _getQualityColor(_lastValue).withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                      builder: (context) => const HistoryDetailPage(type: 'airquality'),
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
                              final airValue = (reading['airQuality'] ?? 0.0) as double;
                              
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
                                    color: _getQualityColor(airValue).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _getQualityColor(airValue).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.air_rounded, color: _getQualityColor(airValue)),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _getQualityLevel(airValue),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: _getQualityColor(airValue),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getQualityColor(airValue).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          airValue.toStringAsFixed(0),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: _getQualityColor(airValue),
                                          ),
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