# SB CONTROL – Entwicklungsstand 0.2.0

Flutter-Quellcode für eine unabhängige iOS-/Android-App zur BLE-Geräteerkennung.

## Bereits umgesetzt
- Dunkles Orange/Anthrazit-Design mit vier Navigationsbereichen
- BLE-Suche mit Filter für VENTY, VEAZY, CRAFTY und VOLCANO
- BLE-Verbindungsaufbau, Trennung, Dienst- und Merkmalübersicht
- Kein Backend; keine Geräte-Schreibbefehle

## Noch NICHT umgesetzt
- Gerätespezifische Protokolle und echte Temperatur-/Boost-Steuerung
- Automatische Wiederverbindung, Nutzungsprofile, Firmware-Updates
- Hardwaretests, Release-Builds und Store-Zulassung

## Projekt vervollständigen und starten
Flutter SDK (3.24+ empfohlen) und Android Studio oder Xcode installieren.
Im Projektordner `flutter create --platforms=android,ios .` ausführen,
danach `flutter pub get` und `flutter run`.
Die BLE-Berechtigungen in den vorhandenen Android/iOS-Notizen prüfen und in
die von Flutter generierten Plattformdateien übernehmen. Android benötigt
BLUETOOTH_SCAN/CONNECT, iOS NSBluetoothAlwaysUsageDescription.

**Sicherheit:** Unbekannte BLE-Merkmale dürfen nicht auf Verdacht beschrieben
werden. Steuerbefehle erst nach unabhängiger Protokollprüfung implementieren.

**Hinweis:** Dieser Quellcode wurde in dieser Umgebung nicht kompiliert oder
auf realer Hardware getestet. Die ZIP ist kein fertiges APK/IPA.
