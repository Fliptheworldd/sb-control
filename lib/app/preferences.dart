import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class Preferences {
  Future<Map<String, dynamic>> load();
  Future<void> save(Map<String, dynamic> value);
}

class LocalPreferences implements Preferences {
  LocalPreferences({this.key = 'sb-control.v3'});
  final String key;
  @override
  Future<Map<String, dynamic>> load() async {
    final p = await SharedPreferences.getInstance();
    final value = p.getString(key);
    if (value == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(value) as Map);
    } on FormatException {
      return {};
    }
  }

  @override
  Future<void> save(Map<String, dynamic> value) async {
    final p = await SharedPreferences.getInstance();
    if (!await p.setString(key, jsonEncode(value))) {
      throw StateError('Einstellungen konnten nicht gespeichert werden.');
    }
  }
}

class MemoryPreferences implements Preferences {
  Map<String, dynamic> value = {};
  @override
  Future<Map<String, dynamic>> load() async => value;
  @override
  Future<void> save(Map<String, dynamic> value) async {
    this.value = value;
  }
}
