// lib/screens/led_control_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import 'dart:math' as math;

class LedControlPage extends StatefulWidget {
  const LedControlPage({super.key});
  
  @override
  _LedControlPageState createState() => _LedControlPageState();
}

class _LedControlPageState extends State<LedControlPage> with TickerProviderStateMixin {
  bool _led1State = false;
  bool _led2State = false;
  late AnimationController _led1Controller;
  late AnimationController _led2Controller;

  @override
  void initState() {
    super.initState();
    _led1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _led2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _led1Controller.dispose();
    _led2Controller.dispose();
    super.dispose();
  }

  void _toggleLED(int ledNumber, bool newValue) {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    setState(() {
      if (ledNumber == 1) {
        _led1State = newValue;
        if (newValue) {
          _led1Controller.repeat(reverse: true);
        } else {
          _led1Controller.stop();
          _led1Controller.reset();
        }
      } else {
        _led2State = newValue;
        if (newValue) {
          _led2Controller.repeat(reverse: true);
        } else {
          _led2Controller.stop();
          _led2Controller.reset();
        }
      }
    });
    bluetoothService.controlLED(ledNumber, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Control de LEDs', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0F1E),
              const Color(0xFF1A1A2E),
              const Color(0xFFF093FB).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Control de Iluminación',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Gestiona tus dispositivos LED',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildLEDCard(
                      ledNumber: 1,
                      ledState: _led1State,
                      controller: _led1Controller,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                      ),
                      onToggle: _toggleLED,
                    ),
                    const SizedBox(height: 20),
                    _buildLEDCard(
                      ledNumber: 2,
                      ledState: _led2State,
                      controller: _led2Controller,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      onToggle: _toggleLED,
                    ),
                    const SizedBox(height: 32),
                    _buildQuickActionsCard(),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3E).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Consumer<BluetoothService>(
                  builder: (context, service, child) => Row(
                    children: [
                      Icon(
                        service.isConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                        color: service.isConnected ? const Color(0xFF4ECDC4) : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          service.statusMessage,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLEDCard({
    required int ledNumber,
    required bool ledState,
    required AnimationController controller,
    required Gradient gradient,
    required Function(int, bool) onToggle,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: ledState ? gradient : null,
        color: ledState ? null : const Color(0xFF2A2A3E).withOpacity(0.4),
        border: Border.all(
          color: ledState ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          width: 2,
        ),
        boxShadow: ledState
            ? [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onToggle(ledNumber, !ledState),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ledState
                                ? Colors.white.withOpacity(0.2 + 0.1 * controller.value)
                                : Colors.grey.withOpacity(0.1),
                            boxShadow: ledState
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3 * controller.value),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            ledState ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                            color: ledState ? Colors.white : Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LED $ledNumber',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ledState ? Colors.white : Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ledState ? 'Encendido' : 'Apagado',
                            style: TextStyle(
                              fontSize: 14,
                              color: ledState ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 1.2,
                      child: Switch(
                        value: ledState,
                        onChanged: (value) => onToggle(ledNumber, value),
                        activeColor: Colors.white,
                        activeTrackColor: Colors.white.withOpacity(0.3),
                        inactiveThumbColor: Colors.grey[700],
                        inactiveTrackColor: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                if (ledState) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.power_rounded, color: Colors.white.withOpacity(0.9), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Activo',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.flash_on_rounded,
                  label: 'Todos ON',
                  onTap: () {
                    _toggleLED(1, true);
                    _toggleLED(2, true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.flash_off_rounded,
                  label: 'Todos OFF',
                  onTap: () {
                    _toggleLED(1, false);
                    _toggleLED(2, false);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}