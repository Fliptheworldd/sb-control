import '../l10n/strings.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'models.dart';

// Independent implementation of observed protocol facts. See docs/PROTOCOLS.md.
// There is deliberately no general-purpose opcode or arbitrary-write API in UI.
const sbBase = '-5354-4f52-5a26-4249434b454c';
const craftyBase = '-4c45-4b43-4942-265a524f5453';
const qService = '00000000$sbBase';
const qCharacteristic = '00000001$sbBase';
const hybridState = '10100000$sbBase';
const hybridControl = '10110000$sbBase';
const craftyControl = '00000001$craftyBase';
const craftyInfo = '00000002$craftyBase';
const craftyState = '00000003$craftyBase';

List<int> le(int number, int width) {
  if ((width != 2 && width != 4) ||
      number < 0 ||
      number >= (1 << (width * 8))) {
    throw RangeError(L.s040);
  }
  return List.generate(width, (i) => (number >> (i * 8)) & 255);
}

int uint16(List<int> bytes, [int offset = 0]) {
  if (bytes.length < offset + 2) {
    throw const FormatException(L.s041);
  }
  return bytes[offset] | (bytes[offset + 1] << 8);
}

String hexBytes(List<int> bytes) =>
    bytes.map((v) => v.toRadixString(16).padLeft(2, '0')).join(' ');
String asciiBytes(List<int> bytes) =>
    ascii.decode(bytes, allowInvalid: true).replaceAll('\u0000', '').trim();
void within(int n, int min, int max) {
  if (n < min || n > max) throw RangeError.range(n, min, max);
}

DeviceModel identify(String name, Iterable<String> services) {
  final s = services.map((e) => e.toLowerCase()).toSet();
  final n = name.toUpperCase();
  if (s.contains(qService)) {
    if (n.contains('VEAZY') || n.startsWith('S&B VZ')) return DeviceModel.veazy;
    if (n.contains('VENTY') || n.startsWith('S&B VY')) return DeviceModel.venty;
    return DeviceModel
        .unknown; // Shared service cannot distinguish these models.
  }
  if (s.contains(hybridControl) && s.contains(hybridState)) {
    return DeviceModel.volcanoHybrid;
  }
  if (s.contains(craftyControl) && s.contains(craftyInfo)) {
    return DeviceModel.crafty;
  }
  return DeviceModel.unknown; // Advertised names alone never authorize writes.
}

bool looksLikeSb(NearbyDevice d) {
  final n = d.name.toUpperCase();
  return [
        'STORZ&BICKEL',
        'S&B',
        'VENTY',
        'VEAZY',
        'CRAFTY',
        'VOLCANO',
      ].any(n.startsWith) ||
      d.services.any(
        (s) => [
          qService,
          hybridControl,
          hybridState,
          craftyControl,
          craftyInfo,
          craftyState,
        ].contains(s.toLowerCase()),
      );
}

List<int>? craftyFirmware(String? text) {
  final m = RegExp(
    r'^V?(\d+)\.(\d+)$',
    caseSensitive: false,
  ).firstMatch(text?.trim() ?? '');
  return m == null ? null : [int.parse(m[1]!), int.parse(m[2]!)];
}

bool craftyModern(String? text) {
  final v = craftyFirmware(text);
  return v != null && (v[0] > 2 || (v[0] == 2 && v[1] >= 51));
}

class QvapCodec {
  static const evidence = 'S&B qvap.js v3.4.1';
  static BleCommand _packet(int cmd, int size, Map<int, int> values) {
    final p = Uint8List(size)..[0] = cmd;
    for (final e in values.entries) {
      p[e.key] = e.value;
    }
    return BleCommand(qService, qCharacteristic, p, evidence);
  }

  static BleCommand firmware() => _packet(2, 20, {});
  static BleCommand status() => _packet(1, 20, {});
  static BleCommand info() => _packet(5, 20, {});
  static BleCommand runtime() => _packet(4, 20, {});
  static BleCommand analysis() => _packet(3, 20, {});
  static BleCommand settings() => _packet(6, 7, {});
  static BleCommand target(int celsius) {
    within(celsius, 40, 210);
    final v = le(celsius * 10, 2);
    return _packet(1, 20, {1: 2, 4: v[0], 5: v[1]});
  }

  static BleCommand heat(bool on) => _packet(1, 20, {1: 32, 11: on ? 1 : 0});
  static BleCommand boost(int offset, {bool superboost = false}) {
    within(offset, 1, 99);
    return _packet(1, 20, {1: superboost ? 8 : 4, superboost ? 7 : 6: offset});
  }

  static BleCommand brightness(int value) {
    within(value, 1, 9);
    return _packet(6, 7, {1: 1, 2: value});
  }

  static BleCommand vibration(bool value) =>
      _packet(6, 7, {1: 8, 5: value ? 1 : 0});
  static BleCommand eco(bool value, {bool voltage = false}) {
    final bit = voltage ? 32 : 8;
    return _packet(1, 20, {1: 128, 14: value ? bit : 0, 15: bit});
  }

