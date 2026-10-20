# Herkunft und Drittanbieter

Grundlage ist das vom Auftraggeber gelieferte `sb_control_v0_2_source.zip`. Originaldateien liegen unter `docs/original-v0.2/`. Eine Projektlizenz war dort nicht angegeben; dieser Ausbau ergänzt keine pauschale Open-Source-Lizenz für fremde/ursprüngliche Rechte. Vor öffentlicher Veröffentlichung legt der Rechteinhaber die Projektlizenz fest.

Gerätenamen/Marken gehören ihren Inhabern. Keine Herstellerzugehörigkeit oder Zertifizierung wird behauptet.

BLE wurde unabhängig aus Protokollfakten implementiert. Proprietärer Hersteller-JavaScript-Code und Implementierungscode aus dem AGPL-lizenzierten reactive-volcano-app-Projekt sind nicht enthalten. Quellen, Hashes und Bytevektoren stehen in docs/PROTOCOLS.md und test/fixtures/vendor_vectors.json.

Flutter-Plattformvorlagen, Runtime und Pub-Pakete behalten ihre Lizenzen. Die aufgelösten Paketlizenzen sind in `licenses/dependencies.txt` gesammelt; maßgeblich sind die jeweiligen Originalhinweise. Hauptabhängigkeiten: Flutter, flutter_reactive_ble, permission_handler, device_info_plus und shared_preferences.

Roboto stammt aus dem Flutter-3.35.3-Material-Font-Cache; Apache-2.0-Lizenz unter `assets/fonts/LICENSE.txt`. Die aktuellen App-Icons sind für dieses Projekt generierte Gerätesilhouetten; siehe historische Herkunft in `docs/DESIGN_ITALIAN.md`.

Der Webbuild enthält zusätzlich Noto Sans Symbols für lokal verfügbare Sonderzeichen. Quelle: Google Fonts / fonts.gstatic.com, Lizenz unter `web/assets/font-fallback/OFL.txt`. Der Web-Bootstrap lädt Fallback-Schriften ausschließlich aus dem lokalen Buildverzeichnis.

## Originale Produktfotos ab 0.6.0

`assets/devices/*.jpg` enthält Originalfotos von den offiziellen STORZ & BICKEL
Produktseiten bzw. der offiziellen Web-App. Bildrechte verbleiben bei STORZ &
BICKEL / den jeweiligen Rechteinhabern. Herkunft, Abrufdatum und SHA-256 jeder
unveränderten JPEG-Datei: `docs/PRODUCT_IMAGE_SOURCES.json`.

Die Fotos wurden auf ausdrücklichen Wunsch des Auftraggebers für seine Test-App
eingebunden. Daraus folgt keine übertragene Lizenz, Herstellerfreigabe oder
Berechtigung für eine öffentliche Store-Veröffentlichung. Die Produktfotos sind
von einer etwaigen Projektlizenz ausgenommen. Es wurden keine Wasserzeichen
entfernt. Nur leere Bildränder werden bei der Flutter-Darstellung ausgeblendet.
CRAFTY nutzt das kleinere offizielle Web-App-Bild; CRAFTY+ sein eigenes Produktfoto.
Die vier alten generierten Geräteillustrationen wurden entfernt. Das eigene
Launcher-Icon und die separaten schematischen Reinigungsbilder bleiben erhalten.
