// =============================================================================
// Clinical Localizations — cross-cutting enum extensions
//
// Phase B (22-jun-2026): canonical localization extensions for the two
// "transversal" clinical enums that surface in the report builder and
// (potentially) in other reporting/display surfaces.
//
// Naming convention: each extension method is prefixed with the enum
// noun (mentalStateLabel, severityLabel) to AVOID collision with the
// existing `label` field on each enum. Those fields stay in place as
// the Spanish-only fallback used by older code paths that haven't been
// migrated yet — same pattern as `defaultLabel` on FeverSite,
// SleepQuality, HydrationBeverage, etc.
//
// To migrate a call site:
//   OLD:  state.label              // hardcoded spanish
//   NEW:  state.mentalStateLabel(l10n)
//
//   OLD:  severity.label           // hardcoded spanish
//   NEW:  severity.severityLabel(l10n)
//
// Where to put new transversal enums: extend this file. Enum-specific
// labels for enums only used in a single widget (e.g. SleepQuality) stay
// co-located with that widget — see lib/widgets/sleep_form_sheet.dart
// for the canonical example of that pattern.
// =============================================================================

import '../models/models.dart';
import '../l10n/app_localizations.dart';

extension MentalStateLocalization on MentalState {
  /// Locale-aware display label. Use this everywhere — `label` (field)
  /// remains as a Spanish fallback only for legacy call sites.
  String mentalStateLabel(AppLocalizations l10n) => switch (this) {
    MentalState.mood => l10n.mentalStateMood,
    MentalState.anxiety => l10n.mentalStateAnxiety,
    MentalState.brainFog => l10n.mentalStateBrainFog,
    MentalState.dissociation => l10n.mentalStateDissociation,
    MentalState.irritability => l10n.mentalStateIrritability,
    MentalState.emotionalEnergy => l10n.mentalStateEmotionalEnergy,
  };
}

extension SymptomSeverityLocalization on SymptomSeverity {
  /// Locale-aware display label. Use this in user-visible surfaces;
  /// `label` (field) remains as a Spanish fallback.
  String severityLabel(AppLocalizations l10n) => switch (this) {
    SymptomSeverity.none => l10n.severityNone,
    SymptomSeverity.mild => l10n.severityMild,
    SymptomSeverity.moderate => l10n.severityModerate,
    SymptomSeverity.intense => l10n.severityIntense,
    SymptomSeverity.unbearable => l10n.severityUnbearable,
  };
}

/// F5 — Locale-aware functional anchor for SymptomSeverity.
///
/// Returns a short patient-facing string describing what each severity
/// level means functionally (e.g. "me obliga a bajar el ritmo o pausar"
/// for moderate). The strings are universal across symptoms — they do
/// not vary by symptom family.
///
/// Method name `severityFunctionalAnchor` is deliberately distinct from
/// the existing `severityLabel` extension so both coexist on the
/// SymptomSeverity enum without conflict.
extension SymptomSeverityFunctionalAnchor on SymptomSeverity {
  String severityFunctionalAnchor(AppLocalizations l10n) => switch (this) {
    SymptomSeverity.none => l10n.severityFunctionalAnchorNone,
    SymptomSeverity.mild => l10n.severityFunctionalAnchorMild,
    SymptomSeverity.moderate => l10n.severityFunctionalAnchorModerate,
    SymptomSeverity.intense => l10n.severityFunctionalAnchorIntense,
    SymptomSeverity.unbearable => l10n.severityFunctionalAnchorUnbearable,
  };
}

/// i18n Batch A.1 — Locale-aware label for OutcomeReason.
///
/// The enum's `.label` field (Spanish) stays as a fallback used by any
/// older code paths that haven't migrated to passing AppLocalizations.
extension OutcomeReasonLocalization on OutcomeReason {
  String outcomeReasonLabel(AppLocalizations l10n) => switch (this) {
    OutcomeReason.natural => l10n.outcomeReasonNatural,
    OutcomeReason.medicationHelped => l10n.outcomeReasonMedicationHelped,
    OutcomeReason.otherTrigger => l10n.outcomeReasonOtherTrigger,
    OutcomeReason.additionalMed => l10n.outcomeReasonAdditionalMed,
    OutcomeReason.unsure => l10n.outcomeReasonUnsure,
  };
}

/// i18n Batch A.1 — Locale-aware label for BowelBucket.
///
/// Same fallback pattern as OutcomeReasonLocalization above.
extension BowelBucketLocalization on BowelBucket {
  String bowelBucketLabel(AppLocalizations l10n) => switch (this) {
    BowelBucket.constipation => l10n.bowelBucketConstipation,
    BowelBucket.normal => l10n.bowelBucketNormal,
    BowelBucket.diarrhea => l10n.bowelBucketDiarrhea,
  };
}

/// i18n Batch A.1 — Locale-aware coarse-label for MedicationOutcome.
///
/// Method name is `medicationOutcomeCoarseLabel`, NOT `coarseLabel`,
/// because Dart does not allow an extension method to share its name
/// with an existing class member (the original getter `coarseLabel`
/// on MedicationOutcome stays intact as a Spanish fallback).
extension MedicationOutcomeLocalization on MedicationOutcome {
  String medicationOutcomeCoarseLabel(AppLocalizations l10n) {
    final d = delta;
    if (d == null) return l10n.medicationOutcomeCoarsePending;
    if (d <= -2) return l10n.medicationOutcomeCoarseMuchBetter;
    if (d == -1) return l10n.medicationOutcomeCoarseBetter;
    if (d == 0) return l10n.medicationOutcomeCoarseSame;
    if (d == 1) return l10n.medicationOutcomeCoarseWorse;
    return l10n.medicationOutcomeCoarseMuchWorse;
  }
}
