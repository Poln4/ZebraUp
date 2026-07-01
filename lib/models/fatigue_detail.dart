// D.1 — Fatigue detail schema-closed model
//
// Typed representation of the optional detail layer attached to a
// SymptomEvent when the symptom matches 'fatigue' and the user has the
// fatigue_detail tracker enabled.
//
// Clinical basis (DOIs):
//   - Clayton EW. IOM 2015 ME/CFS criteria (SEID).
//     DOI: 10.1001/jama.2015.1346
//   - Mateo LJ et al. 2020 (PEM quantification: 24-72h delayed onset,
//     51% not recovered at day 7).
//     DOI: 10.3233/wor-203168
//   - Jason LA et al. 2010 (MFTQ 5 clinically distinguishable fatigue
//     types, including "wired" as factorially separable).
//     DOI: 10.1080/08964280903521370
//   - De Wandele I et al. 2016 (orthostatic intolerance in 74.4% of
//     EDS-HT; fatigue +3.1 NRS post-tilt vs +0.5 in controls).
//     DOI: 10.1093/rheumatology/kew032
//   - Voermans NC et al. 2010 (fatigue as frequent and clinically
//     relevant problem in EDS).
//     DOI: 10.1016/j.semarthrit.2009.08.003
//   - Rowe PC et al. 1999 (EDS + CFS + orthostatism co-occurrence).
//     DOI: 10.1016/s0022-3476(99)70173-3
//
// Design decisions traceable in docs/design_decisions/symptom_detail_layers.md.

/// Predominant type of fatigue (single-select). One physiological
/// mechanism per episode; if two mix, the user picks the dominant one.
enum FatigueType {
  cognitiveDrain('cognitive_drain'),
  muscleUnresponsive('muscle_unresponsive'),
  orthostatic('orthostatic'),
  postExertional('post_exertional'),
  hpaWired('hpa_wired');

  final String serializationKey;
  const FatigueType(this.serializationKey);

  static FatigueType? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// When the fatigue appeared (single-select). Helps distinguish
/// unrefreshing sleep from post-meal patterns and identifiable triggers.
enum FatigueTemporalPattern {
  sinceWaking('since_waking'),
  duringDay('during_day'),
  postMeal('post_meal'),
  postTrigger('post_trigger');

  final String serializationKey;
  const FatigueTemporalPattern(this.serializationKey);

  static FatigueTemporalPattern? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Symptoms accompanying the fatigue (multi-select). Any combination
/// can co-occur in a single episode.
enum FatigueAccompaniment {
  brainFog('brain_fog'),
  dizzinessStanding('dizziness_standing'),
  unrefreshingSleep('unrefreshing_sleep'),
  restingTachycardia('resting_tachycardia'),
  headache('headache'),
  diffuseMusclePain('diffuse_muscle_pain'),
  lightSoundIntolerance('light_sound_intolerance'),
  tempDysregulation('temp_dysregulation');

  final String serializationKey;
  const FatigueAccompaniment(this.serializationKey);

  static FatigueAccompaniment? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Suspected triggers preceding the fatigue (multi-select). Retrospective
/// self-report; the app cross-references with logged life events and
/// activity when available.
enum FatigueTrigger {
  pastExertion('past_exertion'),
  badNight('bad_night'),
  emotionalStress('emotional_stress');

  final String serializationKey;
  const FatigueTrigger(this.serializationKey);

  static FatigueTrigger? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Structured detail attached to a SymptomEvent whose name matches
/// 'fatigue' (via SymptomDefinitionsService.matchesSymptomKey). Attached
/// only when the fatigue_detail tracker is enabled in optionalTrackers.
///
/// All fields are optional. `isEmpty` returns true when the user
/// completed the flow without marking anything — the caller treats that
/// as equivalent to skipping.
class FatigueDetail {
  final FatigueType? type;
  final FatigueTemporalPattern? temporalPattern;
  final Set<FatigueAccompaniment> accompaniments;
  final Set<FatigueTrigger> triggers;

  const FatigueDetail({
    this.type,
    this.temporalPattern,
    this.accompaniments = const <FatigueAccompaniment>{},
    this.triggers = const <FatigueTrigger>{},
  });

  bool get isEmpty =>
      type == null &&
      temporalPattern == null &&
      accompaniments.isEmpty &&
      triggers.isEmpty;

  FatigueDetail copyWith({
    FatigueType? type,
    FatigueTemporalPattern? temporalPattern,
    Set<FatigueAccompaniment>? accompaniments,
    Set<FatigueTrigger>? triggers,
    bool clearType = false,
    bool clearTemporalPattern = false,
  }) {
    return FatigueDetail(
      type: clearType ? null : (type ?? this.type),
      temporalPattern: clearTemporalPattern
          ? null
          : (temporalPattern ?? this.temporalPattern),
      accompaniments: accompaniments ?? this.accompaniments,
      triggers: triggers ?? this.triggers,
    );
  }

  /// Serialization omits empty/null fields so old exports remain compact
  /// and forward-compatible.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (type != null) {
      map['type'] = type!.serializationKey;
    }
    if (temporalPattern != null) {
      map['temporal_pattern'] = temporalPattern!.serializationKey;
    }
    if (accompaniments.isNotEmpty) {
      map['accompaniments'] =
          accompaniments.map((e) => e.serializationKey).toList();
    }
    if (triggers.isNotEmpty) {
      map['triggers'] = triggers.map((e) => e.serializationKey).toList();
    }
    return map;
  }

  factory FatigueDetail.fromMap(Map<String, dynamic> map) {
    final accRaw = map['accompaniments'];
    final trigRaw = map['triggers'];
    return FatigueDetail(
      type: FatigueType.fromKey(map['type'] as String?),
      temporalPattern: FatigueTemporalPattern.fromKey(
          map['temporal_pattern'] as String?),
      accompaniments: accRaw is List
          ? accRaw
              .whereType<String>()
              .map(FatigueAccompaniment.fromKey)
              .whereType<FatigueAccompaniment>()
              .toSet()
          : const <FatigueAccompaniment>{},
      triggers: trigRaw is List
          ? trigRaw
              .whereType<String>()
              .map(FatigueTrigger.fromKey)
              .whereType<FatigueTrigger>()
              .toSet()
          : const <FatigueTrigger>{},
    );
  }
}
