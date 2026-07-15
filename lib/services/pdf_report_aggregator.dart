// Sprint Phase4.A — PDF report aggregator.
//
// Pure function layer: given a Profile and a PdfExportConfig,
// produce a ClinicalReportData. No I/O, no side effects.
//
// This is the "business logic" of what appears in the report.
// The PDF generation service (Phase4.B) is purely presentational —
// it renders whatever this aggregator produces.
//
// Design principles:
//   1. Never expose raw individual events to the report.
//      Aggregate first, render second.
//   2. Truncate long lists to config.topNPerSection to keep the
//      PDF concise (max 3-5 pages typical).
//   3. Return null/empty sections gracefully when data is missing —
//      the PDF renderer will skip empty sections.
//   4. Compose with existing services (weeklyDigestFor) where
//      applicable, but do not depend on them for correctness.
//
// 2026-07-13 — every field reference below was re-verified against the
// real Profile/SymptomEvent/DoseEvent/MedicationOutcome/MedicationDef/
// StructuralEvent/MentalEvent/ActionTaken/MCASDetail shapes in
// models.dart, action_taken.dart and mcas.dart. The original draft of
// this file assumed field names that didn't exist anywhere in the
// codebase (profile.symptomEvents, ActionTaken.recordedAt,
// MedicationOutcome.effectivenessRating, StructuralEvent.region, MCAS
// enum values that don't exist, etc.) — see CLAUDE.md Fase 4 section
// for the full list of what was wrong and why.

import '../models/models.dart';
import '../models/action_taken.dart';
import '../models/mcas.dart';
import '../models/clinical_report_data.dart';
import '../models/pdf_export_config.dart';
import 'symptom_pattern_detector.dart';

/// App version string. Update at each release. Read from pubspec at
/// runtime in future iteration.
const String _kAppVersion = 'beta';

/// Main aggregation entry point.
///
/// Given a Profile with all its historical data and a user-configured
/// PdfExportConfig, produces a ClinicalReportData ready for PDF
/// rendering.
///
/// [now] is injectable for testability; defaults to DateTime.now().
ClinicalReportData aggregateClinicalReport(
  Profile profile,
  PdfExportConfig config, {
  DateTime? now,
}) {
  final generatedAt = now ?? DateTime.now();
  final periodEnd = generatedAt;
  final DateTime periodStart;

  if (config.customStart != null) {
    periodStart = config.customStart!;
  } else if (config.timeRange.days != null) {
    periodStart = periodEnd.subtract(Duration(days: config.timeRange.days!));
  } else {
    // allTime — set to a distant past to include everything
    periodStart = DateTime(2000);
  }

  final metadata = ReportMetadata(
    generatedAt: generatedAt,
    periodStart: periodStart,
    periodEnd: periodEnd,
    rangeLabel: config.timeRange.label,
    appVersion: _kAppVersion,
    locale: 'es',
  );

  return ClinicalReportData(
    metadata: metadata,
    profile: config.enabledSections.contains(PdfSection.patientProfile)
        ? _aggregateProfile(profile)
        : null,
    medications: config.enabledSections.contains(PdfSection.medications)
        ? _aggregateMedications(profile, periodStart, periodEnd)
        : null,
    symptoms: config.enabledSections.contains(PdfSection.symptomsSummary)
        ? _aggregateSymptoms(
            profile,
            periodStart,
            periodEnd,
            topN: config.topNPerSection,
            includePatterns: config.enabledSections.contains(
              PdfSection.symptomsPatterns,
            ),
          )
        : null,
    mcas: config.enabledSections.contains(PdfSection.mcasEvents)
        ? _aggregateMcas(profile, periodStart, periodEnd)
        : null,
    structural: config.enabledSections.contains(PdfSection.structuralEvents)
        ? _aggregateStructural(profile, periodStart, periodEnd)
        : null,
    mentalState: config.enabledSections.contains(PdfSection.mentalState)
        ? _aggregateMentalState(profile, periodStart, periodEnd)
        : null,
    actions: config.enabledSections.contains(PdfSection.actionsEffectiveness)
        ? _aggregateActions(
            profile,
            periodStart,
            periodEnd,
            topN: config.topNPerSection,
          )
        : null,
    patientNotes:
        config.enabledSections.contains(PdfSection.patientNotes) &&
            config.patientNotes.isNotEmpty
        ? PatientNotesSection(text: config.patientNotes)
        : null,
  );
}

