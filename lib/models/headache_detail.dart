// C.4 — Headache detail (schema-cerrado)
//
// Typed model for the cefalea detail layer. Five enums for the five
// groups (location/quality/accompaniments/postural_pattern/onset).
//
// All fields optional: a log entry can have any subset of detail or
// none at all. Logs from before C.4 have detail=null on their Symptom
// instance.
//
// Serialization keys mirror assets/symptom_definitions.json exactly so
// the JSON is the single source of truth for chip identifiers.
//
// Clinical reference for the chip vocabulary:
//   - ICHD-3 (Olesen 2018, DOI: 10.1016/S1474-4422(18)30085-1)
//   - BDHD diary (Jensen 2011, DOI: 10.1177/0333102411424212)
//   - E-diary van Casteren 2021 (DOI: 10.1177/03331024211010306)

enum HeadacheLocation {
  unilateral,
  bilateral,
  behindEyes,
  neckOccipital,
  temples,
  crownDiffuse;

  String get serializationKey => switch (this) {
        HeadacheLocation.unilateral => 'unilateral',
        HeadacheLocation.bilateral => 'bilateral',
        HeadacheLocation.behindEyes => 'behind_eyes',
        HeadacheLocation.neckOccipital => 'neck_occipital',
        HeadacheLocation.temples => 'temples',
        HeadacheLocation.crownDiffuse => 'crown_diffuse',
      };

  static HeadacheLocation? fromKey(String? key) {
    if (key == null) return null;
    for (final v in HeadacheLocation.values) {
      if (v.serializationKey == key) return v;
    }
    return null;
  }
}

enum HeadacheQuality {
  pulsating,
  pressing,
  stabbing,
  brainZaps;

  String get serializationKey => switch (this) {
        HeadacheQuality.pulsating => 'pulsating',
        HeadacheQuality.pressing => 'pressing',
        HeadacheQuality.stabbing => 'stabbing',
        HeadacheQuality.brainZaps => 'brain_zaps',
      };

  static HeadacheQuality? fromKey(String? key) {
    if (key == null) return null;
    for (final v in HeadacheQuality.values) {
      if (v.serializationKey == key) return v;
    }
    return null;
  }
}

enum HeadacheAccompaniment {
  nausea,
  vomiting,
  photophobia,
  phonophobia,
  visualAura,
  movementIntolerance,
  tempDysregulation;

  String get serializationKey => switch (this) {
        HeadacheAccompaniment.nausea => 'nausea',
        HeadacheAccompaniment.vomiting => 'vomiting',
        HeadacheAccompaniment.photophobia => 'photophobia',
        HeadacheAccompaniment.phonophobia => 'phonophobia',
        HeadacheAccompaniment.visualAura => 'visual_aura',
        HeadacheAccompaniment.movementIntolerance => 'movement_intolerance',
        HeadacheAccompaniment.tempDysregulation => 'temp_dysregulation',
      };

  static HeadacheAccompaniment? fromKey(String? key) {
    if (key == null) return null;
    for (final v in HeadacheAccompaniment.values) {
      if (v.serializationKey == key) return v;
    }
    return null;
  }
}

enum HeadachePosturalPattern {
  worseUpright,
  worseRecumbent,
  noPosturalPattern;

  String get serializationKey => switch (this) {
        HeadachePosturalPattern.worseUpright => 'worse_upright',
        HeadachePosturalPattern.worseRecumbent => 'worse_recumbent',
        HeadachePosturalPattern.noPosturalPattern => 'no_postural_pattern',
      };

  static HeadachePosturalPattern? fromKey(String? key) {
    if (key == null) return null;
    for (final v in HeadachePosturalPattern.values) {
      if (v.serializationKey == key) return v;
    }
    return null;
  }
}

enum HeadacheOnset {
  thunderclap;

  String get serializationKey => switch (this) {
        HeadacheOnset.thunderclap => 'thunderclap',
      };

  static HeadacheOnset? fromKey(String? key) {
    if (key == null) return null;
    for (final v in HeadacheOnset.values) {
      if (v.serializationKey == key) return v;
    }
    return null;
  }
}

class HeadacheDetail {
  final Set<HeadacheLocation> locations;
  final HeadacheQuality? quality;
  final Set<HeadacheAccompaniment> accompaniments;
  final HeadachePosturalPattern? posturalPattern;
  final HeadacheOnset? onset;

  const HeadacheDetail({
    this.locations = const {},
    this.quality,
    this.accompaniments = const {},
    this.posturalPattern,
    this.onset,
  });

  /// True if the user touched any chip. An empty detail (all fields
  /// null/empty) is equivalent to no detail — the log entry should
  /// store `null` for the detail field in that case.
  bool get isEmpty =>
      locations.isEmpty &&
      quality == null &&
      accompaniments.isEmpty &&
      posturalPattern == null &&
      onset == null;

  bool get isNotEmpty => !isEmpty;

  HeadacheDetail copyWith({
    Set<HeadacheLocation>? locations,
    HeadacheQuality? quality,
    bool clearQuality = false,
    Set<HeadacheAccompaniment>? accompaniments,
    HeadachePosturalPattern? posturalPattern,
    bool clearPosturalPattern = false,
    HeadacheOnset? onset,
    bool clearOnset = false,
  }) {
    return HeadacheDetail(
      locations: locations ?? this.locations,
      quality: clearQuality ? null : (quality ?? this.quality),
      accompaniments: accompaniments ?? this.accompaniments,
      posturalPattern: clearPosturalPattern
          ? null
          : (posturalPattern ?? this.posturalPattern),
      onset: clearOnset ? null : (onset ?? this.onset),
    );
  }

  Map<String, dynamic> toMap() => {
        if (locations.isNotEmpty)
          'locations': locations.map((e) => e.serializationKey).toList(),
        if (quality != null) 'quality': quality!.serializationKey,
        if (accompaniments.isNotEmpty)
          'accompaniments':
              accompaniments.map((e) => e.serializationKey).toList(),
        if (posturalPattern != null)
          'postural_pattern': posturalPattern!.serializationKey,
        if (onset != null) 'onset': onset!.serializationKey,
      };

  factory HeadacheDetail.fromMap(Map<String, dynamic> m) {
    final locList = (m['locations'] as List?) ?? const [];
    final accList = (m['accompaniments'] as List?) ?? const [];
    return HeadacheDetail(
      locations: locList
          .map((e) => HeadacheLocation.fromKey(e as String?))
          .whereType<HeadacheLocation>()
          .toSet(),
      quality: HeadacheQuality.fromKey(m['quality'] as String?),
      accompaniments: accList
          .map((e) => HeadacheAccompaniment.fromKey(e as String?))
          .whereType<HeadacheAccompaniment>()
          .toSet(),
      posturalPattern:
          HeadachePosturalPattern.fromKey(m['postural_pattern'] as String?),
      onset: HeadacheOnset.fromKey(m['onset'] as String?),
    );
  }
}
