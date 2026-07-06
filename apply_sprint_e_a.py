#!/usr/bin/env python3
"""
ZebraUp — Sprint E.A: MCAS model layer.

Additive foundation for MCAS-specific detail capture on SymptomEvent.
No UI, no widget, no integration hook — pure model + serialization.
Sheet UI comes in E.B, red flag detection in E.C, rendering in E.D,
settings toggle in E.E.

Clinical foundation:
  • Weiler CR et al. 2019 AAAAI MCAS consensus (reaction categories,
    onset windows, red flag markers)
  • Kumskova et al. 2023 GPVI/integrin bleeding patterns (bruising +
    heavy bleeding as reaction kinds)

Design decision (see message context): triggers modeled as TriggerTag
lightweight tuples INSIDE MCASDetail, NOT as a separate TriggerEvent
type. Rationale: user's context is exploratory (no MCAS diagnosis);
pre-emptive trigger logging assumes you know your triggers. Reverse
flow (reaction → suspected trigger) fits exploration better. Migration
path to TriggerEvent open — TriggerTag preserves the fields it would
need.

Applied:

  1. lib/models/mcas.dart — NEW.
     - 4 enums: MCASReactionKind (10), MCASOnsetWindow (6), TriggerKind (7),
       MCASRedFlag (6)
     - TriggerTag class (kind + optional label)
     - MCASDetail class with reactionKinds / onsetWindow / suspectedTriggers /
       redFlags / notes, plus isEmpty / hasRedFlag / copyWith / toMap / fromMap
     - formatMCASDetailCompact(detail, locale) helper for future log rendering
     - Dart 3 switch expressions for exhaustive enum handling

  2. lib/models/models.dart:
     - `import 'mcas.dart';` after existing model imports
     - `final MCASDetail? mcasDetail;` field on SymptomEvent (after
       abdominalDetail)
     - `this.mcasDetail,` ctor param
     - `if (mcasDetail != null) 'mcasDetail': mcasDetail!.toMap(),` in toMap
     - `mcasDetail: map['mcasDetail'] != null ? MCASDetail.fromMap(...) : null,`
       in fromMap

Idempotent per sentinel. Voseo scan on generated Spanish labels.

Post-run:
    dart format lib/models/mcas.dart lib/models/models.dart
    flutter analyze
"""

import re
import sys
from pathlib import Path

MCAS_PATH = Path("lib/models/mcas.dart")
MODELS_PATH = Path("lib/models/models.dart")

log: list[str] = []


def rec(status: str, patch: str, msg: str = "") -> None:
    log.append(f"  {status:4}  {patch:36}  {msg}")


VOSEO_PATTERNS = [
    r'\bpodés\b', r'\btenés\b', r'\bquerés\b', r'\bsabés\b',
    r'\bvenís\b', r'\bpensás\b', r'\bdebés\b', r'\bsentís\b',
    r'\bhablás\b', r'\bcomés\b', r'\btomás\b',
    r'\bsos\b', r'\bvos\b',
    r'\btocá\b', r'\bregistrá\b', r'\btratá\b', r'\bponé\b',
    r'\bmirá\b', r'\bandá\b', r'\bescribí\b', r'\belegí\b',
    r'\brevisá\b', r'\bdecí\b',
]


def voseo_scan(text: str, name: str) -> list[str]:
    findings = []
    for pat in VOSEO_PATTERNS:
        for m in re.finditer(pat, text, re.IGNORECASE):
            findings.append(f"{pat} → {m.group(0)} in {name}")
    return findings


# ============================================================
# FILE: lib/models/mcas.dart
# ============================================================

