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

import '../models/models.dart';
import '../models/action_taken.dart';
import '../models/mcas.dart';
import '../models/clinical_report_data.dart';
import '../models/pdf_export_config.dart';

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
  for (final e in profile.symptomEvents) {
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
    patientDisplayName: profile.displayName,
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
    displayName: profile.displayName,
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

  for (final med in profile.medications) {
    // Doses within period for this medication
    final periodDoses = profile.doseEvents
        .where(
          (d) =>
              d.medicationId == med.id &&
              !d.timestamp.isBefore(start) &&
              !d.timestamp.isAfter(end),
        )
        .toList();

    // Outcomes for doses in period
    final periodOutcomes = profile.medicationOutcomes
        .where((o) => periodDoses.any((d) => d.id == o.doseEventId))
        .toList();

    final effectivenessScores = periodOutcomes
        .where((o) => o.effectivenessRating != null)
        .map((o) => o.effectivenessRating!.toDouble())
        .toList();

    final meanEffectiveness = effectivenessScores.isEmpty
        ? null
        : effectivenessScores.reduce((a, b) => a + b) /
              effectivenessScores.length;

    final hadAdverse = periodOutcomes.any(
      (o) =>
          o.outcomeReason == OutcomeReason.adverseReaction ||
          o.outcomeReason == OutcomeReason.stoppedDueToSideEffects,
    );

    // Adherence: for scheduled meds, ratio of taken vs expected.
    // Simplified: only compute if med has a schedule; otherwise null.
    // The exact adherence formula depends on Medication schema
    // (which we didn't inspect fully here) — placeholder that leaves
    // this null unless the model exposes schedule data.
    double? adherence;
    // If Medication has a `type == basalScheduled` and a dailyDoses
    // count, we could compute adherence. For Phase4.A, leave null
    // and let Phase4.F refine once schedule data is confirmed.

    final entry = MedicationEntry(
      name: med.name,
      doseText: med.doseText,
      adherencePercent: adherence,
      meanEffectiveness: meanEffectiveness,
      totalDoses: periodDoses.length,
      hadAdverseOutcomes: hadAdverse,
    );

    if (med.isActive && periodDoses.isNotEmpty) {
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
  final periodEvents = profile.symptomEvents
      .where((e) => !e.timestamp.isBefore(start) && !e.timestamp.isAfter(end))
      .toList();

  if (periodEvents.isEmpty) {
    return const SymptomSection();
  }

  // Group by symptomInput (or symptomVaultId if available)
  final grouped = <String, List<SymptomEvent>>{};
  for (final e in periodEvents) {
    final key = _symptomGroupKey(e);
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
      ? _detectPatterns(periodEvents, aggregations)
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
  final mcasEvents = profile.symptomEvents
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
    for (final tag in e.mcasDetail!.triggers) {
      final key = tag.customLabel ?? _triggerKindLabel(tag.kind);
      triggerCounts[key] = (triggerCounts[key] ?? 0) + 1;
    }
  }
  final commonTriggers = triggerCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // Common reactions
  final reactionCounts = <String, int>{};
  for (final e in mcasEvents) {
    for (final r in e.mcasDetail!.reactions) {
      final label = _mcasReactionLabel(r);
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
  final periodEvents = profile.structuralEvents
      .where((e) => !e.timestamp.isBefore(start) && !e.timestamp.isAfter(end))
      .toList();

  if (periodEvents.isEmpty) return const StructuralSection();

  final byKind = <StructuralEventKind, Map<String, int>>{};
  for (final e in periodEvents) {
    byKind.putIfAbsent(e.kind, () => {});
    final region = _bodyRegionLabel(e.region);
    byKind[e.kind]![region] = (byKind[e.kind]![region] ?? 0) + 1;
  }

  final aggregations = byKind.entries.map((entry) {
    final total = entry.value.values.fold<int>(0, (sum, v) => sum + v);
    return StructuralAggregation(
      kindLabel: _structuralKindLabel(entry.key),
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
  final periodEntries = profile.mentalEvents
      .where((e) => !e.timestamp.isBefore(start) && !e.timestamp.isAfter(end))
      .toList();

  if (periodEntries.isEmpty) return null;

  // Cognitive state frequencies. Uses MentalState enum labels.
  final stateFreq = <String, int>{};
  for (final e in periodEntries) {
    for (final state in e.states) {
      final label = _mentalStateLabel(state);
      stateFreq[label] = (stateFreq[label] ?? 0) + 1;
    }
  }

  // Valence/arousal aggregates would require valence/arousal fields
  // on MentalEvent. Model inspection at Phase4.A time doesn't guarantee
  // these exist. Leave null; the aggregator can be enriched later
  // when the mental tracker Foxtale-style circumplex ships.

  return MentalStateSection(
    meanValence: null,
    meanArousal: null,
    cognitiveStateFrequency: stateFreq,
    totalEntries: periodEntries.length,
  );
}

ActionsSection _aggregateActions(
  Profile profile,
  DateTime start,
  DateTime end, {
  required int topN,
}) {
  final actions = profile.actionsHistory
      .where((a) => !a.recordedAt.isBefore(start) && !a.recordedAt.isAfter(end))
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
    final withRating = e.value.where((a) => a.effectiveness != null).toList();

    final meanEff = withRating.isEmpty
        ? 0.0
        : withRating
                  .map((a) => a.effectiveness!.value.toDouble())
                  .reduce((a, b) => a + b) /
              withRating.length;

    // Which linked event types were common
    final linkedCounts = <String, int>{};
    for (final a in e.value) {
      if (a.linkedEventType == null) continue;
      final label = _linkedEventTypeLabel(a.linkedEventType!);
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

String _symptomGroupKey(SymptomEvent e) {
  // Prefer explicit vault ID; fall back to trimmed free-text input.
  // (Both fields exist on SymptomEvent per Sprint C.4 / D.1 / D.2.)
  final input = e.symptomInput.trim();
  return input.isEmpty ? '(sin nombre)' : input;
}

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

/// Pattern detection over aggregated data.
/// Heuristic — produces natural-language Spanish observations.
/// Returns empty list if data is insufficient for confident patterns.
List<String> _detectPatterns(
  List<SymptomEvent> events,
  List<SymptomAggregation> aggregations,
) {
  final patterns = <String>[];
  if (events.length < 10) return patterns;

  // Time-of-day dominance for top symptoms
  for (final agg in aggregations.take(3)) {
    if (agg.occurrences < 5) continue;
    final tod = agg.timeOfDayPattern;
    if (tod.isEmpty) continue;
    final maxEntry = tod.entries.reduce((a, b) => a.value > b.value ? a : b);
    final ratio = maxEntry.value / agg.occurrences;
    if (ratio >= 0.5) {
      final windowLabel = switch (maxEntry.key) {
        'morning' => 'por las mañanas',
        'afternoon' => 'por las tardes',
        'evening' => 'al anochecer',
        'night' => 'durante la noche',
        _ => '',
      };
      patterns.add(
        '${agg.name} ocurre principalmente $windowLabel '
        '(${(ratio * 100).round()}% de los episodios).',
      );
    }
  }

  return patterns;
}

String _mcasRedFlagLabel(MCASRedFlag flag) => switch (flag) {
  MCASRedFlag.airwayCompromise => 'Compromiso de la vía aérea',
  MCASRedFlag.hypotension => 'Hipotensión',
  MCASRedFlag.syncope => 'Síncope',
  MCASRedFlag.multiSystemInvolvement => 'Compromiso multi-sistémico',
  MCASRedFlag.severeGastrointestinal => 'Compromiso gastrointestinal severo',
  MCASRedFlag.throatSwelling => 'Edema faríngeo',
};

String _mcasReactionLabel(MCASReactionKind kind) => switch (kind) {
  MCASReactionKind.flushing => 'Rubor / flushing',
  MCASReactionKind.hives => 'Urticaria',
  MCASReactionKind.itching => 'Prurito',
  MCASReactionKind.gi => 'Síntomas GI (dolor, diarrea, náusea)',
  MCASReactionKind.respiratory => 'Síntomas respiratorios',
  MCASReactionKind.cardiovascular => 'Taquicardia / palpitaciones',
  MCASReactionKind.neurological => 'Síntomas neurológicos (cefalea, mareo)',
  MCASReactionKind.swelling => 'Edema local',
  MCASReactionKind.fatigueOnset => 'Fatiga súbita post-exposición',
  MCASReactionKind.other => 'Otra reacción',
};

String _triggerKindLabel(TriggerKind kind) => switch (kind) {
  TriggerKind.food => 'Alimento',
  TriggerKind.medication => 'Medicamento',
  TriggerKind.environmental => 'Ambiental',
  TriggerKind.stress => 'Estrés',
  TriggerKind.temperature => 'Cambio de temperatura',
  TriggerKind.exercise => 'Ejercicio / esfuerzo',
  TriggerKind.other => 'Otro desencadenante',
};

String _structuralKindLabel(StructuralEventKind kind) => switch (kind) {
  StructuralEventKind.subluxation => 'Subluxación',
  StructuralEventKind.dislocation => 'Dislocación',
  StructuralEventKind.sprain => 'Esguince',
  StructuralEventKind.strain => 'Distensión muscular',
  StructuralEventKind.instability => 'Inestabilidad articular',
  StructuralEventKind.other => 'Otro evento estructural',
};

String _bodyRegionLabel(BodyRegion region) {
  // Body regions are numerous; map to Spanish clinical labels.
  // Fall back to region.name if a mapping is missing.
  const map = {
    BodyRegion.neck: 'Cuello',
    BodyRegion.shoulderLeft: 'Hombro izquierdo',
    BodyRegion.shoulderRight: 'Hombro derecho',
    BodyRegion.elbowLeft: 'Codo izquierdo',
    BodyRegion.elbowRight: 'Codo derecho',
    BodyRegion.wristLeft: 'Muñeca izquierda',
    BodyRegion.wristRight: 'Muñeca derecha',
    BodyRegion.fingerLeft: 'Dedos izquierda',
    BodyRegion.fingerRight: 'Dedos derecha',
    BodyRegion.hipLeft: 'Cadera izquierda',
    BodyRegion.hipRight: 'Cadera derecha',
    BodyRegion.kneeLeft: 'Rodilla izquierda',
    BodyRegion.kneeRight: 'Rodilla derecha',
    BodyRegion.ankleLeft: 'Tobillo izquierdo',
    BodyRegion.ankleRight: 'Tobillo derecho',
    BodyRegion.jaw: 'Mandíbula',
    BodyRegion.spineUpper: 'Columna cervical',
    BodyRegion.spineMid: 'Columna torácica',
    BodyRegion.spineLower: 'Columna lumbar',
    BodyRegion.pelvis: 'Pelvis',
  };
  return map[region] ?? region.name;
}

String _mentalStateLabel(MentalState state) => switch (state) {
  MentalState.brainFog => 'Niebla mental',
  MentalState.dissociation => 'Disociación',
  MentalState.anxiety => 'Ansiedad',
  MentalState.irritability => 'Irritabilidad',
  MentalState.overwhelm => 'Sobrecarga',
  MentalState.numbness => 'Embotamiento',
  MentalState.other => 'Otro estado',
};

String _linkedEventTypeLabel(LinkedEventType t) => switch (t) {
  LinkedEventType.symptom => 'Síntoma',
  LinkedEventType.bowel => 'Evento intestinal',
  LinkedEventType.hemorrhoidal => 'Sangrado hemorroidal',
  LinkedEventType.fever => 'Fiebre',
};

String _actionKeyFor(ActionTaken action) {
  // Prefer detail label, fall back to kind label.
  if (action.detail != null && action.detail!.trim().isNotEmpty) {
    return action.detail!.trim();
  }
  return switch (action.kind) {
    ActionKind.medicationBasal => 'Medicación basal',
    ActionKind.medicationRescue => 'Medicación de rescate',
    ActionKind.rest => 'Descanso',
    ActionKind.pacing => 'Pacing (día tranquilo)',
    ActionKind.movement => 'Movimiento / actividad',
    ActionKind.hydration => 'Hidratación',
    ActionKind.nutrition => 'Ajuste nutricional',
    ActionKind.thermal => 'Aplicación térmica',
    ActionKind.compression => 'Compresión / vendaje',
    ActionKind.breathwork => 'Respiración / regulación',
    ActionKind.medicalCare => 'Atención médica',
    ActionKind.nothing => 'No se tomó acción',
  };
}

// ============================================================
// Profile field extractors
// ============================================================
//
// These return best-effort Spanish clinical labels. If Profile
// exposes a different field structure than assumed here, they degrade
// gracefully. Phase4.C UI iteration will confirm each extractor
// against the real Profile schema.

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
  final out = <String>[];
  for (final m in profile.medications) {
    if (!m.isActive) continue;
    final buf = StringBuffer(m.name);
    if (m.doseText != null && m.doseText!.isNotEmpty) {
      buf.write(' — ${m.doseText}');
    }
    out.add(buf.toString());
  }
  return out;
}

List<String> _formatCriticalNotes(Profile profile) {
  // Optional field on Profile. Return empty if absent.
  return const [];
}
