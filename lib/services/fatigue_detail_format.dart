// D.1 — Compact fatigue detail formatter
//
// Utility for rendering a FatigueDetail as a short, human-readable
// summary. Used by sintomas_tab TODAY combined log and hoy_tab narrative
// summary. Mirrors lib/services/headache_detail_format.dart.
//
// Output shape:
//   "post-esfuerzo · durante el día · niebla mental, sueño no reparador · mala noche"
//
// Groups are joined with " · " (mid-dot with surrounding spaces) so the
// four schema layers stay visually delimited. Multi-select chips within
// a group are joined with ", ". Chip labels are lowercased to blend into
// prose. Empty groups are omitted.

import '../models/fatigue_detail.dart';
import 'symptom_definitions_service.dart';

/// Returns a compact " · "-delimited summary of [detail] in [locale].
/// Returns the empty string if the detail carries no selections.
String formatFatigueDetailCompact(FatigueDetail detail, String locale) {
  if (detail.isEmpty) return '';

  final svc = SymptomDefinitionsService.instance;
  final parts = <String>[];

  final type = detail.type;
  if (type != null) {
    final label = svc.getChipLabel(
      'fatigue',
      'type',
      type.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  final temp = detail.temporalPattern;
  if (temp != null) {
    final label = svc.getChipLabel(
      'fatigue',
      'temporal_pattern',
      temp.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  if (detail.accompaniments.isNotEmpty) {
    final labels = <String>[];
    for (final a in detail.accompaniments) {
      final label = svc.getChipLabel(
        'fatigue',
        'accompaniments',
        a.serializationKey,
        locale,
      );
      if (label != null) labels.add(label.toLowerCase());
    }
    if (labels.isNotEmpty) parts.add(labels.join(', '));
  }

  if (detail.triggers.isNotEmpty) {
    final labels = <String>[];
    for (final t in detail.triggers) {
      final label = svc.getChipLabel(
        'fatigue',
        'trigger',
        t.serializationKey,
        locale,
      );
      if (label != null) labels.add(label.toLowerCase());
    }
    if (labels.isNotEmpty) parts.add(labels.join(', '));
  }

  return parts.join(' \u00b7 ');
}
