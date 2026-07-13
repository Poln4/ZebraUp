// Sprint F — Transversal ActionTaken schema
//
// Captures actions the user takes in response to a health event
// (medication, rest, hydration, breathing, etc.) and optionally tracks
// the effectiveness of that action at a user-selected follow-up
// interval.
//
// This model is transversal — a single ActionTaken instance can be
// linked to any typed event via polymorphic linkedEventId +
// linkedEventType discriminator. Supported event types:
//   - SymptomEvent   (linkedEventType = symptom)
//   - BowelEvent     (linkedEventType = bowel)
//   - HemorrhoidalEvent (linkedEventType = hemorrhoidal)
//   - FeverReading   (linkedEventType = fever)
//
// Design decisions traceable in
// docs/design_decisions/symptom_detail_layers.md (Sprint F section
// added by F Part C).
//
// Movement kind: users choosing ActionKind.movement are directed to
// the movement tab for detailed capture (acupuncture, TENS, exercise,
// stretching). The ActionTaken record retains only the kind marker
// and timestamp; correlation with MovementMetric records happens
// via timestamp proximity in post-hoc analytics, NOT via a hard FK.
// This preserves loose coupling between the two subsystems.
//
// Follow-up windows (minutes): 30, 60 (default), 90, 1440 (24h).
// The 24h window enables PEM pattern capture (Mateo LJ et al. 2020,
// DOI: 10.3233/wor-203168 — 24-72h delayed onset window per Jason
// LA et al. 2010, DOI: 10.1080/08964280903521370) and MCAS delayed
// reactions (Weiler CR et al. 2019 AAAAI consensus).

import 'dart:math';

/// Category of action taken in response to a health event. `medication`
/// links to a MedicationDef via medicationRefId. `movement` is a
/// pointer — the user logs details in the movement tab separately.
/// `custom` is the escape hatch for actions not covered by the other
/// kinds; the customLabel field carries the user's free-text.
enum ActionKind {
  medication('medication'),
  rest('rest'),
  hydration('hydration'),
  breathing('breathing'),
  heat('heat'),
  cold('cold'),
  elevation('elevation'),
  sensoryReduction('sensory_reduction'),
  socialWithdrawal('social_withdrawal'),
  food('food'),
  movement('movement'),
  // Sprint F.E — retro flow: user checked in and took no action.
  // Filtered out of ActionTakenSheet (F.B+C) picker; visible only in
  // RetroSymptomDialog.
  nothing('nothing'),
  custom('custom');

  final String serializationKey;
  const ActionKind(this.serializationKey);

  static ActionKind? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// User's rating of how well an action worked, captured at follow-up.
/// `partialReliefThenReturned` handles the common pattern in migraine
/// (triptán) and MCAS (antihistamínico) where the symptom is relieved
/// briefly and then returns.
enum EffectivenessRating {
  muchRelief('much_relief'),
  someRelief('some_relief'),
  partialReliefThenReturned('partial_relief_then_returned'),
  noChange('no_change'),
  worse('worse');

  final String serializationKey;
  const EffectivenessRating(this.serializationKey);

  static EffectivenessRating? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

/// Discriminator for the polymorphic linkedEventId FK. Extensible —
/// add new values as more typed events become linkable (SleepEntry,
/// HydrationReading, etc.). Additive changes only; do not repurpose
/// existing keys.
enum LinkedEventType {
  symptom('symptom'),
  bowel('bowel'),
  hemorrhoidal('hemorrhoidal'),
  fever('fever');

  final String serializationKey;
  const LinkedEventType(this.serializationKey);

  static LinkedEventType? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

final _rand = Random.secure();

String _newActionId() {
  final hex = List.generate(
    6,
    (_) => _rand.nextInt(16).toRadixString(16),
  ).join();
  return '${DateTime.now().microsecondsSinceEpoch}-$hex';
}

/// A user action in response to a health event, with optional
/// follow-up effectiveness capture.
///
/// All fields except id / timestamp / kind / linkedEventId /
/// linkedEventType are optional. The record is meaningful even without
/// a follow-up — the user may skip it or defer it indefinitely.
///
/// Follow-up state is derived from stored data:
///   - hasPendingFollowUp: true when followUpMinutes is set AND
///     followUpCompleted is false
///   - followUpIsDue: true when hasPendingFollowUp AND clock has
///     passed followUpDueAt
///   - followUpDueAt: derived from timestamp + followUpMinutes
///
/// The reminder banner in hoy_tab (Sprint F.D) surfaces follow-ups
/// when followUpIsDue is true and prompts the user to complete the
/// effectiveness capture dialog.
class ActionTaken {
  final String id;
  final DateTime timestamp;
  final ActionKind kind;

  /// Polymorphic FK to the health event this action was in response to.
  final String linkedEventId;
  final LinkedEventType linkedEventType;

  /// When kind == medication, references MedicationDef.id from the
  /// user's Botiquín. Null for non-medication kinds.
  final String? medicationRefId;

  /// When kind == custom, the user-provided free-text label
  /// (e.g., "salt supplement", "cold shower"). Null for other kinds.
  final String? customLabel;

  /// Severity of the linked event immediately before the action, on
  /// the SymptomSeverity 0-4 scale. Optional — user may skip. Stored
  /// as int to keep this model decoupled from the SymptomSeverity enum.
  final int? severityBeforeAction;

