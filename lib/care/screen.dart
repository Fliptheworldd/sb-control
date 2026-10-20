import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/models.dart';
import 'controller.dart';
import 'guides.dart';
import 'illustration.dart';
import 'reminders.dart';

const _accent = Color(0xFFFF7A28), _muted = Color(0xFFA7ABB3);
String careDate(DateTime value) {
  final d = value.toLocal();
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class CareScreen extends StatefulWidget {
  const CareScreen({
    super.key,
    required this.controller,
    this.initialModel = DeviceModel.venty,
  });
  final CareController controller;
  final DeviceModel initialModel;
  @override
  State<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends State<CareScreen> {
  late DeviceModel model;
  CareController get c => widget.controller;
  @override
  void initState() {
    super.initState();
    model = careModels.contains(widget.initialModel)
        ? widget.initialModel
        : DeviceModel.venty;
  }

  @override
  void didUpdateWidget(covariant CareScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialModel != widget.initialModel &&
        careModels.contains(widget.initialModel)) {
      model = widget.initialModel;
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (context, _) {
      final guide = guideFor(model), plan = c.plans[model];
      final overdue = plan != null && !plan.dueAt.isAfter(c.now);
      return ListView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        children: [
          const Text(
            'PFLEGE',
            style: TextStyle(
              color: _accent,
              letterSpacing: 2,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sauber. Startklar.',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dein Gerät. Eine Anleitung, Schritt für Schritt.',
            style: TextStyle(color: _muted),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<DeviceModel>(
            initialValue: model,
            key: ValueKey('care-model-${model.name}'),
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Gerät auswählen',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            items: [
              for (final m in careModels)
                DropdownMenuItem(value: m, child: Text(m.label)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => model = value);
            },
          ),
          const SizedBox(height: 18),
          CareIllustration(model: model, art: CareArt.tools),
          const SizedBox(height: 18),
          _card([
            Row(
              children: [
                Icon(
                  overdue
                      ? Icons.cleaning_services_rounded
                      : Icons.spa_outlined,
                  color: _accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    overdue ? 'Zeit für deinen Pflegecheck' : 'Pflege im Blick',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              plan?.cleanedAt == null
                  ? 'Noch keine Reinigung gespeichert.'
                  : 'Zuletzt gereinigt: ${careDate(plan!.cleanedAt!)}',
            ),
            if (plan != null) ...[
              const SizedBox(height: 6),
              Text(
                'Nächster Pflegecheck: ${careDate(plan.dueAt)}',
                style: const TextStyle(color: _muted),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              guide.manufacturerAdvice,
              style: const TextStyle(color: _muted, height: 1.5),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final saved = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => CareWizard(guide: guide, controller: c),
                    ),
                  );
                  if (context.mounted && saved == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Reinigung gespeichert. Dein Pflegecheck beginnt neu.',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Bildanleitung starten'),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showSources(context, guide),
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: const Text('Herstellerangaben ansehen'),
            ),
          ]),
          const SizedBox(height: 16),
          _card([
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'An Reinigung erinnern',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Wöchentlicher Pflegecheck für ${model.label}. Direkt von SB CONTROL.',
              ),
              value: plan?.remind == true,
              onChanged: c.busy ? null : (value) => c.setReminder(model, value),
            ),
            const Text(
              'Kein Kalender, keine Zeiteinstellung. Bei sichtbaren Ablagerungen früher reinigen. Die App misst keinen Verschmutzungsgrad und zählt keine Köpfe.',
              style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
            ),
            if (plan?.remind == true && !c.notificationsEnabled)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Benachrichtigungen sind in den Optionen ausgeschaltet.',
                  style: TextStyle(color: _accent),
                ),
              ),
            _permissionNotice(c),
          ]),
          if (c.error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                c.error,
                style: const TextStyle(color: Color(0xFFFFB690)),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'Ein Pflegeplan je Modell. Die Anleitung funktioniert auch ohne Bluetooth-Verbindung.',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
          ),
        ],
      );
    },
  );
}