/// Builds the compact EmergencyCardData for the C-mini use case.
/// Called separately from the main aggregator (Phase4.D uses this).
EmergencyCardData aggregateEmergencyCard(
  Profile profile, {
  DateTime? now,
  int recentRedFlagDays = 30,
}) {
  final ref = now ?? DateTime.now();
  final cutoff = ref.subtract(Duration(days: recentRedFlagDays));

  // Recent MCAS red flags
  final redFlags = <MCASRedFlagOccurrence>[];
  for (final e in profile.symptomHistory) {
    if (e.mcasDetail == null) continue;
    if (e.timestamp.isBefore(cutoff)) continue;
    final detail = e.mcasDetail!;
    for (final flag in detail.redFlags) {
      redFlags.add(
        MCASRedFlagOccurrence(
          occurredAt: e.timestamp,
          flag: flag,
          label: _mcasRedFlagLabel(flag),
        ),
      );
    }
  }
  redFlags.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

  return EmergencyCardData(
    patientDisplayName: profile.name,
    dateOfBirth: profile.dateOfBirth,
    conditions: _formatConditions(profile),
    activeMedications: _formatActiveMedications(profile),
    allergiesAndTriggers: _formatAllergiesAndTriggers(profile),
    emergencyContacts: _formatEmergencyContacts(profile),
    recentRedFlags: redFlags,
    criticalNotes: _formatCriticalNotes(profile),
  );
}

// ============================================================
// Section aggregators (internal)
// ============================================================

PatientProfileSection _aggregateProfile(Profile profile) {
  return PatientProfileSection(
    displayName: profile.name,
    dateOfBirth: profile.dateOfBirth,
    conditions: _formatConditions(profile),
    allergies: _formatAllergiesAndTriggers(profile),
    emergencyContacts: _formatEmergencyContacts(profile),
  );
}

MedicationSection _aggregateMedications(
  Profile profile,
  DateTime start,
  DateTime end,
) {
  final active = <MedicationEntry>[];
  final inactive = <MedicationEntry>[];

  for (final med in profile.botiquin) {
    // Doses within period for this medication
    final periodDoses = profile.doseHistory
        .where(
          (d) =>
              d.medicationId == med.id &&
              !d.timestamp.isBefore(start) &&
              !d.timestamp.isAfter(end),
        )
        .toList();
    final periodDoseIds = periodDoses.map((d) => d.id).toSet();

    // Outcomes for doses in period
    final periodOutcomes = profile.medicationOutcomes
        .where((o) => periodDoseIds.contains(o.doseId))
        .toList();

    // MedicationOutcome has no standalone "effectiveness rating" — it
    // captures severityBefore/severityAfter on the linked symptom.
    // We derive a 0-4-ish "improvement" score from that delta instead.
    final outcomesWithFollowUp = periodOutcomes
        .where((o) => o.severityAfter != null)
        .toList();
    final improvementScores = outcomesWithFollowUp
        .map((o) => (o.severityBefore - o.severityAfter!).toDouble())
        .toList();
    final meanEffectiveness = improvementScores.isEmpty
        ? null
        : improvementScores.reduce((a, b) => a + b) /
              improvementScores.length;

    // No explicit "adverse reaction" reason exists on OutcomeReason.
    // Heuristic: symptom got worse after taking the medication.
    final hadAdverse = outcomesWithFollowUp.any(
      (o) => o.severityAfter! > o.severityBefore,
    );

    final entry = MedicationEntry(
      name: med.name,
      doseText: _formatDoseText(med),
      // No schedule/adherence tracking exists on MedicationDef yet;
      // left null until that data model lands (see profile_settings.dart
      // note re: Phase4.F).
      adherencePercent: null,
      meanEffectiveness: meanEffectiveness,
      totalDoses: periodDoses.length,
      hadAdverseOutcomes: hadAdverse,
    );

    // MedicationDef has no isActive flag; treat "active" as "used at
    // least once in the reporting period".
    if (periodDoses.isNotEmpty) {
      active.add(entry);
    } else {
      inactive.add(entry);
    }
  }

  return MedicationSection(active: active, inactive: inactive);
}