MCAS_SOURCE = r'''// Sprint E.A — MCAS (Mast Cell Activation Syndrome) detail layer.
//
// Optional detail on SymptomEvent for MCAS-specific reactions. Applied
// when `_p.optionalTrackers['mcas_detail']` is enabled (settings toggle
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
  immediate('immediate'),         // < 5 min
  earlyMinutes('early_minutes'),  // 5-30 min
  lateMinutes('late_minutes'),    // 30 min - 2 h
  earlyHours('early_hours'),      // 2-6 h
  lateHours('late_hours'),        // 6-24 h
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
  }) =>
      MCASDetail(
        reactionKinds: reactionKinds ?? this.reactionKinds,
        onsetWindow:
            clearOnsetWindow ? null : (onsetWindow ?? this.onsetWindow),
        suspectedTriggers: suspectedTriggers ?? this.suspectedTriggers,
        redFlags: redFlags ?? this.redFlags,
        notes: clearNotes ? null : (notes ?? this.notes),
      );

  Map<String, dynamic> toMap() => {
        if (reactionKinds.isNotEmpty)
          'reactionKinds':
              reactionKinds.map((k) => k.serializationKey).toList(),
        if (onsetWindow != null) 'onsetWindow': onsetWindow!.serializationKey,
        if (suspectedTriggers.isNotEmpty)
          'suspectedTriggers':
              suspectedTriggers.map((t) => t.toMap()).toList(),
        if (redFlags.isNotEmpty)
          'redFlags': redFlags.map((f) => f.serializationKey).toList(),
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      };

  factory MCASDetail.fromMap(Map<String, dynamic> m) => MCASDetail(
        reactionKinds: (m['reactionKinds'] as List?)
                ?.map((k) => MCASReactionKind.fromKey(k as String?))
                .whereType<MCASReactionKind>()
                .toSet() ??
            const {},
        onsetWindow: MCASOnsetWindow.fromKey(m['onsetWindow'] as String?),
        suspectedTriggers: (m['suspectedTriggers'] as List?)
                ?.map((t) => TriggerTag.fromMap(
                    Map<String, dynamic>.from(t as Map)))
                .toSet() ??
            const {},
        redFlags: (m['redFlags'] as List?)
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
        .map(_reactionKindShortLabel)
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
    parts.add('inicio ${_onsetShortLabel(detail.onsetWindow!)}');
  }

  // First trigger with count of others
  if (detail.suspectedTriggers.isNotEmpty) {
    final t = detail.suspectedTriggers.first;
    final label =
        t.hasLabel ? t.label! : _triggerKindShortLabel(t.kind);
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

String _reactionKindShortLabel(MCASReactionKind k) => switch (k) {
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

String _onsetShortLabel(MCASOnsetWindow w) => switch (w) {
      MCASOnsetWindow.immediate => 'inmediato',
      MCASOnsetWindow.earlyMinutes => '5-30 min',
      MCASOnsetWindow.lateMinutes => '30 min-2 h',
      MCASOnsetWindow.earlyHours => '2-6 h',
      MCASOnsetWindow.lateHours => '6-24 h',
      MCASOnsetWindow.unknown => 'incierto',
    };

String _triggerKindShortLabel(TriggerKind k) => switch (k) {
      TriggerKind.food => 'comida',
      TriggerKind.medication => 'medicamento',
      TriggerKind.environmental => 'ambiental',
      TriggerKind.thermal => 'térmico',
      TriggerKind.hormonal => 'hormonal',
      TriggerKind.stress => 'estrés',
      TriggerKind.unknown => 'desconocido',
    };
'''


# ============================================================
# STEP 1 — write mcas.dart
# ============================================================

def write_mcas() -> None:
    if MCAS_PATH.exists():
        existing = MCAS_PATH.read_text()
        if "Sprint E.A" in existing:
            rec("SKIP", "mcas.dart", "already present")
            return
    MCAS_PATH.parent.mkdir(parents=True, exist_ok=True)
    MCAS_PATH.write_text(MCAS_SOURCE)
    rec("OK", "mcas.dart", f"wrote {MCAS_PATH}")


# ============================================================
# STEP 2 — patch models.dart
# ============================================================

