import 'package:flutter_test/flutter_test.dart';
import 'package:sb_control/app/controller.dart';
import 'package:sb_control/app/preferences.dart';
import 'package:sb_control/bluetooth/demo_transport.dart';
import 'package:sb_control/core/models.dart';
import 'package:sb_control/core/protocol.dart';

class RecordingDemo extends DemoTransport {
  final writes = <List<int>>[];
  @override
  Future<void> write(GattField field, List<int> bytes) {
    writes.add([...bytes]);
    return super.write(field, bytes);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('firmware and short responses gate permanent boost', () {
    expect(
      QvapCodec.supportsPermanentBoost(DeviceModel.venty, 'V01.07'),
      false,
    );
    expect(QvapCodec.supportsPermanentBoost(DeviceModel.venty, 'V01.08'), true);
    expect(QvapCodec.supportsPermanentBoost(DeviceModel.venty, 'V01.11'), true);
    expect(QvapCodec.supportsPermanentBoost(DeviceModel.venty, null), false);
    expect(
      QvapCodec.supportsPermanentBoost(DeviceModel.craftyPlus, 'V03.01'),
      false,
    );
    expect(
      QvapCodec.decode([6, 0, 9, 0, 0, 1]).containsKey('permanentBoost'),
      false,
    );
  });
  test(
    'device settings survive reconnect, connect never rewrites them, reset explicit',
    () async {
      final transport = RecordingDemo();
      final c = AppController(
        preferences: MemoryPreferences(),
        nativeFactory: () => transport,
      );
      await c.initialize();
      for (final device in DemoTransport.devices.where(
        (d) => d.id == 'demo-venty' || d.id == 'demo-veazy',
      )) {
        await c.connect(device);
        await c.setTarget(190);
        await c.setBoost(12);
        await c.setBoost(17, superboost: true);
        await c.setPermanentBoost(true);
        await c.setBoostVisualization(false);
        expect(c.data['permanentBoost'], true);
        expect(c.data['boostVisualization'], false);
        expect(
          c.data['heater'],
          false,
          reason: 'Configuration must not start heating',
        );
        await c.disconnect();
        transport.writes.clear();
        await c.connect(device);
        expect(c.data['target'], 190);
        expect(c.data['boost'], 12);
        expect(c.data['superboost'], 17);
        expect(c.data['permanentBoost'], true);
        expect(c.data['boostVisualization'], false);
        expect(
          transport.writes.every((p) => p[1] == 0),
          true,
          reason: 'Reconnect only queries',
        );
        await c.setBoostVisualization(true);
        expect(c.data['boostVisualization'], true);
        await c.setHeat(true);
        expect(c.enabled('factoryReset'), false);
        await c.setHeat(false);
        await c.factoryReset();
        expect(c.data['target'], 180);
        expect(c.data['boost'], 15);
        expect(c.data['superboost'], 15);
        expect(c.data['permanentBoost'], false);
        expect(c.data['boostVisualization'], true);
        expect(c.error, isEmpty);
      }
      await c.shutdown();
      c.dispose();
    },
  );
}
