# Pflege und Reinigung · 0.4.0

Stand: 20.10.2026. Eigene deutsche Kurzfassungen der Herstellerunterlagen, keine Herstellerfreigabe. Schematische Flutter-Zeichnungen unterstützen die Reihenfolge; sie sind keine maßstabsgetreuen Montagebilder. Die Originalanleitung bleibt über den Quellenknopf erreichbar.

## Bedienung und Erinnerungen

Im Tab **Pflege** Modell wählen, Bildanleitung starten und mit Weiter/Zurück oder horizontalem Wischen durch die Schritte gehen. Text kann auf kleinen Bildschirmen innerhalb einer Karte gescrollt werden. Jede Anleitung enthält Vorbereitung, modellspezifische Schritte und einen Abschluss. Erst die Bestätigung „Alles trocken und geprüft“ erlaubt das Speichern. Abbrechen speichert keine Reinigung.

**App-Erinnerung, kein Kalender:** Der Nutzer schaltet „An Reinigung erinnern“ einmal pro Modell ein. Erst dabei wird die Systemberechtigung angefragt. Die App plant eine lokale Benachrichtigung beim Betriebssystem; Bluetooth, Internet, ein Konto und eine laufende App sind dafür nicht erforderlich. Android kann die Zustellung durch Energiesparregeln verzögern; erzwungenes Beenden kann sie unterdrücken. Die Funktion benötigt keine Push-Zertifikate oder Kalenderberechtigung.

Automatisch wird ein **wöchentlicher Pflegecheck** geplant. Es gibt keine Intervall- oder Uhrzeitauswahl. Intern liegt der nächste Check sieben Kalendertage nach Einschalten beziehungsweise bestätigter Reinigung um 18 Uhr Ortszeit. Das ist ein Hinweis zur Kontrolle, keine sekundengenaue Hygienegrenze. Bei sichtbaren Ablagerungen ist früheres Reinigen nötig. Der Hinweis ersetzt die Herstellervorgaben nicht.

Eine bestätigte Reinigung setzt den Ausgangspunkt neu. Der globale Schalter in Optionen entfernt alle geplanten Pflege- und Testhinweise; die Modellauswahl bleibt für später erhalten. Einzelne Modelle lassen sich ebenfalls abschalten. Öffnen einer Benachrichtigung führt zum passenden Pflegebereich. Ein bereits überfälliger Check bleibt in der App sichtbar und erzeugt beim Öffnen keine wiederholten Benachrichtigungen. Nach Bestätigung der nächsten Reinigung wird wieder ein Hinweis geplant.

Es gibt einen Pflegeplan **je Modell**, nicht je Seriennummer. Zeiten werden lokal gespeichert (UTC im Speicher, Ortszeit für Anzeige/Planung), getrennt von den BLE-Einstellungen. Die Web-Vorschau verwendet einen eigenen Speicherbereich und erzeugt keine Systembenachrichtigungen. Die Anleitung funktioniert offline; nur externe Originalquellen benötigen Internet.

Die App zählt keine Füllungen und misst keinen Verschmutzungsgrad. Nutzung bei getrennter App wird nicht aus unvollständigen App-Sitzungen hochgerechnet. Häufigere Nutzung oder geänderter Zugwiderstand sind Gründe für eine frühere Sichtkontrolle. Für eine spätere automatische Anpassung wäre zuerst ein verlässlich belegter, nachträglich lesbarer Nutzungswert und ein nachvollziehbares Pflegemodell nötig. Es wurden dafür keine Bluetooth-Befehle ergänzt.

## Herstellerabgleich

| Modell | Zeit-/Kontrollvorgabe | Besonderheiten im Ablauf |
|---|---|---|
| VENTY | Vor jeder Anwendung prüfen; bei Ablagerungen reinigen, spätestens sieben Tage nach letzter Anwendung. Siebe nach Nutzung ausbürsten. | Luftstromrad und dessen Dichtung, Drehverschluss, „TOP“-Ausrichtung; warmes Spülwasser mindestens fünf Minuten oder Isopropanol höchstens 30 Minuten, danach mindestens eine Minute spülen und vollständig trocknen. |
| VEAZY | Bei Ablagerungen und spätestens sieben Tage nach letzter Benutzung reinigen. | Zwischenboden ausbauen; Spülwasser 5–30 Minuten oder Isopropanol höchstens 30 Minuten; spülen/trocknen. |
| CRAFTY / CRAFTY+ | Regelmäßig sowie bei Ablagerungen reinigen. Kein erfundenes festes Herstellerintervall; Wochencheck ist App-Orientierung. | Deckelriegel mit Hologramm vor Alkoholbad entfernen. Keine Kräutermühle, Füllhilfe oder Magazine in Alkohol. Kleine Bodendichtung muss vollständig im Deckel sitzen. |
| VOLCANO HYBRID | Füllkammer/Zubehör regelmäßig; Füllkammer bei Nutzerwechsel und vor neuem Ballon/Schlauch reinigen. Ballon samt Mundstück und Schlauch alle zwei Wochen ersetzen. | Abnehmbare Teile: Spülwasser oder Isopropanol 70 %, Kunststoff höchstens 30 Minuten. Kaltes Heizelement ausschließlich mit wasserfeuchtem, nicht tropfendem Tuch. Schlauch mindestens ein Meter. |

