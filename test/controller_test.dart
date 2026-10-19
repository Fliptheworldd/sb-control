import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sb_control/app/controller.dart';
import 'package:sb_control/app/preferences.dart';
import 'package:sb_control/bluetooth/demo_transport.dart';
import 'package:sb_control/core/models.dart';
import 'package:sb_control/core/protocol.dart';

class BootloaderDemo extends DemoTransport {
  final commands = <int>[];
  @override
  Stream<List<int>> subscribe(GattField field) =>
      super.subscribe(field).map((p) {
        if (p[0] == 2) return List<int>.from(p)..[1] = 0;
        return p;
      });
  @override
  Future<void> write(GattField field, List<int> bytes) {
    commands.add(bytes.first);
    return super.write(field, bytes);
  }
}

class FahrenheitDemo extends DemoTransport {
  @override
  Future<List<int>> read(GattField field) => field.id == '00000021$craftyBase'
      ? Future.value(le(3650, 2))
      : super.read(field);
}

class UnconfirmedDemo extends DemoTransport {
  @override
  Future<void> write(GattField field, List<int> bytes) async {
    if (field.id == '10110003$sbBase') return;
    await super.write(field, bytes);
  }
}

class DelayedDemo extends DemoTransport {
  final entered = Completer<void>(), release = Completer<void>();
  final writes = <String>[];
  @override
  Future<void> write(GattField field, List<int> bytes) async {
    writes.add(field.id);
    if (field.id == '00000021$craftyBase') {
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
    'all five device profiles support a complete simulated session',
    () async {
      final c = AppController(preferences: MemoryPreferences());
      await c.initialize(startDemo: true);
      for (final device in DemoTransport.devices) {
        await c.connect(device);
        expect(c.connected, true, reason: c.error);
        expect(c.supports('target'), true);
        await c.setTarget(185);
        expect(c.data['target'], 185);
        await c.setHeat(true);
        expect(c.data['heater'], true, reason: c.error);
        await c.setVibration(false);
        expect(c.data['vibration'], false, reason: c.error);
        await c.setBrightness(c.model.isQvap ? 5 : 50);
        expect(c.data['brightness'], c.model.isQvap ? 5 : 50);
        if (c.model.isQvap) {
          await c.setEco(true);
          expect(c.data['ecoCharge'], true);
          await c.setEco(true, voltage: true);
          expect(c.data['chargeLimit'], true);
          await c.setBoost(20, superboost: true);
          expect(c.data['superboost'], 20);
        } else {
          await c.setAutoOff(180);
          expect(c.data['autoOff'], 180);
        }
        if (c.model == DeviceModel.volcanoHybrid) {
          await c.setPump(true);
          expect(c.data['pump'], true);
        } else {
          await c.setBoost(15);
          expect(c.data['boost'], 15);
        }
        await c.setHeat(false);
        expect(c.data['heater'], false);
      }
      await c.shutdown();
      c.dispose();
    },
  );
  test(
    'QVAP bootloader receives only firmware query, never status or control',
    () async {
      final transport = BootloaderDemo();
      final c = AppController(
        preferences: MemoryPreferences(),
        nativeFactory: () => transport,
      );
      await c.initialize();
      await c.connect(DemoTransport.devices.first);
      expect(c.connected, false);
      expect(c.supports('heat'), false);
      expect(transport.commands, [2]);
      expect(c.error, contains('Update-Modus'));
      await c.shutdown();
      c.dispose();
    },
  );
  test(
    'CRAFTY Fahrenheit read mode blocks ambiguous temperature writes',
    () async {
      final c = AppController(
        preferences: MemoryPreferences(),
        nativeFactory: FahrenheitDemo.new,
      );
      await c.initialize();
      await c.connect(DemoTransport.devices[2]);
      expect(c.data['target'], 185);
      expect(c.supports('target'), false);
      expect(c.supports('boost'), false);
      expect(c.supports('heat'), true);
      await c.shutdown();
      c.dispose();
    },
  );
  test(
    'failed readback disconnects and does not pretend a target was applied',
    () async {
      final c = AppController(
        preferences: MemoryPreferences(),
        nativeFactory: UnconfirmedDemo.new,
      );
      await c.initialize();
      await c.connect(DemoTransport.devices.last);
      await c.setTarget(190);
      expect(c.connected, false);
      expect(c.error, contains('nicht sicher bestätigt'));
      expect(c.data['target'], isNull);
      await c.shutdown();
      c.dispose();
    },
  );
  test(
    'disconnect invalidates remaining writes in a multi-write operation',
    () async {
      final t = DelayedDemo();
      final c = AppController(
        preferences: MemoryPreferences(),
        nativeFactory: () => t,
      );
      await c.initialize();
      await c.connect(DemoTransport.devices[2]);
      final pending = c.setTarget(185);
      await t.entered.future;
      await c.disconnect();
      final next = c.connect(DemoTransport.devices.first);
      t.release.complete();
      await pending;
      await next;
      expect(t.writes, isNot(contains('00000031$craftyBase')));
      expect(c.connected, true);
      expect(c.model, DeviceModel.venty);
      await c.shutdown();
      c.dispose();
    },
  );
  test(
    'preferences persist names and unit, never actuator state or demo devices',
    () async {
      final p = MemoryPreferences();
      final c = AppController(preferences: p, nativeFactory: DemoTransport.new);
      await c.initialize();
      await c.connect(DemoTransport.devices.first);
      await c.rename(c.active!.id, 'Mein VENTY');
      await c.setFahrenheit(true);
      await c.setHeat(true);
      await c.disconnect();
      expect(p.value['fahrenheit'], true);
      expect(p.value.containsKey('heater'), false);
      await c.setDemo(true);
      expect(c.saved.length, 1);
      expect(c.diagnosticReport(), isNot(contains('VY000001')));
      await c.shutdown();
      c.dispose();
    },
  );
}
