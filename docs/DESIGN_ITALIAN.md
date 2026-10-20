# 0.5.0 — dashboard and Italian Android build

Historical record. Version 0.6.0 replaces the device illustrations and immediate
Boost writes; see [UX_060.md](UX_060.md).

The temperature page now contains the existing device-stored Boost and Superboost
increment sliders. Firmware gates, range checks, serialized BLE writes and readback
confirmation remain in AppController. This redesign does not invent an activation
command: activation still uses the physical device button. HYBRID has no Boost
slider; CRAFTY-family limits remain constrained by base temperature.

The control card uses decorative, logo-free device illustrations, a large target
readout, a temperature slider and the existing explicit heating control. CRAFTY
and CRAFTY+ share their family illustration. Unknown devices use the generic icon.
Images are artistic interpretations, not exact component diagrams or manufacturer
assets. Cleaning guides retain their separate schematic drawings.

## Languages

German remains the default build. The friend APK explicitly uses Italian:

```sh
flutter pub get
flutter test
flutter test --dart-define=SB_LANGUAGE=it test/italian_test.dart
flutter build apk --debug --dart-define=SB_LANGUAGE=it --dart-define=SB_DEMO=false
```

`lib/l10n/strings.dart` contains compile-time German/Italian text constants;
`tool/translations/it.json` records the translation pairs. Interpolated text remains
at its call site. Flutter's built-in controls use Italian Material localization.
Language is chosen per build, not from Bluetooth data and not by changing the
phone language. Device identifiers, wire bytes, preferences keys and firmware
names are never translated. External manufacturer links retain their verified
original URLs and may open German or English pages.

This APK is a debug-signed development build for direct installation, not a Play
Store release. BLE uses the native transport. Hardware tests on the friend's phone
and vaporizer, notification delivery while idle, and real-device visual checks
remain outstanding. No claim of physical testing follows from simulator tests.

## Art provenance

New art and icon were produced with the built-in image generation tool, then
resized/compressed for the app. No external API key or CLI generation was used.
Project assets: `assets/art/{icon,venty,veazy,crafty,volcanoHybrid}.webp`.
Platform launcher icon PNGs are generated from the same icon image.

Prompt set: premium dark studio product illustrations; graphite ribbed VENTY-style
portable with display; compact ribbed CRAFTY-style portable without display;
VEAZY-style dark teal portable with black cooling unit; VOLCANO HYBRID-style steel
truncated cone with dark display base. Complete centered devices, orange rim light,
near-black background, no logos, text, smoke or props. Icon prompt groups two black
ribbed portables and one brushed-metal cone with strong small-size silhouette.
These are decorative images only, never used for cleaning instructions.

## Validation for this revision

- 56 manufacturer-vector/protocol core checks passed locally.
- Existing German controller/care/layout tests passed; the new dashboard gesture
  test passed after scrolling its real slider into the test viewport.
- Both Italian tests passed: five model layouts at 320 px and cleaning guide
  coverage/limits. The test-only simulator does not claim real BLE validation.
- Flutter analyze: no issues. Italian release web compilation succeeded.
- CI repeats the German suite, Italian suite, analyze and the native Android build
  before producing the APK. See the PR checks for the final build result.
- Compiled Italian web UI browser checks passed: heating button, all five device
  illustrations, 320 px layout; VENTY illustrated guide, dry-parts confirmation,
  saved cleaning, reminder opt-in, persistence after reload, global notifications
  off, and HYBRID guide. No JavaScript errors, missing assets or external requests.
