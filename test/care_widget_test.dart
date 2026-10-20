import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sb_control/app/preferences.dart';
import 'package:sb_control/care/controller.dart';
import 'package:sb_control/care/guides.dart';
import 'package:sb_control/care/screen.dart';
import 'package:sb_control/core/models.dart';

Widget host(CareController controller, CareGuide guide, {double scale = 1}) =>
    MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) =>
                      CareWizard(guide: guide, controller: controller),
                ),
              ),
              child: const Text('Anleitung öffnen'),
            ),
          ),
        ),
      ),
    );

void main() {
  for (final model in careModels) {
    testWidgets(
      '${model.label}: illustrated steps fit 320px and save only after confirmation',
      (tester) async {
        tester.view.physicalSize = const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final now = DateTime(2026, 10, 20, 12);
        final c = CareController(
          preferences: MemoryPreferences(),
          clock: () => now,
        );
        await c.initialize();
        final guide = guideFor(model);
        await tester.pumpWidget(
          host(c, guide, scale: model == DeviceModel.venty ? 1.5 : 1),
        );
        await tester.tap(find.text('Anleitung öffnen'));
        await tester.pumpAndSettle();
        expect(find.text('Das brauchst du'), findsOneWidget);
        await tester.tap(find.text('Los geht’s'));
        await tester.pumpAndSettle();
        for (var i = 0; i < guide.steps.length; i++) {
          expect(find.text(guide.steps[i].title), findsOneWidget);
          expect(
            tester.takeException(),
            isNull,
            reason: '${model.label}: step $i',
          );
          await tester.tap(find.text('Weiter'));
          await tester.pumpAndSettle();
        }
        final save = find.widgetWithText(FilledButton, 'Reinigung speichern');
        expect(tester.widget<FilledButton>(save).onPressed, isNull);
        expect(c.plans[model], isNull);
        final checkbox = find.byType(CheckboxListTile);
        await tester.ensureVisible(checkbox);
        await tester.pumpAndSettle();
        await tester.tap(checkbox);
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(find.text('Anleitung öffnen'), findsOneWidget);
        expect(c.plans[model]!.cleanedAt, now);
        expect(
          c.notificationsEnabled,
          false,
          reason: 'cleaning is not notification opt-in',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        c.dispose();
      },
    );
  }

  testWidgets('leaving a guide does not reset care history', (tester) async {
    final c = CareController(preferences: MemoryPreferences());
    await c.initialize();
    await tester.pumpWidget(host(c, guideFor(DeviceModel.venty)));
    await tester.tap(find.text('Anleitung öffnen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Los geht’s'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    expect(find.text('Das brauchst du'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(c.plans, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    c.dispose();
  });
}
