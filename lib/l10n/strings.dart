// Italian is selected explicitly for the friend build; German stays the default.
abstract final class L {
  static const italian =
      String.fromEnvironment('SB_LANGUAGE', defaultValue: 'de') == 'it';
  static const s000 = italian
      ? "Impossibile salvare le impostazioni."
      : "Einstellungen konnten nicht gespeichert werden.";
  static const s001 = italian
      ? "La connessione è cambiata"
      : "Verbindung wurde geändert";
  static const s002 = italian
      ? "Connessione persa. Riconnetti il dispositivo per continuare."
      : "Verbindung verloren. Zum Fortsetzen erneut verbinden.";
  static const s003 = italian
      ? "Demo · dispositivi simulati"
      : "Demo · simulierte Geräte";
  static const s004 = italian
      ? "Pronto per cercare dispositivi"
      : "Bereit zur Gerätesuche";
  static const s005 = italian ? "Ricerca in corso …" : "Suche läuft …";
  static const s006 = italian
      ? "Ricerca dei dispositivi non riuscita"
      : "Gerätesuche fehlgeschlagen";
  static const s007 = italian
      ? "Nessun dispositivo trovato"
      : "Keine Geräte gefunden";
  static const s009 = italian
      ? "Connessione e verifica del protocollo …"
      : "Verbinde und prüfe Protokoll …";
  static const s010 = italian
      ? "Profilo sconosciuto · solo diagnostica GATT"
      : "Unbekanntes Profil · nur GATT-Diagnose";
  static const s011 = italian
      ? "Canale QVAP incompleto"
      : "QVAP-Kanal unvollständig";
  static const s012 = italian
      ? "Canale notifiche non disponibile"
      : "Benachrichtigungskanal fehlgeschlagen";
  static const s013 = italian
      ? "Modalità aggiornamento o firmware non valido. Usa l’app del produttore. Comandi bloccati."
      : "Update-Modus oder ungültige Firmware. Nutze die Hersteller-App. Steuerung gesperrt.";
  static const s014 = italian
      ? "Dati in tempo reale assenti; interrogazione periodica attiva"
      : "Live-Meldungen fehlen; Abfrage bleibt aktiv";
  static const s015 = italian
      ? "Demo connessa · valori simulati"
      : "Demo verbunden · simulierte Werte";
  static const s016 = italian
      ? "Connesso · verifica hardware da completare"
      : "Verbunden · Hardwareprüfung ausstehend";
  static const s017 = italian ? "Demo connessa" : "Demo verbunden";
  static const s018 = italian
      ? "BLE connesso, profilo riconosciuto"
      : "BLE verbunden, Profil erkannt";
  static const s019 = italian
      ? "Connessione non autorizzata"
      : "Verbindung nicht freigegeben";
  static const s020 = italian
      ? "Modalità applicazione non confermata"
      : "Anwendungsmodus nicht bestätigt";
  static const s021 = italian ? "Connessione cambiata" : "Verbindung geändert";
  static const s022 = italian
      ? "Caratteristica di scrittura verificata assente"
      : "Belegtes Schreibmerkmal fehlt";
  static const s023 = italian
      ? "Valore BLE non valido ignorato"
      : "Ungültiger BLE-Wert verworfen";
  static const s025 = italian
      ? "Dati diagnostici aggiornati"
      : "Diagnosedaten aktualisiert";
  static const s026 = italian
      ? "Nessuna risposta affidabile. Riconnetti il dispositivo."
      : "Keine verlässliche Antwort. Bitte erneut verbinden.";
  static const s027 = italian
      ? "Connessione interrotta"
      : "Verbindung unterbrochen";
  static const s028 = italian
      ? "Questa funzione non è abilitata per il profilo del dispositivo attuale."
      : "Diese Funktion ist für das aktuelle Geräteprofil nicht freigegeben.";
  static const s029 = italian
      ? "Stato del dispositivo non aggiornato"
      : "Gerätestatus nicht aktuell";
  static const s030 = italian
      ? "Il valore riletto non corrisponde"
      : "Rücklesewert weicht ab";
  static const s032 = italian
      ? "Comando non confermato con certezza. Controlla il dispositivo. Nessun tentativo automatico."
      : "Befehl nicht sicher bestätigt. Gerätezustand vor Ort prüfen. Kein automatischer Wiederholungsversuch.";
  static const s033 = italian ? "Comandi sospesi" : "Steuerung angehalten";
  static const s034 = italian
      ? "Temperatura base + Boost non può superare 210 °C"
      : "Basis + Boost darf 210 °C nicht überschreiten";
  static const s035 = italian
      ? "Ripristino inviato; riletta la base di 180 °C. Altre impostazioni rilette."
      : "Reset gesendet; Basis 180 °C rückgelesen. Weitere Einstellungen neu ausgelesen.";
  static const s036 = italian ? "Non connesso" : "Nicht verbunden";
  static const s037 = italian ? "Disconnesso" : "Verbindung getrennt";
  static const s038 = italian ? "SB CONTROL 0.5.0" : "SB CONTROL 0.3.2";
  static const s039 = italian
      ? "Nome, identificativo e numero di serie del dispositivo omessi."
      : "Device name, identifier and serial number omitted.";
  static const s040 = italian
      ? "Valore intero non valido"
      : "Ungültiger Ganzzahlwert";
  static const s041 = italian ? "Valore BLE troppo breve" : "BLE-Wert zu kurz";
  static const s042 = italian ? "Solo QVAP" : "Nur QVAP";
  static const s043 = italian
      ? "Verificato solo per VEAZY"
      : "Nur für VEAZY belegt";
  static const s044 = italian ? "Risposta vuota" : "Leere Antwort";
  static const s045 = italian
      ? "Risposta firmware troppo breve"
      : "Firmware-Antwort zu kurz";
  static const s046 = italian
      ? "Risposta di stato troppo breve"
      : "Status-Antwort zu kurz";
  static const s047 = italian
      ? "Stato del dispositivo non plausibile"
      : "Unplausibler Gerätestatus";
  static const s048 = italian ? "Analisi troppo breve" : "Analyse zu kurz";
  static const s049 = italian ? "Durata troppo breve" : "Laufzeit zu kurz";
  static const s050 = italian
      ? "Dati del dispositivo troppo brevi"
      : "Gerätedaten zu kurz";
  static const s051 = italian
      ? "Impostazioni troppo brevi"
      : "Einstellungen zu kurz";
  static const s052 = italian ? "Famiglia sconosciuta" : "Unbekannte Familie";
  static const s053 = italian ? "Non è un CRAFTY" : "Kein CRAFTY";
  static const s054 = italian
      ? "È necessario un valore di registro aggiornato"
      : "Frischer Registerwert erforderlich";
  static const s055 = italian
      ? "Firmware BLE troppo breve"
      : "BLE-Firmware zu kurz";
  static const s056 = italian
      ? "Temperatura impostata non valida"
      : "Solltemperatur ungültig";
  static const s057 = italian
      ? "Livello batteria non valido"
      : "Akkustand ungültig";
  static const s058 = italian
      ? "App in pausa. Riconnetti quando necessario."
      : "App pausiert. Bei Bedarf erneut verbinden.";
  static const s059 = italian ? "La tua connessione" : "Deine Verbindung";
  static const s060 = italian
      ? "Tutto sotto controllo."
      : "Alles unter Kontrolle.";
  static const s061 = italian
      ? "I tuoi dispositivi. Direttamente via Bluetooth."
      : "Deine Geräte. Direkt über Bluetooth.";
  static const s062 = italian
      ? "Pronto quando vuoi."
      : "Bereit, wenn du es bist.";
  static const s063 = italian
      ? "Collega il vaporizzatore e regola temperatura e impostazioni."
      : "Verbinde deinen Vaporizer und passe Temperatur und Einstellungen an.";
  static const s064 = italian ? "Collega dispositivo" : "Gerät verbinden";
  static const s065 = italian
      ? "Prova con dispositivi demo"
      : "Mit Demo-Geräten ausprobieren";
  static const s066 = italian
      ? "Senza account. Senza cloud. L’app nativa funziona anche senza Internet."
      : "Ohne Konto. Ohne Cloud. Die native App arbeitet auch ohne Internet.";
  static const s067 = italian ? "Il tuo dispositivo" : "Dein Gerät";
  static const s068 = italian
      ? "Esplora l’app con valori simulati."
      : "Erkunde die App mit simulierten Werten.";
  static const s069 = italian
      ? "Connessione diretta. Controllo locale."
      : "Direkt verbunden. Lokal gesteuert.";
  static const s070 = italian ? "DEMO CONNESSA" : "DEMO VERBUNDEN";
  static const s071 = italian ? "BLUETOOTH CONNESSO" : "BLUETOOTH VERBUNDEN";
  static const s072 = italian ? "Disconnetti" : "Verbindung trennen";
  static const s074 = italian ? "Temperatura raggiunta" : "Temperatur erreicht";
  static const s075 = italian ? "Riscaldamento in corso" : "Wird aufgeheizt";
  static const s076 = italian ? "Pronto a riscaldare" : "Bereit zum Aufheizen";
  static const s077 = italian
      ? "Riduci la temperatura di 1 °C"
      : "Temperatur um 1 °C senken";
  static const s078 = italian
      ? "Aumenta la temperatura di 1 °C"
      : "Temperatur um 1 °C erhöhen";
  static const s079 = italian ? "Arresta riscaldamento" : "Aufheizen stoppen";
  static const s080 = italian ? "Spegni pompa" : "Pumpe ausschalten";
  static const s081 = italian ? "Accendi pompa" : "Pumpe einschalten";
  static const s082 = italian ? "Non trasmesso" : "Nicht übertragen";
  static const s083 = italian
      ? "Alcuni firmware non trasmettono una misura. SB CONTROL non mostra temperature stimate."
      : "Manche Firmwarestände liefern keinen Messwert. SB CONTROL zeigt dann keine geschätzte Temperatur.";
  static const s084 = italian
      ? "Firmware vecchio o sconosciuto: riscaldamento e impostazioni avanzate sono bloccati."
      : "Ältere oder unbekannte Firmware: Heizschalter und erweiterte Einstellungen sind gesperrt.";
  static const s085 = italian
      ? "CRAFTY comunica in Fahrenheit. La scrittura della temperatura resta bloccata fino alla verifica hardware."
      : "CRAFTY meldet Fahrenheit. Temperatur-Schreibzugriffe bleiben bis zum Hardwareabgleich gesperrt.";
  static const s086 = italian
      ? "Tutti i dispositivi e i valori in questa modalità sono simulati."
      : "Alle Geräte und Werte in diesem Modus sind simuliert.";
  static const s087 = italian
      ? "Protocolli verificati sulle fonti. Test con hardware reale ancora da completare."
      : "Quellengeprüfte Protokolle. Tests mit echter Hardware stehen noch aus.";
  static const s088 = italian ? "Nome dispositivo" : "Gerätename";
  static const s089 = italian ? "Il tuo setup" : "Dein Setup";
  static const s090 = italian ? "Dispositivi" : "Geräte";
  static const s091 = italian
      ? "Cinque modelli. Un’unica interfaccia."
      : "Fünf Modelle. Eine gemeinsame Bedienung.";
  static const s092 = italian
      ? "Accendi il dispositivo e avvia la ricerca."
      : "Schalte dein Gerät ein und starte die Suche.";
  static const s093 = italian ? "Interrompi ricerca" : "Suche stoppen";
  static const s094 = italian ? "Cerca dispositivi demo" : "Demo-Geräte suchen";
  static const s095 = italian ? "Cerca dispositivi" : "Nach Geräten suchen";
  static const s096 = italian
      ? "Tocca per connettere"
      : "Zum Verbinden antippen";
  static const s097 = italian ? "Gestisci dispositivo" : "Gerät verwalten";
  static const s098 = italian ? "DISPOSITIVI DEMO" : "DEMO-GERÄTE";
  static const s099 = italian ? "NELLE VICINANZE" : "IN DER NÄHE";
  static const s100 = italian
      ? "Nessun dispositivo trovato"
      : "Noch kein Gerät gefunden";
  static const s101 = italian
      ? "Accendi il dispositivo, attiva Bluetooth e chiudi le altre app connesse. Su Android fino alla versione 11 possono essere necessari i servizi di localizzazione."
      : "Gerät einschalten, Bluetooth aktivieren und andere verbundene Apps schließen. Bei Android bis Version 11 können Standortdienste erforderlich sein.";
  static const s102 = italian
      ? "Il nome non basta: dopo la connessione SB CONTROL verifica anche i servizi Bluetooth disponibili."
      : "Der Gerätename allein reicht nicht: SB CONTROL prüft nach dem Verbinden auch die angebotenen Bluetooth-Dienste.";
  static const s103 = italian
      ? "Ripristinare il dispositivo?"
      : "Gerät zurücksetzen?";
  static const s105 = italian ? "Ripristina" : "Zurücksetzen";
  static const s106 = italian ? "Come piace a te" : "Ganz nach dir";
  static const s107 = italian
      ? "Salvate localmente. Applicate al dispositivo."
      : "Lokal gespeichert. Direkt am Gerät wirksam.";
  static const s108 = italian
      ? "Cambia solo la visualizzazione nell’app."
      : "Ändert nur die Anzeige in der App.";
  static const s109 = italian
      ? "L’anteprima web usa dispositivi simulati."
      : "Die Web-Vorschau nutzt simulierte Geräte.";
  static const s110 = italian
      ? "Esplora tutte le schermate senza hardware."
      : "Ohne Hardware alle Ansichten ausprobieren.";
  static const s111 = italian
      ? "Gli incrementi vengono salvati nel dispositivo. Attiva Boost con il pulsante del vaporizzatore."
      : "Offsets werden am Gerät gespeichert. Boost aktivierst du über die Gerätetaste.";
  static const s112 = italian
      ? "Feedback del dispositivo"
      : "Rückmeldung des Geräts";
  static const s113 = italian
      ? "Spegnimento automatico"
      : "Automatische Abschaltung";
  static const s114 = italian
      ? "Mantieni temperatura Boost"
      : "Boost-Temperatur halten";
  static const s115 = italian
      ? "Permanent Boost: nessun ritorno dopo 90 secondi. Vale per Boost e Superboost sul dispositivo; lo spegnimento resta separato."
      : "Permanent Boost: kein 90-Sekunden-Rücksprung. Gilt für Boost und Superboost am Gerät; Abschaltung bleibt separat.";
  static const s116 = italian
      ? "Su VENTY, Permanent Boost richiede un firmware supportato dalla versione 1.08 e un valore riletto valido."
      : "Permanent Boost benötigt beim VENTY eine unterstützte Firmware ab 1.08 und einen gültigen Rücklesewert.";
  static const s117 = italian
      ? "Mostra livello Boost sul dispositivo"
      : "Boost-Stufe am Gerät anzeigen";
  static const s118 = italian
      ? "Il simbolo °C/°F lampeggiante indica Boost e Superboost."
      : "Blinkendes °C/°F zeigt Boost und Superboost an.";
  static const s119 = italian
      ? "Attiva l’indicatore Boost del dispositivo."
      : "Geräteeigene Boost-Anzeige aktivieren.";
  static const s120 = italian
      ? "Queste impostazioni vengono inviate al dispositivo. Attiva poi Boost e Superboost con il pulsante del vaporizzatore. Alla connessione vengono lette le impostazioni esistenti."
      : "Diese Einstellungen werden an das Gerät übertragen. Boost und Superboost aktivierst du danach über die Gerätetaste. Beim Verbinden werden vorhandene Werte ausgelesen.";
  static const s121 = italian ? "Ricarica delicata" : "Schonend laden";
  static const s122 = italian
      ? "Corrente di ricarica ridotta"
      : "Reduzierter Ladestrom";
  static const s123 = italian
      ? "Limite batteria gestito dal dispositivo"
      : "Geräteeigenes Limit für den Akku";
  static const s124 = italian
      ? "Ripristina impostazioni dispositivo"
      : "Geräteeinstellungen zurücksetzen";
  static const s125 = italian
      ? "Solo a riscaldamento spento. Cancella le impostazioni personalizzate; non modifica il firmware."
      : "Nur bei ausgeschaltetem Aufheizen. Löscht die individuellen Geräteeinstellungen; keine Firmwareänderung.";
  static const s126 = italian
      ? "Bluetooth sempre attivo"
      : "Bluetooth dauerhaft aktiv";
  static const s127 = italian
      ? "Può aumentare il consumo della batteria."
      : "Kann den Akkuverbrauch erhöhen.";
  static const s128 = italian
      ? "Collega un dispositivo per modificarne le impostazioni."
      : "Verbinde ein Gerät, um seine Einstellungen zu bearbeiten.";
  static const s129 = italian
      ? "App indipendente di terze parti. Nessuna affiliazione con STORZ & BICKEL. Nessuna telemetria, account o cloud."
      : "Unabhängige Drittanbieter-App. Keine Verbindung zu STORZ & BICKEL. Keine Telemetrie, kein Konto, keine Cloud.";
  static const s130 = italian
      ? "Gli aggiornamenti firmware non sono inclusi. Il ripristino è verificato solo per VENTY e VEAZY."
      : "Firmware-Updates sind in dieser Version nicht enthalten. Reset ist nur für VENTY und VEAZY belegt.";
  static const s131 = italian ? "Tutto in chiaro" : "Ein klarer Blick";
  static const s132 = italian
      ? "Dati di connessione, profilo del dispositivo ed eventi."
      : "Verbindungsdaten, Geräteprofil und Ereignisse.";
  static const s133 = italian ? "NON CONNESSO" : "NICHT VERBUNDEN";
  static const s134 = italian ? "Ultimo stato" : "Letzter Status";
  static const s135 = italian
      ? "Legge la categoria di errore del dispositivo. Nessun invio al produttore e nessun controllo hardware completo."
      : "Liest die geräteeigene Fehlerkategorie aus. Kein Upload an den Hersteller und keine umfassende Hardwareprüfung.";
  static const s136 = italian
      ? "Il dispositivo segnala un errore. Comandi bloccati. Contatta l’assistenza del produttore."
      : "Das Gerät meldet einen Fehler. Steuerung gesperrt. Hersteller-Support kontaktieren.";
  static const s137 = italian
      ? "Avvia analisi dispositivo"
      : "Geräteanalyse starten";
  static const s138 = italian
      ? "Aggiorna diagnostica"
      : "Diagnose aktualisieren";
  static const s139 = italian
      ? "Diagnostica copiata senza numero di serie e ID dispositivo."
      : "Diagnose ohne Seriennummer und Geräte-ID kopiert.";
  static const s140 = italian
      ? "Copia rapporto diagnostico"
      : "Diagnosebericht kopieren";
  static const s142 = italian
      ? "Ancora nessun evento"
      : "Noch keine Ereignisse";
  static const s143 = italian
      ? "La verifica delle fonti non sostituisce i test hardware. I codici errore sconosciuti sono riportati senza modifiche."
      : "Quellenprüfung ersetzt keinen Hardwaretest. Unbekannte Fehlercodes werden unverändert dokumentiert.";
  static const s144 = italian ? "Controllo" : "Übersicht";
  static const s145 = italian
      ? "Impossibile caricare i promemoria di pulizia. Riprova."
      : "Pflege-Erinnerungen konnten nicht geladen werden. Bitte erneut versuchen.";
  static const s146 = italian
      ? "Modifica non salvata completamente o promemoria non pianificato. Riprova."
      : "Änderung nicht vollständig gespeichert oder Erinnerung nicht geplant. Bitte erneut versuchen.";
  static const s147 = italian ? "Pulito. Pronto." : "Sauber. Startklar.";
  static const s148 = italian
      ? "Il tuo dispositivo. Una guida passo dopo passo."
      : "Dein Gerät. Eine Anleitung, Schritt für Schritt.";
  static const s149 = italian ? "Scegli dispositivo" : "Gerät auswählen";
  static const s150 = italian
      ? "È ora del controllo di pulizia"
      : "Zeit für deinen Pflegecheck";
  static const s151 = italian ? "La cura sotto controllo" : "Pflege im Blick";
  static const s152 = italian
      ? "Nessuna pulizia ancora registrata."
      : "Noch keine Reinigung gespeichert.";
  static const s155 = italian
      ? "Pulizia registrata. Il controllo di cura riparte da oggi."
      : "Reinigung gespeichert. Dein Pflegecheck beginnt neu.";
  static const s156 = italian
      ? "Apri guida illustrata"
      : "Bildanleitung starten";
  static const s157 = italian
      ? "Indicazioni del produttore"
      : "Herstellerangaben ansehen";
  static const s158 = italian
      ? "Ricordami la pulizia"
      : "An Reinigung erinnern";
  static const s160 = italian
      ? "Nessun calendario o orario da scegliere. Pulisci prima se noti residui. L’app non misura lo sporco e non conta le sessioni."
      : "Kein Kalender, keine Zeiteinstellung. Bei sichtbaren Ablagerungen früher reinigen. Die App misst keinen Verschmutzungsgrad und zählt keine Köpfe.";
  static const s161 = italian
      ? "Le notifiche sono disattivate nelle impostazioni."
      : "Benachrichtigungen sind in den Optionen ausgeschaltet.";
  static const s162 = italian
      ? "Un piano per modello. La guida funziona anche senza connessione Bluetooth."
      : "Ein Pflegeplan je Modell. Die Anleitung funktioniert auch ohne Bluetooth-Verbindung.";
  static const s163 = italian
      ? "Anteprima: puoi provare il piano di cura. Le notifiche di sistema sono disponibili nell’app iPhone e Android."
      : "Vorschau: Der Pflegeplan lässt sich ausprobieren. System-Benachrichtigungen gibt es in der iPhone- und Android-App.";
  static const s164 = italian
      ? "Le notifiche non sono consentite dal sistema. Il controllo resta visibile nell’app."
      : "Mitteilungen sind im System nicht erlaubt. Der Pflegecheck bleibt in der App sichtbar.";
  static const s165 = italian
      ? "Apri impostazioni di sistema"
      : "Systemeinstellungen öffnen";
  static const s166 = italian
      ? "Notifiche attualmente non disponibili."
      : "Benachrichtigungen momentan nicht verfügbar.";
  static const s167 = italian
      ? "Disattivando, annulli tutti i promemoria di pulizia pianificati."
      : "Ausschalten stoppt alle geplanten Reinigungserinnerungen.";
  static const s168 = italian
      ? "Nella sezione Cura scegli il dispositivo per cui ricevere promemoria."
      : "Wähle im Pflegebereich, für welches Gerät du erinnert werden möchtest.";
  static const s170 = italian ? "Apri Cura" : "Pflege öffnen";
  static const s171 = italian
      ? "Notifica di prova pianificata. Il sistema potrebbe mostrarla in ritardo."
      : "Testerinnerung geplant. Das System kann sie verzögert anzeigen.";
  static const s172 = italian ? "Prova notifica" : "Benachrichtigung testen";
  static const s174 = italian
      ? "Verificato sui documenti del produttore il 20/10/2026. I nostri disegni sono schematici. Per i dettagli dei componenti consulta la guida originale."
      : "Nach Herstellerunterlagen geprüft am 20.10.2026. Unsere Zeichnungen sind schematisch. Für die genaue Bauteilansicht nutze die Originalanleitung.";
  static const s175 = italian
      ? "Impossibile aprire la pagina del produttore."
      : "Die Herstellerseite konnte nicht geöffnet werden.";
  static const s177 = italian ? "PREPARAZIONE" : "DEINE VORBEREITUNG";
  static const s178 = italian ? "PER CONCLUDERE" : "ZUM ABSCHLUSS";
  static const s180 = italian ? "Registra pulizia" : "Reinigung speichern";
  static const s181 = italian ? "Iniziamo" : "Los geht’s";
  static const s182 = italian ? "Cosa ti serve" : "Das brauchst du";
  static const s183 = italian
      ? "La guida riguarda solo le parti rimovibili previste per la pulizia. Non aprire il corpo del dispositivo."
      : "Die Anleitung zeigt dir nur die Reinigung der vorgesehenen, abnehmbaren Teile. Öffne das Gehäuse des Grundgeräts nicht.";
  static const s184 = italian
      ? "Tutto pronto di nuovo?"
      : "Alles wieder bereit?";
  static const s185 = italian
      ? "Registra la pulizia solo quando ogni parte è asciutta, controllata e montata correttamente. Il controllo settimanale ripartirà da oggi."
      : "Speichere die Reinigung erst, wenn alle Teile trocken, geprüft und richtig zusammengesetzt sind. Dann beginnt dein wöchentlicher Pflegecheck neu.";
  static const s186 = italian
      ? "Tutto asciutto e controllato"
      : "Alles trocken und geprüft";
  static const s187 = italian
      ? "La registrazione non avvia il dispositivo e non invia una notifica aggiuntiva di pulizia completata."
      : "Das Speichern startet das Gerät nicht. Es verschickt auch keine zusätzliche „Reinigung fertig“-Benachrichtigung.";
  static const s188 = italian
      ? "Pennello per pulizia e cotton fioc"
      : "Reinigungspinsel & Wattestäbchen";
  static const s189 = italian
      ? "Utensile per camera di riempimento, ciotola e panno morbido"
      : "Füllkammerwerkzeug, Schale & weiches Tuch";
  static const s190 = italian
      ? "Acqua tiepida e detersivo per piatti; in alternativa alcol isopropilico"
      : "Warmes Spülwasser; alternativ Isopropanol";
  static const s191 = italian
      ? "Acqua pulita per risciacquare"
      : "Sauberes Wasser zum Nachspülen";
  static const s192 = italian ? "Prima spegni" : "Erst ausschalten";
  static const s193 = italian
      ? "Spegni il dispositivo, scollega il cavo di ricarica e lascia raffreddare tutto. Pulisci il corpo solo con un panno morbido, asciutto o leggermente umido."
      : "Gerät ausschalten, Ladekabel abziehen und alles abkühlen lassen. Das Gehäuse nur mit einem weichen, trockenen oder leicht feuchten Tuch säubern.";
  static const s194 = italian
      ? "Non immergere mai dispositivo e cavi. Il detergente non deve entrare nell’elettronica."
      : "Gerät und Kabel niemals einweichen. Kein Reiniger darf in die Elektronik laufen.";
  static const s195 = italian
      ? "Pulisci le parti smontate"
      : "Gelöste Teile reinigen";
  static const s196 = italian
      ? "Pulisci le parti smontate consentite in acqua tiepida e detersivo per almeno 5 minuti. In alternativa usa alcol isopropilico: contatto massimo 30 minuti, non oltre."
      : "Die freigegebenen, ausgebauten Teile mindestens 5 Minuten in warmem Spülwasser reinigen. Alternativ Isopropanol verwenden: höchstens 30 Minuten Kontakt, nicht länger.";
  static const s197 = italian
      ? "L’alcol isopropilico è facilmente infiammabile. Ventila bene, tieni lontane le fonti di accensione e segui le indicazioni del produttore del detergente."
      : "Isopropanol ist leicht entzündlich. Gut lüften, Zündquellen fernhalten und die Angaben des Reinigungsmittelherstellers beachten.";
  static const s198 = italian
      ? "Risciacqua accuratamente"
      : "Gründlich nachspülen";
  static const s199 = italian
      ? "Risciacqua le singole parti pulite sotto acqua corrente per almeno un minuto. Il corpo del dispositivo deve restare asciutto."
      : "Die gereinigten Einzelteile mindestens eine Minute unter fließendem Wasser abspülen. Das Grundgerät bleibt dabei trocken.";
  static const s200 = italian
      ? "Lascia asciugare completamente"
      : "Vollständig trocknen";
  static const s201 = italian
      ? "Lascia asciugare tutte le parti all’aria. Controlla crepe, scolorimenti e zone indurite o ammorbidite. Sostituisci le parti danneggiate."
      : "Alle Teile an der Luft vollständig trocknen lassen. Auf Risse, Verfärbungen und verhärtete oder weiche Stellen prüfen. Beschädigte Teile ersetzen.";
  static const s202 = italian
      ? "Riutilizza solo quando tutto è asciutto e i vapori del detergente sono completamente evaporati. Non accendere il riscaldamento per asciugare."
      : "Erst wieder benutzen, wenn alles trocken ist und sämtliche Reinigungsmitteldämpfe verflogen sind. Nicht zum Trocknen aufheizen.";
  static const s203 = italian
      ? "Nessun profilo di pulizia per il dispositivo sconosciuto"
      : "Kein Reinigungsprofil für unbekanntes Gerät";
  static const s204 = italian
      ? "Controlla prima di ogni utilizzo. Pulisci unità di raffreddamento e boccaglio quando ci sono depositi, al più tardi 7 giorni dopo l’ultimo utilizzo. Spazzola i filtri dopo ogni utilizzo."
      : "Vor jeder Anwendung kontrollieren. Kühleinheit und Mundstück bei Ablagerungen reinigen, spätestens 7 Tage nach der letzten Anwendung. Siebe nach jeder Nutzung ausbürsten.";
  static const s205 = italian ? "VENTY: pulizia" : "VENTY: Reinigung";
  static const s206 = italian
      ? "VENTY: smontaggio e montaggio"
      : "VENTY: Zerlegen und Zusammenbauen";
  static const s207 = italian
      ? "VENTY: istruzioni, capitolo 7"
      : "VENTY: Gebrauchsanweisung, Kapitel 7";
  static const s208 = italian
      ? "Estrai il boccaglio"
      : "Mundstück herausziehen";
  static const s209 = italian
      ? "Lascia inizialmente l’unità di raffreddamento avvitata. Inclina delicatamente il boccaglio avanti e indietro, estrailo e rimuovi la sua guarnizione dalla tacca."
      : "Die Kühleinheit bleibt zunächst aufgeschraubt. Mundstück leicht hin und her kippen, herausziehen und seinen Dichtring an der Aussparung abnehmen.";
  static const s210 = italian
      ? "Apri la chiusura a rotazione"
      : "Drehverschluss öffnen";
  static const s211 = italian
      ? "Inserisci il bordo del boccaglio nella tacca della chiusura. Ruota in senso antiorario, estrai la chiusura e rimuovi la guarnizione. Solleva il coperchio."
      : "Die Mundstückkante in die Kerbe des Drehverschlusses setzen. Gegen den Uhrzeigersinn öffnen, herausziehen und den Dichtring abnehmen. Deckel abheben.";
  static const s212 = italian
      ? "Rimuovi filtro e rotella"
      : "Sieb und Einstellrad lösen";
  static const s213 = italian
      ? "Rimuovi il filtro interno. Spingi fuori la rotella del flusso d’aria con l’utensile della camera; conserva la relativa guarnizione."
      : "Inneres Sieb herausnehmen. Das Luftstrom-Einstellrad mit dem Füllkammerwerkzeug herausdrücken; den zugehörigen Dichtring sicher ablegen.";
  static const s214 = italian
      ? "Rimuovi la base dell’unità"
      : "Kühleinheitboden abnehmen";
  static const s215 = italian
      ? "Svita la base ruotandola di 90° in senso antiorario. Spingi fuori delicatamente il filtro con un cotton fioc. Rimuovi la guarnizione grande dalla tacca usando l’utensile."
      : "Boden um 90° gegen den Uhrzeigersinn abdrehen. Sein Sieb mit einem Wattestäbchen vorsichtig herausdrücken. Großen Dichtring an der Aussparung mit dem Werkzeug lösen.";
  static const s216 = italian ? "Spazzola i filtri" : "Siebe ausbürsten";
  static const s217 = italian
      ? "Rimuovi i residui sciolti con il pennello. Se il filtro della camera è ostruito, sollevalo delicatamente di lato con pinzette appuntite ed estrailo. Sostituisci i filtri danneggiati."
      : "Lose Rückstände mit dem Pinsel entfernen. Ein verstopftes Füllkammersieb vorsichtig seitlich mit einer spitzen Pinzette lösen und herausnehmen. Beschädigte Siebe ersetzen.";
  static const s218 = italian ? "Rimonta le parti" : "Wieder zusammensetzen";
  static const s219 = italian
      ? "Monta in ordine inverso. La guarnizione si appoggia direttamente sulla rotella, con “TOP” rivolto verso l’alto. Inserisci correttamente guarnizioni e filtri nelle rispettive scanalature."
      : "In umgekehrter Reihenfolge montieren. Der Dichtring sitzt direkt auf dem Einstellrad, „TOP“ zeigt nach oben. Dichtringe und Siebe korrekt in ihre Nuten einsetzen.";
  static const s220 = italian
      ? "Pulisci unità di raffreddamento e boccaglio in presenza di depositi visibili, al più tardi 7 giorni dopo l’ultimo utilizzo. Rimuovi i residui grossolani dopo ogni utilizzo."
      : "Kühleinheit und Mundstück bei sichtbaren Ablagerungen säubern, spätestens 7 Tage nach der letzten Benutzung. Grobe Rückstände nach jeder Benutzung entfernen.";
  static const s221 = italian ? "VEAZY: pulizia" : "VEAZY: Reinigung";
  static const s222 = italian
      ? "VEAZY: smontaggio e montaggio"
      : "VEAZY: Zerlegen und Zusammenbauen";
  static const s223 = italian
      ? "VEAZY: istruzioni, capitolo 7"
      : "VEAZY: Gebrauchsanweisung, Kapitel 7";
  static const s224 = italian ? "Rimuovi il boccaglio" : "Mundstück lösen";
  static const s225 = italian
      ? "Ruota leggermente il boccaglio in senso antiorario ed estrailo. Rimuovi la guarnizione dalla tacca usando l’utensile della camera."
      : "Mundstück leicht gegen den Uhrzeigersinn drehen und herausziehen. Den Dichtring mit Aussparung und Füllkammerwerkzeug abnehmen.";
  static const s226 = italian ? "Apri il coperchio" : "Deckel öffnen";
  static const s227 = italian
      ? "Con il bordo del boccaglio nella tacca, allenta la chiusura in senso antiorario. Rimuovi chiusura e guarnizione, poi solleva il coperchio."
      : "Mit der Mundstückkante den Drehverschluss an seiner Kerbe gegen den Uhrzeigersinn lösen. Verschluss samt Dichtring entnehmen und den Deckel abheben.";
  static const s228 = italian
      ? "Rimuovi il piano intermedio"
      : "Zwischenboden lösen";
  static const s229 = italian
      ? "Fai scorrere il piano intermedio dalla base dell’unità di raffreddamento. Poi svita la base dal dispositivo ruotandola di 90° in senso antiorario."
      : "Den Zwischenboden vom Kühleinheitboden schieben. Dann den Kühleinheitboden um 90° gegen den Uhrzeigersinn vom Gerät abdrehen.";
  static const s230 = italian
      ? "Rimuovi filtro e guarnizione"
      : "Sieb und Dichtung entnehmen";
  static const s231 = italian
      ? "Spingi fuori il filtro dall’alto con l’utensile della camera. Solleva la guarnizione grande dalla tacca. Rimuovi con cautela un filtro ostruito della camera usando pinzette appuntite."
      : "Das Sieb mit dem Füllkammerwerkzeug von oben herausdrücken. Den großen Dichtring an der Aussparung aushebeln. Verstopftes Füllkammersieb vorsichtig mit einer spitzen Pinzette lösen.";
  static const s232 = italian
      ? "Pulisci le singole parti"
      : "Einzelteile reinigen";
  static const s233 = italian
      ? "Pulisci le parti smontate dell’unità di raffreddamento e il filtro della camera in acqua tiepida e detersivo per 5–30 minuti. In alternativa, alcol isopropilico per non più di 30 minuti."
      : "Ausgebaute Kühleinheitteile und Füllkammersieb 5–30 Minuten in warmem Spülwasser reinigen. Alternativ höchstens 30 Minuten in Isopropanol.";
  static const s234 = italian
      ? "L’alcol isopropilico è facilmente infiammabile: ventila bene e tieni lontane le fonti di accensione. Non immergere mai il corpo del dispositivo."
      : "Isopropanol ist leicht entzündlich: gut lüften, Zündquellen fernhalten. Das Grundgerät niemals einlegen.";
  static const s235 = italian ? "Rimonta con cura" : "Sorgfältig zusammenbauen";
  static const s236 = italian
      ? "Monta in ordine inverso. Inserisci il piano intermedio e posiziona correttamente le guarnizioni. Inserisci il filtro della camera con la curvatura verso l’alto, poi appiattiscilo nella scanalatura con l’utensile."
      : "In umgekehrter Reihenfolge montieren. Zwischenboden aufschieben, Dichtringe korrekt setzen. Füllkammersieb mit Wölbung nach oben einsetzen und mit dem Werkzeug flach in die Nut drücken.";
  static const s237 = italian
      ? "Pulisci regolarmente unità di raffreddamento e boccaglio e quando compaiono depositi; spazzola i filtri dopo ogni utilizzo. Il controllo settimanale dell’app è indicativo, non una scadenza fissa del produttore."
      : "Kühleinheit und Mundstück regelmäßig und bei Ablagerungen reinigen, Siebe nach jeder Nutzung ausbürsten. Der wöchentliche App-Check ist eine Orientierung, keine feste Herstellervorgabe.";
  static const s238 = italian ? "CRAFTY+: pulizia" : "CRAFTY+: Reinigung";
  static const s239 = italian
      ? "CRAFTY+: smontaggio e montaggio"
      : "CRAFTY+: Demontage und Montage";
  static const s240 = italian
      ? "Istruzioni, capitolo 7"
      : "Gebrauchsanweisung, Kapitel 7";
  static const s241 = italian ? "Sblocca il coperchio" : "Deckel entriegeln";
  static const s242 = italian
      ? "Fai scorrere il fermo verso il boccaglio ed estrai il coperchio dell’unità di raffreddamento. Inclina delicatamente il boccaglio, estrailo e rimuovi la sua guarnizione."
      : "Deckelriegel in Richtung Mundstück schieben und den Kühleinheitdeckel abziehen. Das Mundstück leicht hin und her kippen, herausziehen und den Mundstückdichtring abnehmen.";
  static const s243 = italian
      ? "Metti da parte il fermo"
      : "Deckelriegel beiseitelegen";
  static const s244 = italian
      ? "Prima del bagno in alcol, premi il fermo da un lato, sollevalo dall’altro e sfilalo lateralmente."
      : "Vor einem Alkoholbad den Riegel an einer Seite andrücken, gegenüber anheben und zur anderen Seite herausschieben.";
  static const s245 = italian
      ? "Non immergere in alcol il fermo con adesivo olografico. Per questo componente usa acqua tiepida e detersivo."
      : "Der Riegel mit Hologramm-Aufkleber gehört nicht ins Alkoholbad. Für ihn warmes Spülwasser verwenden.";
  static const s246 = italian
      ? "Rimuovi base e guarnizioni"
      : "Boden und Dichtungen lösen";
  static const s247 = italian
      ? "Svita la base dell’unità di raffreddamento di 90° in senso antiorario. Rimuovi la guarnizione grande dalla tacca e quella piccola; spingi fuori il filtro superiore con l’utensile della camera."
      : "Kühleinheitboden um 90° gegen den Uhrzeigersinn abschrauben. Großen Dichtring an der Aussparung lösen, kleinen abnehmen und oberes Sieb mit dem Füllkammerwerkzeug herausdrücken.";
  static const s248 = italian ? "Elimina i residui" : "Rückstände entfernen";
  static const s249 = italian
      ? "Spazzola i filtri. Se il filtro della camera è ostruito, premilo lungo la scanalatura con l’utensile finché si incurva e può essere estratto."
      : "Siebe ausbürsten. Bei verstopftem Füllkammersieb dieses mit dem Füllkammerwerkzeug entlang der Nut eindrücken, bis es sich wölbt und herausnehmen lässt.";
  static const s250 = italian
      ? "Pulisci l’unità di raffreddamento"
      : "Kühleinheit reinigen";
  static const s251 = italian
      ? "Pulisci le parti smontate con acqua tiepida e detersivo. In alternativa immergi in alcol isopropilico per massimo 30 minuti le parti dell’unità senza fermo e il filtro della camera."
      : "Ausgebaute Teile mit warmem Spülwasser reinigen. Alternativ Kühleinheitteile ohne Deckelriegel und das Füllkammersieb höchstens 30 Minuten in Isopropanol legen.";
  static const s252 = italian
      ? "Facilmente infiammabile: ventila e tieni lontane le fonti di accensione. Non immergere in alcol neppure macinino, ausilio di riempimento e caricatore."
      : "Leicht entzündlich: lüften und Zündquellen fernhalten. Auch Kräutermühle, Füllhilfe und Magazin gehören nicht ins Alkoholbad.";
  static const s253 = italian
      ? "Inserisci tutto correttamente"
      : "Alles korrekt einsetzen";
  static const s254 = italian
      ? "Rimonta in ordine inverso. La piccola guarnizione della base deve essere completamente inserita nel coperchio e non visibile. Posiziona i filtri nelle scanalature. Verifica che il passaggio dell’aria sia libero prima dell’uso."
      : "Umgekehrt zusammenbauen. Der kleine Bodendichtring muss vollständig im Deckel sitzen und unsichtbar sein. Siebe sorgfältig in ihre Nuten einsetzen. Vor dem Einsatz den freien Luftweg prüfen.";
  static const s255 = italian
      ? "Pennello morbido per pulizia e panno"
      : "Weicher Reinigungspinsel & Tuch";
  static const s256 = italian
      ? "Ciotola, acqua tiepida e detersivo per piatti"
      : "Schale, warmes Wasser & Spülmittel";
  static const s257 = italian
      ? "In alternativa alcol isopropilico al 70 % per le parti rimovibili"
      : "Alternativ Isopropanol 70 % für abnehmbare Teile";
  static const s258 = italian
      ? "Se necessario, nuovo pallone o tubo (minimo 1 m)"
      : "Bei Bedarf neuer Ballon oder Schlauch (mind. 1 m)";
  static const s259 = italian
      ? "Pulisci regolarmente camera di riempimento, raccordo del tubo e boccaglio. Pulisci la camera al cambio di utilizzatore e prima di un nuovo pallone o tubo. Secondo il produttore, sostituisci ogni due settimane pallone con boccaglio e tubo."
      : "Füllkammer, Schlauchkrümmer und Mundstück regelmäßig reinigen. Bei Nutzerwechsel und vor neuem Ballon/Schlauch die Füllkammer reinigen. Ballon samt Mundstück und Schlauch laut Hersteller alle zwei Wochen ersetzen.";
  static const s260 = italian ? "VOLCANO: pulizia" : "VOLCANO: Reinigung";
  static const s261 = italian
      ? "HYBRID: istruzioni, capitoli 7.6–7.8"
      : "HYBRID: Anleitung, Kapitel 7.6–7.8";
  static const s262 = italian
      ? "Scollega e lascia raffreddare"
      : "Strom trennen und abkühlen";
  static const s263 = italian
      ? "Spegni il dispositivo e stacca la spina. Lascia raffreddare completamente camera di riempimento, coperchio e unità del tubo."
      : "Gerät ausschalten und Netzstecker ziehen. Füllkammer, Deckel und Schlaucheinheit vollständig abkühlen lassen.";
  static const s264 = italian
      ? "Non toccare le parti metalliche calde. Non lavare né immergere il corpo del dispositivo."
      : "Die heißen Metallteile nicht berühren. Grundgerät niemals nass reinigen oder eintauchen.";
  static const s265 = italian
      ? "Tratta gli accessori separatamente"
      : "Zubehör getrennt behandeln";
  static const s266 = italian
      ? "Pallone e tubo sono parti da sostituire. Sfila il tubo dal raccordo e dal boccaglio. Pulisci solo il raccordo e il boccaglio separato del tubo."
      : "Ballon und Schlauch sind Austauschteile. Den Schlauch von Krümmer und Mundstück abziehen. Nur Krümmer und separates Schlauchmundstück werden mitgereinigt.";
  static const s267 = italian
      ? "Sostituisci ogni due settimane pallone EASY VALVE con boccaglio e tubo. Il tubo di ricambio deve essere lungo almeno 1 m; non condividere gli accessori."
      : "EASY-VALVE-Ballon samt Mundstück und Schlauch alle zwei Wochen ersetzen. Ersatzschlauch nicht kürzer als 1 m; Zubehör nicht mit anderen teilen.";
  static const s268 = italian ? "Smonta il coperchio" : "Deckel zerlegen";
  static const s269 = italian
      ? "Spingi fuori il filtro superiore con il manico del pennello. Rimuovi l’anello del coperchio e spingi il cilindro verso il basso fuori dall’alloggiamento."
      : "Oberes Sieb mit dem Pinselstiel herausdrücken. Deckelring abstreifen und den Deckelzylinder nach unten aus dem Gehäuse drücken.";
  static const s270 = italian ? "Smonta la camera" : "Füllkammer zerlegen";
  static const s271 = italian
      ? "Spingi verso l’alto il cilindro della camera con il filtro, estraendolo dall’alloggiamento. Rimuovi il filtro inferiore dal cilindro verso l’alto."
      : "Füllkammerzylinder mit Sieb nach oben aus dem Gehäuse drücken. Das untere Sieb nach oben aus dem Zylinder entnehmen.";
  static const s272 = italian
      ? "Pulisci le parti rimovibili"
      : "Abnehmbare Teile reinigen";
  static const s273 = italian
      ? "Pulisci le parti della camera, il raccordo e il boccaglio del tubo con acqua tiepida e detersivo oppure alcol isopropilico al 70 % e un panno morbido. Lascia la plastica nell’alcol per massimo 30 minuti."
      : "Füllkammerteile, Krümmer und Schlauchmundstück mit warmem Spülwasser oder Isopropanol 70 % und weichem Tuch reinigen. Kunststoff höchstens 30 Minuten im Alkohol lassen.";
  static const s274 = italian
      ? "L’alcol isopropilico è facilmente infiammabile. Tieni lontane le fonti di accensione. Non immergere pallone e tubo nel bagno di pulizia."
      : "Isopropanol ist leicht entzündlich. Zündquellen fernhalten. Ballon und Schlauch nicht mit ins Reinigungsbad legen.";
  static const s275 = italian
      ? "Pulisci il corpo esterno"
      : "Grundgerät abwischen";
  static const s276 = italian
      ? "Passa sul corpo un panno appena umido. Rimuovi con cautela i residui visibili dall’elemento riscaldante freddo usando un panno inumidito solo con acqua, non gocciolante."
      : "Gehäuse nur leicht feucht abwischen. Sichtbare Rückstände am kalten Heizelement vorsichtig mit einem nur wasserfeuchten, nicht tropfenden Tuch entfernen.";
  static const s277 = italian
      ? "Usa solo acqua sull’elemento riscaldante. Non usare spazzole metalliche, aghi o strumenti abrasivi."
      : "Am Heizelement nur Wasser verwenden. Keine Metallbürsten, Nadeln oder scheuernden Hilfsmittel.";
  static const s278 = italian
      ? "Asciuga e controlla le parti"
      : "Teile trocknen und prüfen";
  static const s279 = italian
      ? "Rimuovi i residui di detergente dalle parti rimovibili. Lascia asciugare completamente, controlla eventuali danni e sostituisci le parti danneggiate."
      : "Reinigungsmittelrückstände von den abnehmbaren Teilen entfernen. Vollständig trocknen lassen, auf Schäden prüfen und beschädigte Teile ersetzen.";
  static const s280 = italian
      ? "Monta e usa solo quando tutto è asciutto e i vapori del detergente sono completamente evaporati."
      : "Erst zusammenbauen und benutzen, wenn alles trocken ist und Reinigungsmitteldämpfe vollständig verflogen sind.";
  static const s281 = italian ? "Riassembla" : "Wieder zusammenbauen";
  static const s282 = italian
      ? "Monta in ordine inverso. Aggancia i cilindri; in particolare il filtro superiore deve essere ben inserito nella scanalatura. Collega raccordo e boccaglio al tubo adatto."
      : "In umgekehrter Reihenfolge zusammensetzen. Zylinder einrasten lassen; besonders das obere Sieb muss korrekt in seiner Nut sitzen. Krümmer und Mundstück auf den passenden Schlauch stecken.";
  static const s284 = italian
      ? "PENNELLO · PANNO · DETERGENTE"
      : "PINSEL · TUCH · REINIGER";
  static const s285 = italian ? "SPENTO E FREDDO" : "AUS + ABGEKÜHLT";
  static const s286 = italian ? "SMONTARE" : "LÖSEN";
  static const s287 = italian
      ? "METTI DA PARTE IL FERMO"
      : "RIEGEL SEPARAT ABLEGEN";
  static const s288 = italian
      ? "DISPONI LE PARTI IN ORDINE"
      : "TEILE GEORDNET ABLEGEN";
  static const s289 = italian
      ? "ELEMENTO: SOLO ACQUA"
      : "HEIZELEMENT: NUR WASSER";
  static const s290 = italian
      ? "PULISCI I FILTRI CON CURA"
      : "SIEBE VORSICHTIG SÄUBERN";
  static const s291 = italian ? "SOLO PARTI SMONTATE" : "NUR AUSGEBAUTE TEILE";
  static const s292 = italian
      ? "ASCIUGA COMPLETAMENTE"
      : "VOLLSTÄNDIG TROCKNEN";
  static const s293 = italian
      ? "SB CONTROL · Notifica di prova"
      : "SB CONTROL · Testerinnerung";
  static const s295 = italian
      ? "Ecco il tuo promemoria. Tocca per aprire Cura."
      : "So erscheint deine Erinnerung. Tippen öffnet die Pflege.";
  static const s296 = italian
      ? "Controlla camera, filtri e accessori. La guida illustrata ti aiuta nella manutenzione."
      : "Prüfe Füllkammer, Siebe und Zubehör. Die Bildanleitung hilft dir bei der Pflege.";
  static const s297 = italian
      ? "Controlla unità di raffreddamento e filtri. La guida illustrata ti aiuta nella pulizia."
      : "Prüfe Kühleinheit und Siebe. Die Bildanleitung hilft dir bei der Reinigung.";
  static const s298 = italian ? "Pulizia e cura" : "Reinigung und Pflege";
  static const s299 = italian
      ? "Promemoria locali per la cura dei dispositivi"
      : "Lokale Erinnerungen zum Pflegecheck deiner Geräte";
  static const s300 = italian ? "Demo disconnessa" : "Demo getrennt";
  static const s301 = italian
      ? "Comando demo non riconosciuto"
      : "Kein Demo-Befehl";
  static const s302 = italian
      ? "Il Bluetooth reale non è disponibile in questa anteprima. Usa l’app nativa iOS o Android."
      : "Echtes Bluetooth ist in dieser Vorschau nicht verfügbar. Nutze die native iOS- oder Android-App.";
  static const s303 = italian
      ? "È richiesto iOS o Android"
      : "iOS oder Android erforderlich";
  static const s304 = italian
      ? "Accesso Bluetooth negato. Consentilo nelle impostazioni di sistema."
      : "Bluetooth-Zugriff fehlt. Erlaube ihn in den Systemeinstellungen.";
  static const s305 = italian
      ? "Bluetooth disattivato."
      : "Bluetooth ist ausgeschaltet.";
  static const s306 = italian
      ? "Accesso Bluetooth negato. Controlla le impostazioni di sistema."
      : "Bluetooth-Zugriff fehlt. Prüfe die Systemeinstellungen.";
  static const s307 = italian
      ? "Android richiede i servizi di localizzazione attivi per la scansione BLE."
      : "Android benötigt aktivierte Standortdienste für den BLE-Scan.";
  static const s309 = italian
      ? "Nessun dispositivo connesso"
      : "Kein Gerät verbunden";
  static const s310 = italian
      ? "La caratteristica non supporta la scrittura"
      : "Merkmal unterstützt keine Schreibzugriffe";
  static const s311 = italian ? "Annulla" : "Abbrechen";
  static const s312 = italian ? "Spegnimento" : "Abschaltung";
  static const s313 = italian ? "Batteria" : "Akku";
  static const s314 = italian ? "Codice analisi" : "Analysecode";
  static const s315 = italian ? "Riscalda" : "Aufheizen";
  static const s316 = italian ? "Da completare" : "Ausstehend";
  static const s317 = italian ? "Pronto" : "Bereit";
  static const s318 = italian ? "Ore di utilizzo" : "Betriebszeit";
  static const s319 = italian ? "Servizi Bluetooth" : "Bluetooth-Dienste";
  static const s320 = italian ? "Boost" : "Boost-Offset";
  static const s321 = italian ? "Origine dati" : "Datenquelle";
  static const s322 = italian ? "Modalità demo" : "Demo-Modus";
  static const s323 = italian ? "Diagnostica" : "Diagnose";
  static const s324 = italian ? "Impostazioni" : "Einstellungen";
  static const s325 = italian ? "Rimuovi" : "Entfernen";
  static const s326 = italian ? "SALVATI" : "GESPEICHERT";
  static const s327 = italian ? "Test hardware" : "Hardwaretests";
  static const s328 = italian ? "Luminosità" : "Helligkeit";
  static const s329 = italian
      ? "Indicazioni del produttore"
      : "Herstellerangaben";
  static const s330 = italian ? "Temperatura attuale" : "Isttemperatur";
  static const s331 = italian ? "Limite di ricarica" : "Ladelimit";
  static const s332 = italian ? "Modello" : "Modell";
  static const s333 = italian ? "Alimentazione di rete" : "Netzbetrieb";
  static const s334 = italian ? "Opzioni" : "Optionen";
  static const s335 = italian ? "CURA" : "PFLEGE";
  static const s336 = italian ? "Cura" : "Pflege";
  static const s337 = italian
      ? "Notifiche di pulizia"
      : "Pflege-Benachrichtigungen";
  static const s338 = italian ? "Numero di serie" : "Seriennummer";
  static const s339 = italian ? "Simulazione" : "Simulation";
  static const s340 = italian ? "Salva" : "Speichern";
  static const s341 = italian ? "Superboost" : "Superboost-Offset";
  static const s342 = italian ? "Unità di temperatura" : "Temperatureinheit";
  static const s343 = italian ? "Rinomina" : "Umbenennen";
  static const s344 = italian ? "Sconosciuto" : "Unbekannt";
  static const s345 = italian ? "REGISTRO CONNESSIONE" : "VERBINDUNGSPROTOKOLL";
  static const s346 = italian ? "CONNESSO" : "VERBUNDEN";
  static const s347 = italian ? "Connesso" : "Verbunden";
  static const s348 = italian ? "Alimentazione" : "Versorgung";
  static const s349 = italian ? "Vibrazione" : "Vibration";
  static const s350 = italian ? "Avanti" : "Weiter";
  static const s351 = italian ? "TEMPERATURA IMPOSTATA" : "ZIELTEMPERATUR";
  static const s352 = italian ? "SOSTITUIRE" : "AUSTAUSCHEN";
  static const s353 = italian
      ? "Versione 0.5.0 · Build di sviluppo"
      : "Version 0.5.0 · Entwicklungsstand";
}
