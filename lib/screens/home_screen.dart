// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'sensor_display_page.dart';
import 'air_quality_page.dart';
import 'led_control_page.dart';
import 'servo_control_page.dart';
import 'profiles_page.dart';
import '../providers/settings_provider.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBluetoothStateAndGetDevices());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkBluetoothStateAndGetDevices() {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    bluetoothService.addListener(() {
      if (mounted && bluetoothService.bluetoothState.isEnabled && _devices.isEmpty) {
        _getPairedDevices();
      }
    });
    if (bluetoothService.bluetoothState.isEnabled) {
      _getPairedDevices();
    }
  }

  Future<void> _getPairedDevices() async {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    List<BluetoothDevice> devices = await bluetoothService.getPairedDevices();
    if (!mounted) return;
    setState(() {
      _devices = devices;
      if (_selectedDevice != null && !_devices.any((d) => d.address == _selectedDevice!.address)) {
        _selectedDevice = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.router, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('IoT Smart Control', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilesPage()),
              );
            },
            tooltip: 'Perfiles',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _getPairedDevices,
            tooltip: 'Refresh Devices',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0F1E),
              const Color(0xFF1A1A2E),
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<BluetoothService>(
        builder: (context, service, child) {
          if (!service.bluetoothState.isEnabled) {
            return _buildBluetoothOffUI(context);
          }
          return _buildControlPanel(context, service);
        },
          ),
        ),
      ),
    );
  }

  Widget _buildBluetoothOffUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.bluetooth_disabled_rounded, size: 80.0, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Text(
              'Bluetooth Desactivado',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Por favor, activa el Bluetooth para conectarte a tus dispositivos IoT.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context, BluetoothService service) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
      child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConnectionCard(context, service),
                const SizedBox(height: 16),
                _buildProfileSelector(context),
                const SizedBox(height: 24),
                Text(
                  'Control Panel',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Administra tus dispositivos inteligentes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildListDelegate([
              _buildFeatureCard(
                context,
                icon: Icons.thermostat_rounded,
                title: 'Ambiente',
                subtitle: 'Temp & Humedad',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                isEnabled: service.isConnected,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SensorDisplayPage())),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.air_rounded,
                title: 'Aire',
                subtitle: 'Calidad',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                isEnabled: service.isConnected,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AirQualityPage())),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.lightbulb_rounded,
                title: 'LEDs',
                subtitle: 'Control',
                gradient: const LinearGradient(
                  colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                ),
                isEnabled: service.isConnected,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LedControlPage())),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.settings_remote_rounded,
                title: 'Servo',
                subtitle: 'Control',
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                isEnabled: service.isConnected,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServoControlPage())),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionCard(BuildContext context, BluetoothService service) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: service.isConnected
              ? [const Color(0xFF00D9FF).withOpacity(0.3), const Color(0xFF03DAC6).withOpacity(0.3)]
              : [const Color(0xFF2A2A3E), const Color(0xFF1A1A2E)],
        ),
        border: Border.all(
          color: service.isConnected ? const Color(0xFF00D9FF) : const Color(0xFF2A2A3E),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: service.isConnected ? const Color(0xFF00D9FF).withOpacity(0.3) : Colors.black26,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: service.isConnected ? const Color(0xFF00D9FF).withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                      boxShadow: service.isConnected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00D9FF).withOpacity(0.5 * _animationController.value),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      service.isConnected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_rounded,
                      color: service.isConnected ? const Color(0xFF00D9FF) : Colors.grey,
                      size: 28,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
        child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.isConnected ? 'Conectado' : 'Desconectado',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.statusMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
            const SizedBox(height: 20),
            DropdownButtonFormField<BluetoothDevice>(
            decoration: InputDecoration(
              labelText: 'Dispositivo',
              prefixIcon: const Icon(Icons.devices_rounded),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
              value: _selectedDevice,
              onChanged: (device) => setState(() => _selectedDevice = device),
            items: _devices.map((device) {
              return DropdownMenuItem(
                value: device,
                child: Text(device.name ?? device.address),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selectedDevice == null || service.isConnected ? null : () => service.connect(_selectedDevice!),
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Conectar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9FF),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[800],
                    disabledForegroundColor: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: service.isConnected ? () => service.disconnect() : null,
                  icon: const Icon(Icons.link_off_rounded),
                  label: const Text('Desconectar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[800],
                    disabledForegroundColor: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: gradient,
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  if (!isEnabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.lock_outline, size: 16, color: Colors.white.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          'Desconectado',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSelector(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final activeProfile = settings.activeProfile;
        final profiles = settings.profiles;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2A2A3E).withOpacity(0.6),
                const Color(0xFF1A1A2E).withOpacity(0.6),
              ],
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.speed_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perfil Activo',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButton<String>(
                      value: activeProfile.id,
                      isExpanded: true,
                      underline: Container(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      dropdownColor: const Color(0xFF2A2A3E),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      items: profiles.map((profile) {
                        return DropdownMenuItem<String>(
                          value: profile.id,
                          child: Row(
                            children: [
                              if (profile.id == activeProfile.id)
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              if (profile.id == activeProfile.id)
                                const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  profile.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${profile.temperatureInterval}s/${profile.airQualityInterval}s',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newProfileId) {
                        if (newProfileId != null) {
                          settings.setActiveProfile(newProfileId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Perfil cambiado a: ${profiles.firstWhere((p) => p.id == newProfileId).name}',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}