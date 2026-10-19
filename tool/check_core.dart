// This runner intentionally also works with only the standalone Dart SDK.
// ignore_for_file: avoid_relative_lib_imports
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../lib/core/models.dart';
import '../lib/core/protocol.dart';
import '../lib/core/serial_queue.dart';
import '../lib/bluetooth/demo_transport.dart';

int passed = 0;
void check(bool value, String label) {
  if (!value) throw StateError('FAIL $label');
  passed++;
  stdout.writeln('PASS $label');
}

bool throws(void Function() action) {
  try {
    action();
    return false;
  } catch (_) {
    return true;
  }
}

Future<void> main() async {
  final fixture =
      jsonDecode(File('test/fixtures/vendor_vectors.json').readAsStringSync())
          as Map;
  final commands = <String, List<int>>{
    for (final on in [true, false])
      'q.permanentBoost.$on': QvapCodec.permanentBoost(on).bytes,
    for (final on in [true, false])
      'q.visualization.venty.$on': QvapCodec.boostVisualization(
        DeviceModel.venty,
        on,
      ).bytes,
    for (final on in [true, false])
      'q.visualization.veazy.$on': QvapCodec.boostVisualization(
        DeviceModel.veazy,
        on,
      ).bytes,
    'q.reset': QvapCodec.factoryReset().bytes,
    'q.analysis': QvapCodec.analysis().bytes,
    'q.target185': QvapCodec.target(185).bytes,
    'q.boost15': QvapCodec.boost(15).bytes,
    'q.superboost20': QvapCodec.boost(20, superboost: true).bytes,
    'q.heatOn': QvapCodec.heat(true).bytes,
    'q.heatOff': QvapCodec.heat(false).bytes,
    'q.brightness7': QvapCodec.brightness(7).bytes,
    'q.vibrationOn': QvapCodec.vibration(true).bytes,
    'crafty.target185': AttributeCodec.target(DeviceModel.crafty, 185).bytes,
    'crafty.boost15': AttributeCodec.boost(DeviceModel.crafty, 15).bytes,
    'crafty.heatOn': AttributeCodec.heat(DeviceModel.crafty, true).bytes,
    'crafty.heatOff': AttributeCodec.heat(DeviceModel.crafty, false).bytes,
    'hybrid.target185': AttributeCodec.target(
      DeviceModel.volcanoHybrid,
      185,
    ).bytes,
    'hybrid.heatOn': AttributeCodec.heat(DeviceModel.volcanoHybrid, true).bytes,
    'hybrid.heatOff': AttributeCodec.heat(
      DeviceModel.volcanoHybrid,
      false,
    ).bytes,
    'hybrid.pumpOn': AttributeCodec.pump(true).bytes,
    'hybrid.pumpOff': AttributeCodec.pump(false).bytes,
  };
  for (final vector in fixture['vectors'] as List) {
    check(
      jsonEncode(commands[vector['case']]) ==
          jsonEncode(vector['writes'][0]['bytes']),
      'vendor bytes ${vector['case']}',
    );
  }
  check(
    throws(() => QvapCodec.target(211)),
    'reject excessive QVAP temperature',
  );
  check(
    throws(() => AttributeCodec.target(DeviceModel.volcanoHybrid, 231)),
    'reject excessive HYBRID temperature',
  );
  check(
    throws(() => AttributeCodec.target(DeviceModel.craftyPlus, 39)),
    'reject low CRAFTY+ temperature',
  );
  check(throws(() => QvapCodec.boost(0)), 'reject zero boost');
  check(throws(() => QvapCodec.decode([1, 0])), 'reject truncated status');
  check(throws(() => QvapCodec.decode([2, 1])), 'reject truncated firmware');
  check(throws(() => uint16([0])), 'reject truncated uint16');
  check(
    identify('VENTY', []) == DeviceModel.unknown,
    'name does not authorize control',
  );
  check(
    identify('S&B', [qService]) == DeviceModel.unknown,
    'shared service does not infer model',
  );
  check(
    identify('S&B VY123456', [qService]) == DeviceModel.venty,
    'VENTY advertising identity',
  );
  check(
    identify('S&B VZ123456', [qService]) == DeviceModel.veazy,
    'VEAZY advertising identity',
  );
  check(
    identify('unknown', [hybridState, hybridControl]) ==
        DeviceModel.volcanoHybrid,
    'HYBRID service identity',
  );
  check(
    !craftyModern('V02.50') && craftyModern('V02.51') && craftyModern('V03.01'),
    'firmware boundary',
  );
  check(
    !craftyModern(null) && !craftyModern('bad'),
    'unknown firmware blocked',
  );
  final firmware = List<int>.filled(20, 0)..[0] = 2;
  check(
    QvapCodec.decode(firmware)['applicationMode'] == false,
    'bootloader blocked',
  );
  firmware[1] = 0x11;
  check(
    QvapCodec.decode(firmware)['applicationMode'] == false,
    'invalid application blocked',
  );
  firmware[1] = 1;
  check(
    QvapCodec.decode(firmware)['applicationMode'] == true,
    'application mode recognized',
  );
  final status = List<int>.filled(20, 0)
    ..[0] = 1
    ..[3] = 128
    ..[4] = 8
    ..[5] = 7
    ..[8] = 80
    ..[9] = 70
    ..[10] = 50;
  check(
    QvapCodec.decode(status)['current'] == null,
    'sentinel is not a sensor temperature',
  );
  check(
    QvapCodec.decode(status)['remaining'] == 120,
    'countdown is sum, not uint16',
  );
  status[8] = 255;
  check(throws(() => QvapCodec.decode(status)), 'invalid battery rejected');
  check(
    AttributeCodec.decode(
          DeviceModel.crafty,
          '00000021$craftyBase',
          le(3650, 2),
        )['target'] ==
        185,
    'CRAFTY Fahrenheit read quirk',
  );
  final sequence = AttributeCodec.autoOff(DeviceModel.crafty, 120);
  check(
    sequence.length == 2 &&
        uint16(sequence.first.bytes) == 815 &&
        uint16(sequence.last.bytes) == 120,
    'CRAFTY protected write sequence',
  );
  check(
    uint16(
          AttributeCodec.vibration(
            DeviceModel.crafty,
            true,
            freshRegister: 0xa005,
          ).bytes,
        ) ==
        0xa004,
    'preserve unrelated register bits',
  );
  check(
    throws(() => QvapCodec.permanentBluetooth(DeviceModel.venty, true)),
    'no speculative VENTY permanent Bluetooth',
  );
  final queue = SerialQueue(), gate = Completer<void>();
  final order = <int>[];
  final first = queue.run(() async {
    await gate.future;
    order.add(1);
  });
  final second = queue.run(() async {
    order.add(2);
  });
  await Future<void>.delayed(Duration.zero);
  check(order.isEmpty, 'queue waits for in-flight request');
  gate.complete();
  await Future.wait([first, second]);
  check(order.join(',') == '1,2', 'GATT operations serialized');
  final stop = Completer<void>();
  final inFlight = queue.run(() => stop.future);
  final cancelled = queue.run(() async {
    throw StateError('MUST NOT RUN');
  });
  final caught = cancelled.then(
    (_) => false,
    onError: (Object e) => e.toString().contains('Verbindung wurde geändert'),
  );
  queue.invalidate();
  stop.complete();
  try {
    await inFlight;
  } catch (_) {}
  check(await caught, 'queued command cancelled by disconnect');
  for (final device in DemoTransport.devices) {
    final demo = DemoTransport();
    final fields = await demo.connect(device.id);
    check(
      fields.isNotEmpty &&
          identify(device.name, fields.map((f) => f.service)) !=
              DeviceModel.unknown,
      'demo profile ${device.id}',
    );
    await demo.dispose();
  }
  stdout.writeln('\n$passed core checks passed. No hardware involved.');
}
