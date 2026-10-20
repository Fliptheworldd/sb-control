# Offene Hardwaretests

**Keine dokumentierte vollständige Hardware-Abnahme.** Der Nutzer berichtet, dass 0.3.2 auf seinem iPhone mit VENTY einschließlich Einstellungen funktioniert. Das ist ein hilfreicher Praxistest, aber ohne protokollierte Firmware-/Testmatrix keine Freigabe aller Modelle. Der Entwicklungsumgebung stehen keine physischen Geräte zur Verfügung. Quellenabgleich und Simulation ersetzen die folgende Abnahme nicht.

## Pflege 0.4.0 — noch am Telefon zu prüfen

- Erststart ohne Mitteilungsdialog; Einschalten einer Modellerinnerung fragt einmal nach Berechtigung.
- „Benachrichtigung testen“ im Vordergrund, Hintergrund und gesperrt: sichtbarer Hinweis, passender Modell-Pflegebereich beim Antippen. Android darf verzögert zustellen.
- Warmstart und vollständig beendete App durch Antippen einer Mitteilung; keine unerwünschte Geräteverbindung oder Heizaktivierung.
- Globaler und modellbezogener Aus-Schalter entfernen ausstehende Hinweise; Bestätigung einer Reinigung verlegt den nächsten Check.
- OS-Berechtigung ablehnen/entziehen/wieder erlauben, Fokusmodus, Android-Energiesparen, Telefonneustart, App-Update sowie Zeitzonen-/Sommerzeitwechsel prüfen.
- Pflegeplan nach App-Neustart vorhanden, auch ohne Bluetooth/Internet. Nutzer mit zwei Geräten desselben Modells auf gemeinsamen Modellplan hinweisen.
- Alle Anleitungen am tatsächlich vorhandenen Modell gegen dessen Bauform/Revision abgleichen. Keine reale Demontage oder chemische Reinigung für diese Änderung ausgeführt.
- VoiceOver/TalkBack und besonders große Schrift; Texte innerhalb einer Karte erreichbar, Weiter/Zurück unabhängig davon bedienbar.

| Gerät | Firmware erfassen | iOS BLE | Android BLE | Steuerung | Einstellungen | Abbruch/Fehler |
|---|---|---|---|---|---|---|
| VENTY | Offen | Offen | Offen | Offen | Offen | Offen |
| VEAZY | Offen | Offen | Offen | Offen | Offen | Offen |
| CRAFTY <2.51 | Offen | Offen | Offen | Sperren prüfen | Sperren prüfen | Offen |
| CRAFTY ≥2.51 | Offen | Offen | Offen | Offen | Offen | Offen |
| CRAFTY+ | Offen | Offen | Offen | Offen | Offen | Offen |
| VOLCANO HYBRID | Offen | Offen | Offen | Inkl. Pumpe offen | Offen | Offen |

Pro Kombination Telefonmodell, OS-Version, App-Commit, Geräte-/BLE-Firmware und Ergebnis erfassen. Seriennummern gehören nicht in öffentliche Issues.

## Prüfablauf

1. **Lesen vor Schreiben:** Dienste, Firmware, Akku, Temperatur, Restzeit und Betriebszeit gegen Gerät/Hersteller-App prüfen. Andere steuernde Apps schließen. Kaltes und bereits eingeschaltetes Gerät erfassen.
2. **Berechtigungen:** Erstinstallation, Erlaubnis, Ablehnung, Entzug; Bluetooth aus/ein. Android 24–30 mit Standortdiensten und ≥31 mit Scan/Connect. iOS CoreBluetooth-Freigabe. Keine Anfrage nur beim Öffnen der Startseite.
3. **Zieltemperatur:** Änderung um 1 °C, Geräteanzeige und Rücklesewert vergleichen. Grenzwerte separat prüfen. CRAFTY-Boost nach Zieländerung erhalten. Fahrenheit-Schreiben bleibt bis zu eindeutiger Verifikation gesperrt.
4. **Heizung/Pumpe:** Bewusst ein/aus, physische Reaktion und Antwortlatenz messen. HYBRID-Pumpe gesondert. Fehlende Bestätigung darf keinen automatischen Wiederholungsbefehl auslösen.
5. **Einstellungen:** Jede Option einzeln ändern, am Gerät/Herstellerclient rücklesen, Ausgangswert wiederherstellen. CRAFTY-Code+Auto-Off-Sequenz und fremde Registerbits gesondert erfassen. VEAZY-permanentes-BLE und Ladeoptionen pro Firmware prüfen.
6. **Abbruch:** Während Write, bei Modellwechsel während Mehrfach-Write, außer Reichweite, Hintergrund/Vordergrund, Ausschalten. Kein alter Befehl darf nach Wiederverbindung oder auf einem anderen Gerät ausgeführt werden. Hintergrundtrennung schaltet die Geräteheizung nicht automatisch aus.
7. **Unvollständige Profile:** Fehlende Merkmale, unbekannte Firmware, umbenanntes Gerät, gekürzte Antwort, ungültiger Sensorwert, leerer Akku, andere verbundene App. Fehlende Werte dürfen nicht als Messung erscheinen.
8. **QVAP-Modus:** Flags anhand Firmwareantwort kontrollieren. Bootloader nur prüfen, wenn das Gerät regulär bereits dort ist; keinen Update/Reset aus SB CONTROL zu Testzwecken auslösen. Vor Modusbestätigung ausschließlich Opcode 2.
9. **Bedienung:** VoiceOver/TalkBack, große Systemschrift, kleine Displays, Benennung und Diagnoseexport. Export ohne Namen, Adresse, Seriennummer.

