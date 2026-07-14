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

import 'dart:math';

import 'headache_detail.dart';
import 'fatigue_detail.dart';
import 'abdominal_detail.dart';
import 'action_taken.dart';
import 'mcas.dart';
import 'medication_type.dart';
import 'profile_settings.dart';
import 'profile_state.dart';

// -----------------------------------------------------------------------------
// ID generation
// -----------------------------------------------------------------------------
String _newId() {
  final rand = Random.secure();
  final hex = List.generate(
    6,
    (_) => rand.nextInt(16).toRadixString(16),
  ).join();
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

// -----------------------------------------------------------------------------
// F5 — Functional severity anchors
// -----------------------------------------------------------------------------
// Each severity level on the 0–4 scale carries a short *functional* anchor
// describing what the level means in terms of what the person can or can't
// do, not what the symptom feels like. Anchors are universal (apply to ANY
// symptom in the vault) and replace the older intensity-only adjective in
// the picker UI.
//
// Why functional: the symptom vault is free-text. Trying to mapping
// "tos seca nocturna" / "fatiga post-cognitiva" / "mareo postural" to a
// taxonomy of families is fragile and ends up either over-classifying or
// under-classifying the rare-disease edge cases that matter most. A single
// functional scale ("does this stop me from doing things?") is robust
// across symptoms, comparable across patients, and resistant to the
// internal-scale drift that chronic-symptom patients experience over time.
//
// Spanish default fallback. Use the locale-aware extension
// `SymptomSeverityFunctionalAnchor.severityFunctionalAnchor(l10n)` from
// lib/services/clinical_localizations.dart for user-facing strings.
const Map<SymptomSeverity, String> kSeverityFunctionalAnchorsEs = {
  SymptomSeverity.none: 'no lo noto',
  SymptomSeverity.mild: 'lo noto, pero no me detiene',
  SymptomSeverity.moderate: 'me obliga a bajar el ritmo o pausar',
  SymptomSeverity.intense: 'no puedo hacer lo que tenía planeado',
  SymptomSeverity.unbearable: 'no puedo funcionar; necesito detenerme',
};

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

  /// C.4: Optional structured detail when the symptom is a headache and the
  /// user has the headache_detail tracker enabled in optionalTrackers.
  /// Null for all non-cefalea symptoms and for cefalea logs created before
  /// C.4. See lib/models/headache_detail.dart for the schema.
  final HeadacheDetail? headacheDetail;

  /// D.1: Optional structured detail when the symptom is fatigue and the
  /// user has the fatigue_detail tracker enabled in optionalTrackers.
  /// Null for all non-fatigue symptoms and for fatigue logs created before
  /// D.1. See lib/models/fatigue_detail.dart for the schema.
  final FatigueDetail? fatigueDetail;

  /// D.2: Optional structured detail when the symptom is abdominal
  /// (pain, bloating, or gas semantics) and the user has the
  /// abdominal_detail tracker enabled in optionalTrackers. Null for all
  /// non-abdominal symptoms and for abdominal logs created before D.2.
  /// See lib/models/abdominal_detail.dart for the schema.
  final AbdominalDetail? abdominalDetail;

  // Sprint E.A — MCAS detail layer (additive, gated by
  // optionalTrackers['mcas_detail'] once E.E wires the toggle).
  final MCASDetail? mcasDetail;

  SymptomEvent({
    String? id,
    required this.timestamp,
    required this.name,
    required this.severity,
    this.note,
    this.photoPath,
    this.headacheDetail,
    this.fatigueDetail,
    this.abdominalDetail,
    this.mcasDetail,
  }) : id = id ?? _newId();

  SymptomEvent copyWith({
    DateTime? timestamp,
    SymptomSeverity? severity,
    String? note,
    String? photoPath,
    HeadacheDetail? headacheDetail,
    FatigueDetail? fatigueDetail,
    AbdominalDetail? abdominalDetail,
    MCASDetail? mcasDetail,
  }) {
    return SymptomEvent(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      name: name,
      severity: severity ?? this.severity,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
      headacheDetail: headacheDetail ?? this.headacheDetail,
      fatigueDetail: fatigueDetail ?? this.fatigueDetail,
      abdominalDetail: abdominalDetail ?? this.abdominalDetail,
      mcasDetail: mcasDetail ?? this.mcasDetail,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'name': name,
    'severity': severity.value,
    'note': note,
    'photoPath': photoPath,
    if (headacheDetail != null) 'headacheDetail': headacheDetail!.toMap(),
    if (fatigueDetail != null) 'fatigueDetail': fatigueDetail!.toMap(),
    if (abdominalDetail != null) 'abdominalDetail': abdominalDetail!.toMap(),
    if (mcasDetail != null) 'mcasDetail': mcasDetail!.toMap(),
  };

  factory SymptomEvent.fromMap(Map<String, dynamic> map) {
    final hdRaw = map['headacheDetail'];
    final fdRaw = map['fatigueDetail'];
    final adRaw = map['abdominalDetail'];
    final mcasRaw = map['mcasDetail'];
    return SymptomEvent(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      name: map['name'],
      severity: SymptomSeverity.fromValue((map['severity'] as num).toInt()),
      note: map['note'] as String?,
      photoPath: map['photoPath'] as String?,
      headacheDetail: hdRaw is Map
          ? HeadacheDetail.fromMap(Map<String, dynamic>.from(hdRaw))
          : null,
      fatigueDetail: fdRaw is Map
          ? FatigueDetail.fromMap(Map<String, dynamic>.from(fdRaw))
          : null,
      abdominalDetail: adRaw is Map
          ? AbdominalDetail.fromMap(Map<String, dynamic>.from(adRaw))
          : null,
      mcasDetail: mcasRaw is Map
          ? MCASDetail.fromMap(Map<String, dynamic>.from(mcasRaw))
          : null,
    );
  }
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
  final String
  formAtDose; // 'pill', 'capsule', 'drop', 'tablet', 'patch', 'spray', 'ml'
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
    medicationId: map['medicationId'] as String?,
    quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
    strengthAtDose: (map['strengthAtDose'] as num?)?.toDouble() ?? 0.0,
    unitAtDose: map['unitAtDose'] as String? ?? '',
    formAtDose: map['formAtDose'] as String? ?? 'pill',
    linkedSymptomIds: List<String>.from(map['linkedSymptomIds'] ?? const []),
    severityBefore: Map<String, int>.from(
      (map['severityBefore'] as Map?)?.map(
            (k, v) => MapEntry(k as String, (v as num).toInt()),
          ) ??
          const {},
    ),
    groupId: map['groupId'] as String?,
  );
}

// =============================================================================
// PHASE F4 — STRUCTURAL EVENT KIND TAXONOMY
// =============================================================================
// Six-kind cascade for structural injury logging. Replaces the flat
// `_structuralTypes` list previously hardcoded in sintomas_tab.dart.
//
// Each StructuralEvent carries both `kind` (broad category) and `type`
// (specific entry within that category). Legacy events without `kind`
// have it inferred from `type` via inferKindFromType — no migration
// step required.

enum StructuralEventKind {
  joint('Articulación'),
  muscle('Músculo'),
  tendon('Tendón'),
  ligament('Ligamento'),
  softTissue('Tejido blando'),
  nerve('Nervio');

  /// Spanish fallback label (LatAm neutral). For user-facing localized
  /// labels, use the StructuralEventKindLocalization.label(l10n) extension
  /// in lib/services/structural_taxonomy.dart — the canonical i18n pattern,
  /// mirroring FeverSiteLocalization.
  final String defaultLabel;
  const StructuralEventKind(this.defaultLabel);

