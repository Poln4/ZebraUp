#!/usr/bin/env python3
"""
ZebraUp — Phase 5.0 patch: lib/models/models.dart
=================================================

Adds six new event types (BowelEvent, HemorrhoidalEvent, SleepEntry,
HydrationEntry, HrvReading, MovementMetric) plus the matching history
lists on Profile. All additions are backwards-compatible: every new
collection defaults to empty in fromMap, so v1 exports keep importing.

Run from the repo root (the directory that contains lib/).
Idempotent: detects the sentinel block and reports SKIP on second run.
"""

import sys
from pathlib import Path

TARGET = Path("lib/models/models.dart")
SENTINEL = "// PHASE 5 — EMA EXPANSION MODELS (schema v2)"

# ---------------------------------------------------------------------------
# New models block — appended to the end of models.dart
# ---------------------------------------------------------------------------

NEW_MODELS_BLOCK = """

// =============================================================================
// PHASE 5 — EMA EXPANSION MODELS (schema v2)
// =============================================================================
// Six new event types added in Phase 5.0 as the data-layer foundation for
// the GI / sleep / hydration / HRV / movement tracks. All fields are
// additive and backwards-compatible: `fromMap` tolerates missing keys so
// v1 exports keep working.
//
// Schema-versioning rule (Phase 5.0 onwards):
//   - profile_io_service.dart owns the schemaVersion constant (now 2).
//   - Profile.fromMap reads new collections under their own keys with a
//     `?? const []` fallback so old exports just produce empty lists.
//   - No field on an existing model has changed shape. Phase 5.0 is purely
//     additive.
// =============================================================================

// -----------------------------------------------------------------------------
// GI tract — bowel + hemorrhoidal (5.1, 5.2)
// -----------------------------------------------------------------------------

/// 3-tier simplification of the Bristol Stool Scale (Dale et al. 2024).
/// The full 7-point scale is preserved in `BowelEvent.bristolType` for users
/// who tap "más detalle" — this enum is the primary UI bucket.
enum BowelBucket {
  constipation(1, 'estreñimiento'), // BSS 1–2
  normal(2, 'normal'),               // BSS 3–5
  diarrhea(3, 'diarrea');            // BSS 6–7

  final int value;
  final String label;
  const BowelBucket(this.value, this.label);

  static BowelBucket fromValue(int v) {
    return values.firstWhere((b) => b.value == v,
        orElse: () => BowelBucket.normal);
  }

  static BowelBucket? parse(String? raw) {
    if (raw == null) return null;
    for (final b in values) {
      if (b.name == raw) return b;
    }
    return null;
  }
}

class BowelEvent {
  final String id;
  final DateTime timestamp;
  final BowelBucket bucket;
  /// Optional full 7-point Bristol type for users who tap "más detalle".
  final int? bristolType;
  /// 0–4 severity — reuses SymptomSeverity for consistent dot UI.
  final SymptomSeverity severity;
  final bool urgency;
  final bool bloodPresent;
  final bool incompleteEvacuation;
  /// Future-proofing for photo logging — privacy conversation deferred.
  /// No UI surfaces this field in Phase 5.
  final String? photoPath;
  final String? note;

  BowelEvent({
    String? id,
    required this.timestamp,
    required this.bucket,
    this.bristolType,
    this.severity = SymptomSeverity.none,
    this.urgency = false,
    this.bloodPresent = false,
    this.incompleteEvacuation = false,
    this.photoPath,
    this.note,
  }) : id = id ?? _newId();

  BowelEvent copyWith({
    DateTime? timestamp,
    BowelBucket? bucket,
    int? bristolType,
    SymptomSeverity? severity,
    bool? urgency,
    bool? bloodPresent,
    bool? incompleteEvacuation,
    String? photoPath,
    String? note,
  }) {
    return BowelEvent(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      bucket: bucket ?? this.bucket,
      bristolType: bristolType ?? this.bristolType,
      severity: severity ?? this.severity,
      urgency: urgency ?? this.urgency,
      bloodPresent: bloodPresent ?? this.bloodPresent,
      incompleteEvacuation: incompleteEvacuation ?? this.incompleteEvacuation,
      photoPath: photoPath ?? this.photoPath,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'bucket': bucket.name,
        'bristolType': bristolType,
        'severity': severity.value,
        'urgency': urgency,
        'bloodPresent': bloodPresent,
        'incompleteEvacuation': incompleteEvacuation,
        'photoPath': photoPath,
        'note': note,
      };

  factory BowelEvent.fromMap(Map<String, dynamic> map) => BowelEvent(
        id: map['id'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
        bucket: BowelBucket.parse(map['bucket'] as String?) ??
            BowelBucket.normal,
        bristolType: (map['bristolType'] as num?)?.toInt(),
        severity: SymptomSeverity.fromValue(
          (map['severity'] as num?)?.toInt() ?? 0,
        ),
        urgency: map['urgency'] as bool? ?? false,
        bloodPresent: map['bloodPresent'] as bool? ?? false,
        incompleteEvacuation: map['incompleteEvacuation'] as bool? ?? false,
        photoPath: map['photoPath'] as String?,
        note: map['note'] as String?,
      );
}

/// Hemorrhoidal event — logged independently from bowel events.
/// EDS-hemorrhoid connective tissue link: Plackett 2014, Parol 2025, Sandler 2019.
class HemorrhoidalEvent {
  final String id;
  final DateTime timestamp;
  final bool bleeding;
  /// 0–4 discomfort/pain severity.
  final SymptomSeverity severity;
  final String? note;

  HemorrhoidalEvent({
    String? id,
    required this.timestamp,
    this.bleeding = false,
    this.severity = SymptomSeverity.none,
    this.note,
  }) : id = id ?? _newId();

  HemorrhoidalEvent copyWith({
    DateTime? timestamp,
    bool? bleeding,
    SymptomSeverity? severity,
    String? note,
  }) {
    return HemorrhoidalEvent(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      bleeding: bleeding ?? this.bleeding,
      severity: severity ?? this.severity,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'bleeding': bleeding,
        'severity': severity.value,
        'note': note,
      };

  factory HemorrhoidalEvent.fromMap(Map<String, dynamic> map) =>
      HemorrhoidalEvent(
        id: map['id'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
        bleeding: map['bleeding'] as bool? ?? false,
        severity: SymptomSeverity.fromValue(
          (map['severity'] as num?)?.toInt() ?? 0,
        ),
        note: map['note'] as String?,
      );
}

// -----------------------------------------------------------------------------
// Sleep (5.1b)
// -----------------------------------------------------------------------------

enum SleepQuality {
  bad(1, 'mal'),
  regular(2, 'regular'),
  good(3, 'bien'),
  veryGood(4, 'muy bien');

  final int value;
  final String label;
  const SleepQuality(this.value, this.label);

  static SleepQuality? parse(String? raw) {
    if (raw == null) return null;
    for (final q in values) {
      if (q.name == raw) return q;
    }
    return null;
  }

  static SleepQuality fromValue(int v) {
    return values.firstWhere((q) => q.value == v,
        orElse: () => SleepQuality.regular);
  }
}

/// One entry per night. `dateKey` is the YYYY-MM-DD of the *waking* day —
/// an entry logged Monday morning carries Monday's dateKey and refers to
/// Sunday night → Monday morning sleep.
class SleepEntry {
  final String id;
  final DateTime timestamp;
  final String dateKey;
  final SleepQuality quality;
  final int? durationMinutes;
  /// "¿te costó dormirte?" — minutes from bedtime to falling asleep.
  final int? onsetLatencyMinutes;
  /// Number of mid-night wake-ups.
  final int? wakeCount;
  /// Single yes/no, no narrative, no severity (deliberate — see 5.1b).
  final bool? nightmare;
  final String? note;

  SleepEntry({
    String? id,
    required this.timestamp,
    required this.dateKey,
    required this.quality,
    this.durationMinutes,
    this.onsetLatencyMinutes,
    this.wakeCount,
    this.nightmare,
    this.note,
  }) : id = id ?? _newId();

  SleepEntry copyWith({
    DateTime? timestamp,
    String? dateKey,
    SleepQuality? quality,
    int? durationMinutes,
    int? onsetLatencyMinutes,
    int? wakeCount,
    bool? nightmare,
    String? note,
  }) {
    return SleepEntry(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      dateKey: dateKey ?? this.dateKey,
      quality: quality ?? this.quality,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      onsetLatencyMinutes: onsetLatencyMinutes ?? this.onsetLatencyMinutes,
      wakeCount: wakeCount ?? this.wakeCount,
      nightmare: nightmare ?? this.nightmare,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'dateKey': dateKey,
        'quality': quality.name,
        'durationMinutes': durationMinutes,
        'onsetLatencyMinutes': onsetLatencyMinutes,
        'wakeCount': wakeCount,
        'nightmare': nightmare,
        'note': note,
      };

  factory SleepEntry.fromMap(Map<String, dynamic> map) => SleepEntry(
        id: map['id'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
        dateKey: map['dateKey'] as String,
        quality: SleepQuality.parse(map['quality'] as String?) ??
            SleepQuality.regular,
        durationMinutes: (map['durationMinutes'] as num?)?.toInt(),
        onsetLatencyMinutes: (map['onsetLatencyMinutes'] as num?)?.toInt(),
        wakeCount: (map['wakeCount'] as num?)?.toInt(),
        nightmare: map['nightmare'] as bool?,
        note: map['note'] as String?,
      );
}

// -----------------------------------------------------------------------------
// Hydration (5.1c)
// -----------------------------------------------------------------------------

enum HydrationBeverage {
  water('agua'),
  electrolyte('electrolitos'),
  coffee('café'),
  other('otro');

  final String label;
  const HydrationBeverage(this.label);

  static HydrationBeverage? parse(String? raw) {
    if (raw == null) return null;
    for (final b in values) {
      if (b.name == raw) return b;
    }
    return null;
  }
}

/// Sodium source tagged onto a hydration entry. No mg arithmetic in v1 —
/// POTS sodium guidance is by cluster, not by total.
enum SodiumSource {
  pinch('pizca de sal'),
  sachet('sobre de electrolitos'),
  saltySnack('snack salado');

  final String label;
  const SodiumSource(this.label);

  static SodiumSource? parse(String? raw) {
    if (raw == null) return null;
    for (final s in values) {
      if (s.name == raw) return s;
    }
    return null;
  }
}

class HydrationEntry {
  final String id;
  final DateTime timestamp;
  /// Volume in ml. Null = pure sodium log with no fluid intake.
  final double? volumeMl;
  /// Beverage type. Null on a pure sodium log.
  final HydrationBeverage? beverage;
  /// Optional sodium tag. Null = plain water (or no added sodium).
  final SodiumSource? sodium;
  final String? note;

  HydrationEntry({
    String? id,
    required this.timestamp,
    this.volumeMl,
    this.beverage,
    this.sodium,
    this.note,
  }) : id = id ?? _newId();

  HydrationEntry copyWith({
    DateTime? timestamp,
    double? volumeMl,
    HydrationBeverage? beverage,
    SodiumSource? sodium,
    String? note,
  }) {
    return HydrationEntry(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      volumeMl: volumeMl ?? this.volumeMl,
      beverage: beverage ?? this.beverage,
      sodium: sodium ?? this.sodium,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'volumeMl': volumeMl,
        'beverage': beverage?.name,
        'sodium': sodium?.name,
        'note': note,
      };

  factory HydrationEntry.fromMap(Map<String, dynamic> map) => HydrationEntry(
        id: map['id'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
        volumeMl: (map['volumeMl'] as num?)?.toDouble(),
        beverage: HydrationBeverage.parse(map['beverage'] as String?),
        sodium: SodiumSource.parse(map['sodium'] as String?),
        note: map['note'] as String?,
      );
}

// -----------------------------------------------------------------------------
// HRV (5.6, 5.7)
// -----------------------------------------------------------------------------

enum HrvContext {
  morning('matinal'),
  afternoon('tarde'),
  evening('noche'),
  postExercise('post-ejercicio'),
  other('otro');

  final String label;
  const HrvContext(this.label);

  static HrvContext? parse(String? raw) {
    if (raw == null) return null;
    for (final c in values) {
      if (c.name == raw) return c;
    }
    return null;
  }
}

/// Single HRV (RMSSD) reading. `source` defaults to 'manual' and is
/// future-proofed for sensor-fed readings once mobile lands.
class HrvReading {
  final String id;
  final DateTime timestamp;
  /// RMSSD in milliseconds.
  final double rmssdMs;
  final HrvContext context;
  /// Free-form source identifier. 'manual' for keyed-in values; later
  /// 'oura', 'whoop', 'welltory', 'polar', 'healthkit', etc.
  final String source;
  final String? note;

  HrvReading({
    String? id,
    required this.timestamp,
    required this.rmssdMs,
    this.context = HrvContext.morning,
    this.source = 'manual',
    this.note,
  }) : id = id ?? _newId();

  HrvReading copyWith({
    DateTime? timestamp,
    double? rmssdMs,
    HrvContext? context,
    String? source,
    String? note,
  }) {
    return HrvReading(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      rmssdMs: rmssdMs ?? this.rmssdMs,
      context: context ?? this.context,
      source: source ?? this.source,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'rmssdMs': rmssdMs,
        'context': context.name,
        'source': source,
        'note': note,
      };

  factory HrvReading.fromMap(Map<String, dynamic> map) => HrvReading(
        id: map['id'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
        rmssdMs: (map['rmssdMs'] as num).toDouble(),
        context: HrvContext.parse(map['context'] as String?) ??
            HrvContext.morning,
        source: map['source'] as String? ?? 'manual',
        note: map['note'] as String?,
      );
}

// -----------------------------------------------------------------------------
// Movement metrics (5.5, 5.8)
// -----------------------------------------------------------------------------

/// Per-day movement summary. The user picks one unit of measure (steps /
/// active minutes / exercises completed / personalizado) in 5.5 settings;
/// the UI prompts for that field. The others may be populated later by
/// sensor integrations without breaking existing entries.
class MovementMetric {
  final String id;
  final DateTime timestamp;
  final String dateKey; // YYYY-MM-DD
  final int? steps;
  final int? activeMinutes;
  final int? exercisesCompleted;
  /// Free-form quantity if the user chose 'personalizado' in 5.5 settings.
  final double? customValue;
  final String? customUnit; // e.g. 'km', 'series'
  final String? note;

  MovementMetric({
    String? id,
    required this.timestamp,
    required this.dateKey,
    this.steps,
    this.activeMinutes,
    this.exercisesCompleted,
    this.customValue,
    this.customUnit,
    this.note,
  }) : id = id ?? _newId();

  MovementMetric copyWith({
    DateTime? timestamp,
    String? dateKey,
    int? steps,
    int? activeMinutes,
    int? exercisesCompleted,
    double? customValue,
    String? customUnit,
    String? note,
  }) {
    return MovementMetric(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      dateKey: dateKey ?? this.dateKey,
      steps: steps ?? this.steps,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      customValue: customValue ?? this.customValue,
      customUnit: customUnit ?? this.customUnit,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'dateKey': dateKey,
        'steps': steps,
        'activeMinutes': activeMinutes,
        'exercisesCompleted': exercisesCompleted,
        'customValue': customValue,
        'customUnit': customUnit,
        'note': note,
      };

  factory MovementMetric.fromMap(Map<String, dynamic> map) => MovementMetric(
        id: map['id'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
        dateKey: map['dateKey'] as String,
        steps: (map['steps'] as num?)?.toInt(),
        activeMinutes: (map['activeMinutes'] as num?)?.toInt(),
        exercisesCompleted: (map['exercisesCompleted'] as num?)?.toInt(),
        customValue: (map['customValue'] as num?)?.toDouble(),
        customUnit: map['customUnit'] as String?,
        note: map['note'] as String?,
      );
}
"""