def patch_models() -> None:
    if not MODELS_PATH.exists():
        rec("FAIL", "models.dart", "file not found")
        return
    src = MODELS_PATH.read_text()
    original = src

    # 2a — import mcas.dart
    if "import 'mcas.dart';" in src:
        rec("SKIP", "models:import", "already present")
    else:
        lines = src.split('\n')
        last_import = -1
        for i, line in enumerate(lines):
            if line.startswith('import '):
                last_import = i
        if last_import >= 0:
            lines.insert(last_import + 1, "import 'mcas.dart';")
            src = '\n'.join(lines)
            rec("OK", "models:import", "added mcas.dart import")
        else:
            rec("FAIL", "models:import", "no imports found")

    # 2b — mcasDetail field on SymptomEvent (after abdominalDetail field)
    if "MCASDetail? mcasDetail" in src:
        rec("SKIP", "models:symptom_field", "already present")
    else:
        old = "  final AbdominalDetail? abdominalDetail;"
        new = ("  final AbdominalDetail? abdominalDetail;\n"
               "\n"
               "  // Sprint E.A — MCAS detail layer (additive, gated by\n"
               "  // optionalTrackers['mcas_detail'] once E.E wires the toggle).\n"
               "  final MCASDetail? mcasDetail;")
        if old in src:
            src = src.replace(old, new, 1)
            rec("OK", "models:symptom_field", "added mcasDetail field")
        else:
            rec("FAIL", "models:symptom_field",
                "AbdominalDetail? abdominalDetail anchor missing")

    # 2c — this.mcasDetail ctor param (after this.abdominalDetail)
    if "this.mcasDetail" in src:
        rec("SKIP", "models:symptom_ctor", "already present")
    else:
        old = "    this.abdominalDetail,"
        new = "    this.abdominalDetail,\n    this.mcasDetail,"
        # Confirm this appears in SymptomEvent context (unique)
        count = src.count(old)
        if count == 1:
            src = src.replace(old, new)
            rec("OK", "models:symptom_ctor", "added mcasDetail ctor param")
        elif count > 1:
            rec("WARN", "models:symptom_ctor",
                f"{count} matches — ambiguous, skipping")
        else:
            rec("FAIL", "models:symptom_ctor",
                "this.abdominalDetail ctor anchor missing")

    # 2d — toMap entry
    if "'mcasDetail'" in src:
        rec("SKIP", "models:symptom_toMap", "already present")
    else:
        # Anchor on abdominalDetail toMap entry
        # Pattern (best guess based on optional-detail idiom):
        #   if (abdominalDetail != null) 'abdominalDetail': abdominalDetail!.toMap(),
        old = ("        if (abdominalDetail != null)\n"
               "          'abdominalDetail': abdominalDetail!.toMap(),")
        new = ("        if (abdominalDetail != null)\n"
               "          'abdominalDetail': abdominalDetail!.toMap(),\n"
               "        if (mcasDetail != null) 'mcasDetail': mcasDetail!.toMap(),")
        if old in src:
            src = src.replace(old, new, 1)
            rec("OK", "models:symptom_toMap", "added mcasDetail toMap entry")
        else:
            # Try single-line variant (dart format may have collapsed)
            old2 = ("        if (abdominalDetail != null) "
                    "'abdominalDetail': abdominalDetail!.toMap(),")
            new2 = ("        if (abdominalDetail != null) "
                    "'abdominalDetail': abdominalDetail!.toMap(),\n"
                    "        if (mcasDetail != null) 'mcasDetail': mcasDetail!.toMap(),")
            if old2 in src:
                src = src.replace(old2, new2, 1)
                rec("OK", "models:symptom_toMap",
                    "added mcasDetail toMap entry (single-line variant)")
            else:
                rec("FAIL", "models:symptom_toMap",
                    "abdominalDetail toMap anchor missing — see manual step")

    # 2e — fromMap entry
    if "MCASDetail.fromMap" in src:
        rec("SKIP", "models:symptom_fromMap", "already present")
    else:
        # Anchor pattern (best guess):
        #   abdominalDetail: map['abdominalDetail'] != null
        #       ? AbdominalDetail.fromMap(...)
        #       : null,
        # Locate via AbdominalDetail.fromMap unique match
        anchor_pattern = re.compile(
            r"(abdominalDetail:\s*map\[[^\]]+\]\s*!=\s*null\s*\n?\s*\?\s*"
            r"AbdominalDetail\.fromMap\([^)]+\)\s*\n?\s*:\s*null,)",
            re.DOTALL,
        )
        m = anchor_pattern.search(src)
        if m:
            insertion = (
                "\n        mcasDetail: map['mcasDetail'] != null\n"
                "            ? MCASDetail.fromMap(\n"
                "                Map<String, dynamic>.from(map['mcasDetail'] as Map))\n"
                "            : null,"
            )
            insert_pos = m.end()
            src = src[:insert_pos] + insertion + src[insert_pos:]
            rec("OK", "models:symptom_fromMap",
                "added mcasDetail fromMap entry")
        else:
            rec("FAIL", "models:symptom_fromMap",
                "AbdominalDetail.fromMap anchor pattern not matched — "
                "see manual step")

    if src != original:
        MODELS_PATH.write_text(src)


# ============================================================
# Voseo scan
# ============================================================

def scan_all() -> None:
    findings = voseo_scan(MCAS_SOURCE, "mcas.dart")
    findings += voseo_scan(Path(__file__).read_text(), "python source")
    if findings:
        rec("WARN", "voseo_scan", f"{len(findings)} match(es):")
        for f in findings:
            log.append(f"          - {f}")
    else:
        rec("OK", "voseo_scan", "no voseo patterns detected")


# ============================================================
# MAIN
# ============================================================

def main() -> None:
    if not Path("pubspec.yaml").exists():
        print("ERROR: run from project root")
        sys.exit(1)

    print("Sprint E.A — MCAS model layer\n")

    write_mcas()
    patch_models()
    scan_all()

    print("\n".join(log))

    # Check if fromMap / toMap failed and print manual instructions
    fails = [l for l in log if 'FAIL' in l and ('toMap' in l or 'fromMap' in l)]
    if fails:
        print("""
─────────────────────────────────────────────────────────────────────
MANUAL STEP — one or both of the SymptomEvent toMap/fromMap patches
failed because the anchor pattern didn't match the exact idiom in
your models.dart. Apply manually:

In SymptomEvent.toMap(), after the abdominalDetail entry:

    if (mcasDetail != null) 'mcasDetail': mcasDetail!.toMap(),

In SymptomEvent.fromMap(), after the abdominalDetail entry:

    mcasDetail: map['mcasDetail'] != null
        ? MCASDetail.fromMap(
            Map<String, dynamic>.from(map['mcasDetail'] as Map))
        : null,

For a targeted patch script next turn, paste 30 lines around the
abdominalDetail entries in toMap and fromMap:

    grep -n "abdominalDetail" lib/models/models.dart
    sed -n '[first_hit-5],[last_hit+5]p' lib/models/models.dart
─────────────────────────────────────────────────────────────────────
""")

    print("\nNext: dart format lib/models/mcas.dart lib/models/models.dart \\")
    print("      && flutter analyze")


if __name__ == "__main__":
    main()