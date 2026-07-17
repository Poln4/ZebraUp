// D.4 — Pelvic pain detail schema-closed model
//
// Typed representation of the optional detail layer attached to a
// SymptomEvent when the symptom matches 'pelvic_pain' and the user has
// the pelvic_pain_detail tracker enabled.
//
// Trauma-informed by design (CLAUDE.md backlog note). Two decisions
// were confirmed with Paulina before this schema was written — see
// docs/design_decisions/symptom_detail_layers.md §14 for the full
// discussion:
//   - Location chip wording is soft/everyday register, not clinical-
//     neutral — deliberately avoids the word "genital" (uses "zona
//     íntima" instead), mirroring the tone precedent set in D.1
//     fatigue.
//   - A sexual-pain (dyspareunia) chip IS included, worded neutrally
//     ("con la actividad sexual") as one optional multi-select trigger
//     among several — skippable, no follow-up questions, same opt-in
//     gating as everything else in this layer.
//
// `timing`'s `noCyclePattern` option explicitly covers "no clear
// relation to the cycle, or not applicable" in its copy, so patients
// who don't menstruate aren't forced into a menstrual-only framing
// (CLAUDE.md gender-neutral copy rule).
//
// Clinical basis: ACOG chronic pelvic pain guidance (cyclic vs. acyclic
// differentiation drives the `timing` group; sudden severe onset as an
// acute-abdomen/adnexal-torsion red flag drives `character`'s
// `suddenSevereOnset` — see pelvic_pain_red_flags.dart). Exact Practice
// Bulletin number/DOI to be verified before citing externally — see
// docs/design_decisions/symptom_detail_layers.md §14.
//
// 23 chips across 5 groups — exceeds the Morren ≤20 ceiling, same
// deliberate deviation already documented for D.2 abdominal (22 chips).

/// Ubicación del dolor (single-select). Wording suave/cotidiano — evita
/// la palabra "genital" a propósito (usa "zona íntima"), consistente
/// con el registro trauma-informado de D.1. Regiones abstractas, sin
/// mapa corporal anatómico, mismo principio que AbdominalLocation.
enum PelvicPainLocation {
  lowerAbdomen('lower_abdomen'),
  deepCentral('deep_central'),
  externalIntimate('external_intimate'),
  lowBackTailbone('low_back_tailbone'),
  radiatingLegsGroin('radiating_legs_groin');

  final String serializationKey;
  const PelvicPainLocation(this.serializationKey);

  static PelvicPainLocation? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Carácter del dolor (single-select). `suddenSevereOnset` es el gate
/// del red flag URGENT in-sheet (mirrors abdominal's `tearing`) — un
/// inicio súbito y muy intenso, distinto de lo usual, puede indicar
/// torsión anexial o rotura de un embarazo ectópico.
enum PelvicPainCharacter {
  cramping('cramping'),
  burning('burning'),
  pressureHeaviness('pressure_heaviness'),
  sharpStabbing('sharp_stabbing'),
  suddenSevereOnset('sudden_severe_onset');

  final String serializationKey;
  const PelvicPainCharacter(this.serializationKey);

  static PelvicPainCharacter? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Relación temporal con el ciclo (single-select). `noCyclePattern`
/// cubre explícitamente "sin relación clara, o no aplica" para no
/// asumir que toda paciente menstrúa.
enum PelvicPainTiming {
  withPeriod('with_period'),
  midCycle('mid_cycle'),
  noCyclePattern('no_cycle_pattern');

  final String serializationKey;
  const PelvicPainTiming(this.serializationKey);

  static PelvicPainTiming? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Contexto que dispara o acompaña el dolor (multi-select). Incluye el
/// chip de dolor con actividad sexual (dispareunia) — opcional, sin
/// preguntas de seguimiento, wording neutro.
enum PelvicPainTrigger {
  withBowelMovement('with_bowel_movement'),
  withBladderFullness('with_bladder_fullness'),
  prolongedSitting('prolonged_sitting'),
  physicalActivity('physical_activity'),
  sexualActivity('sexual_activity');

  final String serializationKey;
  const PelvicPainTrigger(this.serializationKey);

  static PelvicPainTrigger? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Síntomas acompañantes (multi-select). `abnormalBleeding` alimenta un
/// red flag URGENT; `pelvicFloorTension` fundamenta un advisory sobre
/// piso pélvico hipertónico (ver assets/zebra_wisdom.json).
enum PelvicPainAccompaniment {
  bloating('bloating'),
  urinaryUrgencyFrequency('urinary_urgency_frequency'),
  bowelChanges('bowel_changes'),
  pelvicFloorTension('pelvic_floor_tension'),
  abnormalBleeding('abnormal_bleeding');

  final String serializationKey;
  const PelvicPainAccompaniment(this.serializationKey);

  static PelvicPainAccompaniment? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Structured detail attached to a SymptomEvent whose name matches
/// 'pelvic_pain' (via SymptomDefinitionsService.matchesSymptomKey).
/// Attached only when the pelvic_pain_detail tracker is enabled in
/// optionalTrackers.
///
/// All fields are optional. `isEmpty` returns true when the user
/// completed the flow without marking anything — the caller treats
/// that as equivalent to skipping.
class PelvicPainDetail {
  final PelvicPainLocation? location;
  final PelvicPainCharacter? character;
  final PelvicPainTiming? timing;
  final Set<PelvicPainTrigger> triggers;
  final Set<PelvicPainAccompaniment> accompaniments;

  const PelvicPainDetail({
    this.location,
    this.character,
    this.timing,
    this.triggers = const <PelvicPainTrigger>{},
    this.accompaniments = const <PelvicPainAccompaniment>{},
  });

  bool get isEmpty =>
      location == null &&
      character == null &&
      timing == null &&
      triggers.isEmpty &&
      accompaniments.isEmpty;

  PelvicPainDetail copyWith({
    PelvicPainLocation? location,
    PelvicPainCharacter? character,
    PelvicPainTiming? timing,
    Set<PelvicPainTrigger>? triggers,
    Set<PelvicPainAccompaniment>? accompaniments,
    bool clearLocation = false,
    bool clearCharacter = false,
    bool clearTiming = false,
  }) {
    return PelvicPainDetail(
      location: clearLocation ? null : (location ?? this.location),
      character: clearCharacter ? null : (character ?? this.character),
      timing: clearTiming ? null : (timing ?? this.timing),
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
    if (timing != null) {
      map['timing'] = timing!.serializationKey;
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

  factory PelvicPainDetail.fromMap(Map<String, dynamic> map) {
    final trigRaw = map['triggers'];
    final accRaw = map['accompaniments'];
    return PelvicPainDetail(
      location: PelvicPainLocation.fromKey(map['location'] as String?),
      character: PelvicPainCharacter.fromKey(map['character'] as String?),
      timing: PelvicPainTiming.fromKey(map['timing'] as String?),
      triggers: trigRaw is List
          ? trigRaw
                .whereType<String>()
                .map(PelvicPainTrigger.fromKey)
                .whereType<PelvicPainTrigger>()
                .toSet()
          : const <PelvicPainTrigger>{},
      accompaniments: accRaw is List
          ? accRaw
                .whereType<String>()
                .map(PelvicPainAccompaniment.fromKey)
                .whereType<PelvicPainAccompaniment>()
                .toSet()
          : const <PelvicPainAccompaniment>{},
    );
  }
}
