// C.4 — Symptom definition dialog (reusable)
//
// Shows a localized definition dialog. Two modes:
//   - Master mode: pass only `symptomKey`. Shows master label + master
//     definition for that symptom.
//   - Chip mode: pass `symptomKey + groupKey + chipKey`. Shows chip
//     label + clinical definition.
//
// Will be reused by other symptom detail layers (fatiga, dolor
// abdominal, etc.) once those land.

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/symptom_definitions_service.dart';

/// Shows the dialog and awaits dismissal. Returns when the user taps
/// "Understood" or dismisses by tapping outside.
///
/// If `groupKey` and `chipKey` are both provided, displays the chip
/// definition; otherwise shows the master definition for `symptomKey`.
Future<void> showSymptomDefinitionDialog({
  required BuildContext context,
  required String symptomKey,
  String? groupKey,
  String? chipKey,
  required Color contrastColor,
  required Color inverseContrastColor,
}) async {
  await SymptomDefinitionsService.instance.ensureLoaded();
  if (!context.mounted) return;

  final l10n = AppLocalizations.of(context)!;
  final locale = l10n.localeName;
  final svc = SymptomDefinitionsService.instance;

  final String title;
  final String body;
  if (groupKey != null && chipKey != null) {
    title = svc.getChipLabel(symptomKey, groupKey, chipKey, locale) ?? chipKey;
    body = svc.getChipDefinition(symptomKey, groupKey, chipKey, locale) ?? '';
  } else {
    title = svc.getMasterLabel(symptomKey, locale) ?? symptomKey;
    body = svc.getMasterDefinition(symptomKey, locale) ?? '';
  }

  if (!context.mounted) return;

  return showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: inverseContrastColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: contrastColor, width: 1.5),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      title: Text(
        title,
        style: TextStyle(
          color: contrastColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: SelectableText(
          body.isEmpty ? '—' : body,
          style: TextStyle(color: contrastColor, fontSize: 14, height: 1.5),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx),
          child: Text(
            l10n.actionUnderstood,
            style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
