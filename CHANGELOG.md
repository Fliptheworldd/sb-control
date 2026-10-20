# Änderungen

## 0.4.0 — 20.10.2026

- Offline-Pflegebereich mit schematischen Bildkarten für VENTY, VEAZY, CRAFTY, CRAFTY+ und VOLCANO HYBRID.
- Modellbezogene Herstellerquellen, Reinigungsmittelgrenzen und Besonderheiten beim Zerlegen/Zusammenbauen.
- Lokale iOS-/Android-Erinnerungen nach ausdrücklichem Einschalten; automatisch wöchentlich, ohne Intervall-/Uhrzeitwahl oder Kalender.
- Bestätigte Reinigung startet den Pflegecheck neu; Hinweise global und pro Modell abschaltbar. Berechtigungsfehler bleiben sichtbar.
- Keine neuen Bluetooth-Befehle, kein behaupteter Verbrauchszähler, kein Hintergrundzugriff auf das Gerät.
- 24 Flutter-Tests inklusive Pflege, Berechtigungen, Speicherfehlern, konkurrierenden Änderungen und kleinen Displays; 56 Protokollprüfungen.
- Pull Requests erhalten einen unsignierten iPhone-Build und Android-Debug-Build zur Integrationsprüfung.

## 0.3.2
- Geräteeinstellungen statt lokaler App-Boost-Stufen; vorhandene Werte beim Verbinden auslesen.
- QVAP Permanent Boost, modellabhängige Boost-Anzeige, bestätigter Reset mit Rücklesen.
- Seriennummer und Betriebszeit in der Geräteansicht; Seriennummer bleibt aus Diagnoseexporten entfernt.
- Geräteanalyse liest QVAP-Fehlerkategorie; keine Hersteller-Cloudübertragung.
- 24 Herstellervektoren, 56 Kernprüfungen, 10 Flutter-Tests; Hardwareabnahme weiter offen.

## 0.3.1 — 19.10.2026

- Aufheizen/Stoppen statt Heizungsbeschriftung.
- Direkte Basis-/Boost-/Superboost-Buttons, zwei frei einstellbare lokale Aufschläge pro Gerät.
- Ausschließlich bereits belegte Temperatur- und Ein/Aus-Befehle; keine neuen Modus- oder Registerbefehle.
- Rückkehr zur Basis, Begrenzung an der Gerätegrenze, keine Addition durch wiederholtes Tippen und kein Wiederholen nach Reconnect.


## 0.3.0 — 19.10.2026

- v0.2-Entwurf im Dark-/Orange-Design zu einer Flutter-App mit iOS-/Android-Hosts ausgebaut.
- Geräteverwaltung, drei BLE-Protokollfamilien für fünf Modelle, Dashboard, Einstellungen und Diagnose implementiert.
- Herstellerquellen abgeglichen, Bytevektoren erzeugt, Firmware-/GATT-Sperren, Readback und serialisierte Writes ergänzt.
- flutter_blue_plus durch flutter_reactive_ble ersetzt.
- Simulator, Flutter-Web-Vorschau, Tests und GitHub-Workflows ergänzt.
- Offene native Builds und Hardwareabnahme dokumentiert.

Originaldateien unverändert unter `docs/original-v0.2/`; vom Analyzer ausgeschlossen und nicht in die App eingebunden.
