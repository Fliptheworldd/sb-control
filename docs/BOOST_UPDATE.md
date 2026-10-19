> Historisch: Dieses Verhalten gehörte zu 0.3.1. Die lokalen App-Stufen wurden in 0.3.2 entfernt; siehe DEVICE_SETTINGS.md.

# App-Boosts · 0.3.1

Die Bedienung heißt jetzt „Aufheizen“ und „Aufheizen stoppen“. Basis, Boost und Superboost sind im Dashboard direkt anwählbar. Beide Aufschläge werden im Dashboard und unter Optionen eingestellt, von 1 bis 99 °C in einzelnen Gradschritten. Keine Beschränkung auf feste 10/15/20-Presets.

Beispiel: Basis 180 °C + Boost 10 °C = 190 °C; Superboost zusätzlich 17 °C = 207 °C. Superboost kann auch direkt aus der Basis angewählt werden. Wiederholtes Tippen addiert nicht erneut. Zielwerte werden auf die Modellgrenze begrenzt (210 °C, HYBRID 230 °C), die Buttons zeigen die tatsächlich begrenzte Temperatur vor dem Antippen.

Die Aufschläge sind lokale App-Einstellungen je Gerätekennung. Änderungen an den Aufschlägen allein senden keinen Temperaturbefehl; sie gelten beim nächsten Antippen einer Stufe. „Basis“ stellt die ursprüngliche Basis wieder her und heizt auf. „Aufheizen stoppen“ schaltet aus und stellt bei einer bekannten aktiven App-Stufe die Basis wieder her. Manuelles Ändern der Zieltemperatur beendet die App-Stufe und setzt eine neue Basis.

## Protokollentscheidung

Die App-Stufen sind bewusst keine Behauptung über einen nativen Boost-Modus. Sie senden ausschließlich bereits in v0.3.0 gegen Herstellerquellen geprüfte Zieltemperatur- und Ein/Aus-Befehle, anschließend Rücklesen. Bei QVAP wird der belegte normale Aufheizmodus verwendet. Keine neuen Opcodes, kein Schreiben der Moduswerte 2/3, kein Setzen von CRAFTY-Boost-Registerbits.

Zusätzlich recherchiert: Die unabhängige Alpha-Bibliothek [storzandbickel-ble 0.1.21](https://pypi.org/project/storzandbickel-ble/0.1.21/) / [Quellrepository](https://github.com/lorek123/snb-ble) bietet native Boost-Modi an. Ihr QVAP-Moduswechsel setzt zusätzliche Offset-Schreibmasken ohne Offsetwerte. Ohne Hardwareabgleich ist das für SB CONTROL keine ausreichend belastbare Grundlage. Dieser Code wurde nicht übernommen. Der Hersteller beschreibt konfigurierbare Offsets und geräteeigene Boosts im [VENTY-Support](https://support.storz-bickel.com/hc/de/articles/36131382635153-Temperatureinstellungen).

Die bisherigen Einstellungen für die physische Gerätetaste bleiben separat unter „Gerätetaste: …“ erhalten. So werden lokale App-Aufschläge nicht mit geräteeigenen Einstellungen verwechselt. CRAFTY mit bereits aktivem Geräte-Boost sperrt App-Stufen, bis dieser am Gerät beendet wurde; ältere/gesperrte Firmware bleibt ebenfalls gesperrt.

## Grenzen

Kein automatischer 90-Sekunden-Rücksprung. Bei Verbindungsverlust oder Hintergrundtrennung kann die App nichts mehr zurückstellen; die zuletzt bestätigte Zieltemperatur kann am Gerät bestehen bleiben. Geräteabschaltung und physische Bedienung bleiben maßgeblich. Eine erneute Verbindung startet keine gespeicherte aktive Stufe. Bei externen Temperaturänderungen wird eine nicht mehr passende App-Stufe nicht als aktiv angezeigt.

Keine neuen Hardwaretests durchgeführt. Android-/iOS-Builds bleiben offen. Neue Simulationstests prüfen Stufen, variable Aufschläge, wiederholtes Tippen, Grenzwerte, Basisrückkehr, Stoppen, Reconnect und Speicherung je Gerät; Ergebnisse stehen im ergänzten Testbericht.