  static StructuralEventKind? parse(String? raw) {
    if (raw == null) return null;
    for (final k in values) {
      if (k.name == raw) return k;
    }
    return null;
  }
}

/// Authoritative kind -> types map. Single source of truth for the
/// form picker AND for inferring kind from legacy free-text types.
///
/// F6.a: type values are now stable snake_case IDs. Display labels come
/// from `StructuralEventTypeLocalization` in lib/services/structural_taxonomy.dart.
/// Legacy Spanish strings from v3 storage are migrated silently in
/// `StructuralEvent.fromMap` via `_migrateStructuralTypeId`.
const Map<StructuralEventKind, List<String>> kStructuralTaxonomy = {
  StructuralEventKind.joint: [
    'subluxation',
    'dislocation',
    'joint_instability',
    'joint_pain',
  ],
  StructuralEventKind.muscle: [
    'muscle_strain',
    'muscle_distension',
    'muscle_tear',
    'contracture',
    'muscle_spasm',
    'myofascial_pain',
  ],
  StructuralEventKind.tendon: [
    'tendinitis',
    'tendinosis',
    'bursitis',
    'enthesitis',
    'tendon_fissure',
  ],
  StructuralEventKind.ligament: [
    'mild_sprain',
    'severe_sprain',
    'ligament_tear',
  ],
  StructuralEventKind.softTissue: [
    'superficial_cut',
    'skin_fissure',
    'deep_wound',
    'hematoma',
    'contusion',
    'burn',
    'abrasion',
  ],
  StructuralEventKind.nerve: ['neuropathic_pain', 'paresthesia'],
};

/// F6.a + F6.b: Stable IDs for body zones.
///
/// F6.b decision (17-jun-2026): catalog expanded to 24 zones using
/// *everyday Spanish*, NOT anatomical terminology. "Atrás del muslo"
/// instead of "isquiotibial", "pantorrilla" instead of "tríceps sural".
/// Most users don't know specific muscle names; clinical-grade naming
/// creates a usability barrier without clinical benefit at the data
/// layer (the doctor can interpret "atrás del muslo" just as well).
///
/// Zones are grouped into 6 BodyRegion values for picker UX
/// (lib/screens/sintomas_tab.dart uses kBodyRegionZones to render
/// region headers with zone chips beneath, rather than 24 chips flat).
///
/// `kBodyZones` is the flat list (kept for migration lookups,
/// `BodySide` enum support in a future sprint, etc.). Source of truth
/// for the UI is `kBodyRegionZones` below.
const List<String> kBodyZones = [
  // head/neck
  'cervical',
  'jaw',
  'temple',
  // shoulders/upper back
  'shoulders',
  'shoulder_blades',
  'upper_back',
  // arms
  'upper_arm',
  'elbow',
  'forearm',
  'wrists',
  'hands',
  // chest/abdomen
  'chest',
  'side',
  'ribs',
  'abdomen',
  // lower back/pelvis
  'lumbar_pelvis',
  'hips',
  'glutes',
  // legs
  'front_thigh',
  'back_thigh',
  'knees',
  'calf',
  'ankles',
  'feet',
];

/// F6.b: Body regions for the structural picker UX. Display labels
/// resolved via BodyRegionLocalization extension in
/// lib/services/structural_taxonomy.dart.
enum BodyRegion {
  headNeck,
  shouldersUpperBack,
  arms,
  chestAbdomen,
  lowerBackPelvis,
  legs;

  static BodyRegion? parse(String? raw) {
    if (raw == null) return null;
    for (final r in values) {
      if (r.name == raw) return r;
    }
    return null;
  }
}

/// F6.b: Region → zone IDs map. Mirror of `kBodyZones` grouped. Keep
/// the flat list and this map in sync when adding zones.
const Map<BodyRegion, List<String>> kBodyRegionZones = {
  BodyRegion.headNeck: ['cervical', 'jaw', 'temple'],
  BodyRegion.shouldersUpperBack: ['shoulders', 'shoulder_blades', 'upper_back'],
  BodyRegion.arms: ['upper_arm', 'elbow', 'forearm', 'wrists', 'hands'],
  BodyRegion.chestAbdomen: ['chest', 'side', 'ribs', 'abdomen'],
  BodyRegion.lowerBackPelvis: ['lumbar_pelvis', 'hips', 'glutes'],
  BodyRegion.legs: [
    'front_thigh',
    'back_thigh',
    'knees',
    'calf',
    'ankles',
    'feet',
  ],
};

/// Legacy Spanish structural type strings → stable IDs.
/// Used by `StructuralEvent.fromMap` to migrate v3 events silently on read.
/// Lower-cased keys; lookup is case-insensitive.
const Map<String, String> _kLegacyStructuralTypeToId = {
  'subluxación': 'subluxation',
  'dislocación': 'dislocation',
  'inestabilidad articular': 'joint_instability',
  'dolor articular': 'joint_pain',
  'tirón muscular': 'muscle_strain',
  'distensión muscular': 'muscle_distension',
  'desgarro muscular': 'muscle_tear',
  'contractura': 'contracture',
  'espasmo muscular': 'muscle_spasm',
  'dolor miofascial': 'myofascial_pain',
  'tendinitis': 'tendinitis',
  'tendinosis': 'tendinosis',
  'bursitis': 'bursitis',
  'entesitis': 'enthesitis',
  'fisura tendinosa': 'tendon_fissure',
  'esguince leve': 'mild_sprain',
  'esguince grave': 'severe_sprain',
  'desgarro ligamentario': 'ligament_tear',
  'corte superficial': 'superficial_cut',
  'fisura cutánea': 'skin_fissure',
  'herida profunda': 'deep_wound',
  'hematoma': 'hematoma',
  'contusión': 'contusion',
  'quemadura': 'burn',
  'abrasión': 'abrasion',
  'dolor neuropático': 'neuropathic_pain',
  'parestesia': 'paresthesia',
};

/// Legacy Spanish body zone strings → stable IDs.
const Map<String, String> _kLegacyZoneToId = {
  'cervicales': 'cervical',
  'hombros': 'shoulders',
  'muñecas': 'wrists',
  'manos': 'hands',
  'lumbar/pelvis': 'lumbar_pelvis',
  'caderas': 'hips',
  'rodillas': 'knees',
  'tobillos': 'ankles',
};

/// Migrate a stored `type` string to its stable ID. Returns the input
/// unchanged if it's already a valid ID. Returns the legacy mapping if
/// it matches a known Spanish label (case-insensitive). Returns the
/// input as-is if neither — graceful degradation for unknown types
/// (the localization extension also has an unknown-id fallback).
String _migrateStructuralTypeId(String raw) {
  for (final list in kStructuralTaxonomy.values) {
    if (list.contains(raw)) return raw;
  }
  final mapped = _kLegacyStructuralTypeToId[raw.toLowerCase().trim()];
  return mapped ?? raw;
}

/// Migrate a stored `zone` string to its stable ID. Same fallback strategy
/// as `_migrateStructuralTypeId`.
String _migrateZoneId(String raw) {
  if (kBodyZones.contains(raw)) return raw;
  final mapped = _kLegacyZoneToId[raw.toLowerCase().trim()];
  return mapped ?? raw;
}

