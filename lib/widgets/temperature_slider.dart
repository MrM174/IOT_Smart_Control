import 'package:flutter/material.dart';
import '../thermostat.dart';
import '../sensor_interface.dart';

class TemperatureSlider extends StatefulWidget {
  const TemperatureSlider({
    super.key,
    required this.thermostat,
    this.sensor,
  });

  final Thermostat thermostat;
  final SensorInterface? sensor;

  @override
  State<TemperatureSlider> createState() => _TemperatureSliderState();
}

class _TemperatureSliderState extends State<TemperatureSlider> {
  double _sliderValue = 20.0;
  double? _currentReading;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.thermostat.targetTemperature;
    _loadCurrentTemperature();
  }

  Future<void> _loadCurrentTemperature() async {
    if (widget.sensor == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reading = await widget.thermostat.checkCurrentTemperature(
        widget.sensor!,
      );
      setState(() {
        _currentReading = reading;
        _isLoading = false;
        // Si el valor es 0.0, significa que hubo un error (valor seguro)
        if (reading == 0.0) {
          _errorMessage = 'Error al leer sensor';
        } else {
          _errorMessage = null;
        }
      });
    } catch (e) {
      setState(() {
        _currentReading = 0.0;
        _errorMessage = 'Error al leer sensor';
        _isLoading = false;
      });
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
    });
    widget.thermostat.setTargetTemperature(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Temperatura Objetivo: ${_sliderValue.toStringAsFixed(1)}°C',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Slider(
          value: _sliderValue,
          min: Thermostat.minTemperature,
          max: Thermostat.maxTemperature,
          divisions: 30,
          label: '${_sliderValue.toStringAsFixed(1)}°C',
          onChanged: _onSliderChanged,
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        if (_currentReading != null && !_isLoading)
          Text(
            'Temperatura Actual: ${_currentReading!.toStringAsFixed(1)}°C',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ElevatedButton(
          onPressed: _loadCurrentTemperature,
          child: const Text('Actualizar Temperatura'),
        ),
      ],
    );
  }
}

