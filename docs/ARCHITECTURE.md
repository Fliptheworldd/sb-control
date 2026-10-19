# Architektur

`lib/ui/app.dart` enthält Übersicht, Geräte, Diagnose und Optionen als Material-3-Widgetbaum mit nativen Hosts, ohne WebView. `AppController` koordiniert Scan, Sitzungen, Fähigkeiten, Daten und Aktionen.

`BleTransport` trennt Funk vom Simulator. Nativ arbeitet `flutter_reactive_ble`; der Webbuild bindet per Conditional Import einen Stub ein und startet ausdrücklich `DemoTransport`. Beide Modi nutzen dieselben Codecs und denselben Controller. Das native Plugin wird erst durch Scan/Connect initialisiert.

`lib/core/protocol.dart` enthält die dokumentierten Profile und Befehle. `SerialQueue` serialisiert GATT-Operationen. Ein Verbindungswechsel erhöht eine Generation und verwirft wartende Arbeit. Laufende OS-Operationen sind nicht sicher rückholbar; deshalb wird vor weiteren Writes und vor Übernahme einer Antwort erneut die Generation geprüft. CRAFTY-Ziel+Boost und Code+Auto-Off bleiben in einem Warteschlangeneintrag.

QVAP erfordert Firmwareabfrage und bestätigten Anwendungsmodus. Polling: QVAP ungefähr jede Sekunde, Attribute alle zwei Sekunden, ergänzend verfügbare Notifications. Steuerung erfordert einen höchstens acht Sekunden alten Status. Nach einer Aktion wird zurückgelesen und verglichen. Timeout/Abweichung stoppen die Sitzung ohne Aktuatorwiederholung.

Persistiert werden Gerätekennungen/-namen und Temperatureinheit, keine Heizung, Pumpe, Demo-Geräte oder wartenden Befehle. SharedPreferences ist lokaler Anwendungsspeicher, kein verschlüsselter Tresor; Android-Backup ist deaktiviert. Es gibt keine Sollzustandsregelung oder automatische Wiederverbindung.

Diagnose: bis zu 80 Ereignisse; Export ohne Namen, Adresse, Seriennummer, keine Uploadfunktion. Nach Trennung werden aktive Werte/GATT gelöscht. Ein danach erstellter Bericht rekonstruiert daher keine vollständige alte Sitzung. Bei Hardwaretests vor dem Trennen exportieren und Abbruchbeobachtungen separat dokumentieren.

Hintergrundwechsel trennt die native BLE-Sitzung, garantiert jedoch keine Geräteabschaltung. App und Gerät haben unabhängige Lebenszyklen; beim Fortsetzen wird kein alter Befehl ausgeführt.



## Korrektur ab 0.3.2

Die lokalen App-Boost-Stufen aus 0.3.1 sind entfernt. Alte appBoostPresets werden nicht mehr ausgewertet. Boost-Offets und neue QVAP-Schalter werden über denselben serialisierten BLE-Controller am Gerät gelesen/geschrieben. Die App hält keine aktive Boost-Stufe und benötigt keinen Hintergrundtimer für Permanent Boost. Der Simulator hält Geräteeinstellungen pro Gerätekennung innerhalb seiner Lebenszeit; das ersetzt keinen Hardware-Persistenztest.
