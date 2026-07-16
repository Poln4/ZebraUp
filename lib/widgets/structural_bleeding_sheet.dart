// §12.6b — Standalone bleeding-detail sheet for the classic picker
// ("Ya sé qué es").
//
// Shown right after the user picks a specific softTissue type (hematoma,
// contusión, corte, etc. — everything except 'burn', which isn't a
// bleeding phenomenon) from the classic kind→tipo picker
// (_openStructuralMenu in sintomas_tab.dart). That picker has no room for
// a third step inline, so this is its own small modal, calcado de
// structural_quick_log_sheet.dart: caller pops the classic picker first,
// then awaits this sheet, then saves the StructuralEvent with the result
// attached. Captures the same two groups
// (bleeding_onset/bleeding_severity, assets/symptom_definitions.json
// under "structural") as the embedded step in structural_detail_sheet.dart
// — same chip content, same StructuralChip widget (structural_chip.dart),
// different host UI, so both stay in sync for free.
//
// Returns null when skipped (or dismissed) — the event still gets saved
// by the caller, just without bleedingDetail attached.

import 'package:flutter/material.dart';
import '../extensions/context_ext.dart';
import '../models/structural_detail.dart';
import '../services/symptom_definitions_service.dart';
import 'structural_chip.dart';
import 'symptom_definition_dialog.dart';

Future<StructuralBleedingDetail?> showStructuralBleedingDetailSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
}) {
  return showModalBottomSheet<StructuralBleedingDetail>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (_) => _StructuralBleedingSheetBody(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
    ),
  );
}

class _StructuralBleedingSheetBody extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;

  const _StructuralBleedingSheetBody({
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  @override
  State<_StructuralBleedingSheetBody> createState() =>
      _StructuralBleedingSheetBodyState();
}

class _StructuralBleedingSheetBodyState
    extends State<_StructuralBleedingSheetBody> {
  BleedingOnset? _onset;
  BleedingSeverity? _severity;

  Widget _buildGroup({
    required String groupKey,
    required Color cc,
    required Color ic,
    required String locale,
    required bool Function(String chipKey) isSelected,
    required void Function(String chipKey) onTap,
  }) {
    final svc = SymptomDefinitionsService.instance;
    final header = svc.getGroupHeader('structural', groupKey, locale) ?? groupKey;
    final chipKeys = svc.getChipKeysInOrder('structural', groupKey);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              header,
              style: TextStyle(
                color: cc.withValues(alpha: 0.55),
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chipKeys.map((chipKey) {
              final label =
                  svc.getChipLabel('structural', groupKey, chipKey, locale) ??
                  chipKey;
              final selected = isSelected(chipKey);
              return StructuralChip(
                label: label,
                selected: selected,
                cc: cc,
                ic: ic,
                onToggle: () => onTap(chipKey),
                onInfo: () => showSymptomDefinitionDialog(
                  context: context,
                  symptomKey: 'structural',
                  groupKey: groupKey,
                  chipKey: chipKey,
                  contrastColor: cc,
                  inverseContrastColor: ic,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = l10n.localeName;
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cc.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.structuralBleedingLogTitle,
                style: TextStyle(
                  color: cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.structuralBleedingLogSubtitle,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              _buildGroup(
                groupKey: 'bleeding_onset',
                cc: cc,
                ic: ic,
                locale: locale,
                isSelected: (chipKey) =>
                    _onset != null &&
                    _onset == BleedingOnset.fromKey(chipKey),
                onTap: (chipKey) {
                  final v = BleedingOnset.fromKey(chipKey);
                  if (v == null) return;
                  setState(() => _onset = _onset == v ? null : v);
                },
              ),
              _buildGroup(
                groupKey: 'bleeding_severity',
                cc: cc,
                ic: ic,
                locale: locale,
                isSelected: (chipKey) =>
                    _severity != null &&
                    _severity == BleedingSeverity.fromKey(chipKey),
                onTap: (chipKey) {
                  final v = BleedingSeverity.fromKey(chipKey);
                  if (v == null) return;
                  setState(() => _severity = _severity == v ? null : v);
                },
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cc,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => Navigator.pop(
                  context,
                  StructuralBleedingDetail(onset: _onset, severity: _severity),
                ),
                child: Text(
                  l10n.actionSave,
                  style: TextStyle(color: ic, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.actionSkip,
                    style: TextStyle(color: cc.withValues(alpha: 0.6)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