SymptomSection _aggregateSymptoms(
  Profile profile,
  DateTime start,
  DateTime end, {
  required int topN,
  required bool includePatterns,
}) {
  final periodEvents = profile.symptomHistory
      .where((e) => !e.timestamp.isBefore(start) && !e.timestamp.isAfter(end))
      .toList();

  if (periodEvents.isEmpty) {
    return const SymptomSection();
  }

  // Group by symptom name
  final grouped = <String, List<SymptomEvent>>{};
  for (final e in periodEvents) {
    final key = e.name.trim().isEmpty ? '(sin nombre)' : e.name.trim();
    grouped.putIfAbsent(key, () => []).add(e);
  }

  // Compute aggregations
  final aggregations = <SymptomAggregation>[];
  for (final entry in grouped.entries) {
    final events = entry.value;
    final severityDist = <int, int>{};
    for (final e in events) {
      final sev = e.severity.value;
      severityDist[sev] = (severityDist[sev] ?? 0) + 1;
    }
    final meanSeverity = events.isEmpty
        ? 0.0
        : events.map((e) => e.severity.value).reduce((a, b) => a + b) /
              events.length;

    final timePattern = _timeOfDayPattern(events);

    aggregations.add(
      SymptomAggregation(
        name: entry.key,
        occurrences: events.length,
        severityDistribution: severityDist,
        meanSeverity: meanSeverity,
        timeOfDayPattern: timePattern,
      ),
    );
  }

  // Sort by frequency × mean severity (impact score)
  aggregations.sort((a, b) {
    final scoreA = a.occurrences * (a.meanSeverity + 1);
    final scoreB = b.occurrences * (b.meanSeverity + 1);
    return scoreB.compareTo(scoreA);
  });

  final top = aggregations.take(topN).toList();
  final otherCount = aggregations.length > topN
      ? aggregations.length - topN
      : 0;

  // Days with severe (>= 3) events
  final severeDays = periodEvents
      .where((e) => e.severity.value >= 3)
      .map((e) => _dateKey(e.timestamp))
      .toSet()
      .length;

  // Patterns (only if enabled and enough data)
  final patterns = includePatterns
      ? detectSymptomPatterns(periodEvents)
      : <String>[];

  return SymptomSection(
    topSymptoms: top,
    otherSymptomsCount: otherCount,
    severeSymptomDays: severeDays,
    totalEvents: periodEvents.length,
    detectedPatterns: patterns,
  );
}

MCASSection? _aggregateMcas(Profile profile, DateTime start, DateTime end) {
  final mcasEvents = profile.symptomHistory
      .where(
        (e) =>
            e.mcasDetail != null &&
            !e.timestamp.isBefore(start) &&
            !e.timestamp.isAfter(end),
      )
      .toList();

  if (mcasEvents.isEmpty) return null;

  // Collect red flags
  final redFlags = <MCASRedFlagOccurrence>[];
  for (final e in mcasEvents) {
    for (final flag in e.mcasDetail!.redFlags) {
      redFlags.add(
        MCASRedFlagOccurrence(
          occurredAt: e.timestamp,
          flag: flag,
          label: _mcasRedFlagLabel(flag),
        ),
      );
    }
  }
  redFlags.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

  // Common triggers
  final triggerCounts = <String, int>{};
  for (final e in mcasEvents) {
    for (final tag in e.mcasDetail!.suspectedTriggers) {
      final key = tag.hasLabel
          ? tag.label!.trim()
          : mcasTriggerKindShortLabel(tag.kind);
      triggerCounts[key] = (triggerCounts[key] ?? 0) + 1;
    }
  }
  final commonTriggers = triggerCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // Common reactions
  final reactionCounts = <String, int>{};
  for (final e in mcasEvents) {
    for (final r in e.mcasDetail!.reactionKinds) {
      final label = mcasReactionKindShortLabel(r);
      reactionCounts[label] = (reactionCounts[label] ?? 0) + 1;
    }
  }
  final commonReactions = reactionCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return MCASSection(
    totalEvents: mcasEvents.length,
    redFlags: redFlags,
    commonTriggers: commonTriggers.take(5).map((e) => e.key).toList(),
    commonReactions: commonReactions.take(5).map((e) => e.key).toList(),
  );
}

StructuralSection _aggregateStructural(
  Profile profile,
  DateTime start,
  DateTime end,
) {
  final periodEvents = profile.structuralHistory
      .where((e) => !e.timestamp.isBefore(start) && !e.timestamp.isAfter(end))
      .toList();

  if (periodEvents.isEmpty) return const StructuralSection();

  final byKind = <StructuralEventKind, Map<String, int>>{};
  for (final e in periodEvents) {
    byKind.putIfAbsent(e.kind, () => {});
    final zone = e.zone.trim().isEmpty ? '(sin zona)' : e.zone.trim();
    byKind[e.kind]![zone] = (byKind[e.kind]![zone] ?? 0) + 1;
  }

  final aggregations = byKind.entries.map((entry) {
    final total = entry.value.values.fold<int>(0, (sum, v) => sum + v);
    return StructuralAggregation(
      // StructuralEventKind carries its own Spanish default label.
      kindLabel: entry.key.defaultLabel,
      regionCounts: entry.value,
      occurrences: total,
    );
  }).toList();

  aggregations.sort((a, b) => b.occurrences.compareTo(a.occurrences));

  return StructuralSection(
    byKind: aggregations,
    totalEvents: periodEvents.length,
  );
}

