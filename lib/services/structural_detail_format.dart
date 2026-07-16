// §12 — Compact structural detail formatter
//
// Utility for rendering a StructuralDetail (4-group funnel) or a
// zone-history quick-log outcome (severity + comparedToUsual) as a
// short summary for the "Registros de hoy" timeline. Mirrors
// abdominal_detail_format.dart shape.
//
// Output shape (funnel path):
//   "izquierda · agudo/punzante · post-esfuerzo diferido · empeora con movimiento"
//
// Output shape (quick-log path):
//   "moderada · peor que de costumbre"

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../models/structural_detail.dart';
import '../services/clinical_localizations.dart';
import 'symptom_definitions_service.dart';

String formatStructuralDetailCompact(StructuralDetail detail, String locale) {
  if (detail.isEmpty) return '';

  final svc = SymptomDefinitionsService.instance;
  final parts = <String>[];

  final lat = detail.laterality;
  if (lat != null) {
    final label = svc.getChipLabel(
      'structural',
      'laterality',
      lat.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  final ch = detail.painCharacter;
  if (ch != null) {
    final label = svc.getChipLabel(
      'structural',
      'pain_character',
      ch.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  final ant = detail.antecedent;
  if (ant != null) {
    final label = svc.getChipLabel(
      'structural',
      'antecedent',
      ant.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  final mech = detail.mechanics;
  if (mech != null) {
    final label = svc.getChipLabel(
      'structural',
      'mechanics',
      mech.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  return parts.join(' · ');
}

/// §12.6b — Compact summary for a bleeding-detail event (origin +
/// ISTH-BAT-adapted severity), captured for softTissue-kind events
/// instead of the 4-group funnel. Mirrors formatStructuralDetailCompact.
String formatStructuralBleedingDetailCompact(
  StructuralBleedingDetail detail,
  String locale,
) {
  if (detail.isEmpty) return '';

  final svc = SymptomDefinitionsService.instance;
  final parts = <String>[];

  final onset = detail.onset;
  if (onset != null) {
    final label = svc.getChipLabel(
      'structural',
      'bleeding_onset',
      onset.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  final severity = detail.severity;
  if (severity != null) {
    final label = svc.getChipLabel(
      'structural',
      'bleeding_severity',
      severity.serializationKey,
      locale,
    );
    if (label != null) parts.add(label.toLowerCase());
  }

  return parts.join(' · ');
}

/// Compact summary for the zone-history quick-log path — severity +
/// "¿distinto a lo usual?", the two fields that path captures instead
/// of the 4-group funnel.
String formatStructuralQuickLogCompact(
  StructuralEvent event,
  AppLocalizations l10n,
) {
  final parts = <String>[];

  final sev = event.severity;
  if (sev != null) parts.add(sev.severityLabel(l10n).toLowerCase());

  final cmp = event.comparedToUsual;
  if (cmp != null) {
    final label = switch (cmp) {
      StructuralComparisonToUsual.worse => l10n.structuralComparedToUsualWorse,
      StructuralComparisonToUsual.normal =>
        l10n.structuralComparedToUsualNormal,
      StructuralComparisonToUsual.better =>
        l10n.structuralComparedToUsualBetter,
    };
    parts.add(label.toLowerCase());
  }

  return parts.join(' · ');
}
