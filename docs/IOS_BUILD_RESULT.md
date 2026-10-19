# iPhone-Testbuild 0.3.2 (5)

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