# ---------------------------------------------------------------------------
# Surgical edits to the Profile class — all anchors must be unique in file.
# ---------------------------------------------------------------------------

PROFILE_FIELDS_ANCHOR = """  List<MedicationOutcome> medicationOutcomes;

  // Weather"""

PROFILE_FIELDS_INSERTION = """  List<MedicationOutcome> medicationOutcomes;

  // Phase 5.0 — EMA expansion (schema v2). All additive.
  List<BowelEvent> bowelHistory;
  List<HemorrhoidalEvent> hemorrhoidalHistory;
  List<SleepEntry> sleepHistory;
  List<HydrationEntry> hydrationHistory;
  List<HrvReading> hrvHistory;
  List<MovementMetric> movementHistory;

  // Weather"""

PROFILE_PARAMS_ANCHOR = """    Set<String>? saved,
  })  : medicationGroups = medicationGroups ?? <MedicationGroup>[],"""

PROFILE_PARAMS_INSERTION = """    Set<String>? saved,
    List<BowelEvent>? bowel,
    List<HemorrhoidalEvent>? hemorrhoidal,
    List<SleepEntry>? sleep,
    List<HydrationEntry>? hydration,
    List<HrvReading>? hrv,
    List<MovementMetric>? movement,
  })  : medicationGroups = medicationGroups ?? <MedicationGroup>[],"""

