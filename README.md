# SB CONTROL · 0.3.2

Native Flutter-App für iOS und Android auf Basis des gelieferten Quellcodes v0.2. Dunkles Design mit Orange, lokale Geräteverwaltung und direkte Bluetooth-LE-Kommunikation ohne Konto oder Backend.

**Implementiert und in Simulation getestet. Kein physisches Gerät wurde getestet.** Bluetooth-Befehle sind gegen die öffentliche STORZ & BICKEL Web-App v3.4.1 geprüft. Das ist keine Herstellerfreigabe oder Garantie für alle Firmwarestände.

**iPhone-Testbuild erfolgreich erstellt:** Release für echte iPhones, Version 0.3.2 (5), noch unsigniert. [Build-Nachweis](docs/IOS_BUILD_RESULT.md) · [Installation über Windows](docs/IPHONE_WINDOWS.md).

## Neu in 0.3.2

Konfiguration direkt am Gerät: Boost-/Superboost-Aufschläge, Permanent Boost (90-Sekunden-Rücksprung deaktivieren), Boost-Anzeige und bestätigter Einstellungen-Reset für VENTY/VEAZY. Die doppelten lokalen App-Boost-Stufen aus 0.3.1 wurden entfernt. Beim Verbinden werden vorhandene Gerätewerte gelesen, nicht mit App-Vorgaben überschrieben. „Aufheizen“ bleibt als optionale direkte Bedienung erhalten.

VENTY: Permanent Boost ist auf erkannte 1.xx-Firmware ab 1.08 mit gültiger Einstellungsantwort begrenzt; VEAZY nutzt seine eigene Freigabe und invertierte Anzeige-Bitlogik. CRAFTY/+ und HYBRID erhalten keine spekulativen QVAP-Funktionen. Weitere Details: [Geräteeinstellungen](docs/DEVICE_SETTINGS.md).

## Funktionen

- Geräte suchen, verbinden, lokal benennen, speichern und entfernen; erneute Verbindung bewusst durch Antippen.
- Dashboard mit Zieltemperatur, Aufheizen, verfügbaren Messwerten, Akku, Abschaltung und Betriebszeit; HYBRID zusätzlich mit Pumpenschalter.
- Modellabhängige Einstellungen und Diagnose mit Firmware, GATT-Tabelle, Ereignissen und kopierbarem JSON ohne Gerätename, Geräteadresse oder Seriennummer.
- Expliziter Demo-Modus mit fünf simulierten Geräten. Bluetoothfehler wechseln niemals automatisch zur Simulation.
- Vollständige iOS-/Android-Hosts, kompilierte Web-Demo, Tests und GitHub-Actions-Workflows.

| Modell | Temperatur | Aufheizen | Zusätzliche Steuerung |
|---|---:|---|---|
| VENTY | 40–210 °C | Nach Prüfung des Anwendungsmodus | Boost/Superboost-Offset, Permanent Boost, Boost-Anzeige, Reset, Helligkeit, Vibration, Ladeoptionen |
| VEAZY | 40–210 °C | Nach Prüfung des Anwendungsmodus | Wie VENTY; zusätzlich dauerhaftes Bluetooth, wenn im Status vorhanden |
| CRAFTY | 40–210 °C | Ab erkannter Firmware 2.51 | Boost, Helligkeit; Vibration/Abschaltung bei freigegebenem Profil |
| CRAFTY+ | 40–210 °C | Bei erkannter moderner Firmware | Wie CRAFTY; gemeinsames GATT-Protokoll |
| VOLCANO HYBRID | 40–230 °C | Ja | Pumpe, Helligkeit, Vibration, Abschaltung |

Die Tabelle beschreibt implementierte Funktionen, keine Hardwarefreigabe. Fehlende oder uneindeutige Merkmale sperren die jeweilige Bedienung. CRAFTY-Fahrenheit-Rückmeldungen sperren Temperatur-Schreibzugriffe. Nicht übertragene Isttemperaturen erscheinen als „Nicht übertragen“.

## Starten

Getestet mit **Flutter 3.35.3 / Dart 3.9.2**. Android benötigt Java 17 und das Android SDK; iOS benötigt macOS, Xcode und CocoaPods.

```sh
flutter pub get
dart run tool/check_core.dart
flutter analyze
flutter test
flutter run
```

Die native App startet ohne aktive Verbindung. Im Tab „Geräte“ suchen und verbinden. „Mit Demo-Geräten ausprobieren“ startet die Simulation. Alternativ:

```sh
flutter run --dart-define=SB_DEMO=true
```

## Bedienbare Vorschau

Das Auslieferungs-ZIP enthält unter `preview/web/` einen kompilierten **Flutter-Web-Releasebuild derselben Oberfläche und desselben Controllers**. Bluetooth ist dort durch den Simulator ersetzt. Alle Werte sind simuliert.

```sh
python3 -m http.server 8080 --directory preview/web
# http://localhost:8080 im Browser öffnen.
```

Nach einem Git-Klon neu erzeugen:

```sh
flutter build web --release --no-web-resources-cdn --pwa-strategy=none --dart-define=SB_DEMO=true
python3 -m http.server 8080 --directory build/web
```

Schrift und CanvasKit sind lokal eingebunden. Der Webbuild ist eine Bedienvorschau ohne Web-Bluetooth. Die zusätzliche Vorschau in der Unterhaltung ist eine kompakte Oberflächensimulation.

## Dokumentation

- [Protokolle, Quellen und Byteformate](docs/PROTOCOLS.md)
- [Testbericht und Grenzen](docs/TEST_REPORT.md)
- [Hardware-Abnahmeplan](docs/HARDWARE_TESTS.md)
- [Builds, Signierung und GitHub](docs/BUILD.md)
- [Architektur](docs/ARCHITECTURE.md)
- [Änderungen](CHANGELOG.md) und [Herkunft/Lizenzen](NOTICE.md)

Bei Verbindungsabbruch oder Hintergrundwechsel hält die App ihre Steuerung an. Das ist **kein bestätigter Ausschaltbefehl an das Gerät**. Das Gerät und seine eigene Abschaltung bleiben maßgeblich. Firmware-Updates, Factory Reset, Cloud-Diagnose und automatische Heizabläufe sind nicht implementiert.

## iPhone-Test mit Windows

Der Workflow **iPhone IPA for local signing** erstellt eine noch unsignierte IPA für echte iPhones. Danach erfolgt die persönliche Signierung und Installation lokal unter Windows. Siehe [Anleitung](docs/IPHONE_WINDOWS.md). Der bisherige Simulator-Workflow bleibt separat.
