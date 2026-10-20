import '../l10n/strings.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../bluetooth/demo_transport.dart';
import '../bluetooth/transport.dart';
import '../bluetooth/transport_factory.dart';
import '../core/models.dart';
import '../core/protocol.dart';
import '../core/serial_queue.dart';
import 'preferences.dart';

class AppController extends ChangeNotifier {
  AppController({
    Preferences? preferences,
    BleTransport Function()? nativeFactory,
  }) : _preferences = preferences ?? LocalPreferences(),
       _nativeFactory = nativeFactory ?? createNativeTransport;
  final Preferences _preferences;
  final BleTransport Function() _nativeFactory;
  final SerialQueue _queue = SerialQueue();
  BleTransport? _transport;
  StreamSubscription<NearbyDevice>? _scan;
  StreamSubscription<bool>? _link;
  final List<StreamSubscription<List<int>>> _subscriptions = [];
  Timer? _scanTimeout, _poll;
  Completer<List<int>>? _reply;
  int? _replyCommand;
  bool _disposed = false, _initializing = false, _polling = false;
  bool demo = false,
      scanning = false,
      connecting = false,
      connected = false,
      busy = false;
  bool fahrenheit = false;
  String status = L.s317, error = '';
  DeviceModel model = DeviceModel.unknown;
  NearbyDevice? active;
  List<GattField> fields = [];
  final Map<String, NearbyDevice> found = {};
  List<SavedDevice> saved = [];
  final Map<String, Object?> data = {};
  final List<String> log = [];
  DateTime? lastStatus;
  int _pollCount = 0;
  int? _operationGeneration;

  Future<T> _serialized<T>(Future<T> Function() action) => _queue.run(() async {
    _operationGeneration = _queue.generation;
    try {
      return await action();
    } finally {
      _operationGeneration = null;
    }
  });

