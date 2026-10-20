import '../l10n/strings.dart';

enum DeviceModel { venty, veazy, crafty, craftyPlus, volcanoHybrid, unknown }

extension DeviceModelInfo on DeviceModel {
  String get label => switch (this) {
    DeviceModel.venty => 'VENTY',
    DeviceModel.veazy => 'VEAZY',
    DeviceModel.crafty => 'CRAFTY',
    DeviceModel.craftyPlus => 'CRAFTY+',
    DeviceModel.volcanoHybrid => 'VOLCANO HYBRID',
    DeviceModel.unknown => L.s344,
  };
  bool get isQvap => this == DeviceModel.venty || this == DeviceModel.veazy;
  bool get isCrafty =>
      this == DeviceModel.crafty || this == DeviceModel.craftyPlus;
  bool get hasBattery =>
      this != DeviceModel.volcanoHybrid && this != DeviceModel.unknown;
  int get maxTemperature => this == DeviceModel.volcanoHybrid ? 230 : 210;
}

class NearbyDevice {
  const NearbyDevice(this.id, this.name, this.rssi, this.services);
  final String id, name;
  final int rssi;
  final List<String> services;
}

class GattField {
  const GattField(
    this.service,
    this.id, {
    this.read = false,
    this.write = false,
    this.writeWithoutResponse = false,
    this.notify = false,
  });
  final String service, id;
  final bool read, write, writeWithoutResponse, notify;
  String get key => '$service/$id';
  Map<String, Object> toJson() => {
    'service': service,
    'characteristic': id,
    'read': read,
    'write': write,
    'writeWithoutResponse': writeWithoutResponse,
    'notify': notify,
  };
}

class BleCommand {
  BleCommand(this.service, this.characteristic, List<int> bytes, this.evidence)
    : bytes = List.unmodifiable(bytes);
  final String service, characteristic, evidence;
  final List<int> bytes;
}

class SavedDevice {
  const SavedDevice({
    required this.id,
    required this.name,
    required this.model,
    this.nickname = '',
  });
  final String id, name, nickname;
  final DeviceModel model;
  String get displayName => nickname.isEmpty ? model.label : nickname;
  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'model': model.name,
    'nickname': nickname,
  };
  static SavedDevice fromJson(Map<String, dynamic> value) => SavedDevice(
    id: value['id'] as String,
    name: value['name'] as String,
    model: DeviceModel.values.firstWhere(
      (m) => m.name == value['model'],
      orElse: () => DeviceModel.unknown,
    ),
    nickname: value['nickname'] as String? ?? '',
  );
}
