// lib/widgets/semi_circle_gauge.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SemiCircleGauge extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final double minimum;
  final double maximum;
  final Color gaugeColor;

  const SemiCircleGauge({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.minimum,
    required this.maximum,
    required this.gaugeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: minimum,
              maximum: maximum,
              startAngle: 180,
              endAngle: 0,
              showLabels: true,
              showTicks: true,
              axisLineStyle: AxisLineStyle(
                thickness: 0.2,
                cornerStyle: CornerStyle.bothCurve,
                thicknessUnit: GaugeSizeUnit.factor,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              ),
              pointers: <GaugePointer>[
                RangePointer(
                  value: value,
                  width: 0.2,
                  sizeUnit: GaugeSizeUnit.factor,
                  cornerStyle: CornerStyle.bothCurve,
                  color: gaugeColor,
                ),
                MarkerPointer(
                  value: value,
                  markerType: MarkerType.invertedTriangle,
                  color: Colors.white,
                )
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    '${value.toStringAsFixed(1)} $unit',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.5,
                )
              ],
            )
          ],
        ),
      ],
    );
  }
}