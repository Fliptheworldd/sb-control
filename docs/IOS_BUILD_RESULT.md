# iPhone-Testbuild 0.4.0 (6)

Stand: 20.10.2026. [GitHub-Actions-Build erfolgreich](https://github.com/Fliptheworldd/sb-control/actions/runs/39351218993), Quellcommit `4766a26ad9f08a6b7632e4d0068285b149f82159`.

- macOS 15, Flutter 3.35.3; statische Analyse ohne Befund und 24 Flutter-Tests bestanden.
- Release für physische iPhones erfolgreich gebaut, ohne Signierung und ohne Apple-Zugangsdaten.
- Artefakt `SB-Control-iPhone-unsigned` enthält IPA und SHA256-Datei. Der Download wurde als `SB-Control-0.4.0-iPhone.zip` bereitgestellt.
- ZIP/IPA-Integrität und deklarierte Prüfsumme geprüft. Info.plist bestätigt Version `0.4.0`, Build `6`, Bundle-ID `de.vachsystems.sbcontrol`, Plattform `iPhoneOS`, Mindestversion iOS 13.0.
- Framework `flutter_local_notifications` ist enthalten. Kein eingebettetes Provisioning-Profil; persönliche Signierung bleibt erforderlich, z. B. wie bisher mit Sideloadly.

IPA SHA256:
```
fd6a7ab0e80fff4299c19eb510878b12bfb900f5ca6bc767a8eee27baefba818
```

ZIP SHA256:
```
c73353d66303369cf375f1dc58dba98af43e110be7779498f7e4fdae35ed75aa
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
