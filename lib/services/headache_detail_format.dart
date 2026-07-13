// C.4 — Headache detail compact formatter
//
// Pure helper that turns a HeadacheDetail into a one-line summary of
// localized chip labels separated by " · " (middle dot). Used in:
//   - sintomas_tab.dart: today's symptom log entry render
//   - hoy_tab.dart: narrative summary
//
// Labels are lowercased for visual consistency across the chip list
// (zh-TW labels are unaffected — Han characters have no case).

import '../l10n/app_localizations.dart';
import '../models/headache_detail.dart';
import 'symptom_definitions_service.dart';

/// Returns a compact, " · "-separated string of localized chip labels
/// for a HeadacheDetail in the order:
///   locations → quality → accompaniments → postural pattern → onset
///
/// Returns an empty string when the detail has no marked chips or when
/// no labels resolve (definitions service not loaded, missing keys).
String formatHeadacheDetailCompact(
  HeadacheDetail detail,
  AppLocalizations l10n,
) {
  final svc = SymptomDefinitionsService.instance;
  final locale = l10n.localeName;
  final parts = <String>[];

  void addChip(String groupKey, String chipKey) {
    final label = svc.getChipLabel('headache', groupKey, chipKey, locale);
    if (label != null && label.isNotEmpty) {
      parts.add(label.toLowerCase());
    }
  }

  for (final loc in detail.locations) {
    addChip('location', loc.serializationKey);
  }
  if (detail.quality != null) {
    addChip('quality', detail.quality!.serializationKey);
  }
  for (final acc in detail.accompaniments) {
    addChip('accompaniments', acc.serializationKey);
  }
  if (detail.posturalPattern != null) {
    addChip('postural_pattern', detail.posturalPattern!.serializationKey);
  }
  if (detail.onset != null) {
    addChip('onset', detail.onset!.serializationKey);
  }

  return parts.join(' · ');
}
