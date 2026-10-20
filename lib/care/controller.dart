import 'package:flutter/foundation.dart';
import '../app/preferences.dart';
import '../core/models.dart';
import 'guides.dart';
import 'reminders.dart';

class CarePlan {
  const CarePlan({
    required this.startedAt,
    this.cleanedAt,
    this.remind = false,
  });
  final DateTime startedAt;
  final DateTime? cleanedAt;
  final bool remind;
  DateTime get anchor => cleanedAt ?? startedAt;
  DateTime get dueAt {
    final local = anchor.toLocal();
    // An automatic daytime check, not an exact sanitation deadline.
    return DateTime(local.year, local.month, local.day + 7, 18);
  }

  CarePlan withReminder(bool value) =>
      CarePlan(startedAt: startedAt, cleanedAt: cleanedAt, remind: value);
  CarePlan cleaned(DateTime now) =>
      CarePlan(startedAt: startedAt, cleanedAt: now, remind: remind);
  Map<String, dynamic> toJson() => {
    'started': startedAt.toUtc().toIso8601String(),
    'cleaned': cleanedAt?.toUtc().toIso8601String(),
    'remind': remind,
  };
  static CarePlan? fromJson(Object? value) {
    if (value is! Map || value['started'] is! String) return null;
    final started = DateTime.tryParse(value['started'] as String);
    final cleanedValue = value['cleaned'];
    final cleaned = cleanedValue is String
        ? DateTime.tryParse(cleanedValue)
        : null;
    if (started == null || (cleanedValue != null && cleaned == null)) {
      return null;
    }
    return CarePlan(
      startedAt: started,
      cleanedAt: cleaned,
      remind: value['remind'] == true,
    );
  }
}

class CareController extends ChangeNotifier {
  CareController({
    required Preferences preferences,
    CareReminders? reminders,
    DateTime Function()? clock,
  }) : _preferences = preferences,
       _reminders = reminders ?? NoCareReminders(),
       _clock = clock ?? DateTime.now;
  final Preferences _preferences;
  final CareReminders _reminders;
  final DateTime Function() _clock;
  final Map<DeviceModel, CarePlan> plans = {};
  bool notificationsEnabled = false, busy = false, _disposed = false;
  ReminderAccess permission = ReminderAccess.unavailable;
  String error = '';
  DeviceModel? openModel;
  Future<void> _pending = Future.value();
  bool get supportsNotifications => _reminders.supported;
  DateTime get now => _clock();
  int get enabledCount => plans.values.where((p) => p.remind).length;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> initialize() async {
    try {
      final saved = await _preferences.load();
      notificationsEnabled = saved['notifications'] == true;
      final raw = saved['plans'];
      if (raw is Map) {
        for (final model in careModels) {
          final plan = CarePlan.fromJson(raw[model.name]);
          if (plan != null &&
              !plan.anchor.isAfter(now.add(const Duration(days: 1)))) {
            plans[model] = plan;
          }
        }
      }
      final initial = await _reminders.initialize((model) {
        openModel = model;
        notifyListeners();
      });
      if (initial != null) openModel = initial;
      await _sync();
    } catch (_) {
      error =
          'Pflege-Erinnerungen konnten nicht geladen werden. Bitte erneut versuchen.';
    }
    notifyListeners();
  }

  DeviceModel? consumeOpenModel() {
    final model = openModel;
    openModel = null;
    return model;
  }

  Future<void> _persist() => _preferences.save({
    'notifications': notificationsEnabled,
    'plans': {
      for (final entry in plans.entries) entry.key.name: entry.value.toJson(),
    },
  });

  Future<void> _sync({bool request = false}) async {
    await _reminders.cancelAll();
    permission = await _reminders.access(
      request: request && notificationsEnabled,
    );
    if (!notificationsEnabled || permission != ReminderAccess.allowed) return;
    for (final entry in plans.entries) {
      if (entry.value.remind && entry.value.dueAt.isAfter(now)) {
        await _reminders.schedule(entry.key, entry.value.dueAt);
      }
    }
    // Overdue checks stay visible in the app; opening it never creates a new alert storm.
  }

  Future<void> _run(Future<void> Function() action) {
    final future = _pending.then((_) async {
      if (_disposed) return;
      busy = true;
      error = '';
      notifyListeners();
      try {
        await action();
      } catch (_) {
        error =
            'Änderung nicht vollständig gespeichert oder Erinnerung nicht geplant. Bitte erneut versuchen.';
      } finally {
        busy = false;
        notifyListeners();
      }
    });
    _pending = future;
    return future;
  }

  Future<void> setReminder(DeviceModel model, bool enabled) => _run(() async {
    if (!careModels.contains(model)) return;
    final old = plans[model];
    final oldMaster = notificationsEnabled;
    plans[model] = (old ?? CarePlan(startedAt: now)).withReminder(enabled);
    if (enabled) notificationsEnabled = true;
    try {
      await _persist();
    } catch (_) {
      if (old == null) {
        plans.remove(model);
      } else {
        plans[model] = old;
      }
      notificationsEnabled = oldMaster;
      rethrow;
    }
    await _sync(request: enabled);
  });

  Future<void> setNotifications(bool enabled) => _run(() async {
    final old = notificationsEnabled;
    notificationsEnabled = enabled;
    if (!enabled) await _reminders.cancelAll();
    try {
      await _persist();
    } catch (_) {
      notificationsEnabled = old;
      rethrow;
    }
    await _sync(request: enabled);
  });

  Future<void> markCleaned(DeviceModel model) => _run(() async {
    if (!careModels.contains(model)) return;
    final old = plans[model];
    plans[model] = (old ?? CarePlan(startedAt: now)).cleaned(now);
    try {
      await _persist();
    } catch (_) {
      if (old == null) {
        plans.remove(model);
      } else {
        plans[model] = old;
      }
      rethrow;
    }
    await _sync();
  });

  Future<void> refreshPermission() => _run(() => _sync());

  Future<void> testReminder(DeviceModel model) => _run(() async {
    if (!notificationsEnabled || !supportsNotifications) return;
    permission = await _reminders.access(request: true);
    if (permission == ReminderAccess.allowed) {
      await _reminders.schedule(
        model,
        now.add(const Duration(seconds: 10)),
        test: true,
      );
    }
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
