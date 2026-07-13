// =============================================================================
// Interaction engine — condition-aware drug interaction rules.
//
// Phase-1 rewrite notes:
//   • Single source of truth. The duplicate `InteractionRule` definition that
//     used to live in models.dart is gone.
//   • Rules table expanded along the rare-disease wedge — most of these are
//     class-level interactions that mainstream interaction checkers either
//     don't flag or flag generically. The zebraupp value-add is making them
//     condition-aware (EDS, dysautonomia/POTS, adenomiosis, MCAS).
//   • Rules read meds by substring on the active ingredient + brand name; a
//     rule fires when ALL `medicationKeys` substrings appear among today's
//     dose names AND at least one of `requiredConditions` (if any) matches
//     the patient's conditions.
//   • These rules are NOT medical advice. UI surfaces should label them as
//     informative flags and link out to PubMed / DailyMed / CIMA where
//     possible. The `reference` field is a future hook for that.
//
// To add a rule: append to `kInteractionRules`. Once we cross ~30 entries,
// migrate to a JSON asset under assets/interactions.json.
// =============================================================================

enum InteractionLevel { info, warning, severe }

class InteractionRule {
  /// Lowercase substrings; ALL must appear among today's meds for the rule
  /// to fire. Match is by substring so 'ibuprofeno' matches 'Ibuprofeno 600',
  /// 'IBUPROFENO', and 'Ibuprofeno arginina'.
  final List<String> medicationKeys;

  /// Lowercase substrings; if provided, at least ONE must appear in the
  /// patient's conditions for the rule to fire. Null/empty = applies to all.
  final List<String>? requiredConditions;

  final InteractionLevel level;
  final String message;

  /// Optional clinical reference. Phase-2 will turn this into a tap-through
  /// to PubMed / DailyMed / CIMA.
  final String? reference;

  const InteractionRule({
    required this.medicationKeys,
    this.requiredConditions,
    required this.level,
    required this.message,
    this.reference,
  });

  bool matches({
    required List<String> medsLower,
    required List<String> conditionsLower,
  }) {
    final medsOk = medicationKeys.every(
      (key) => medsLower.any((m) => m.contains(key)),
    );
    if (!medsOk) return false;
    if (requiredConditions == null || requiredConditions!.isEmpty) return true;
    return requiredConditions!.any(
      (c) => conditionsLower.any((dx) => dx.contains(c)),
    );
  }
}

