import '../core/models.dart';
import 'transport.dart';

BleTransport createNativeTransport() => UnsupportedTransport();

class UnsupportedTransport implements BleTransport {
  static const message =
      'Echtes Bluetooth ist in dieser Vorschau nicht verfügbar. Nutze die native iOS- oder Android-App.';
  @override
  Stream<bool> get connection => const Stream.empty();
  @override
  Stream<NearbyDevice> scan() => Stream.error(UnsupportedError(message));
  @override
  Future<List<GattField>> connect(String id) async =>
      throw UnsupportedError(message);
  @override
  Future<void> disconnect() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<List<int>> read(GattField field) async =>
      throw UnsupportedError(message);
  @override
  Stream<List<int>> subscribe(GattField field) => const Stream.empty();
  @override
  Future<void> write(GattField field, List<int> bytes) async =>
      throw UnsupportedError(message);
}
