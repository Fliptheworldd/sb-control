import 'package:sb_control/core/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sb_control/app/controller.dart';
import 'package:sb_control/app/preferences.dart';
import 'package:sb_control/bluetooth/demo_transport.dart';
import 'package:sb_control/care/guides.dart';
import 'package:sb_control/l10n/strings.dart';
import 'package:sb_control/ui/app.dart';

void main() {
  testWidgets('Italian controls and all models fit a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final device in DemoTransport.devices) {
      final c = AppController(
        preferences: MemoryPreferences(),
        nativeFactory: DemoTransport.new,
      );
      await c.initialize();
      var done = false;
      final connecting = c.connect(device).whenComplete(() => done = true);
      for (var n = 0; !done && n < 200; n++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      await connecting;
      expect(c.connected, true, reason: c.error);
      await tester.pumpWidget(SbControlApp(controller: c));
      await tester.pumpAndSettle();
      expect(find.text('TEMPERATURA IMPOSTATA'), findsOneWidget);
      if (c.model.hasBattery) expect(find.text('Boost'), findsOneWidget);
      if (c.model.isQvap) expect(find.text('Superboost'), findsOneWidget);
      for (final tab in [
        'Controllo',
        'Opzioni',
        'Diagnostica',
        'Dispositivi',
        'Cura',
      ]) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${device.name}: $tab');
        await tester.drag(find.byType(ListView).first, const Offset(0, -800));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(c.shutdown);
      c.dispose();
    }
  }, skip: !L.italian);

  test('Italian guides preserve cleaning limits and model coverage', () {
    for (final model in careModels) {
      final guide = guideFor(model);
      expect(
        guide.steps.first.title,
        contains(model.hasBattery ? 'spegni' : 'Scollega'),
      );
      final text = guide.steps.map((s) => '${s.text} ${s.warning}').join(' ');
      expect(text, contains('30 minuti'));
      expect(text, contains('asciutto'));
      expect(guide.sources.every((s) => s.url.startsWith('https://')), true);
    }
  }, skip: !L.italian);
}
