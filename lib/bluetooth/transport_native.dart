import '../l10n/strings.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../core/models.dart';
import 'transport.dart';

BleTransport createNativeTransport() => NativeTransport();

class NativeTransport implements BleTransport {
  FlutterReactiveBle? _client;
  // Constructing the plugin starts native adapter observation. Do it only
  // after an explicit scan/connect action, never just by opening the app.
  FlutterReactiveBle get _ble => _client ??= FlutterReactiveBle();
  final _connection = StreamController<bool>.broadcast();
  StreamSubscription<ConnectionStateUpdate>? _link;
  String? _id;
  @override
  Stream<bool> get connection => _connection.stream;

  Future<void> _prepare() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError(L.s303);
    }
    if (Platform.isAndroid) {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      final permissions = sdk >= 31
          ? [Permission.bluetoothScan, Permission.bluetoothConnect]
          : [Permission.locationWhenInUse];
      final states = await permissions.request();
      if (states.values.any((s) => !s.isGranted)) {
        throw StateError(L.s304);
      }
    }
    await _ble.initialize();
    final state = _ble.status == BleStatus.unknown
        ? await _ble.statusStream
              .firstWhere((s) => s != BleStatus.unknown)
              .timeout(const Duration(seconds: 8))
        : _ble.status;
    if (state != BleStatus.ready) {
      throw StateError(switch (state) {
        BleStatus.poweredOff => L.s305,
        BleStatus.unauthorized => L.s306,
        BleStatus.locationServicesDisabled => L.s307,
        _ =>
          (L.italian
              ? "Bluetooth non disponibile: ${state.name}"
              : "Bluetooth ist nicht verfügbar: ${state.name}"),
      });
    }
  }

  @override
  Stream<NearbyDevice> scan() async* {
    await _prepare();
    // Different firmware advertises different services. Filter after discovery.
    yield* _ble
        .scanForDevices(withServices: [], scanMode: ScanMode.lowLatency)
        .map(
          (d) => NearbyDevice(
            d.id,
            d.name,
            d.rssi,
            d.serviceUuids.map((u) => u.toString().toLowerCase()).toList(),
          ),
        );
  }

  @override
  Future<List<GattField>> connect(String id) async {
    await disconnect();
    await _prepare();
    final ready = Completer<void>();
    _id = id;
    _link = _ble
        .connectToDevice(id: id, connectionTimeout: const Duration(seconds: 15))
        .listen(
          (event) {
            if (event.connectionState == DeviceConnectionState.connected) {
              if (!ready.isCompleted) ready.complete();
              _connection.add(true);
            } else if (event.connectionState ==
                DeviceConnectionState.disconnected) {
              if (!ready.isCompleted) {
                ready.completeError(StateError(L.s037));
              }
              _connection.add(false);
            }
          },
          onError: (Object e) {
            if (!ready.isCompleted) ready.completeError(e);
            _connection.add(false);
          },
        );
    try {
      await ready.future.timeout(const Duration(seconds: 18));
      await _ble.discoverAllServices(id).timeout(const Duration(seconds: 15));
      final services = await _ble
          .getDiscoveredServices(id)
          .timeout(const Duration(seconds: 5));
      return [
        for (final s in services)
          for (final c in s.characteristics)
            GattField(
              s.id.toString().toLowerCase(),
              c.id.toString().toLowerCase(),
              read: c.isReadable,
              write: c.isWritableWithResponse,
              writeWithoutResponse: c.isWritableWithoutResponse,
              notify: c.isNotifiable || c.isIndicatable,
            ),
      ];
    } catch (_) {
      await disconnect();
      rethrow;
    }
  }

  QualifiedCharacteristic _qualified(GattField field) {
    final id = _id;
    if (id == null) throw StateError(L.s309);
    return QualifiedCharacteristic(
      deviceId: id,
      serviceId: Uuid.parse(field.service),
      characteristicId: Uuid.parse(field.id),
    );
  }

  @override
  Future<List<int>> read(GattField field) =>
      _ble.readCharacteristic(_qualified(field));
  @override
  Future<void> write(GattField field, List<int> bytes) {
    if (field.write) {
      return _ble.writeCharacteristicWithResponse(
        _qualified(field),
        value: bytes,
      );
    }
    if (field.writeWithoutResponse) {
      return _ble.writeCharacteristicWithoutResponse(
        _qualified(field),
        value: bytes,
      );
    }
    throw StateError(L.s310);
  }

  @override
  Stream<List<int>> subscribe(GattField field) =>
      _ble.subscribeToCharacteristic(_qualified(field));
  @override
  Future<void> disconnect() async {
    _id = null;
    await _link?.cancel();
    _link = null;
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _connection.close();
  }
}
