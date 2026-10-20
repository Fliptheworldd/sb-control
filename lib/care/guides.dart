import '../l10n/strings.dart';
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

const _portableSupplies = [L.s188, L.s189, L.s190, L.s191];
const _power = CareStep(L.s192, L.s193, CareArt.power, warning: L.s194);
const _bath = CareStep(L.s195, L.s196, CareArt.bath, warning: L.s197);
const _rinse = CareStep(L.s198, L.s199, CareArt.rinse);
const _dry = CareStep(L.s200, L.s201, CareArt.dry, warning: L.s202);

CareGuide guideFor(DeviceModel model) => switch (model) {
  DeviceModel.venty => _venty,
  DeviceModel.veazy => _veazy,
  DeviceModel.crafty || DeviceModel.craftyPlus => _crafty(model),
  DeviceModel.volcanoHybrid => _hybrid,
  DeviceModel.unknown => throw ArgumentError(L.s203),
};

const _venty = CareGuide(
  model: DeviceModel.venty,
  supplies: _portableSupplies,
  manufacturerAdvice: L.s204,
  sources: [
    CareSource(
      L.s205,
      'https://support.storz-bickel.com/hc/de/articles/36557361120401-Reinigung',
    ),
    CareSource(
      L.s206,
      'https://support.storz-bickel.com/hc/en-us/articles/36056947203473-Disassembling-Assembling',
    ),
    CareSource(
      L.s207,
      'https://www.storz-bickel.com/de/amfile/file/download/file/621/',
    ),
  ],
  steps: [
    _power,
    CareStep(L.s208, L.s209, CareArt.mouthpiece),
    CareStep(L.s210, L.s211, CareArt.cap),
    CareStep(L.s212, L.s213, CareArt.parts),
    CareStep(L.s214, L.s215, CareArt.parts),
    CareStep(L.s216, L.s217, CareArt.brush),
    _bath,
    _rinse,
    _dry,
    CareStep(L.s218, L.s219, CareArt.assemble),
  ],
);

const _veazy = CareGuide(
  model: DeviceModel.veazy,
  supplies: _portableSupplies,
  manufacturerAdvice: L.s220,
  sources: [
    CareSource(
      L.s221,
      'https://support.storz-bickel.com/hc/de/articles/36674537322769-Reinigung',
    ),
    CareSource(
      L.s222,
      'https://support.storz-bickel.com/hc/de/articles/38391715337361-Demontage-Montage',
    ),
    CareSource(
      L.s223,
      'https://www.storz-bickel.com/de/amfile/file/download/file/668/',
    ),
  ],
  steps: [
    _power,
    CareStep(L.s224, L.s225, CareArt.mouthpiece),
    CareStep(L.s226, L.s227, CareArt.cap),
    CareStep(L.s228, L.s229, CareArt.parts),
    CareStep(L.s230, L.s231, CareArt.brush),
    CareStep(L.s232, L.s233, CareArt.bath, warning: L.s234),
    _rinse,
    _dry,
    CareStep(L.s235, L.s236, CareArt.assemble),
  ],
);

CareGuide _crafty(DeviceModel model) => CareGuide(
  model: model,
  supplies: _portableSupplies,
  manufacturerAdvice: L.s237,
  sources: const [
    CareSource(
      L.s238,
      'https://support.storz-bickel.com/hc/de/articles/36103580179473-Reinigung',
    ),
    CareSource(
      L.s239,
      'https://support.storz-bickel.com/hc/de/articles/36058359911953-Demontage-Montage',
    ),
    CareSource(
      L.s240,
      'https://www.storz-bickel.com/de/amfile/file/download/file/7/',
    ),
  ],
  steps: const [
    _power,
    CareStep(L.s241, L.s242, CareArt.cap),
    CareStep(L.s243, L.s244, CareArt.parts, warning: L.s245),
    CareStep(L.s246, L.s247, CareArt.parts),
    CareStep(L.s248, L.s249, CareArt.brush),
    CareStep(L.s250, L.s251, CareArt.bath, warning: L.s252),
    _rinse,
    _dry,
    CareStep(L.s253, L.s254, CareArt.assemble),
  ],
);

const _hybrid = CareGuide(
  model: DeviceModel.volcanoHybrid,
  supplies: [L.s255, L.s256, L.s257, L.s258],
  manufacturerAdvice: L.s259,
  sources: [
    CareSource(
      L.s260,
      'https://support.storz-bickel.com/hc/de/articles/36092589504785-Reinigung',
    ),
    CareSource(
      L.s261,
      'https://www.storz-bickel.com/de/amfile/file/download/file/40/',
    ),
  ],
  steps: [
    CareStep(L.s262, L.s263, CareArt.power, warning: L.s264),
    CareStep(L.s265, L.s266, CareArt.replace, warning: L.s267),
    CareStep(L.s268, L.s269, CareArt.cap),
    CareStep(L.s270, L.s271, CareArt.parts),
    CareStep(L.s272, L.s273, CareArt.bath, warning: L.s274),
    CareStep(L.s275, L.s276, CareArt.brush, warning: L.s277),
    CareStep(L.s278, L.s279, CareArt.dry, warning: L.s280),
    CareStep(L.s281, L.s282, CareArt.assemble),
  ],
);
