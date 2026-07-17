// D.3 — Presyncope detail schema-closed model
//
// Typed representation of the optional detail layer attached to a
// SymptomEvent when the symptom matches 'presyncope' and the user has
// the presyncope_detail tracker enabled.
//
// Deliberately subjective-only: this layer captures what the patient
// experienced (trigger, prodrome, outcome, recovery), never a measured
// value. Active measurement (OrthostaticTest / NASA lean test) is
// explicitly deferred to a future mobile build — see
// docs/design_decisions/symptom_detail_layers.md §13.
//
// Clinical basis (verified DOIs):
//   - Brignole M et al. 2018 — ESC Guidelines for the diagnosis and
//     management of syncope (mechanism taxonomy: reflex/vasovagal,
//     orthostatic, cardiac; high-risk features).
//     DOI: 10.1093/eurheartj/ehy037
//
// MAPS (Malmö POTS Symptom Score, Spahic et al. 2023,
// DOI: 10.1111/joim.13566) was considered and archived for a future
// periodic-scale item instead of this per-event layer — it's a 7-day
// recall symptom-burden questionnaire, architecturally different from
// the event-by-event pattern used by C.4/D.1/D.2/D.3.

/// Desencadenante del episodio (single-select). `postExertion` y
/// `noPositionChange` alimentan red flags ADVISORY en
/// presyncope_red_flags.dart.
enum PresyncopeMechanism {
  onStanding('on_standing'),
  prolongedStanding('prolonged_standing'),
  situational('situational'),
  postExertion('post_exertion'),
  strongEmotionOrPain('strong_emotion_or_pain'),
  noPositionChange('no_position_change'),
  unidentified('unidentified');

  final String serializationKey;
  const PresyncopeMechanism(this.serializationKey);

  static PresyncopeMechanism? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Síntomas previos al episodio (multi-select). Signos clásicos de
/// hipoperfusión transitoria / respuesta autonómica per ESC 2018.
enum PresyncopeProdromeSymptom {
  tunnelVision('tunnel_vision'),
  ringingEars('ringing_ears'),
  coldSweat('cold_sweat'),
  nausea('nausea'),
  palenessNoted('paleness_noted'),
  palpitations('palpitations');

  final String serializationKey;
  const PresyncopeProdromeSymptom(this.serializationKey);

  static PresyncopeProdromeSymptom? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Cómo terminó el episodio (single-select). `briefLossOfConsciousness`
/// es el gate del red flag URGENT (in-sheet, bloqueante pre-save).
enum PresyncopeOutcome {
  satOrLayDown('sat_or_lay_down'),
  nearFallNoLoc('near_fall_no_loc'),
  briefLossOfConsciousness('brief_loc');

  final String serializationKey;
  const PresyncopeOutcome(this.serializationKey);

  static PresyncopeOutcome? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Velocidad/calidad de la recuperación (single-select).
enum PresyncopeRecovery {
  fast('fast'),
  slow('slow'),
  tiredAfter('tired_after');

  final String serializationKey;
  const PresyncopeRecovery(this.serializationKey);

  static PresyncopeRecovery? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Structured detail attached to a SymptomEvent whose name matches
/// 'presyncope' (via SymptomDefinitionsService.matchesSymptomKey).
/// Attached only when the presyncope_detail tracker is enabled in
/// optionalTrackers.
///
/// All fields are optional. `isEmpty` returns true when the user
/// completed the flow without marking anything — the caller treats
/// that as equivalent to skipping.
class PresyncopeDetail {
  final PresyncopeMechanism? mechanism;
  final Set<PresyncopeProdromeSymptom> prodrome;
  final PresyncopeOutcome? outcome;
  final PresyncopeRecovery? recovery;

  const PresyncopeDetail({
    this.mechanism,
    this.prodrome = const <PresyncopeProdromeSymptom>{},
    this.outcome,
    this.recovery,
  });

  bool get isEmpty =>
      mechanism == null &&
      prodrome.isEmpty &&
      outcome == null &&
      recovery == null;

  PresyncopeDetail copyWith({
    PresyncopeMechanism? mechanism,
    Set<PresyncopeProdromeSymptom>? prodrome,
    PresyncopeOutcome? outcome,
    PresyncopeRecovery? recovery,
    bool clearMechanism = false,
    bool clearOutcome = false,
    bool clearRecovery = false,
  }) {
    return PresyncopeDetail(
      mechanism: clearMechanism ? null : (mechanism ?? this.mechanism),
      prodrome: prodrome ?? this.prodrome,
      outcome: clearOutcome ? null : (outcome ?? this.outcome),
      recovery: clearRecovery ? null : (recovery ?? this.recovery),
    );
  }

  /// Serialization omits empty/null fields so old exports remain
  /// compact and forward-compatible.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (mechanism != null) {
      map['mechanism'] = mechanism!.serializationKey;
    }
    if (prodrome.isNotEmpty) {
      map['prodrome'] = prodrome.map((e) => e.serializationKey).toList();
    }
    if (outcome != null) {
      map['outcome'] = outcome!.serializationKey;
    }
    if (recovery != null) {
      map['recovery'] = recovery!.serializationKey;
    }
    return map;
  }

  factory PresyncopeDetail.fromMap(Map<String, dynamic> map) {
    final prodromeRaw = map['prodrome'];
    return PresyncopeDetail(
      mechanism: PresyncopeMechanism.fromKey(map['mechanism'] as String?),
      prodrome: prodromeRaw is List
          ? prodromeRaw
                .whereType<String>()
                .map(PresyncopeProdromeSymptom.fromKey)
                .whereType<PresyncopeProdromeSymptom>()
                .toSet()
          : const <PresyncopeProdromeSymptom>{},
      outcome: PresyncopeOutcome.fromKey(map['outcome'] as String?),
      recovery: PresyncopeRecovery.fromKey(map['recovery'] as String?),
    );
  }
}
