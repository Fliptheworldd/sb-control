import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sb_control/app/controller.dart';
import 'package:sb_control/app/preferences.dart';
import 'package:sb_control/bluetooth/demo_transport.dart';
import 'package:sb_control/l10n/strings.dart';
import 'package:sb_control/ui/app.dart';

void main() {
  testWidgets('Matteo header is exclusive to opted-in Italian Android', (
    tester,
  ) async {
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final c = AppController(
      preferences: MemoryPreferences(),
      nativeFactory: DemoTransport.new,
    );
    await c.initialize();
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      debugDefaultTargetPlatformOverride = platform;
      await tester.pumpWidget(
        SbControlApp(key: ValueKey(platform), controller: c),
      );
      await tester.pumpAndSettle();
      final expected =
          platform == TargetPlatform.android &&
          L.italian &&
          const bool.fromEnvironment('SB_MATTEO');
      expect(
        find.text('Il Vape Club di Matteo'),
        expected ? findsOneWidget : findsNothing,
      );
      expect(find.text(L.s065), findsNothing, reason: 'No native demo entry');
      await tester.tap(find.text(L.s334).last);
      await tester.pumpAndSettle();
      expect(find.text(L.s322), findsNothing, reason: 'No native demo switch');
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(c.shutdown);
    c.dispose();
    debugDefaultTargetPlatformOverride = null;
  });
}
