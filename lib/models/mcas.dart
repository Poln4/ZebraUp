// Sprint E.A — MCAS (Mast Cell Activation Syndrome) detail layer.
//
// Optional detail on SymptomEvent for MCAS-specific reactions. Applied
// when `_p.settings.optionalTrackers['mcas_detail']` is enabled (settings toggle
// arrives in Sprint E.E).
//
// Captures four independent aspects of a mast cell event:
//   • What kind of reaction (multi-select, 10 categories)
//   • When it started relative to suspected exposure (single window)
//   • Suspected triggers (multi-tag, kind + optional freeform label)
//   • Red-flag markers (multi-select, drive anaphylaxis warning in E.C)
//   • Free-form notes
//
// Design decision: triggers are lightweight tags (TriggerTag) rather
// than a separate typed event stream. Fits exploratory usage — you
// notice a reaction and reason backwards to a suspected cause. If the
// exploratory flow matures and you want pre-emptive exposure logging,
// TriggerTag's fields migrate to a full TriggerEvent type additively.
//
// Clinical foundation:
//   • Weiler CR et al. 2019 AAAAI MCAS consensus
//   • Kumskova et al. 2023 GPVI/integrin bleeding patterns

// ============================================================
// Enums
// ============================================================

enum MCASReactionKind {
  flushing('flushing'),
  urticaria('urticaria'),
  itching('itching'),
  angioedema('angioedema'),
  gi('gi'),
  respiratory('respiratory'),
  cardiovascular('cardiovascular'),
  bruising('bruising'),
  heavyBleeding('heavy_bleeding'),
  other('other');

  const MCASReactionKind(this.serializationKey);
  final String serializationKey;

  static MCASReactionKind? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

enum MCASOnsetWindow {
  immediate('immediate'), // < 5 min
  earlyMinutes('early_minutes'), // 5-30 min
  lateMinutes('late_minutes'), // 30 min - 2 h
  earlyHours('early_hours'), // 2-6 h
  lateHours('late_hours'), // 6-24 h
  unknown('unknown');

  const MCASOnsetWindow(this.serializationKey);
  final String serializationKey;

  static MCASOnsetWindow? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

enum TriggerKind {
  food('food'),
  medication('medication'),
  environmental('environmental'),
  thermal('thermal'),
  hormonal('hormonal'),
  stress('stress'),
  unknown('unknown');

  const TriggerKind(this.serializationKey);
  final String serializationKey;

  static TriggerKind? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

enum MCASRedFlag {
  throatTightness('throat_tightness'),
  breathingDifficulty('breathing_difficulty'),
  tongueSwelling('tongue_swelling'),
  faintness('faintness'),
  drasticBPChange('drastic_bp_change'),
  confusion('confusion');

  const MCASRedFlag(this.serializationKey);
  final String serializationKey;

  static MCASRedFlag? fromKey(String? raw) {
    if (raw == null) return null;
    for (final v in values) {
      if (v.serializationKey == raw) return v;
    }
    return null;
  }
}

// ============================================================
// TriggerTag — kind + optional freeform label
// ============================================================

/// Lightweight tuple describing a suspected trigger.
///
/// Examples:
///   TriggerTag(kind: TriggerKind.food, label: 'queso azul')
///   TriggerTag(kind: TriggerKind.environmental, label: 'perfume nuevo')
///   TriggerTag(kind: TriggerKind.thermal, label: 'ducha muy caliente')
///   TriggerTag(kind: TriggerKind.unknown)   // "algo, pero no sé qué"
class TriggerTag {
  final TriggerKind kind;
  final String? label;

  const TriggerTag({required this.kind, this.label});

  bool get hasLabel => label != null && label!.trim().isNotEmpty;

  Map<String, dynamic> toMap() => {
    'kind': kind.serializationKey,
    if (hasLabel) 'label': label!.trim(),
  };

