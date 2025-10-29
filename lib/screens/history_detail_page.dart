// lib/screens/history_detail_page.dart
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class HistoryDetailPage extends StatefulWidget {
  final String type; // 'temperature' o 'airquality'
  
  const HistoryDetailPage({super.key, required this.type});
  
  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  List<Map<String, dynamic>> _readings = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }
  
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    final data = widget.type == 'temperature'
        ? await DatabaseHelper.instance.getTempHumReadings()
        : await DatabaseHelper.instance.getAirQualityReadings();
    
    if (mounted) {
      setState(() {
        _readings = data;
        _isLoading = false;
      });
    }
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
    } else if (difference.inDays == 1) {
      return 'Ayer a las ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
  
  Color _getQualityColor(double value) {
    if (value < 800) return const Color(0xFF4ECDC4);
    if (value < 1500) return const Color(0xFF44A08D);
    if (value < 2500) return const Color(0xFFFFC837);
    if (value < 3500) return const Color(0xFFFF8E53);
    return const Color(0xFFFF5252);
  }
  
  String _getQualityLevel(double value) {
    if (value < 800) return 'Excelente';
    if (value < 1500) return 'Bueno';
    if (value < 2500) return 'Moderado';
    if (value < 3500) return 'Malo';
    return 'Muy Malo';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.type == 'temperature' ? 'Historial de Ambiente' : 'Historial de Calidad del Aire',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadHistory,
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
              // Header con estadísticas
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2A2A3E).withOpacity(0.6),
                      const Color(0xFF1A1A2E).withOpacity(0.6),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.inventory_2_rounded,
                      label: 'Total',
                      value: '${_readings.length}',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildStatItem(
                      icon: Icons.access_time_rounded,
                      label: 'Último',
                      value: _readings.isEmpty ? '-' : _formatTimestamp(DateTime.parse(_readings.first['timestamp'])).split(' ').first,
                      color: const Color(0xFF4ECDC4),
                    ),
                  ],
                ),
              ),
              
              // Lista de registros
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _readings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_rounded, size: 100, color: Colors.grey[700]),
                                const SizedBox(height: 20),
                                Text(
                                  'No hay registros',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 18),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: _readings.length,
                            itemBuilder: (context, index) {
                              final reading = _readings[index];
                              final timestamp = DateTime.parse(reading['timestamp']);
                              
                              if (widget.type == 'temperature') {
                                return _buildTempHumCard(reading, timestamp);
                              } else {
                                return _buildAirQualityCard(reading, timestamp);
                              }
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTempHumCard(Map<String, dynamic> reading, DateTime timestamp) {
    final temp = reading['temperature']?.toStringAsFixed(1) ?? '0.0';
    final hum = reading['humidity']?.toStringAsFixed(1) ?? '0.0';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.thermostat_auto_rounded, color: Color(0xFFFF6B6B), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timestamp.toString().substring(0, 19),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDataBox(
                    icon: Icons.device_thermostat,
                    label: 'Temperatura',
                    value: temp,
                    unit: '°C',
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDataBox(
                    icon: Icons.water_drop_rounded,
                    label: 'Humedad',
                    value: hum,
                    unit: '%',
                    color: const Color(0xFF4ECDC4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAirQualityCard(Map<String, dynamic> reading, DateTime timestamp) {
    final airValue = (reading['airQuality'] ?? 0.0) as double;
    final color = _getQualityColor(airValue);
    final level = _getQualityLevel(airValue);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A2A3E).withOpacity(0.4),
            const Color(0xFF1A1A2E).withOpacity(0.4),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.air_rounded, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timestamp.toString().substring(0, 19),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nivel de Calidad',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level,
                      style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.5), width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Valor',
                        style: TextStyle(
                          color: color.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        airValue.toStringAsFixed(0),
                        style: TextStyle(
                          color: color,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDataBox({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