MentalStateSection? _aggregateMentalState(
  Profile profile,
  DateTime start,
  DateTime end,
) {
  final periodEntries = profile.mentalHistory
      .where((e) => !e.timestamp.isBefore(start) && !e.timestamp.isAfter(end))
      .toList();
  final periodMoods = profile.moodHistory
      .where((m) => !m.timestamp.isBefore(start) && !m.timestamp.isAfter(end))
      .toList();

  if (periodEntries.isEmpty && periodMoods.isEmpty) return null;

  // MentalEvent carries a single MentalState (not a set); it already
  // exposes a Spanish label via MentalState.label.
  final stateFreq = <String, int>{};
  for (final e in periodEntries) {
    final label = e.state.label;
    stateFreq[label] = (stateFreq[label] ?? 0) + 1;
  }

  // Valence/arousal derived from MoodEntry.primaryQuadrant — the mood
  // tracker's circumplex model. Separate, richer log from the
  // MentalEvent/MentalState frequencies above.
  double? meanValence;
  double? meanArousal;
  final quadrantFreq = <String, int>{};
  final wordFreq = <String, int>{};
  if (periodMoods.isNotEmpty) {
    var valenceSum = 0.0;
    var arousalSum = 0.0;
    for (final m in periodMoods) {
      valenceSum += m.primaryQuadrant.valenceSign;
      arousalSum += m.primaryQuadrant.arousalSign;
      final qLabel = m.primaryQuadrant.label;
      quadrantFreq[qLabel] = (quadrantFreq[qLabel] ?? 0) + 1;
      for (final word in m.states) {
        wordFreq[word] = (wordFreq[word] ?? 0) + 1;
      }
    }
    meanValence = valenceSum / periodMoods.length;
    meanArousal = arousalSum / periodMoods.length;
  }

  return MentalStateSection(
    meanValence: meanValence,
    meanArousal: meanArousal,
    cognitiveStateFrequency: stateFreq,
    moodQuadrantFrequency: quadrantFreq,
    moodWordFrequency: wordFreq,
    totalEntries: periodEntries.length,
    totalMoodEntries: periodMoods.length,
  );
}

ActionsSection _aggregateActions(
  Profile profile,
  DateTime start,
  DateTime end, {
  required int topN,
}) {
  final actions = profile.actionsHistory
      .where((a) => !a.timestamp.isBefore(start) && !a.timestamp.isAfter(end))
      .toList();

  if (actions.isEmpty) return const ActionsSection();

  // Group by action label
  final grouped = <String, List<ActionTaken>>{};
  for (final a in actions) {
    final key = _actionKeyFor(a);
    grouped.putIfAbsent(key, () => []).add(a);
  }

  final entries = <ActionEffectivenessEntry>[];
  for (final e in grouped.entries) {
    final withRating = e.value
        .where((a) => a.effectivenessRating != null)
        .toList();

    final meanEff = withRating.isEmpty
        ? 0.0
        : withRating
                  .map((a) => _effectivenessScore(a.effectivenessRating!))
                  .reduce((a, b) => a + b) /
              withRating.length;

    // Which linked event types were common
    final linkedCounts = <String, int>{};
    for (final a in e.value) {
      final label = _linkedEventTypeLabel(a.linkedEventType);
      linkedCounts[label] = (linkedCounts[label] ?? 0) + 1;
    }
    final commonLinked = linkedCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    entries.add(
      ActionEffectivenessEntry(
        label: e.key,
        uses: e.value.length,
        meanEffectiveness: meanEff,
        commonLinkedTo: commonLinked.take(3).map((e) => e.key).toList(),
      ),
    );
  }

  // Most effective: sort by mean effectiveness descending, filter uses >= 2
  final effective = entries.where((e) => e.uses >= 2).toList()
    ..sort((a, b) => b.meanEffectiveness.compareTo(a.meanEffectiveness));

  // Least effective: those with mean below 2 (out of 4) and uses >= 2
  final ineffective =
      entries.where((e) => e.uses >= 2 && e.meanEffectiveness < 2).toList()
        ..sort((a, b) => a.meanEffectiveness.compareTo(b.meanEffectiveness));

  return ActionsSection(
    mostEffective: effective.take(topN).toList(),
    leastEffective: ineffective.take(topN ~/ 2).toList(),
    totalActions: actions.length,
  );
}

