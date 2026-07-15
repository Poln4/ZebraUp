// §12 rediseño de dolor estructural + rework 18-jul-2026 (flujo
// combinado zona+tipo).
//
// Default entry point when logging pain in a zone with no saved
// StructuralZoneHistoryEntry, AND the default target of the symptom
// vault ("el baúl") free-text detector (structural_text_detector.dart)
// when it recognizes structural vocabulary. Captures zone, kind
// (general — muscular/articular/tendinoso/ligamentoso/tejido
// blando/nervioso/sin causa clara), and the 4 detail groups
// (laterality/pain character/antecedent/mechanics) — whichever of
// zone/kind is already known (from a zone-chip tap, or detected from
// typed text) is pre-filled and its step is skipped; the sheet only
// asks for what's missing. Chip content for the 4 groups lives in
// assets/symptom_definitions.json under the "structural" key, resolved
// via SymptomDefinitionsService (same mechanism already used for
// headache/fatigue/abdominal_pain). Zone and kind labels come from ARB
// via the extensions in lib/services/structural_taxonomy.dart — never
// duplicated into the JSON.
//
// Unlike headache/fatigue/abdominal, completing this funnel does NOT
// attach to a SymptomEvent — the caller (sintomas_tab.dart) builds a
// StructuralEvent with the resolved zone/kind (type resolved via
// kGenericStructuralTypeForKind in models.dart) and this StructuralDetail
// attached.
//
// Four distinct outcomes, wrapped in StructuralDetailSheetResult since
// a plain nullable return can't distinguish "skip" from "use the
// classic kind→type picker instead":
//   - Skip (or dismiss): caller does nothing.
//   - "Ya sé qué es": caller opens the existing classic picker
//     (_openStructuralMenu) for the now-resolved zone — no precedent in
//     this codebase for "pop this sheet, then open a different one", so
//     the caller owns that sequencing, this sheet only signals intent.
//   - Save: caller gets zone + kind + StructuralDetail (empty detail is
//     still a legitimate save — with zone+kind always present, "no
//     laterality/character/antecedent/mechanics selected" is no longer
//     equivalent to "nothing happened").

import 'package:flutter/material.dart';
import '../extensions/context_ext.dart';
import '../models/models.dart';
import '../models/structural_detail.dart';
import '../services/structural_taxonomy.dart';
import '../services/symptom_definitions_service.dart';
import 'body_zone_picker_grid.dart';
import 'symptom_definition_dialog.dart';

class StructuralDetailSheetResult {
  final String? zone;
  final StructuralEventKind? kind;
  final StructuralDetail? detail;
  final bool useClassicPicker;

  const StructuralDetailSheetResult.skip()
    : zone = null,
      kind = null,
      detail = null,
      useClassicPicker = false;

  const StructuralDetailSheetResult.save({
    required this.zone,
    required this.kind,
    this.detail,
  }) : useClassicPicker = false;

  const StructuralDetailSheetResult.classicPicker({required this.zone})
    : kind = null,
      detail = null,
      useClassicPicker = true;
}

enum _StructuralSheetStep { zone, kind, groups }

Future<StructuralDetailSheetResult?> showStructuralDetailSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  String? initialZone,
  StructuralEventKind? initialKind,
}) async {
  await SymptomDefinitionsService.instance.ensureLoaded();
  if (!context.mounted) return null;

  return showModalBottomSheet(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (ctx) => _StructuralDetailSheetBody(
      cc: contrastColor,
      ic: inverseContrastColor,
      initialZone: initialZone,
      initialKind: initialKind,
    ),
  );
}

class _StructuralDetailSheetBody extends StatefulWidget {
  final Color cc;
  final Color ic;
  final String? initialZone;
  final StructuralEventKind? initialKind;

  const _StructuralDetailSheetBody({
    required this.cc,
    required this.ic,
    this.initialZone,
    this.initialKind,
  });

  @override
  State<_StructuralDetailSheetBody> createState() =>
      _StructuralDetailSheetBodyState();
}

