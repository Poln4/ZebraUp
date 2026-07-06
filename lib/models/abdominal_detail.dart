// D.2 — Abdominal detail schema-closed model
//
// Typed representation of the optional detail layer attached to a
// SymptomEvent when the symptom matches 'abdominal_pain' and the user
// has the abdominal_detail tracker enabled.
//
// The alias set for abdominal_pain is intentionally broad. It covers
// three semantic clusters:
//   - Pain (dolor abdominal, cólico, retortijón, ...)
//   - Bloating (hinchazón, distensión, ...)
//   - Gas (gases, pedos, peos, flatulencia, ...)
//
// The sheet UI applies progressive disclosure semántico based on which
// alias triggered the sheet, pre-marking relevant chips in the
// accompaniments group (bloating / excessive_gas) without hiding any
// other group. Grupos siempre visibles — respects user autonomy to log
// combinations (bloating with cramps, gas with tender abdomen, etc.).
//
// Clinical basis (verified DOIs):
//   - Palsson OS et al. 2016 — Rome IV Diagnostic Questionnaire.
//     DOI: 10.1053/j.gastro.2016.02.014
//   - Zeitoun JD et al. 2013 — Functional digestive symptoms in EDS
//     (84% GI symptom prevalence).
//     DOI: 10.1371/journal.pone.0080321
//   - Fikree A et al. 2014 — GI symptoms in JHS prospective cohort.
//     DOI: 10.1016/j.cgh.2014.01.014
//   - Fikree A et al. 2015 — FGID + JHS case-control.
//     DOI: 10.1111/nmo.12535
//   - Fikree A et al. 2017 — GI involvement in EDS review.
//     DOI: 10.1002/ajmg.c.31546
//   - Nelson AD et al. 2015 — Mayo Clinic 20-year retrospective
//     (66% GI symptoms, 25% gastroparesis, 30% abnormal colonic transit).
//     DOI: 10.1111/nmo.12665
//
// `linkedBowelEventId` field — forward-compat FK to BowelEvent.id.
// Wired up in D.2.E (integration cruzada). At D.2.A infrastructure
// stage, the field exists but is not populated by any flow.
// Referential integrity is best-effort — if the referenced BowelEvent
// is deleted, the abdominal detail retains the dangling ID for future
// analytics recovery. Design decisions traceable in
// docs/design_decisions/symptom_detail_layers.md.

/// Ubicación anatómica del dolor (single-select). 5 cuadrantes abstractos
/// per Gemini UX + NotebookLM recommendations — avoids anatomical body-
/// map interfaces that create trauma-informed and motor-accessibility
/// issues (EDS hand hypermobility).
enum AbdominalLocation {
  epigastric('epigastric'),
  periumbilical('periumbilical'),
  hypogastric('hypogastric'),
  ruq('ruq'),
  diffuse('diffuse');

  final String serializationKey;
  const AbdominalLocation(this.serializationKey);

  static AbdominalLocation? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Calidad del dolor (single-select). Cualitativamente distinta según
/// origen: motor (colicky), mucoso/inflamatorio (burning), mecánico
/// (pressure), vascular/isquémico (tearing — URGENT flag trigger).
enum AbdominalQuality {
  colicky('colicky'),
  burning('burning'),
  pressure('pressure'),
  tearing('tearing');

  final String serializationKey;
  const AbdominalQuality(this.serializationKey);

  static AbdominalQuality? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Relación temporal con eventos fisiológicos (single-select). El timing
/// es el principal discriminador clínico de trastornos funcionales GI
/// per Roma IV (Palsson 2016).
enum AbdominalTiming {
  postprandialImmediate('postprandial_immediate'),
  postprandialDelayed('postprandial_delayed'),
  nocturnal('nocturnal'),
  bowelRelated('bowel_related');

  final String serializationKey;
  const AbdominalTiming(this.serializationKey);

  static AbdominalTiming? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Síntomas acompañantes (multi-select). El chip `bloating` es
/// pre-marcado por el sheet cuando el alias que abrió el sheet es de
/// semántica bloating; `excessiveGas` idem para semántica gas.
enum AbdominalAccompaniment {
  nausea('nausea'),
  vomiting('vomiting'),
  earlySatiety('early_satiety'),
  bloating('bloating'),
  excessiveGas('excessive_gas'),
  bloodyStool('bloody_stool');

  final String serializationKey;
  const AbdominalAccompaniment(this.serializationKey);

