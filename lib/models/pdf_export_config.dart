// Sprint Phase4.A — PDF export configuration schema.
//
// Defines what the user can toggle when generating a clinical report:
// which sections to include, what time range, and other preferences.
//
// The config object is created per-export-session (not persisted here).
// PdfExportPreferences captures the user's defaults for future exports;
// persistence to Hive is deferred to Phase4.F.

/// Toggleable sections that can be included in a clinical PDF report.
///
/// Ordered by typical clinical priority — the enum order also drives
/// default visual order in the UI configuration screen.
enum PdfSection {
  /// Patient identity + conditions + allergies. Always on for emergency
  /// card. Optional for routine reports (some patients prefer to keep
  /// it separate).
  patientProfile,

  /// Current active medications + adherence % (for scheduled meds) +
  /// mean effectiveness. Always relevant for medication reviews.
  medications,

  /// Aggregated symptom counts and severity distribution by category.
  /// NOT individual entries — patterns only.
  symptomsSummary,

  /// Key patterns detected: frequency trends, common triggers, times
  /// of day. Only shown when enough data exists to detect patterns
  /// (aggregator returns empty if insufficient).
  symptomsPatterns,

  /// MCAS-specific events with red-flag markers. Prominent when red
  /// flags exist. Section may be absent entirely if no MCAS data in
  /// the period.
  mcasEvents,

  /// Structural events: dislocations, subluxations, sprains. Grouped
  /// by body region.
  structuralEvents,

  /// "Cuadros temporales" (Episode): acute-but-not-chronic diagnoses
  /// (resfrío, amigdalitis…) with the symptoms the patient linked to
  /// each one. Only episodes with a linked symptom in the report
  /// period are shown.
  episodes,

  /// Mental state aggregated (mean valence, mean arousal, cognitive
  /// state frequencies). NEVER individual mental entries — privacy.
  mentalState,

  /// Which actions worked best (top-N by effectiveness) and which
  /// didn't. Cross-references with linked events.
  actionsEffectiveness,

  /// Free-text notes the patient wants to raise with the specialist.
  /// Populated in the export screen at generation time.
  patientNotes,

  /// Emergency card: compact, always-included section for the C-mini
  /// use case. When exporting the standalone emergency card, only
  /// this section is used and the layout is single-page.
  emergencyCard,
}

/// Time range covered by a clinical report.
enum PdfTimeRange {
  /// Last 7 days from generation timestamp.
  sevenDays,

  /// Last 30 days. Default — matches typical inter-consult interval
  /// for chronic patients.
  thirtyDays,

  /// Last 90 days. Useful for quarterly reviews.
  ninetyDays,

  /// All available data. Truncation still applies per section (top-N).
  allTime,
}

extension PdfTimeRangeExtension on PdfTimeRange {
  /// Returns the number of days for this range, or null for allTime.
  int? get days => switch (this) {
    PdfTimeRange.sevenDays => 7,
    PdfTimeRange.thirtyDays => 30,
    PdfTimeRange.ninetyDays => 90,
    PdfTimeRange.allTime => null,
  };

  /// Spanish label for the range (clinical Spanish, not casual).
  String get label => switch (this) {
    PdfTimeRange.sevenDays => 'Últimos 7 días',
    PdfTimeRange.thirtyDays => 'Últimos 30 días',
    PdfTimeRange.ninetyDays => 'Últimos 90 días',
    PdfTimeRange.allTime => 'Historial completo',
  };
}

/// Per-export-session configuration.
///
/// Not persisted directly. See PdfExportPreferences for user defaults
/// that populate this on export screen open.
class PdfExportConfig {
  /// Sections the user has enabled for this specific export.
  final Set<PdfSection> enabledSections;

  /// Time range for this export.
  final PdfTimeRange timeRange;

  /// Optional custom start/end dates. If both non-null, they override
  /// timeRange. Reserved for future custom-range feature; unused in
  /// Phase4.A.
  final DateTime? customStart;
  final DateTime? customEnd;

  /// Free-text notes the patient wants to include in the "para tu
  /// especialista" section. Empty string = section renders empty (or
  /// is skipped if patientNotes not enabled).
  final String patientNotes;

  /// Truncation cap for aggregation. Sections that could produce
  /// long lists (symptoms, structural events, actions) will show
  /// top-N by frequency/severity/effectiveness and summarize the rest.
  /// Default 10.
  final int topNPerSection;