PROFILE_INIT_ANCHOR = """        pacingDays = pacing ?? <String>{},
        savedArticlePmids = saved ?? <String>{};"""

PROFILE_INIT_INSERTION = """        pacingDays = pacing ?? <String>{},
        savedArticlePmids = saved ?? <String>{},
        bowelHistory = bowel ?? <BowelEvent>[],
        hemorrhoidalHistory = hemorrhoidal ?? <HemorrhoidalEvent>[],
        sleepHistory = sleep ?? <SleepEntry>[],
        hydrationHistory = hydration ?? <HydrationEntry>[],
        hrvHistory = hrv ?? <HrvReading>[],
        movementHistory = movement ?? <MovementMetric>[];"""

PROFILE_TOMAP_ANCHOR = """        'homeLatitude': homeLatitude,
        'homeLongitude': homeLongitude,
      };"""

PROFILE_TOMAP_INSERTION = """        'homeLatitude': homeLatitude,
        'homeLongitude': homeLongitude,
        'bowelHistory': bowelHistory.map((x) => x.toMap()).toList(),
        'hemorrhoidalHistory':
            hemorrhoidalHistory.map((x) => x.toMap()).toList(),
        'sleepHistory': sleepHistory.map((x) => x.toMap()).toList(),
        'hydrationHistory': hydrationHistory.map((x) => x.toMap()).toList(),
        'hrvHistory': hrvHistory.map((x) => x.toMap()).toList(),
        'movementHistory': movementHistory.map((x) => x.toMap()).toList(),
      };"""