  void _checkSession() {
    if (!connected ||
        _operationGeneration == null ||
        !_queue.isCurrent(_operationGeneration!)) {
      throw StateError(L.s001);
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> initialize({bool startDemo = false}) async {
    final p = await _preferences.load();
    fahrenheit = p['fahrenheit'] == true;
    final entries = p['devices'];
    if (entries is List) {
      for (final row in entries) {
        try {
          saved.add(
            SavedDevice.fromJson(Map<String, dynamic>.from(row as Map)),
          );
        } catch (_) {
          /* Ignore individual corrupt preferences. */
        }
      }
    }
    await setDemo(startDemo);
  }

  Future<void> _persist() => _preferences.save({
    'fahrenheit': fahrenheit,
    'devices': saved.map((d) => d.toJson()).toList(),
  });
  Future<void> setFahrenheit(bool value) async {
    fahrenheit = value;
    notifyListeners();
    await _persist();
  }

  String temperature(num? c) =>
      c == null ? '—' : '${(fahrenheit ? c * 9 / 5 + 32 : c).round()}';
  String get unit => fahrenheit ? '°F' : '°C';
  String get displayName {
    for (final d in saved) {
      if (d.id == active?.id) return d.displayName;
    }
    return model.label;
  }

  void _event(String event) {
    log.insert(
      0,
      '${DateTime.now().toIso8601String().substring(11, 19)}  $event',
    );
    if (log.length > 80) log.removeLast();
  }

  Future<void> setDemo(bool value) async {
    await disconnect();
    await _link?.cancel();
    await _transport?.dispose();
    demo = value;
    found.clear();
    log.clear();
    _transport = demo ? DemoTransport() : _nativeFactory();
    _link = _transport!.connection.listen((up) {
      if (!up && (connected || connecting)) {
        unawaited(disconnect(message: L.s002));
      }
    });
    status = demo ? L.s003 : L.s004;
    notifyListeners();
    if (demo) {
      for (final d in DemoTransport.devices) {
        found[d.id] = d;
      }
      await connect(DemoTransport.devices.first);
    }
  }

  Future<void> startScan() async {
    if (connecting || scanning) return;
    await stopScan();
    error = '';
    found.clear();
    scanning = true;
    status = L.s005;
    notifyListeners();
    _scan = _transport!.scan().listen(
      (device) {
        if (looksLikeSb(device)) {
          found[device.id] = device;
          notifyListeners();
        }
      },
      onError: (Object e) {
        error = '$e';
        _event(L.s006);
        unawaited(stopScan());
      },
      onDone: () => unawaited(stopScan()),
    );
    _scanTimeout = Timer(
      const Duration(seconds: 12),
      () => unawaited(stopScan()),
    );
  }

  Future<void> stopScan() async {
    _scanTimeout?.cancel();
    await _scan?.cancel();
    _scan = null;
    scanning = false;
    if (!connected && !connecting) {
      status = found.isEmpty
          ? L.s007
          : (L.italian
                ? "${found.length} dispositivi trovati"
                : "${found.length} Geräte gefunden");
    }
    notifyListeners();
  }

  GattField? _field(String id, [String? service]) {
    final matches = fields.where(
      (f) => f.id == id && (service == null || f.service == service),
    );
    return matches.length == 1
        ? matches.single
        : null; // Reject ambiguous GATT tables.
  }

  bool _writable(String id) {
    final f = _field(id);
    return f != null && (f.write || f.writeWithoutResponse);
  }

  String _id(String prefix) => AttributeCodec.uuid(model, prefix);
  bool get fresh =>
      lastStatus != null &&
      DateTime.now().difference(lastStatus!) < const Duration(seconds: 8);
  bool get _safe =>
      connected &&
      !_initializing &&
      fresh &&
      data['fault'] != true &&
      data['resetRequested'] != true;
  bool supports(String feature) {
    if (!_safe || model == DeviceModel.unknown) return false;
    if (model.isQvap) {
      if (data['applicationMode'] != true || !_writable(qCharacteristic)) {
        return false;
      }
      return switch (feature) {
        'target' ||
        'heat' ||
        'boost' ||
        'superboost' ||
        'brightness' ||
        'vibration' ||
        'ecoCharge' ||
        'chargeLimit' => true,
        'permanentBoost' =>
          data.containsKey('permanentBoost') &&
              QvapCodec.supportsPermanentBoost(
                model,
                data['firmware'] as String?,
              ),
        'boostVisualization' => data.containsKey('boostVisualization'),
        'factoryReset' => data['heater'] == false,
        'permanentBluetooth' =>
          model == DeviceModel.veazy && data.containsKey('permanentBluetooth'),
        _ => false,
      };
    }
    if (model.isCrafty) {
      final modern = craftyModern(data['firmware'] as String?);
      return switch (feature) {
        'target' =>
          data['craftyFahrenheit'] != true &&
              data['boost'] != null &&
              _writable(_id('00000021')) &&
              _writable(_id('00000031')),
        'boost' =>
          data['craftyFahrenheit'] != true && _writable(_id('00000031')),
        'heat' =>
          modern &&
              data['heater'] is bool &&
              _writable(_id('00000081')) &&
              _writable(_id('00000091')),
        'brightness' => _writable(_id('00000051')),
        'vibration' =>
          modern &&
              _writable(_id('000001c3')) &&
              _field(_id('000001c3'))?.read == true,
        'autoOff' =>
          modern && _writable(_id('000001b3')) && _writable(_id('00000061')),
        _ => false,
      };
    }
    return switch (feature) {
      'target' => _writable(_id('10110003')),
      'heat' =>
        data['heater'] is bool &&
            _writable(_id('1011000f')) &&
            _writable(_id('10110010')),
      'pump' =>
        data['pump'] is bool &&
            _writable(_id('10110013')) &&
            _writable(_id('10110014')),
      'brightness' => _writable(_id('10110005')),
      'vibration' => _writable(_id('1010000e')),
      'autoOff' => _writable(_id('1011000d')),
      _ => false,
    };
  }

  bool enabled(String feature) => supports(feature) && !busy && !connecting;

  Future<void> connect(NearbyDevice device) async {
    if (connecting || busy) return;
    await disconnect();
    error = '';
    connecting = true;
    _initializing = true;
    active = device;
    status = L.s009;
    notifyListeners();
    final token = _queue.generation;
    try {
      final discovered = await _transport!.connect(device.id);
      if (!_queue.isCurrent(token)) return;
      fields = discovered;
      model = identify(device.name, fields.map((f) => f.service));
      connected = true;
      if (model == DeviceModel.unknown) {
        status = L.s010;
        return;
      }
      await _serialized(() async {
        if (model.isQvap) {
          final f = _field(qCharacteristic, qService);
          if (f == null || !f.notify || (!f.write && !f.writeWithoutResponse)) {
            throw StateError(L.s011);
          }
          _subscriptions.add(
            _transport!.subscribe(f).listen((p) {
              if (!_queue.isCurrent(token) || p.isEmpty) return;
              final reply = _reply;
              if (reply != null &&
                  p[0] == _replyCommand &&
                  !reply.isCompleted) {
                reply.complete(p);
              }
            }, onError: (Object _) => _event(L.s012)),
          );
          // Only firmware query is permitted before proving application mode.
          await _exchange(QvapCodec.firmware());
          if (data['applicationMode'] != true) {
            throw StateError(L.s013);
          }
          await _exchange(QvapCodec.status());
          await _exchange(QvapCodec.settings());
          await _exchange(QvapCodec.info());
          await _exchange(QvapCodec.runtime());
        } else {
          await _readAttributes(all: true);
          if (model.isCrafty &&
              (craftyFirmware(data['firmware'] as String?)?.first ?? 0) >= 3) {
            model = DeviceModel.craftyPlus;
          }
          for (final f in fields.where((f) => f.notify && f.read)) {
            final prefix = f.id.substring(0, 8);
            if (!AttributeCodec.fields(model).contains(prefix)) continue;
            _subscriptions.add(
              _transport!.subscribe(f).listen((p) {
                if (_queue.isCurrent(token)) _decodeAttribute(f, p);
              }, onError: (Object _) => _event(L.s014)),
            );
          }
        }
      });
      if (!_queue.isCurrent(token)) return;
      if (!demo && model != DeviceModel.unknown) {
        final old = saved.where((d) => d.id == device.id).firstOrNull;
        saved.removeWhere((d) => d.id == device.id);
        saved.add(
          SavedDevice(
            id: device.id,
            name: device.name,
            model: model,
            nickname: old?.nickname ?? '',
          ),
        );
        await _persist();
      }
      status = demo ? L.s015 : L.s016;
      _event(demo ? L.s017 : L.s018);
      _poll = Timer.periodic(
        Duration(seconds: model.isQvap ? 1 : 2),
        (_) => unawaited(refresh()),
      );
    } catch (e) {
      if (_queue.isCurrent(token)) {
        error = '$e';
        await disconnect(message: L.s019);
      }
    } finally {
      if (_queue.isCurrent(token)) {
        connecting = false;
        _initializing = false;
      }
      notifyListeners();
    }
  }

  Future<void> _exchange(BleCommand command) async {
    _checkSession();
    if (command.bytes.first != 2 && data['applicationMode'] != true) {
      throw StateError(L.s020);
    }
    final token = _queue.generation;
    final waiter = Completer<List<int>>();
    _reply = waiter;
    _replyCommand = command.bytes.first;
    // Attach timeout listener before write, since a notification can arrive first.
    final response = waiter.future.timeout(const Duration(seconds: 5));
    // Always consume the response future, including when the OS write fails.
    unawaited(
      response.then<void>((_) {}, onError: (Object _, StackTrace __) {}),
    );
    try {
      await _write(command);
      final bytes = await response;
      if (!_queue.isCurrent(token)) throw StateError(L.s021);
      final decoded = QvapCodec.decode(bytes);
      if (bytes[0] == 6) data.remove('permanentBoost');
      data.addAll(decoded);
      if (decoded.containsKey('boostVisualizationBit')) {
        final bit = decoded['boostVisualizationBit'] == true;
        data['boostVisualization'] = model == DeviceModel.veazy ? !bit : bit;
      }
      if (bytes[0] == 1) lastStatus = DateTime.now();
    } finally {
      if (identical(_reply, waiter)) {
        _reply = null;
        _replyCommand = null;
      }
    }
  }

  Future<void> _write(BleCommand command) async {
    _checkSession();
    final f = _field(command.characteristic, command.service);
    if (f == null || (!f.write && !f.writeWithoutResponse)) {
      throw StateError(L.s022);
    }
    await _transport!
        .write(f, command.bytes)
        .timeout(const Duration(seconds: 5));
  }

  void _decodeAttribute(GattField field, List<int> p) {
    try {
      data.addAll(AttributeCodec.decode(model, field.id, p));
      if (['00000093', '1010000c'].contains(field.id.substring(0, 8))) {
        lastStatus = DateTime.now();
      }
      notifyListeners();
    } on FormatException {
      _event(L.s023);
    }
  }

  Future<void> _readAttributes({bool all = false}) async {
    _checkSession();
    final token = _queue.generation;
    final live = model.isCrafty
        ? [
            '00000021',
            '00000031',
            '00000011',
            '00000041',
            '00000093',
            '000001c3',
            '00000071',
          ]
        : ['10110003', '10110001', '1010000c', '1011000c'];
    for (final prefix in all ? AttributeCodec.fields(model) : live) {
      if (!_queue.isCurrent(token)) return;
      final f = _field(_id(prefix));
      if (f?.read != true) continue;
      try {
        final bytes = await _transport!
            .read(f!)
            .timeout(const Duration(seconds: 5));
        if (_queue.isCurrent(token)) _decodeAttribute(f, bytes);
      } on TimeoutException {
        rethrow;
      } catch (_) {
        _event(
          (L.italian
              ? "Caratteristica opzionale non leggibile: $prefix"
              : "Optionales Merkmal nicht lesbar: $prefix"),
        );
      }
    }
  }

  Future<void> refresh({bool analysis = false}) async {
    if (!connected ||
        connecting ||
        busy ||
        _polling ||
        model == DeviceModel.unknown) {
      return;
    }
    _polling = true;
    final token = _queue.generation;
    try {
      await _serialized(() async {
        if (model.isQvap) {
          await _exchange(QvapCodec.status());
          if (analysis) {
            await _exchange(QvapCodec.settings());
            await _exchange(QvapCodec.analysis());
          }
          if (++_pollCount % 30 == 0 || analysis) {
            await _exchange(QvapCodec.runtime());
          }
        } else {
          await _readAttributes(all: analysis);
        }
      });
      if (analysis) _event(L.s025);
    } catch (_) {
      if (_queue.isCurrent(token)) {
        error = L.s026;
        await disconnect(message: L.s027);
      }
    } finally {
      _polling = false;
      notifyListeners();
    }
  }

  Future<void> _control(
    String feature,
    Future<void> Function() action, {
    bool Function()? confirmed,
  }) async {
    if (!enabled(feature)) {
      error = L.s028;
      notifyListeners();
      return;
    }
    busy = true;
    error = '';
    notifyListeners();
    final token = _queue.generation;
    try {
      await _serialized(() async {
        // Recheck immediately before the operation, not just before queueing.
        if (!supports(feature) || !_queue.isCurrent(token)) {
          throw StateError(L.s029);
        }
        await action();
        if (!_queue.isCurrent(token)) return;
        if (model.isQvap) {
          await _exchange(QvapCodec.status());
          if (feature == 'brightness' ||
              feature == 'vibration' ||
              feature == 'permanentBoost' ||
              feature == 'factoryReset') {
            await _exchange(QvapCodec.settings());
          }
        } else {
          await _readAttributes(all: true);
        }
        if (!_queue.isCurrent(token)) return;
        if (confirmed != null && !confirmed()) {
          throw StateError(L.s030);
        }
      });
      if (_queue.isCurrent(token)) {
        _event(
          (L.italian
              ? "Stato confermato dopo il comando: $feature"
              : "Gerätestatus nach Befehl bestätigt: $feature"),
        );
      }
    } catch (_) {
      if (_queue.isCurrent(token)) {
        error = L.s032;
        await disconnect(message: L.s033);
      }
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> setTarget(int value) => _control('target', () async {
    within(value, 40, model.maxTemperature);
    if (model.isQvap) {
      await _exchange(QvapCodec.target(value));
    } else {
      await _write(AttributeCodec.target(model, value));
      if (model.isCrafty) {
        // Vendor client rewrites the boost after a target change.
        final offset = (data['boost'] as num).round();
        await _write(AttributeCodec.boost(model, offset));
      }
    }
  }, confirmed: () => (data['target'] as num?)?.round() == value);
  Future<void> setHeat(bool on) => _control(
    'heat',
    () => model.isQvap
        ? _exchange(QvapCodec.heat(on))
        : _write(AttributeCodec.heat(model, on)),
    confirmed: () => data['heater'] == on,
  );
  Future<void> setPump(bool on) => _control(
    'pump',
    () => _write(AttributeCodec.pump(on)),
    confirmed: () => data['pump'] == on,
  );
  Future<void> setBoost(int value, {bool superboost = false}) => _control(
    superboost ? 'superboost' : 'boost',
    () async {
      within(value, 1, 99);
      if (model.isQvap) {
        await _exchange(QvapCodec.boost(value, superboost: superboost));
      } else {
        if ((data['target'] as num? ?? 210) + value > 210) {
          throw RangeError(L.s034);
        }
        await _write(AttributeCodec.boost(model, value));
      }
    },
    confirmed: () => data[superboost ? 'superboost' : 'boost'] == value,
  );
  Future<void> setBrightness(int value) => _control(
    'brightness',
    () => model.isQvap
        ? _exchange(QvapCodec.brightness(value))
        : _write(AttributeCodec.brightness(model, value)),
    confirmed: () => data['brightness'] == value,
  );
  Future<void> setVibration(bool value) => _control('vibration', () async {
    if (model.isQvap) {
      await _exchange(QvapCodec.vibration(value));
      return;
    }
    int? register;
    if (model.isCrafty) {
      final f = _field(_id('000001c3'))!;
      register = uint16(
        await _transport!.read(f).timeout(const Duration(seconds: 5)),
      );
    }
    await _write(
      AttributeCodec.vibration(model, value, freshRegister: register),
    );
  }, confirmed: () => data['vibration'] == value);
  Future<void> setAutoOff(int seconds) => _control('autoOff', () async {
    // Entire code+value sequence occupies one queue slot.
    for (final command in AttributeCodec.autoOff(model, seconds)) {
      await _write(command);
    }
  }, confirmed: () => data['autoOff'] == seconds);
  Future<void> setEco(bool value, {bool voltage = false}) => _control(
    voltage ? 'chargeLimit' : 'ecoCharge',
    () => _exchange(QvapCodec.eco(value, voltage: voltage)),
    confirmed: () => data[voltage ? 'chargeLimit' : 'ecoCharge'] == value,
  );
  Future<void> setPermanentBoost(bool value) => _control(
    'permanentBoost',
    () => _exchange(QvapCodec.permanentBoost(value)),
    confirmed: () => data['permanentBoost'] == value,
  );
  Future<void> setBoostVisualization(bool value) => _control(
    'boostVisualization',
    () => _exchange(QvapCodec.boostVisualization(model, value)),
    confirmed: () => data['boostVisualization'] == value,
  );
  Future<void> factoryReset() async {
    await _control(
      'factoryReset',
      () => _exchange(QvapCodec.factoryReset()),
      confirmed: () => data['target'] == 180,
    );
    if (connected && error.isEmpty) {
      _event(L.s035);
    }
  }

  Future<void> setPermanentBluetooth(bool value) => _control(
    'permanentBluetooth',
    () => _exchange(QvapCodec.permanentBluetooth(model, value)),
    confirmed: () => data['permanentBluetooth'] == value,
  );

  Future<void> rename(String id, String nickname) async {
    saved = [
      for (final d in saved)
        if (d.id == id)
          SavedDevice(
            id: d.id,
            name: d.name,
            model: d.model,
            nickname: nickname.trim(),
          )
        else
          d,
    ];
    await _persist();
    notifyListeners();
  }

  Future<void> forget(String id) async {
    if (active?.id == id) await disconnect();
    saved.removeWhere((d) => d.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> reconnect(SavedDevice device) =>
      connect(NearbyDevice(device.id, device.name, 0, []));
  Future<void> disconnect({String message = L.s036}) async {
    _queue.invalidate();
    _poll?.cancel();
    _poll = null;
    connected = false;
    connecting = false;
    busy = false;
    _initializing = false;
    await stopScan();
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
    final pending = _reply;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(StateError(L.s037));
    }
    _reply = null;
    _replyCommand = null;
    await _transport?.disconnect();
    data.clear();
    fields = [];
    active = null;
    lastStatus = null;
    model = DeviceModel.unknown;
    status = message;
    notifyListeners();
  }

  String diagnosticReport() => const JsonEncoder.withIndent('  ').convert({
    'app': L.s038,
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'mode': demo ? 'simulation' : 'native',
    'model': model.label,
    'connected': connected,
    'hardwareValidated': false,
    'values': {
      for (final e in data.entries)
        if (e.key != 'serial') e.key: e.value,
    },
    'gatt': fields.map((f) => f.toJson()).toList(),
    'events': log,
    'privacy': L.s039,
  });
  Future<void> shutdown() async {
    await disconnect();
    await _link?.cancel();
    await _transport?.dispose();
  }

  @override
  void dispose() {
    _disposed = true;
    _poll?.cancel();
    _scanTimeout?.cancel();
    unawaited(shutdown());
    super.dispose();
  }
}
