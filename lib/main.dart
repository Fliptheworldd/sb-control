import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app/controller.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  await controller.initialize(
    startDemo: kIsWeb || const bool.fromEnvironment('SB_DEMO'),
  );
  runApp(SbControlApp(controller: controller));
}
