// Sprint G.A — Flare detection service.
//
// Pure heuristic detection of "should we suggest flare mode?" over a
// Profile. Consumed by G.E's suggestion banner in Hoy. This file has
// no UI, no state mutation, no side effects — it reads history lists
// and returns a decision.
//
// Three rules evaluated in parallel; any triggers the suggestion:
//
//   • Rule 1 — Severe symptom accumulation. 3+ SymptomEvents with
//     severity.value >= 3 in the last 24 hours. Threshold chosen to
//     avoid false positives from a single bad day; requires a real
//     cluster of intense events.
//
//   • Rule 2 — Recent MCAS red flag. Any SymptomEvent with
//     mcasDetail.hasRedFlag == true in the last 6 hours. A single
//     anaphylaxis-adjacent event is enough. Weiler CR et al. 2019
//     AAAAI consensus supports treating recent red flag markers as
//     high-signal regardless of surrounding context.
//
//   • Rule 3 — PEM pattern. ActionKind.movement 24-72h ago +
//     fatigue-labeled SymptomEvent with severity >= 3 in the last
//     24h. Delayed onset window per Mateo LJ et al. 2020 and
//     Jason LA et al. 2010. Requires BOTH the trigger (movement)
//     and the consequence (severe fatigue) to fire — reduces false
//     positives from unrelated fatigue.
//
// Future extensions (documented for the next iteration):
//   • Rule 4 — Multi-day pacing violation (3+ days with no pacing
//     day marked when severity load is above baseline)
//   • Rule 5 — Sleep debt cluster (avg sleep < 5h for 3+ nights)
//   • Weight rules by strength; require aggregate score >= threshold
//     rather than any-single-rule trigger.

import '../models/models.dart';
import '../models/action_taken.dart';
import '../models/mcas.dart';

// ============================================================
// Result shape
// ============================================================

enum FlareRule {
  severeSymptomAccumulation('severe_symptom_accumulation'),
  mcasRedFlagRecent('mcas_red_flag_recent'),
  pemPattern('pem_pattern');

  const FlareRule(this.serializationKey);
  final String serializationKey;
}

class FlareDetectionResult {
  /// True when at least one rule triggered. Convenience for callers
  /// that don't need to inspect individual rules.
  final bool suggested;

  /// The specific rules that triggered. Empty when suggested == false.
  /// Order matches the internal evaluation order but has no semantic
  /// meaning — callers should treat this as a set-like collection.
  final List<FlareRule> triggeredRules;

  /// When the detection ran. Useful for banner display ("evaluado
  /// hace X minutos") and for suppressing re-fires within a cooldown.
  final DateTime evaluatedAt;

  const FlareDetectionResult({
    required this.suggested,
    required this.triggeredRules,
    required this.evaluatedAt,
  });

  /// Convenience: no rules triggered — nothing to suggest.
  bool get isEmpty => triggeredRules.isEmpty;
}

// ============================================================
// Public entry point
// ============================================================

/// Evaluates all flare rules over the profile and returns whether
/// flare mode should be suggested.
///
/// [now] defaults to DateTime.now(); pass explicitly for testability
/// or for evaluation at a specific reference moment.
FlareDetectionResult detectFlarePattern(Profile profile, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final triggered = <FlareRule>[];

  if (_detectSevereSymptomAccumulation(profile, ref)) {
    triggered.add(FlareRule.severeSymptomAccumulation);
  }
  if (_detectRecentMCASRedFlag(profile, ref)) {
    triggered.add(FlareRule.mcasRedFlagRecent);
  }
  if (_detectPEMPattern(profile, ref)) {
    triggered.add(FlareRule.pemPattern);
  }

  return FlareDetectionResult(
    suggested: triggered.isNotEmpty,
    triggeredRules: triggered,
    evaluatedAt: ref,
  );
}

// ============================================================
// Rule 1 — Severe symptom accumulation
// ============================================================

/// 3+ SymptomEvents with severity.value >= 3 in the last 24 hours.
bool _detectSevereSymptomAccumulation(Profile profile, DateTime ref) {
  final since = ref.subtract(const Duration(hours: 24));
  var count = 0;
  for (final s in profile.symptomHistory) {
    if (s.timestamp.isBefore(since)) continue;
    if (s.timestamp.isAfter(ref)) continue;
    if (s.severity.value >= 3) {
      count++;
      if (count >= 3) return true;
    }
  }
  return false;
}

// ============================================================
// Rule 2 — Recent MCAS red flag
// ============================================================

/// Any SymptomEvent in the last 6 hours has mcasDetail.hasRedFlag.
bool _detectRecentMCASRedFlag(Profile profile, DateTime ref) {
  final since = ref.subtract(const Duration(hours: 6));
  for (final s in profile.symptomHistory) {
    if (s.timestamp.isBefore(since)) continue;
    if (s.timestamp.isAfter(ref)) continue;
    final detail = s.mcasDetail;
    if (detail != null && detail.hasRedFlag) {
      return true;
    }
  }
  return false;
}

// ============================================================
// Rule 3 — PEM pattern
// ============================================================

/// ActionKind.movement 24-72h ago AND fatigue SymptomEvent with
/// severity >= 3 in the last 24h. Both conditions must hold.
bool _detectPEMPattern(Profile profile, DateTime ref) {
  final windowStart = ref.subtract(const Duration(hours: 72));
  final windowEnd = ref.subtract(const Duration(hours: 24));

  // Movement 24-72h ago
  var movementFound = false;
  for (final a in profile.actionsHistory) {
    if (a.timestamp.isBefore(windowStart)) continue;
    if (a.timestamp.isAfter(windowEnd)) continue;
    if (a.kind == ActionKind.movement) {
      movementFound = true;
      break;
    }
  }
  if (!movementFound) return false;

  // Severe fatigue in the last 24h
  for (final s in profile.symptomHistory) {
    if (s.timestamp.isBefore(windowEnd)) continue;
    if (s.timestamp.isAfter(ref)) continue;
    if (s.severity.value < 3) continue;
    if (_isFatigueSymptom(s.name)) return true;
  }
  return false;
}

// ============================================================
// Fatigue keyword heuristic
// ============================================================

/// Keyword match for fatigue-related symptom names. Temporary
/// approach — future migration to symptom_definitions_service with
/// a curated `fatigue` alias list. Same pattern as _isMCASSymptom
/// in sintomas_tab.dart.
bool _isFatigueSymptom(String name) {
  final lower = name.toLowerCase();
  const keywords = [
    'fatiga',
    'cansancio',
    'agotamiento',
    'malestar general',
    'extenuación',
    'extenuacion',
    'agotada',
    'agotado',
  ];
  return keywords.any((k) => lower.contains(k));
}
