// D.5 — Chest pain detail schema-closed model
//
// Typed representation of the optional detail layer attached to a
// SymptomEvent when the symptom matches 'chest_pain' and the user has
// the chest_pain_detail tracker enabled.
//
// The highest-stakes symptom detail layer in the app: chest pain in
// this population spans very common benign costochondritis/Tietze
// syndrome (frequent in EDS due to costochondral joint laxity — see
// assets/condition_codes.json) all the way to two genuine emergencies —
// acute coronary syndrome (general population risk) and, for vascular
// EDS (vEDS) patients specifically, aortic dissection/arterial rupture.
//
// Clinical basis (verified DOIs):
//   - Gulati M et al. 2021 — AHA/ACC/ASE/CHEST/SAEM/SCCT/SCMR Guideline
//     for the Evaluation and Diagnosis of Chest Pain. Circulation
//     2021;144:e368–e454. DOI: 10.1161/CIR.0000000000001029.
//   - Isselbacher EM et al. 2022 — ACC/AHA Guideline for the Diagnosis
//     and Management of Aortic Disease. Circulation 2022.
//     DOI: 10.1161/CIR.0000000000001106. Covers vascular EDS explicitly.
//
// See lib/services/chest_pain_red_flags.dart for the vEDS-aware red
// flag logic and docs/design_decisions/symptom_detail_layers.md §15
// for the full design writeup.

/// Ubicación del dolor (single-select). `upperBackBetweenShoulderBlades`
/// no es solo una zona musculoesquelética — es un patrón de irradiación
/// clásico de disección aórtica per la guía de enfermedad aórtica 2022.
enum ChestPainLocation {
  retrosternalCentral('retrosternal_central'),
  leftSided('left_sided'),
  rightSided('right_sided'),
  costalMargin('costal_margin'),
  upperBackBetweenShoulderBlades('upper_back_between_shoulder_blades');

  final String serializationKey;
  const ChestPainLocation(this.serializationKey);

  static ChestPainLocation? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Carácter del dolor (single-select). `tearingOrRipping` es el gate
/// del red flag URGENT in-sheet (mirrors abdominal's `tearing` y
/// pelvic pain's `suddenSevereOnset`) — descriptor clásico de
/// disección aórtica. `achingWorseWithPressing` es el diferenciador de
/// costocondritis: la sensibilidad reproducible a la palpación es un
/// signo clínico reconocido que reduce la probabilidad de causa
/// cardíaca.
enum ChestPainCharacter {
  pressureOrTightness('pressure_or_tightness'),
  sharpOrStabbing('sharp_or_stabbing'),
  burning('burning'),
  achingWorseWithPressing('aching_worse_with_pressing'),
  tearingOrRipping('tearing_or_ripping');

  final String serializationKey;
  const ChestPainCharacter(this.serializationKey);

  static ChestPainCharacter? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Qué lo empeora o dispara (multi-select). `worseWithExertion`
/// alimenta un red flag URGENT compuesto (patrón anginal per
/// AHA/ACC 2021).
enum ChestPainTrigger {
  worseWithBreathingOrMovement('worse_with_breathing_or_movement'),
  worseWithPressingOnArea('worse_with_pressing_on_area'),
  worseWithExertion('worse_with_exertion'),
  afterEatingOrLyingDown('after_eating_or_lying_down'),
  noClearTrigger('no_clear_trigger');

  final String serializationKey;
  const ChestPainTrigger(this.serializationKey);

  static ChestPainTrigger? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Síntomas acompañantes (multi-select). `radiatesToArmJawBack`,
/// `shortnessOfBreath` y `sweatingOrClamminess` alimentan el red flag
/// URGENT de patrón cardíaco (AHA/ACC 2021). `palpitationsOrRacingHeart`
/// es especialmente relevante dada la comorbilidad de POTS/disautonomía
/// en esta población.
enum ChestPainAccompaniment {
  shortnessOfBreath('shortness_of_breath'),
  radiatesToArmJawBack('radiates_to_arm_jaw_back'),
  sweatingOrClamminess('sweating_or_clamminess'),
  nauseaOrVomiting('nausea_or_vomiting'),
  palpitationsOrRacingHeart('palpitations_or_racing_heart'),
  feelingFaintOrDizzy('feeling_faint_or_dizzy');

  final String serializationKey;
  const ChestPainAccompaniment(this.serializationKey);

  static ChestPainAccompaniment? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Structured detail attached to a SymptomEvent whose name matches
/// 'chest_pain' (via SymptomDefinitionsService.matchesSymptomKey).
/// Attached only when the chest_pain_detail tracker is enabled in
/// optionalTrackers.
///
/// All fields are optional. `isEmpty` returns true when the user
/// completed the flow without marking anything — the caller treats
/// that as equivalent to skipping.
class ChestPainDetail {
  final ChestPainLocation? location;
  final ChestPainCharacter? character;
  final Set<ChestPainTrigger> triggers;
  final Set<ChestPainAccompaniment> accompaniments;

  const ChestPainDetail({
    this.location,
    this.character,
    this.triggers = const <ChestPainTrigger>{},
    this.accompaniments = const <ChestPainAccompaniment>{},
  });

  bool get isEmpty =>
      location == null &&
      character == null &&
      triggers.isEmpty &&
      accompaniments.isEmpty;

  ChestPainDetail copyWith({
    ChestPainLocation? location,
    ChestPainCharacter? character,
    Set<ChestPainTrigger>? triggers,
    Set<ChestPainAccompaniment>? accompaniments,
    bool clearLocation = false,
    bool clearCharacter = false,
  }) {
    return ChestPainDetail(
      location: clearLocation ? null : (location ?? this.location),
      character: clearCharacter ? null : (character ?? this.character),
      triggers: triggers ?? this.triggers,
      accompaniments: accompaniments ?? this.accompaniments,
    );
  }

  /// Serialization omits empty/null fields so old exports remain
  /// compact and forward-compatible.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (location != null) {
      map['location'] = location!.serializationKey;
    }
    if (character != null) {
      map['character'] = character!.serializationKey;
    }
    if (triggers.isNotEmpty) {
      map['triggers'] = triggers.map((e) => e.serializationKey).toList();
    }
    if (accompaniments.isNotEmpty) {
      map['accompaniments'] = accompaniments
          .map((e) => e.serializationKey)
          .toList();
    }
    return map;
  }

  factory ChestPainDetail.fromMap(Map<String, dynamic> map) {
    final trigRaw = map['triggers'];
    final accRaw = map['accompaniments'];
    return ChestPainDetail(
      location: ChestPainLocation.fromKey(map['location'] as String?),
      character: ChestPainCharacter.fromKey(map['character'] as String?),
      triggers: trigRaw is List
          ? trigRaw
                .whereType<String>()
                .map(ChestPainTrigger.fromKey)
                .whereType<ChestPainTrigger>()
                .toSet()
          : const <ChestPainTrigger>{},
      accompaniments: accRaw is List
          ? accRaw
                .whereType<String>()
                .map(ChestPainAccompaniment.fromKey)
                .whereType<ChestPainAccompaniment>()
                .toSet()
          : const <ChestPainAccompaniment>{},
    );
  }
}