/// Infer kind from a `type` string when no `kind` field is stored.
/// F6.a: now handles both stable IDs (primary path) and legacy Spanish
/// strings (heuristic fallback). Legacy heuristics retained verbatim
/// because they ALSO catch typos and pre-F4 capitalizations.
StructuralEventKind inferKindFromType(String type) {
  // 1. Exact match against current taxonomy (stable IDs)
  for (final entry in kStructuralTaxonomy.entries) {
    if (entry.value.contains(type)) return entry.key;
  }
  // 2. Heuristic fallbacks — Spanish strings (legacy v3), typos, edge cases
  final lower = type.toLowerCase();
  if (lower.contains('miofascial')) return StructuralEventKind.muscle;
  if (lower.contains('neurop') || lower.contains('parest')) {
    return StructuralEventKind.nerve;
  }
  if (lower.contains('subluxa') ||
      lower.contains('disloca') ||
      lower.contains('luxa') ||
      lower.contains('articul') ||
      lower.contains('inestab')) {
    return StructuralEventKind.joint;
  }
  if (lower.contains('tendin') || lower.contains('bursit')) {
    return StructuralEventKind.tendon;
  }
  if (lower.contains('esguince') || lower.contains('ligament')) {
    return StructuralEventKind.ligament;
  }
  if (lower.contains('corte') ||
      lower.contains('herida') ||
      lower.contains('hematoma') ||
      lower.contains('contus') ||
      lower.contains('quemad') ||
      lower.contains('abras')) {
    return StructuralEventKind.softTissue;
  }
  if (lower.contains('muscul') ||
      lower.contains('contrac') ||
      lower.contains('espasm') ||
      lower.contains('desgarro') ||
      lower.contains('distens')) {
    return StructuralEventKind.muscle;
  }
  // Last-resort default
  return StructuralEventKind.joint;
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
  }) : id = id ?? _newId(),
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
  final int effort; // 0–10 RPE
  final int feeling; // 1–5 subjective
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

  factory MedicationOutcome.fromMap(Map<String, dynamic> map) =>
      MedicationOutcome(
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
        respondedAt: map['respondedAt'] != null
            ? DateTime.parse(map['respondedAt'])
            : null,
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
  double strength; // numeric strength, e.g. 500
  String unit; // 'mg', 'mcg', 'IU', 'g', 'ml', '' for unspecified
  String form; // 'pill', 'capsule', 'drop', 'tablet', 'patch', 'spray', 'ml'
  double defaultQuantity; // 1.0, 0.5, 2.0…

  /// Hours after a dose at which to ask "¿mejor / igual / peor?".
  /// Null = don't track outcomes (daily vitamins etc.).
  int? outcomeCheckHours;

  /// Free-form notes from the patient (e.g. "tomar con comida").
  String? notes;

  /// Active ingredient (INN). Populated later by CIMA lookup.
  String? activeIngredient;

  /// CIMA registration code (Spain) once matched.
  String? cimaCode;

  /// Optional sub-ingredients for multi-component supplements (e.g. a
  /// B-Complex made of B1, B6, B12... each with its own strength/unit).
  /// Empty for ordinary single-ingredient medications.
  List<MedicationComponent> components;

  /// Sprint F.F — basal/scheduled vs PRN/rescue classification.
  /// Defaults to [MedicationType.undefined] for records created before
  /// this field existed; the user reclassifies at their own pace via
  /// this form.
  MedicationType medicationType;

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
    List<MedicationComponent>? components,
    this.medicationType = MedicationType.undefined,
  }) : id = id ?? _newId(),
       components = components ?? <MedicationComponent>[];

  /// Human-readable dose summary for UI rows: "1 pill × 500mg".
  String get displayDose {
    final qty = _formatQuantity(defaultQuantity);
    final formLabel = _pluralizeForm(form, defaultQuantity);
    final base = (strength > 0 && unit.isNotEmpty)
        ? '$qty $formLabel × ${_formatQuantity(strength)}$unit'
        : '$qty $formLabel';
    if (components.isNotEmpty) {
      final label = components.length == 1 ? 'componente' : 'componentes';
      return '$base · ${components.length} $label';
    }
    return base;
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
    'components': components.map((c) => c.toMap()).toList(),
    'medicationType': medicationType.serializationKey,
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
    components: List<MedicationComponent>.from(
      (map['components'] as List? ?? const []).map(
        (c) => MedicationComponent.fromMap(Map<String, dynamic>.from(c as Map)),
      ),
    ),
    medicationType:
        MedicationType.fromKey(map['medicationType'] as String?) ??
        MedicationType.undefined,
  );
}

/// A single sub-ingredient within a multi-component supplement, e.g. one
/// vitamin inside a B-Complex. `unit` is free text, same as
/// [MedicationDef.unit], so it can hold values like "billones" for
/// probiotic CFU counts.
class MedicationComponent {
  String name;
  double strength;
  String unit;

  MedicationComponent({required this.name, this.strength = 0, this.unit = ''});

  Map<String, dynamic> toMap() => {
    'name': name,
    'strength': strength,
    'unit': unit,
  };

  factory MedicationComponent.fromMap(Map<String, dynamic> map) =>
      MedicationComponent(
        name: map['name'] as String? ?? '',
        strength: (map['strength'] as num?)?.toDouble() ?? 0,
        unit: map['unit'] as String? ?? '',
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
  }) : id = id ?? _newId(),
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
      (map['entries'] as List? ?? const []).map(
        (e) =>
            MedicationGroupEntry.fromMap(Map<String, dynamic>.from(e as Map)),
      ),
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

/// Wisdom quote with text in 4 languages. Falls back to English then
/// Spanish then the first non-empty field when the requested locale is
/// missing — same chain as EmaMood. The `category` field is a single
/// language tag; categories aren't translated yet (see B.3 scope notes).
class WisdomQuote {
  final String textEs;
  final String textEn;
  final String textZh;
  final String textKo;
  final String category;
  final String source;

  WisdomQuote({
    required this.textEs,
    this.textEn = '',
    this.textZh = '',
    this.textKo = '',
    required this.category,
    this.source = '',
  });

  /// Returns the text in the requested locale with fallback chain.
  /// Locale code matching is prefix-based: 'zh', 'zh_TW', 'zh-Hant'
  /// all resolve through the `zh` branch.
  String text(String localeCode) {
    final code = localeCode.toLowerCase();
    if (code.startsWith('zh')) {
      if (textZh.trim().isNotEmpty) return textZh;
      if (textEn.trim().isNotEmpty) return textEn;
      return textEs;
    }
    if (code.startsWith('ko')) {
      if (textKo.trim().isNotEmpty) return textKo;
      if (textEn.trim().isNotEmpty) return textEn;
      return textEs;
    }
    if (code.startsWith('en')) {
      if (textEn.trim().isNotEmpty) return textEn;
      return textEs;
    }
    // Spanish is the default / template locale.
    if (textEs.trim().isNotEmpty) return textEs;
    return textEn;
  }

  /// Reads a wisdom entry from a row of zebra_wisdom.json. Tolerates
  /// missing language keys — they fall back via `text(locale)`.
  factory WisdomQuote.fromJson(Map<String, dynamic> map) => WisdomQuote(
    textEs: (map['fact_es'] as String?)?.trim() ?? '',
    textEn: (map['fact_en'] as String?)?.trim() ?? '',
    textZh: (map['fact_zh'] as String?)?.trim() ?? '',
    textKo: (map['fact_ko'] as String?)?.trim() ?? '',
    category: (map['condition'] as String?) ?? 'Dato Clínico',
    source:
        ((map['citation'] ?? map['source'] ?? map['reference'] ?? map['url'])
                as String?)
            ?.trim() ??
        '',
  );
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
    fetchedForConditions: List<String>.from(
      map['fetchedForConditions'] ?? const [],
    ),
  );
}

/// Pre-bundled aggregate of cached search results for a condition.
/// (PubMedSearchResult lives in lib/services/pubmed_service.dart — not here.)

