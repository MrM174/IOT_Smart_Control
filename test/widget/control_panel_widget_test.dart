import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_device_tester/widgets/control_panel_widget.dart';

void main() {
  testWidgets('should show zero when ControlPanelWidget initializes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ControlPanelWidget(),
      ),
    );

    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('should increment to one when button is tapped once', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ControlPanelWidget(),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('should increment to five when button is tapped five times', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ControlPanelWidget(),
      ),
    );

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byType(FloatingActionButton));
    }
    await tester.pumpAndSettle();

    expect(find.text('5'), findsOneWidget);
  });
}

