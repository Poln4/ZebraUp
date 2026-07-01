// D.1 — Fatigue red flag detection
//
// Pure red-flag detection for fatigue logs. Called by sintomas_tab
// after a fatigue-typed SymptomEvent is saved with a non-null
// FatigueDetail. All flags returned here are ADVISORY (non-blocking,
// informative). Fatigue has no URGENT patterns at this stage.
//
// Clinical basis (DOIs):
//   - Clayton EW. IOM 2015 ME/CFS criteria (SEID). PEM as central
//     diagnostic criterion.
//     DOI: 10.1001/jama.2015.1346
//   - Mateo LJ et al. 2020 (PEM 24-72h delayed onset window; 51%
//     unresolved at day 7).
//     DOI: 10.3233/wor-203168
//   - Jason LA et al. 2010 (MFTQ 5 clinically distinguishable fatigue
//     types; "wired" separable from other categories).
//     DOI: 10.1080/08964280903521370
//   - De Wandele I et al. 2016 (orthostatic intolerance in 74.4% of
//     EDS-HT; positive tilt increases NRS fatigue +3.1 vs +0.5).
//     DOI: 10.1093/rheumatology/kew032

import '../models/fatigue_detail.dart';

/// Severity classification for a fatigue red flag. All current fatigue
/// flags return `advisory`; `urgent` is reserved for future patterns
/// that might warrant immediate action (currently none identified).
enum FatigueRedFlagSeverity {
  advisory,
  urgent,
}

/// Concrete red-flag patterns detectable from a FatigueDetail plus the
/// severity index of the underlying SymptomEvent.
enum FatigueRedFlag {
  pemPattern,
  orthostaticPattern,
  hpaPattern;

  /// Classification for gating UI presentation. Advisories go through
  /// a non-blocking informational dialog; urgents (none today) would
  /// receive stronger UI treatment.
  FatigueRedFlagSeverity get severity {
    switch (this) {
      case FatigueRedFlag.pemPattern:
      case FatigueRedFlag.orthostaticPattern:
      case FatigueRedFlag.hpaPattern:
        return FatigueRedFlagSeverity.advisory;
    }
  }
}

/// Detect red flags from a FatigueDetail plus the SymptomEvent severity
/// on the 0-4 SymptomSeverity scale. Pure function — no side effects,
/// no localization concerns (mapping to user-facing strings happens in
/// sintomas_tab via ARB keys).
///
/// Design rule: red flags only surface at severity ≥ 3 (intense or
/// unbearable). A mild PEM pattern in an otherwise-good day is not
/// clinically actionable and would create alert fatigue.
List<FatigueRedFlag> detectFatigueRedFlags({
  required FatigueDetail detail,
  required int severityIndex,
}) {
  final flags = <FatigueRedFlag>[];

  // Do not surface any red flag when the severity is below intense.
  // Mild patterns are captured but not alerted; the data is available
  // in reports for retrospective review.
  if (severityIndex < 3) return flags;

  final type = detail.type;
  if (type == null) return flags;

  switch (type) {
    case FatigueType.postExertional:
      flags.add(FatigueRedFlag.pemPattern);
      break;
    case FatigueType.orthostatic:
      flags.add(FatigueRedFlag.orthostaticPattern);
      break;
    case FatigueType.hpaWired:
      flags.add(FatigueRedFlag.hpaPattern);
      break;
    case FatigueType.cognitiveDrain:
    case FatigueType.muscleUnresponsive:
      // No red flag associated with these two types; they are
      // informative on their own and do not warrant a specific
      // advisory beyond the log itself.
      break;
  }

  return flags;
}
