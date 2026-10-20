import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sb_control/app/preferences.dart';
import 'package:sb_control/care/controller.dart';
import 'package:sb_control/care/reminders.dart';
import 'package:sb_control/core/models.dart';

class RecordingReminders implements CareReminders {
  @override
  bool supported = true;
  ReminderAccess permission = ReminderAccess.allowed;
  int requests = 0;
  final scheduled = <DeviceModel, DateTime>{};
  final tests = <DeviceModel, DateTime>{};
  DeviceModel? launch;
  void Function(DeviceModel)? open;
  Completer<void>? scheduleStarted, scheduleGate;
  @override
  Future<DeviceModel?> initialize(void Function(DeviceModel) onOpen) async {
    open = onOpen;
    return launch;
  }

  @override
  Future<ReminderAccess> access({bool request = false}) async {
    if (request) requests++;
    return permission;
  }

  @override
  Future<void> cancelAll() async {
    scheduled.clear();
    tests.clear();
  }

  @override
  Future<void> schedule(
    DeviceModel model,
    DateTime when, {
    bool test = false,
  }) async {
    if (scheduleStarted != null && !scheduleStarted!.isCompleted) {
      scheduleStarted!.complete();
    }
    await scheduleGate?.future;
    (test ? tests : scheduled)[model] = when;
  }
}

class FailingPreferences extends MemoryPreferences {
  bool fail = false;
  @override
  Future<void> save(Map<String, dynamic> value) async {
    if (fail) throw StateError('storage unavailable');
    await super.save(value);
  }
}

