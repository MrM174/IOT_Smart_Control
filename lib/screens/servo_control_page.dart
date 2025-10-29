// lib/screens/servo_control_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import 'dart:math' as math;

class ServoControlPage extends StatefulWidget {
  const ServoControlPage({super.key});
  
  @override
  _ServoControlPageState createState() => _ServoControlPageState();
}

class _ServoControlPageState extends State<ServoControlPage> with SingleTickerProviderStateMixin {
  double _currentAngle = 90.0;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rotationAnimation = Tween<double>(begin: 90, end: 90).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _updateAngle(double angle) {
    setState(() {
      _currentAngle = angle;
    });
    _rotationAnimation = Tween<double>(
      begin: _rotationAnimation.value,
      end: angle,
    ).animate(CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut));
    _rotationController.forward(from: 0);
  }

  void _setPresetAngle(double angle) {
    _updateAngle(angle);
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    bluetoothService.setServoAngle(angle.round());
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Control de Servo', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0F1E),
              const Color(0xFF1A1A2E),
              const Color(0xFF667EEA).withOpacity(0.1),
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
                    Icon(Icons.settings_remote_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Control de Servomotor',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Ajusta el ángulo de rotación',
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
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Circular Indicator
                      _buildCircularIndicator(),
                      const SizedBox(height: 50),
                      // Slider Control
                      _buildSliderControl(bluetoothService),
                      const SizedBox(height: 30),
                      // Preset Buttons
                      _buildPresetButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
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

  Widget _buildCircularIndicator() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
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
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Angle arc background
          CustomPaint(
            size: const Size(280, 280),
            painter: _AngleArcPainter(_currentAngle),
          ),
          // Rotating indicator
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: ((_rotationAnimation.value - 90) * math.pi / 180),
                child: Container(
                  width: 140,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFF667EEA),
                        Color(0xFF764BA2),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Center circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A2E),
              border: Border.all(
                color: const Color(0xFF667EEA).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_currentAngle.round()}°',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Ángulo Actual',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF667EEA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderControl(BluetoothService bluetoothService) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ajuste Fino',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentAngle.round()}°',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('0°', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF667EEA),
                    inactiveTrackColor: Colors.grey[800],
                    thumbColor: const Color(0xFF764BA2),
                    overlayColor: const Color(0xFF667EEA).withOpacity(0.3),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                  ),
                  child: Slider(
                    value: _currentAngle,
                    min: 0,
                    max: 180,
                    divisions: 180,
                    label: '${_currentAngle.round()}°',
                    onChanged: (double value) {
                      _updateAngle(value);
                    },
                    onChangeEnd: (double value) {
                      bluetoothService.setServoAngle(value.round());
                    },
                  ),
                ),
              ),
              const Text('180°', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons() {
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
              Icon(Icons.bookmark_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Posiciones Predefinidas',
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
                child: _buildPresetButton(
                  label: '0°',
                  angle: 0,
                  icon: Icons.first_page_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPresetButton(
                  label: '45°',
                  angle: 45,
                  icon: Icons.rotate_left_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPresetButton(
                  label: '90°',
                  angle: 90,
                  icon: Icons.swap_horiz_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPresetButton(
                  label: '135°',
                  angle: 135,
                  icon: Icons.rotate_right_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPresetButton(
                  label: '180°',
                  angle: 180,
                  icon: Icons.last_page_rounded,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton({
    required String label,
    required double angle,
    required IconData icon,
  }) {
    final isActive = (_currentAngle - angle).abs() < 1;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _setPresetAngle(angle),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  )
                : null,
            color: isActive ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? const Color(0xFF667EEA) : Colors.white.withOpacity(0.1),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[400],
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[400],
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AngleArcPainter extends CustomPainter {
  final double angle;

  _AngleArcPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Gradient arc for current angle
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (angle / 180) * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      sweepAngle,
      false,
      gradientPaint,
    );

    // Angle markers
    for (int i = 0; i <= 180; i += 30) {
      final markerAngle = -math.pi + (i / 180 * math.pi);
      final markerStart = Offset(
        center.dx + (radius - 5) * math.cos(markerAngle),
        center.dy + (radius - 5) * math.sin(markerAngle),
      );
      final markerEnd = Offset(
        center.dx + (radius + 5) * math.cos(markerAngle),
        center.dy + (radius + 5) * math.sin(markerAngle),
      );

      final markerPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(markerStart, markerEnd, markerPaint);
    }
  }

  @override
  bool shouldRepaint(_AngleArcPainter oldDelegate) => oldDelegate.angle != angle;
} 