PROFILE_FROMMAP_ANCHOR = """        homeLatitude: (map['homeLatitude'] as num?)?.toDouble(),
        homeLongitude: (map['homeLongitude'] as num?)?.toDouble(),
      );"""

PROFILE_FROMMAP_INSERTION = """        homeLatitude: (map['homeLatitude'] as num?)?.toDouble(),
        homeLongitude: (map['homeLongitude'] as num?)?.toDouble(),
        bowel: List<BowelEvent>.from(
          (map['bowelHistory'] ?? const []).map(
              (x) => BowelEvent.fromMap(Map<String, dynamic>.from(x as Map))),
        ),
        hemorrhoidal: List<HemorrhoidalEvent>.from(
          (map['hemorrhoidalHistory'] ?? const []).map((x) =>
              HemorrhoidalEvent.fromMap(Map<String, dynamic>.from(x as Map))),
        ),
        sleep: List<SleepEntry>.from(
          (map['sleepHistory'] ?? const []).map(
              (x) => SleepEntry.fromMap(Map<String, dynamic>.from(x as Map))),
        ),
        hydration: List<HydrationEntry>.from(
          (map['hydrationHistory'] ?? const []).map((x) =>
              HydrationEntry.fromMap(Map<String, dynamic>.from(x as Map))),
        ),
        hrv: List<HrvReading>.from(
          (map['hrvHistory'] ?? const []).map(
              (x) => HrvReading.fromMap(Map<String, dynamic>.from(x as Map))),
        ),
        movement: List<MovementMetric>.from(
          (map['movementHistory'] ?? const []).map((x) =>
              MovementMetric.fromMap(Map<String, dynamic>.from(x as Map))),
        ),
      );"""


