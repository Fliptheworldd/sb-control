import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sb_control/app/controller.dart';
import 'package:sb_control/app/preferences.dart';
import 'package:sb_control/ui/app.dart';
import 'package:sb_control/bluetooth/demo_transport.dart';

void main() {
  testWidgets('all connected layouts fit at 320px, including Fahrenheit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Future<void> complete(Future<void> Function() action) async {
      var done = false;
      final pending = action().whenComplete(() => done = true);
      for (var n = 0; !done && n < 200; n++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(done, true, reason: 'simulated BLE operation timed out');
      await pending;
    }

    for (final device in DemoTransport.devices) {
      final c = AppController(
        preferences: MemoryPreferences(),
        nativeFactory: DemoTransport.new,
      );
      await c.initialize();
      await complete(() => c.connect(device));
      expect(c.connected, true, reason: c.error);
      await c.setFahrenheit(true);
      await tester.pumpWidget(SbControlApp(controller: c));
      for (final tab in [
        'Übersicht',
        'Optionen',
        'Diagnose',
        'Geräte',
        'Pflege',
      ]) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${device.name}: $tab');
        await tester.drag(find.byType(ListView).first, const Offset(0, -900));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${device.name}: $tab scrolled',
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
      // StreamSubscription.cancel may complete on the real event loop.
      await tester.runAsync(c.shutdown);
      c.dispose();
    }
  });
  testWidgets('native entry screen and navigation remain usable at 390px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = AppController(preferences: MemoryPreferences());
    await c.initialize();
    await tester.pumpWidget(SbControlApp(controller: c));
    expect(find.text('Alles unter Kontrolle.'), findsOneWidget);
    await tester.tap(find.text('Geräte').last);
    await tester.pumpAndSettle();
    expect(find.text('Nach Geräten suchen'), findsOneWidget);
    await tester.tap(find.text('Optionen').last);
    await tester.pumpAndSettle();
    expect(find.text('Temperatureinheit'), findsOneWidget);
    await tester.tap(find.text('°F'));
    await tester.pumpAndSettle();
    expect(c.fahrenheit, true);
    await tester.tap(find.text('Diagnose').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Diagnosebericht kopieren'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Diagnosebericht kopieren'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    c.dispose();
  });
}
