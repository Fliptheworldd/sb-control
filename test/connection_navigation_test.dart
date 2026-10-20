import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sb_control/app/controller.dart';
import 'package:sb_control/app/preferences.dart';
import 'package:sb_control/bluetooth/demo_transport.dart';
import 'package:sb_control/core/models.dart';
import 'package:sb_control/l10n/strings.dart';
import 'package:sb_control/ui/app.dart';

class FailedConnection extends DemoTransport {
  @override
  Future<List<GattField>> connect(String id) async =>
      throw StateError('Connection failed');
}

void main() {
  for (final saved in [true, false]) {
    for (final fail in [false, true]) {
      testWidgets(
        '${saved ? 'saved' : 'discovered'} device ${fail ? 'stays on devices after failure' : 'opens controls after confirmation'}',
        (tester) async {
          final device = DemoTransport.devices.first;
          final p = MemoryPreferences();
          if (saved) {
            p.value['devices'] = [
              SavedDevice(
                id: device.id,
                name: device.name,
                model: DeviceModel.venty,
              ).toJson(),
            ];
          }
          final c = AppController(
            preferences: p,
            nativeFactory: fail ? FailedConnection.new : DemoTransport.new,
          );
          await c.initialize();
          if (!saved) c.found[device.id] = device;
          await tester.pumpWidget(SbControlApp(controller: c));
          await tester.tap(find.text(L.s090).last);
          await tester.pumpAndSettle();
          final tile = find.byKey(
            ValueKey('${saved ? 'saved' : 'found'}-${device.id}'),
          );
          await tester.ensureVisible(tile);
          await tester.pumpAndSettle();
          await tester.tap(tile);
          for (var n = 0; n < 100; n++) {
            await tester.pump(const Duration(milliseconds: 20));
          }
          expect(c.connected, !fail);
          expect(
            tester
                .widget<NavigationBar>(find.byType(NavigationBar))
                .selectedIndex,
            fail ? 1 : 0,
          );
          if (!fail && saved) {
            final revision = c.connectionRevision;
            await tester.tap(find.text(L.s090).last);
            await tester.pumpAndSettle();
            await tester.ensureVisible(tile);
            await tester.tap(tile);
            await tester.pumpAndSettle();
            expect(
              tester
                  .widget<NavigationBar>(find.byType(NavigationBar))
                  .selectedIndex,
              0,
            );
            expect(
              c.connectionRevision,
              revision,
              reason: 'Already connected device opens without reconnecting',
            );
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.runAsync(c.shutdown);
          c.dispose();
        },
      );
    }
  }
}
