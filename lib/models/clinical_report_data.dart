// Sprint Phase4.A — Clinical report data structures.
//
// The output schema of pdf_report_aggregator. These structures are
// what the PDF generation service (Phase4.B) will render into the
// PDF document.
//
// Key design principle: this layer contains AGGREGATED data, not
// raw event lists. The PDF shows patterns to the clinician, not a
// journal. Truncation is applied at the aggregator level.

import 'mcas.dart' show MCASRedFlag;

// ============================================================
// Root
// ============================================================

/// Complete aggregated data for one clinical report generation.
///
/// Sections are nullable when the user has disabled them OR when the
/// data is insufficient. The PDF generator (Phase4.B) skips null
/// sections silently.
class ClinicalReportData {
  final ReportMetadata metadata;
  final PatientProfileSection? profile;
  final MedicationSection? medications;
  final SymptomSection? symptoms;
  final MCASSection? mcas;
  final StructuralSection? structural;
  final MentalStateSection? mentalState;
  final ActionsSection? actions;
  final PatientNotesSection? patientNotes;
  final EpisodeSection? episodes;

  const ClinicalReportData({
    required this.metadata,
    this.profile,
    this.medications,
    this.symptoms,
    this.mcas,
    this.structural,
    this.mentalState,
    this.actions,
    this.patientNotes,
    this.episodes,
  });

  /// True if no meaningful data exists for the report. The UI should
  /// warn the user before generating an empty PDF.
  bool get isEmpty =>
      profile == null &&
      medications == null &&
      (symptoms?.isEmpty ?? true) &&
      mcas == null &&
      (structural?.isEmpty ?? true) &&
      mentalState == null &&
      (actions?.isEmpty ?? true) &&
      (patientNotes == null || patientNotes!.text.isEmpty) &&
      (episodes?.isEmpty ?? true);
}

// ============================================================
// Metadata
// ============================================================

class ReportMetadata {
  /// When this report was generated.
  final DateTime generatedAt;

  /// Start of the covered period (inclusive).
  final DateTime periodStart;

  /// End of the covered period (inclusive, typically now).
  final DateTime periodEnd;

  /// Human-readable range label (e.g., "Últimos 30 días").
  final String rangeLabel;

  /// ZebraUp app version at generation time. For traceability.
  final String appVersion;

  /// Locale used for the report (e.g., "es").
  final String locale;

  const ReportMetadata({
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.rangeLabel,
    required this.appVersion,
    required this.locale,
  });
}

// ============================================================
// Patient profile section
// ============================================================

class PatientProfileSection {
  /// Display name of the patient. May be first-name only or a nickname.
  final String? displayName;

  /// Date of birth if provided. Rendered as age at report time.
  final DateTime? dateOfBirth;

  /// Confirmed or self-reported diagnoses in Spanish clinical
  /// terminology (e.g., "Síndrome de Ehlers-Danlos clásico-like",
  /// "POTS", "MCAS").
  final List<String> conditions;

  /// Known allergies and MCAS triggers (drug names, foods, environmental).
  final List<String> allergies;

  /// Emergency contacts as free-form text lines.
  final List<String> emergencyContacts;

  const PatientProfileSection({
    this.displayName,
    this.dateOfBirth,
    this.conditions = const [],
    this.allergies = const [],
    this.emergencyContacts = const [],
  });
}

// ============================================================
// Medications section
// ============================================================

class MedicationSection {
  /// Active medications aggregated by name.
  final List<MedicationEntry> active;

  /// Medications discontinued or "as-needed" not used in the period.
  final List<MedicationEntry> inactive;

  const MedicationSection({this.active = const [], this.inactive = const []});

  bool get isEmpty => active.isEmpty && inactive.isEmpty;
}

class MedicationEntry {
  /// Medication display name.
  final String name;

  /// Standard dose text (e.g., "10 mg cada 8 h").
  final String? doseText;

  /// Adherence percentage (0-100) for scheduled medications.
  /// Null for as-needed medications.
  final double? adherencePercent;

  /// Mean effectiveness rating (0-4 scale, where 4 = "aliviado por completo").
  /// Null if never rated in the period.
  final double? meanEffectiveness;

  /// Total doses recorded in the period.
  final int totalDoses;

  /// Whether the medication had adverse outcomes reported.
  final bool hadAdverseOutcomes;

  const MedicationEntry({
    required this.name,
    this.doseText,
    this.adherencePercent,
    this.meanEffectiveness,
    this.totalDoses = 0,
    this.hadAdverseOutcomes = false,
  });
}

// ============================================================
// Symptoms section
// ============================================================

class SymptomSection {
  /// Aggregated symptom categories with counts + severity distribution.
  /// Truncated to top-N by frequency*severity score.
  final List<SymptomAggregation> topSymptoms;