  factory TriggerTag.fromMap(Map<String, dynamic> m) => TriggerTag(
    kind: TriggerKind.fromKey(m['kind'] as String?) ?? TriggerKind.unknown,
    label: m['label'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is TriggerTag && kind == other.kind && label == other.label;

  @override
  int get hashCode => Object.hash(kind, label);
}

// ============================================================
// MCASDetail — the composite detail layer
// ============================================================

class MCASDetail {
  final Set<MCASReactionKind> reactionKinds;
  final MCASOnsetWindow? onsetWindow;
  final Set<TriggerTag> suspectedTriggers;
  final Set<MCASRedFlag> redFlags;
  final String? notes;

  const MCASDetail({
    this.reactionKinds = const {},
    this.onsetWindow,
    this.suspectedTriggers = const {},
    this.redFlags = const {},
    this.notes,
  });

  /// True when nothing meaningful is captured. Used by SymptomEvent to
  /// decide whether to persist the detail at all.
  bool get isEmpty =>
      reactionKinds.isEmpty &&
      onsetWindow == null &&
      suspectedTriggers.isEmpty &&
      redFlags.isEmpty &&
      (notes == null || notes!.trim().isEmpty);

  /// True when any red flag is present — drives the anaphylaxis warning
  /// dialog in Sprint E.C.
  bool get hasRedFlag => redFlags.isNotEmpty;

  MCASDetail copyWith({
    Set<MCASReactionKind>? reactionKinds,
    MCASOnsetWindow? onsetWindow,
    Set<TriggerTag>? suspectedTriggers,
    Set<MCASRedFlag>? redFlags,
    String? notes,
    bool clearOnsetWindow = false,
    bool clearNotes = false,
  }) => MCASDetail(
    reactionKinds: reactionKinds ?? this.reactionKinds,
    onsetWindow: clearOnsetWindow ? null : (onsetWindow ?? this.onsetWindow),
    suspectedTriggers: suspectedTriggers ?? this.suspectedTriggers,
    redFlags: redFlags ?? this.redFlags,
    notes: clearNotes ? null : (notes ?? this.notes),
  );

  Map<String, dynamic> toMap() => {
    if (reactionKinds.isNotEmpty)
      'reactionKinds': reactionKinds.map((k) => k.serializationKey).toList(),
    if (onsetWindow != null) 'onsetWindow': onsetWindow!.serializationKey,
    if (suspectedTriggers.isNotEmpty)
      'suspectedTriggers': suspectedTriggers.map((t) => t.toMap()).toList(),
    if (redFlags.isNotEmpty)
      'redFlags': redFlags.map((f) => f.serializationKey).toList(),
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
  };

  factory MCASDetail.fromMap(Map<String, dynamic> m) => MCASDetail(
    reactionKinds:
        (m['reactionKinds'] as List?)
            ?.map((k) => MCASReactionKind.fromKey(k as String?))
            .whereType<MCASReactionKind>()
            .toSet() ??
        const {},
    onsetWindow: MCASOnsetWindow.fromKey(m['onsetWindow'] as String?),
    suspectedTriggers:
        (m['suspectedTriggers'] as List?)
            ?.map(
              (t) => TriggerTag.fromMap(Map<String, dynamic>.from(t as Map)),
            )
            .toSet() ??
        const {},
    redFlags:
        (m['redFlags'] as List?)
            ?.map((f) => MCASRedFlag.fromKey(f as String?))
            .whereType<MCASRedFlag>()
            .toSet() ??
        const {},
    notes: m['notes'] as String?,
  );
}

// ============================================================
// Compact formatter for symptom log rendering
// ============================================================

/// Returns a compact one-line summary of the MCAS detail for rendering
/// under the symptom name in the Síntomas log, matching the pattern of
/// formatHeadacheDetailCompact / formatFatigueDetailCompact /
/// formatAbdominalDetailCompact.
///
/// Returns empty string when there is nothing meaningful to display.
/// The rendering site (Sprint E.D) should skip rendering the line
/// entirely when this returns empty.
///
/// Examples:
///   "enrojecimiento · habones · inicio 5-30 min · gatillo: queso"
///   "GI · inicio 2-6 h · gatillo: comida"
///   "urticaria · gatillo: perfume · ⚠ alerta"
String formatMCASDetailCompact(MCASDetail detail, String localeName) {
  if (detail.isEmpty) return '';

  final parts = <String>[];

  // Reaction kinds — first 3, then "+N" if more
  if (detail.reactionKinds.isNotEmpty) {
    final labels = detail.reactionKinds
        .take(3)
        .map((k) => mcasReactionKindShortLabel(k))
        .toList();
    var text = labels.join(' · ');
    if (detail.reactionKinds.length > 3) {
      text += ' +${detail.reactionKinds.length - 3}';
    }
    parts.add(text);
  }

  // Onset window (skip if unknown — noise)
  if (detail.onsetWindow != null &&
      detail.onsetWindow != MCASOnsetWindow.unknown) {
    parts.add('inicio ${mcasOnsetShortLabel(detail.onsetWindow!)}');
  }

  // First trigger with count of others
  if (detail.suspectedTriggers.isNotEmpty) {
    final t = detail.suspectedTriggers.first;
    final label = t.hasLabel ? t.label! : mcasTriggerKindShortLabel(t.kind);
    var text = 'gatillo: $label';
    if (detail.suspectedTriggers.length > 1) {
      text += ' +${detail.suspectedTriggers.length - 1}';
    }
    parts.add(text);
  }

  // Red flag marker (rendering site decides styling)
  if (detail.hasRedFlag) {
    parts.add('⚠ alerta');
  }

  return parts.join(' · ');
}

String mcasReactionKindShortLabel(MCASReactionKind k) => switch (k) {
  MCASReactionKind.flushing => 'enrojecimiento',
  MCASReactionKind.urticaria => 'habones',
  MCASReactionKind.itching => 'picazón',
  MCASReactionKind.angioedema => 'hinchazón',
  MCASReactionKind.gi => 'GI',
  MCASReactionKind.respiratory => 'respiratorio',
  MCASReactionKind.cardiovascular => 'cardiovascular',
  MCASReactionKind.bruising => 'moretones',
  MCASReactionKind.heavyBleeding => 'sangrado',
  MCASReactionKind.other => 'otra reacción',
};

String mcasOnsetShortLabel(MCASOnsetWindow w) => switch (w) {
  MCASOnsetWindow.immediate => 'inmediato',
  MCASOnsetWindow.earlyMinutes => '5-30 min',
  MCASOnsetWindow.lateMinutes => '30 min-2 h',
  MCASOnsetWindow.earlyHours => '2-6 h',
  MCASOnsetWindow.lateHours => '6-24 h',
  MCASOnsetWindow.unknown => 'incierto',
};

String mcasTriggerKindShortLabel(TriggerKind k) => switch (k) {
  TriggerKind.food => 'comida',
  TriggerKind.medication => 'medicamento',
  TriggerKind.environmental => 'ambiental',
  TriggerKind.thermal => 'térmico',
  TriggerKind.hormonal => 'hormonal',
  TriggerKind.stress => 'estrés',
  TriggerKind.unknown => 'desconocido',
};
