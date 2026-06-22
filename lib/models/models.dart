// =============================================================================
// ZebraUp domain model — Phase 1 foundation.
//
// Changes vs. the previous schema (clean wipe, no migration code):
//   • SymptomSeverity is now a 5-level scale (0–4) matching Wave's dot UI.
//   • MentalEvent severity stays 1–5 for now (separate concern; revisit later).
//   • MedicationDef separates `strength` + `unit` from `defaultQuantity` + `form`
//     so a Bearable-style "1 pill × 500mg" UI is possible.
//   • DoseEvent gains `quantity`, `groupId`, plus a snapshot of strength/unit/form,
//     and a `severityBefore` map keyed by symptomId for outcome baselining.
//   • MedicationOutcome now captures severityBefore + severityAfter (0–4) and an
//     optional OutcomeReason. Status (better/same/worse) is computed from the
//     delta, not stored.
//   • New: MedicationGroup + MedicationGroupEntry — Bearable-style batch logging
//     ("Meds de la noche" @ 22:00 → 1 tap logs 6 doses).
//   • New: SymptomEvent.photoPath for the "añadir foto" Wave feature.
//   • MedicationDef gains a stable `id` so groups can reference it across renames.
//
// Interaction rules moved out to lib/services/interaction_engine.dart
// (single source of truth — the old duplicate here is gone).
// =============================================================================

// =============================================================================
// ZebraUpp domain model — Phase 1 foundation.
//
// Changes vs. the previous schema (clean wipe, no migration code):
//   • SymptomSeverity is now a 5-level scale (0–4) matching Wave's dot UI.
//   • MentalEvent severity stays 1–5 for now (separate concern; revisit later).
//   • MedicationDef separates `strength` + `unit` from `defaultQuantity` + `form`
//     so a Bearable-style "1 pill × 500mg" UI is possible.
//   • DoseEvent gains `quantity`, `groupId`, plus a snapshot of strength/unit/form,
//     and a `severityBefore` map keyed by symptomId for outcome baselining.
//   • MedicationOutcome now captures severityBefore + severityAfter (0–4) and an
//     optional OutcomeReason. Status (better/same/worse) is computed from the
//     delta, not stored.
//   • New: MedicationGroup + MedicationGroupEntry — Bearable-style batch logging
//     ("Meds de la noche" @ 22:00 → 1 tap logs 6 doses).
//   • New: SymptomEvent.photoPath for the "añadir foto" Wave feature.
//   • MedicationDef gains a stable `id` so groups can reference it across renames.
//
// Interaction rules moved out to lib/services/interaction_engine.dart
// (single source of truth — the old duplicate here is gone).
// =============================================================================

import 'dart:math';

// ============================================================================
// ID GENERATION
// ============================================================================
String _newId() {
  final rand = Random.secure();
  final hex = List.generate(6, (_) => rand.nextInt(16).toRadixString(16)).join();
  return '${DateTime.now().microsecondsSinceEpoch}-$hex';
}

// =============================================================================
// SEVERITY (0–4 scale)
// =============================================================================

/// Five-level symptom severity scale.
///
/// Stored as an int (`value`) so analytics can do arithmetic — delta, mean,
/// trend — without round-tripping through an enum. UI surfaces should render
/// the dot at index `value` colored per `colorHex`.
enum SymptomSeverity {
  none(0, 'Ninguna'),
  mild(1, 'Leve'),
  moderate(2, 'Moderada'),
  intense(3, 'Intensa'),
  unbearable(4, 'Insoportable');

  final int value;
  final String label;
  const SymptomSeverity(this.value, this.label);

  static SymptomSeverity fromValue(int v) {
    if (v < 0) return none;
    if (v > 4) return unbearable;
    return values.firstWhere((s) => s.value == v);
  }

