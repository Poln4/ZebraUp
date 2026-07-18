// D.5 — Chest pain red flag detection
//
// Pure red-flag detection for chest_pain logs. Called by sintomas_tab
// after a chest_pain-typed SymptomEvent is saved with a non-null
// ChestPainDetail. Both URGENT (in-sheet emergency dialog, plus two
// post-save URGENT checks) and ADVISORY (post-save informational
// dialog) flags may be returned in the same list; the UI layer
// separates them by `.severity`.
//
// Clinical basis (DOIs):
//   - Gulati M et al. 2021 — AHA/ACC/ASE/CHEST/SAEM/SCCT/SCMR
//     Guideline for the Evaluation and Diagnosis of Chest Pain.
//     Circulation 2021;144:e368–e454. DOI: 10.1161/CIR.0000000000001029.
//     Grounds the compound anginal/exertional URGENT gates below.
//   - Isselbacher EM et al. 2022 — ACC/AHA Guideline for the Diagnosis
//     and Management of Aortic Disease. Circulation 2022.
//     DOI: 10.1161/CIR.0000000000001106. Covers vascular EDS (vEDS)
//     explicitly as a syndromic heritable thoracic aortic disease —
//     grounds isLikelyVEDSFromConditions below.
//
// V1 has 6 red-flag conditions (1 in-sheet urgent + 2 post-save urgent
// + 3 advisory) — deliberately more than any prior layer (C.4/D.1/D.2/
// D.3/D.4 each shipped with 5 or fewer), matching the "múltiples red
// flags esperadas" note in CLAUDE.md's backlog for D.5. Alarm-fatigue
// control is handled by chip taxonomy, not a history/quick-log system:
// the common benign costochondritis presentation (achingWorseWithPressing
// + worseWithPressingOnArea/worseWithBreathingOrMovement) never
// satisfies any gate below.

import '../models/chest_pain_detail.dart';
import '../models/red_flag_severity.dart';

/// Mirrors the vEDS substring match already used by
/// domainsForUserCondition in lib/services/condition_labels.dart:217-239
/// — same three keywords, same heuristic/free-text limitation
/// (Profile.conditions is not a validated diagnosis field; see
/// CLAUDE.md / Coussens 2022 on why it stays free-text). First reuse of
/// this pattern outside condition_labels.dart, confirmed with Paulina
/// before building — see symptom_detail_layers.md §15.
bool isLikelyVEDSFromConditions(List<String> conditions) {
  for (final raw in conditions) {
    final c = raw.toLowerCase();
    if (c.contains('veds') ||
        c.contains('vascular eds') ||
        c.contains('vascular ehlers')) {
      return true;
    }
  }
  return false;
}

/// Concrete red-flag patterns detectable from a ChestPainDetail plus
/// severity index. `urgent` either requires an in-sheet emergency
/// dialog before save (tearingOrRipping, mirrors abdominal's tearing
/// quality) or a post-save urgent dialog (possibleCardiacPatternUrgent,
/// exertionalPatternUrgent); `advisory` surfaces via post-save
/// informational dialog.
enum ChestPainRedFlag {
  tearingOrRipping,
  possibleCardiacPatternUrgent,
  exertionalPatternUrgent,
  pleuriticPatternAdvisory,
  palpitationsPatternAdvisory,
  refluxPatternAdvisory;

  RedFlagSeverity get severity {
    switch (this) {
      case ChestPainRedFlag.tearingOrRipping:
      case ChestPainRedFlag.possibleCardiacPatternUrgent:
      case ChestPainRedFlag.exertionalPatternUrgent:
        return RedFlagSeverity.urgent;
      case ChestPainRedFlag.pleuriticPatternAdvisory:
      case ChestPainRedFlag.palpitationsPatternAdvisory:
      case ChestPainRedFlag.refluxPatternAdvisory:
        return RedFlagSeverity.advisory;
    }
  }
}