class _StructuralDetailSheetBodyState
    extends State<_StructuralDetailSheetBody> {
  String? _zone;
  StructuralEventKind? _kind;
  late _StructuralSheetStep _step;

  StructuralLaterality? _laterality;
  StructuralPainCharacter? _painCharacter;
  StructuralAntecedent? _antecedent;
  StructuralMechanics? _mechanics;

  @override
  void initState() {
    super.initState();
    _zone = widget.initialZone;
    _kind = widget.initialKind;
    _step = _computeStep();
  }

  _StructuralSheetStep _computeStep() {
    if (_zone == null) return _StructuralSheetStep.zone;
    if (_kind == null) return _StructuralSheetStep.kind;
    return _StructuralSheetStep.groups;
  }

  StructuralDetail _buildDetail() => StructuralDetail(
    laterality: _laterality,
    painCharacter: _painCharacter,
    antecedent: _antecedent,
    mechanics: _mechanics,
  );

  bool _isChipSelected(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'laterality':
        final v = StructuralLaterality.fromKey(chipKey);
        return v != null && _laterality == v;
      case 'pain_character':
        final v = StructuralPainCharacter.fromKey(chipKey);
        return v != null && _painCharacter == v;
      case 'antecedent':
        final v = StructuralAntecedent.fromKey(chipKey);
        return v != null && _antecedent == v;
      case 'mechanics':
        final v = StructuralMechanics.fromKey(chipKey);
        return v != null && _mechanics == v;
    }
    return false;
  }

  void _handleChipTap(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'laterality':
        final v = StructuralLaterality.fromKey(chipKey);
        if (v == null) return;
        setState(() => _laterality = _laterality == v ? null : v);
        break;
      case 'pain_character':
        final v = StructuralPainCharacter.fromKey(chipKey);
        if (v == null) return;
        setState(() => _painCharacter = _painCharacter == v ? null : v);
        break;
      case 'antecedent':
        final v = StructuralAntecedent.fromKey(chipKey);
        if (v == null) return;
        setState(() => _antecedent = _antecedent == v ? null : v);
        break;
      case 'mechanics':
        final v = StructuralMechanics.fromKey(chipKey);
        if (v == null) return;
        setState(() => _mechanics = _mechanics == v ? null : v);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.cc;
    final ic = widget.ic;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
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
              switch (_step) {
                _StructuralSheetStep.zone => _buildZoneStep(context, cc),
                _StructuralSheetStep.kind => _buildKindStep(context, cc),
                _StructuralSheetStep.groups => _buildGroupsStep(
                  context,
                  cc,
                  ic,
                ),
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneStep(BuildContext context, Color cc) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.structuralZonePickTitle,
          style: TextStyle(color: cc, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.structuralZonePickSubtitle,
          style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 16),
        BodyZonePickerGrid(
          contrastColor: cc,
          onZoneTap: (zone) => setState(() {
            _zone = zone;
            _step = _computeStep();
          }),
        ),
      ],
    );
  }

  Widget _buildKindStep(BuildContext context, Color cc) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.structuralKindPickTitle,
          style: TextStyle(color: cc, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.structuralKindPickSubtitle,
          style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: StructuralEventKind.values.map((k) {
            return ActionChip(
              backgroundColor: Colors.transparent,
              side: BorderSide(color: cc.withValues(alpha: 0.6)),
              label: Text(
                k.label(l10n),
                style: TextStyle(color: cc, fontSize: 13),
              ),
              onPressed: () => setState(() {
                _kind = k;
                _step = _computeStep();
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGroupsStep(BuildContext context, Color cc, Color ic) {
    final l10n = context.l10n;
    final locale = l10n.localeName;
    final svc = SymptomDefinitionsService.instance;
    final zone = _zone!;
    final kind = _kind!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with info button (opens master definition)
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.structuralSheetTitle,
                style: TextStyle(
                  color: cc,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: cc.withValues(alpha: 0.7),
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: l10n.actionUnderstood,
              onPressed: () => showSymptomDefinitionDialog(
                context: context,
                symptomKey: 'structural',
                contrastColor: cc,
                inverseContrastColor: ic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.structuralSheetSubtitle,
          style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 8),
        // Passive confirmation of the zone+kind resolved by the
        // previous steps (or pre-filled from a chip tap / vault
        // detection) — lets the user notice a misdetection before
        // saving, since the vault path can silently pre-fill both.
        Text(
          '${zone.bodyZoneLabel(l10n)} · ${kind.label(l10n)}',
          style: TextStyle(color: cc, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // "Ya sé qué es" — prominent shortcut to the classic
        // kind→tipo picker, for users who already know the
        // clinical term. Same visual weight as the funnel's own
        // Skip button below (§3 item 6 — Saltar prominente).
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: cc, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size.fromHeight(44),
          ),
          onPressed: () => Navigator.pop(
            context,
            StructuralDetailSheetResult.classicPicker(zone: zone),
          ),
          child: Text(
            l10n.structuralKnownTermShortcut,
            style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 20),

        // 4 groups in JSON insertion order
        ...svc.getGroupKeysInOrder('structural').map((groupKey) {
          final header =
              svc.getGroupHeader('structural', groupKey, locale) ?? groupKey;
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
                    final chipLabel =
                        svc.getChipLabel('structural', groupKey, chipKey, locale) ??
                        chipKey;
                    final isSelected = _isChipSelected(groupKey, chipKey);
                    return _StructuralChip(
                      label: chipLabel,
                      selected: isSelected,
                      cc: cc,
                      ic: ic,
                      onToggle: () => _handleChipTap(groupKey, chipKey),
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
        }),

        const SizedBox(height: 4),

        // Footer: Skip (prominent, secondary) + Save (primary)
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cc, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(
                  context,
                  const StructuralDetailSheetResult.skip(),
                ),
                child: Text(
                  l10n.actionSkip,
                  style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cc,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  final detail = _buildDetail();
                  Navigator.pop(
                    context,
                    StructuralDetailSheetResult.save(
                      zone: zone,
                      kind: kind,
                      detail: detail.isEmpty ? null : detail,
                    ),
                  );
                },
                child: Text(
                  l10n.actionSave,
                  style: TextStyle(color: ic, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom chip rendering label + info-icon. Same shape as
/// _HeadacheChip (headache_detail_sheet.dart) — duplicated rather than
/// shared because the two live in different files with no existing
/// shared-widget module for this pattern; extracting one is a fair
/// follow-up if a 5th symptom needs the same chip.
class _StructuralChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color cc;
  final Color ic;
  final VoidCallback onToggle;
  final VoidCallback onInfo;

  const _StructuralChip({
    required this.label,
    required this.selected,
    required this.cc,
    required this.ic,
    required this.onToggle,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = selected ? ic : cc;
    final iconColor = selected
        ? ic.withValues(alpha: 0.7)
        : cc.withValues(alpha: 0.55);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
          decoration: BoxDecoration(
            color: selected ? cc : Colors.transparent,
            border: Border.all(color: cc),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(color: labelColor, fontSize: 13)),
              const SizedBox(width: 2),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onInfo,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.info_outline, size: 14, color: iconColor),
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
