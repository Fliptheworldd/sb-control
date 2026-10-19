import '../core/models.dart';

abstract interface class BleTransport {
  Stream<bool> get connection;
  Stream<NearbyDevice> scan();
  Future<List<GattField>> connect(String id);
  Future<void> disconnect();
  Future<List<int>> read(GattField field);
  Future<void> write(GattField field, List<int> bytes);
  Stream<List<int>> subscribe(GattField field);
  Future<void> dispose();
}
