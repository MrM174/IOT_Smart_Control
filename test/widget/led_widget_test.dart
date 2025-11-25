import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_device_tester/widgets/led_widget.dart';

void main() {
  testWidgets('should render green icon when LEDWidget is on', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LEDWidget(isOn: true),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, Colors.green);
  });

  testWidgets('should render grey icon when LEDWidget is off', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LEDWidget(isOn: false),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, Colors.grey);
  });
}