Widget _card(List<Widget> children) => Card(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  ),
);

Widget _permissionNotice(CareController c) {
  if (!c.supportsNotifications) {
    return const Padding(
      padding: EdgeInsets.only(top: 12),
      child: Text(
        'Vorschau: Der Pflegeplan lässt sich ausprobieren. System-Benachrichtigungen gibt es in der iPhone- und Android-App.',
        style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
      ),
    );
  }
  if (c.notificationsEnabled && c.permission == ReminderAccess.blocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mitteilungen sind im System nicht erlaubt. Der Pflegecheck bleibt in der App sichtbar.',
          style: TextStyle(color: Color(0xFFFFB690), fontSize: 12),
        ),
        TextButton(
          onPressed: openAppSettings,
          child: const Text('Systemeinstellungen öffnen'),
        ),
      ],
    );
  }
  if (c.notificationsEnabled && c.permission == ReminderAccess.unavailable) {
    return const Text(
      'Benachrichtigungen momentan nicht verfügbar.',
      style: TextStyle(color: _muted),
    );
  }
  return const SizedBox.shrink();
}

class CareNotificationSettings extends StatelessWidget {
  const CareNotificationSettings({
    super.key,
    required this.controller,
    required this.onOpen,
  });
  final CareController controller;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => _card([
      const Text(
        'PFLEGE',
        style: TextStyle(color: _muted, letterSpacing: 1.8, fontSize: 11),
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Pflege-Benachrichtigungen'),
        subtitle: const Text(
          'Ausschalten stoppt alle geplanten Reinigungserinnerungen.',
        ),
        value: controller.notificationsEnabled,
        onChanged: controller.busy ? null : controller.setNotifications,
      ),
      Text(
        controller.enabledCount == 0
            ? 'Wähle im Pflegebereich, für welches Gerät du erinnert werden möchtest.'
            : '${controller.enabledCount} Modell(e) vorgemerkt. Ohne Konto, Kalender oder Cloud.',
        style: const TextStyle(color: _muted, fontSize: 12, height: 1.5),
      ),
      _permissionNotice(controller),
      TextButton.icon(
        onPressed: onOpen,
        icon: const Icon(Icons.cleaning_services_outlined),
        label: const Text('Pflege öffnen'),
      ),
      if (controller.notificationsEnabled && controller.supportsNotifications)
        TextButton(
          onPressed: controller.busy
              ? null
              : () async {
                  final model =
                      controller.plans.entries
                          .where((e) => e.value.remind)
                          .firstOrNull
                          ?.key ??
                      DeviceModel.venty;
                  await controller.testReminder(model);
                  if (context.mounted &&
                      controller.error.isEmpty &&
                      controller.permission == ReminderAccess.allowed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Testerinnerung geplant. Das System kann sie verzögert anzeigen.',
                        ),
                      ),
                    );
                  }
                },
          child: const Text('Benachrichtigung testen'),
        ),
      if (controller.error.isNotEmpty)
        Text(
          controller.error,
          style: const TextStyle(color: Color(0xFFFFB690), fontSize: 12),
        ),
    ]),
  );
}

Future<void> _showSources(
  BuildContext context,
  CareGuide guide,
) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (sheetContext) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${guide.model.label}: Originalanleitungen',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nach Herstellerunterlagen geprüft am 20.10.2026. Unsere Zeichnungen sind schematisch. Für die genaue Bauteilansicht nutze die Originalanleitung.',
              style: TextStyle(color: _muted, height: 1.5),
            ),
            const SizedBox(height: 12),
            for (final source in guide.sources)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(source.label),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () async {
                  try {
                    if (await launchUrl(
                      Uri.parse(source.url),
                      mode: LaunchMode.externalApplication,
                    )) {
                      return;
                    }
                  } catch (_) {
                    /* Keep the app usable if no browser is available. */
                  }
                  if (sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Die Herstellerseite konnte nicht geöffnet werden.',
                        ),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    ),
  ),
);

