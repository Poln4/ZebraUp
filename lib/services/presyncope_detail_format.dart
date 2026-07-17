// D.3 — Compact presyncope detail formatter
//
// Utility for rendering a PresyncopeDetail as a short summary. Used
// by sintomas_tab TODAY log. Mirrors abdominal_detail_format.dart
// shape.
//
// Output shape:
//   "al pararme · visión en túnel u oscurecida, sudor frío · perdí el
//    conocimiento, aunque breve · rápida (menos de un minuto)"
//
// Groups joined with " · ", multi-select chips within a group joined
// with ", ". Chip labels lowercased for prose flow. Empty groups
// omitted. Unlike abdominal_pain's "trigger" group key, presyncope's
// group keys match the Dart field names 1:1 (mechanism/prodrome/
// outcome/recovery) — no singular/plural mismatch to replicate here.

import '../models/presyncope_detail.dart';
import 'symptom_definitions_service.dart';

String formatPresyncopeDetailCompact(PresyncopeDetail detail, String locale) {
  if (detail.isEmpty) return '';

  final svc = SymptomDefinitionsService.instance;
  final parts = <String>[];

  final mechanism = detail.mechanism;
  if (mechanism != null) {
    final label = svc.getChipLabel(
      'presyncope',
      'mechanism',
      mechanism.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  if (detail.prodrome.isNotEmpty) {
    final labels = <String>[];
    for (final p in detail.prodrome) {
      final label = svc.getChipLabel(
        'presyncope',
        'prodrome',
        p.serializationKey,
        locale,
      );
      if (label != null) labels.add(label.toLowerCase());
    }
    if (labels.isNotEmpty) parts.add(labels.join(', '));
  }

  final outcome = detail.outcome;
  if (outcome != null) {
    final label = svc.getChipLabel(
      'presyncope',
      'outcome',
      outcome.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  final recovery = detail.recovery;
  if (recovery != null) {
    final label = svc.getChipLabel(
      'presyncope',
      'recovery',
      recovery.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  return parts.join(' · ');
}
