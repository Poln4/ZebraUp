// D.3 — Presyncope red flag detection
//
// Pure red-flag detection for presyncope logs. Called by sintomas_tab
// after a presyncope-typed SymptomEvent is saved with a non-null
// PresyncopeDetail. Both URGENT (in-sheet emergency dialog) and
// ADVISORY (post-save informational dialog) flags may be returned in
// the same list; the UI layer separates them by `.severity`.
//
// Clinical basis (DOI):
//   - Brignole M et al. 2018 — ESC Guidelines for the diagnosis and
//     management of syncope (high-risk features: exertional trigger,
//     no position-change trigger, actual loss of consciousness).
//     DOI: 10.1093/eurheartj/ehy037
//
// V1 stays deliberately small (1 urgent + 2 advisory) — frequency/
// recurrence-based rules and prodrome-combination rules are V2
// candidates once beta data exists, same scope discipline as
// C.4/D.1/D.2.

import '../models/presyncope_detail.dart';
import '../models/red_flag_severity.dart';

/// Concrete red-flag patterns detectable from a PresyncopeDetail plus
/// severity index. `urgent` requires an in-sheet emergency dialog
/// before save (mirrors the abdominal tearing-pain pattern); `advisory`
/// surfaces via post-save informational dialog.
enum PresyncopeRedFlag {
  briefLossOfConsciousness,
  exertionalTrigger,
  noPositionChangeTrigger;

  RedFlagSeverity get severity {
    switch (this) {
      case PresyncopeRedFlag.briefLossOfConsciousness:
        return RedFlagSeverity.urgent;
      case PresyncopeRedFlag.exertionalTrigger:
      case PresyncopeRedFlag.noPositionChangeTrigger:
        return RedFlagSeverity.advisory;
    }
  }
}

/// Detect red flags from a PresyncopeDetail plus the SymptomEvent
/// severity on the 0-4 SymptomSeverity scale.
///
/// Pure function — no side effects, no localization concerns. Mapping
/// to user-facing strings happens in sintomas_tab via ARB keys.
///
/// Design gates:
///   - Brief loss of consciousness: no severity gate. The outcome
///     itself (any loss of consciousness, however brief) is the
///     trigger — mirrors abdominal's tearing-pain "trust the user's
///     assertion" design.
///   - Exertional trigger: mechanism == postExertion, no severity gate.
///   - No-position-change trigger: mechanism == noPositionChange, no
///     severity gate — this is the ESC 2018 feature least consistent
///     with a purely orthostatic origin.
List<PresyncopeRedFlag> detectPresyncopeRedFlags({
  required PresyncopeDetail detail,
  required int severityIndex,
}) {
  final flags = <PresyncopeRedFlag>[];

  if (detail.outcome == PresyncopeOutcome.briefLossOfConsciousness) {
    flags.add(PresyncopeRedFlag.briefLossOfConsciousness);
  }

  if (detail.mechanism == PresyncopeMechanism.postExertion) {
    flags.add(PresyncopeRedFlag.exertionalTrigger);
  }

  if (detail.mechanism == PresyncopeMechanism.noPositionChange) {
    flags.add(PresyncopeRedFlag.noPositionChangeTrigger);
  }

  return flags;
}
