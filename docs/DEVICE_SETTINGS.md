# Geräteeinstellungen · 0.3.2

Ziel: Verbinden, Einstellungen ändern, danach das Gerät über seine eigenen Tasten nutzen. Die App liest Basis, Boost und Superboost sowie verfügbare Schalter aus dem Gerät. Eine Verbindung sendet keine Einstellungsänderung. Änderungen werden explizit geschrieben und rückgelesen; bei fehlender Bestätigung wird getrennt, kein Befehl wiederholt.

- Aufschläge: Geräteeinstellungen statt separater App-Presets. VENTY/VEAZY 1–99 °C entsprechend Herstellerclient. CRAFTY/+ weiterhin gerätespezifisch; HYBRID hat keine erfundenen Boost-Schalter.
- Boost-Temperatur halten: vorhandenen Gerätezustand anzeigen; nur nach Benutzereingriff ändern. Aktiviert Permanent Boost für Boost und Superboost gemeinsam. Die normale Geräteabschaltung bleibt unabhängig.
- Boost-Anzeige: VENTY blinkendes °C/°F, VEAZY modellabhängige Anzeige. Unterschiedliche Bitpolarität berücksichtigt.
- Reset: nur VENTY/VEAZY, ausgeschaltetes Aufheizen, Bestätigungsdialog. Aktuellen Status und Einstellungen nachlesen. Keine Firmwareänderung.
- Geräteinformationen: Seriennummer, Laufzeit, Firmware/Bootloader anzeigen. Export enthält weiterhin keine Seriennummer oder Geräteadresse.
- Geräteanalyse: lokale QVAP-Fehlerkategorie auslesen; kein Upload an S&B, keine Behauptung vollständiger Hardwarediagnose.

## Bluetooth-Stand

Die native Flutter-App nutzt flutter_reactive_ble: Scan, Verbindungsaufbau, Dienstsuche, Notifications, GATT Read/Write. Android-Berechtigungen unterscheiden API31+ (Scan/Connect) und ältere Systeme (Standort); iOS nutzt CoreBluetooth mit Zwecktexten in Info.plist. Adapterstatus, Timeouts, verlorene Verbindungen und Rückleseabweichungen werden behandelt. Die Web-Vorschau nutzt ausschließlich DemoTransport.

Kein echter iOS-/Android-Build oder Funkstreckentest in dieser Umgebung. Keine Garantie der Gerätekompatibilität vor Abnahme. Physische Tests müssen insbesondere zeigen, dass geänderte Einstellungen nach App-Schließen, Bluetooth-Trennung und Geräte-Neustart erhalten bleiben und der Timeout am Gerät wie erwartet arbeitet.
