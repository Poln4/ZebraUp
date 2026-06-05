enum InteractionLevel { info, warning, severe }

class InteractionRule {
  /// Lowercase substrings; ALL must appear among today's meds for the rule to fire.
  final List<String> medicationKeys;
  /// Lowercase substrings; if provided, at least ONE must match patient conditions.
  final List<String>? requiredConditions;
  final InteractionLevel level;
  final String message;
  /// Optional clinical reference (future: link out to PubMed/DailyMed).
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
    final medsOk = medicationKeys.every((key) => medsLower.any((m) => m.contains(key)));
    if (!medsOk) return false;
    if (requiredConditions == null || requiredConditions!.isEmpty) return true;
    return requiredConditions!.any((c) => conditionsLower.any((dx) => dx.contains(c)));
  }
}

/// Rules library. Move to JSON asset once it grows past ~20 entries.
const List<InteractionRule> kInteractionRules = [
  InteractionRule(
    medicationKeys: ['hierro', 'vitamina c'],
    level: InteractionLevel.info,
    message: '💡 SINERGIA: La Vitamina C potencia la absorción del hierro.',
  ),
  InteractionRule(
    medicationKeys: ['duloxetina', 'ibuprofeno'],
    requiredConditions: ['eds', 'adenomiosis', 'sangrado', 'menorragia'],
    level: InteractionLevel.severe,
    message: '🚨 ALERTA HEMORRÁGICA: Duloxetina + AINE elevan el riesgo de sangrado.',
    reference: 'SNRI + NSAID class warning; relevant en EDS y adenomiosis.',
  ),
];

class InteractionEngine {
  static List<InteractionRule> evaluate({
    required List<String> medicationsToday,
    required List<String> conditions,
  }) {
    final meds = medicationsToday.map((m) => m.toLowerCase()).toList();
    final conds = conditions.map((c) => c.toLowerCase()).toList();
    return kInteractionRules
        .where((r) => r.matches(medsLower: meds, conditionsLower: conds))
        .toList();
  }
}