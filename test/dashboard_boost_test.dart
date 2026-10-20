import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sb_control/app/controller.dart';
import 'package:sb_control/app/preferences.dart';
import 'package:sb_control/bluetooth/demo_transport.dart';
import 'package:sb_control/ui/app.dart';

void main() {
  testWidgets('dashboard edits device boost without starting heat', (
    tester,
  ) async {
    final c = AppController(
      preferences: MemoryPreferences(),
      nativeFactory: DemoTransport.new,
    );
    await c.initialize();
    var done = false;
    final connection = c
        .connect(DemoTransport.devices.first)
        .whenComplete(() => done = true);
    while (!done) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await connection;
    await tester.pumpWidget(SbControlApp(controller: c));
    await tester.pumpAndSettle();
    final boost = find.byWidgetPredicate(
      (w) => w is SettingSlider && w.label == 'Boost-Offset',
    );
    final superboost = find.byWidgetPredicate(
      (w) => w is SettingSlider && w.label == 'Superboost-Offset',
    );
    expect(boost, findsOneWidget);
    expect(superboost, findsOneWidget);
    final before = c.data['boost'];
    await tester.ensureVisible(boost);
    await tester.drag(
      find.descendant(of: boost, matching: find.byType(Slider)),
      const Offset(35, 0),
    );
    for (var n = 0; n < 100; n++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(c.data['boost'], isNot(before));
    expect(c.data['heater'], false);
    expect(c.error, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(c.shutdown);
    c.dispose();
  });
}
