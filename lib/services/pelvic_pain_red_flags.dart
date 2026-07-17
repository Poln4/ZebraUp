// D.4 — Pelvic pain red flag detection
//
// Pure red-flag detection for pelvic_pain logs. Called by sintomas_tab
// after a pelvic_pain-typed SymptomEvent is saved with a non-null
// PelvicPainDetail. Both URGENT (in-sheet emergency dialog, plus two
// post-save URGENT checks) and ADVISORY (post-save informational
// dialog) flags may be returned in the same list; the UI layer
// separates them by `.severity`.
//
// Clinical basis: ACOG chronic pelvic pain guidance — sudden severe
// onset as an acute-abdomen/adnexal-torsion or ectopic-rupture
// concern; fever + pelvic pain as a pelvic inflammatory disease
// concern. Exact Practice Bulletin number/DOI to be verified before
// citing externally — see docs/design_decisions/symptom_detail_layers.md
// §14.
//
// V1 stays deliberately small (1 in-sheet urgent + 2 post-save urgent +
// 2 advisory) — same scope discipline as C.4/D.1/D.2/D.3.

import '../models/pelvic_pain_detail.dart';
import '../models/red_flag_severity.dart';

/// Concrete red-flag patterns detectable from a PelvicPainDetail plus
/// severity index and same-day fever status. `urgent` either requires
/// an in-sheet emergency dialog before save (suddenSevereOnset, mirrors
/// abdominal's tearing-pain pattern) or a post-save urgent dialog
/// (abnormalBleedingUrgent, feverUrgent); `advisory` surfaces via
/// post-save informational dialog.
enum PelvicPainRedFlag {
  suddenSevereOnset,
  abnormalBleedingUrgent,
  feverUrgent,
  bladderPatternAdvisory,
  pelvicFloorTensionAdvisory;

  RedFlagSeverity get severity {
    switch (this) {
      case PelvicPainRedFlag.suddenSevereOnset:
      case PelvicPainRedFlag.abnormalBleedingUrgent:
      case PelvicPainRedFlag.feverUrgent:
        return RedFlagSeverity.urgent;
      case PelvicPainRedFlag.bladderPatternAdvisory:
      case PelvicPainRedFlag.pelvicFloorTensionAdvisory:
        return RedFlagSeverity.advisory;
    }
  }
}

/// Detect red flags from a PelvicPainDetail plus the SymptomEvent
/// severity on the 0-4 SymptomSeverity scale and (optionally) whether
/// the profile logged a fever the same day.
///
/// Pure function — no side effects, no localization concerns. Mapping
/// to user-facing strings happens in sintomas_tab via ARB keys.
///
/// Design gates:
///   - Sudden severe onset: no severity gate. A user asserting this
///     character is trusted regardless of the numeric severity they
///     picked — mirrors abdominal's tearing-pain "trust the user's
///     assertion" design.
///   - Abnormal bleeding: compound gate (abnormal bleeding + severity
///     >= 3), mirrors abdominal's massiveHematochezia gate.
///   - Fever: gated lower than the bleeding flag (severity >= 2)
///     because the fever itself is the alarm signal (possible pelvic
///     inflammatory disease), not pain intensity.
///   - Bladder pattern: triggered by either the bladder-fullness
///     trigger or the urinary urgency/frequency accompaniment.
///   - Pelvic floor tension: grounds the existing zebra_wisdom.json
///     "Pelvic Floor & EDS"/"Pelvic Floor & Dysautonomia" facts into an
///     actual advisory.
List<PelvicPainRedFlag> detectPelvicPainRedFlags({
  required PelvicPainDetail detail,
  required int severityIndex,
  bool hasFeverToday = false,
}) {
  final flags = <PelvicPainRedFlag>[];

  if (detail.character == PelvicPainCharacter.suddenSevereOnset) {
    flags.add(PelvicPainRedFlag.suddenSevereOnset);
  }

  final hasAbnormalBleeding = detail.accompaniments.contains(
    PelvicPainAccompaniment.abnormalBleeding,
  );
  if (hasAbnormalBleeding && severityIndex >= 3) {
    flags.add(PelvicPainRedFlag.abnormalBleedingUrgent);
  }

  if (hasFeverToday && severityIndex >= 2) {
    flags.add(PelvicPainRedFlag.feverUrgent);
  }

  final hasBladderPattern =
      detail.triggers.contains(PelvicPainTrigger.withBladderFullness) ||
      detail.accompaniments.contains(
        PelvicPainAccompaniment.urinaryUrgencyFrequency,
      );
  if (hasBladderPattern) {
    flags.add(PelvicPainRedFlag.bladderPatternAdvisory);
  }

  if (detail.accompaniments.contains(
    PelvicPainAccompaniment.pelvicFloorTension,
  )) {
    flags.add(PelvicPainRedFlag.pelvicFloorTensionAdvisory);
  }

  return flags;
}
