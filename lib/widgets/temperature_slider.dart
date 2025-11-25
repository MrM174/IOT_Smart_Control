import 'package:flutter/material.dart';
import 'package:smart_device_tester/thermostat.dart';

class TemperatureSlider extends StatefulWidget {
  const TemperatureSlider({
    super.key,
    required this.thermostat,
    this.onTemperatureChanged,
  });

  final Thermostat thermostat;
  final ValueChanged<double>? onTemperatureChanged;

  @override
  State<TemperatureSlider> createState() => _TemperatureSliderState();
}

class _TemperatureSliderState extends State<TemperatureSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.thermostat.targetTemperature;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Temperatura: ${_currentValue.toStringAsFixed(1)}°C',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        Slider(
          value: _currentValue,
          min: Thermostat.minTemperature,
          max: Thermostat.maxTemperature,
          divisions: 30,
          label: '${_currentValue.toStringAsFixed(1)}°C',
          onChanged: (double value) {
            setState(() {
              _currentValue = value;
              widget.thermostat.setTargetTemperature(value);
              widget.onTemperatureChanged?.call(value);
            });
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.thermostat.isHeating
                  ? Icons.thermostat
                  : widget.thermostat.isCooling
                      ? Icons.ac_unit
                      : Icons.check_circle,
              color: widget.thermostat.isHeating
                  ? Colors.red
                  : widget.thermostat.isCooling
                      ? Colors.blue
                      : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              widget.thermostat.isHeating
                  ? 'Calentando'
                  : widget.thermostat.isCooling
                      ? 'Enfriando'
                      : 'Estable',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }
}
