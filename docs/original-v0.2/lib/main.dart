import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const orange = Color(0xFFFF7A28);
const panel = Color(0xFF1B1E23);
void main() => runApp(const SbControl());

class SbControl extends StatelessWidget {
  const SbControl({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SB CONTROL',
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF101216),
      colorScheme: ColorScheme.fromSeed(seedColor: orange, brightness: Brightness.dark),
      cardTheme: const CardThemeData(color: panel, elevation: 0)),
    home: const ControlHome(),
  );
}

class ControlHome extends StatefulWidget {
  const ControlHome({super.key});
  @override
  State<ControlHome> createState() => _ControlHomeState();
}

class _ControlHomeState extends State<ControlHome> {
  final Map<String, ScanResult> found = {};
  List<BluetoothService> services = [];
  StreamSubscription<List<ScanResult>>? scanSubscription;
  StreamSubscription<BluetoothConnectionState>? connectionSubscription;
  BluetoothDevice? device;
  bool scanning = false;
  int tab = 0;
  String status = 'Bereit zur Suche';
  static const models = ['VENTY', 'VEAZY', 'CRAFTY', 'VOLCANO'];

  @override
  void initState() {
    super.initState();
    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      setState(() {
        for (final result in results) {
          final name = _name(result);
          if (models.any((m) => name.toUpperCase().contains(m))) {
            found[result.device.remoteId.str] = result;
          }
        }
      });
    });
  }

  String _name(ScanResult r) => r.device.platformName.isNotEmpty
      ? r.device.platformName : r.advertisementData.advName;

  Future<void> scan() async {
    if (scanning) return;
    setState(() { scanning = true; found.clear(); status = 'Suche läuft …'; });
    try {
      if (!await FlutterBluePlus.isSupported) throw Exception('Bluetooth LE nicht unterstützt');
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      await Future.delayed(const Duration(seconds: 10));
      if (mounted) setState(() => status = '${found.length} Gerät(e) gefunden');
    } catch (e) {
      if (mounted) setState(() => status = 'Bluetooth-Fehler: $e');
    } finally {
      if (mounted) setState(() => scanning = false);
    }
  }

  Future<void> connect(BluetoothDevice next) async {
    try {
      await FlutterBluePlus.stopScan();
      await connectionSubscription?.cancel();
      if (device != null) await device!.disconnect();
      setState(() { device = null; services = []; status = 'Verbinde …'; });
      await next.connect(timeout: const Duration(seconds: 15));
      final discovered = await next.discoverServices();
      connectionSubscription = next.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected && mounted) {
          setState(() { device = null; services = []; status = 'Verbindung getrennt'; });
        }
      });
      if (mounted) setState(() { device = next; services = discovered; status = 'Bluetooth verbunden'; tab = 0; });
    } catch (e) {
      if (mounted) setState(() => status = 'Verbindungsfehler: $e');
    }
  }

  Future<void> disconnect() async {
    await device?.disconnect();
    if (mounted) setState(() { device = null; services = []; status = 'Verbindung getrennt'; });
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    connectionSubscription?.cancel();
    super.dispose();
  }

  Widget heading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text(subtitle, style: const TextStyle(color: Colors.white60)),
      const SizedBox(height: 24),
    ],
  );

  Widget tile(String title, String detail, IconData icon) => Card(
    child: ListTile(contentPadding: const EdgeInsets.all(15),
      leading: Icon(icon, color: orange), title: Text(title),
      subtitle: Text(detail, style: const TextStyle(color: Colors.white60))),
  );

  Widget dashboard() => ListView(padding: const EdgeInsets.all(22), children: [
    heading('Dein Dashboard', 'Alle Geräte. Eine App.'),
    Card(child: Padding(padding: const EdgeInsets.all(23), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.circle, size: 11, color: orange), const SizedBox(width: 9),
          Text(device == null ? 'KEIN GERÄT VERBUNDEN' : 'BLUETOOTH VERBUNDEN',
            style: const TextStyle(letterSpacing: 1.5, fontSize: 12, color: orange))]),
        const SizedBox(height: 19),
        const Icon(Icons.air, size: 75, color: Colors.white70),
        const SizedBox(height: 18),
        Text(device?.platformName.isNotEmpty == true ? device!.platformName : 'SB CONTROL',
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(status, style: const TextStyle(color: Colors.white60)),
        const SizedBox(height: 17),
        if (device == null) FilledButton.icon(onPressed: () => setState(() => tab = 1),
          icon: const Icon(Icons.bluetooth_searching), label: const Text('Gerät verbinden'))
        else OutlinedButton.icon(onPressed: disconnect,
          icon: const Icon(Icons.link_off), label: const Text('Verbindung trennen')),
      ],
    ))),
    const SizedBox(height: 17),
    tile('Temperatursteuerung', 'Nach Prüfung des jeweiligen Bluetooth-Protokolls verfügbar', Icons.thermostat),
    tile('Boost & Superboost', 'Noch nicht freigeschaltet – keine ungetesteten Gerätebefehle', Icons.bolt),
    tile('Live-Diagnose', '${services.length} Bluetooth-Dienste erkannt', Icons.monitor_heart_outlined),
    const SizedBox(height: 14),
    const Text('UNABHÄNGIGE DRITTANBIETER-APP',
      style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 1.3)),
  ]);

  Widget devices() => ListView(padding: const EdgeInsets.all(22), children: [
    heading('Geräte', 'Kompatible Bluetooth-Geräte in der Nähe'),
    FilledButton.icon(onPressed: scanning ? null : scan,
      icon: const Icon(Icons.bluetooth_searching),
      label: Text(scanning ? 'Suche läuft …' : 'Nach Geräten suchen')),
    const SizedBox(height: 17),
    Text(status, style: const TextStyle(color: Colors.white60)),
    const SizedBox(height: 13),
    ...found.values.map((r) => Card(child: ListTile(
      leading: const Icon(Icons.bluetooth, color: orange),
      title: Text(_name(r)), subtitle: Text('Signalstärke: ${r.rssi} dBm'),
      trailing: const Icon(Icons.chevron_right), onTap: () => connect(r.device)))),
    if (found.isEmpty) tile('Noch keine Geräte gefunden',
      'Gerät einschalten, Bluetooth aktivieren und Suche starten.', Icons.radar),
    const SizedBox(height: 22),
    const Text('GEPLANTE MODELLE', style: TextStyle(letterSpacing: 1.8, color: Colors.white54)),
    const SizedBox(height: 12),
    const Wrap(spacing: 8, runSpacing: 8, children: [
      Chip(label: Text('VENTY')), Chip(label: Text('VEAZY')),
      Chip(label: Text('CRAFTY / CRAFTY+')), Chip(label: Text('VOLCANO HYBRID')),
    ]),
  ]);

  Widget diagnostics() => ListView(padding: const EdgeInsets.all(22), children: [
    heading('Diagnose', 'Bluetooth-Dienste und Geräteinformationen'),
    tile('Verbindungsstatus', status, Icons.bluetooth_connected),
    if (device == null) tile('Kein Gerät verbunden',
      'Verbinde ein Gerät, um seine angebotenen Dienste zu sehen.', Icons.info_outline),
    ...services.map((s) => ExpansionTile(title: Text('Dienst ${s.uuid}'),
      subtitle: Text('${s.characteristics.length} Merkmale'),
      children: s.characteristics.map((c) => ListTile(
        title: Text(c.uuid.toString(), style: const TextStyle(fontSize: 12)),
        subtitle: Text('Lesbar: ${c.properties.read} · Benachrichtigung: ${c.properties.notify} · Schreibbar: ${c.properties.write}'),
      )).toList())),
    const SizedBox(height: 14),
    const Text('Diagnose zeigt derzeit nur BLE-Metadaten. Es werden keine unbekannten Befehle übertragen.',
      style: TextStyle(color: Colors.white54, fontSize: 12)),
  ]);

  Widget settings() => ListView(padding: const EdgeInsets.all(22), children: [
    heading('Einstellungen', 'Deine App. Deine Kontrolle.'),
    tile('Offline-Betrieb', 'Bluetooth-Steuerung benötigt grundsätzlich kein Internet.', Icons.wifi_off),
    tile('Privatsphäre', 'Kein Benutzerkonto und kein eigener Cloud-Server.', Icons.shield_outlined),
    tile('Gerätesicherheit', 'Unbekannte Schreibbefehle und Firmware-Updates sind deaktiviert.', Icons.lock_outline),
    tile('Version', '0.2.0 · Entwicklungsprototyp', Icons.info_outline),
    const SizedBox(height: 20),
    const Text('SB CONTROL ist ein unabhängiges Projekt und weder offiziell noch vom Hersteller unterstützt.',
      style: TextStyle(color: Colors.white54, fontSize: 12)),
  ]);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.transparent,
      title: const Text('SB  /  CONTROL',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18)),
      actions: [const Padding(padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.bluetooth, color: orange))]),
    body: IndexedStack(index: tab, children: [dashboard(), devices(), diagnostics(), settings()]),
    bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Übersicht'),
        NavigationDestination(icon: Icon(Icons.devices), label: 'Geräte'),
        NavigationDestination(icon: Icon(Icons.monitor_heart_outlined), label: 'Diagnose'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Optionen'),
      ]),
  );
}
