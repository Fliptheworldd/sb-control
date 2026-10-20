import '../core/models.dart';

enum CareArt {
  tools,
  power,
  mouthpiece,
  cap,
  parts,
  brush,
  bath,
  rinse,
  dry,
  assemble,
  replace,
}

class CareStep {
  const CareStep(this.title, this.text, this.art, {this.warning});
  final String title, text;
  final CareArt art;
  final String? warning;
}

class CareSource {
  const CareSource(this.label, this.url);
  final String label, url;
}

class CareGuide {
  const CareGuide({
    required this.model,
    required this.supplies,
    required this.steps,
    required this.sources,
    required this.manufacturerAdvice,
  });
  final DeviceModel model;
  final List<String> supplies;
  final List<CareStep> steps;
  final List<CareSource> sources;
  final String manufacturerAdvice;
}

const careModels = [
  DeviceModel.venty,
  DeviceModel.veazy,
  DeviceModel.crafty,
  DeviceModel.craftyPlus,
  DeviceModel.volcanoHybrid,
];

const _portableSupplies = [
  'Reinigungspinsel & Wattestäbchen',
  'Füllkammerwerkzeug, Schale & weiches Tuch',
  'Warmes Spülwasser; alternativ Isopropanol',
  'Sauberes Wasser zum Nachspülen',
];
const _power = CareStep(
  'Erst ausschalten',
  'Gerät ausschalten, Ladekabel abziehen und alles abkühlen lassen. Das Gehäuse nur mit einem weichen, trockenen oder leicht feuchten Tuch säubern.',
  CareArt.power,
  warning:
      'Gerät und Kabel niemals einweichen. Kein Reiniger darf in die Elektronik laufen.',
);
const _bath = CareStep(
  'Gelöste Teile reinigen',
  'Die freigegebenen, ausgebauten Teile mindestens 5 Minuten in warmem Spülwasser reinigen. Alternativ Isopropanol verwenden: höchstens 30 Minuten Kontakt, nicht länger.',
  CareArt.bath,
  warning:
      'Isopropanol ist leicht entzündlich. Gut lüften, Zündquellen fernhalten und die Angaben des Reinigungsmittelherstellers beachten.',
);
const _rinse = CareStep(
  'Gründlich nachspülen',
  'Die gereinigten Einzelteile mindestens eine Minute unter fließendem Wasser abspülen. Das Grundgerät bleibt dabei trocken.',
  CareArt.rinse,
);
const _dry = CareStep(
  'Vollständig trocknen',
  'Alle Teile an der Luft vollständig trocknen lassen. Auf Risse, Verfärbungen und verhärtete oder weiche Stellen prüfen. Beschädigte Teile ersetzen.',
  CareArt.dry,
  warning:
      'Erst wieder benutzen, wenn alles trocken ist und sämtliche Reinigungsmitteldämpfe verflogen sind. Nicht zum Trocknen aufheizen.',
);

CareGuide guideFor(DeviceModel model) => switch (model) {
  DeviceModel.venty => _venty,
  DeviceModel.veazy => _veazy,
  DeviceModel.crafty || DeviceModel.craftyPlus => _crafty(model),
  DeviceModel.volcanoHybrid => _hybrid,
  DeviceModel.unknown => throw ArgumentError(
    'Kein Reinigungsprofil für unbekanntes Gerät',
  ),
};