  static bool supportsPermanentBoost(DeviceModel model, String? firmware) {
    if (model == DeviceModel.veazy) return true;
    if (model != DeviceModel.venty) return false;
    final match = RegExp(r'^V?0*1\.(\d+)$').firstMatch(firmware ?? '');
    return match != null && int.parse(match.group(1)!) >= 8;
  }

  static BleCommand permanentBoost(bool value) =>
      _packet(6, 7, {1: 16, 6: value ? 1 : 0});
  static BleCommand boostVisualization(DeviceModel model, bool value) {
    if (!model.isQvap) throw UnsupportedError(L.s042);
    final bit = model == DeviceModel.veazy ? !value : value;
    return _packet(1, 20, {1: 128, 14: bit ? 64 : 0, 15: 64});
  }

  static BleCommand factoryReset() => _packet(1, 20, {1: 128, 14: 4, 15: 4});

  static BleCommand permanentBluetooth(DeviceModel model, bool value) {
    if (model != DeviceModel.veazy) {
      throw UnsupportedError(L.s043);
    }
    return _packet(1, 20, {1: 128, 16: value ? 1 : 0, 17: 1});
  }

  static Map<String, Object?> decode(List<int> p) {
    if (p.isEmpty) throw const FormatException(L.s044);
    switch (p[0]) {
      case 2:
        if (p.length < 19) {
          throw const FormatException(L.s045);
        }
        return {
          'firmware': asciiBytes(p.sublist(2, 8)),
          'bootloader': asciiBytes(p.sublist(11, 17)),
          'applicationMode': (p[1] & 1) != 0 && (p[1] & 48) == 0,
          'firmwareFlags': p[1],
        };
      case 1:
        if (p.length < 15) {
          throw const FormatException(L.s046);
        }
        final rawCurrent = uint16(p, 2), rawTarget = uint16(p, 4);
        if (rawTarget < 400 || rawTarget > 2100 || p[8] > 100 || p[11] > 3) {
          throw const FormatException(L.s047);
        }
        return {
          'current': rawCurrent >= 0x8000 || rawCurrent > 3000
              ? null
              : rawCurrent / 10,
          'target': rawTarget / 10,
          'boost': p[6],
          'superboost': p[7],
          'battery': p[8],
          'remaining': p[9] + p[10],
          'heater': p[11] > 0,
          'heaterMode': p[11],
          'charging': p[13] > 0,
          'ready': (p[14] & 2) != 0,
          'ecoCharge': (p[14] & 8) != 0,
          'chargeLimit': (p[14] & 32) != 0,
          'boostVisualizationBit': (p[14] & 64) != 0,
          if (p.length >= 17) 'permanentBluetooth': (p[16] & 1) != 0,
        };
      case 3:
        if (p.length < 3) throw const FormatException(L.s048);
        return {'errorCode': p[1], 'errorCategory': p[2], 'fault': p[2] == 4};
      case 4:
        if (p.length < 7) throw const FormatException(L.s049);
        return {'runtimeMinutes': p[1] | p[2] << 8 | p[3] << 16};
      case 5:
        if (p.length < 18) throw const FormatException(L.s050);
        return {
          'serial': asciiBytes([...p.sublist(15, 17), ...p.sublist(9, 15)]),
        };
      case 6:
        if (p.length < 6) throw const FormatException(L.s051);
        return {
          'brightness': p[2],
          'vibration': p[5] != 0,
          if (p.length >= 7 && p[6] <= 1) 'permanentBoost': p[6] == 1,
        };
      default:
        return {}; // No inferred meaning for unrecognized responses.
    }
  }
}

