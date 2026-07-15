// Combined zone+kind entry flow (18-jul-2026 rework, §12 follow-up).
//
// Free-text detector for the symptom vault ("el baúl"): given whatever
// the patient typed (e.g. "dolor muscular", "dolor pierna", "dolor
// muscular en la rodilla"), figures out which of zone/kind is already
// implied so the combined structural sheet only has to ask for the
// piece that's missing.
//
// Deliberately NOT built on SymptomDefinitionsService.detectAliasVariant
// (hard-gated to symptomKey == 'abdominal_pain', matches Dart const
// lists, not generalized) and NOT sourced from
// assets/symptom_definitions.json (zone/kind display labels already
// live in ARB via the extensions in structural_taxonomy.dart — a
// second source of truth for the same labels would be confusing).
// Same pattern as the existing _isMCASSymptom keyword list in
// sintomas_tab.dart: hard-coded LatAm-neutral Spanish keywords, no
// voseo.
//
// Callers MUST check the existing headache/fatigue/abdominal_pain/MCAS
// gates first (see _dispatchSymptomInput in sintomas_tab.dart) — this
// detector has no awareness of those and will happily match unrelated
// text if given the chance out of order.

import '../models/models.dart';

class StructuralTextMatch {
  final String? zone;
  final StructuralEventKind? kind;

  /// True when the text names a body region too broad to resolve to a
  /// single zone ID (e.g. "pierna" spans front_thigh/back_thigh/knees/
  /// calf/ankles/feet) but is still clearly a structural-pain mention.
  /// Only set when [zone] is null. Exists so [isEmpty] correctly stays
  /// false for this case — without it, "dolor pierna" alone would match
  /// neither a specific zone nor a kind and silently fall through to
  /// the generic severity menu instead of opening the combined sheet's
  /// zone-pick step, which is the whole point of this example.
  final bool hasAmbiguousZoneSignal;

  const StructuralTextMatch({
    this.zone,
    this.kind,
    this.hasAmbiguousZoneSignal = false,
  });

  bool get isEmpty => zone == null && kind == null && !hasAmbiguousZoneSignal;
}

/// Broad body-region words that don't map to one specific zone ID but
/// should still be recognized as "this is about structural pain" —
/// see [StructuralTextMatch.hasAmbiguousZoneSignal].
const List<String> _ambiguousZoneSignalWords = ['pierna', 'piernas', 'espalda'];

/// Zone keyword table. Deliberately excludes `chest`/`side`/`ribs`/
/// `abdomen` (overlap with GI vocabulary already gated to
/// 'abdominal_pain' — guata/panza/barriga/estómago — and with
/// "dolor de pecho", which has no dedicated flow; auto-routing those
/// into a musculoskeletal sheet would be misleading) and `temple`
/// (overlaps with tension-headache language). All 5 stay reachable via
/// manual zone-chip tap or the sheet's own zone-pick step.
///
/// Bare "pierna" and "espalda" are intentionally absent — each is
/// ambiguous across 5-6 real zones. Not matching either is the correct
/// outcome: it leaves `zone: null`, which routes the combined sheet to
/// ask the zone explicitly ("preguntar solo lo que falta"). See
/// `_ambiguousZoneSignalWords` for how these still trigger the sheet
/// despite not resolving a specific zone.
const Map<String, List<String>> _zoneKeywords = {
  'cervical': ['cervical', 'cervicales', 'cuello', 'nuca'],
  'jaw': ['mandíbula', 'mandibula', 'quijada'],
  'shoulders': ['hombro', 'hombros'],
  'shoulder_blades': [
    'omóplato',
    'omoplato',
    'escápula',
    'escapula',
    'paletilla',
  ],
  'upper_back': ['espalda alta', 'espalda superior'],
  // 'forearm' before 'upper_arm' matters only for readability here —
  // matching itself uses longest-match-wins, not list order, so
  // "antebrazo" resolves correctly even though it contains "brazo".
  'forearm': ['antebrazo'],
  'upper_arm': ['brazo', 'bíceps', 'biceps', 'tríceps', 'triceps'],
  'elbow': ['codo'],
  'wrists': ['muñeca', 'muñecas', 'muneca', 'munecas'],
  'hands': ['mano', 'manos', 'dedo', 'dedos'],
  'lumbar_pelvis': ['lumbar', 'espalda baja', 'zona lumbar'],
  'hips': ['cadera', 'caderas'],
  'glutes': ['glúteo', 'gluteo', 'glúteos', 'gluteos'],
  'front_thigh': ['muslo', 'cuádriceps', 'cuadriceps'],
  'back_thigh': ['isquiotibial'],
  'knees': ['rodilla', 'rodillas'],
  'calf': ['pantorrilla', 'pantorrillas', 'gemelo', 'gemelos'],
  'ankles': ['tobillo', 'tobillos'],
  'feet': ['pie', 'pies'],
};

/// Kind keyword table. `painWithoutClearCause` deliberately has no
/// keywords — it's the explicit "I don't know" bucket, never
/// auto-detected from free text, only ever chosen in the sheet's
/// kind-pick step.
///
/// softTissue deliberately excludes "moretón"/"hematoma" — those are
/// already caught by _isMCASSymptom's keyword list in sintomas_tab.dart,
/// and MCAS is checked before this detector runs (see
/// _dispatchSymptomInput), so including them here would be unreachable.
const Map<StructuralEventKind, List<String>> _kindKeywords = {
  StructuralEventKind.joint: [
    'articular',
    'articulación',
    'articulacion',
    'coyuntura',
  ],
  StructuralEventKind.muscle: ['muscular', 'músculo', 'musculo'],
  StructuralEventKind.tendon: [
    'tendón',
    'tendon',
    'tendinitis',
    'tendinosis',
  ],
  StructuralEventKind.ligament: ['ligamento', 'esguince'],
  StructuralEventKind.softTissue: [
    'herida',
    'corte',
    'quemadura',
    'abrasión',
    'abrasion',
  ],
  StructuralEventKind.nerve: [
    'nervio',
    'neuropático',
    'neuropatico',
    'hormigueo',
    'entumecid',
    'adormecid',
  ],
};

/// Finds the longest matching keyword for [norm] across all entries of
/// [table], returning the associated key (zone ID or kind) or null.
/// Longest-match-wins is required, not cosmetic: e.g. "antebrazo"
/// contains the substring "brazo", so a naive first-match scan would
/// wrongly resolve to upper_arm instead of forearm.
T? _longestKeywordMatch<T>(String norm, Map<T, List<String>> table) {
  T? best;
  var bestLength = 0;
  for (final entry in table.entries) {
    for (final keyword in entry.value) {
      if (keyword.length > bestLength && norm.contains(keyword)) {
        best = entry.key;
        bestLength = keyword.length;
      }
    }
  }
  return best;
}

/// Detects a body zone and/or a structural kind from free text typed
/// into the symptom vault. Zone and kind are resolved independently
/// since both can legitimately co-occur (e.g. "dolor muscular en la
/// rodilla" → kind=muscle AND zone=knees).
StructuralTextMatch detectStructuralTextMatch(String userInput) {
  final norm = userInput.trim().toLowerCase();
  if (norm.isEmpty) return const StructuralTextMatch();
  final zone = _longestKeywordMatch(norm, _zoneKeywords);
  final kind = _longestKeywordMatch(norm, _kindKeywords);
  final ambiguousZoneSignal =
      zone == null && _ambiguousZoneSignalWords.any(norm.contains);
  return StructuralTextMatch(
    zone: zone,
    kind: kind,
    hasAmbiguousZoneSignal: ambiguousZoneSignal,
  );
}