„Sieben Tage nach letzter Anwendung“ ist nicht identisch mit „sieben Tage nach Reinigung“. Deshalb bezeichnet die Oberfläche den App-Termin ausdrücklich als Pflegecheck und zeigt daneben die Originalvorgabe. Für CRAFTY/+ und HYBRID wird der Wochencheck nicht als starres Herstellerintervall ausgegeben.

Die aktuellen geprüften Unterlagen für VENTY/VEAZY/CRAFTY+ nennen in diesen Reinigungsabschnitten keine einheitliche Isopropanol-Konzentration. Die App behauptet dort deshalb keine 99,9%-Empfehlung. HYBRID nennt ausdrücklich 70 %. Isopropanol ist entzündlich; Hinweise zu Lüftung, Zündquellen, Trocknung und Verdampfen von Resten sind Bestandteil der Karten. Grundgeräte/Elektronik werden nie eingetaucht.

## Originalquellen

- VENTY: [Reinigung](https://support.storz-bickel.com/hc/de/articles/36557361120401-Reinigung), [Demontage/Montage](https://support.storz-bickel.com/hc/en-us/articles/36056947203473-Disassembling-Assembling), [Gebrauchsanweisung Kapitel 7](https://www.storz-bickel.com/de/amfile/file/download/file/621/).
- VEAZY: [Reinigung](https://support.storz-bickel.com/hc/de/articles/36674537322769-Reinigung), [Demontage/Montage](https://support.storz-bickel.com/hc/de/articles/38391715337361-Demontage-Montage), [Gebrauchsanweisung Kapitel 7](https://www.storz-bickel.com/de/amfile/file/download/file/668/).
- CRAFTY+: [Reinigung](https://support.storz-bickel.com/hc/de/articles/36103580179473-Reinigung), [Demontage/Montage](https://support.storz-bickel.com/hc/de/articles/36058359911953-Demontage-Montage), [Gebrauchsanweisung Kapitel 7](https://www.storz-bickel.com/de/amfile/file/download/file/7/). Der Hersteller beschreibt die [gemeinsame Kühleinheit CRAFTY(+)](https://www.storz-bickel.com/de/crafty-cooling-unit); beide Modelle verwenden die entsprechende Anleitung. Diese Produktseite ist nur Kompatibilitätsbeleg in der Dokumentation, kein Kauflink in der App.
- HYBRID: [Reinigung](https://support.storz-bickel.com/hc/de/articles/36092589504785-Reinigung), [Gebrauchsanweisung Kapitel 7.6–7.8](https://www.storz-bickel.com/de/amfile/file/download/file/40/).
- Benachrichtigungsintegration: [flutter_local_notifications 19.4.2](https://pub.dev/packages/flutter_local_notifications/versions/19.4.2), passend zum vorhandenen Flutter 3.35.3. Android verwendet ungenaue Alarme (`inexactAllowWhileIdle`), Boot-Receiver und Desugaring, keine Berechtigung für exakte Alarme. iOS verwendet `UNUserNotificationCenter` ohne Hintergrund-Bluetooth oder Push-Server.

## Verifikation und offene Abnahme

Automatisierte Tests prüfen Opt-in, Ausschalten, Rechteentzug/-erteilung, persistierte Reinigung, überfällige Pläne, ungültige Daten, Speicherfehler, überlappende Änderungen und Benachrichtigungspayloads. Widgettests bedienen alle fünf Bildanleitungen bei 320 Pixeln; VENTY zusätzlich mit 150 % Schriftgröße. Bestehende BLE-/Layouttests laufen unverändert mit.

Offen bleiben reale Zustellung bei gesperrtem Telefon, nach Neustart, im Energiesparmodus und bei entzogenem Recht; kalter/warmer App-Start durch Antippen sowie VoiceOver/TalkBack. „Benachrichtigung testen“ in Optionen plant nach bewusster Betätigung einen Testhinweis (frühestens etwa zehn Sekunden; Android kann verzögern). Keine reale Reinigung/Demontage mit allen fünf Geräten durchgeführt. Die vollständige Prüfliste steht in [HARDWARE_TESTS.md](HARDWARE_TESTS.md).