## Ergebnisvorlage

| Feld | Eintrag |
|---|---|
| Datum / Prüfer / Commit | |
| Gerät / Firmware / BLE-Firmware | |
| Telefon / OS | |
| Testfall / Ausgangszustand | |
| Erwartete / beobachtete Bytes | |
| Reaktion am Gerät / Rücklesewert | |
| Latenz / Ergebnis / Abweichung | |

Freigabe erst nach erfolgreichen dokumentierten Ergebnissen für die tatsächlich beworbenen Modell-/Firmware-/OS-Kombinationen. Demo-Erfolg ist kein Hardware-Freigabekriterium.

## Zusätzliche Abnahme 0.3.2 (alle offen)

- VENTY V01.07 versus V01.08/V01.11: Permanent-Boost-Freigabe und Byte6-Länge. VEAZY separat prüfen.
- Beide Aufschläge ändern, App schließen/Bluetooth aus, Stufen an der Gerätetaste aufrufen. Gerätegrenze und Werte nach Neustart prüfen.
- Permanent Boost aus: Rücksprung nach90s. An: kein90s-Rücksprung; automatische Abschaltung unverändert. Beide Zustände nach Reconnect/Stromzyklus prüfen.
- Boost-Anzeige an/aus und VEAZY-Inversion physisch abgleichen; andere Settings müssen erhalten bleiben.
- Reset abbrechen: kein Write. Bestätigen: Defaults nachlesen und mit Hersteller-App vergleichen; keine Heizaktivierung.
- Analyse mit bekannten Fehlern und ohne Fehler; kein Cloudverkehr.
- iOS/Android: Berechtigung verweigert, Bluetooth aus, Scan/Verbindung, App-Hintergrund, Funkverlust, Reconnect ohne Einstellungswrite.

## Zusätzliche Abnahme 0.6.0 — offen

- Beide Aufschläge auf der Steuerungsseite ändern: vor „Auf Gerät speichern“ keine Geräteänderung, danach korrekte Bestätigung und exakte Werte in der Hersteller-App.
- Bluetooth trennen, App vollständig schließen, Boost und Superboost an der physischen Taste aktivieren. Danach Gerät aus-/einschalten und gespeicherte Aufschläge erneut vergleichen. Reconnect-Simulation beweist keine Persistenz über einen echten Stromzyklus.
- Verbindung während des Speicherns abbrechen: keine falsche Erfolgsmeldung, keine automatisch wiederholten Writes. Bei Teilübertragung nach Wiederverbindung beide gelesenen Werte prüfen.
- Gespeichertes und neu gefundenes Gerät antippen: Erfolg öffnet Steuerung, Fehler bleibt in Geräteansicht. Bereits verbundenes Gerät ohne neue Verbindung öffnen.
- Android-Italienisch: Matteo-Zeile sichtbar; deutsche iPhone-Version ohne diese Zeile. Kein Demo-Einstieg/Schalter auf beiden Telefonen.
- Originalfotos, Lesbarkeit bei großer Schrift sowie VoiceOver/TalkBack auf den echten Telefonen prüfen.
