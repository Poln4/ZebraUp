// D.5 — Compact chest pain detail formatter
//
// Utility for rendering a ChestPainDetail as a short summary. Used by
// sintomas_tab TODAY log. Mirrors pelvic_pain_detail_format.dart shape.
//
// Output shape:
//   "retroesternal, en el centro · presión u opresión · con el
//    esfuerzo físico · dificultad para respirar, se irradia a brazo,
//    mandíbula o espalda"
//
// Groups joined with " · ", multi-select chips within a group joined
// with ", ". Chip labels lowercased for prose flow. Empty groups
// omitted. Group keys match the Dart field names 1:1 (location/
// character/triggers/accompaniments) — no singular/plural mismatch to
// replicate here.

import '../models/chest_pain_detail.dart';
import 'symptom_definitions_service.dart';

String formatChestPainDetailCompact(ChestPainDetail detail, String locale) {
  if (detail.isEmpty) return '';

  final svc = SymptomDefinitionsService.instance;
  final parts = <String>[];

  final location = detail.location;
  if (location != null) {
    final label = svc.getChipLabel(
      'chest_pain',
      'location',
      location.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  final character = detail.character;
  if (character != null) {
    final label = svc.getChipLabel(
      'chest_pain',
      'character',
      character.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  if (detail.triggers.isNotEmpty) {
    final labels = <String>[];
    for (final t in detail.triggers) {
      final label = svc.getChipLabel(
        'chest_pain',
        'triggers',
        t.serializationKey,
        locale,
      );
      if (label != null) labels.add(label.toLowerCase());
    }
    if (labels.isNotEmpty) parts.add(labels.join(', '));
  }

  if (detail.accompaniments.isNotEmpty) {
    final labels = <String>[];
    for (final a in detail.accompaniments) {
      final label = svc.getChipLabel(
        'chest_pain',
        'accompaniments',
        a.serializationKey,
        locale,
      );
      if (label != null) labels.add(label.toLowerCase());
    }
    if (labels.isNotEmpty) parts.add(labels.join(', '));
  }

  return parts.join(' · ');
}
