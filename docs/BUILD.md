# Builds und GitHub

| Bestandteil | Projektstand |
|---|---|
| Flutter / Dart | 3.35.3 / 3.9.2, hier ausgeführt |
| Android | minSdk 24 (Android 7), Compile/Target aus Flutter 3.35.3 (36), Java 17 |
| Gradle / AGP / Kotlin | 8.12 / 8.9.1 / 2.3.0 |
| iOS | Ziel 13.0; macOS, Xcode und CocoaPods erforderlich |
| App-/Bundle-ID | `de.vachsystems.sbcontrol`, vor Signierung auf eigene registrierte Kennung prüfen |
| Abhängigkeiten | Direkte Versionen in pubspec.yaml, Auflösung in pubspec.lock |

Kotlin 2.3.0 entspricht dem aufgelösten `shared_preferences_android` 2.4.23. `flutter_reactive_ble` 5.4.2 wurde für Dart 3.9 gewählt. Updates mit erneutem Test- und Lockfile-Review. Native Builds laufen inzwischen über GitHub Actions: Android auf Ubuntu, iPhone auf macOS. Der lokale Linux-Arbeitsplatz führt Flutter-Tests, Analyse und die kompilierte Web-Vorschau aus.

## Entwicklung

```sh
flutter --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
dart run tool/check_core.dart
flutter analyze
flutter test
flutter devices
flutter run -d DEVICE_ID
```

Bluetooth wird erst bei Scan/Connect angefordert. Android ≥31 nutzt Scan/Connect; ältere unterstützte Versionen Standortfreigabe für BLE-Scan. iOS nutzt CoreBluetooth und die Usage Descriptions in Info.plist. Hintergrund-BLE ist nicht aktiviert.

## Android

```sh
flutter build apk --debug --dart-define=SB_LANGUAGE=it --dart-define=SB_MATTEO=true
```

Die Freundesausgabe ist italienisch. `SB_MATTEO=true` ergänzt nur unter Android die persönliche Zeile. Ohne diese Defines ist die App deutsch. Die native App kann durch `SB_DEMO` nicht in Simulation geschaltet werden.

Für Release eigenen Keystore verwalten und `android/key.properties.example` lokal nach `android/key.properties` kopieren. Echte Werte eintragen, Schlüssel/Kennwörter nie committen. `storeFile` ist relativ zu `android/app/` oder ein absoluter Pfad.

```sh
flutter build appbundle --release
```

Ohne Release-Schlüssel kein Rückfall auf Debug-Signierung. Ein unsigniertes Artefakt ist kein installierbarer Release. Version/-code stammen aus pubspec.yaml. Das Produktionsmanifest fordert kein Internet an; Debug/Profile dürfen für Flutter-Entwicklung Internet erlauben.

## iOS

```sh
flutter pub get
cd ios
pod install
cd ..
flutter build ios --release --no-codesign
open ios/Runner.xcworkspace
```

Eigenes Team, registrierte Bundle-ID und Signing in Xcode wählen. Auf echtem iPhone testen; erst nach Abnahme signierten Export über Xcode oder `flutter build ipa --release` erstellen. Der erste erfolgreiche macOS-Build erzeugt `ios/Podfile.lock`; dieses danach prüfen und committen.

Kompilierbarkeit garantiert keine Store-Zulassung. Die [Apple App Review Guidelines 1.4.3](https://developer.apple.com/app-store/review/guidelines/#physical-harm) schränken Apps ein, die Tabak-/Vape-Nutzung fördern. Den konkreten Vertriebspfad vor Veröffentlichung anhand der dann geltenden Regeln prüfen. App-Store-/TestFlight-Verfügbarkeit wird nicht zugesagt.

## GitHub

Repository: https://github.com/Fliptheworldd/sb-control
Aktuelle Erweiterung: PR #2, `feature/design-italiano` auf `feature/cleaning-care`.

- `verify.yml`: Format, Kernprüfungen, Analyse, Flutter-Tests und interne deutsche Web-Vorschau.
- `mobile-builds.yml`: Android-APK bei relevanten Pull Requests; zusätzlich italienische Tests mit Matteo-Flag. Simulator-Build nur beim passenden manuellen Aufruf.
- `ios-device.yml`: deutsche unsignierte IPA für echte iPhones auf macOS. Kein italienisches Sprach- oder Matteo-Flag.

APK und IPA liegen nach erfolgreichen Jobs als Actions-Artefakte vor, jeweils
14 Tage aufbewahrt. Kein Store-Upload und keine Apple-/Release-Schlüssel im Repo.
Die Android-APK ist debug-signiert; für dauerhafte Update-Kompatibilität später
einen eigenen stabilen Schlüssel verwenden. Die IPA wird anschließend lokal mit
Sideloadly signiert und installiert; Anleitung unter `IPHONE_WINDOWS.md`.
