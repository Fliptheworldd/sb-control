# Bluetooth-Protokolle und Nachweise

Prüfstand: 19.10.2026. **Quellenabgleich bestanden; physische BLE-Aufzeichnungen und Hardwaretests fehlen für alle fünf Modelle.**

## Methode und Quellen

Primärquelle ist die öffentlich ausgelieferte [STORZ & BICKEL Web-App](https://app.storz-bickel.com). Die geprüften Dateien weisen sich als Version 3.4.1 aus:

| Datei | Quelle | Verwendung |
|---|---|---|
| main.js | https://app.storz-bickel.com/js/main.js | Little-Endian-Konvertierung, Modell-/UI-Grenzen |
| qvap.js | https://app.storz-bickel.com/js/qvap.js | VENTY **und VEAZY**, Modusprüfung, Paketprotokoll |
| crafty.js | https://app.storz-bickel.com/js/crafty.js | CRAFTY/CRAFTY+, Firmwaregrenze, Attribute |
| volcano.js | https://app.storz-bickel.com/js/volcano.js | HYBRID, Schreibbreiten, Heizung/Pumpe, Register |

Hashes stehen in `test/fixtures/vendor_vectors.json`. `tool/vendor_vectors.mjs` führt 24 ausgewählte Herstellerfunktionen mit gemocktem GATT aus. `tool/check_core.dart` prüft deren Bytes gegen die unabhängig entwickelten Dart-Encoder. Dies sind **ausgeführte Referenzvektoren, keine Gerätemitschnitte**. Registermasken und weitere Abfragen wurden direkt im Herstellerclient kontrolliert. Proprietärer Herstellerquellcode wird nicht mitgeliefert.

Sekundär abgeglichen: [reactive-volcano-app-Protokolldokumentation](https://firsttris.github.io/reactive-volcano-app/docs/protocol.html), [VENTY-Spezifikation](https://github.com/SavageNL/home-assistant-volcano-hybrid/blob/main/VENTY_BLE_SPEC.md), [CRAFTY-Spezifikation](https://github.com/SavageNL/home-assistant-volcano-hybrid/blob/main/CRAFTY_BLE_SPEC.md), [HYBRID-Spezifikation](https://github.com/SavageNL/home-assistant-volcano-hybrid/blob/main/VOLCANO_BLE_SPEC.md). Auch dies sind Reverse-Engineering-Dokumente. VENTY-Dokumentation allein belegt VEAZY nicht; dessen gemeinsame Behandlung wurde ausdrücklich im Herstellerclient geprüft.

## UUIDs und Erkennung

UUIDs unten: achtstelliger Präfix plus Suffix. `SB` = `-5354-4f52-5a26-4249434b454c`; `C` = `-4c45-4b43-4942-265a524f5453`.

| Familie | Dienste | Erkennung |
|---|---|---|
| VENTY/VEAZY | `00000000+SB` | Zusätzlich Name VENTY / `S&B VY…` bzw. VEAZY / `S&B VZ…`. Gemeinsamer Dienst allein genügt nicht. |
| CRAFTY/+ | `00000001+C`, `00000002+C`, optional `00000003+C` | Gemeinsames Protokoll. Firmware-Hauptversion ≥3 kennzeichnet CRAFTY+ laut Herstellerclient; Zuordnung an Hardware noch offen. |
| HYBRID | `10100000+SB`, `10110000+SB` | Beide Dienste müssen vorhanden sein. |

Ein Name allein erlaubt keine Schreibzugriffe. Jede Operation prüft Dienst, eindeutiges Merkmal und Schreibfähigkeit. Unbekannte/umbenannte QVAP-Modelle bleiben im Diagnosezustand.

## VENTY und VEAZY: QVAP

Write-/Notify-Merkmal `00000001+SB` im Dienst `00000000+SB`. Bytepositionen beginnen bei 0; ungenannte Bytes sind 0. Eine Operation gleichzeitig, Antwortzuordnung über Opcode, Timeout 5 Sekunden.

**Zuerst nur Firmwareabfrage `02` im 20-Byte-Paket.** Antwort mindestens 19 Bytes: Byte 1 muss Bit `0x01` gesetzt haben; `0x10` und `0x20` müssen gelöscht sein. Sonst trennen. Opcode `01` hat im Bootloader eine andere Bedeutung und darf vorher nicht gesendet werden.

| Funktion | Paket | Beleg in qvap.js |
|---|---|---|
| Status | 20 Byte: `[0]=1`, `[1]=0` | `periodicIntervalFunc`, `parseBLEResponse` |
| Basis-Zieltemperatur | 20 Byte: `[0]=1`, `[1]=2`, `[4..5]=°C×10 uint16LE`, 40–210 °C | `writeSollTemperatureQVap` |
| Heizung | 20 Byte: `[0]=1`, `[1]=32`, `[11]=1/0` | `onHeatClickQvap` |
| Boost-Offset | 20 Byte: `[0]=1`, `[1]=4`, `[6]=1..99 °C` | `writeBoostTemperatureQVap` |
| Superboost-Offset | 20 Byte: `[0]=1`, `[1]=8`, `[7]=1..99 °C` | `writeSuperBoostTemperatureQVap` |
| Einstellungen lesen | 7 Byte: `[0]=6` | `QVapReadBrightnessAndVibration` |
| Helligkeit | 7 Byte: `[0]=6`, `[1]=1`, `[2]=1..9` | `writeBrightnessQvap` |
| Vibration | 7 Byte: `[0]=6`, `[1]=8`, `[5]=1/0` | `vibrationToggleHandlerQvap` |
| Reduzierter Ladestrom | 20 Byte: `[0]=1`, `[1]=128`, `[14]=8/0`, `[15]=8` | `chargeOptimizationFunc` |
| Ladelimit | 20 Byte: `[0]=1`, `[1]=128`, `[14]=32/0`, `[15]=32` | `chargeLimitFunc` |
| Permanentes BLE, nur VEAZY | 20 Byte: `[0]=1`, `[1]=128`, `[16]=1/0`, `[17]=1` | VEAZY-Zweig des Bluetooth-Schalters |
| Fehlerkategorie | 20 Byte: `[0]=3` | `startAnalysisQvapFunc`, Antwortfall 3 |
| Laufzeit | 20 Byte: `[0]=4` | `periodicIntervalFunc`, Antwortfall 4 |
| Geräteinformation | 20 Byte: `[0]=5` | `readDeviceData`, Antwortfall 5 |

Status: Istwert `[2..3]/10`, Basisziel `[4..5]/10`, Boost `[6]`, Superboost `[7]`, Akku `[8]`, Restzeit **`[9]+[10]`** (kein uint16), Heizmodus `[11]`, Laden `[13]`, bereit `[14]&2`, Ladeoptionen `[14]&8/32`. Antwortfall 4: Laufzeit-Minuten als uint24LE an `[1..3]`. Fall 3: Fehlercode/Kategorie; nur Kategorie 4 wird als Fehler bewertet, ohne erfundene Fehlertexte.

Ein Istwert wie `0x8000` oder >300 °C wird als fehlend dargestellt. Ziel, Akku und Heizmodus müssen plausibel sein. Boost wird als Offset konfiguriert und am Gerät aktiviert; kein spekulativer Boost-Heizbefehl. Die UI zeigt die Basiszieltemperatur. QVAP-Abschaltzeit ist nur lesbar: `writeAutoOffCountdownQVap` enthält keinen Steuerbefehl.

## CRAFTY und CRAFTY+

Kontrolldienst `00000001+C`, Informationen `00000002+C`, Status `00000003+C`. Ganzzahlen little-endian.

| Funktion | Merkmal | Format/Regel |
|---|---|---|
| Isttemperatur | `00000011+C` | uint16 /10 |
| Zieltemperatur | `00000021+C` | uint16 °C×10, 40–210 °C; danach bisherigen Boost erneut schreiben |
| Boost | `00000031+C` | uint16 Offset×10; Basis+Offset ≤210 °C |
| Akku | `00000041+C` | uint16 0–100 |
| Helligkeit | `00000051+C` | uint16 0–100 |
| Abschaltung | `00000061+C` | uint16 Sekunden, 30–300; vorher Code 815 uint16 an `000001b3+C`, ununterbrochene Write-Sequenz |
| Restzeit | `00000071+C` | uint16 Sekunden |
| Heizung ein/aus | `00000081+C` / `00000091+C` | Je zwei Nullbytes |
| Firmware/Seriennummer | `00000032+C` / `00000052+C` | ASCII |
| BLE-Firmware | `00000072+C` | Drei Versionsbytes |
| Projektstatus | `00000093+C` | uint16: 16=Heizung, 32=Boost, 64=Superboost; Fehler `0x2008`, Reset-Anforderung `0x8000` |
| Vibration/Ready | `000001c3+C` | Frisch lesen, nur Bit 0 ändern: 0=Vibration an; andere Bits erhalten, rücklesen. Ready=Bit 2 |
| Laufzeit | `00000023+C` / `000001e3+C` | Stunden / Minutenanteil |

Belege in `crafty.js`: `writeSollTemperatureCrafty`, `onHeatClickCrafty`, `writeBoostTemperatureCrafty`, `writeBrightnessCrafty`, `writeAutoOffCountdownCrafty`, `projectRegister2ChangeBitC`, `handleProjectRegisterValChanged`, `handlePrjstatusRegister2` und Initialisierung.

Heizung, Vibration und Abschaltzeit sind unter Firmware 2.51 oder bei nicht parsebarer Firmware gesperrt. Zielwerte >210 werden gemäß Fahrenheit-Sonderfall umgerechnet; Ziel-/Boost-Schreiben bleibt dann bis zum Hardwareabgleich gesperrt. Es wird keine unbekannte Geräteeinstellung zur Einheitenkorrektur geschrieben.

## VOLCANO HYBRID

Statusdienst `10100000+SB`, Steuerdienst `10110000+SB`.

| Funktion | Merkmal | Format/Regel |
|---|---|---|
| Isttemperatur | `10110001+SB` | uint16 /10 |
| Zieltemperatur | `10110003+SB` | **Schreiben uint32LE** °C×10; Lesen uint16 /10; 40–230 °C |
| Helligkeit | `10110005+SB` | uint16 0–100 |
| Restzeit | `1011000c+SB` | uint16 Sekunden |
| Abschaltung | `1011000d+SB` | uint16 Sekunden, 60–21600; Hersteller-UI multipliziert Minuten mit 60 |
| Heizung ein/aus | `1011000f+SB` / `10110010+SB` | Je **ein Nullbyte** |
| Pumpe ein/aus | `10110013+SB` / `10110014+SB` | Je **ein Nullbyte** |
| Projektstatus | `1010000c+SB` | uint16: 32=Heizung, 8192=Pumpe, Fehlerbits 16408 |
| Vibration | `1010000e+SB` | Schreiben uint32LE `0x400` an, `0x10400` aus; Lesen Bit `0x400` invers |
| Firmware/BLE/Seriennummer | `10100003/04/08+SB` | ASCII |
| Laufzeit | `10110015/16+SB` | Stunden / Minutenanteil |

Belege: `writeSollTemperatureHybrid`, `onHeatClickVolcano`, `onAirClickVolcano`, `writeBrightnessVolcano`, `writeAutoOffCountdownVolcano`, `vibrationToggleVolcanoHandler`, `projectRegister3ChangeBit`, `evalPrj1Volcano`. Abweichend von manchen Sekundärdokumenten werden die tatsächlich ausgeführten Null-Payloads des Herstellerclients verwendet und gegen Bytevektoren geprüft.

## Grenzen und Reproduktion

GATT-UUIDs sind kein kryptografischer Echtheitsnachweis. Firmwarevarianten, MTU/CCCD-Verhalten, OS-Permissions und Write-/Readback-Latenzen müssen an Geräten geprüft werden. Die App liest nach Änderungen zurück und trennt bei unbestätigtem Ergebnis; Aktuatorbefehle werden nicht automatisch wiederholt. Nur belegte Diagnosebits werden interpretiert.

Nicht implementiert: Firmware-/Bootloader-Updates, Reset für CRAFTY/+ oder HYBRID, Seriennummernänderung, Cloud-Diagnose, QVAP-Auto-Off-Schreiben, Heizworkflows, automatische Wiederverbindung oder Wiederholen alter Befehle auf einem neuen Gerät.

Die vier JS-Dateien separat von den Quellen herunterladen und kontrollieren. Danach:

```sh
node tool/vendor_vectors.mjs /pfad/zu/herstellerdateien
dart run tool/check_core.dart
git diff -- test/fixtures/vendor_vectors.json
```

Neue Bytes/Quellen erfordern Protokollreview und Hardwareabgleich. Der VM-Kontext des Skripts ist ein GATT-Mock, keine Sicherheits-Sandbox für beliebigen fremden Code.

## Ergänzungen 0.3.2: Gerätekonfiguration

Erneuter Abruf der Herstellerdateien am 19.10.2026, SHA-256 in den aktualisierten Fixtures. Acht zusätzliche ausgeführte Referenzvektoren: Permanent Boost an/aus, Anzeige an/aus für VENTY und VEAZY, Reset und Analyse. Keine Herstellerquellen mitgeliefert.

| Funktion | Paket / Antwort | Herstellerfunktion |
|---|---|---|
| Permanent Boost | 7 Byte: [0]=6, [1]=16, [6]=1 an / 0 aus; Rücklesen Opcode 6 Byte 6 | boostSuperboostTimeoutFuncQvap, parseBLEResponse Fall 6 |
| Boost-Anzeige | 20 Byte: [0]=1, [1]=128, [15]=64; [14]=64 an / 0 aus bei VENTY; VEAZY invertiert | boostVisualizationFunc, parseBLEResponse Fall 1 |
| Einstellungen-Reset | 20 Byte: [0]=1, [1]=128, [14]=4, [15]=4 | startFactoryResetFuncQVap |
| Analyse | 20 Byte: [0]=3 | startAnalysisQvapFunc |

Permanent Boost wird beim VENTY im Original nach Firmware-Minor >=8 eingeblendet. SB CONTROL begrenzt zusätzlich konservativ auf erkannte V01.xx (ab V01.08); andere Hauptversionen benötigen Review. Antwortbyte 6 muss vorhanden und 0/1 sein. VEAZY wird im Original separat freigegeben. Die Boost-Anzeige wird aus Statusbyte 14 Bit64 modellabhängig interpretiert. Schreibmasken ändern ausschließlich das angeforderte Feld.

Reset wird nur nach Dialogbestätigung bei ausgeschaltetem Aufheizen gesendet, niemals automatisch wiederholt. Danach werden Status und Einstellungen neu gelesen; Basis180 wird geprüft. Dies bestätigt nicht jedes mögliche Firmware-Default und keine Persistenz nach echtem Stromzyklus.

Die Analyse verwendet die lokale Fehlerabfrage. Der zusätzliche Hersteller-Cloud-Upload (startAnalysisQvapFuncSandB) wird nicht nachgebaut. Aus einer fehlerfreien Kategorie wird kein allgemeines Hardware-Prüfsiegel abgeleitet.

Die App-Temperaturstufen aus 0.3.1 sind entfernt. Geräte-Boosts werden am physischen Gerät aktiviert. Keine geratenen Moduswerte oder App-Timer.
