// =============================================================================
// MoodQuadrantLocalization — locale-aware labels for mood quadrants.
//
// Same pattern as MentalStateLocalization / SymptomSeverityLocalization in
// clinical_localizations.dart: the model file keeps Spanish defaults
// (MoodQuadrantLabels.label / .teaserStates) as a UI-framework-free
// fallback, and this extension supplies the AppLocalizations-aware
// variants. Method names differ from the model-layer field names so the
// two extensions coexist on MoodQuadrant without conflict.
//
// Used by lib/widgets/mood_picker_sheet.dart for the step-1 quadrant
// cards and step-2 section headers.
// =============================================================================

import '../l10n/app_localizations.dart';
import '../models/models.dart';

extension MoodQuadrantLocalization on MoodQuadrant {
  /// Localized label, e.g. "activación · malestar" / "activation · unpleasant"
  /// / "活化 · 不適". Falls back to the Spanish default if a key is missing
  /// from the ARB.
  String quadrantLabel(AppLocalizations l10n) => switch (this) {
    MoodQuadrant.activatedUnpleasant => l10n.moodQuadrantActivatedUnpleasant,
    MoodQuadrant.activatedPleasant => l10n.moodQuadrantActivatedPleasant,
    MoodQuadrant.calmUnpleasant => l10n.moodQuadrantCalmUnpleasant,
    MoodQuadrant.calmPleasant => l10n.moodQuadrantCalmPleasant,
  };

  /// Localized teaser of representative emotions for the quadrant card.
  String quadrantTeaser(AppLocalizations l10n) => switch (this) {
    MoodQuadrant.activatedUnpleasant => l10n.moodTeaserActivatedUnpleasant,
    MoodQuadrant.activatedPleasant => l10n.moodTeaserActivatedPleasant,
    MoodQuadrant.calmUnpleasant => l10n.moodTeaserCalmUnpleasant,
    MoodQuadrant.calmPleasant => l10n.moodTeaserCalmPleasant,
  };
}
