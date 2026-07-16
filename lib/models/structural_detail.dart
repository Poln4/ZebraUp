// Rediseño de dolor estructural (docs/design_decisions/symptom_detail_laters.md §12)
//
// Typed detail layer for the structural/musculoskeletal pain funnel.
// Unlike headache/fatigue/abdominal, this is NOT attached to a
// SymptomEvent — it attaches to a StructuralEvent (zone/kind/type based,
// no severity of its own until this sprint). Completing this funnel is
// the DEFAULT path when logging pain in a zone with no saved history;
// it replaces picking a specific clinical `type` for that entry. The
// resulting StructuralEvent always gets
// `kind = StructuralEventKind.painWithoutClearCause` +
// `type = 'unclear_structural_cause'` (see lib/models/models.dart) — the
// "Ya sé qué es" shortcut bypasses this whole funnel in favor of the
// classic kind→type picker for users who already know the clinical term.
//
// 4 single-select groups, 18 chips total (Morren 2009 ≤20 rule, §2.7).
// Chip content (labels/definitions) lives in assets/symptom_definitions.json
// under the "structural" key, resolved via SymptomDefinitionsService —
// same mechanism already used for headache/fatigue/abdominal_pain.

/// Lateralidad — de qué lado está el dolor. Implementa el `BodySide`
/// anticipado en un comentario de models.dart (kBodyZones) desde F6.b.
enum StructuralLaterality {
  left('left'),
  right('right'),
  both('both'),
  diffuseCentral('diffuse_central');

  final String serializationKey;
  const StructuralLaterality(this.serializationKey);

  static StructuralLaterality? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Carácter del dolor. "Agudo/punzante" y "sensación de corte" se
/// mantienen separados a pedido explícito — suficientemente distintos
/// como para no fusionarse (§12.4).
enum StructuralPainCharacter {
  sharpStabbing('sharp_stabbing'),
  cuttingSensation('cutting_sensation'),
  electricShocks('electric_shocks'),
  tingling('tingling'),
  dullDiffuse('dull_diffuse'),
  burning('burning');

  final String serializationKey;
  const StructuralPainCharacter(this.serializationKey);

  static StructuralPainCharacter? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Antecedente. `knownCondition` es el disparador de la oferta post-save
/// "guardar esto como algo que ya conozco" (§12.6) cuando la zona no
/// tiene todavía una StructuralZoneHistoryEntry guardada.
enum StructuralAntecedent {
  recentExertion('recent_exertion'),
  delayedExertion('delayed_exertion'),
  trauma('trauma'),
  knownCondition('known_condition'),
  noSpecificAntecedent('no_specific_antecedent');

  final String serializationKey;
  const StructuralAntecedent(this.serializationKey);

  static StructuralAntecedent? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Mecánica — mismo shape que "Patrón postural" ya usado en cefalea.
enum StructuralMechanics {
  worseWithMovement('worse_with_movement'),
  presentAtRest('present_at_rest'),
  bothMovementRest('both_movement_rest');

  final String serializationKey;
  const StructuralMechanics(this.serializationKey);

  static StructuralMechanics? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// "¿Distinto a lo usual?" — solo se usa en el quick-log de zonas con
/// historial conocido (§12.6), no en el embudo de 4 grupos.
enum StructuralComparisonToUsual {
  worse('worse'),
  normal('normal'),
  better('better');

  final String serializationKey;
  const StructuralComparisonToUsual(this.serializationKey);

  static StructuralComparisonToUsual? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// §12.6b — Origen del sangrado/moretón. Eje que Kumskova et al. 2023
/// marca como clínicamente notable para hematomas musculares: 13% de
/// pacientes EDS tuvo hematomas musculares "espontáneos, sin trauma" —
/// el subgrupo más severo que mide el estudio.
enum BleedingOnset {
  spontaneous('spontaneous'),
  trauma('trauma');

  final String serializationKey;
  const BleedingOnset(this.serializationKey);