// =============================================================================
// PROFILE — patient (or caregiver) analytics engine
// =============================================================================

class Profile {
  final String id;
  String name;
  String? relationship;
  List<String> conditions;
  String? country;
  List<LifeEvent> lifeEvents;

  /// custom exercises
  List<String> customExercises;

  /// Catalog of symptoms this profile chooses to track (filters the picker).
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

  // Phase 5.0 — EMA expansion (schema v2). All additive.
  List<BowelEvent> bowelHistory;
  List<HemorrhoidalEvent> hemorrhoidalHistory;
  List<SleepEntry> sleepHistory;
  List<HydrationEntry> hydrationHistory;
  List<HrvReading> hrvHistory;
  List<MovementMetric> movementHistory;
  // PHASE 5.2d — fever readings (schema v3, additive)
  List<FeverReading> feverHistory;

  // Sprint F.B+C — transversal action capture (schema v4, additive).
  // ActionTaken links polymorphically to symptom/bowel/hemorrhoidal/fever
  // events. Follow-up effectiveness capture is a separate concern (F.D).
  List<ActionTaken> actionsHistory;

  /// Sprint P.B — grouped user preferences. Home for optionalTrackers
  /// (per-feature enablement flags). Future: theme, language,
  /// notification preferences. See lib/models/profile_settings.dart.
  ProfileSettings settings;

  // Weather
  double? homeLatitude;
  double? homeLongitude;

  /// Sprint P.B — grouped transient session state. Home for
  /// pacingDays (recovery day markers), flare (crisis-mode session),
  /// future energy budget and multi-observer permission grants. See
  /// lib/models/profile_state.dart.
  ProfileState state;

  /// Sprint P.B — backwards-compat proxy for pre-refactor call sites.
  /// Access profile.state.pacingDays directly in new code.
  ///@Deprecated('Sprint P.C migration target — use profile.state.pacingDays')
  Set<String> get pacingDays => state.pacingDays;

  ///@Deprecated(
  ///  'Sprint P.C migration target — use profile.state.pacingDays = ...',
  ///)
  set pacingDays(Set<String> value) {
    state.pacingDays = value;
  }

  /// PMIDs the user starred from PubMed search.
  Set<String> savedArticlePmids;

  /// Sprint Phase4.A — known allergies and MCAS/hypersensitivity triggers,
  /// free-text. Surfaced prominently in the clinical PDF export and the
  /// emergency card. No dedicated edit UI yet (Phase4.C).
  List<String> allergies;

  /// Sprint Phase4.A — emergency contacts as free-form text lines (e.g.
  /// "Mamá — Ana Pérez — +56 9 1234 5678"). No dedicated edit UI yet
  /// (Phase4.C).
  List<String> emergencyContacts;

  /// Sprint Phase4.A — optional date of birth, used to render age in
  /// the clinical PDF export. No dedicated edit UI yet (Phase4.C).
  DateTime? dateOfBirth;

  Profile({
    required this.id,
    required this.name,
    required this.conditions,
    required this.symptomVault,
    required this.botiquin,
    this.customExercises = const [],
    this.moodHistory = const [],
    this.country,
    this.homeLatitude,
    this.homeLongitude,
    this.allergies = const [],
    this.emergencyContacts = const [],
    this.dateOfBirth,
    this.therapyHistory = const [],
    this.customTherapyModalities = const [],
    this.relationship,
    List<LifeEvent>? lifeEvents,
    List<MedicationGroup>? medicationGroups,
    List<SymptomEvent>? symptoms,
    List<DoseEvent>? doses,
    List<StructuralEvent>? structural,
    List<MentalEvent>? mental,
    List<ActivityEvent>? activity,
    List<MedicationOutcome>? outcomes,
    ProfileState? state,
    Set<String>? saved,
    List<BowelEvent>? bowel,
    List<HemorrhoidalEvent>? hemorrhoidal,
    List<SleepEntry>? sleep,
    List<HydrationEntry>? hydration,
    List<HrvReading>? hrv,
    List<MovementMetric>? movement,
    List<FeverReading>? fever,
    List<ActionTaken>? actions,
    ProfileSettings? settings,
  }) : settings = settings ?? ProfileSettings(),
       medicationGroups = medicationGroups ?? <MedicationGroup>[],
       symptomHistory = symptoms ?? <SymptomEvent>[],
       doseHistory = doses ?? <DoseEvent>[],
       structuralHistory = structural ?? <StructuralEvent>[],
       mentalHistory = mental ?? <MentalEvent>[],
       activityHistory = activity ?? <ActivityEvent>[],
       lifeEvents = lifeEvents ?? <LifeEvent>[],
       medicationOutcomes = outcomes ?? <MedicationOutcome>[],
       state = state ?? ProfileState(),
       savedArticlePmids = saved ?? <String>{},
       bowelHistory = bowel ?? <BowelEvent>[],
       hemorrhoidalHistory = hemorrhoidal ?? <HemorrhoidalEvent>[],
       sleepHistory = sleep ?? <SleepEntry>[],
       hydrationHistory = hydration ?? <HydrationEntry>[],
       hrvHistory = hrv ?? <HrvReading>[],
       movementHistory = movement ?? <MovementMetric>[],
       feverHistory = fever ?? <FeverReading>[],
       actionsHistory = actions ?? <ActionTaken>[];

  // ---------------------------------------------------------------------------
  // Catalog helpers
  // ---------------------------------------------------------------------------

  MedicationDef? findMedById(String medId) {
    for (final m in botiquin) {
      if (m.id == medId) return m;
    }
    return null;
  }

  MedicationDef? findMedByName(String name) {
    final lower = name.toLowerCase();
    for (final m in botiquin) {
      if (m.name.toLowerCase() == lower) return m;
    }
    return null;
  }

  /// Delete a med from the botiquín. By default, dose history is preserved
  /// (so reports retain the data) and group entries referencing the med are
  /// stripped. Pass `purgeHistory: true` to also delete past doses.
  ///
  /// Returns the number of group entries removed.
  int deleteMedication(String medId, {bool purgeHistory = false}) {
    botiquin.removeWhere((m) => m.id == medId);
    int groupEntriesRemoved = 0;
    for (final g in medicationGroups) {
      final before = g.entries.length;
      g.entries.removeWhere((e) => e.medicationId == medId);
      groupEntriesRemoved += before - g.entries.length;
    }
    if (purgeHistory) {
      doseHistory.removeWhere((d) => d.medicationId == medId);
    }
    return groupEntriesRemoved;
  }

  // ---------------------------------------------------------------------------
  // Day queries
  // ---------------------------------------------------------------------------

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DoseEvent> getDosesForDay(DateTime date) =>
      doseHistory.where((e) => _sameDay(e.timestamp, date)).toList();

  List<MoodEntry> getMoodForDay(DateTime day) {
    return moodHistory
        .where(
          (m) =>
              m.timestamp.year == day.year &&
              m.timestamp.month == day.month &&
              m.timestamp.day == day.day,
        )
        .toList();
  }

  List<TherapyEvent> getTherapyForDay(DateTime day) {
    return therapyHistory
        .where(
          (t) =>
              t.timestamp.year == day.year &&
              t.timestamp.month == day.month &&
              t.timestamp.day == day.day,
        )
        .toList();
  }

  int getDoseCountForDayAndMed(DateTime date, String medName) =>
      getDosesForDay(date).where((e) => e.medicationName == medName).length;

  /// Total quantity of a med taken today (handles the 2-pills-at-once case).
  double getDoseQuantityForDayAndMed(DateTime date, String medName) {
    var sum = 0.0;
    for (final d in getDosesForDay(date)) {
      if (d.medicationName == medName) sum += d.quantity;
    }
    return sum;
  }

