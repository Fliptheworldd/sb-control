import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/controller.dart';
import '../core/models.dart';
import '../core/protocol.dart';
import '../app/preferences.dart';
import '../care/controller.dart';
import '../care/screen.dart';

const orange = Color(0xFFFF7A28);
const panel = Color(0xFF1B1E23);
const muted = Color(0xFFA7ABB3);
const canvas = Color(0xFF101216);

class SbControlApp extends StatelessWidget {
  const SbControlApp({super.key, required this.controller, this.care});
  final AppController controller;
  final CareController? care;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SB CONTROL',
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: canvas,
      colorScheme: const ColorScheme.dark(
        primary: orange,
        onPrimary: Color(0xFF201006),
        surface: panel,
        onSurface: Color(0xFFF6F6F7),
        secondary: orange,
        onSecondaryContainer: orange,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: panel,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: canvas,
        indicatorColor: Color(0xFF493020),
      ),
      sliderTheme: const SliderThemeData(trackHeight: 5),
      dividerTheme: const DividerThemeData(color: Color(0xFF30333A), space: 28),
    ),
    home: ControlHome(controller: controller, care: care),
  );
}

class ControlHome extends StatefulWidget {
  const ControlHome({super.key, required this.controller, this.care});
  final AppController controller;
  final CareController? care;
  @override
  State<ControlHome> createState() => _ControlHomeState();
}

