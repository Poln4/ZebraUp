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

  /// Populated instead of [zone] when the text names a body region too
  /// broad to resolve to a single zone ID (e.g. "pierna" spans
  /// front_thigh/back_thigh/knees/calf/ankles/feet) but is still clearly
  /// a structural-pain mention. The list scopes the sheet's zone-pick
  /// step to just these candidates instead of the full body grid — see
  /// [BodyZonePickerGrid.candidateZones]. Only set when [zone] is null.
  /// Exists so [isEmpty] correctly stays false for this case — without
  /// it, "dolor pierna" alone would match neither a specific zone nor a
  /// kind and silently fall through to the generic severity menu
  /// instead of opening the combined sheet's zone-pick step, which is
  /// the whole point of this example.
  final List<String>? ambiguousZoneCandidates;

  const StructuralTextMatch({
    this.zone,
    this.kind,
    this.ambiguousZoneCandidates,
  });

  bool get hasAmbiguousZoneSignal => ambiguousZoneCandidates != null;

  bool get isEmpty =>
      zone == null && kind == null && ambiguousZoneCandidates == null;
}

/// Broad body-region words that don't map to one specific zone ID but
/// should still be recognized as "this is about structural pain", each
/// scoped to the subset of zones it plausibly refers to — see
/// [StructuralTextMatch.ambiguousZoneCandidates]. "espalda" is scoped to
/// the back-proper zones (not hips/glutes, which are lower_back_pelvis
/// siblings but not "espalda" in patient language).
const Map<String, List<String>> _ambiguousZoneSignalGroups = {
  'pierna': ['front_thigh', 'back_thigh', 'knees', 'calf', 'ankles', 'feet'],
  'piernas': ['front_thigh', 'back_thigh', 'knees', 'calf', 'ankles', 'feet'],
  'espalda': ['upper_back', 'shoulder_blades', 'lumbar_pelvis'],
};

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
/// `_ambiguousZoneSignalGroups` for how these still trigger the sheet
/// (now scoped to a candidate zone list) despite not resolving a
/// specific zone.
const Map<String, List<String>> _zoneKeywords = {
  'cervical': ['cervical', 'cervicales', 'cuello', 'nuca'],
  'jaw': ['mandíbula', 'mandibula', 'mandíbulas', 'mandibulas', 'quijada'],
  'shoulders': ['hombro', 'hombros'],
  'shoulder_blades': [
    'omóplato',
    'omoplato',
    'omóplatos',
    'omoplatos',
    'escápula',
    'escapula',
    'escápulas',
    'escapulas',
    'paletilla',
    'paletillas',
  ],
  'upper_back': ['espalda alta', 'espalda superior'],
  // Word-boundary matching (see _containsWord) means "antebrazo" no
  // longer accidentally matches the "brazo" keyword below (it's
  // preceded by "ante", not a boundary) — list order/longest-match no
  // longer does the disambiguation work it used to.
  'forearm': ['antebrazo', 'antebrazos'],
  'upper_arm': [
    'brazo',
    'brazos',
    'bíceps',
    'biceps',
    'tríceps',
    'triceps',
  ],
  'elbow': ['codo', 'codos'],
  'wrists': ['muñeca', 'muñecas', 'muneca', 'munecas'],
  'hands': ['mano', 'manos', 'dedo', 'dedos'],
  'lumbar_pelvis': ['lumbar', 'espalda baja', 'zona lumbar'],
  'hips': ['cadera', 'caderas'],
  'glutes': ['glúteo', 'gluteo', 'glúteos', 'gluteos'],
  'front_thigh': ['muslo', 'muslos', 'cuádriceps', 'cuadriceps'],
  'back_thigh': ['isquiotibial', 'isquiotibiales'],
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
///
/// All entries are complete words — matching is word-boundary strict
/// (see _containsWord), so inflections (plural, gender, verb forms)
/// must be listed explicitly rather than relying on a truncated stem
/// substring-matching into them.
const Map<StructuralEventKind, List<String>> _kindKeywords = {
  StructuralEventKind.joint: [
    'articular',
    'articulación',
    'articulacion',
    'articulaciones',
    'coyuntura',
    'coyunturas',
  ],
  StructuralEventKind.muscle: [
    'muscular',
    'musculares',
    'músculo',
    'musculo',
    'músculos',
    'musculos',
  ],
  StructuralEventKind.tendon: [
    'tendón',
    'tendon',
    'tendones',
    'tendinitis',
    'tendinosis',
  ],
  StructuralEventKind.ligament: [
    'ligamento',
    'ligamentos',
    'esguince',
    'esguinces',
  ],
  StructuralEventKind.softTissue: [
    'herida',
    'heridas',
    'corte',
    'cortes',
    'quemadura',
    'quemaduras',
    'abrasión',
    'abrasion',
    'abrasiones',
  ],
  StructuralEventKind.nerve: [
    'nervio',
    'nervios',
    'neuropático',
    'neuropatico',
    'hormigueo',
    'hormigueos',
    'entumecido',
    'entumecida',
    'entumecidos',
    'entumecidas',
    'adormecido',
    'adormecida',
    'adormecidos',
    'adormecidas',
  ],
};

/// Spanish letters (incl. accented vowels + ñ) and digits — used to
/// define word boundaries so keyword matching doesn't fire on a
/// keyword that's merely a substring of an unrelated longer word (e.g.
/// "pie" inside "piernas", found in production 18-jul-2026: "dolor
/// piernas" was silently resolving to the "feet" zone).
const _wordCharPattern = '[a-z0-9áéíóúñ]';

/// True when [keyword] appears in [norm] as a whole word (or whole
/// phrase, for multi-word keywords like "espalda alta") — not merely
/// as a substring of a longer word. Both [norm] and [keyword] are
/// expected already lowercased.
bool _containsWord(String norm, String keyword) {
  final pattern = RegExp(
    '(?<!$_wordCharPattern)${RegExp.escape(keyword)}(?!$_wordCharPattern)',
  );
  return pattern.hasMatch(norm);
}

/// Finds the longest matching keyword for [norm] across all entries of
/// [table], returning the associated key (zone ID or kind) or null.
/// Longest-match-wins is a tie-breaker for when a text legitimately
/// contains more than one recognizable keyword (e.g. a multi-word
/// phrase alongside a shorter one); it does not compensate for
/// accidental substring collisions — those are prevented by
/// [_containsWord]'s word-boundary check instead.
T? _longestKeywordMatch<T>(String norm, Map<T, List<String>> table) {
  T? best;
  var bestLength = 0;
  for (final entry in table.entries) {
    for (final keyword in entry.value) {
      if (keyword.length > bestLength && _containsWord(norm, keyword)) {
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
  List<String>? ambiguousZoneCandidates;
  if (zone == null) {
    for (final entry in _ambiguousZoneSignalGroups.entries) {
      if (_containsWord(norm, entry.key)) {
        ambiguousZoneCandidates = entry.value;
        break;
      }
    }
  }
  return StructuralTextMatch(
    zone: zone,
    kind: kind,
    ambiguousZoneCandidates: ambiguousZoneCandidates,
  );
}