// ============================================================
// Helpers — labeling and formatting
// ============================================================

Map<String, int> _timeOfDayPattern(List<SymptomEvent> events) {
  final counts = <String, int>{
    'morning': 0,
    'afternoon': 0,
    'evening': 0,
    'night': 0,
  };
  for (final e in events) {
    final h = e.timestamp.hour;
    if (h >= 5 && h < 12) {
      counts['morning'] = counts['morning']! + 1;
    } else if (h >= 12 && h < 18) {
      counts['afternoon'] = counts['afternoon']! + 1;
    } else if (h >= 18 && h < 22) {
      counts['evening'] = counts['evening']! + 1;
    } else {
      counts['night'] = counts['night']! + 1;
    }
  }
  return counts;
}

String _dateKey(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

String _mcasRedFlagLabel(MCASRedFlag flag) => switch (flag) {
  MCASRedFlag.throatTightness => 'Opresión en la garganta',
  MCASRedFlag.breathingDifficulty => 'Dificultad para respirar',
  MCASRedFlag.tongueSwelling => 'Hinchazón de la lengua',
  MCASRedFlag.faintness => 'Desvanecimiento / mareo severo',
  MCASRedFlag.drasticBPChange => 'Cambio drástico de presión arterial',
  MCASRedFlag.confusion => 'Confusión',
};

/// EffectivenessRating is an ordinal enum with no built-in numeric value
/// (unlike SymptomSeverity). Map it onto the same 0-4 scale the report
/// schema documents (4 = best outcome).
double _effectivenessScore(EffectivenessRating r) => switch (r) {
  EffectivenessRating.muchRelief => 4,
  EffectivenessRating.someRelief => 3,
  EffectivenessRating.partialReliefThenReturned => 2,
  EffectivenessRating.noChange => 1,
  EffectivenessRating.worse => 0,
};

String _linkedEventTypeLabel(LinkedEventType t) => switch (t) {
  LinkedEventType.symptom => 'Síntoma',
  LinkedEventType.bowel => 'Evento intestinal',
  LinkedEventType.hemorrhoidal => 'Sangrado hemorroidal',
  LinkedEventType.fever => 'Fiebre',
};

String _actionKeyFor(ActionTaken action) {
  if (action.kind == ActionKind.custom &&
      action.customLabel != null &&
      action.customLabel!.trim().isNotEmpty) {
    return action.customLabel!.trim();
  }
  return switch (action.kind) {
    ActionKind.medication => 'Medicación',
    ActionKind.rest => 'Descanso',
    ActionKind.hydration => 'Hidratación',
    ActionKind.breathing => 'Respiración / regulación',
    ActionKind.heat => 'Aplicación de calor',
    ActionKind.cold => 'Aplicación de frío',
    ActionKind.elevation => 'Elevación',
    ActionKind.sensoryReduction => 'Reducción sensorial',
    ActionKind.socialWithdrawal => 'Retiro social',
    ActionKind.food => 'Alimentación',
    ActionKind.movement => 'Movimiento / actividad',
    ActionKind.nothing => 'No se tomó acción',
    ActionKind.custom => 'Acción personalizada',
  };
}

/// Formats a MedicationDef's strength/unit/form into a short display
/// string (e.g. "500 mg — comprimido"). MedicationDef has no separate
/// "doseText" field — this is derived from its numeric fields.
String _formatDoseText(MedicationDef med) {
  final strength = med.strength == med.strength.roundToDouble()
      ? med.strength.round().toString()
      : med.strength.toString();
  final buf = StringBuffer('$strength ${med.unit}'.trim());
  if (med.form.isNotEmpty) {
    buf.write(' — ${med.form}');
  }
  return buf.toString();
}

// ============================================================
// Profile field extractors
// ============================================================

List<String> _formatConditions(Profile profile) {
  return List<String>.from(profile.conditions);
}

List<String> _formatAllergiesAndTriggers(Profile profile) {
  return List<String>.from(profile.allergies);
}

List<String> _formatEmergencyContacts(Profile profile) {
  return List<String>.from(profile.emergencyContacts);
}

List<String> _formatActiveMedications(Profile profile) {
  // No isActive flag on MedicationDef; the emergency card shows the
  // whole Botiquín (medications the patient keeps on hand), since
  // "currently active" isn't a modeled concept yet.
  return profile.botiquin
      .map((m) => '${m.name} — ${_formatDoseText(m)}')
      .toList();
}

List<String> _formatCriticalNotes(Profile profile) {
  // Optional field on Profile. Return empty if absent.
  return const [];
}