  const PdfExportConfig({
    required this.enabledSections,
    this.timeRange = PdfTimeRange.thirtyDays,
    this.customStart,
    this.customEnd,
    this.patientNotes = '',
    this.topNPerSection = 10,
  });

  /// Default config: routine consult report. All sections enabled
  /// except emergencyCard (which is a separate export flow).
  factory PdfExportConfig.routineConsult() => const PdfExportConfig(
    enabledSections: {
      PdfSection.patientProfile,
      PdfSection.medications,
      PdfSection.symptomsSummary,
      PdfSection.symptomsPatterns,
      PdfSection.mcasEvents,
      PdfSection.structuralEvents,
      PdfSection.episodes,
      PdfSection.mentalState,
      PdfSection.actionsEffectiveness,
      PdfSection.patientNotes,
    },
    timeRange: PdfTimeRange.thirtyDays,
  );

  /// Emergency card config: only the emergency section, no time range
  /// concept applies (current state snapshot + recent red flags only).
  factory PdfExportConfig.emergencyCard() => const PdfExportConfig(
    enabledSections: {PdfSection.emergencyCard},
    timeRange: PdfTimeRange.thirtyDays, // used for recent-red-flags cutoff
  );

  /// Whether this config represents an emergency card export (used to
  /// route to compact layout in Phase4.B).
  bool get isEmergencyCard =>
      enabledSections.length == 1 &&
      enabledSections.contains(PdfSection.emergencyCard);

  PdfExportConfig copyWith({
    Set<PdfSection>? enabledSections,
    PdfTimeRange? timeRange,
    DateTime? customStart,
    DateTime? customEnd,
    String? patientNotes,
    int? topNPerSection,
  }) {
    return PdfExportConfig(
      enabledSections: enabledSections ?? this.enabledSections,
      timeRange: timeRange ?? this.timeRange,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      patientNotes: patientNotes ?? this.patientNotes,
      topNPerSection: topNPerSection ?? this.topNPerSection,
    );
  }
}

/// User's persisted defaults for PDF exports. Populated into
/// PdfExportConfig when the export screen opens.
///
/// Persistence to Hive is deferred to Phase4.F. For now, this class
/// exists so downstream code can depend on the shape.
class PdfExportPreferences {
  /// Which sections the user wants included by default.
  final Set<PdfSection> defaultSections;

  /// Which time range to preselect.
  final PdfTimeRange defaultTimeRange;

  /// Truncation cap preference.
  final int defaultTopN;

  const PdfExportPreferences({
    this.defaultSections = const {
      PdfSection.patientProfile,
      PdfSection.medications,
      PdfSection.symptomsSummary,
      PdfSection.symptomsPatterns,
      PdfSection.mcasEvents,
      PdfSection.structuralEvents,
      PdfSection.episodes,
      PdfSection.mentalState,
      PdfSection.actionsEffectiveness,
      PdfSection.patientNotes,
    },
    this.defaultTimeRange = PdfTimeRange.thirtyDays,
    this.defaultTopN = 10,
  });

  /// Builds an initial PdfExportConfig from these preferences.
  PdfExportConfig toInitialConfig() => PdfExportConfig(
    enabledSections: Set.from(defaultSections),
    timeRange: defaultTimeRange,
    topNPerSection: defaultTopN,
  );

  Map<String, dynamic> toMap() => {
    'defaultSections': defaultSections.map((s) => s.name).toList(),
    'defaultTimeRange': defaultTimeRange.name,
    'defaultTopN': defaultTopN,
  };

  factory PdfExportPreferences.fromMap(Map<String, dynamic> map) {
    Set<PdfSection> parseSections(dynamic raw) {
      if (raw is! List) return const {};
      final out = <PdfSection>{};
      for (final s in raw) {
        for (final section in PdfSection.values) {
          if (section.name == s) {
            out.add(section);
            break;
          }
        }
      }
      return out;
    }

    PdfTimeRange parseRange(dynamic raw) {
      for (final r in PdfTimeRange.values) {
        if (r.name == raw) return r;
      }
      return PdfTimeRange.thirtyDays;
    }

    return PdfExportPreferences(
      defaultSections: parseSections(map['defaultSections']).isEmpty
          ? const PdfExportPreferences().defaultSections
          : parseSections(map['defaultSections']),
      defaultTimeRange: parseRange(map['defaultTimeRange']),
      defaultTopN: map['defaultTopN'] is int ? map['defaultTopN'] as int : 10,
    );
  }
}
