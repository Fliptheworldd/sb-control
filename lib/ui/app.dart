import '../l10n/strings.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
    locale: const Locale(L.italian ? 'it' : 'de'),
    supportedLocales: const [Locale('de'), Locale('it')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Color(0xFF30343B)),
        ),
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
      unawaited(c.disconnect(message: L.s058));
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
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
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
        title(L.s059, L.s060, L.s061),
        block([
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/art/icon.webp',
              height: 160,
              width: double.infinity,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            L.s062,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text(L.s063, style: TextStyle(color: muted, height: 1.5)),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: c.connecting ? null : () => setState(() => tab = 1),
              icon: const Icon(Icons.add, color: canvas),
              label: const Text(L.s064),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: c.connecting ? null : () => c.setDemo(true),
              child: const Text(L.s065),
            ),
          ),
        ]),
        const SizedBox(height: 18),
        note(L.s066, icon: Icons.wifi_off),
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
        c.demo ? 'Demo · ${c.model.label}' : L.s067,
        c.displayName,
        c.demo ? L.s068 : L.s069,
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
                      label: c.demo ? L.s070 : L.s071,
                      active: true,
                    ),
                  ),
                  IconButton(
                    onPressed: c.busy ? null : c.disconnect,
                    tooltip: L.s072,
                    icon: const Icon(Icons.link_off, size: 20),
                  ),
                ],
              ),
              Semantics(
                label: (L.italian
                    ? "Temperatura impostata ${c.temperature(target)} ${c.unit}"
                    : "Zieltemperatur ${c.temperature(target)} ${c.unit}"),
                child: SizedBox(
                  height: 245,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        right: -12,
                        top: 0,
                        bottom: 0,
                        width: 190,
                        child: ExcludeSemantics(
                          child: ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (rect) => const RadialGradient(
                              colors: [
                                Colors.white,
                                Colors.white,
                                Colors.transparent,
                              ],
                              stops: [0, .6, 1],
                              radius: .85,
                            ).createShader(rect),
                            child: Image.asset(
                              'assets/art/${c.model == DeviceModel.unknown
                                  ? 'icon'
                                  : c.model.isCrafty
                                  ? 'crafty'
                                  : c.model.name}.webp',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              panel,
                              Color(0xE61B1E23),
                              Color(0x001B1E23),
                            ],
                            stops: [0, .35, .85],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              L.s351,
                              style: TextStyle(
                                color: muted,
                                fontSize: 10,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: c.temperature(target),
                                    style: const TextStyle(
                                      fontSize: 70,
                                      height: 1,
                                      letterSpacing: -4,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  TextSpan(
                                    text: c.unit,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: 150,
                              child: Text(
                                heating
                                    ? ready
                                          ? L.s074
                                          : L.s075
                                    : L.s076,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                  height: 1.4,
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
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed:
                        c.enabled('target') && target != null && target > 40
                        ? () => c.setTarget(target.round() - 1)
                        : null,
                    tooltip: L.s077,
                    icon: const Icon(Icons.remove, color: canvas),
                  ),
                  Expanded(child: TargetSlider(controller: c)),
                  IconButton.filledTonal(
                    onPressed:
                        c.enabled('target') &&
                            target != null &&
                            target < c.model.maxTemperature
                        ? () => c.setTarget(target.round() + 1)
                        : null,
                    tooltip: L.s078,
                    icon: const Icon(Icons.add, color: canvas),
                  ),
                ],
              ),
              if (c.model != DeviceModel.volcanoHybrid) ...[
                SettingSlider(
                  label: L.s320,
                  value: (c.data['boost'] as num?)?.toDouble(),
                  min: 1,
                  max: c.model.isCrafty
                      ? math
                            .max(
                              1,
                              math.min(
                                99,
                                210 - (c.data['target'] as num? ?? 180),
                              ),
                            )
                            .toDouble()
                      : 99,
                  suffix: '°C',
                  enabled:
                      c.enabled('boost') &&
                      (!c.model.isCrafty ||
                          (c.data['target'] as num? ?? 210) < 210),
                  onCommit: (v) => c.setBoost(v),
                ),
                if (c.model.isQvap)
                  SettingSlider(
                    label: L.s341,
                    value: (c.data['superboost'] as num?)?.toDouble(),
                    min: 1,
                    max: 99,
                    suffix: '°C',
                    enabled: c.enabled('superboost'),
                    onCommit: (v) => c.setBoost(v, superboost: true),
                  ),
              ],
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
                  label: Text(heating ? L.s079 : L.s315),
                ),
              ),
              if (c.model != DeviceModel.volcanoHybrid) note(L.s111),
              if (c.model == DeviceModel.volcanoHybrid) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: c.enabled('pump')
                        ? () => c.setPump(c.data['pump'] != true)
                        : null,
                    icon: const Icon(Icons.air),
                    label: Text(c.data['pump'] == true ? L.s080 : L.s081),
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
            c.model.hasBattery ? L.s313 : L.s348,
            c.model.hasBattery ? '${c.data['battery'] ?? '—'} %' : L.s333,
            c.model.hasBattery ? Icons.battery_5_bar : Icons.power,
          ),
          const SizedBox(width: 10),
          metric(
            L.s312,
            '${c.data['remaining'] ?? '—'} s',
            Icons.timer_outlined,
          ),
          const SizedBox(width: 10),
          metric(L.s318, '${runtime ~/ 60} h', Icons.history),
        ],
      ),
      const SizedBox(height: 18),
      block([
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(L.s330, style: TextStyle(color: muted)),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                current == null
                    ? L.s082
                    : '${c.temperature(current)} ${c.unit}',
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        if (c.model.isQvap) note(L.s083),
        if (c.model.isCrafty && !craftyModern(c.data['firmware'] as String?))
          note(L.s084),
        if (c.data['craftyFahrenheit'] == true) note(L.s085),
      ]),
      note(
        c.demo ? L.s086 : L.s087,
        icon: c.demo ? Icons.science_outlined : Icons.verified_outlined,
      ),
    ]);
  }

  Future<void> rename(SavedDevice d) async {
    final input = TextEditingController(text: d.nickname);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(L.s088),
        content: TextField(
          controller: input,
          maxLength: 30,
          autofocus: true,
          decoration: InputDecoration(hintText: d.model.label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(L.s311),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text),
            child: const Text(L.s340),
          ),
        ],
      ),
    );
    input.dispose();
    if (result != null) await c.rename(d.id, result);
  }

  Widget devices() => screen([
    title(L.s089, L.s090, c.demo ? L.s091 : L.s092),
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
            ? L.s093
            : c.demo
            ? L.s094
            : L.s095,
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
        L.s326,
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
              subtitle: Text(c.active?.id == d.id ? L.s347 : L.s096),
              onTap: c.connecting || c.busy ? null : () => c.reconnect(d),
              trailing: PopupMenuButton<String>(
                tooltip: L.s097,
                onSelected: (v) {
                  if (v == 'rename') {
                    rename(d);
                  } else {
                    c.forget(d.id);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'rename', child: Text(L.s343)),
                  const PopupMenuItem(value: 'forget', child: Text(L.s325)),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
    const SizedBox(height: 24),
    Text(
      c.demo ? L.s098 : L.s099,
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
                  ? L.s347
                  : '${d.rssi} dBm · ${c.demo ? L.s339 : (L.italian ? 'Disponibile' : 'Verfügbar')}',
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
        const Text(L.s100),
        note(L.s101),
      ]),
    const SizedBox(height: 20),
    note(L.s102),
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
        title: const Text(L.s103),
        content: Text(
          (L.italian
              ? "Le impostazioni personalizzate di ${c.model.label} saranno ripristinate ai valori predefiniti. La temperatura base sarà impostata a 180 °C."
              : "Die individuellen Einstellungen von ${c.model.label} werden auf die Geräte-Standardwerte zurückgesetzt. Die Basis wird auf 180 °C gesetzt."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(L.s311),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(L.s105),
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
    title(L.s106, L.s324, L.s107),
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
          const Text(L.s342),
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
      const Text(L.s108, style: TextStyle(color: muted, fontSize: 12)),
      const Divider(),
      option(
        L.s322,
        kIsWeb ? L.s109 : L.s110,
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
        SettingSlider(
          label: L.s328,
          value: (c.data['brightness'] as num?)?.toDouble(),
          min: c.model.isQvap ? 1 : 0,
          max: c.model.isQvap ? 9 : 100,
          suffix: c.model.isQvap ? '/ 9' : '%',
          enabled: c.enabled('brightness'),
          onCommit: c.setBrightness,
        ),
        option(
          L.s349,
          L.s112,
          c.data['vibration'] as bool?,
          c.enabled('vibration'),
          c.setVibration,
        ),
        if (!c.model.isQvap)
          SettingSlider(
            label: L.s113,
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
            L.s114,
            L.s115,
            c.data['permanentBoost'] as bool?,
            c.enabled('permanentBoost'),
            c.setPermanentBoost,
          ),
          if (!c.supports('permanentBoost')) note(L.s116),
          option(
            L.s117,
            c.model == DeviceModel.venty ? L.s118 : L.s119,
            c.data['boostVisualization'] as bool?,
            c.enabled('boostVisualization'),
            c.setBoostVisualization,
          ),
          note(L.s120),

          option(
            L.s121,
            L.s122,
            c.data['ecoCharge'] as bool?,
            c.enabled('ecoCharge'),
            c.setEco,
          ),
          option(
            L.s331,
            L.s123,
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
            label: const Text(L.s124),
          ),
          note(L.s125),
        ],
        if (c.model == DeviceModel.veazy)
          option(
            L.s126,
            L.s127,
            c.data['permanentBluetooth'] as bool?,
            c.enabled('permanentBluetooth'),
            c.setPermanentBluetooth,
          ),
      ])
    else
      note(L.s128),
    const SizedBox(height: 18),
    block([
      const Text(
        'SB CONTROL',
        style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.8),
      ),
      const SizedBox(height: 8),
      const Text(L.s353, style: TextStyle(color: muted, fontSize: 12)),
      note(L.s129),
      const Text(
        L.s130,
        style: TextStyle(color: muted, fontSize: 12, height: 1.5),
      ),
    ]),
  ]);
  Widget diagnostics() => screen([
    title(L.s131, L.s323, L.s132),
    block([
      _StatusPill(label: c.connected ? L.s346 : L.s133, active: c.connected),
      const SizedBox(height: 20),
      ...{
        L.s332: c.model.label,
        L.s338: '${c.data['serial'] ?? '—'}',
        L.s318: '${c.data['runtimeMinutes'] ?? '—'} min',
        'Firmware': '${c.data['firmware'] ?? '—'}',
        'BLE / Bootloader':
            '${c.data['bleFirmware'] ?? c.data['bootloader'] ?? '—'}',
        L.s321: c.demo ? L.s339 : 'Bluetooth LE',
        L.s327: L.s316,
        L.s134:
            c.lastStatus?.toLocal().toIso8601String().substring(11, 19) ?? '—',
        if (c.data.containsKey('errorCode'))
          L.s314:
              "${c.data['errorCode']} / ${L.italian ? 'Categoria' : 'Kategorie'} ${c.data['errorCategory']}",
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
      if (c.model.isQvap) note(L.s135),
      if (c.data['fault'] == true)
        const Text(L.s136, style: TextStyle(color: orange)),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: c.connected && !c.busy
              ? () => c.refresh(analysis: true)
              : null,
          icon: const Icon(Icons.refresh),
          label: Text(c.model.isQvap ? L.s137 : L.s138),
        ),
      ),
    ]),
    const SizedBox(height: 16),
    OutlinedButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: c.diagnosticReport()));
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(L.s139)));
        }
      },
      icon: const Icon(Icons.copy_outlined),
      label: const Text(L.s140),
    ),
    const SizedBox(height: 20),
    Card(
      child: ExpansionTile(
        title: const Text(L.s319, style: TextStyle(fontSize: 15)),
        subtitle: Text(
          (L.italian
              ? "${c.fields.map((f) => f.service).toSet().length} servizi · ${c.fields.length} caratteristiche"
              : "${c.fields.map((f) => f.service).toSet().length} Dienste · ${c.fields.length} Merkmale"),
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
                  "${L.italian ? 'Lettura' : 'Lesen'} ${f.read ? '✓' : '–'} · ${L.italian ? 'Scrittura' : 'Schreiben'} ${f.write || f.writeWithoutResponse ? '✓' : '–'} · ${L.italian ? 'Notifiche' : 'Meldungen'} ${f.notify ? '✓' : '–'}",
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
        L.s345,
        style: TextStyle(color: muted, fontSize: 11, letterSpacing: 1.4),
      ),
      const SizedBox(height: 14),
      if (c.log.isEmpty) const Text(L.s142, style: TextStyle(color: muted)),
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
    note(L.s143),
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
            label: L.s144,
          ),
          NavigationDestination(
            icon: Icon(Icons.devices_outlined),
            label: L.s090,
          ),
          NavigationDestination(
            icon: Icon(Icons.cleaning_services_outlined),
            selectedIcon: Icon(Icons.cleaning_services),
            label: L.s336,
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            label: L.s323,
          ),
          NavigationDestination(icon: Icon(Icons.tune), label: L.s334),
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