def main():
    if not TARGET.exists():
        print(f"ERROR: {TARGET} not found. Run from repo root.", file=sys.stderr)
        sys.exit(1)

    src = TARGET.read_text(encoding="utf-8")

    if SENTINEL in src:
        print(f"SKIP: {TARGET} already contains Phase 5.0 models.")
        return

    edits = [
        (PROFILE_FIELDS_ANCHOR, PROFILE_FIELDS_INSERTION, "Profile fields"),
        (PROFILE_PARAMS_ANCHOR, PROFILE_PARAMS_INSERTION, "Profile constructor params"),
        (PROFILE_INIT_ANCHOR, PROFILE_INIT_INSERTION, "Profile initializer list"),
        (PROFILE_TOMAP_ANCHOR, PROFILE_TOMAP_INSERTION, "Profile.toMap"),
        (PROFILE_FROMMAP_ANCHOR, PROFILE_FROMMAP_INSERTION, "Profile.fromMap"),
    ]

    # Verify every anchor exists exactly once before mutating anything.
    for anchor, _, label in edits:
        n = src.count(anchor)
        if n != 1:
            print(
                f"ERROR: anchor for '{label}' found {n} times (expected 1). Aborting; no changes written.",
                file=sys.stderr,
            )
            sys.exit(2)

    out = src
    for anchor, insertion, _ in edits:
        out = out.replace(anchor, insertion)

    out = out.rstrip() + NEW_MODELS_BLOCK.rstrip() + "\n"

    TARGET.write_text(out, encoding="utf-8")
    print(f"OK: applied Phase 5.0 model additions to {TARGET}")
    print(f"  - 6 new models appended at end of file")
    print(f"  - Profile: 6 new history lists with backwards-compat fromMap")


if __name__ == "__main__":
    main()