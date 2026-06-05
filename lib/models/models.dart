import 'dart:math';

// ============================================================================
// ID GENERATION
// ============================================================================
String _newId() {
  final rand = Random.secure();
  final hex = List.generate(6, (_) => rand.nextInt(16).toRadixString(16)).join();
  return '${DateTime.now().microsecondsSinceEpoch}-$hex';
}

// ============================================================================
// ENUMS
// ============================================================================

enum SymptomSeverity {
  mild('Leve'),
  moderate('Moderado'),
  severe('Severo');

  final String label;
  const SymptomSeverity(this.label);

  static SymptomSeverity parse(dynamic raw) {
    if (raw is String) {
      for (final s in SymptomSeverity.values) {
        if (s.name == raw) return s;
      }
      for (final s in SymptomSeverity.values) {
        if (s.label.toLowerCase() == raw.toLowerCase()) return s;
      }
    }
    return SymptomSeverity.moderate;
  }
}

/// Outcome of a medication-symptom check-in.
enum MedicationOutcomeStatus {
  pending('Pendiente'),
  better('Mejor'),
  same('Igual'),
  worse('Peor'),
  unknown('No recuerdo');

  final String label;
  const MedicationOutcomeStatus(this.label);

  static MedicationOutcomeStatus parse(dynamic raw) {
    if (raw is String) {
      for (final s in MedicationOutcomeStatus.values) {
        if (s.name == raw) return s;
      }
    }
    return MedicationOutcomeStatus.pending;
  }
}

/// Fixed catalog of mental states tracked. Kept deliberately shallow.
enum MentalState {
  mood('Ánimo', '🙂'),
  anxiety('Ansiedad', '😰'),
  brainFog('Niebla mental', '🌫️'),
  dissociation('Disociación', '🫥'),
  irritability('Irritabilidad', '⚡'),
  emotionalEnergy('Energía emocional', '🔋');

  final String label;
  final String emoji;
  const MentalState(this.label, this.emoji);

  static MentalState? parse(dynamic raw) {
    if (raw is String) {
      for (final s in MentalState.values) {
        if (s.name == raw) return s;
      }
    }
    return null;
  }
}

// ============================================================================
// EVENT LOGS (TIMESERIES DATA)
// ============================================================================

class SymptomEvent {
  final String id;
  final DateTime timestamp;
  final String name;
  final SymptomSeverity severity;
  final String? note;

  SymptomEvent({
    String? id,
    required this.timestamp,
    required this.name,
    required this.severity,
    this.note,
  }) : id = id ?? _newId();

  SymptomEvent copyWith({DateTime? timestamp, SymptomSeverity? severity, String? note}) {
    return SymptomEvent(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      name: name,
      severity: severity ?? this.severity,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'name': name,
        'severity': severity.name,
        'note': note,
      };

  factory SymptomEvent.fromMap(Map<String, dynamic> map) => SymptomEvent(
        id: map['id'],
        timestamp: DateTime.parse(map['timestamp']),
        name: map['name'],
        severity: SymptomSeverity.parse(map['severity']),
        note: map['note'] as String?,
      );
}

class DoseEvent {
  final String id;
  final DateTime timestamp;
  final String medicationName;
  /// IDs of symptoms this dose was taken in response to (for outcome tracking).
  final List<String> linkedSymptomIds;

  DoseEvent({
    String? id,
    required this.timestamp,
    required this.medicationName,
    this.linkedSymptomIds = const [],
  }) : id = id ?? _newId();

  DoseEvent copyWith({DateTime? timestamp, List<String>? linkedSymptomIds}) {
    return DoseEvent(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      medicationName: medicationName,
      linkedSymptomIds: linkedSymptomIds ?? this.linkedSymptomIds,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'medicationName': medicationName,
        'linkedSymptomIds': linkedSymptomIds,
      };

  factory DoseEvent.fromMap(Map<String, dynamic> map) => DoseEvent(
        id: map['id'],
        timestamp: DateTime.parse(map['timestamp']),
        medicationName: map['medicationName'],
        linkedSymptomIds: List<String>.from(map['linkedSymptomIds'] ?? []),
      );
}

class StructuralEvent {
  final String id;
  final DateTime timestamp;
  final String zone;
  final String type;
  final String? note;