class CareWizard extends StatefulWidget {
  const CareWizard({super.key, required this.guide, required this.controller});
  final CareGuide guide;
  final CareController controller;
  @override
  State<CareWizard> createState() => _CareWizardState();
}

class _CareWizardState extends State<CareWizard> {
  final pages = PageController();
  int index = 0;
  bool checked = false;
  CareGuide get g => widget.guide;
  int get count => g.steps.length + 2;
  @override
  void dispose() {
    pages.dispose();
    super.dispose();
  }

  void go(int i) => pages.animateToPage(
    i,
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOutCubic,
  );
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text(
          '${g.model.label} reinigen',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Herstellerangaben',
            onPressed: () => _showSources(context, g),
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index == 0
                            ? 'DEINE VORBEREITUNG'
                            : index == count - 1
                            ? 'ZUM ABSCHLUSS'
                            : 'SCHRITT $index VON ${g.steps.length}',
                        style: const TextStyle(
                          color: _accent,
                          letterSpacing: 1.5,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (index + 1) / count,
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: pages,
                    itemCount: count,
                    onPageChanged: (value) => setState(() => index = value),
                    itemBuilder: (context, page) => SingleChildScrollView(
                      key: ValueKey('care-page-$page'),
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
                      child: page == 0
                          ? _supplies()
                          : page == count - 1
                          ? _finish()
                          : _step(g.steps[page - 1]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
                  child: Row(
                    children: [
                      if (index > 0) ...[
                        OutlinedButton(
                          onPressed: widget.controller.busy
                              ? null
                              : () => go(index - 1),
                          child: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: widget.controller.busy
                              ? null
                              : index == count - 1
                              ? checked
                                    ? () async {
                                        await widget.controller.markCleaned(
                                          g.model,
                                        );
                                        if (context.mounted &&
                                            widget.controller.error.isEmpty) {
                                          Navigator.pop(context, true);
                                        }
                                      }
                                    : null
                              : () => go(index + 1),
                          child: Text(
                            index == count - 1
                                ? 'Reinigung speichern'
                                : index == 0
                                ? 'Los geht’s'
                                : 'Weiter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _supplies() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CareIllustration(model: g.model, art: CareArt.tools),
      const SizedBox(height: 22),
      const Text(
        'Das brauchst du',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 14),
      for (final supply in g.supplies)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, color: _accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(supply, style: const TextStyle(height: 1.4)),
              ),
            ],
          ),
        ),
      const Text(
        'Die Anleitung zeigt dir nur die Reinigung der vorgesehenen, abnehmbaren Teile. Öffne das Gehäuse des Grundgeräts nicht.',
        style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
      ),
    ],
  );

  Widget _step(CareStep step) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CareIllustration(model: g.model, art: step.art),
      const SizedBox(height: 22),
      Text(
        step.title,
        style: const TextStyle(
          fontSize: 27,
          height: 1.15,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 14),
      Text(step.text, style: const TextStyle(fontSize: 16, height: 1.55)),
      if (step.warning != null) ...[
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF39291F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            step.warning!,
            style: const TextStyle(
              color: Color(0xFFFFC99F),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    ],
  );

  Widget _finish() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CareIllustration(model: g.model, art: CareArt.assemble),
      const SizedBox(height: 22),
      const Text(
        'Alles wieder bereit?',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      const Text(
        'Speichere die Reinigung erst, wenn alle Teile trocken, geprüft und richtig zusammengesetzt sind. Dann beginnt dein wöchentlicher Pflegecheck neu.',
        style: TextStyle(height: 1.55),
      ),
      const SizedBox(height: 12),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text('Alles trocken und geprüft'),
        value: checked,
        onChanged: (value) => setState(() => checked = value == true),
      ),
      if (widget.controller.error.isNotEmpty)
        Text(
          widget.controller.error,
          style: const TextStyle(color: Color(0xFFFFB690)),
        ),
      const SizedBox(height: 10),
      const Text(
        'Das Speichern startet das Gerät nicht. Es verschickt auch keine zusätzliche „Reinigung fertig“-Benachrichtigung.',
        style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
      ),
    ],
  );
}
