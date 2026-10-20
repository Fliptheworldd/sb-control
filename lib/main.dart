import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app/controller.dart';
import 'ui/app.dart';
import 'app/preferences.dart';
import 'care/controller.dart';
import 'care/reminders.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  await controller.initialize(
    startDemo: kIsWeb || const bool.fromEnvironment('SB_DEMO'),
  );
  final care = CareController(
    preferences: LocalPreferences(
      key: kIsWeb ? 'sb-control.care.demo.v1' : 'sb-control.care.v1',
    ),
    reminders: NativeCareReminders(),
  );
  await care.initialize();
  runApp(SbControlApp(controller: controller, care: care));
}