  StructuralEvent({
    String? id,
    required this.timestamp,
    required this.zone,
    required this.type,
    this.note,
  }) : id = id ?? _newId();

  StructuralEvent copyWith({DateTime? timestamp, String? type, String? note}) {
    return StructuralEvent(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      zone: zone,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'zone': zone,
        'type': type,
        'note': note,
      };

  factory StructuralEvent.fromMap(Map<String, dynamic> map) => StructuralEvent(
        id: map['id'],
        timestamp: DateTime.parse(map['timestamp']),
        zone: map['zone'],
        type: map['type'],
        note: map['note'] as String?,
      );
}

/// Mental state event — same shape as symptom but bounded to the MentalState enum.
class MentalEvent {
  final String id;
  final DateTime timestamp;
  final MentalState state;
  /// 1–5 scale (1 = none/very low, 5 = severe/very high)
  final int severity;
  final String? note;

  MentalEvent({
    String? id,
    required this.timestamp,
    required this.state,
    required this.severity,
    this.note,
  }) : id = id ?? _newId();

  MentalEvent copyWith({DateTime? timestamp, int? severity, String? note}) {
    return MentalEvent(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      state: state,
      severity: severity ?? this.severity,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'state': state.name,
        'severity': severity,
        'note': note,
      };

  factory MentalEvent.fromMap(Map<String, dynamic> map) => MentalEvent(
        id: map['id'],
        timestamp: DateTime.parse(map['timestamp']),
        state: MentalState.parse(map['state']) ?? MentalState.mood,
        severity: (map['severity'] as num).toInt(),
        note: map['note'] as String?,
      );
}

/// Activity event — for tracking exercise/movement (Hampton-style routine).
class ActivityEvent {
  final String id;
  final DateTime timestamp;
  final String name;
  /// Either reps×sets OR duration — keep both optional.
  final int? sets;
  final int? reps;
  final int? durationMinutes;
  /// Rate of Perceived Exertion, 0–10.
  final int effort;
  /// 1–5 feeling scale (1 = pain/injured, 5 = strong/confident).
  final int feeling;
  /// Heart rate response, free text for now ("80 → 110", "n/a", etc).
  final String? hhr;
  final String? note;

  ActivityEvent({
    String? id,
    required this.timestamp,
    required this.name,
    this.sets,
    this.reps,
    this.durationMinutes,
    required this.effort,
    required this.feeling,
    this.hhr,
    this.note,
  }) : id = id ?? _newId();

  ActivityEvent copyWith({
    DateTime? timestamp,
    int? sets,
    int? reps,
    int? durationMinutes,
    int? effort,
    int? feeling,
    String? hhr,
    String? note,
  }) {
    return ActivityEvent(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      name: name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      effort: effort ?? this.effort,
      feeling: feeling ?? this.feeling,
      hhr: hhr ?? this.hhr,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'name': name,
        'sets': sets,
        'reps': reps,
        'durationMinutes': durationMinutes,
        'effort': effort,
        'feeling': feeling,
        'hhr': hhr,
        'note': note,
      };

  factory ActivityEvent.fromMap(Map<String, dynamic> map) => ActivityEvent(
        id: map['id'],
        timestamp: DateTime.parse(map['timestamp']),
        name: map['name'],
        sets: map['sets'] as int?,
        reps: map['reps'] as int?,
        durationMinutes: map['durationMinutes'] as int?,
        effort: (map['effort'] as num).toInt(),
        feeling: (map['feeling'] as num).toInt(),
        hhr: map['hhr'] as String?,
        note: map['note'] as String?,
      );
}

/// Tracks whether a dose helped with a specific symptom.
/// Created when user logs a dose AND opts in to tracking effectiveness.
class MedicationOutcome {
  final String id;
  final String doseId;
  final String symptomId;
  final String medicationName;
  final String symptomName;
  final DateTime doseTimestamp;
  final DateTime checkAt;
  final MedicationOutcomeStatus status;
  /// When the user actually answered (null if still pending).
  final DateTime? respondedAt;