class _ControlHomeState extends State<ControlHome> with WidgetsBindingObserver {
  int tab = 0;
  late final CareController care;
  DeviceModel careModel = DeviceModel.venty;
  AppController get c => widget.controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    care = widget.care ?? CareController(preferences: MemoryPreferences());
    if (widget.care == null) unawaited(care.initialize());
    care.addListener(_openCareFromNotification);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _openCareFromNotification(),
    );
  }

  void _openCareFromNotification() {
    if (!mounted || care.openModel == null) return;
    final model = care.consumeOpenModel()!;
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() {
      careModel = model;
      tab = 2;
    });
  }

  void _selectTab(int value) => setState(() {
    if (value == 2 && tab != 2 && c.model != DeviceModel.unknown) {
      careModel = c.model;
    }
    tab = value;
  });

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    care.removeListener(_openCareFromNotification);
    if (widget.care == null) care.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(care.refreshPermission());
    // No background control or silent command replay on resume.
    if (state == AppLifecycleState.paused && !c.demo) {
      unawaited(
        c.disconnect(message: 'App pausiert. Bei Bedarf erneut verbinden.'),
      );
    }
  }

  Widget title(String eyebrow, String name, String detail) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: orange,
            letterSpacing: 2,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 30,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(detail, style: const TextStyle(color: muted, height: 1.5)),
      ],
    ),
  );
  Widget screen(List<Widget> children) => ListView(
    padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
    children: children,
  );
  Widget block(List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
  Widget note(String text, {IconData icon = Icons.info_outline}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: muted, fontSize: 12, height: 1.5),
          ),
        ),
      ],
    ),
  );
  Widget metric(String label, String value, IconData icon) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: orange),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: muted, fontSize: 11)),
          ],
        ),
      ),
    ),
  );
  Widget dashboard() {
    if (!c.connected) {
      return screen([
        title(
          'Deine Verbindung',
          'Alles unter Kontrolle.',
          'Deine Geräte. Direkt über Bluetooth.',
        ),
        block([
          const Icon(
            Icons.bluetooth_searching_rounded,
            color: orange,
            size: 64,
          ),
          const SizedBox(height: 26),
          const Text(
            'Bereit, wenn du es bist.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text(
            'Verbinde deinen Vaporizer und passe Temperatur und Einstellungen an.',
            style: TextStyle(color: muted, height: 1.5),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: c.connecting ? null : () => setState(() => tab = 1),
              icon: const Icon(Icons.add),
              label: const Text('Gerät verbinden'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: c.connecting ? null : () => c.setDemo(true),
              child: const Text('Mit Demo-Geräten ausprobieren'),
            ),
          ),
        ]),
        const SizedBox(height: 18),
        note(
          'Ohne Konto. Ohne Cloud. Die native App arbeitet auch ohne Internet.',
          icon: Icons.wifi_off,
        ),
        const Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            Chip(label: Text('VENTY')),
            Chip(label: Text('VEAZY')),
            Chip(label: Text('CRAFTY / +')),
            Chip(label: Text('VOLCANO HYBRID')),
          ],
        ),
      ]);
    }
    final target = c.data['target'] as num?;
    final heating = c.data['heater'] == true;
    final ready = c.data['ready'] == true;
    final current = c.data['current'] as num?;
    final runtime =
        c.data['runtimeMinutes'] as int? ??
        ((c.data['runtimeHours'] as int? ?? 0) * 60 +
            (c.data['runtimeRemainder'] as int? ?? 0));
    return screen([
      title(
        c.demo ? 'Demo · ${c.model.label}' : 'Dein Gerät',
        c.displayName,
        c.demo
            ? 'Erkunde die App mit simulierten Werten.'
            : 'Direkt verbunden. Lokal gesteuert.',
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: _StatusPill(
                      label: c.demo ? 'DEMO VERBUNDEN' : 'BLUETOOTH VERBUNDEN',
                      active: true,
                    ),
                  ),
                  IconButton(
                    onPressed: c.busy ? null : c.disconnect,
                    tooltip: 'Verbindung trennen',
                    icon: const Icon(Icons.link_off, size: 20),
                  ),
                ],
              ),
              Semantics(
                label: 'Zieltemperatur ${c.temperature(target)} ${c.unit}',
                child: SizedBox(
                  height: 260,
                  child: LayoutBuilder(
                    builder: (context, box) {
                      return CustomPaint(
                        painter: DialPainter(
                          progress: target == null
                              ? 0
                              : ((target - 40) / (c.model.maxTemperature - 40))
                                    .clamp(0, 1)
                                    .toDouble(),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'ZIELTEMPERATUR',
                                style: TextStyle(
                                  letterSpacing: 2,
                                  color: muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.temperature(target),
                                      style: const TextStyle(
                                        fontSize: 74,
                                        letterSpacing: -4,
                                        fontWeight: FontWeight.w300,
                                        height: 1.2,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 14,
                                        left: 6,
                                      ),
                                      child: Text(
                                        c.unit,
                                        style: const TextStyle(
                                          color: orange,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                heating
                                    ? ready
                                          ? 'Temperatur erreicht'
                                          : 'Wird aufgeheizt'
                                    : 'Bereit zum Aufheizen',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed:
                        c.enabled('target') && target != null && target > 40
                        ? () => c.setTarget(target.round() - 1)
                        : null,
                    tooltip: 'Temperatur um 1 °C senken',
                    icon: const Icon(Icons.remove),
                  ),
                  Expanded(child: TargetSlider(controller: c)),
                  IconButton.filledTonal(
                    onPressed:
                        c.enabled('target') &&
                            target != null &&
                            target < c.model.maxTemperature
                        ? () => c.setTarget(target.round() + 1)
                        : null,
                    tooltip: 'Temperatur um 1 °C erhöhen',
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: c.enabled('heat')
                      ? () => c.setHeat(!heating)
                      : null,
                  style: heating
                      ? FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF343840),
                          foregroundColor: Colors.white,
                        )
                      : null,
                  icon: c.busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.power_settings_new),
                  label: Text(heating ? 'Aufheizen stoppen' : 'Aufheizen'),
                ),
              ),
              if (c.model == DeviceModel.volcanoHybrid) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: c.enabled('pump')
                        ? () => c.setPump(c.data['pump'] != true)
                        : null,
                    icon: const Icon(Icons.air),
                    label: Text(
                      c.data['pump'] == true
                          ? 'Pumpe ausschalten'
                          : 'Pumpe einschalten',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          metric(
            c.model.hasBattery ? 'Akku' : 'Versorgung',
            c.model.hasBattery
                ? '${c.data['battery'] ?? '—'} %'
                : 'Netzbetrieb',
            c.model.hasBattery ? Icons.battery_5_bar : Icons.power,
          ),
          const SizedBox(width: 10),
          metric(
            'Abschaltung',
            '${c.data['remaining'] ?? '—'} s',
            Icons.timer_outlined,
          ),
          const SizedBox(width: 10),
          metric('Betriebszeit', '${runtime ~/ 60} h', Icons.history),
        ],
      ),
      const SizedBox(height: 18),
      block([
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text('Isttemperatur', style: TextStyle(color: muted)),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                current == null
                    ? 'Nicht übertragen'
                    : '${c.temperature(current)} ${c.unit}',
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        if (c.model.isQvap)
          note(
            'Manche Firmwarestände liefern keinen Messwert. SB CONTROL zeigt dann keine geschätzte Temperatur.',
          ),
        if (c.model.isCrafty && !craftyModern(c.data['firmware'] as String?))
          note(
            'Ältere oder unbekannte Firmware: Heizschalter und erweiterte Einstellungen sind gesperrt.',
          ),
        if (c.data['craftyFahrenheit'] == true)
          note(
            'CRAFTY meldet Fahrenheit. Temperatur-Schreibzugriffe bleiben bis zum Hardwareabgleich gesperrt.',
          ),
      ]),
      note(
        c.demo
            ? 'Alle Geräte und Werte in diesem Modus sind simuliert.'
            : 'Quellengeprüfte Protokolle. Tests mit echter Hardware stehen noch aus.',
        icon: c.demo ? Icons.science_outlined : Icons.verified_outlined,
      ),
    ]);
  }

  Future<void> rename(SavedDevice d) async {
    final input = TextEditingController(text: d.nickname);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerätename'),
        content: TextField(
          controller: input,
          maxLength: 30,
          autofocus: true,
          decoration: InputDecoration(hintText: d.model.label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    input.dispose();
    if (result != null) await c.rename(d.id, result);
  }

  Widget devices() => screen([
    title(
      'Dein Setup',
      'Geräte',
      c.demo
          ? 'Fünf Modelle. Eine gemeinsame Bedienung.'
          : 'Schalte dein Gerät ein und starte die Suche.',
    ),
    FilledButton.icon(
      onPressed: c.connecting
          ? null
          : c.scanning
          ? c.stopScan
          : c.startScan,
      icon: Icon(
        c.scanning ? Icons.stop_circle_outlined : Icons.bluetooth_searching,
      ),
      label: Text(
        c.scanning
            ? 'Suche stoppen'
            : c.demo
            ? 'Demo-Geräte suchen'
            : 'Nach Geräten suchen',
      ),
    ),
    const SizedBox(height: 12),
    Text(c.status, style: const TextStyle(color: muted, fontSize: 13)),
    if (c.scanning || c.connecting)
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      ),
    if (!c.demo && c.saved.isNotEmpty) ...[
      const SizedBox(height: 24),
      const Text(
        'GESPEICHERT',
        style: TextStyle(color: muted, letterSpacing: 1.6, fontSize: 11),
      ),
      const SizedBox(height: 12),
      ...c.saved.map(
        (d) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              leading: const Icon(Icons.devices, color: orange),
              title: Text(d.displayName),
              subtitle: Text(
                c.active?.id == d.id ? 'Verbunden' : 'Zum Verbinden antippen',
              ),
              onTap: c.connecting || c.busy ? null : () => c.reconnect(d),
              trailing: PopupMenuButton<String>(
                tooltip: 'Gerät verwalten',
                onSelected: (v) {
                  if (v == 'rename') {
                    rename(d);
                  } else {
                    c.forget(d.id);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Text('Umbenennen'),
                  ),
                  const PopupMenuItem(
                    value: 'forget',
                    child: Text('Entfernen'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
    const SizedBox(height: 24),
    Text(
      c.demo ? 'DEMO-GERÄTE' : 'IN DER NÄHE',
      style: const TextStyle(color: muted, letterSpacing: 1.6, fontSize: 11),
    ),
    const SizedBox(height: 12),
    ...c.found.values.map((d) {
      final m = identify(d.name, d.services);
      final label = d.id == 'demo-craftyPlus'
          ? 'CRAFTY+'
          : m == DeviceModel.unknown
          ? d.name
          : m.label;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            leading: Icon(
              m == DeviceModel.volcanoHybrid
                  ? Icons.device_thermostat
                  : Icons.bluetooth,
              color: orange,
            ),
            title: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              c.active?.id == d.id && c.connected
                  ? 'Verbunden'
                  : '${d.rssi} dBm · ${c.demo ? 'Simulation' : 'Verfügbar'}',
            ),
            trailing: Icon(
              c.active?.id == d.id && c.connected
                  ? Icons.check_circle
                  : Icons.chevron_right,
              color: c.active?.id == d.id ? orange : muted,
            ),
            onTap: c.connecting || c.busy
                ? null
                : () async {
                    await c.connect(d);
                    if (mounted && c.connected) setState(() => tab = 0);
                  },
          ),
        ),
      );
    }),
    if (c.found.isEmpty)
      block([
        const Icon(Icons.radar, color: muted, size: 35),
        const SizedBox(height: 14),
        const Text('Noch kein Gerät gefunden'),
        note(
          'Gerät einschalten, Bluetooth aktivieren und andere verbundene Apps schließen. Bei Android bis Version 11 können Standortdienste erforderlich sein.',
        ),
      ]),
    const SizedBox(height: 20),
    note(
      'Der Gerätename allein reicht nicht: SB CONTROL prüft nach dem Verbinden auch die angebotenen Bluetooth-Dienste.',
    ),
  ]);

  Widget option(
    String name,
    String detail,
    bool? value,
    bool enabled,
    ValueChanged<bool> change,
  ) => SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    title: Text(name, style: const TextStyle(fontSize: 15)),
    subtitle: Text(detail, style: const TextStyle(color: muted, fontSize: 12)),
    value: value ?? false,
    onChanged: enabled && value != null ? change : null,
  );
  Future<void> confirmReset() async {
    final deviceId = c.active?.id;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerät zurücksetzen?'),
        content: Text(
          'Die individuellen Einstellungen von ${c.model.label} werden auf die Geräte-Standardwerte zurückgesetzt. Die Basis wird auf 180 °C gesetzt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );
    if (confirmed == true &&
        mounted &&
        c.active?.id == deviceId &&
        c.enabled('factoryReset')) {
      await c.factoryReset();
    }
  }

  Widget settings() => screen([
    title(
      'Ganz nach dir',
      'Einstellungen',
      'Lokal gespeichert. Direkt am Gerät wirksam.',
    ),
    block([
      const Text(
        'APP',
        style: TextStyle(color: muted, letterSpacing: 1.8, fontSize: 11),
      ),
      const SizedBox(height: 15),
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          const Text('Temperatureinheit'),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('°C')),
              ButtonSegment(value: true, label: Text('°F')),
            ],
            selected: {c.fahrenheit},
            onSelectionChanged: (v) => c.setFahrenheit(v.first),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Ändert nur die Anzeige in der App.',
        style: TextStyle(color: muted, fontSize: 12),
      ),
      const Divider(),
      option(
        'Demo-Modus',
        kIsWeb
            ? 'Die Web-Vorschau nutzt simulierte Geräte.'
            : 'Ohne Hardware alle Ansichten ausprobieren.',
        c.demo,
        !kIsWeb && !c.busy && !c.connecting,
        c.setDemo,
      ),
    ]),
    const SizedBox(height: 18),
    CareNotificationSettings(controller: care, onOpen: () => _selectTab(2)),
    const SizedBox(height: 18),
    if (c.connected)
      block([
        Text(
          c.model.label,
          style: const TextStyle(
            color: orange,
            letterSpacing: 1.6,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 12),
        if (c.model != DeviceModel.volcanoHybrid) ...[
          SettingSlider(
            label: 'Boost-Offset',
            value: (c.data['boost'] as num?)?.toDouble(),
            min: 1,
            max: c.model.isCrafty
                ? math
                      .max(
                        1,
                        math.min(99, 210 - (c.data['target'] as num? ?? 180)),
                      )
                      .toDouble()
                : 99,
            suffix: '°C',
            enabled:
                c.enabled('boost') &&
                (!c.model.isCrafty || (c.data['target'] as num? ?? 210) < 210),
            onCommit: (v) => c.setBoost(v),
          ),
          if (c.model.isQvap)
            SettingSlider(
              label: 'Superboost-Offset',
              value: (c.data['superboost'] as num?)?.toDouble(),
              min: 1,
              max: 99,
              suffix: '°C',
              enabled: c.enabled('superboost'),
              onCommit: (v) => c.setBoost(v, superboost: true),
            ),
          note(
            'Offsets werden am Gerät gespeichert. Boost aktivierst du über die Gerätetaste.',
          ),
          const Divider(),
        ],
        SettingSlider(
          label: 'Helligkeit',
          value: (c.data['brightness'] as num?)?.toDouble(),
          min: c.model.isQvap ? 1 : 0,
          max: c.model.isQvap ? 9 : 100,
          suffix: c.model.isQvap ? '/ 9' : '%',
          enabled: c.enabled('brightness'),
          onCommit: c.setBrightness,
        ),
        option(
          'Vibration',
          'Rückmeldung des Geräts',
          c.data['vibration'] as bool?,
          c.enabled('vibration'),
          c.setVibration,
        ),
        if (!c.model.isQvap)
          SettingSlider(
            label: 'Automatische Abschaltung',
            value: (c.data['autoOff'] as num?)?.toDouble(),
            min: c.model.isCrafty ? 30 : 60,
            max: c.model.isCrafty ? 300 : 21600,
            suffix: 's',
            enabled: c.enabled('autoOff'),
            onCommit: c.setAutoOff,
          ),
        if (c.model.isQvap) ...[
          const Divider(),
          option(
            'Boost-Temperatur halten',
            'Permanent Boost: kein 90-Sekunden-Rücksprung. Gilt für Boost und Superboost am Gerät; Abschaltung bleibt separat.',
            c.data['permanentBoost'] as bool?,
            c.enabled('permanentBoost'),
            c.setPermanentBoost,
          ),
          if (!c.supports('permanentBoost'))
            note(
              'Permanent Boost benötigt beim VENTY eine unterstützte Firmware ab 1.08 und einen gültigen Rücklesewert.',
            ),
          option(
            'Boost-Stufe am Gerät anzeigen',
            c.model == DeviceModel.venty
                ? 'Blinkendes °C/°F zeigt Boost und Superboost an.'
                : 'Geräteeigene Boost-Anzeige aktivieren.',
            c.data['boostVisualization'] as bool?,
            c.enabled('boostVisualization'),
            c.setBoostVisualization,
          ),
          note(
            'Diese Einstellungen werden an das Gerät übertragen. Boost und Superboost aktivierst du danach über die Gerätetaste. Beim Verbinden werden vorhandene Werte ausgelesen.',
          ),

          option(
            'Schonend laden',
            'Reduzierter Ladestrom',
            c.data['ecoCharge'] as bool?,
            c.enabled('ecoCharge'),
            c.setEco,
          ),
          option(
            'Ladelimit',
            'Geräteeigenes Limit für den Akku',
            c.data['chargeLimit'] as bool?,
            c.enabled('chargeLimit'),
            (v) => c.setEco(v, voltage: true),
          ),
        ],
        if (c.model.isQvap) ...[
          const Divider(),
          OutlinedButton.icon(
            onPressed: c.enabled('factoryReset') ? confirmReset : null,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Geräteeinstellungen zurücksetzen'),
          ),
          note(
            'Nur bei ausgeschaltetem Aufheizen. Löscht die individuellen Geräteeinstellungen; keine Firmwareänderung.',
          ),
        ],
        if (c.model == DeviceModel.veazy)
          option(
            'Bluetooth dauerhaft aktiv',
            'Kann den Akkuverbrauch erhöhen.',
            c.data['permanentBluetooth'] as bool?,
            c.enabled('permanentBluetooth'),
            c.setPermanentBluetooth,
          ),
      ])
    else
      note('Verbinde ein Gerät, um seine Einstellungen zu bearbeiten.'),
    const SizedBox(height: 18),
    block([
      const Text(
        'SB CONTROL',
        style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.8),
      ),
      const SizedBox(height: 8),
      const Text(
        'Version 0.4.0 · Entwicklungsstand',
        style: TextStyle(color: muted, fontSize: 12),
      ),
      note(
        'Unabhängige Drittanbieter-App. Keine Verbindung zu STORZ & BICKEL. Keine Telemetrie, kein Konto, keine Cloud.',
      ),
      const Text(
        'Firmware-Updates sind in dieser Version nicht enthalten. Reset ist nur für VENTY und VEAZY belegt.',
        style: TextStyle(color: muted, fontSize: 12, height: 1.5),
      ),
    ]),
  ]);
  Widget diagnostics() => screen([
    title(
      'Ein klarer Blick',
      'Diagnose',
      'Verbindungsdaten, Geräteprofil und Ereignisse.',
    ),
    block([
      _StatusPill(
        label: c.connected ? 'VERBUNDEN' : 'NICHT VERBUNDEN',
        active: c.connected,
      ),
      const SizedBox(height: 20),
      ...{
        'Modell': c.model.label,
        'Seriennummer': '${c.data['serial'] ?? '—'}',
        'Betriebszeit': '${c.data['runtimeMinutes'] ?? '—'} min',
        'Firmware': '${c.data['firmware'] ?? '—'}',
        'BLE / Bootloader':
            '${c.data['bleFirmware'] ?? c.data['bootloader'] ?? '—'}',
        'Datenquelle': c.demo ? 'Simulation' : 'Bluetooth LE',
        'Hardwaretests': 'Ausstehend',
        'Letzter Status':
            c.lastStatus?.toLocal().toIso8601String().substring(11, 19) ?? '—',
        if (c.data.containsKey('errorCode'))
          'Analysecode':
              '${c.data['errorCode']} / Kategorie ${c.data['errorCategory']}',
      }.entries.map(
        (e) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  e.key,
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  e.value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
      if (c.model.isQvap)
        note(
          'Liest die geräteeigene Fehlerkategorie aus. Kein Upload an den Hersteller und keine umfassende Hardwareprüfung.',
        ),
      if (c.data['fault'] == true)
        const Text(
          'Das Gerät meldet einen Fehler. Steuerung gesperrt. Hersteller-Support kontaktieren.',
          style: TextStyle(color: orange),
        ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: c.connected && !c.busy
              ? () => c.refresh(analysis: true)
              : null,
          icon: const Icon(Icons.refresh),
          label: Text(
            c.model.isQvap ? 'Geräteanalyse starten' : 'Diagnose aktualisieren',
          ),
        ),
      ),
    ]),
    const SizedBox(height: 16),
    OutlinedButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: c.diagnosticReport()));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Diagnose ohne Seriennummer und Geräte-ID kopiert.',
              ),
            ),
          );
        }
      },
      icon: const Icon(Icons.copy_outlined),
      label: const Text('Diagnosebericht kopieren'),
    ),
    const SizedBox(height: 20),
    Card(
      child: ExpansionTile(
        title: const Text('Bluetooth-Dienste', style: TextStyle(fontSize: 15)),
        subtitle: Text(
          '${c.fields.map((f) => f.service).toSet().length} Dienste · ${c.fields.length} Merkmale',
          style: const TextStyle(color: muted, fontSize: 12),
        ),
        children: c.fields
            .map(
              (f) => ListTile(
                title: SelectableText(
                  f.id,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
                subtitle: Text(
                  'Lesen ${f.read ? '✓' : '–'} · Schreiben ${f.write || f.writeWithoutResponse ? '✓' : '–'} · Meldungen ${f.notify ? '✓' : '–'}',
                  style: const TextStyle(fontSize: 11, color: muted),
                ),
              ),
            )
            .toList(),
      ),
    ),
    const SizedBox(height: 16),
    block([
      const Text(
        'VERBINDUNGSPROTOKOLL',
        style: TextStyle(color: muted, fontSize: 11, letterSpacing: 1.4),
      ),
      const SizedBox(height: 14),
      if (c.log.isEmpty)
        const Text('Noch keine Ereignisse', style: TextStyle(color: muted)),
      ...c.log
          .take(10)
          .map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                line,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.6,
                ),
              ),
            ),
          ),
    ]),
    note(
      'Quellenprüfung ersetzt keinen Hardwaretest. Unbekannte Fehlercodes werden unverändert dokumentiert.',
    ),
  ]);
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              color: Color(0xFFF6F6F7),
              fontFamily: 'Roboto',
              fontSize: 18,
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(
                text: 'SB',
                style: TextStyle(color: orange),
              ),
              TextSpan(text: ' / CONTROL'),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: c.demo
                ? const _StatusPill(label: 'DEMO', active: true)
                : Icon(Icons.bluetooth, color: c.connected ? orange : muted),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                if (c.error.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF432920),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      c.error,
                      style: const TextStyle(
                        color: Color(0xFFFFC9AA),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                Expanded(
                  child: switch (tab) {
                    0 => dashboard(),
                    1 => devices(),
                    2 => CareScreen(controller: care, initialModel: careModel),
                    3 => diagnostics(),
                    _ => settings(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Übersicht',
          ),
          NavigationDestination(
            icon: Icon(Icons.devices_outlined),
            label: 'Geräte',
          ),
          NavigationDestination(
            icon: Icon(Icons.cleaning_services_outlined),
            selectedIcon: Icon(Icons.cleaning_services),
            label: 'Pflege',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'Diagnose',
          ),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Optionen'),
        ],
      ),
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.active});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF35291F) : const Color(0xFF292C32),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: active ? orange : muted,
        letterSpacing: .8,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class DialPainter extends CustomPainter {
  const DialPainter({required this.progress});
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2 - 18;
    final center = Offset(size.width / 2, size.height / 2 + 8);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = const Color(0xFF30343B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    const start = math.pi * .75, sweep = math.pi * 1.5;
    canvas.drawArc(rect, start, sweep, false, track);
    canvas.drawArc(rect, start, sweep * progress, false, track..color = orange);
    for (int i = 0; i <= 40; i++) {
      final a = start + sweep * i / 40;
      final p1 = center + Offset(math.cos(a), math.sin(a)) * (radius - 15);
      final p2 =
          center +
          Offset(math.cos(a), math.sin(a)) * (radius - (i % 5 == 0 ? 23 : 19));
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = const Color(0xFF555A63)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(DialPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

class SettingSlider extends StatefulWidget {
  const SettingSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.enabled,
    required this.onCommit,
  });
  final String label, suffix;
  final double? value;
  final double min, max;
  final bool enabled;
  final ValueChanged<int> onCommit;
  @override
  State<SettingSlider> createState() => _SettingSliderState();
}

class _SettingSliderState extends State<SettingSlider> {
  double? draft;
  @override
  Widget build(BuildContext context) {
    final max = math.max(widget.min + 1, widget.max);
    final current = (draft ?? widget.value ?? widget.min).clamp(
      widget.min,
      max,
    );
    final active =
        widget.enabled && widget.value != null && widget.max > widget.min;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.label, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Text(
                widget.value == null
                    ? '—'
                    : '${current.round()} ${widget.suffix}',
                style: const TextStyle(color: orange, fontSize: 14),
              ),
            ],
          ),
          Slider(
            value: current,
            min: widget.min,
            max: max,
            divisions: (max - widget.min).round(),
            semanticFormatterCallback: (v) => '${v.round()} ${widget.suffix}',
            onChanged: active ? (v) => setState(() => draft = v) : null,
            onChangeEnd: active
                ? (v) {
                    setState(() => draft = null);
                    widget.onCommit(v.round());
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class TargetSlider extends StatefulWidget {
  const TargetSlider({super.key, required this.controller});
  final AppController controller;
  @override
  State<TargetSlider> createState() => _TargetSliderState();
}

class _TargetSliderState extends State<TargetSlider> {
  double? draft;
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final value = (draft ?? (c.data['target'] as num?)?.toDouble() ?? 180)
        .clamp(40.0, c.model.maxTemperature.toDouble());
    return Slider(
      value: value,
      min: 40,
      max: c.model.maxTemperature.toDouble(),
      divisions: c.model.maxTemperature - 40,
      label: '${c.temperature(value)} ${c.unit}',
      semanticFormatterCallback: (v) => '${c.temperature(v)} ${c.unit}',
      onChanged: c.enabled('target') ? (v) => setState(() => draft = v) : null,
      onChangeEnd: c.enabled('target')
          ? (v) async {
              setState(() => draft = null);
              await c.setTarget(v.round());
            }
          : null,
    );
  }
}
