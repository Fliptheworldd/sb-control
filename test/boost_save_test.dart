import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sb_control/app/controller.dart';
import 'package:sb_control/app/preferences.dart';
import 'package:sb_control/bluetooth/demo_transport.dart';
import 'package:sb_control/core/models.dart';

class MissingBoostConfirmation extends DemoTransport {
  @override
  Future<void> write(GattField field, List<int> bytes) =>
      bytes[0] == 1 && bytes[1] == 4
      ? super.write(field, List<int>.from(bytes)..[1] = 0)
      : super.write(field, bytes);
}

class InterruptedBoost extends DemoTransport {
  final entered = Completer<void>(), release = Completer<void>();
  final setters = <int>[];
  @override
  Future<void> write(GattField field, List<int> bytes) async {
    if (bytes[0] == 1 && bytes[1] != 0) setters.add(bytes[1]);
    if (bytes[0] == 1 && bytes[1] == 4) {
      entered.complete();
      await release.future;
      return;
    }
    await super.write(field, bytes);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'explicit save confirms both offsets and reconnect reads device values',
    () async {
      final c = AppController(
        preferences: MemoryPreferences(),
        nativeFactory: DemoTransport.new,
      );
      await c.initialize();
      for (final d in DemoTransport.devices.take(4)) {
        await c.connect(d);
        expect(
          await c.saveBoostSettings(
            boost: 12,
            superboost: c.model.isQvap ? 23 : null,
          ),
          true,
        );
        expect(c.data['heater'], false);
        await c.disconnect();
        await c.connect(d);
        expect(c.data['boost'], 12);
        if (c.model.isQvap) expect(c.data['superboost'], 23);
      }
      await c.shutdown();
      c.dispose();
    },
  );
  test('a missing readback never reports the pair saved', () async {
    final c = AppController(
      preferences: MemoryPreferences(),
      nativeFactory: MissingBoostConfirmation.new,
    );
    await c.initialize();
    await c.connect(DemoTransport.devices.first);
    expect(await c.saveBoostSettings(boost: 19, superboost: 22), false);
    expect(c.connected, false);
    expect(c.error, isNotEmpty);
    await c.shutdown();
    c.dispose();
  });
  test(
    'disconnect between offsets cancels second write and success feedback',
    () async {
      final t = InterruptedBoost();
      final c = AppController(
        preferences: MemoryPreferences(),
        nativeFactory: () => t,
      );
      await c.initialize();
      await c.connect(DemoTransport.devices.first);
      final saving = c.saveBoostSettings(boost: 19, superboost: 22);
      await t.entered.future;
      await c.disconnect();
      t.release.complete();
      expect(await saving, false);
      expect(t.setters, [4]);
      await c.shutdown();
      c.dispose();
    },
  );
}