  static AbdominalAccompaniment? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Trigger sospechoso (multi-select). Retrospective self-report — el
/// app cross-referencia con logged life events cuando corresponde.
enum AbdominalTrigger {
  specificFood('specific_food'),
  emotionalStress('emotional_stress'),
  menstrualCycle('menstrual_cycle');

  final String serializationKey;
  const AbdominalTrigger(this.serializationKey);

  static AbdominalTrigger? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Structured detail attached to a SymptomEvent whose name matches
/// 'abdominal_pain' (via SymptomDefinitionsService.matchesSymptomKey).
/// Attached only when the abdominal_detail tracker is enabled in
/// optionalTrackers.
///
/// All fields are optional. `isEmpty` returns true when the user
/// completed the flow without marking anything — the caller treats
/// that as equivalent to skipping.
class AbdominalDetail {
  final AbdominalLocation? location;
  final AbdominalQuality? quality;
  final AbdominalTiming? timing;
  final Set<AbdominalAccompaniment> accompaniments;
  final Set<AbdominalTrigger> triggers;

  /// D.2 forward-compat: link to a BowelEvent.id when the abdominal
  /// pain is temporally associated with a specific bowel movement.
  /// Populated by the D.2.E integration flow (post-save prompt).
  /// Null when unpopulated.
  final String? linkedBowelEventId;

  const AbdominalDetail({
    this.location,
    this.quality,
    this.timing,
    this.accompaniments = const <AbdominalAccompaniment>{},
    this.triggers = const <AbdominalTrigger>{},
    this.linkedBowelEventId,
  });

  bool get isEmpty =>
      location == null &&
      quality == null &&
      timing == null &&
      accompaniments.isEmpty &&
      triggers.isEmpty &&
      linkedBowelEventId == null;

  AbdominalDetail copyWith({
    AbdominalLocation? location,
    AbdominalQuality? quality,
    AbdominalTiming? timing,
    Set<AbdominalAccompaniment>? accompaniments,
    Set<AbdominalTrigger>? triggers,
    String? linkedBowelEventId,
    bool clearLocation = false,
    bool clearQuality = false,
    bool clearTiming = false,
    bool clearLinkedBowelEventId = false,
  }) {
    return AbdominalDetail(
      location: clearLocation ? null : (location ?? this.location),
      quality: clearQuality ? null : (quality ?? this.quality),
      timing: clearTiming ? null : (timing ?? this.timing),
      accompaniments: accompaniments ?? this.accompaniments,
      triggers: triggers ?? this.triggers,
      linkedBowelEventId: clearLinkedBowelEventId
          ? null
          : (linkedBowelEventId ?? this.linkedBowelEventId),
    );
  }

  /// Serialization omits empty/null fields so old exports remain
  /// compact and forward-compatible.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (location != null) {
      map['location'] = location!.serializationKey;
    }
    if (quality != null) {
      map['quality'] = quality!.serializationKey;
    }
    if (timing != null) {
      map['timing'] = timing!.serializationKey;
    }
    if (accompaniments.isNotEmpty) {
      map['accompaniments'] =
          accompaniments.map((e) => e.serializationKey).toList();
    }
    if (triggers.isNotEmpty) {
      map['triggers'] = triggers.map((e) => e.serializationKey).toList();
    }
    if (linkedBowelEventId != null) {
      map['linkedBowelEventId'] = linkedBowelEventId;
    }
    return map;
  }

  factory AbdominalDetail.fromMap(Map<String, dynamic> map) {
    final accRaw = map['accompaniments'];
    final trigRaw = map['triggers'];
    return AbdominalDetail(
      location: AbdominalLocation.fromKey(map['location'] as String?),
      quality: AbdominalQuality.fromKey(map['quality'] as String?),
      timing: AbdominalTiming.fromKey(map['timing'] as String?),
      accompaniments: accRaw is List
          ? accRaw
              .whereType<String>()
              .map(AbdominalAccompaniment.fromKey)
              .whereType<AbdominalAccompaniment>()
              .toSet()
          : const <AbdominalAccompaniment>{},
      triggers: trigRaw is List
          ? trigRaw
              .whereType<String>()
              .map(AbdominalTrigger.fromKey)
              .whereType<AbdominalTrigger>()
              .toSet()
          : const <AbdominalTrigger>{},
      linkedBowelEventId: map['linkedBowelEventId'] as String?,
    );
  }
}