/// Curated rules. Order matters only for display — UI sorts by `level` desc.
const List<InteractionRule> kInteractionRules = [
  // ---------------------------------------------------------------------------
  // Absorption: iron + things that block or boost it
  // ---------------------------------------------------------------------------
  InteractionRule(
    medicationKeys: ['hierro', 'vitamina c'],
    level: InteractionLevel.info,
    message:
        '💡 SINERGIA: La vitamina C reduce el hierro a Fe²⁺ y potencia su absorción. '
        'Tomar juntos en ayunas para máximo efecto.',
  ),
  InteractionRule(
    medicationKeys: ['hierro', 'calcio'],
    level: InteractionLevel.warning,
    message:
        '⚠️ BLOQUEO DE ABSORCIÓN: El calcio interfiere con la captación de hierro. '
        'Separar al menos 2 horas entre tomas.',
  ),
  InteractionRule(
    medicationKeys: ['hierro', 'omeprazol'],
    level: InteractionLevel.warning,
    message:
        '⚠️ ABSORCIÓN REDUCIDA: Los IBP suben el pH gástrico y reducen la '
        'absorción de hierro hasta un 70%. Considerar bisglicinato de hierro '
        '(menos pH-dependiente) o tomar lejos del IBP.',
  ),
  InteractionRule(
    medicationKeys: ['hierro', 'zinc'],
    level: InteractionLevel.info,
    message:
        '💡 COMPETENCIA DE MINERALES: Hierro y zinc compiten por el mismo '
        'transportador (DMT1). Separar tomas si es posible.',
  ),
  InteractionRule(
    medicationKeys: ['levotiroxina', 'hierro'],
    level: InteractionLevel.warning,
    message:
        '⚠️ ABSORCIÓN DE LEVOTIROXINA: El hierro forma quelatos con la '
        'levotiroxina. Tomar la levotiroxina al menos 4h antes que el hierro.',
  ),
  InteractionRule(
    medicationKeys: ['levotiroxina', 'calcio'],
    level: InteractionLevel.warning,
    message:
        '⚠️ ABSORCIÓN DE LEVOTIROXINA: El calcio interfiere. Separar al menos 4h.',
  ),

  // ---------------------------------------------------------------------------
  // Bleeding risk (relevant for EDS / adenomiosis / menorrhagia)
  // ---------------------------------------------------------------------------
  InteractionRule(
    medicationKeys: ['duloxetina', 'ibuprofeno'],
    requiredConditions: ['eds', 'adenomiosis', 'sangrado', 'menorragia', 'sed'],
    level: InteractionLevel.severe,
    message:
        '🚨 ALERTA HEMORRÁGICA: La duloxetina (ISRSN) inhibe la recaptación '
        'de serotonina plaquetaria. Combinada con un AINE como ibuprofeno '
        'multiplica el riesgo de sangrado, ya elevado en EDS y adenomiosis.',
    reference:
        'SNRI + NSAID class warning. Relevante en EDS/SED y adenomiosis.',
  ),
  InteractionRule(
    medicationKeys: ['duloxetina', 'naproxeno'],
    requiredConditions: ['eds', 'adenomiosis', 'sangrado', 'menorragia', 'sed'],
    level: InteractionLevel.severe,
    message:
        '🚨 ALERTA HEMORRÁGICA: Duloxetina + naproxeno tienen el mismo riesgo '
        'que con ibuprofeno. Riesgo elevado en EDS/adenomiosis.',
  ),
  InteractionRule(
    medicationKeys: ['sertralina', 'ibuprofeno'],
    requiredConditions: ['eds', 'adenomiosis', 'sangrado', 'menorragia', 'sed'],
    level: InteractionLevel.warning,
    message:
        '⚠️ Riesgo hemorrágico: ISRS + AINE eleva el riesgo de sangrado, '
        'especialmente en EDS y adenomiosis.',
  ),
  InteractionRule(
    medicationKeys: ['ibuprofeno', 'aspirina'],
    level: InteractionLevel.warning,
    message:
        '⚠️ DOBLE AINE: Combinar AINEs aumenta riesgo gastrointestinal y '
        'hemorrágico sin beneficio analgésico claro.',
  ),

  // ---------------------------------------------------------------------------
  // Adenomiosis / menstrual context
  // ---------------------------------------------------------------------------
  InteractionRule(
    medicationKeys: ['ibuprofeno'],
    requiredConditions: ['adenomiosis', 'menorragia', 'sangrado abundante'],
    level: InteractionLevel.info,
    message:
        '💡 NOTA: El ibuprofeno puede reducir el sangrado menstrual abundante '
        'al disminuir prostaglandinas, pero también afecta función plaquetaria. '
        'Discutir balance con tu equipo médico.',
  ),

  // ---------------------------------------------------------------------------
  // Dysautonomia / POTS
  // ---------------------------------------------------------------------------
  InteractionRule(
    medicationKeys: ['fludrocortisona', 'ibuprofeno'],
    requiredConditions: ['pots', 'disautonomia', 'disautonomía'],
    level: InteractionLevel.warning,
    message:
        '⚠️ ANTAGONISMO: Los AINEs retienen sodio pero antagonizan el efecto '
        'mineralocorticoide de la fludrocortisona, y elevan el riesgo de '
        'úlcera GI con el corticoide.',
  ),
  InteractionRule(
    medicationKeys: ['midodrina', 'pseudoefedrina'],
    requiredConditions: ['pots', 'disautonomia', 'disautonomía'],
    level: InteractionLevel.severe,
    message:
        '🚨 HIPERTENSIÓN: Doble agonista alfa. Riesgo de crisis hipertensiva '
        'aún en pacientes POTS que normalmente tienden a hipotensión.',
  ),
  InteractionRule(
    medicationKeys: ['propranolol', 'midodrina'],
    requiredConditions: ['pots', 'disautonomia', 'disautonomía'],
    level: InteractionLevel.info,
    message:
        '💡 EFECTOS OPUESTOS: Beta-bloqueante + agonista alfa actúan en '
        'direcciones contrarias. Combinación clínicamente válida en algunos '
        'protocolos POTS pero requiere monitorización estrecha.',
  ),

  // ---------------------------------------------------------------------------
  // Serotonin syndrome risk
  // ---------------------------------------------------------------------------
  InteractionRule(
    medicationKeys: ['duloxetina', 'tramadol'],
    level: InteractionLevel.severe,
    message:
        '🚨 SÍNDROME SEROTONINÉRGICO: Duloxetina + tramadol elevan riesgo de '
        'síndrome serotoninérgico. Vigilar agitación, hipertermia, mioclonus.',
  ),
  InteractionRule(
    medicationKeys: ['sertralina', 'tramadol'],
    level: InteractionLevel.severe,
    message: '🚨 SÍNDROME SEROTONINÉRGICO: ISRS + tramadol — riesgo elevado.',
  ),
  InteractionRule(
    medicationKeys: ['sumatriptán', 'duloxetina'],
    level: InteractionLevel.warning,
    message:
        '⚠️ Riesgo de síndrome serotoninérgico con triptanes + ISRSN. '
        'Vigilar síntomas en las 24h post-toma.',
  ),

  // ---------------------------------------------------------------------------
  // MCAS / antihistamine context
  // ---------------------------------------------------------------------------
  InteractionRule(
    medicationKeys: ['cetirizina', 'difenhidramina'],
    requiredConditions: ['mcas', 'mastocitos'],
    level: InteractionLevel.info,
    message:
        '💡 DOBLE H1: Combinar antihistamínicos H1 es práctica común en MCAS '
        'cuando uno no basta. Difenhidramina es más sedante; cetirizina diurna.',
  ),

  // ---------------------------------------------------------------------------
  // Hormonal / Dienogest
  // ---------------------------------------------------------------------------
  InteractionRule(
    medicationKeys: ['dienogest', 'rifampicina'],
    level: InteractionLevel.severe,
    message:
        '🚨 INDUCCIÓN ENZIMÁTICA: Rifampicina reduce la eficacia del dienogest. '
        'Considerar método anticonceptivo de barrera adicional.',
  ),
];

class InteractionEngine {
  /// Returns the rules that fire given today's medication names and the
  /// patient's condition list. Sorted by severity (severe first).
  static List<InteractionRule> evaluate({
    required List<String> medicationsToday,
    required List<String> conditions,
  }) {
    final meds = medicationsToday.map((m) => m.toLowerCase()).toList();
    final conds = conditions.map((c) => c.toLowerCase()).toList();
    final hits = kInteractionRules
        .where((r) => r.matches(medsLower: meds, conditionsLower: conds))
        .toList();
    hits.sort((a, b) => b.level.index.compareTo(a.level.index));
    return hits;
  }
}
