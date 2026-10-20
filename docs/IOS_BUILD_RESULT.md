# iPhone-Testbuild 0.4.0 (6)

Stand: 20.10.2026. [GitHub-Actions-Build erfolgreich](https://github.com/Fliptheworldd/sb-control/actions/runs/39350020945), Quellcommit `609a0bfcfefb2f3e50a24a40d5cee9e8c704b00b`.

- macOS 15, Flutter 3.35.3; statische Analyse ohne Befund und 24 Flutter-Tests bestanden.
- Release für physische iPhones erfolgreich gebaut, ohne Signierung und ohne Apple-Zugangsdaten.
- Artefakt `SB-Control-iPhone-unsigned` enthält IPA und SHA256-Datei. Der Download wurde als `SB-Control-0.4.0-iPhone.zip` bereitgestellt.
- ZIP/IPA-Integrität und deklarierte Prüfsumme geprüft. Info.plist bestätigt Version `0.4.0`, Build `6`, Bundle-ID `de.vachsystems.sbcontrol`, Plattform `iPhoneOS`, Mindestversion iOS 13.0.
- Framework `flutter_local_notifications` ist enthalten. Kein eingebettetes Provisioning-Profil; persönliche Signierung bleibt erforderlich, z. B. wie bisher mit Sideloadly.

IPA SHA256:
```
87a5260edb64e9d371e7f01f0a4d8dbd173d5d5908c2e3acbd461aed0be69d2e
```

ZIP SHA256:
```
03071403db9a73cadf1ead5dbec4aa4636262d3bfdd93c081d4984e7032c1ef9
```

Die neue Pflegefunktion ist noch nicht auf einem physischen Telefon abgenommen. Der frühere erfolgreiche VENTY-Test des Nutzers bezog sich auf 0.3.2. Insbesondere Mitteilungsberechtigung, tatsächliche Zustellung und das Öffnen der richtigen Anleitung über eine Mitteilung sind zu prüfen; siehe [Hardwaretests](HARDWARE_TESTS.md).

## Historischer iPhone-Testbuild 0.3.2 (5)

Stand: 19.10.2026. Der gesamte GitHub-Actions-Job ist erfolgreich abgeschlossen.

- Quellcommit: `f0dce19ec0ec7bfd93f4d639f785a593ab25ca81`
- Workflow: `.github/workflows/ios-device.yml`, macOS 15, Flutter 3.35.3.
- [Erfolgreicher Buildlauf](https://github.com/Fliptheworldd/sb-control/actions/runs/39238341611)
- `flutter analyze`: bestanden; `flutter test`: 10 Tests bestanden.
- `flutter build ios --release --no-codesign --dart-define=SB_DEMO=false`: erfolgreich.
- Artefakt: `SB-Control-iPhone-unsigned`, enthält IPA und SHA256-Datei.

Die heruntergeladene ZIP und die IPA wurden auf Integrität geprüft. Die IPA enthält `Payload/Runner.app`, das native BLE-Framework und den Bluetooth-Zwecktext. Bundle-ID: `de.vachsystems.sbcontrol`, Plattform: `iPhoneOS`, Mindestversion: iOS 13.0.

IPA SHA256:
```
4ffaadd7840af547d19f025ec26539822d8e6550087c01273ec1ab979de2de11
```

Die IPA ist **unsigniert**. Installation erfordert Signierung, beispielsweise lokal über Sideloadly auf Windows; siehe [Anleitung](IPHONE_WINDOWS.md). Es wurden keine Apple-Zugangsdaten für den Cloud-Build benötigt.

Noch nicht durchgeführt: Signierung, Installation und Start auf einem physischen iPhone, Bluetooth-Verbindung zu echten Geräten, Persistenz der Einstellungen nach Trennung/Neustart und realer Permanent-Boost-/90-Sekunden-Test. Ein erfolgreicher Build bestätigt keine Gerätekompatibilität. Die übrigen Prüfungen stehen im [Testbericht](TEST_REPORT.md), die Hardwareabnahme in [HARDWARE_TESTS.md](HARDWARE_TESTS.md).