  MedicationOutcome({
    String? id,
    required this.doseId,
    required this.symptomId,
    required this.medicationName,
    required this.symptomName,
    required this.doseTimestamp,
    required this.checkAt,
    this.status = MedicationOutcomeStatus.pending,
    this.respondedAt,
  }) : id = id ?? _newId();

  MedicationOutcome copyWith({
    MedicationOutcomeStatus? status,
    DateTime? respondedAt,
  }) {
    return MedicationOutcome(
      id: id,
      doseId: doseId,
      symptomId: symptomId,
      medicationName: medicationName,
      symptomName: symptomName,
      doseTimestamp: doseTimestamp,
      checkAt: checkAt,
      status: status ?? this.status,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  bool get isPending => status == MedicationOutcomeStatus.pending;
  bool get isDue => isPending && DateTime.now().isAfter(checkAt);

  Map<String, dynamic> toMap() => {
        'id': id,
        'doseId': doseId,
        'symptomId': symptomId,
        'medicationName': medicationName,
        'symptomName': symptomName,
        'doseTimestamp': doseTimestamp.toIso8601String(),
        'checkAt': checkAt.toIso8601String(),
        'status': status.name,
        'respondedAt': respondedAt?.toIso8601String(),
      };

  factory MedicationOutcome.fromMap(Map<String, dynamic> map) => MedicationOutcome(
        id: map['id'],
        doseId: map['doseId'],
        symptomId: map['symptomId'],
        medicationName: map['medicationName'],
        symptomName: map['symptomName'],
        doseTimestamp: DateTime.parse(map['doseTimestamp']),
        checkAt: DateTime.parse(map['checkAt']),
        status: MedicationOutcomeStatus.parse(map['status']),
        respondedAt: map['respondedAt'] != null ? DateTime.parse(map['respondedAt']) : null,
      );
}

// ============================================================================
// CATALOGS (DICTIONARY)
// ============================================================================

class MedicationDef {
  String name;
  String defaultDose;
  /// Hours after which the app should ask if the med helped.
  /// Null means don't track outcomes for this med (e.g., daily vitamins).
  int? outcomeCheckHours;

  MedicationDef({
    required this.name,
    required this.defaultDose,
    this.outcomeCheckHours = 3,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'defaultDose': defaultDose,
        'outcomeCheckHours': outcomeCheckHours,
      };

  factory MedicationDef.fromMap(Map<String, dynamic> map) => MedicationDef(
        name: map['name'],
        defaultDose: map['defaultDose'],
        outcomeCheckHours: map['outcomeCheckHours'] as int? ?? 3,
      );
}

class WisdomQuote {
  final String text;
  final String category;
  WisdomQuote({required this.text, required this.category});
}

class ClinicalArticle {
  final String category;
  final String title;
  final String content;
  ClinicalArticle({
    required this.category,
    required this.title,
    required this.content,
  });
}

// ============================================================================
// PUBMED CACHE
// ============================================================================

/// A cached PubMed article. Stored once per PMID across all profiles.
class PubMedArticle {
  final String pmid;
  final String title;
  final String? abstractText;
  final String journal;
  final List<String> authors;
  final DateTime publicationDate;
  final DateTime cachedAt;
  /// Conditions this article was fetched for (for cache invalidation).
  final List<String> fetchedForConditions;

  PubMedArticle({
    required this.pmid,
    required this.title,
    this.abstractText,
    required this.journal,
    required this.authors,
    required this.publicationDate,
    DateTime? cachedAt,
    this.fetchedForConditions = const [],
  }) : cachedAt = cachedAt ?? DateTime.now();

  String get authorsShort {
    if (authors.isEmpty) return 'Sin autor';
    if (authors.length == 1) return authors.first;
    if (authors.length <= 3) return authors.join(', ');
    return '${authors.first} et al.';
  }

  String get pubmedUrl => 'https://pubmed.ncbi.nlm.nih.gov/$pmid/';

  Map<String, dynamic> toMap() => {
        'pmid': pmid,
        'title': title,
        'abstractText': abstractText,
        'journal': journal,
        'authors': authors,
        'publicationDate': publicationDate.toIso8601String(),
        'cachedAt': cachedAt.toIso8601String(),
        'fetchedForConditions': fetchedForConditions,
      };

  factory PubMedArticle.fromMap(Map<String, dynamic> map) => PubMedArticle(
        pmid: map['pmid'],
        title: map['title'],
        abstractText: map['abstractText'] as String?,
        journal: map['journal'] ?? '',
        authors: List<String>.from(map['authors'] ?? []),
        publicationDate: DateTime.parse(map['publicationDate']),
        cachedAt: DateTime.parse(map['cachedAt']),
        fetchedForConditions: List<String>.from(map['fetchedForConditions'] ?? []),
      );
}

// ============================================================================
// INTERACTION ENGINE
// ============================================================================

enum InteractionLevel { info, warning, severe }

class InteractionRule {
  final List<String> medicationKeys;
  final List<String>? requiredConditions;
  final InteractionLevel level;
  final String message;
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
    return requiredConditions!.any((c) => conditionsLower.any((dx) => dx.contains(c)));
  }
}

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
    reference: 'SNRI + NSAID class warning; relevante en EDS y adenomiosis.',
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

// ============================================================================
// EXERCISE CATALOG (Hampton-modified)
// ============================================================================

class ExerciseDef {
  final String name;
  final String category;
  final bool durationBased;
  const ExerciseDef(this.name, this.category, {this.durationBased = false});
}

const List<ExerciseDef> kExerciseCatalog = [
  ExerciseDef('Push-ups', 'Push'),
  ExerciseDef('Pull-ups', 'Pull'),
  ExerciseDef('Squats', 'Legs'),
  ExerciseDef('Bridges', 'Posterior'),
  ExerciseDef('Leg raises', 'Core'),
  ExerciseDef('Twists', 'Core'),
  ExerciseDef('Estiramiento', 'Stretch', durationBased: true),
  ExerciseDef('Caminata', 'Cardio', durationBased: true),
  ExerciseDef('Yoga gentil', 'Stretch', durationBased: true),
];

// ============================================================================
// PROFILE (ANALYTICS ENGINE)
// ============================================================================

class Profile {
  final String id;
  String name;
  List<String> conditions;
  String? country; // For clinical-trial filtering later

  List<String> symptomVault;
  List<MedicationDef> botiquin;

  List<SymptomEvent> symptomHistory;
  List<DoseEvent> doseHistory;
  List<StructuralEvent> structuralHistory;
  List<MentalEvent> mentalHistory;
  List<ActivityEvent> activityHistory;
  List<MedicationOutcome> medicationOutcomes;

  Set<String> pacingDays;
  /// PMIDs the user saved to their library.
  Set<String> savedArticlePmids;

  Profile({
    required this.id,
    required this.name,
    required this.conditions,
    required this.symptomVault,
    required this.botiquin,
    this.country,
    List<SymptomEvent>? symptoms,
    List<DoseEvent>? doses,
    List<StructuralEvent>? structural,
    List<MentalEvent>? mental,
    List<ActivityEvent>? activity,
    List<MedicationOutcome>? outcomes,
    Set<String>? pacing,
    Set<String>? saved,
  })  : symptomHistory = symptoms ?? [],
        doseHistory = doses ?? [],
        structuralHistory = structural ?? [],
        mentalHistory = mental ?? [],
        activityHistory = activity ?? [],
        medicationOutcomes = outcomes ?? [],
        pacingDays = pacing ?? {},
        savedArticlePmids = saved ?? {};

  // --- ANALYTICS ---

  List<String> getTrendingSymptoms() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recent = symptomHistory.where((e) => e.timestamp.isAfter(oneWeekAgo));
    final counts = <String, int>{};
    for (final e in recent) {
      counts[e.name] = (counts[e.name] ?? 0) + 1;
    }
    return counts.entries
        .where((entry) => entry.value >= 2)
        .map((entry) => entry.key)
        .toList();
  }

  List<DoseEvent> getDosesForDay(DateTime date) => doseHistory
      .where((e) =>
          e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day)
      .toList();

  int getDoseCountForDayAndMed(DateTime date, String medName) =>
      getDosesForDay(date).where((e) => e.medicationName == medName).length;

  List<SymptomEvent> getSymptomsForDay(DateTime date) => symptomHistory
      .where((e) =>
          e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day)
      .toList();

  List<StructuralEvent> getStructuralForDay(DateTime date) => structuralHistory
      .where((e) =>
          e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day)
      .toList();

  List<MentalEvent> getMentalForDay(DateTime date) => mentalHistory
      .where((e) =>
          e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day)
      .toList();

  List<ActivityEvent> getActivityForDay(DateTime date) => activityHistory
      .where((e) =>
          e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day)
      .toList();

  /// Latest mental severity for a given state today, or null if not logged.
  int? latestMentalSeverity(MentalState state, DateTime date) {
    final today = getMentalForDay(date).where((e) => e.state == state).toList();
    if (today.isEmpty) return null;
    today.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return today.first.severity;
  }

  /// Returns symptoms logged in the last [hours] hours with moderate+ severity.
  /// Used to suggest linking a dose to a recent symptom.
  List<SymptomEvent> recentSignificantSymptoms({int hours = 2}) {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return symptomHistory
        .where((s) =>
            s.timestamp.isAfter(cutoff) &&
            (s.severity == SymptomSeverity.moderate ||
                s.severity == SymptomSeverity.severe))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Pending medication outcomes that are due for check-in.
  List<MedicationOutcome> getDueOutcomes() =>
      medicationOutcomes.where((o) => o.isDue).toList()
        ..sort((a, b) => a.checkAt.compareTo(b.checkAt));

  /// Effectiveness summary for a med→symptom pairing.
  /// Returns "X of Y" (better count over answered count), or null if no data.
  ({int better, int total})? effectivenessFor(String medName, String symptomName) {
    final answered = medicationOutcomes
        .where((o) =>
            o.medicationName.toLowerCase() == medName.toLowerCase() &&
            o.symptomName.toLowerCase() == symptomName.toLowerCase() &&
            !o.isPending &&
            o.status != MedicationOutcomeStatus.unknown)
        .toList();
    if (answered.isEmpty) return null;
    final better =
        answered.where((o) => o.status == MedicationOutcomeStatus.better).length;
    return (better: better, total: answered.length);
  }

  // --- SERIALIZATION ---

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'conditions': conditions,
        'country': country,
        'symptomVault': symptomVault,
        'pacingDays': pacingDays.toList(),
        'savedArticlePmids': savedArticlePmids.toList(),
        'botiquin': botiquin.map((x) => x.toMap()).toList(),
        'symptomHistory': symptomHistory.map((x) => x.toMap()).toList(),
        'doseHistory': doseHistory.map((x) => x.toMap()).toList(),
        'structuralHistory': structuralHistory.map((x) => x.toMap()).toList(),
        'mentalHistory': mentalHistory.map((x) => x.toMap()).toList(),
        'activityHistory': activityHistory.map((x) => x.toMap()).toList(),
        'medicationOutcomes': medicationOutcomes.map((x) => x.toMap()).toList(),
      };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'],
        name: map['name'],
        conditions: List<String>.from(map['conditions'] ?? []),
        country: map['country'] as String?,
        symptomVault: List<String>.from(map['symptomVault'] ?? []),
        pacing: Set<String>.from(map['pacingDays'] ?? []),
        saved: Set<String>.from(map['savedArticlePmids'] ?? []),
        botiquin: List<MedicationDef>.from(
            (map['botiquin'] ?? []).map((x) => MedicationDef.fromMap(x))),
        symptoms: List<SymptomEvent>.from(
            (map['symptomHistory'] ?? []).map((x) => SymptomEvent.fromMap(x))),
        doses: List<DoseEvent>.from(
            (map['doseHistory'] ?? []).map((x) => DoseEvent.fromMap(x))),
        structural: List<StructuralEvent>.from(
            (map['structuralHistory'] ?? []).map((x) => StructuralEvent.fromMap(x))),
        mental: List<MentalEvent>.from(
            (map['mentalHistory'] ?? []).map((x) => MentalEvent.fromMap(x))),
        activity: List<ActivityEvent>.from(
            (map['activityHistory'] ?? []).map((x) => ActivityEvent.fromMap(x))),
        outcomes: List<MedicationOutcome>.from((map['medicationOutcomes'] ?? [])
            .map((x) => MedicationOutcome.fromMap(x))),
      );
}