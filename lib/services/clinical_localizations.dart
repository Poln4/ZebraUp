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