class AttributeCodec {
  static String service(DeviceModel m, String prefix) => m.isCrafty
      ? '${prefix.endsWith('1')
            ? '00000001'
            : prefix.endsWith('2')
            ? '00000002'
            : '00000003'}$craftyBase'
      : '${prefix.startsWith('1011') ? '10110000' : '10100000'}$sbBase';
  static String uuid(DeviceModel m, String prefix) =>
      '$prefix${m.isCrafty ? craftyBase : sbBase}';
  static BleCommand _command(DeviceModel m, String prefix, List<int> bytes) {
    if (!m.isCrafty && m != DeviceModel.volcanoHybrid) {
      throw UnsupportedError(L.s052);
    }
    return BleCommand(
      service(m, prefix),
      uuid(m, prefix),
      bytes,
      m.isCrafty ? 'S&B crafty.js v3.4.1' : 'S&B volcano.js v3.4.1',
    );
  }

  static BleCommand target(DeviceModel m, int value) {
    within(value, 40, m.maxTemperature);
    return _command(
      m,
      m.isCrafty ? '00000021' : '10110003',
      le(value * 10, m.isCrafty ? 2 : 4),
    );
  }

  static BleCommand heat(DeviceModel m, bool on) => _command(
    m,
    m.isCrafty
        ? (on ? '00000081' : '00000091')
        : (on ? '1011000f' : '10110010'),
    m.isCrafty ? [0, 0] : [0],
  );
  static BleCommand pump(bool on) =>
      _command(DeviceModel.volcanoHybrid, on ? '10110013' : '10110014', [0]);
  static BleCommand boost(DeviceModel m, int value) {
    if (!m.isCrafty) throw UnsupportedError(L.s053);
    within(value, 1, 99);
    return _command(m, '00000031', le(value * 10, 2));
  }

  static BleCommand brightness(DeviceModel m, int value) {
    within(value, 0, 100);
    return _command(m, m.isCrafty ? '00000051' : '10110005', le(value, 2));
  }

  static List<BleCommand> autoOff(DeviceModel m, int seconds) {
    within(seconds, m.isCrafty ? 30 : 60, m.isCrafty ? 300 : 21600);
    return [
      if (m.isCrafty) _command(m, '000001b3', le(815, 2)),
      _command(m, m.isCrafty ? '00000061' : '1011000d', le(seconds, 2)),
    ];
  }

  static BleCommand vibration(
    DeviceModel m,
    bool enabled, {
    int? freshRegister,
  }) {
    if (m.isCrafty) {
      if (freshRegister == null) {
        throw StateError(L.s054);
      }
      return _command(
        m,
        '000001c3',
        le(enabled ? freshRegister & ~1 : freshRegister | 1, 2),
      );
    }
    return _command(m, '1010000e', le(0x400 + (enabled ? 0 : 0x10000), 4));
  }

  static Map<String, Object?> decode(
    DeviceModel m,
    String characteristic,
    List<int> p,
  ) {
    final id = characteristic.substring(0, 8).toLowerCase();
    final names = m.isCrafty
        ? {'00000032': 'firmware', '00000052': 'serial'}
        : {
            '10100003': 'firmware',
            '10100004': 'bleFirmware',
            '10100008': 'serial',
          };
    if (names.containsKey(id)) return {names[id]!: asciiBytes(p)};
    if (id == '00000072') {
      if (p.length < 3) throw const FormatException(L.s055);
      return {'bleFirmware': '${p[0]}.${p[1]}.${p[2]}'};
    }
    if (id == '10100015' || id == '10100016') return {'raw.$id': hexBytes(p)};
    final v = uint16(p);
    switch (id) {
      case '00000011':
      case '10110001':
        return {'current': v >= 0x8000 || v > 3000 ? null : v / 10};
      case '00000021':
        final raw = v / 10;
        final t = raw > 210 ? (raw - 32) / 1.8 : raw;
        if (t < 40 || t > 210.1) {
          throw const FormatException(L.s056);
        }
        return {'target': t, 'craftyFahrenheit': raw > 210};
      case '10110003':
        if (v < 400 || v > 2300) {
          throw const FormatException(L.s056);
        }
        return {'target': v / 10};
      case '00000031':
        return {'boost': (v / 10).round()};
      case '00000041':
        if (v > 100) throw const FormatException(L.s057);
        return {'battery': v};
      case '00000051':
      case '10110005':
        return {'brightness': v};
      case '00000061':
      case '1011000d':
        return {'autoOff': v};
      case '00000071':
      case '1011000c':
        return {'remaining': v};
      case '00000023':
      case '10110015':
        return {'runtimeHours': v};
      case '000001e3':
      case '10110016':
        return {'runtimeRemainder': v};
      case '00000093':
        return {
          'raw.$id': v,
          'heater': (v & 16) != 0,
          'heaterMode': (v & 64) != 0
              ? 3
              : (v & 32) != 0
              ? 2
              : (v & 16) != 0
              ? 1
              : 0,
          'fault': (v & 0x2008) != 0,
          'resetRequested': (v & 0x8000) != 0,
        };
      case '000001c3':
        return {'raw.$id': v, 'vibration': (v & 1) == 0, 'ready': (v & 4) != 0};
      case '1010000c':
        return {
          'raw.$id': v,
          'heater': (v & 32) != 0,
          'pump': (v & 8192) != 0,
          'fault': (v & 16408) != 0,
        };
      case '1010000e':
        return {'raw.$id': v, 'vibration': (v & 1024) == 0};
      default:
        return {'raw.$id': v};
    }
  }

  static List<String> fields(DeviceModel m) => m.isCrafty
      ? [
          '00000032',
          '00000052',
          '00000072',
          '00000021',
          '00000031',
          '00000011',
          '00000041',
          '00000051',
          '00000061',
          '00000071',
          '00000093',
          '000001c3',
          '00000023',
          '000001e3',
          '00000083',
          '00000063',
          '00000073',
        ]
      : [
          '10100003',
          '10100004',
          '10100008',
          '10110003',
          '10110001',
          '1010000c',
          '1010000d',
          '1010000e',
          '10110005',
          '1011000c',
          '1011000d',
          '10110015',
          '10110016',
          '10100015',
          '10100016',
        ];
}