const _venty = CareGuide(
  model: DeviceModel.venty,
  supplies: _portableSupplies,
  manufacturerAdvice:
      'Vor jeder Anwendung kontrollieren. Kühleinheit und Mundstück bei Ablagerungen reinigen, spätestens 7 Tage nach der letzten Anwendung. Siebe nach jeder Nutzung ausbürsten.',
  sources: [
    CareSource(
      'VENTY: Reinigung',
      'https://support.storz-bickel.com/hc/de/articles/36557361120401-Reinigung',
    ),
    CareSource(
      'VENTY: Zerlegen und Zusammenbauen',
      'https://support.storz-bickel.com/hc/en-us/articles/36056947203473-Disassembling-Assembling',
    ),
    CareSource(
      'VENTY: Gebrauchsanweisung, Kapitel 7',
      'https://www.storz-bickel.com/de/amfile/file/download/file/621/',
    ),
  ],
  steps: [
    _power,
    CareStep(
      'Mundstück herausziehen',
      'Die Kühleinheit bleibt zunächst aufgeschraubt. Mundstück leicht hin und her kippen, herausziehen und seinen Dichtring an der Aussparung abnehmen.',
      CareArt.mouthpiece,
    ),
    CareStep(
      'Drehverschluss öffnen',
      'Die Mundstückkante in die Kerbe des Drehverschlusses setzen. Gegen den Uhrzeigersinn öffnen, herausziehen und den Dichtring abnehmen. Deckel abheben.',
      CareArt.cap,
    ),
    CareStep(
      'Sieb und Einstellrad lösen',
      'Inneres Sieb herausnehmen. Das Luftstrom-Einstellrad mit dem Füllkammerwerkzeug herausdrücken; den zugehörigen Dichtring sicher ablegen.',
      CareArt.parts,
    ),
    CareStep(
      'Kühleinheitboden abnehmen',
      'Boden um 90° gegen den Uhrzeigersinn abdrehen. Sein Sieb mit einem Wattestäbchen vorsichtig herausdrücken. Großen Dichtring an der Aussparung mit dem Werkzeug lösen.',
      CareArt.parts,
    ),
    CareStep(
      'Siebe ausbürsten',
      'Lose Rückstände mit dem Pinsel entfernen. Ein verstopftes Füllkammersieb vorsichtig seitlich mit einer spitzen Pinzette lösen und herausnehmen. Beschädigte Siebe ersetzen.',
      CareArt.brush,
    ),
    _bath,
    _rinse,
    _dry,
    CareStep(
      'Wieder zusammensetzen',
      'In umgekehrter Reihenfolge montieren. Der Dichtring sitzt direkt auf dem Einstellrad, „TOP“ zeigt nach oben. Dichtringe und Siebe korrekt in ihre Nuten einsetzen.',
      CareArt.assemble,
    ),
  ],
);

const _veazy = CareGuide(
  model: DeviceModel.veazy,
  supplies: _portableSupplies,
  manufacturerAdvice:
      'Kühleinheit und Mundstück bei sichtbaren Ablagerungen säubern, spätestens 7 Tage nach der letzten Benutzung. Grobe Rückstände nach jeder Benutzung entfernen.',
  sources: [
    CareSource(
      'VEAZY: Reinigung',
      'https://support.storz-bickel.com/hc/de/articles/36674537322769-Reinigung',
    ),
    CareSource(
      'VEAZY: Zerlegen und Zusammenbauen',
      'https://support.storz-bickel.com/hc/de/articles/38391715337361-Demontage-Montage',
    ),
    CareSource(
      'VEAZY: Gebrauchsanweisung, Kapitel 7',
      'https://www.storz-bickel.com/de/amfile/file/download/file/668/',
    ),
  ],
  steps: [
    _power,
    CareStep(
      'Mundstück lösen',
      'Mundstück leicht gegen den Uhrzeigersinn drehen und herausziehen. Den Dichtring mit Aussparung und Füllkammerwerkzeug abnehmen.',
      CareArt.mouthpiece,
    ),
    CareStep(
      'Deckel öffnen',
      'Mit der Mundstückkante den Drehverschluss an seiner Kerbe gegen den Uhrzeigersinn lösen. Verschluss samt Dichtring entnehmen und den Deckel abheben.',
      CareArt.cap,
    ),
    CareStep(
      'Zwischenboden lösen',
      'Den Zwischenboden vom Kühleinheitboden schieben. Dann den Kühleinheitboden um 90° gegen den Uhrzeigersinn vom Gerät abdrehen.',
      CareArt.parts,
    ),
    CareStep(
      'Sieb und Dichtung entnehmen',
      'Das Sieb mit dem Füllkammerwerkzeug von oben herausdrücken. Den großen Dichtring an der Aussparung aushebeln. Verstopftes Füllkammersieb vorsichtig mit einer spitzen Pinzette lösen.',
      CareArt.brush,
    ),
    CareStep(
      'Einzelteile reinigen',
      'Ausgebaute Kühleinheitteile und Füllkammersieb 5–30 Minuten in warmem Spülwasser reinigen. Alternativ höchstens 30 Minuten in Isopropanol.',
      CareArt.bath,
      warning:
          'Isopropanol ist leicht entzündlich: gut lüften, Zündquellen fernhalten. Das Grundgerät niemals einlegen.',
    ),
    _rinse,
    _dry,
    CareStep(
      'Sorgfältig zusammenbauen',
      'In umgekehrter Reihenfolge montieren. Zwischenboden aufschieben, Dichtringe korrekt setzen. Füllkammersieb mit Wölbung nach oben einsetzen und mit dem Werkzeug flach in die Nut drücken.',
      CareArt.assemble,
    ),
  ],
);

