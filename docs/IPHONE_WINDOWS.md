# iPhone-Test über Windows

Der Workflow **iPhone IPA for local signing** baut für ein physisches iPhone (Release/ARM64), nicht den Simulator. Er benötigt keine Apple-Zugangsdaten in GitHub. Das ZIP-Artefakt `SB-Control-iPhone-unsigned` enthält `SB-Control-unsigned.ipa` und SHA-256. Diese IPA ist noch nicht signiert und kann nicht durch einfaches Antippen installiert werden.

1. Erfolgreichen Lauf unter GitHub → Actions öffnen und Artefakt herunterladen/entpacken.
2. Sideloadly ausschließlich von https://sideloadly.io installieren; dortige Windows-Voraussetzungen für Apple-Treiber/iTunes/iCloud beachten.
3. iPhone per USB mit Windows verbinden, dem PC auf dem iPhone vertrauen.
4. IPA in Sideloadly auswählen, eigenen Apple-Account lokal verwenden, signieren/installieren. Keine Zugangsdaten in Issues, Chat oder Repository hinterlegen.
5. Auf dem iPhone bei Bedarf Entwicklerprofil vertrauen und Entwicklermodus aktivieren.
6. SB CONTROL öffnen, Bluetooth erlauben, VENTY einschalten und in der App suchen/verbinden. Zunächst Werte nur lesen, dann eine reversible Einstellung ändern und am Gerät kontrollieren.

Ein kostenloses Konto erfordert üblicherweise nach sieben Tagen eine erneute Signierung; Sideloadly kann dies über den PC auffrischen. Diese Installation und reales Bluetooth wurden noch nicht auf dem Zieltelefon getestet. Geräte-Einstellungen nach App-Schließen/Trennen/Neustart anhand HARDWARE_TESTS.md prüfen.

GitHub Actions verbraucht je nach Kontingent/Repository-Tarif Build-Minuten. Dieser Workflow ändert weder Abrechnung noch Ausgabenlimits. Ein Fehler aufgrund fehlenden Kontingents muss im GitHub-Konto behoben werden.
