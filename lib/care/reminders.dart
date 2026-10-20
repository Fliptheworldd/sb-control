import '../l10n/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../core/models.dart';
import 'guides.dart';

enum ReminderAccess { allowed, blocked, unavailable }

abstract interface class CareReminders {
  bool get supported;
  Future<DeviceModel?> initialize(void Function(DeviceModel) onOpen);
  Future<ReminderAccess> access({bool request = false});
  Future<void> schedule(DeviceModel model, DateTime when, {bool test = false});
  Future<void> cancelAll();
}

class NoCareReminders implements CareReminders {
  @override
  bool get supported => false;
  @override
  Future<DeviceModel?> initialize(void Function(DeviceModel) onOpen) async =>
      null;
  @override
  Future<ReminderAccess> access({bool request = false}) async =>
      ReminderAccess.unavailable;
  @override
  Future<void> schedule(
    DeviceModel model,
    DateTime when, {
    bool test = false,
  }) async {}
  @override
  Future<void> cancelAll() async {}
}

class NativeCareReminders implements CareReminders {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  @override
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  static DeviceModel? parsePayload(String? payload) {
    for (final model in careModels) {
      if (payload == 'care:${model.name}') return model;
    }
    return null;
  }

  @override
  Future<DeviceModel?> initialize(void Function(DeviceModel) onOpen) async {
    if (!supported) return null;
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_care_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final model = parsePayload(response.payload);
        if (model != null) onOpen(model);
      },
    );
    _ready = true;
    final launch = await _plugin.getNotificationAppLaunchDetails();
    return launch?.didNotificationLaunchApp == true
        ? parsePayload(launch?.notificationResponse?.payload)
        : null;
  }

  @override
  Future<ReminderAccess> access({bool request = false}) async {
    if (!supported || !_ready) return ReminderAccess.unavailable;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!;
      if (request) await android.requestNotificationsPermission();
      return await android.areNotificationsEnabled() == true
          ? ReminderAccess.allowed
          : ReminderAccess.blocked;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()!;
    if (request) {
      await ios.requestPermissions(alert: true, badge: false, sound: true);
    }
    final settings = await ios.checkPermissions();
    return settings?.isEnabled == true
        ? ReminderAccess.allowed
        : ReminderAccess.blocked;
  }

  @override
  Future<void> schedule(
    DeviceModel model,
    DateTime when, {
    bool test = false,
  }) async {
    if (!_ready || !supported) return;
    await _plugin.zonedSchedule(
      (test ? 7200 : 7100) + careModels.indexOf(model),
      test
          ? L.s293
          : (L.italian
                ? "${model.label}: controllo di pulizia"
                : "${model.label}: Zeit für den Pflegecheck"),
      test
          ? L.s295
          : model == DeviceModel.volcanoHybrid
          ? L.s296
          : L.s297,
      tz.TZDateTime.from(when.toUtc(), tz.UTC),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sb_care_v1',
          L.s298,
          channelDescription: L.s299,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: 'ic_care_notification',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
        ),
      ),
      // A maintenance reminder does not need restricted exact-alarm permission.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'care:${model.name}',
    );
  }

  @override
  Future<void> cancelAll() async {
    if (!supported || !_ready) return;
    // Only our own IDs, so future unrelated notifications remain untouched.
    for (var i = 0; i < careModels.length; i++) {
      await _plugin.cancel(7100 + i);
      await _plugin.cancel(7200 + i);
    }
  }
}
