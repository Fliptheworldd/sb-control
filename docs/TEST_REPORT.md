# Testbericht · SB CONTROL 0.3.2

Stand 19.10.2026, Flutter 3.35.3 / Dart 3.9.2.

| Prüfung | Ergebnis |
|---|---|
| Herstellerfunktionen mit GATT-Mock ausgeführt | 24 Referenzvektoren |
| Kernprüfungen inklusive Hersteller-Bytevergleich | 56/56 bestanden |
| Flutter-Controller- und Widgettests | 10/10 bestanden |
| Statische Analyse | Keine Probleme |
| Formatprüfung | 16 Dateien, keine Änderungen |
| Flutter Web Release | Erfolgreich kompiliert |
| iOS Release für physische iPhones, ohne Signierung | GitHub Actions erfolgreich; siehe [Build-Nachweis](IOS_BUILD_RESULT.md) |
| Browserprüfung | Permanent Boost, Anzeige, Reset abbrechen/bestätigen sowie bisherige Bedienung bestanden |

Die neuen Tests prüfen Firmwarefreigaben, verkürzte Antworten, Konfiguration ohne Aufheizen, Reconnect ohne Konfigurationswrite, simulierte Gerätespeicherung, beide Anzeige-Polaritäten und Reset-Sperre bei eingeschaltetem Aufheizen. Layouts bei 320/390 Pixeln bleiben geprüft. Der Diagnose-Test scrollt nun zu den zusätzlichen Informationen. Der Browserlauf enthält keine JS-Fehler, fehlgeschlagenen oder externen Requests.

Aktuelle Protokolle: `docs/test-results/device-*`. Ältere Protokolle und Berichte unten sind historisch. Nativer iOS-Releasebuild erfolgreich; Analyse und 10 Fluttertests auch auf macOS bestanden. Android-Build, Installation auf einem iPhone, physisches BLE, Neustart-Persistenz und reale 90-Sekunden-Abläufe **nicht getestet**. Siehe HARDWARE_TESTS.md und DEVICE_SETTINGS.md.

## Historischer Testbericht · SB CONTROL 0.3.1

## Erneut geprüft für das Boost-Update

Stand 19.10.2026, Flutter 3.35.3 / Dart 3.9.2.

- `flutter analyze`: keine Probleme.
- `flutter test`: **10/10 bestanden**, einschließlich neuer Boost- und Persistenztests.
- `dart run tool/check_core.dart`: **48/48 bestanden**.
- Neue Tests: alle fünf Modelle, unabhängige variable Aufschläge, wiederholtes Antippen ohne Addition, Gerätegrenze, Basisrückkehr, Ausschalten mit Basisrückkehr, kein Wiederanlauf nach Reconnect, Speicherung je Gerätekennung.
- Flutter-Web-Releasebuild: erfolgreich; kompilierte Vorschau aktualisiert.
- Browserprüfung mit Chrome Headless Shell 155.0.8059.84: bestanden, einschließlich Boost/Superboost, wiederholtem Antippen und Basisrückkehr. Keine JavaScript-Fehler, fehlgeschlagenen oder externen Requests.
- Formatprüfung: 16 Dateien, keine Änderungen.
- Widgettests prüfen weiterhin alle Ansichten aller fünf Modelle bei 320 Pixeln.

Aktuelle Protokolle tragen das Präfix `boost-` in `docs/test-results/`. Die untenstehenden Ergebnisse ohne Präfix dokumentieren die vorherige Version 0.3.0. Hardware-, Android- und iOS-Tests wurden auch für dieses Update nicht durchgeführt.

## Vorheriger Teststand · SB CONTROL 0.3.0

Stand 19.10.2026. Getestet unter Linux mit Flutter 3.35.3 (Revision `a402d9a4376add5bc2d6b1e33e53edaae58c07f8`), Dart 3.9.2 und Chrome Headless Shell 155.0.8059.84. Flutter lief mit deaktivierter Telemetrie im unterstützten CI-Modus.

## Ausgeführt