/// Detect red flags from a ChestPainDetail plus the SymptomEvent
/// severity on the 0-4 SymptomSeverity scale.
///
/// Pure function — no side effects, no localization concerns. Mapping
/// to user-facing strings happens in sintomas_tab via ARB keys.
///
/// Design gates:
///   - Tearing/ripping: no severity gate. A user asserting this
///     character is trusted regardless of the numeric severity they
///     picked — mirrors abdominal's tearing-pain "trust the user's
///     assertion" design. Aortic dissection descriptor.
///   - Possible cardiac pattern: pressure/tightness quality + at least
///     one of radiates-to-arm/jaw/back, shortness of breath, or
///     sweating/clamminess + severity >= 2. AHA/ACC 2021 high-risk
///     anginal combination.
///   - Exertional pattern: worse-with-exertion trigger + at least one
///     of shortness of breath or palpitations + severity >= 2.
///   - Pleuritic pattern: sharp/stabbing quality + worse with
///     breathing/movement + severity >= 2. Advisory tier — usually
///     less urgent than the cardiac patterns above but still worth
///     medical mention (pericarditis, pneumothorax, PE differential).
///   - Palpitations pattern: palpitations/racing heart accompaniment +
///     severity >= 2. Independent of the exertional urgent gate — both
///     can legitimately fire together. Relevant given this population's
///     POTS/dysautonomia comorbidity.
///   - Reflux pattern: burning quality + after eating/lying down
///     trigger + severity >= 2. Lower-stakes GI differential, same
///     lower-severity-gate-justified-by-pattern-specificity precedent
///     as abdominal's gastroparesis advisory.
List<ChestPainRedFlag> detectChestPainRedFlags({
  required ChestPainDetail detail,
  required int severityIndex,
}) {
  final flags = <ChestPainRedFlag>[];

  if (detail.character == ChestPainCharacter.tearingOrRipping) {
    flags.add(ChestPainRedFlag.tearingOrRipping);
  }

  final hasCardiacAccompaniment =
      detail.accompaniments.contains(
        ChestPainAccompaniment.radiatesToArmJawBack,
      ) ||
      detail.accompaniments.contains(ChestPainAccompaniment.shortnessOfBreath) ||
      detail.accompaniments.contains(
        ChestPainAccompaniment.sweatingOrClamminess,
      );
  if (detail.character == ChestPainCharacter.pressureOrTightness &&
      hasCardiacAccompaniment &&
      severityIndex >= 2) {
    flags.add(ChestPainRedFlag.possibleCardiacPatternUrgent);
  }

  final hasExertionalAccompaniment =
      detail.accompaniments.contains(ChestPainAccompaniment.shortnessOfBreath) ||
      detail.accompaniments.contains(
        ChestPainAccompaniment.palpitationsOrRacingHeart,
      );
  if (detail.triggers.contains(ChestPainTrigger.worseWithExertion) &&
      hasExertionalAccompaniment &&
      severityIndex >= 2) {
    flags.add(ChestPainRedFlag.exertionalPatternUrgent);
  }

  if (detail.character == ChestPainCharacter.sharpOrStabbing &&
      detail.triggers.contains(ChestPainTrigger.worseWithBreathingOrMovement) &&
      severityIndex >= 2) {
    flags.add(ChestPainRedFlag.pleuriticPatternAdvisory);
  }

  if (detail.accompaniments.contains(
        ChestPainAccompaniment.palpitationsOrRacingHeart,
      ) &&
      severityIndex >= 2) {
    flags.add(ChestPainRedFlag.palpitationsPatternAdvisory);
  }

  if (detail.character == ChestPainCharacter.burning &&
      detail.triggers.contains(ChestPainTrigger.afterEatingOrLyingDown) &&
      severityIndex >= 2) {
    flags.add(ChestPainRedFlag.refluxPatternAdvisory);
  }

  return flags;
}