CareGuide _crafty(DeviceModel model) => CareGuide(
  model: model,
  supplies: _portableSupplies,
  manufacturerAdvice:
      'Kühleinheit und Mundstück regelmäßig und bei Ablagerungen reinigen, Siebe nach jeder Nutzung ausbürsten. Der wöchentliche App-Check ist eine Orientierung, keine feste Herstellervorgabe.',
  sources: const [
    CareSource(
      'CRAFTY+: Reinigung',
      'https://support.storz-bickel.com/hc/de/articles/36103580179473-Reinigung',
    ),
    CareSource(
      'CRAFTY+: Demontage und Montage',
      'https://support.storz-bickel.com/hc/de/articles/36058359911953-Demontage-Montage',
    ),
    CareSource(
      'Gebrauchsanweisung, Kapitel 7',
      'https://www.storz-bickel.com/de/amfile/file/download/file/7/',
    ),
  ],
  steps: const [
    _power,
    CareStep(
      'Deckel entriegeln',
      'Deckelriegel in Richtung Mundstück schieben und den Kühleinheitdeckel abziehen. Das Mundstück leicht hin und her kippen, herausziehen und den Mundstückdichtring abnehmen.',
      CareArt.cap,
    ),
    CareStep(
      'Deckelriegel beiseitelegen',
      'Vor einem Alkoholbad den Riegel an einer Seite andrücken, gegenüber anheben und zur anderen Seite herausschieben.',
      CareArt.parts,
      warning:
          'Der Riegel mit Hologramm-Aufkleber gehört nicht ins Alkoholbad. Für ihn warmes Spülwasser verwenden.',
    ),
    CareStep(
      'Boden und Dichtungen lösen',
      'Kühleinheitboden um 90° gegen den Uhrzeigersinn abschrauben. Großen Dichtring an der Aussparung lösen, kleinen abnehmen und oberes Sieb mit dem Füllkammerwerkzeug herausdrücken.',
      CareArt.parts,
    ),
    CareStep(
      'Rückstände entfernen',
      'Siebe ausbürsten. Bei verstopftem Füllkammersieb dieses mit dem Füllkammerwerkzeug entlang der Nut eindrücken, bis es sich wölbt und herausnehmen lässt.',
      CareArt.brush,
    ),
    CareStep(
      'Kühleinheit reinigen',
      'Ausgebaute Teile mit warmem Spülwasser reinigen. Alternativ Kühleinheitteile ohne Deckelriegel und das Füllkammersieb höchstens 30 Minuten in Isopropanol legen.',
      CareArt.bath,
      warning:
          'Leicht entzündlich: lüften und Zündquellen fernhalten. Auch Kräutermühle, Füllhilfe und Magazin gehören nicht ins Alkoholbad.',
    ),
    _rinse,
    _dry,
    CareStep(
      'Alles korrekt einsetzen',
      'Umgekehrt zusammenbauen. Der kleine Bodendichtring muss vollständig im Deckel sitzen und unsichtbar sein. Siebe sorgfältig in ihre Nuten einsetzen. Vor dem Einsatz den freien Luftweg prüfen.',
      CareArt.assemble,
    ),
  ],
);