  /// Severity of the linked event at the follow-up moment. Populated
  /// when the follow-up dialog is answered.
  final int? severityAfterAction;

  /// User-selected follow-up interval in minutes. Valid values: 30,
  /// 60, 90, 1440. Null when no follow-up was scheduled.
  final int? followUpMinutes;

  /// True when the follow-up dialog has been answered (regardless of
  /// what the user picked). Prevents re-prompting.
  final bool followUpCompleted;

  /// User's rating of the action's effectiveness. Populated at
  /// follow-up completion.
  final EffectivenessRating? effectivenessRating;

  /// Free-text notes on the action or its outcome.
  final String? notes;

  ActionTaken({
    String? id,
    required this.timestamp,
    required this.kind,
    required this.linkedEventId,
    required this.linkedEventType,
    this.medicationRefId,
    this.customLabel,
    this.severityBeforeAction,
    this.severityAfterAction,
    this.followUpMinutes,
    this.followUpCompleted = false,
    this.effectivenessRating,
    this.notes,
  }) : id = id ?? _newActionId();

  /// Computed follow-up due timestamp. Null if no follow-up scheduled.
  DateTime? get followUpDueAt {
    if (followUpMinutes == null) return null;
    return timestamp.add(Duration(minutes: followUpMinutes!));
  }

  /// True when a follow-up is scheduled but not yet answered.
  bool get hasPendingFollowUp => followUpMinutes != null && !followUpCompleted;

  /// True when the follow-up window has elapsed and awaits capture.
  bool get followUpIsDue {
    if (!hasPendingFollowUp) return false;
    return DateTime.now().isAfter(followUpDueAt!);
  }

  /// True when the record carries no meaningful content — used to
  /// short-circuit persistence of accidental blank entries.
  bool get isEmpty =>
      kind == ActionKind.custom &&
      customLabel == null &&
      medicationRefId == null &&
      severityBeforeAction == null;

  ActionTaken copyWith({
    ActionKind? kind,
    String? medicationRefId,
    String? customLabel,
    int? severityBeforeAction,
    int? severityAfterAction,
    int? followUpMinutes,
    bool? followUpCompleted,
    EffectivenessRating? effectivenessRating,
    String? notes,
    bool clearMedicationRefId = false,
    bool clearCustomLabel = false,
    bool clearSeverityBeforeAction = false,
    bool clearSeverityAfterAction = false,
    bool clearFollowUp = false,
    bool clearEffectivenessRating = false,
    bool clearNotes = false,
  }) {
    return ActionTaken(
      id: id,
      timestamp: timestamp,
      linkedEventId: linkedEventId,
      linkedEventType: linkedEventType,
      kind: kind ?? this.kind,
      medicationRefId: clearMedicationRefId
          ? null
          : (medicationRefId ?? this.medicationRefId),
      customLabel: clearCustomLabel ? null : (customLabel ?? this.customLabel),
      severityBeforeAction: clearSeverityBeforeAction
          ? null
          : (severityBeforeAction ?? this.severityBeforeAction),
      severityAfterAction: clearSeverityAfterAction
          ? null
          : (severityAfterAction ?? this.severityAfterAction),
      followUpMinutes: clearFollowUp
          ? null
          : (followUpMinutes ?? this.followUpMinutes),
      followUpCompleted: followUpCompleted ?? this.followUpCompleted,
      effectivenessRating: clearEffectivenessRating
          ? null
          : (effectivenessRating ?? this.effectivenessRating),
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  /// Serialization omits null / empty fields to keep exported profiles
  /// compact.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'kind': kind.serializationKey,
      'linkedEventId': linkedEventId,
      'linkedEventType': linkedEventType.serializationKey,
      'followUpCompleted': followUpCompleted,
    };
    if (medicationRefId != null) map['medicationRefId'] = medicationRefId;
    if (customLabel != null) map['customLabel'] = customLabel;
    if (severityBeforeAction != null) {
      map['severityBeforeAction'] = severityBeforeAction;
    }
    if (severityAfterAction != null) {
      map['severityAfterAction'] = severityAfterAction;
    }
    if (followUpMinutes != null) map['followUpMinutes'] = followUpMinutes;
    if (effectivenessRating != null) {
      map['effectivenessRating'] = effectivenessRating!.serializationKey;
    }
    if (notes != null) map['notes'] = notes;
    return map;
  }

  factory ActionTaken.fromMap(Map<String, dynamic> map) {
    return ActionTaken(
      id: map['id'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      kind: ActionKind.fromKey(map['kind'] as String?) ?? ActionKind.custom,
      linkedEventId: map['linkedEventId'] as String,
      linkedEventType:
          LinkedEventType.fromKey(map['linkedEventType'] as String?) ??
          LinkedEventType.symptom,
      medicationRefId: map['medicationRefId'] as String?,
      customLabel: map['customLabel'] as String?,
      severityBeforeAction: (map['severityBeforeAction'] as num?)?.toInt(),
      severityAfterAction: (map['severityAfterAction'] as num?)?.toInt(),
      followUpMinutes: (map['followUpMinutes'] as num?)?.toInt(),
      followUpCompleted: map['followUpCompleted'] as bool? ?? false,
      effectivenessRating: EffectivenessRating.fromKey(
        map['effectivenessRating'] as String?,
      ),
      notes: map['notes'] as String?,
    );
  }
}