void main() {
  final start = DateTime(2026, 10, 20, 12);
  test(
    'opt-in, cleaning, restart and disabling preserve the right schedule',
    () async {
      var now = start;
      final prefs = MemoryPreferences();
      final reminders = RecordingReminders();
      final c = CareController(
        preferences: prefs,
        reminders: reminders,
        clock: () => now,
      );
      await c.initialize();
      expect(reminders.requests, 0);
      expect(reminders.scheduled, isEmpty);
      await c.setReminder(DeviceModel.venty, true);
      expect(reminders.requests, 1);
      expect(
        reminders.scheduled[DeviceModel.venty],
        DateTime(2026, 10, 27, 18),
      );
      now = DateTime(2026, 10, 23, 10);
      await c.markCleaned(DeviceModel.venty);
      expect(c.plans[DeviceModel.venty]!.cleanedAt, now);
      expect(
        reminders.scheduled[DeviceModel.venty],
        DateTime(2026, 10, 30, 18),
      );
      expect(
        reminders.requests,
        1,
        reason: 'saving cleaning must not request permission',
      );
      c.dispose();

      final reloaded = CareController(
        preferences: prefs,
        reminders: reminders,
        clock: () => now,
      );
      await reloaded.initialize();
      expect(reloaded.plans[DeviceModel.venty]!.cleanedAt, now.toUtc());
      expect(reminders.scheduled.length, 1);
      await reloaded.testReminder(DeviceModel.venty);
      expect(reminders.tests.length, 1);
      await reloaded.setNotifications(false);
      expect(reminders.scheduled, isEmpty);
      expect(reminders.tests, isEmpty);
      expect(reloaded.plans[DeviceModel.venty]!.remind, true);
      await reloaded.setNotifications(true);
      expect(reminders.scheduled.length, 1);
      await reloaded.setReminder(DeviceModel.venty, false);
      expect(reminders.scheduled, isEmpty);
      reloaded.dispose();
    },
  );

  test(
    'denied permission keeps care history; OS changes sync without a new prompt',
    () async {
      final r = RecordingReminders()..permission = ReminderAccess.blocked;
      final c = CareController(
        preferences: MemoryPreferences(),
        reminders: r,
        clock: () => start,
      );
      await c.initialize();
      await c.setReminder(DeviceModel.veazy, true);
      expect(c.permission, ReminderAccess.blocked);
      expect(r.scheduled, isEmpty);
      await c.markCleaned(DeviceModel.veazy);
      expect(c.plans[DeviceModel.veazy]!.cleanedAt, start);
      r.permission = ReminderAccess.allowed;
      await c.refreshPermission();
      expect(r.requests, 1);
      expect(r.scheduled.keys, [DeviceModel.veazy]);
      r.permission = ReminderAccess.blocked;
      await c.refreshPermission();
      expect(r.scheduled, isEmpty);
      c.dispose();
    },
  );

  test(
    'overdue check stays visible without creating repeat alerts on reopen',
    () async {
      var now = start;
      final r = RecordingReminders();
      final c = CareController(
        preferences: MemoryPreferences(),
        reminders: r,
        clock: () => now,
      );
      await c.initialize();
      await c.setReminder(DeviceModel.venty, true);
      now = start.add(const Duration(days: 20));
      await c.refreshPermission();
      await c.refreshPermission();
      expect(r.scheduled, isEmpty);
      expect(c.plans[DeviceModel.venty]!.dueAt.isBefore(now), true);
      await c.markCleaned(DeviceModel.venty);
      expect(r.scheduled[DeviceModel.venty]!.isAfter(now), true);
      c.dispose();
    },
  );

  test('late native scheduling cannot override a subsequent disable', () async {
    final r = RecordingReminders()
      ..scheduleStarted = Completer<void>()
      ..scheduleGate = Completer<void>();
    final c = CareController(
      preferences: MemoryPreferences(),
      reminders: r,
      clock: () => start,
    );
    await c.initialize();
    final enabling = c.setReminder(DeviceModel.venty, true);
    await r.scheduleStarted!.future;
    final disabling = c.setNotifications(false);
    r.scheduleGate!.complete();
    await Future.wait([enabling, disabling]);
    expect(c.notificationsEnabled, false);
    expect(r.scheduled, isEmpty);
    expect(c.busy, false);
    c.dispose();
  });

  test(
    'failed storage does not claim a cleaning or change its due date',
    () async {
      var now = start;
      final prefs = FailingPreferences();
      final r = RecordingReminders();
      final c = CareController(
        preferences: prefs,
        reminders: r,
        clock: () => now,
      );
      await c.initialize();
      await c.setReminder(DeviceModel.venty, true);
      final due = c.plans[DeviceModel.venty]!.dueAt;
      prefs.fail = true;
      now = start.add(const Duration(days: 3));
      await c.markCleaned(DeviceModel.venty);
      expect(c.error, isNotEmpty);
      expect(c.plans[DeviceModel.venty]!.cleanedAt, isNull);
      expect(c.plans[DeviceModel.venty]!.dueAt, due);
      expect(r.scheduled[DeviceModel.venty], due);
      c.dispose();
    },
  );

  test('offline/web history works without notification capabilities', () async {
    final prefs = MemoryPreferences();
    final c = CareController(preferences: prefs, clock: () => start);
    await c.initialize();
    await c.markCleaned(DeviceModel.craftyPlus);
    await c.setReminder(DeviceModel.craftyPlus, true);
    expect(c.supportsNotifications, false);
    expect(c.permission, ReminderAccess.unavailable);
    expect(c.error, isEmpty);
    expect((prefs.value['plans'] as Map).containsKey('craftyPlus'), true);
    c.dispose();
  });

  test(
    'malformed history and unknown notification payloads are ignored',
    () async {
      final prefs = MemoryPreferences()
        ..value = {
          'plans': {
            'venty': {'started': 'broken'},
            'veazy': {
              'started': start.add(const Duration(days: 30)).toIso8601String(),
            },
            'crafty': {'started': start.toIso8601String(), 'cleaned': 123},
            'unknown': {'started': start.toIso8601String(), 'remind': true},
          },
        };
      final c = CareController(preferences: prefs, clock: () => start);
      await c.initialize();
      expect(c.plans, isEmpty);
      await c.setReminder(DeviceModel.unknown, true);
      expect(c.plans, isEmpty);
      expect(NativeCareReminders.parsePayload(null), isNull);
      expect(NativeCareReminders.parsePayload('care:unknown'), isNull);
      expect(NativeCareReminders.parsePayload('https://example.com'), isNull);
      expect(
        NativeCareReminders.parsePayload('care:volcanoHybrid'),
        DeviceModel.volcanoHybrid,
      );
      c.dispose();
    },
  );

  test(
    'cold and warm notification taps select the corresponding guide once',
    () async {
      final r = RecordingReminders()..launch = DeviceModel.crafty;
      final c = CareController(preferences: MemoryPreferences(), reminders: r);
      await c.initialize();
      expect(c.consumeOpenModel(), DeviceModel.crafty);
      expect(c.consumeOpenModel(), isNull);
      r.open!(DeviceModel.volcanoHybrid);
      expect(c.consumeOpenModel(), DeviceModel.volcanoHybrid);
      c.dispose();
    },
  );
}
