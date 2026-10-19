# Offene Hardwaretests

**Kein Test wurde an einem physischen Gerät durchgeführt.** Weder Vaporizer noch iPhone/Android-Telefone mit zugänglichem Bluetooth-Adapter standen zur Verfügung. Quellenabgleich und Simulation ersetzen diese Abnahme nicht.

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