  /// Number of additional symptoms not shown in topSymptoms.
  /// Rendered as "y N síntomas adicionales" in the PDF.
  final int otherSymptomsCount;

  /// Days in the period where at least one symptom had severity ≥ 3.
  /// (SymptomSeverity 0-4 scale; 3 = severe.)
  final int severeSymptomDays;

  /// Total number of symptom events in the period.
  final int totalEvents;

  /// Patterns detected: e.g., "Migraña más frecuente por las mañanas"
  /// or "Fatiga incrementa 24-72h tras actividad". Only populated
  /// when patterns section is enabled and enough data exists.
  final List<String> detectedPatterns;

  const SymptomSection({
    this.topSymptoms = const [],
    this.otherSymptomsCount = 0,
    this.severeSymptomDays = 0,
    this.totalEvents = 0,
    this.detectedPatterns = const [],
  });

  bool get isEmpty => topSymptoms.isEmpty && totalEvents == 0;
}

class SymptomAggregation {
  /// Symptom display name (e.g., "Migraña", "Fatiga profunda").
  final String name;

  /// Number of times this symptom was logged in the period.
  final int occurrences;

  /// Severity distribution: keys 0-4, values = count at that severity.
  final Map<int, int> severityDistribution;

  /// Mean severity (0-4).
  final double meanSeverity;

  /// Times of day pattern: keys "morning" / "afternoon" / "evening" /
  /// "night", values = count. Only populated if there's a clear
  /// temporal pattern.
  final Map<String, int> timeOfDayPattern;

  const SymptomAggregation({
    required this.name,
    required this.occurrences,
    this.severityDistribution = const {},
    this.meanSeverity = 0,
    this.timeOfDayPattern = const {},
  });
}

// ============================================================
// MCAS section (nullable — only when data exists)
// ============================================================

class MCASSection {
  /// Total MCAS-flagged events in the period.
  final int totalEvents;

  /// Red flag events, prominently displayed. Sorted by date descending.
  final List<MCASRedFlagOccurrence> redFlags;

  /// Most common triggers identified.
  final List<String> commonTriggers;

  /// Most common reaction kinds (Spanish labels).
  final List<String> commonReactions;

  const MCASSection({
    this.totalEvents = 0,
    this.redFlags = const [],
    this.commonTriggers = const [],
    this.commonReactions = const [],
  });
}

class MCASRedFlagOccurrence {
  final DateTime occurredAt;
  final MCASRedFlag flag;

  /// Human-readable Spanish label for the red flag.
  final String label;

  const MCASRedFlagOccurrence({
    required this.occurredAt,
    required this.flag,
    required this.label,
  });
}

// ============================================================
// Structural events section
// ============================================================

class StructuralSection {
  /// Structural events grouped by kind.
  final List<StructuralAggregation> byKind;

  /// Total structural events in the period.
  final int totalEvents;

  const StructuralSection({this.byKind = const [], this.totalEvents = 0});

  bool get isEmpty => byKind.isEmpty && totalEvents == 0;
}

class StructuralAggregation {
  /// Human-readable kind (e.g., "Subluxación", "Dislocación").
  final String kindLabel;

  /// Body regions affected with counts.
  /// Key = body region label in Spanish, value = occurrences.
  final Map<String, int> regionCounts;

  /// Total occurrences of this kind.
  final int occurrences;

  const StructuralAggregation({
    required this.kindLabel,
    this.regionCounts = const {},
    this.occurrences = 0,
  });
}

// ============================================================
// Mental state section (aggregate only)
// ============================================================

class MentalStateSection {
  /// Mean valence (positive/negative) score across all mood entries in
  /// the period, derived from MoodEntry.primaryQuadrant (pleasant=+1,
  /// unpleasant=-1, averaged). Range [-1, 1]. Null when there's no mood
  /// data for the period.
  final double? meanValence;

  /// Mean arousal (activation/deactivation) score, same derivation
  /// (activated=+1, calm=-1, averaged). Range [-1, 1].
  final double? meanArousal;

  /// Cognitive state frequencies: e.g., "niebla mental": 12,
  /// "disociación": 3. Labels in Spanish. Sourced from MentalEvent/
  /// MentalState — a separate, simpler tracker from the mood quadrant
  /// data above.
  final Map<String, int> cognitiveStateFrequency;

  /// Mood quadrant frequencies (e.g. "activación · bienestar": 8),
  /// using MoodQuadrantLabels.label. Aggregate only.
  final Map<String, int> moodQuadrantFrequency;

  /// Most frequently selected mood words (e.g. "Frustración": 5),
  /// from MoodEntry.states. Aggregate only — MoodEntry.notes free text
  /// is never surfaced here.
  final Map<String, int> moodWordFrequency;

  /// Number of mental entries logged. For context only — no
  /// individual entries are exposed to the specialist.
  final int totalEntries;

