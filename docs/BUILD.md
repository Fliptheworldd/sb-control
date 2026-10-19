# Builds und GitHub

| Bestandteil | Projektstand |
|---|---|
| Flutter / Dart | 3.35.3 / 3.9.2, hier ausgeführt |
| Android | minSdk 24 (Android 7), Compile/Target aus Flutter 3.35.3 (36), Java 17 |
| Gradle / AGP / Kotlin | 8.12 / 8.9.1 / 2.3.0 |
| iOS | Ziel 13.0; macOS, Xcode und CocoaPods erforderlich |
| App-/Bundle-ID | `de.vachsystems.sbcontrol`, vor Signierung auf eigene registrierte Kennung prüfen |
| Abhängigkeiten | Direkte Versionen in pubspec.yaml, Auflösung in pubspec.lock |

Kotlin 2.3.0 entspricht dem aufgelösten `shared_preferences_android` 2.4.23. `flutter_reactive_ble` 5.4.2 wurde für Dart 3.9 gewählt. Updates mit erneutem Test- und Lockfile-Review. Hier wurde **kein Android-/iOS-Build abgeschlossen**: Eine vollständige Android-SDK-/JDK- bzw. Xcode-/CocoaPods-Buildumgebung fehlte.

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
flutter build apk --debug
```

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

Quellen, Tests, pubspec.lock, Gradle-Wrapper, .gitignore und zwei Workflows liegen vor:

- `verify.yml`: Formatierung, Kernprüfungen, Analyse, Flutter-Tests und Web-Releasebuild bei Push/PR; Webbuild als Actions-Artefakt.
- `mobile-builds.yml`: manuell startbare Android-Debug-APK und iOS-Simulator-Builds. Vorbereitet, hier nicht auf GitHub ausgeführt. Keine Veröffentlichung oder Signing-Secrets.

Das Projekt wurde nicht zu GitHub übertragen. Nach Anlegen des gewünschten Repositories:

```sh
git init -b main
git add .
git commit -m "Implement SB CONTROL native Flutter app"
git remote add origin YOUR_GITHUB_REMOTE
git push -u origin main
```

`preview/web/` ist im ZIP enthalten, bleibt aber aus Git ausgeschlossen; CI baut es neu. Caches, lokale SDK-Pfade, Pods und Schlüssel bleiben ausgeschlossen. Der Rechteinhaber legt die Projektlizenz fest (siehe NOTICE.md).

## Browserprüfung

Nach Webbuild, mit Node.js und Playwright als reine Entwicklungswerkzeuge:

```sh
npm install --no-save playwright
npx playwright install chromium
node tool/web_smoke.cjs
```

`SB_CHROME` setzt einen bereits installierten Chromium-/Headless-Shell-Pfad, `SB_WEB_DIR` ein alternatives Buildverzeichnis. Der Test startet und beendet seinen lokalen Server selbst.