| Prüfung | Ergebnis | Aussage |
|---|---|---|
| `flutter pub get` | Erfolgreich | Abhängigkeiten aufgelöst, pubspec.lock vorhanden |
| Dart-Formatprüfung | 15 Dateien, keine Änderungen | Format konsistent |
| `flutter analyze` | Keine Probleme | Statische Analyse inklusive nativem Dart-Adapter erfolgreich |
| `dart run tool/check_core.dart` | **48/48 bestanden** | Byteformate, Grenzen, Decoder, Identifikation, Warteschlange, fünf Demo-Profile |
| `flutter test` | **8/8 bestanden** | Sechs Controller- und zwei Widget-Tests |
| `flutter build web --release …` | Erfolgreich | Tatsächlicher Flutter-Releasebuild kompiliert; CanvasKit und Fonts lokal |
| `node tool/web_smoke.cjs` | Bestanden | Kompilierten Flutterbuild im Browser bedient; Details unten |
| Inline-Oberflächensimulation | 10 Interaktionsprüfungen bestanden | Modellwechsel/Navigation/Bedienung; Breiten 320/390/736 ohne horizontalen Überlauf |
| Plattformdateien | XML/plist/YAML parsebar | Manifeste, Storyboards und Workflow-Syntax geprüft; kein nativer Compilerlauf |

Die abschließenden Konsolenprotokolle liegen unter `docs/test-results/`. Browser-Screenshots wurden nur zur Sichtprüfung verwendet und nicht als Teil der Auslieferung gespeichert.

## Was die Tests abdecken

**Kern:** 16 aus ausgewählten Herstellerfunktionen erzeugte Schreibvektoren; Ablehnung ungültiger Temperatur-/Boostwerte und verkürzter Pakete; Firmwaregrenze; Anwendung/Bootloader; unbekannte Dienste; QVAP-Sensor-Sentinel und addierte Countdownbytes; Fahrenheit-Sonderfall; CRAFTY-Code+Auto-Off und Registererhalt; Warteschlangenreihenfolge/Invalidierung; Erkennung aller fünf simulierten Profile.

**Controller:** Vollständige simulierte Sitzungen für fünf Modelle mit Ziel, Heizung, Helligkeit, Vibration und modellabhängigen Einstellungen; Bootloader erhält nur Firmwareabfrage; CRAFTY-Fahrenheit-Schreiben gesperrt; unbestätigter Write stoppt Verbindung; Verbindungswechsel zwischen CRAFTY-Ziel/Boost darf keinen alten Write auf das nächste Gerät übertragen; Präferenzen persistieren Namen/Einheit, aber keinen Aktuatorzustand, Demo-Geräte oder personenbezogene Diagnosefelder.

**Widgets:** Native Startansicht und Navigation bei 390×844; alle vier Ansichten für alle fünf verbundenen Profile bei 320×740 inklusive Fahrenheit, jeweils auch gescrollt. Im Test gefundene Überläufe bei Einheitenauswahl, Temperatur und Verbindungsstatus wurden behoben.

**Flutter-Web-Browserlauf:** Zieltemperatur ändern, Heizung einschalten, Einheitenwechsel, alle fünf Modelle auswählen, HYBRID-Pumpe einschalten, Diagnose aktualisieren, Optionen bei 320 Pixeln anzeigen, Verbindung trennen. Keine JavaScript-Fehler, fehlgeschlagenen Requests, HTTP-Fehler oder externen Requests im abschließenden Durchlauf. Lokale Schrift-/Symbolressourcen beheben die zuvor im Browser beobachteten fehlenden Beschriftungen.

## Nicht ausgeführt

- Kein physischer Bluetooth-Scan, kein Pairing und keine GATT-Kommunikation mit echter Hardware.
- Kein Nachweis der Firmware-/Geräteserien-Kompatibilität, Write-/Readback-Latenz, Sensor-/Timer-Richtigkeit oder realen Heizer-/Pumpenreaktion.
- Kein Android-APK/AAB-Compile, kein iOS-Compile/Archive, keine Signierung und keine Store-Einreichung in dieser Umgebung.
- Kein GitHub-Push und kein ausgeführter GitHub-Actions-Lauf; Workflows sind vorbereitet.
- Keine VoiceOver-/TalkBack-Abnahme oder OS-Permission-Prüfung auf einem Telefon.

Die Simulatoren sind Testdoubles. Ihr Erfolg beweist Controller-/UI-Verhalten, nicht die Reaktion eines Vaporizer-Geräts. Die Bytevektoren stärken den Herstellerquellenabgleich, bleiben aber ebenfalls ohne Funkstrecke. Die vollständige offene Abnahmematrix steht in [HARDWARE_TESTS.md](HARDWARE_TESTS.md).
