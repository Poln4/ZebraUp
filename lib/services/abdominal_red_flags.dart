// D.2 — Abdominal red flag detection
//
// Pure red-flag detection for abdominal logs. Called by sintomas_tab
// after an abdominal_pain-typed SymptomEvent is saved with a non-null
// AbdominalDetail. Both URGENT (in-sheet emergency dialog) and
// ADVISORY (post-save informational dialog) flags may be returned in
// the same list; the UI layer separates them by `.severity`.
//
// Clinical basis (DOIs):
//   - Palsson OS 2016 — Rome IV alarm criteria.
//     DOI: 10.1053/j.gastro.2016.02.014
//   - Nelson AD 2015 — Mayo Clinic gastroparesis 25% in EDS cohorts.
//     DOI: 10.1111/nmo.12665
//   - Zeitoun JD 2013 — GI symptom prevalence 84% in EDS.
//     DOI: 10.1371/journal.pone.0080321

import '../models/abdominal_detail.dart';

/// Severity classification. `urgent` requires an in-sheet emergency
/// dialog before save (cefalea thunderclap pattern); `advisory`
/// surfaces via post-save informational dialog.
enum AbdominalRedFlagSeverity {
  advisory,
  urgent,
}

/// Concrete red-flag patterns detectable from an AbdominalDetail plus
/// severity index and (optionally) the SymptomEvent.note text.
enum AbdominalRedFlag {
  tearingPainSedv,
  massiveHematochezia,
  hematemesis,
  nocturnalPainAdvisory,
  gastroparesisPatternAdvisory;

  AbdominalRedFlagSeverity get severity {
    switch (this) {
      case AbdominalRedFlag.tearingPainSedv:
      case AbdominalRedFlag.massiveHematochezia:
      case AbdominalRedFlag.hematemesis:
        return AbdominalRedFlagSeverity.urgent;
      case AbdominalRedFlag.nocturnalPainAdvisory:
      case AbdominalRedFlag.gastroparesisPatternAdvisory:
        return AbdominalRedFlagSeverity.advisory;
    }
  }
}

/// Detect red flags from an AbdominalDetail plus the SymptomEvent
/// severity on the 0-4 SymptomSeverity scale and (optionally) the
/// free-text note.
///
/// Pure function — no side effects, no localization concerns.
/// Mapping to user-facing strings happens in sintomas_tab via ARB keys.
///
/// Design gates:
///   - Tearing pain: no severity gate. User asserting tearing quality
///     is trusted regardless of numeric severity — patients may
///     understate emergencies.
///   - Massive hematochezia: compound gate (blood + nausea/vomiting
///     + severity >= 3). Isolated hemorrhoidal bleeding does not fire.
///   - Hematemesis: any occurrence via note keyword match.
///   - Nocturnal pain: severity >= 3.
///   - Gastroparesis pattern: severity >= 2 (lower threshold; the
///     pattern itself is more specific than severity alone).
List<AbdominalRedFlag> detectAbdominalRedFlags({
  required AbdominalDetail detail,
  required int severityIndex,
  String? noteText,
}) {
  final flags = <AbdominalRedFlag>[];

  // ---- URGENT: tearing pain (SEDv-adjacent presentation) ----
  // No severity gate — a user asserting tearing quality is trusted
  // regardless of the numeric severity they picked. Patients often
  // understate in-progress emergencies.
  if (detail.quality == AbdominalQuality.tearing) {
    flags.add(AbdominalRedFlag.tearingPainSedv);
  }

  // ---- URGENT: massive hematochezia ----
  // Compound gate: bleeding + GI distress + high severity. Isolated
  // hemorrhoidal bleeding (bloody_stool alone, no other symptoms) does
  // not fire; that stays in advisory territory or user judgement.
  final hasBlood = detail.accompaniments
      .contains(AbdominalAccompaniment.bloodyStool);
  final hasNausea = detail.accompaniments
      .contains(AbdominalAccompaniment.nausea);
  final hasVomiting = detail.accompaniments
      .contains(AbdominalAccompaniment.vomiting);
  if (hasBlood && (hasNausea || hasVomiting) && severityIndex >= 3) {
    flags.add(AbdominalRedFlag.massiveHematochezia);
  }

  // ---- URGENT: hematemesis (via note keyword match) ----
  // No chip exists for this — per Gemini/UX rationale, seeing a
  // "vómito con sangre" chip daily would be traumatizing for chronic
  // users. Instead, if the user writes about it in the note, we
  // surface an emergency prompt.
  if (noteText != null && _containsHematemesisKeyword(noteText)) {
    flags.add(AbdominalRedFlag.hematemesis);
  }

  // ---- ADVISORY: nocturnal pain (Rome IV alarm criterion) ----
  if (detail.timing == AbdominalTiming.nocturnal && severityIndex >= 3) {
    flags.add(AbdominalRedFlag.nocturnalPainAdvisory);
  }

  // ---- ADVISORY: gastroparesis pattern ----
  // Postprandial immediate + early satiety + at least moderate
  // severity. The pattern itself is specific enough that we use a
  // lower severity gate than for advisories driven by severity alone.
  if (detail.timing == AbdominalTiming.postprandialImmediate &&
      detail.accompaniments
          .contains(AbdominalAccompaniment.earlySatiety) &&
      severityIndex >= 2) {
    flags.add(AbdominalRedFlag.gastroparesisPatternAdvisory);
  }

  return flags;
}

/// Hematemesis keyword set spanning es / en / zh. Lowercased at match
/// time (Chinese is unaffected by case). List is deliberate — false
/// negatives (a user phrasing something we didn't anticipate) are
/// preferable to false positives (a user typing "sin sangre en el
/// vómito" firing an emergency dialog). Refine as beta feedback
/// arrives.
const _hematemesisKeywords = <String>[
  // Spanish
  'vómito con sangre',
  'vomité sangre',
  'vomitar sangre',
  'sangre en el vómito',
  'sangre en vómito',
  'hematemesis',
  'devolví sangre',
  'vomité con sangre',
  // English
  'vomited blood',
  'blood in vomit',
  'vomiting blood',
  'bloody vomit',
  'threw up blood',
  // Traditional Chinese
  '嘔血',
  '吐血',
];

bool _containsHematemesisKeyword(String text) {
  final lower = text.toLowerCase();
  for (final kw in _hematemesisKeywords) {
    if (lower.contains(kw.toLowerCase())) return true;
  }
  return false;
}