  List<LifeEvent> getLifeEventsForDay(DateTime date) =>
      lifeEvents.where((e) => e.covers(date)).toList();

  List<SymptomEvent> getSymptomsForDay(DateTime date) =>
      symptomHistory.where((e) => _sameDay(e.timestamp, date)).toList();

  List<StructuralEvent> getStructuralForDay(DateTime date) =>
      structuralHistory.where((e) => _sameDay(e.timestamp, date)).toList();

  // PHASE 5.1 — bowel/hemorrhoidal day-query helpers
  List<BowelEvent> getBowelForDay(DateTime date) =>
      bowelHistory.where((e) => _sameDay(e.timestamp, date)).toList();

  List<HemorrhoidalEvent> getHemorrhoidalForDay(DateTime date) =>
      hemorrhoidalHistory.where((e) => _sameDay(e.timestamp, date)).toList();

  // PHASE 5.2d — fever day-query helper
  List<FeverReading> getFeverForDay(DateTime date) =>
      feverHistory.where((e) => _sameDay(e.timestamp, date)).toList();

  // Sleep day-query helper. SleepEntry uses `dateKey` (YYYY-MM-DD of the
  // waking day) rather than raw timestamp matching, so we compare on
  // that field — an entry logged Monday morning carries Monday's
  // dateKey and refers to Sunday-night → Monday-morning sleep.
  List<SleepEntry> getSleepForDay(DateTime date) {
    final dk =
        "${date.year}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
    return sleepHistory.where((e) => e.dateKey == dk).toList();
  }

  // F6.b: Hydration day-query helper. Uses raw timestamp matching since
  // hydration entries are point-in-time events (not "for a night").
  List<HydrationEntry> getHydrationForDay(DateTime date) =>
      hydrationHistory.where((e) => _sameDay(e.timestamp, date)).toList();

  // F6.b: HRV day-query helper. Same pattern as hydration.
  List<HrvReading> getHrvForDay(DateTime date) =>
      hrvHistory.where((e) => _sameDay(e.timestamp, date)).toList();

  /// Days since the most recent bowel event, computed from `bowelHistory`.
  ///
  /// Returns `null` when there is no bowel history at all — the UI uses
  /// null as the "no data yet" sentinel and hides the counter rather than
  /// showing a misleading large number. Once any event has been logged,
  /// the value is the integer day delta between today and the most recent
  /// event's calendar date (so an event logged this morning returns 0).
  int? get daysSinceLastBM {
    if (bowelHistory.isEmpty) return null;
    final mostRecent = bowelHistory
        .map((e) => e.timestamp)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(mostRecent.year, mostRecent.month, mostRecent.day);
    final diff = today.difference(lastDay).inDays;
    return diff < 0 ? 0 : diff;
  }

  List<MentalEvent> getMentalForDay(DateTime date) =>
      mentalHistory.where((e) => _sameDay(e.timestamp, date)).toList();