  /// Number of mood entries logged in the period. Separate counter
  /// from totalEntries since mood and mental-state are different logs.
  final int totalMoodEntries;

  const MentalStateSection({
    this.meanValence,
    this.meanArousal,
    this.cognitiveStateFrequency = const {},
    this.moodQuadrantFrequency = const {},
    this.moodWordFrequency = const {},
    this.totalEntries = 0,
    this.totalMoodEntries = 0,
  });
}

// ============================================================
// Actions section
// ============================================================

class ActionsSection {
  /// Top actions by mean effectiveness, truncated to top-N.
  final List<ActionEffectivenessEntry> mostEffective;

  /// Actions that were rated ineffective repeatedly.
  final List<ActionEffectivenessEntry> leastEffective;

  /// Total ActionTaken entries in the period.
  final int totalActions;

  const ActionsSection({
    this.mostEffective = const [],
    this.leastEffective = const [],
    this.totalActions = 0,
  });

  bool get isEmpty =>
      mostEffective.isEmpty && leastEffective.isEmpty && totalActions == 0;
}

class ActionEffectivenessEntry {
  /// Action display label (e.g., "Ibuprofeno 400 mg",
  /// "Descanso en cama", "Compresión térmica").
  final String label;

  /// Number of times used in the period.
  final int uses;

  /// Mean effectiveness rating (0-4 scale).
  final double meanEffectiveness;

  /// Which linked event types this action was most commonly used with
  /// (e.g., ["Migraña", "Fatiga"]).
  final List<String> commonLinkedTo;

  const ActionEffectivenessEntry({
    required this.label,
    required this.uses,
    required this.meanEffectiveness,
    this.commonLinkedTo = const [],
  });
}

// ============================================================
// Episodes section ("cuadros temporales" — acute-but-not-chronic
// diagnoses, e.g. resfrío, amigdalitis — with the symptoms the patient
// linked to each one). See Episode in lib/models/models.dart.
// ============================================================

class EpisodeSection {
  /// One entry per Episode that has at least one linked symptom in the
  /// report period. Episodes with zero matches in range are omitted by
  /// the aggregator, not represented here as empty entries.
  final List<EpisodeSummary> episodes;

  const EpisodeSection({this.episodes = const []});

  bool get isEmpty => episodes.isEmpty;
}

class EpisodeSummary {
  final String title;
  final DateTime startDate;

  /// Null means still open ("en curso") at report generation time.
  final DateTime? resolvedAt;

  final String? note;

  /// Linked symptom occurrences within the report period, sorted by
  /// timestamp descending. Kept small (bounded by one episode's worth
  /// of symptoms) — this is per-episode context, not a raw journal dump
  /// of the whole period.
  final List<EpisodeSymptomOccurrence> symptoms;

  const EpisodeSummary({
    required this.title,
    required this.startDate,
    this.resolvedAt,
    this.note,
    this.symptoms = const [],
  });
}

class EpisodeSymptomOccurrence {
  final String name;
  final DateTime timestamp;

  /// 0-4 scale, same as SymptomSeverity.value.
  final int severity;

  const EpisodeSymptomOccurrence({
    required this.name,
    required this.timestamp,
    required this.severity,
  });
}

// ============================================================
// Patient notes section
// ============================================================

class PatientNotesSection {
  /// Free-text notes the patient wrote at export time. Rendered
  /// verbatim in the PDF under a "Para tu especialista" heading.
  final String text;

  const PatientNotesSection({required this.text});
}

// ============================================================
// Emergency card data (Phase4.D compact export)
// ============================================================

/// Compact single-page data structure for the emergency card variant.
/// Only used when PdfExportConfig.isEmergencyCard is true.
///
/// Phase4.D will render this. Included in Phase4.A because it's
/// derivable from the same aggregation logic and belongs to the
/// output schema.
class EmergencyCardData {
  final String? patientDisplayName;
  final DateTime? dateOfBirth;

  /// Confirmed diagnoses, prominent.
  final List<String> conditions;

  /// Active medications with dose (e.g., "Fludrocortisona 0.1 mg / día").
  final List<String> activeMedications;

  /// Known allergies + MCAS triggers, prominent.
  final List<String> allergiesAndTriggers;

  /// Emergency contacts.
  final List<String> emergencyContacts;

  /// MCAS red flags in the last 30 days (dates only).
  final List<MCASRedFlagOccurrence> recentRedFlags;

  /// Additional patient-provided critical info (e.g., "Sensibilidad a
  /// anestésicos", "No dar AINEs").
  final List<String> criticalNotes;

  const EmergencyCardData({
    this.patientDisplayName,
    this.dateOfBirth,
    this.conditions = const [],
    this.activeMedications = const [],
    this.allergiesAndTriggers = const [],
    this.emergencyContacts = const [],
    this.recentRedFlags = const [],
    this.criticalNotes = const [],
  });
}
