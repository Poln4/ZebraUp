// D.2 — Compact abdominal detail formatter
//
// Utility for rendering an AbdominalDetail as a short summary. Used
// by sintomas_tab TODAY log and hoy_tab narrative. Mirrors
// fatigue_detail_format.dart shape.
//
// Output shape:
//   "epigástrico · cólico · postprandial inmediato · náusea, hinchazón"
//
// Groups joined with " · ", multi-select chips within a group joined
// with ", ". Chip labels lowercased for prose flow. Empty groups
// omitted. `linkedBowelEventId` is not rendered in the compact
// summary — it is metadata for the D.2.E integration cruzada.

import '../models/abdominal_detail.dart';
import 'symptom_definitions_service.dart';

String formatAbdominalDetailCompact(
  AbdominalDetail detail,
  String locale,
) {
  if (detail.isEmpty) return '';

  final svc = SymptomDefinitionsService.instance;
  final parts = <String>[];

  final loc = detail.location;
  if (loc != null) {
    final label = svc.getChipLabel(
      'abdominal_pain', 'location', loc.serializationKey, locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  final q = detail.quality;
  if (q != null) {
    final label = svc.getChipLabel(
      'abdominal_pain', 'quality', q.serializationKey, locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  final t = detail.timing;
  if (t != null) {
    final label = svc.getChipLabel(
      'abdominal_pain', 'timing', t.serializationKey, locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  if (detail.accompaniments.isNotEmpty) {
    final labels = <String>[];
    for (final a in detail.accompaniments) {
      final label = svc.getChipLabel(
        'abdominal_pain', 'accompaniments', a.serializationKey, locale,
      );
      if (label != null) labels.add(label.toLowerCase());
    }
    if (labels.isNotEmpty) parts.add(labels.join(', '));
  }

  if (detail.triggers.isNotEmpty) {
    final labels = <String>[];
    for (final t in detail.triggers) {
      final label = svc.getChipLabel(
        'abdominal_pain', 'trigger', t.serializationKey, locale,
      );
      if (label != null) labels.add(label.toLowerCase());
    }
    if (labels.isNotEmpty) parts.add(labels.join(', '));
  }

  return parts.join(' \u00b7 ');
}