  /// Hex color string for the severity dot — keeps the model UI-framework-free.
  /// Flutter callers parse with `Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000)`.
  String get colorHex => switch (this) {
        SymptomSeverity.none => '#9E9E9E',
        SymptomSeverity.mild => '#FFD54F',
        SymptomSeverity.moderate => '#FF9800',
        SymptomSeverity.intense => '#F44336',
        SymptomSeverity.unbearable => '#7B1FA2',
      };
}

// =============================================================================
// MEDICATION OUTCOME — context for "why the severity changed"
// =============================================================================

/// Optional reason a user attributes the outcome to, captured on check-in.
/// Lets us flag outcomes where the med likely didn't drive the change.
enum OutcomeReason {
  natural('Cambio natural del síntoma'),
  medicationHelped('Creo que ayudó este medicamento'),
  otherTrigger('Otro gatillo (comida, estrés, clima…)'),
  additionalMed('Tomé otro medicamento también'),
  unsure('No estoy seguro/a');

  final String label;
  const OutcomeReason(this.label);

  static OutcomeReason? parse(String? raw) {
    if (raw == null) return null;
    for (final r in values) {
      if (r.name == raw) return r;
    }
    return null;
  }
}

// =============================================================================
// MENTAL STATE catalog (unchanged shape; severity still 1–5)
// =============================================================================

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
      for (final s in values) {
        if (s.name == raw) return s;
      }
    }
    return null;
  }
}

// =============================================================================
// EVENT LOGS
// =============================================================================

class SymptomEvent {
  final String id;
  final DateTime timestamp;
  final String name;
  final SymptomSeverity severity;
  final String? note;
  /// Optional local file path to a photo (rashes, swelling, subluxations).
  /// Phase-1 stores the path only; the actual file lives on the device fs.
  final String? photoPath;

  SymptomEvent({
    String? id,
    required this.timestamp,
    required this.name,
    required this.severity,
    this.note,
    this.photoPath,
  }) : id = id ?? _newId();

  SymptomEvent copyWith({
    DateTime? timestamp,
    SymptomSeverity? severity,
    String? note,
    String? photoPath,
  }) {
    return SymptomEvent(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      name: name,
      severity: severity ?? this.severity,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'name': name,
        'severity': severity.value,
        'note': note,
        'photoPath': photoPath,
      };

  factory SymptomEvent.fromMap(Map<String, dynamic> map) => SymptomEvent(
        id: map['id'],
        timestamp: DateTime.parse(map['timestamp']),
        name: map['name'],
        severity: SymptomSeverity.fromValue((map['severity'] as num).toInt()),
        note: map['note'] as String?,
        photoPath: map['photoPath'] as String?,
      );
}

class DoseEvent {
  final String id;
  final DateTime timestamp;
  final String medicationName;
  /// Stable ref to MedicationDef.id. Falls back to name match if null
  /// (legacy entries or imports without the FK).
  final String? medicationId;
  /// How many of the form unit were taken — 1, 0.5, 2, etc.
  final double quantity;
  /// Snapshot of strength at the moment of the dose (mg, mcg, IU…). Snapshotted
  /// because the user may later edit the MedicationDef strength; we don't want
  /// historical dose totals to silently shift under us.
  final double strengthAtDose;
  final String unitAtDose; // 'mg', 'mcg', 'IU', 'g', 'ml', ''
  final String formAtDose; // 'pill', 'capsule', 'drop', 'tablet', 'patch', 'spray', 'ml'
  /// IDs of symptoms this dose was logged in response to.
  final List<String> linkedSymptomIds;
  /// Severity (0–4) of each linked symptom AT DOSE TIME. Used as the baseline
  /// for outcome deltas — answering "did it help?" requires knowing the before.
  final Map<String, int> severityBefore;
  /// If this dose was logged as part of a MedicationGroup batch, the group's id.
  final String? groupId;

  DoseEvent({
    String? id,
    required this.timestamp,
    required this.medicationName,
    this.medicationId,
    this.quantity = 1.0,
    this.strengthAtDose = 0.0,
    this.unitAtDose = '',
    this.formAtDose = 'pill',
    this.linkedSymptomIds = const [],
    this.severityBefore = const {},
    this.groupId,
  }) : id = id ?? _newId();