const _hybrid = CareGuide(
  model: DeviceModel.volcanoHybrid,
  supplies: [
    'Weicher Reinigungspinsel & Tuch',
    'Schale, warmes Wasser & Spülmittel',
    'Alternativ Isopropanol 70 % für abnehmbare Teile',
    'Bei Bedarf neuer Ballon oder Schlauch (mind. 1 m)',
  ],
  manufacturerAdvice:
      'Füllkammer, Schlauchkrümmer und Mundstück regelmäßig reinigen. Bei Nutzerwechsel und vor neuem Ballon/Schlauch die Füllkammer reinigen. Ballon samt Mundstück und Schlauch laut Hersteller alle zwei Wochen ersetzen.',
  sources: [
    CareSource(
      'VOLCANO: Reinigung',
      'https://support.storz-bickel.com/hc/de/articles/36092589504785-Reinigung',
    ),
    CareSource(
      'HYBRID: Anleitung, Kapitel 7.6–7.8',
      'https://www.storz-bickel.com/de/amfile/file/download/file/40/',
    ),
  ],
  steps: [
    CareStep(
      'Strom trennen und abkühlen',
      'Gerät ausschalten und Netzstecker ziehen. Füllkammer, Deckel und Schlaucheinheit vollständig abkühlen lassen.',
      CareArt.power,
      warning:
          'Die heißen Metallteile nicht berühren. Grundgerät niemals nass reinigen oder eintauchen.',
    ),
    CareStep(
      'Zubehör getrennt behandeln',
      'Ballon und Schlauch sind Austauschteile. Den Schlauch von Krümmer und Mundstück abziehen. Nur Krümmer und separates Schlauchmundstück werden mitgereinigt.',
      CareArt.replace,
      warning:
          'EASY-VALVE-Ballon samt Mundstück und Schlauch alle zwei Wochen ersetzen. Ersatzschlauch nicht kürzer als 1 m; Zubehör nicht mit anderen teilen.',
    ),
    CareStep(
      'Deckel zerlegen',
      'Oberes Sieb mit dem Pinselstiel herausdrücken. Deckelring abstreifen und den Deckelzylinder nach unten aus dem Gehäuse drücken.',
      CareArt.cap,
    ),
    CareStep(
      'Füllkammer zerlegen',
      'Füllkammerzylinder mit Sieb nach oben aus dem Gehäuse drücken. Das untere Sieb nach oben aus dem Zylinder entnehmen.',
      CareArt.parts,
    ),
    CareStep(
      'Abnehmbare Teile reinigen',
      'Füllkammerteile, Krümmer und Schlauchmundstück mit warmem Spülwasser oder Isopropanol 70 % und weichem Tuch reinigen. Kunststoff höchstens 30 Minuten im Alkohol lassen.',
      CareArt.bath,
      warning:
          'Isopropanol ist leicht entzündlich. Zündquellen fernhalten. Ballon und Schlauch nicht mit ins Reinigungsbad legen.',
    ),
    CareStep(
      'Grundgerät abwischen',
      'Gehäuse nur leicht feucht abwischen. Sichtbare Rückstände am kalten Heizelement vorsichtig mit einem nur wasserfeuchten, nicht tropfenden Tuch entfernen.',
      CareArt.brush,
      warning:
          'Am Heizelement nur Wasser verwenden. Keine Metallbürsten, Nadeln oder scheuernden Hilfsmittel.',
    ),
    CareStep(
      'Teile trocknen und prüfen',
      'Reinigungsmittelrückstände von den abnehmbaren Teilen entfernen. Vollständig trocknen lassen, auf Schäden prüfen und beschädigte Teile ersetzen.',
      CareArt.dry,
      warning:
          'Erst zusammenbauen und benutzen, wenn alles trocken ist und Reinigungsmitteldämpfe vollständig verflogen sind.',
    ),
    CareStep(
      'Wieder zusammenbauen',
      'In umgekehrter Reihenfolge zusammensetzen. Zylinder einrasten lassen; besonders das obere Sieb muss korrekt in seiner Nut sitzen. Krümmer und Mundstück auf den passenden Schlauch stecken.',
      CareArt.assemble,
    ),
  ],
);