  List<ActivityEvent> getActivityForDay(DateTime date) =>
      activityHistory.where((e) => _sameDay(e.timestamp, date)).toList();

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------

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
        .where(
          (s) =>
              s.timestamp.isAfter(cutoff) &&
              s.severity.value >= SymptomSeverity.moderate.value,
        )
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
          o.reason == OutcomeReason.additionalMed)
        return false;
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
    'hemorrhoidalHistory': hemorrhoidalHistory.map((x) => x.toMap()).toList(),
    'sleepHistory': sleepHistory.map((x) => x.toMap()).toList(),
    'hydrationHistory': hydrationHistory.map((x) => x.toMap()).toList(),
    'hrvHistory': hrvHistory.map((x) => x.toMap()).toList(),
    'movementHistory': movementHistory.map((x) => x.toMap()).toList(),
    'feverHistory': feverHistory.map((x) => x.toMap()).toList(),
    'actionsHistory': actionsHistory.map((x) => x.toMap()).toList(),
    'settings': settings.toMap(),
    'state': state.toMap(),
    'allergies': allergies,
    'emergencyContacts': emergencyContacts,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
  };

  // ---------------------------------------------------------------------------
  // Sprint P.B — deserialization helpers with legacy flat-field fallback.
  // Prefer nested `settings` / `state` when present; fall back to
  // pre-P.B flat `optionalTrackers` / `pacingDays` for backwards compat
  // with profiles serialized before the P.B refactor.
  // ---------------------------------------------------------------------------
  static ProfileSettings _settingsFromMap(Map<String, dynamic> map) {
    final raw = map['settings'];
    if (raw is Map) {
      return ProfileSettings.fromMap(Map<String, dynamic>.from(raw));
    }
    final legacyRaw = map['optionalTrackers'];
    return ProfileSettings(
      optionalTrackers: legacyRaw is Map
          ? Map<String, bool>.from(
              legacyRaw.map((k, v) => MapEntry(k.toString(), v == true)),
            )
          : <String, bool>{},
    );
  }

  static ProfileState _stateFromMap(Map<String, dynamic> map) {
    final raw = map['state'];
    if (raw is Map) {
      return ProfileState.fromMap(Map<String, dynamic>.from(raw));
    }
    return ProfileState(
      pacingDays: Set<String>.from(map['pacingDays'] ?? const []),
    );
  }

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map['id'],
    name: map['name'],
    conditions: List<String>.from(map['conditions'] ?? const []),
    country: map['country'] as String?,
    customExercises: List<String>.from(map['customExercises'] ?? []),
    symptomVault: List<String>.from(map['symptomVault'] ?? const []),
    state: _stateFromMap(map),
    saved: Set<String>.from(map['savedArticlePmids'] ?? const []),
    botiquin: List<MedicationDef>.from(
      (map['botiquin'] ?? const []).map(
        (x) => MedicationDef.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    medicationGroups: List<MedicationGroup>.from(
      (map['medicationGroups'] ?? const []).map(
        (x) => MedicationGroup.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    symptoms: List<SymptomEvent>.from(
      (map['symptomHistory'] ?? const []).map(
        (x) => SymptomEvent.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    doses: List<DoseEvent>.from(
      (map['doseHistory'] ?? const []).map(
        (x) => DoseEvent.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    moodHistory: List<MoodEntry>.from(
      (map['moodHistory'] ?? const []).map(
        (x) => MoodEntry.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    structural: List<StructuralEvent>.from(
      (map['structuralHistory'] ?? const []).map(
        (x) => StructuralEvent.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    mental: List<MentalEvent>.from(
      (map['mentalHistory'] ?? const []).map(
        (x) => MentalEvent.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    activity: List<ActivityEvent>.from(
      (map['activityHistory'] ?? const []).map(
        (x) => ActivityEvent.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    outcomes: List<MedicationOutcome>.from(
      (map['medicationOutcomes'] ?? const []).map(
        (x) => MedicationOutcome.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    therapyHistory: ((map['therapyHistory'] as List?) ?? const [])
        .map((x) => TherapyEvent.fromMap(x as Map<String, dynamic>))
        .toList(),
    relationship: map['relationship'] as String?,
    lifeEvents: ((map['lifeEvents'] as List?) ?? const [])
        .map((x) => LifeEvent.fromMap(Map<String, dynamic>.from(x as Map)))
        .toList(),
    customTherapyModalities: List<String>.from(
      map['customTherapyModalities'] ?? [],
    ),
    homeLatitude: (map['homeLatitude'] as num?)?.toDouble(),
    homeLongitude: (map['homeLongitude'] as num?)?.toDouble(),
    allergies: List<String>.from(map['allergies'] ?? const []),
    emergencyContacts: List<String>.from(map['emergencyContacts'] ?? const []),
    dateOfBirth: map['dateOfBirth'] is String
        ? DateTime.tryParse(map['dateOfBirth'] as String)
        : null,
    bowel: List<BowelEvent>.from(
      (map['bowelHistory'] ?? const []).map(
        (x) => BowelEvent.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    hemorrhoidal: List<HemorrhoidalEvent>.from(
      (map['hemorrhoidalHistory'] ?? const []).map(
        (x) => HemorrhoidalEvent.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    sleep: List<SleepEntry>.from(
      (map['sleepHistory'] ?? const []).map(
        (x) => SleepEntry.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    hydration: List<HydrationEntry>.from(
      (map['hydrationHistory'] ?? const []).map(
        (x) => HydrationEntry.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    hrv: List<HrvReading>.from(
      (map['hrvHistory'] ?? const []).map(
        (x) => HrvReading.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    movement: List<MovementMetric>.from(
      (map['movementHistory'] ?? const []).map(
        (x) => MovementMetric.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    fever: List<FeverReading>.from(
      (map['feverHistory'] ?? const []).map(
        (x) => FeverReading.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
    settings: _settingsFromMap(map),
    actions: List<ActionTaken>.from(
      (map['actionsHistory'] ?? const []).map(
        (x) => ActionTaken.fromMap(Map<String, dynamic>.from(x as Map)),
      ),
    ),
  );
}

// =============================================================================
// MOOD TRACKING (Foxtale-style B+C: quadrant → palette → multi-select)
// =============================================================================

// =============================================================================
// MOOD TRACKING MODELS (EMA - Quadrant → Rich Palette via JSON)
// Language: Gender-Neutral Nouns (Sustantivos Neutros)
// =============================================================================

enum MoodQuadrant {
  activatedUnpleasant,
  activatedPleasant,
  calmUnpleasant,
  calmPleasant,
}

extension MoodQuadrantLabels on MoodQuadrant {
  /// Etiquetas de los cuadrantes utilizando sustantivos abstractos neutros
  /// en lugar de adjetivos con género (ej. 'activada/calmada').
  String get label => switch (this) {
    MoodQuadrant.activatedUnpleasant => 'activación · malestar',
    MoodQuadrant.activatedPleasant => 'activación · bienestar',
    MoodQuadrant.calmUnpleasant => 'calma · malestar',
    MoodQuadrant.calmPleasant => 'calma · bienestar',
  };

  /// Descriptores breves basados en estados sustantivos neutros para el paso 1.
  String get teaserStates => switch (this) {
    MoodQuadrant.activatedUnpleasant => 'tensión, ansiedad',
    MoodQuadrant.activatedPleasant => 'energía, alegría',
    MoodQuadrant.calmUnpleasant => 'agotamiento, tristeza',
    MoodQuadrant.calmPleasant => 'tranquilidad, paz',
  };

  /// Valence sign for aggregation (pleasant=+1, unpleasant=-1). Shared
  /// single source of truth — used by both the PDF report's period
  /// mean (pdf_report_aggregator.dart) and the in-app report's daily
  /// time series (report_time_series.dart).
  double get valenceSign => switch (this) {
    MoodQuadrant.activatedPleasant => 1.0,
    MoodQuadrant.calmPleasant => 1.0,
    MoodQuadrant.activatedUnpleasant => -1.0,
    MoodQuadrant.calmUnpleasant => -1.0,
  };

  /// Arousal sign for aggregation (activated=+1, calm=-1). Same sharing
  /// rationale as [valenceSign].
  double get arousalSign => switch (this) {
    MoodQuadrant.activatedPleasant => 1.0,
    MoodQuadrant.activatedUnpleasant => 1.0,
    MoodQuadrant.calmPleasant => -1.0,
    MoodQuadrant.calmUnpleasant => -1.0,
  };

  /// Mapea las claves de categorías del archivo JSON con los enums nativos de Dart
  static MoodQuadrant fromJsonCategory(String category) {
    return switch (category.toLowerCase()) {
      'high-unpleasant' => MoodQuadrant.activatedUnpleasant,
      'high-pleasant' => MoodQuadrant.activatedPleasant,
      'low-unpleasant' => MoodQuadrant.calmUnpleasant,
      'low-pleasant' => MoodQuadrant.calmPleasant,
      _ => MoodQuadrant.calmPleasant,
    };
  }
}

/// Representa una emoción rica con sus definiciones clínicas y traducciones,
/// cargada directamente desde el archivo `ema_moods.json` (versión neutra,
/// trilingüe).
///
/// Locale resolution at display time: callers use the `label(locale)` and
/// `definition(locale)` helpers, which fall back to English when zh-TW
/// content is empty or missing — per Phase 3a's user-confirmed behaviour
/// for partial translations.
class EmaMood {
  final String english;
  final String spanish; // Sustantivo neutro (ej. "Aislamiento", "Frustración")
  final String chinese; // Traditional Chinese (zh-TW)
  final String definitionEn;
  final String definitionEs;
  final String definitionZh;

  EmaMood({
    required this.english,
    required this.spanish,
    required this.chinese,
    required this.definitionEn,
    required this.definitionEs,
    required this.definitionZh,
  });

  /// Display label for the given locale code (e.g. 'es', 'en', 'zh').
  /// If the requested locale's string is empty, falls back to English.
  String label(String localeCode) {
    final code = localeCode.toLowerCase();
    if (code.startsWith('zh')) {
      return chinese.trim().isNotEmpty ? chinese : english;
    }
    if (code.startsWith('en')) return english;
    return spanish.trim().isNotEmpty ? spanish : english;
  }

  /// Definition for the given locale code, with same fallback chain.
  String definition(String localeCode) {
    final code = localeCode.toLowerCase();
    if (code.startsWith('zh')) {
      return definitionZh.trim().isNotEmpty ? definitionZh : definitionEn;
    }
    if (code.startsWith('en')) return definitionEn;
    return definitionEs.trim().isNotEmpty ? definitionEs : definitionEn;
  }

  factory EmaMood.fromMap(Map<String, dynamic> map) {
    // Tolerant key resolution — JSON has gone through several iterations
    // (`spanish_equivalent`, `estado_es`, etc.). 'Falta Key' marker stays
    // as a visible error sentinel.
    final es =
        map['spanish_equivalent'] ??
        map['estado_es'] ??
        map['name_es'] ??
        map['word_es'] ??
        map['mood_es'] ??
        'Falta Key';
    final en =
        map['english_term'] ??
        map['estado_en'] ??
        map['name_en'] ??
        map['word_en'] ??
        map['mood_en'] ??
        'Missing Key';
    final zh =
        map['tw_chinese_equivalent'] ??
        map['chinese_equivalent'] ??
        map['name_zh'] ??
        map['mood_zh'] ??
        '';

    final defEs =
        map['definition_es'] ?? map['definicion_es'] ?? map['desc_es'] ?? '';
    final defEn =
        map['definition_en'] ?? map['definicion_en'] ?? map['desc_en'] ?? '';
    final defZh =
        map['definition_tw'] ??
        map['definition_zh'] ??
        map['definicion_zh'] ??
        '';

    return EmaMood(
      english: en.toString(),
      spanish: es.toString(),
      chinese: zh.toString(),
      definitionEn: defEn.toString(),
      definitionEs: defEs.toString(),
      definitionZh: defZh.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'english': english,
    'spanish': spanish,
    'chinese': chinese,
    'definition_en': definitionEn,
    'definition_es': definitionEs,
    'definition_zh': definitionZh,
  };
}

/// Representa un registro histórico guardado por el usuario.
/// Mantiene los estados seleccionados como cadenas (sustantivos del JSON)
/// y notas contextuales libres.
class MoodEntry {
  final String id;
  final DateTime timestamp;
  final MoodQuadrant primaryQuadrant;
  final List<String> states; // Almacena los sustantivos neutros seleccionados
  final String?
  notes; // Contexto personalizado opcional (Ej: "Mucha niebla mental")

  MoodEntry({
    String? id,
    required this.timestamp,
    required this.primaryQuadrant,
    required this.states,
    this.notes,
  }) : id =
           id ??
           '${timestamp.millisecondsSinceEpoch}-${states.join('|').hashCode}';

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'primaryQuadrant': primaryQuadrant.name,
    'states': states,
    'notes': notes,
  };

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    // MAGIA DE RETROCOMPATIBILIDAD (v1.0 -> v1.1)
    // Si la nota viene nula, pero existe una 'intensity' de la versión vieja,
    // la rescatamos y la convertimos en texto para no perder la historia del paciente.
    String? extractedNotes = map['notes'] as String?;
    if (extractedNotes == null &&
        map.containsKey('intensity') &&
        map['intensity'] != null) {
      extractedNotes = "Intensidad anterior: ${map['intensity']}/5";
    }

    return MoodEntry(
      id: map['id'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      primaryQuadrant: MoodQuadrant.values.firstWhere(
        (q) => q.name == map['primaryQuadrant'],
        orElse: () => MoodQuadrant.calmPleasant,
      ),
      // Los adjetivos viejos (ej. "ansiosa") seguirán mostrándose correctamente
      // junto a los nuevos sustantivos ("ansiedad") sin romper la app.
      states: List<String>.from((map['states'] as List?) ?? const []),
      notes: extractedNotes,
    );
  }

  MoodEntry copyWith({
    DateTime? timestamp,
    MoodQuadrant? primaryQuadrant,
    List<String>? states,
    String? notes,
  }) => MoodEntry(
    id: id,
    timestamp: timestamp ?? this.timestamp,
    primaryQuadrant: primaryQuadrant ?? this.primaryQuadrant,
    states: states ?? this.states,
    notes: notes ?? this.notes,
  );
}

// =============================================================================
// WEATHER (Open-Meteo daily snapshot, cached locally)
// =============================================================================

class WeatherDay {
  /// Date key in YYYY-MM-DD format.
  final String dateKey;
  final double? pressureHpa;
  final double? temperatureC;
  final double? humidityPct;
  final double? pressureDeltaHpa; // vs. previous day, can be negative
  final DateTime fetchedAt;

  WeatherDay({
    required this.dateKey,
    this.pressureHpa,
    this.temperatureC,
    this.humidityPct,
    this.pressureDeltaHpa,
    required this.fetchedAt,
  });

  Map<String, dynamic> toMap() => {
    'dateKey': dateKey,
    'pressureHpa': pressureHpa,
    'temperatureC': temperatureC,
    'humidityPct': humidityPct,
    'pressureDeltaHpa': pressureDeltaHpa,
    'fetchedAt': fetchedAt.toIso8601String(),
  };

  factory WeatherDay.fromMap(Map<String, dynamic> map) => WeatherDay(
    dateKey: map['dateKey'] as String,
    pressureHpa: (map['pressureHpa'] as num?)?.toDouble(),
    temperatureC: (map['temperatureC'] as num?)?.toDouble(),
    humidityPct: (map['humidityPct'] as num?)?.toDouble(),
    pressureDeltaHpa: (map['pressureDeltaHpa'] as num?)?.toDouble(),
    fetchedAt: DateTime.parse(map['fetchedAt'] as String),
  );

  /// Sentence-form summary for the Hoy chip.
  String shortSummary() {
    final parts = <String>[];
    if (pressureHpa != null) {
      final p = pressureHpa!.round();
      final arrow = pressureDeltaHpa == null
          ? ''
          : pressureDeltaHpa! <= -3
          ? ' ↓${pressureDeltaHpa!.abs().round()}'
          : pressureDeltaHpa! >= 3
          ? ' ↑${pressureDeltaHpa!.round()}'
          : '';
      parts.add('$p hPa$arrow');
    }
    if (temperatureC != null) parts.add('${temperatureC!.round()}°C');
    if (humidityPct != null) parts.add('${humidityPct!.round()}% hum.');
    return parts.join(' · ');
  }
}

// =============================================================================
// THERAPY EVENTS (passive therapies: kinesio, acupuntura, masaje, etc.)
// =============================================================================
// Distinct from ActivityEvent because therapies are passive, clinical,
// often paid, and tracked for outcome rather than effort.
// Source: Steen, Jaiswal & Kumbhare (2025); Maarj et al. (2022).

class TherapyEvent {
  final String id;
  final DateTime timestamp;
  final String modality; // e.g. "Kinesiología", "Acupuntura"
  final String? bodyArea; // e.g. "Cervicales", "Lumbar"
  final int? durationMinutes;
  final String? therapistOrPlace; // free text
  final int? cost; // CLP, optional
  final int? severityBefore; // 0-4, e-VAS pre-session
  final int? severityAfter; // 0-4, e-VAS post-session
  final String? note;

  TherapyEvent({
    String? id,
    required this.timestamp,
    required this.modality,
    this.bodyArea,
    this.durationMinutes,
    this.therapistOrPlace,
    this.cost,
    this.severityBefore,
    this.severityAfter,
    this.note,
  }) : id = id ?? '${timestamp.millisecondsSinceEpoch}-${modality.hashCode}';

  /// Computed: positive number = improvement (before was worse), 0 = no change,
  /// negative = got worse. Null if either side is unrecorded.
  int? get severityDelta {
    if (severityBefore == null || severityAfter == null) return null;
    return severityBefore! - severityAfter!;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'modality': modality,
    'bodyArea': bodyArea,
    'durationMinutes': durationMinutes,
    'therapistOrPlace': therapistOrPlace,
    'cost': cost,
    'severityBefore': severityBefore,
    'severityAfter': severityAfter,
    'note': note,
  };

  factory TherapyEvent.fromMap(Map<String, dynamic> map) => TherapyEvent(
    id: map['id'] as String?,
    timestamp: DateTime.parse(map['timestamp'] as String),
    modality: map['modality'] as String,
    bodyArea: map['bodyArea'] as String?,
    durationMinutes: map['durationMinutes'] as int?,
    therapistOrPlace: map['therapistOrPlace'] as String?,
    cost: map['cost'] as int?,
    severityBefore: map['severityBefore'] as int?,
    severityAfter: map['severityAfter'] as int?,
    note: map['note'] as String?,
  );

  TherapyEvent copyWith({
    DateTime? timestamp,
    String? modality,
    String? bodyArea,
    int? durationMinutes,
    String? therapistOrPlace,
    int? cost,
    int? severityBefore,
    int? severityAfter,
    String? note,
  }) => TherapyEvent(
    id: id,
    timestamp: timestamp ?? this.timestamp,
    modality: modality ?? this.modality,
    bodyArea: bodyArea ?? this.bodyArea,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    therapistOrPlace: therapistOrPlace ?? this.therapistOrPlace,
    cost: cost ?? this.cost,
    severityBefore: severityBefore ?? this.severityBefore,
    severityAfter: severityAfter ?? this.severityAfter,
    note: note ?? this.note,
  );
}

/// Standard therapy modalities for Chilean / LatAm users.
/// Custom additions live on Profile.customTherapyModalities.
const kTherapyCatalog = <String>[
  'Kinesiología',
  'Acupuntura',
  'Masaje terapéutico',
  'Punción seca',
  'Terapia manual',
  'Osteopatía',
  'Fisioterapia',
  'Quiropraxia',
];

// =============================================================================
// LIFE EVENTS (context layer over symptom/dose/mood data)
// =============================================================================
// Discrete real-world events (travel, accident, move, grief, work change…)
// that contextualize the period of data they overlap. Not a daily log.
// Shown as dots on the calendar strip and as a context section in reports.

class LifeEvent {
  final String id;
  String title;
  DateTime startDate;

  /// Null means single-day event.
  DateTime? endDate;

  /// Free-form category. Suggested values live in kLifeEventCategorySuggestions.
  String? category;
  String? note;

  LifeEvent({
    String? id,
    required this.title,
    required this.startDate,
    this.endDate,
    this.category,
    this.note,
  }) : id = id ?? '${startDate.millisecondsSinceEpoch}-${title.hashCode}';

  /// Returns true if this event covers the given date (inclusive on both ends).
  bool covers(DateTime date) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = endDate == null
        ? start
        : DateTime(endDate!.year, endDate!.month, endDate!.day);
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'category': category,
    'note': note,
  };

  factory LifeEvent.fromMap(Map<String, dynamic> map) => LifeEvent(
    id: map['id'] as String?,
    title: map['title'] as String,
    startDate: DateTime.parse(map['startDate'] as String),
    endDate: map['endDate'] != null
        ? DateTime.parse(map['endDate'] as String)
        : null,
    category: map['category'] as String?,
    note: map['note'] as String?,
  );

  LifeEvent copyWith({
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? note,
    bool clearEndDate = false,
  }) => LifeEvent(
    id: id,
    title: title ?? this.title,
    startDate: startDate ?? this.startDate,
    endDate: clearEndDate ? null : (endDate ?? this.endDate),
    category: category ?? this.category,
    note: note ?? this.note,
  );
}

/// Suggested categories shown as autocomplete chips. Free-form input is allowed.
const kLifeEventCategorySuggestions = <String>[
  'viaje',
  'accidente',
  'mudanza',
  'duelo',
  'cambio laboral',
  'evento estresante',
  'evento positivo',
  'intervención médica',
  'enfermedad',
  'otro',
];

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
  normal(2, 'normal'), // BSS 3–5
  diarrhea(3, 'diarrea'); // BSS 6–7

  final int value;
  final String label;
  const BowelBucket(this.value, this.label);

  static BowelBucket fromValue(int v) {
    return values.firstWhere(
      (b) => b.value == v,
      orElse: () => BowelBucket.normal,
    );
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
    bucket: BowelBucket.parse(map['bucket'] as String?) ?? BowelBucket.normal,
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

  /// Spanish fallback (LatAm neutral). For user-facing localized labels,
  /// use SleepQualityLocalization.label(l10n) from
  /// lib/widgets/sleep_form_sheet.dart.
  final String defaultLabel;
  const SleepQuality(this.value, this.defaultLabel);

  static SleepQuality? parse(String? raw) {
    if (raw == null) return null;
    for (final q in values) {
      if (q.name == raw) return q;
    }
    return null;
  }

  static SleepQuality fromValue(int v) {
    return values.firstWhere(
      (q) => q.value == v,
      orElse: () => SleepQuality.regular,
    );
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
    quality:
        SleepQuality.parse(map['quality'] as String?) ?? SleepQuality.regular,
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

  /// Spanish fallback. Use HydrationBeverageLocalization.label(l10n) from
  /// lib/widgets/hydration_form_sheet.dart for the i18n version.
  final String defaultLabel;
  const HydrationBeverage(this.defaultLabel);

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

  /// Spanish fallback. Use SodiumSourceLocalization.label(l10n) from
  /// lib/widgets/hydration_form_sheet.dart for the i18n version.
  final String defaultLabel;
  const SodiumSource(this.defaultLabel);

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

  /// Spanish fallback. Use HrvContextLocalization.label(l10n) from
  /// lib/widgets/hrv_form_sheet.dart for the i18n version.
  final String defaultLabel;
  const HrvContext(this.defaultLabel);

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
    context: HrvContext.parse(map['context'] as String?) ?? HrvContext.morning,
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

// =============================================================================
// PHASE 5.2d — FEVER (schema v3)
// =============================================================================
// First-class temperature tracking. Distinct from SymptomEvent because
// temperatures are quantitative and require dedicated display (peak,
// trajectory, antipyretic timing). Captured in Celsius internally; UI
// handles °C ↔ °F conversion at display time.
//
// Clinical motivation: patients with EDS frequently have autonomic
// dysregulation, comorbid autoimmune conditions, or both. Fever as a
// first-class signal lets clinicians distinguish infection from
// dysautonomia symptoms — a temperature reading is unambiguous data,
// where "fiebre" buried in a symptom note is not.

enum FeverSite {
  axillary('axilar'),
  oral('oral'),
  tympanic('timpánica'),
  rectal('rectal'),
  forehead('frente');

  // Default fallback label (Spanish, LatAm neutral). For user-facing
  // localized labels, use the FeverSiteLocalization.label(l10n)
  // extension in lib/widgets/fever_form_sheet.dart.
  final String defaultLabel;
  const FeverSite(this.defaultLabel);

  static FeverSite? parse(String? raw) {
    if (raw == null) return null;
    for (final s in values) {
      if (s.name == raw) return s;
    }
    return null;
  }
}

class FeverReading {
  final String id;
  final DateTime timestamp;

  /// Temperature in Celsius. Single source of truth in the model — UI
  /// converts to °F at display time, never the other direction.
  final double temperatureC;

  final FeverSite site;

  /// Did the user take an antipyretic in roughly the 4h leading up to (or
  /// concurrent with) this reading? Stored as a simple bool; the user
  /// records the temperature they observe, and this flag contextualizes it
  /// (a 38.2°C reading after paracetamol means something different than
  /// 38.2°C with no medication on board).
  final bool antipyreticTaken;

  /// Optional free-text antipyretic name ("paracetamol", "ibuprofeno").
  /// Not normalized to MedicationDef in 5.2d.1 — that mapping is
  /// correlation engine territory and can be inferred later by name match.
  final String? antipyreticName;

  final String? note;

  FeverReading({
    String? id,
    required this.timestamp,
    required this.temperatureC,
    this.site = FeverSite.axillary,
    this.antipyreticTaken = false,
    this.antipyreticName,
    this.note,
  }) : id = id ?? _newId();

  FeverReading copyWith({
    DateTime? timestamp,
    double? temperatureC,
    FeverSite? site,
    bool? antipyreticTaken,
    String? antipyreticName,
    String? note,
  }) {
    return FeverReading(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      temperatureC: temperatureC ?? this.temperatureC,
      site: site ?? this.site,
      antipyreticTaken: antipyreticTaken ?? this.antipyreticTaken,
      antipyreticName: antipyreticName ?? this.antipyreticName,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'temperatureC': temperatureC,
    'site': site.name,
    'antipyreticTaken': antipyreticTaken,
    'antipyreticName': antipyreticName,
    'note': note,
  };

  factory FeverReading.fromMap(Map<String, dynamic> map) => FeverReading(
    id: map['id'] as String?,
    timestamp: DateTime.parse(map['timestamp'] as String),
    temperatureC: (map['temperatureC'] as num).toDouble(),
    site: FeverSite.parse(map['site'] as String?) ?? FeverSite.axillary,
    antipyreticTaken: map['antipyreticTaken'] as bool? ?? false,
    antipyreticName: map['antipyreticName'] as String?,
    note: map['note'] as String?,
  );
}
