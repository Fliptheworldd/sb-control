# Herkunft und Drittanbieter

Grundlage ist das vom Auftraggeber gelieferte `sb_control_v0_2_source.zip`. Originaldateien liegen unter `docs/original-v0.2/`. Eine Projektlizenz war dort nicht angegeben; dieser Ausbau ergänzt keine pauschale Open-Source-Lizenz für fremde/ursprüngliche Rechte. Vor öffentlicher Veröffentlichung legt der Rechteinhaber die Projektlizenz fest.

Gerätenamen/Marken gehören ihren Inhabern. Keine Herstellerzugehörigkeit oder Zertifizierung wird behauptet.

BLE wurde unabhängig aus Protokollfakten implementiert. Proprietärer Hersteller-JavaScript-Code und Implementierungscode aus dem AGPL-lizenzierten reactive-volcano-app-Projekt sind nicht enthalten. Quellen, Hashes und Bytevektoren stehen in docs/PROTOCOLS.md und test/fixtures/vendor_vectors.json.

Flutter-Plattformvorlagen, Runtime und Pub-Pakete behalten ihre Lizenzen. Die aufgelösten Paketlizenzen sind in `licenses/dependencies.txt` gesammelt; maßgeblich sind die jeweiligen Originalhinweise. Hauptabhängigkeiten: Flutter, flutter_reactive_ble, permission_handler, device_info_plus und shared_preferences.

Roboto stammt aus dem Flutter-3.35.3-Material-Font-Cache; Apache-2.0-Lizenz unter `assets/fonts/LICENSE.txt`. Die SB-Monogramm-App-Icons wurden für das Projekt erstellt; keine Herstellerlogos übernommen.

Der Webbuild enthält zusätzlich Noto Sans Symbols für lokal verfügbare Sonderzeichen. Quelle: Google Fonts / fonts.gstatic.com, Lizenz unter `web/assets/font-fallback/OFL.txt`. Der Web-Bootstrap lädt Fallback-Schriften ausschließlich aus dem lokalen Buildverzeichnis.