  /// Total active dose ("how much active ingredient I took") — quantity × strength.
  /// Useful for reports: "Duloxetina hoy: 90mg total".
  double get totalStrength => quantity * strengthAtDose;

  DoseEvent copyWith({
    DateTime? timestamp,
    double? quantity,
    List<String>? linkedSymptomIds,
    Map<String, int>? severityBefore,
  }) {
    return DoseEvent(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      medicationName: medicationName,
      medicationId: medicationId,
      quantity: quantity ?? this.quantity,
      strengthAtDose: strengthAtDose,
      unitAtDose: unitAtDose,
      formAtDose: formAtDose,
      linkedSymptomIds: linkedSymptomIds ?? this.linkedSymptomIds,
      severityBefore: severityBefore ?? this.severityBefore,
      groupId: groupId,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'medicationName': medicationName,
        'medicationId': medicationId,
        'quantity': quantity,
        'strengthAtDose': strengthAtDose,
        'unitAtDose': unitAtDose,
        'formAtDose': formAtDose,
        'linkedSymptomIds': linkedSymptomIds,
        'severityBefore': severityBefore,
        'groupId': groupId,
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
  final StructuralEventKind kind;
  final String type;
  final String? note;

  /// When the user reports the injury fully healed. Used for healing
  /// tracking. NOT included in the clinical report by default — per F4
  /// principle, reports show aggregations + current state, not historical
  /// per-event detail. Visible only in the event's edit sheet.
  final DateTime? resolvedAt;

  /// Whether the area still hurts after `resolvedAt` was set. Most events
  /// transition resolvedAt!=null && stillPainful==false (fully healed).
  /// stillPainful==true with resolvedAt!=null means "the visible injury
  /// closed but the pain stayed".
  final bool stillPainful;

  StructuralEvent({
    String? id,
    required this.timestamp,
    required this.zone,
    StructuralEventKind? kind,
    required this.type,
    this.note,
    this.resolvedAt,
    this.stillPainful = false,
  })  : id = id ?? _newId(),
        kind = kind ?? inferKindFromType(type);

  bool get isResolved => resolvedAt != null;

  StructuralEvent copyWith({
    DateTime? timestamp,
    StructuralEventKind? kind,
    String? type,
    String? note,
    DateTime? resolvedAt,
    bool clearResolvedAt = false,
    bool? stillPainful,
  }) {
    return StructuralEvent(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      zone: zone,
      kind: kind ?? this.kind,
      type: type ?? this.type,
      note: note ?? this.note,
      resolvedAt: clearResolvedAt ? null : (resolvedAt ?? this.resolvedAt),
      stillPainful: stillPainful ?? this.stillPainful,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'zone': zone,
        'kind': kind.name,
        'type': type,
        'note': note,
        'resolvedAt': resolvedAt?.toIso8601String(),
        'stillPainful': stillPainful,
      };

  /// F6.a: applies silent migrations for both `zone` and `type` strings.
  /// Legacy Spanish events ("Cervicales", "Subluxación", etc.) are converted
  /// to stable IDs on read; unknown values pass through unchanged.
  factory StructuralEvent.fromMap(Map<String, dynamic> map) => StructuralEvent(
        id: map['id'],
        timestamp: DateTime.parse(map['timestamp']),
        zone: _migrateZoneId(map['zone'] as String),
        kind: StructuralEventKind.parse(map['kind'] as String?),
        type: _migrateStructuralTypeId(map['type'] as String),
        note: map['note'] as String?,
        resolvedAt: map['resolvedAt'] != null
            ? DateTime.parse(map['resolvedAt'] as String)
            : null,
        stillPainful: map['stillPainful'] as bool? ?? false,
      );
}

class MentalEvent {
  final String id;
  final DateTime timestamp;
  final MentalState state;
  /// 1–5 scale (1 = very low/none, 5 = severe/overwhelming).
  /// Kept on its own scale on purpose — mental states and physical symptoms
  /// have different shapes; unifying with SymptomSeverity is a separate
  /// product decision, not a foundation change.
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

class ActivityEvent {
  final String id;
  final DateTime timestamp;
  final String name;
  final int? sets;
  final int? reps;
  final int? durationMinutes;
  final int effort;   // 0–10 RPE
  final int feeling;  // 1–5 subjective
  final String? hhr;
  final String? note;
  final int? painBefore;
  final int? painAfter;

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
    this.painBefore,
    this.painAfter,
  }) : id = id ?? _newId();

  /// Positive = improvement (less pain after). Null if either side missing.
  int? get painDelta {
    if (painBefore == null || painAfter == null) return null;
    return painBefore! - painAfter!;
  }

  ActivityEvent copyWith({
    DateTime? timestamp,
    int? sets,
    int? reps,
    int? durationMinutes,
    int? effort,
    int? feeling,
    String? hhr,
    String? note,
    int? painBefore,
    int? painAfter,
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
      painBefore: painBefore ?? this.painBefore,
      painAfter: painAfter ?? this.painAfter,
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
        'painBefore': painBefore,
        'painAfter': painAfter,
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
        painBefore: (map['painBefore'] as num?)?.toInt(),
        painAfter: (map['painAfter'] as num?)?.toInt(),
      );
}

// =============================================================================
// MEDICATION OUTCOME — before/after capture
// =============================================================================

/// A pending or answered "did the med help?" check-in for a specific
/// dose↔symptom pair.
///
/// Phase 1 design: capture severity BEFORE (at dose time) and AFTER (at
/// check-in). Don't collapse to better/same/worse — keep the raw numbers and
/// let downstream code compute deltas, distributions, and effect-size stats.
class MedicationOutcome {
  final String id;
  final String doseId;
  final String symptomId;
  final String medicationName;
  final String symptomName;
  final DateTime doseTimestamp;
  final DateTime checkAt;

  /// 0–4 severity captured AT DOSE TIME (snapshot copied from DoseEvent.severityBefore).
  final int severityBefore;

  /// 0–4 severity reported at check-in. Null while pending.
  final int? severityAfter;

  /// Optional context the user adds when answering.
  final OutcomeReason? reason;

  /// When the user actually answered (null if still pending).
  final DateTime? respondedAt;

  /// Free-text note from the check-in moment (rare, but useful).
  final String? note;

  MedicationOutcome({
    String? id,
    required this.doseId,
    required this.symptomId,
    required this.medicationName,
    required this.symptomName,
    required this.doseTimestamp,
    required this.checkAt,
    required this.severityBefore,
    this.severityAfter,
    this.reason,
    this.respondedAt,
    this.note,
  }) : id = id ?? _newId();

  bool get isPending => severityAfter == null;
  bool get isDue => isPending && DateTime.now().isAfter(checkAt);

  /// Negative = improved, 0 = unchanged, positive = worsened.
  /// Null while pending.
  int? get delta =>
      severityAfter == null ? null : severityAfter! - severityBefore;

  /// Coarse label for legacy UI surfaces. Prefer `delta` for analytics.
  String get coarseLabel {
    final d = delta;
    if (d == null) return 'Pendiente';
    if (d <= -2) return 'Mucho mejor';
    if (d == -1) return 'Mejor';
    if (d == 0) return 'Igual';
    if (d == 1) return 'Peor';
    return 'Mucho peor';
  }

  MedicationOutcome copyWith({
    int? severityAfter,
    OutcomeReason? reason,
    DateTime? respondedAt,
    String? note,
  }) {
    return MedicationOutcome(
      id: id,
      doseId: doseId,
      symptomId: symptomId,
      medicationName: medicationName,
      symptomName: symptomName,
      doseTimestamp: doseTimestamp,
      checkAt: checkAt,
      severityBefore: severityBefore,
      severityAfter: severityAfter ?? this.severityAfter,
      reason: reason ?? this.reason,
      respondedAt: respondedAt ?? this.respondedAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'doseId': doseId,
        'symptomId': symptomId,
        'medicationName': medicationName,
        'symptomName': symptomName,
        'doseTimestamp': doseTimestamp.toIso8601String(),
        'checkAt': checkAt.toIso8601String(),
        'severityBefore': severityBefore,
        'severityAfter': severityAfter,
        'reason': reason?.name,
        'respondedAt': respondedAt?.toIso8601String(),
        'note': note,
      };

  factory MedicationOutcome.fromMap(Map<String, dynamic> map) => MedicationOutcome(
        id: map['id'],
        doseId: map['doseId'],
        symptomId: map['symptomId'],
        medicationName: map['medicationName'],
        symptomName: map['symptomName'],
        doseTimestamp: DateTime.parse(map['doseTimestamp']),
        checkAt: DateTime.parse(map['checkAt']),
        severityBefore: (map['severityBefore'] as num).toInt(),
        severityAfter: (map['severityAfter'] as num?)?.toInt(),
        reason: OutcomeReason.parse(map['reason'] as String?),
        respondedAt: map['respondedAt'] != null ? DateTime.parse(map['respondedAt']) : null,
        note: map['note'] as String?,
      );
}

// =============================================================================
// MEDICATION CATALOG (definitions + groups)
// =============================================================================

class MedicationDef {
  /// Stable id so MedicationGroup entries survive name edits.
  final String id;

  String name;
  double strength;          // numeric strength, e.g. 500
  String unit;              // 'mg', 'mcg', 'IU', 'g', 'ml', '' for unspecified
  String form;              // 'pill', 'capsule', 'drop', 'tablet', 'patch', 'spray', 'ml'
  double defaultQuantity;   // 1.0, 0.5, 2.0…

  /// Hours after a dose at which to ask "¿mejor / igual / peor?".
  /// Null = don't track outcomes (daily vitamins etc.).
  int? outcomeCheckHours;

  /// Free-form notes from the patient (e.g. "tomar con comida").
  String? notes;

  /// Active ingredient (INN). Populated later by CIMA lookup.
  String? activeIngredient;

  /// CIMA registration code (Spain) once matched.
  String? cimaCode;

  MedicationDef({
    String? id,
    required this.name,
    this.strength = 0,
    this.unit = '',
    this.form = 'pill',
    this.defaultQuantity = 1.0,
    this.outcomeCheckHours = 3,
    this.notes,
    this.activeIngredient,
    this.cimaCode,
  }) : id = id ?? _newId();

  /// Human-readable dose summary for UI rows: "1 pill × 500mg".
  String get displayDose {
    final qty = _formatQuantity(defaultQuantity);
    final formLabel = _pluralizeForm(form, defaultQuantity);
    if (strength > 0 && unit.isNotEmpty) {
      final str = _formatQuantity(strength);
      return '$qty $formLabel × $str$unit';
    }
    return '$qty $formLabel';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'strength': strength,
        'unit': unit,
        'form': form,
        'defaultQuantity': defaultQuantity,
        'outcomeCheckHours': outcomeCheckHours,
        'notes': notes,
        'activeIngredient': activeIngredient,
        'cimaCode': cimaCode,
      };

  factory MedicationDef.fromMap(Map<String, dynamic> map) => MedicationDef(
        id: map['id'] as String?,
        name: map['name'],
        strength: (map['strength'] as num?)?.toDouble() ?? 0,
        unit: map['unit'] as String? ?? '',
        form: map['form'] as String? ?? 'pill',
        defaultQuantity: (map['defaultQuantity'] as num?)?.toDouble() ?? 1.0,
        outcomeCheckHours: map['outcomeCheckHours'] as int? ?? 3,
        notes: map['notes'] as String?,
        activeIngredient: map['activeIngredient'] as String?,
        cimaCode: map['cimaCode'] as String?,
      );
}

String _formatQuantity(double q) {
  if (q == q.roundToDouble()) return q.toInt().toString();
  return q.toString();
}

String _pluralizeForm(String form, double qty) {
  // Don't try to be clever in Spanish — just hand back the form. The UI
  // can localize if it wants. "1 pill" reads fine for English; for Spanish
  // we use 'pastilla', 'cápsula', 'gota', 'parche' as the form value at
  // creation time and accept that "1 gotas" is mildly weird and ignorable.
  return form;
}

class MedicationGroupEntry {
  /// Foreign key to MedicationDef.id.
  final String medicationId;
  /// How many of the form unit when this group is logged.
  /// Overrides MedicationDef.defaultQuantity for batch logging.
  double quantity;

  MedicationGroupEntry({required this.medicationId, this.quantity = 1.0});

  Map<String, dynamic> toMap() => {
        'medicationId': medicationId,
        'quantity': quantity,
      };

  factory MedicationGroupEntry.fromMap(Map<String, dynamic> map) =>
      MedicationGroupEntry(
        medicationId: map['medicationId'] as String,
        quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      );
}

/// A reusable batch of meds — e.g. "Meds de la noche @ 22:00".
/// Tapping the group on the Botiquín tab logs every entry in one shot.
class MedicationGroup {
  final String id;
  String name;
  /// Default time-of-day in minutes since midnight, or null if no default.
  /// Stored as int (not TimeOfDay) so the model has no Flutter dependency.
  int? defaultTimeMinutes;
  List<MedicationGroupEntry> entries;

  MedicationGroup({
    String? id,
    required this.name,
    this.defaultTimeMinutes,
    List<MedicationGroupEntry>? entries,
  })  : id = id ?? _newId(),
        entries = entries ?? <MedicationGroupEntry>[];

  /// Apply defaultTimeMinutes to a date — convenience for the "log this group
  /// for today at its default time" gesture.
  DateTime? defaultTimeOn(DateTime date) {
    final m = defaultTimeMinutes;
    if (m == null) return null;
    return DateTime(date.year, date.month, date.day, m ~/ 60, m % 60);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'defaultTimeMinutes': defaultTimeMinutes,
        'entries': entries.map((e) => e.toMap()).toList(),
      };

  factory MedicationGroup.fromMap(Map<String, dynamic> map) => MedicationGroup(
        id: map['id'] as String?,
        name: map['name'] as String,
        defaultTimeMinutes: map['defaultTimeMinutes'] as int?,
        entries: List<MedicationGroupEntry>.from(
          (map['entries'] as List? ?? const []).map((e) =>
              MedicationGroupEntry.fromMap(Map<String, dynamic>.from(e as Map))),
        ),
      );
}

// =============================================================================
// EXERCISE CATALOG (unchanged)
// =============================================================================

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

// =============================================================================
// WISDOM + CLINICAL ARTICLES (small DTOs, unchanged)
// =============================================================================

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

// =============================================================================
// PUBMED CACHE (unchanged)
// =============================================================================

class PubMedArticle {
  final String pmid;
  final String title;
  final String? abstractText;
  final String journal;
  final List<String> authors;
  final DateTime publicationDate;
  final DateTime cachedAt;
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
        authors: List<String>.from(map['authors'] ?? const []),
        publicationDate: DateTime.parse(map['publicationDate']),
        cachedAt: DateTime.parse(map['cachedAt']),
        fetchedForConditions:
            List<String>.from(map['fetchedForConditions'] ?? const []),
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

// =============================================================================
// PROFILE — patient (or caregiver) analytics engine
// =============================================================================

class Profile {
  final String id;
  String name;
  String? relationship;
  List<String> conditions;
  String? country; // For clinical-trial filtering later

  List<String> symptomVault;

  /// Med catalog for this profile (the "botiquín").
  List<MedicationDef> botiquin;

  /// Reusable batch logs (Bearable-style "morning meds", "night meds").
  List<MedicationGroup> medicationGroups;

  // Time-series history
  List<SymptomEvent> symptomHistory;
  List<DoseEvent> doseHistory;
  List<MoodEntry> moodHistory;
  List<StructuralEvent> structuralHistory;
  List<MentalEvent> mentalHistory;
  List<ActivityEvent> activityHistory;
  List<TherapyEvent> therapyHistory;
  List<String> customTherapyModalities;
  List<MedicationOutcome> medicationOutcomes;

  Set<String> pacingDays;

  /// PMIDs the user starred from PubMed search.
  Set<String> savedArticlePmids;

  Profile({
    required this.id,
    required this.name,
    required this.conditions,
    required this.symptomVault,
    required this.botiquin,
    this.customExercises = const [],
    this.moodHistory = const [],
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

  int? latestMentalSeverity(MentalState state, DateTime date) {
    final today = getMentalForDay(date).where((e) => e.state == state).toList();
    if (today.isEmpty) return null;
    today.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return today.first.severity;
  }

  /// Symptoms logged in the last [hours] hours at severity >= moderate (2).
  /// Used when logging a dose to suggest a recent symptom to link.
  List<SymptomEvent> recentSignificantSymptoms({int hours = 2}) {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return symptomHistory
        .where((s) =>
            s.timestamp.isAfter(cutoff) && s.severity.value >= SymptomSeverity.moderate.value)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Pending outcomes that have crossed their checkAt.
  List<MedicationOutcome> getDueOutcomes() =>
      medicationOutcomes.where((o) => o.isDue).toList()
        ..sort((a, b) => a.checkAt.compareTo(b.checkAt));

  /// Effect-size summary for a (medication, symptom) pair.
  ///
  /// Returns the mean delta across answered outcomes (e.g. -1.8 means
  /// the med drops severity by ~1.8 points on the 0–4 scale), the count
  /// of answered outcomes, and the count of times the user reported
  /// improvement (delta < 0). Returns null if there are no answered
  /// outcomes yet.
  ///
  /// Outcomes with reason == `otherTrigger` or `additionalMed` are
  /// excluded — those tell us the change probably wasn't this med.
  ({double meanDelta, int total, int improved})? effectivenessFor(
    String medName,
    String symptomName,
  ) {
    final medLower = medName.toLowerCase();
    final sxLower = symptomName.toLowerCase();
    final answered = medicationOutcomes.where((o) {
      if (o.medicationName.toLowerCase() != medLower) return false;
      if (o.symptomName.toLowerCase() != sxLower) return false;
      if (o.isPending) return false;
      if (o.reason == OutcomeReason.otherTrigger ||
          o.reason == OutcomeReason.additionalMed) return false;
      return true;
    }).toList();
    if (answered.isEmpty) return null;
    var sum = 0.0;
    var improved = 0;
    for (final o in answered) {
      final d = o.delta!;
      sum += d;
      if (d < 0) improved++;
    }
    return (
      meanDelta: sum / answered.length,
      total: answered.length,
      improved: improved,
    );
  }

  // ---------------------------------------------------------------------------
  // Mutators — batch group logging
  // ---------------------------------------------------------------------------

  /// Log every entry in a medication group as a single batch at [timestamp].
  /// Returns the created DoseEvents. Does NOT call save — caller is
  /// responsible for persistence so this stays UI-framework-free.
  ///
  /// [linkedSymptomIds] and [severityBefore] are applied to every dose in
  /// the batch; for a single-symptom acute use case (rare for night meds,
  /// common for an as-needed group), the UI can pre-collect a severity and
  /// pass it through.
  List<DoseEvent> logGroup(
    MedicationGroup group, {
    required DateTime timestamp,
    List<String> linkedSymptomIds = const [],
    Map<String, int> severityBefore = const {},
  }) {
    final created = <DoseEvent>[];
    for (final entry in group.entries) {
      final med = findMedById(entry.medicationId);
      if (med == null) continue; // referenced med was deleted; skip silently
      final dose = DoseEvent(
        timestamp: timestamp,
        medicationName: med.name,
        medicationId: med.id,
        quantity: entry.quantity,
        strengthAtDose: med.strength,
        unitAtDose: med.unit,
        formAtDose: med.form,
        linkedSymptomIds: linkedSymptomIds,
        severityBefore: severityBefore,
        groupId: group.id,
      );
      doseHistory.add(dose);
      created.add(dose);
    }
    return created;
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'conditions': conditions,
        'country': country,
        'symptomVault': symptomVault,
        'customExercises': customExercises,
        'pacingDays': pacingDays.toList(),
        'savedArticlePmids': savedArticlePmids.toList(),
        'botiquin': botiquin.map((x) => x.toMap()).toList(),
        'medicationGroups': medicationGroups.map((x) => x.toMap()).toList(),
        'symptomHistory': symptomHistory.map((x) => x.toMap()).toList(),
        'doseHistory': doseHistory.map((x) => x.toMap()).toList(),
        'moodHistory': moodHistory.map((m) => m.toMap()).toList(),
        'structuralHistory': structuralHistory.map((x) => x.toMap()).toList(),
        'mentalHistory': mentalHistory.map((x) => x.toMap()).toList(),
        'activityHistory': activityHistory.map((x) => x.toMap()).toList(),
        'medicationOutcomes': medicationOutcomes.map((x) => x.toMap()).toList(),
        'therapyHistory': therapyHistory.map((t) => t.toMap()).toList(),
        'relationship': relationship,
        'lifeEvents': lifeEvents.map((e) => e.toMap()).toList(),
        'customTherapyModalities': customTherapyModalities,
        'homeLatitude': homeLatitude,
        'homeLongitude': homeLongitude,
        'bowelHistory': bowelHistory.map((x) => x.toMap()).toList(),
        'hemorrhoidalHistory':
            hemorrhoidalHistory.map((x) => x.toMap()).toList(),
        'sleepHistory': sleepHistory.map((x) => x.toMap()).toList(),
        'hydrationHistory': hydrationHistory.map((x) => x.toMap()).toList(),
        'hrvHistory': hrvHistory.map((x) => x.toMap()).toList(),
        'movementHistory': movementHistory.map((x) => x.toMap()).toList(),
        'feverHistory': feverHistory.map((x) => x.toMap()).toList(),
        'optionalTrackers': optionalTrackers,
      };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'],
        name: map['name'],
        conditions: List<String>.from(map['conditions'] ?? const []),
        country: map['country'] as String?,
        symptomVault: List<String>.from(map['symptomVault'] ?? []),
        pacing: Set<String>.from(map['pacingDays'] ?? []),
        saved: Set<String>.from(map['savedArticlePmids'] ?? []),
        botiquin: List<MedicationDef>.from(
          (map['botiquin'] ?? const []).map(
              (x) => MedicationDef.fromMap(Map<String, dynamic>.from(x as Map))),
        ),
        medicationGroups: List<MedicationGroup>.from(
          (map['medicationGroups'] ?? const []).map((x) =>
              MedicationGroup.fromMap(Map<String, dynamic>.from(x as Map))),
        ),
        symptoms: List<SymptomEvent>.from(
          (map['symptomHistory'] ?? const []).map(
              (x) => SymptomEvent.fromMap(Map<String, dynamic>.from(x as Map))),
        ),
        doses: List<DoseEvent>.from(
            (map['doseHistory'] ?? []).map((x) => DoseEvent.fromMap(x))),
        structural: List<StructuralEvent>.from(
          (map['structuralHistory'] ?? const []).map((x) =>
              StructuralEvent.fromMap(Map<String, dynamic>.from(x as Map))),
        ),
        mental: List<MentalEvent>.from(
          (map['mentalHistory'] ?? const []).map(
              (x) => MentalEvent.fromMap(Map<String, dynamic>.from(x as Map))),
        ),
        activity: List<ActivityEvent>.from(
            (map['activityHistory'] ?? []).map((x) => ActivityEvent.fromMap(x))),
        outcomes: List<MedicationOutcome>.from((map['medicationOutcomes'] ?? [])
            .map((x) => MedicationOutcome.fromMap(x))),
      );
}