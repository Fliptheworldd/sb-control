import 'dart:async';
import 'dart:convert';
import '../core/models.dart';
import '../core/protocol.dart';
import 'transport.dart';

/// Simulator, never a fallback for a failed native connection.
/// Uses the same codecs and controller as the native app.
class DemoTransport implements BleTransport {
  final _connection = StreamController<bool>.broadcast();
  final Map<String, StreamController<List<int>>> _notifications = {};
  DeviceModel model = DeviceModel.venty;
  bool connected = false, heating = false, pump = false, vibration = true;
  bool permanentBoost = false, boostVisualizationBit = true;
  bool ecoCharge = false, chargeLimit = false, permanentBluetooth = false;
  int target = 180, boost = 15, superboost = 15, brightness = 7, autoOff = 120;
  final Map<String, List<Object>> _deviceSettings = {};
  String? _deviceId;
  void _saveSettings() {
    if (_deviceId != null) {
      _deviceSettings[_deviceId!] = [
        target,
        boost,
        superboost,
        brightness,
        vibration,
        ecoCharge,
        chargeLimit,
        permanentBoost,
        boostVisualizationBit,
        permanentBluetooth,
        autoOff,
      ];
    }
  }

  double current = 24;
  DateTime _last = DateTime.now();
  static final devices = [
    for (final m in DeviceModel.values.where((m) => m != DeviceModel.unknown))
      NearbyDevice(
        'demo-${m.name}',
        switch (m) {
          DeviceModel.venty => 'S&B VY000001',
          DeviceModel.veazy => 'S&B VZ000002',
          DeviceModel.volcanoHybrid => 'S&B VOLCANO H',
          _ => 'Storz&Bickel ${m.label}',
        },
        -48 - m.index * 6,
        m.isQvap
            ? [qService]
            : m.isCrafty
            ? [craftyControl, craftyInfo, craftyState]
            : [hybridState, hybridControl],
      ),
  ];
  @override
  Stream<bool> get connection => _connection.stream;
  @override
  Stream<NearbyDevice> scan() async* {
    for (final d in devices) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      yield d;
    }
  }

  @override
  Future<List<GattField>> connect(String id) async {
    model = DeviceModel.values.firstWhere((m) => id == 'demo-${m.name}');
    heating = false;
    pump = false;
    current = 24;
    _saveSettings();
    _deviceId = id;
    final saved =
        _deviceSettings[id] ??
        <Object>[
          180,
          15,
          15,
          model.isQvap ? 7 : 70,
          true,
          false,
          false,
          false,
          model == DeviceModel.venty,
          false,
          120,
        ];
    target = saved[0] as int;
    boost = saved[1] as int;
    superboost = saved[2] as int;
    brightness = saved[3] as int;
    vibration = saved[4] as bool;
    ecoCharge = saved[5] as bool;
    chargeLimit = saved[6] as bool;
    permanentBoost = saved[7] as bool;
    boostVisualizationBit = saved[8] as bool;
    permanentBluetooth = saved[9] as bool;
    autoOff = saved[10] as int;
    connected = true;
    _last = DateTime.now();
    _connection.add(true);
    if (model.isQvap) {
      return [
        const GattField(qService, qCharacteristic, write: true, notify: true),
      ];
    }
    final writes = model.isCrafty
        ? [
            '00000021',
            '00000031',
            '00000051',
            '00000061',
            '000001c3',
            '000001b3',
            '00000081',
            '00000091',
          ]
        : [
            '10110003',
            '10110005',
            '1011000d',
            '1010000e',
            '1011000f',
            '10110010',
            '10110013',
            '10110014',
          ];
    final reads = AttributeCodec.fields(model);
    return [
      for (final id in {...reads, ...writes})
        GattField(
          AttributeCodec.service(model, id),
          AttributeCodec.uuid(model, id),
          read: reads.contains(id),
          write: writes.contains(id),
          notify: false,
        ),
    ];
  }

  void _tick() {
    final now = DateTime.now(),
        difference = now.difference(_last).inMilliseconds / 1000;
    _last = now;
    current = heating
        ? (current + difference * 9).clamp(24, target.toDouble())
        : (current - difference * 2).clamp(24, 230);
  }

  @override
  Future<List<int>> read(GattField field) async {
    if (!connected) throw StateError('Demo getrennt');
    _tick();
    final key = field.id.substring(0, 8);
    if (key == '00000032' || key == '10100003') {
      return ascii.encode(
        model == DeviceModel.craftyPlus ? 'V03.01' : 'V02.51',
      );
    }
    if (key == '00000052' || key == '10100008') return ascii.encode('DEMO0001');
    if (key == '00000072') return [1, 2, 3];
    if (key == '10100004') return ascii.encode('V01.02');
    return le(switch (key) {
      '00000011' || '10110001' => (current * 10).round(),
      '00000021' || '10110003' => target * 10,
      '00000031' => boost * 10,
      '00000041' => 82,
      '00000051' || '10110005' => brightness,
      '00000061' || '1011000d' => autoOff,
      '00000071' || '1011000c' => heating ? autoOff : 0,
      '00000093' => heating ? 16 : 0,
      '000001c3' =>
        (vibration ? 0 : 1) | (current >= target && heating ? 4 : 0),
      '1010000c' => (heating ? 32 : 0) | (pump ? 8192 : 0),
      '1010000e' => vibration ? 0 : 1024,
      '00000023' || '10110015' => 42,
      '000001e3' || '10110016' => 18,
      _ => 0,
    }, 2);
  }

  List<int> _qReply(int command) {
    final p = List<int>.filled(command == 6 ? 7 : 20, 0)..[0] = command;
    if (command == 2) {
      p[1] = 1;
      p.setRange(2, 8, ascii.encode('V01.09'));
      p.setRange(11, 17, ascii.encode('V01.02'));
    }
    if (command == 1) {
      p[3] = 128; // Sentinel: no invented VENTY/VEAZY sensor reading.
      p[4] = (target * 10) & 255;
      p[5] = (target * 10) >> 8;
      p[6] = boost;
      p[7] = superboost;
      p[8] = 82;
      p[9] = heating ? 120 : 0;
      p[11] = heating ? 1 : 0;
      p[14] =
          (current >= target && heating ? 2 : 0) |
          (ecoCharge ? 8 : 0) |
          (chargeLimit ? 32 : 0) |
          (boostVisualizationBit ? 64 : 0);
      p[16] = permanentBluetooth ? 1 : 0;
    }
    if (command == 4) {
      p[1] = 234;
      p[2] = 9;
    }
    if (command == 5) {
      p.setRange(9, 15, ascii.encode('000001'));
      p.setRange(
        15,
        17,
        ascii.encode(model == DeviceModel.venty ? 'VY' : 'VZ'),
      );
    }
    if (command == 6) {
      p[2] = brightness;
      p[5] = vibration ? 1 : 0;
      p[6] = permanentBoost ? 1 : 0;
    }
    return p;
  }

  @override
  Future<void> write(GattField field, List<int> bytes) async {
    if (!connected) throw StateError('Demo getrennt');
    _tick();
    if (model.isQvap) {
      final cmd = bytes[0], mask = bytes[1];
      if (cmd == 1) {
        if ((mask & 2) != 0) target = uint16(bytes, 4) ~/ 10;
        if ((mask & 4) != 0) boost = bytes[6];
        if ((mask & 8) != 0) superboost = bytes[7];
        if ((mask & 32) != 0) heating = bytes[11] > 0;
        if ((mask & 128) != 0) {
          if ((bytes[15] & 4) != 0 && (bytes[14] & 4) != 0) {
            target = 180;
            boost = 15;
            superboost = 15;
            brightness = 9;
            vibration = true;
            permanentBoost = false;
            ecoCharge = false;
            chargeLimit = false;
            boostVisualizationBit = model == DeviceModel.venty;
          }
          if ((bytes[15] & 64) != 0) {
            boostVisualizationBit = (bytes[14] & 64) != 0;
          }
          if ((bytes[15] & 8) != 0) ecoCharge = (bytes[14] & 8) != 0;
          if ((bytes[15] & 32) != 0) chargeLimit = (bytes[14] & 32) != 0;
          if ((bytes[17] & 1) != 0) permanentBluetooth = (bytes[16] & 1) != 0;
        }
      }
      if (cmd == 6) {
        if ((mask & 16) != 0) permanentBoost = bytes[6] != 0;
        if ((mask & 1) != 0) brightness = bytes[2];
        if ((mask & 8) != 0) vibration = bytes[5] != 0;
      }
      await Future<void>.delayed(const Duration(milliseconds: 15));
      if (connected) _notifications[field.key]?.add(_qReply(cmd));
      return;
    }
    switch (field.id.substring(0, 8)) {
      case '00000021':
      case '10110003':
        target = uint16(bytes) ~/ 10;
      case '00000031':
        boost = uint16(bytes) ~/ 10;
      case '00000051':
      case '10110005':
        brightness = uint16(bytes);
      case '00000081':
      case '1011000f':
        heating = true;
      case '00000091':
      case '10110010':
        heating = false;
      case '10110013':
        pump = true;
      case '10110014':
        pump = false;
      case '00000061':
      case '1011000d':
        autoOff = uint16(bytes);
      case '000001c3':
        vibration = (uint16(bytes) & 1) == 0;
      case '1010000e':
        vibration = bytes.length == 4 && bytes[2] == 0;
      case '000001b3':
        break;
      default:
        throw UnsupportedError('Kein Demo-Befehl');
    }
  }

  @override
  Stream<List<int>> subscribe(GattField field) =>
      (_notifications[field.key] ??= StreamController<List<int>>.broadcast())
          .stream;
  @override
  Future<void> disconnect() async {
    _saveSettings();
    connected = false;
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _connection.close();
    for (final s in _notifications.values) {
      await s.close();
    }
  }
}
