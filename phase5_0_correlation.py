#!/usr/bin/env python3
"""
ZebraUp — Phase 5.0 patch: lib/services/correlation_engine.dart (new file)
=========================================================================

Creates the scaffold for the correlation engine — sibling to
interaction_engine.dart. Defines the rule interface and an empty registry.
Concrete correlations land in phase 5.4 and 5.9.

Run from the repo root.
Idempotent: refuses to overwrite an existing file.
"""

import sys
from pathlib import Path

TARGET = Path("lib/services/correlation_engine.dart")

CONTENT = """// =============================================================================
// Correlation engine — within-person pattern detection (Phase 5.0 scaffold).
//
// Sibling to interaction_engine.dart. Where the interaction engine surfaces
// known clinical interactions from a rules table, this engine surfaces
// statistical patterns in the *user's own data* using rolling time windows.
//
// Design principles (PHASE_5_ROADMAP.md, sections 5.0 / 5.4 / 5.9):
//   - Within-person only. We never compare a user against population norms.
//   - Cold-start gated. Every rule declares a `minimumEvents` threshold and
//     a `windowDays` width. Below the threshold, the rule returns
//     `CorrelationConfidence.insufficientData`.
//   - Correlation, not causation. The UI layer is responsible for surfacing
//     `humanSummary` with neutral framing — this engine reports the math.
//   - Opt-in by default (5.10 trauma-informed lens). The engine returns
//     results; the UI decides whether to show them based on per-rule toggles.
//
// 5.0 ships the scaffold only. Concrete rules arrive in 5.4 (v1) and 5.9 (v2).
// =============================================================================

import '../models/models.dart';

enum CorrelationConfidence {
  /// Not enough data yet to evaluate this rule. UI should show a
  /// "necesito más datos para comparar" placeholder.
  insufficientData,

  /// Pattern is present but weak — surface only if the user opted in for
  /// exploratory insights.
  weak,

  /// Pattern is consistent across the window.
  moderate,

  /// Pattern is strong and stable across the window.
  strong,
}

/// The output of evaluating a [CorrelationRule] against a [Profile].
class CorrelationResult {
  final String ruleId;
  final CorrelationConfidence confidence;

  /// Number of events that participated in the computation.
  final int sampleSize;

  /// Window the rule looked at, expressed in days.
  final int windowDays;

  /// Raw figures for the UI layer to format. Schema is rule-specific; the
  /// UI cards in clinica_tab.dart know how to read each rule's payload.
  final Map<String, dynamic> data;

  final DateTime computedAt;

  const CorrelationResult({
    required this.ruleId,
    required this.confidence,
    required this.sampleSize,
    required this.windowDays,
    required this.data,
    required this.computedAt,
  });

  factory CorrelationResult.insufficient({
    required String ruleId,
    required int windowDays,
    required int sampleSize,
    DateTime? computedAt,
  }) =>
      CorrelationResult(
        ruleId: ruleId,
        confidence: CorrelationConfidence.insufficientData,
        sampleSize: sampleSize,
        windowDays: windowDays,
        data: const {},
        computedAt: computedAt ?? DateTime.now(),
      );

  bool get hasEnoughData =>
      confidence != CorrelationConfidence.insufficientData;
}

/// Signature for the evaluator function on a [CorrelationRule]. Implementations
/// are pure: they read the profile and return a result without side effects.
typedef CorrelationEvaluator = CorrelationResult Function(
  Profile profile,
  DateTime now,
);

/// A single correlation pattern the engine can evaluate.
///
/// Concrete instances live in `kCorrelationRules` and are added across
/// phases 5.4 and 5.9. This mirrors the interaction_engine pattern — a
/// const-friendly data class with the evaluator as a function pointer.
class CorrelationRule {
  /// Stable identifier used for UI keys, settings toggles, and analytics.
  /// Convention: lowercase snake_case, e.g. 'hemorrhoidal_x_fatigue'.
  final String id;

  /// Short identifier shown only in dev tooling — not user-facing.
  final String debugLabel;

  /// Window the rule looks back over.
  final int windowDays;

  /// Minimum number of qualifying events inside the window before the rule
  /// returns anything other than `insufficientData`.
  final int minimumEvents;

  /// The actual computation. Should be deterministic given (profile, now)
  /// and free of UI / locale concerns.
  final CorrelationEvaluator evaluate;

  const CorrelationRule({
    required this.id,
    required this.debugLabel,
    required this.windowDays,
    required this.minimumEvents,
    required this.evaluate,
  });
}

/// Registry of all correlation rules. Empty in 5.0 by design — phase 5.4
/// populates the first three (hemorrhoidal x fatigue, sleep x pain next day,
/// hydration x bowel pattern) and phase 5.9 adds the HRV / boom-bust / SAI /
/// DOW family. UI surfaces walk this list to render insight cards.
final List<CorrelationRule> kCorrelationRules = <CorrelationRule>[];

/// Convenience: evaluate every registered rule and return one result per rule.
///
/// `now` is parameterized so tests can pin time. UI callers pass DateTime.now().
List<CorrelationResult> runAllCorrelations(
  Profile profile, {
  DateTime? now,
}) {
  final t = now ?? DateTime.now();
  return [
    for (final rule in kCorrelationRules) rule.evaluate(profile, t),
  ];
}
"""


def main():
    if TARGET.exists():
        print(f"SKIP: {TARGET} already exists. Refusing to overwrite.")
        return
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    TARGET.write_text(CONTENT, encoding="utf-8")
    print(f"OK: created {TARGET}")
    print(f"  - Scaffolded CorrelationResult, CorrelationRule, kCorrelationRules")
    print(f"  - Empty registry — concrete rules land in 5.4 and 5.9")


if __name__ == "__main__":
    main()