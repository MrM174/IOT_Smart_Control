import 'package:flutter/material.dart';

class LEDWidget extends StatelessWidget {
  const LEDWidget({super.key, required this.isOn});

  final bool isOn;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.lightbulb,
      color: isOn ? Colors.green : Colors.grey,
      size: 48,
      semanticLabel: isOn ? 'LED encendido' : 'LED apagado',
    );
  }
}

