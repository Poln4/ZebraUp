// C.4 — Headache red flag detection
//
// Pure logic: maps (HeadacheDetail, severityIndex) → List<HeadacheRedFlag>.
// UI translates the enum to localized banner copy + severity treatment.
//
// Red flags implemented:
//   - csfLeakPattern: postural worse-upright + severe pain.
//     Spontaneous CSF leaks are over-represented in EDS; positional
//     headache is the cardinal feature.
//     Refs: Reinstein 2013 (DOI: 10.1038/ejhg.2012.270);
//           Henderson 2017 (DOI: 10.1002/ajmg.c.31549)
//
//   - intracranialHypertension: postural worse-recumbent + severe pain.
//     IIH is also enriched in hypermobile populations.
//     Ref: ICHD-3 7.1 criteria; Mollan 2018 (DOI: 10.1136/jnnp-2017-317440)
//
//   - thunderclap: onset=thunderclap, any severity.
//     SNNOOP10 #1 — must rule out SAH, RCVS, venous thrombosis.
//     Refs: Wijeratne 2023 (DOI: 10.1016/j.ensci.2023.100473);
//           Munoz-Ceron 2019 (DOI: 10.1371/journal.pone.0208728)
//
// Deferred (insufficient data captured in C.4):
//   - meningitis pattern (needs fever + neck stiffness)
//   - prolonged aura (needs aura duration capture)

import '../models/headache_detail.dart';
import '../models/red_flag_severity.dart';

enum HeadacheRedFlag {
  /// Severity tag for UI treatment. `urgent` should render a strong
  /// banner with explicit "seek emergency care" wording. `advisory`
  /// renders as a softer informational banner.
  // (Enum values declared below; severity is a getter.)
  csfLeakPattern,
  intracranialHypertension,
  thunderclap;

  RedFlagSeverity get severity => switch (this) {
    HeadacheRedFlag.thunderclap => RedFlagSeverity.urgent,
    HeadacheRedFlag.csfLeakPattern => RedFlagSeverity.advisory,
    HeadacheRedFlag.intracranialHypertension => RedFlagSeverity.advisory,
  };
}

/// Pure function: given a saved HeadacheDetail and the symptom's
/// severity index (0=none through 4=unbearable, matching the existing
/// 5-point app severity scale), returns the list of red flags that
/// fire. List may be empty.
///
/// The severity threshold for the postural flags is `>= 3` (severe or
/// unbearable). A mild positional headache that improves quickly is
/// not by itself a red flag — the combination of severity + clear
/// postural pattern is what raises concern.
List<HeadacheRedFlag> detectHeadacheRedFlags({
  required HeadacheDetail detail,
  required int severityIndex,
}) {
  final flags = <HeadacheRedFlag>[];

  // Thunderclap is always urgent regardless of severity rating —
  // patient classification of onset is the trigger.
  if (detail.onset == HeadacheOnset.thunderclap) {
    flags.add(HeadacheRedFlag.thunderclap);
  }

  // Postural patterns require severe pain to fire as flags. A mild
  // positional headache is common in healthy people (e.g. dehydration)
  // and would flood the UI with low-value warnings.
  final isSevere = severityIndex >= 3;
  if (isSevere) {
    switch (detail.posturalPattern) {
      case HeadachePosturalPattern.worseUpright:
        flags.add(HeadacheRedFlag.csfLeakPattern);
        break;
      case HeadachePosturalPattern.worseRecumbent:
        flags.add(HeadacheRedFlag.intracranialHypertension);
        break;
      case HeadachePosturalPattern.noPosturalPattern:
      case null:
        break;
    }
  }

  return flags;
}