  static BleedingOnset? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// §12.6b — Gravedad adaptada del ISTH-BAT (0-4), en vez de reusar
/// SymptomSeverity genérico. Reemplaza la escala 0-4 genérica que el
/// propio diseño (docs/design_decisions/symptom_detail_layers.md
/// §12.6b) señala como insuficiente para tejido blando — validado más
/// allá de EDS (Gooijer et al. 2024 en osteogénesis imperfecta).
enum BleedingSeverity {
  none('none'),
  noted('noted'),
  consultedOnly('consulted_only'),
  treated('treated'),
  severe('severe');

  final String serializationKey;
  const BleedingSeverity(this.serializationKey);

  static BleedingSeverity? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// §12.6b — Detalle estructurado para eventos `StructuralEventKind.softTissue`
/// (excepto `type == 'burn'`, que no es un fenómeno de sangrado). Reemplaza
/// el embudo de 4 grupos de dolor (`StructuralDetail`) para este kind — ver
/// docs/design_decisions/symptom_detail_layers.md §12.6b.
class StructuralBleedingDetail {
  final BleedingOnset? onset;
  final BleedingSeverity? severity;

  const StructuralBleedingDetail({this.onset, this.severity});

  bool get isEmpty => onset == null && severity == null;

  StructuralBleedingDetail copyWith({
    BleedingOnset? onset,
    BleedingSeverity? severity,
    bool clearOnset = false,
    bool clearSeverity = false,
  }) {
    return StructuralBleedingDetail(
      onset: clearOnset ? null : (onset ?? this.onset),
      severity: clearSeverity ? null : (severity ?? this.severity),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (onset != null) map['onset'] = onset!.serializationKey;
    if (severity != null) map['severity'] = severity!.serializationKey;
    return map;
  }

  factory StructuralBleedingDetail.fromMap(Map<String, dynamic> map) {
    return StructuralBleedingDetail(
      onset: BleedingOnset.fromKey(map['onset'] as String?),
      severity: BleedingSeverity.fromKey(map['severity'] as String?),
    );
  }
}

/// Structured detail attached to a StructuralEvent when the user
/// completes the 4-group funnel (as opposed to "Ya sé qué es").
///
/// All fields are optional. `isEmpty` returns true when the user
/// completed the flow without marking anything — the caller treats
/// that as equivalent to skipping.
class StructuralDetail {
  final StructuralLaterality? laterality;
  final StructuralPainCharacter? painCharacter;
  final StructuralAntecedent? antecedent;
  final StructuralMechanics? mechanics;

  const StructuralDetail({
    this.laterality,
    this.painCharacter,
    this.antecedent,
    this.mechanics,
  });

  bool get isEmpty =>
      laterality == null &&
      painCharacter == null &&
      antecedent == null &&
      mechanics == null;

  StructuralDetail copyWith({
    StructuralLaterality? laterality,
    StructuralPainCharacter? painCharacter,
    StructuralAntecedent? antecedent,
    StructuralMechanics? mechanics,
    bool clearLaterality = false,
    bool clearPainCharacter = false,
    bool clearAntecedent = false,
    bool clearMechanics = false,
  }) {
    return StructuralDetail(
      laterality: clearLaterality ? null : (laterality ?? this.laterality),
      painCharacter: clearPainCharacter
          ? null
          : (painCharacter ?? this.painCharacter),
      antecedent: clearAntecedent ? null : (antecedent ?? this.antecedent),
      mechanics: clearMechanics ? null : (mechanics ?? this.mechanics),
    );
  }

  /// Serialization omits empty/null fields so old exports remain
  /// compact and forward-compatible.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (laterality != null) {
      map['laterality'] = laterality!.serializationKey;
    }
    if (painCharacter != null) {
      map['painCharacter'] = painCharacter!.serializationKey;
    }
    if (antecedent != null) {
      map['antecedent'] = antecedent!.serializationKey;
    }
    if (mechanics != null) {
      map['mechanics'] = mechanics!.serializationKey;
    }
    return map;
  }

  factory StructuralDetail.fromMap(Map<String, dynamic> map) {
    return StructuralDetail(
      laterality: StructuralLaterality.fromKey(map['laterality'] as String?),
      painCharacter: StructuralPainCharacter.fromKey(
        map['painCharacter'] as String?,
      ),
      antecedent: StructuralAntecedent.fromKey(map['antecedent'] as String?),
      mechanics: StructuralMechanics.fromKey(map['mechanics'] as String?),
    );
  }
}
