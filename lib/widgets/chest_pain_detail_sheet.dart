// D.5 — Chest pain detail sheet
//
// Bottom sheet that captures structured detail for a chest_pain log.
// Renders the 4 groups from symptom_definitions.json with chips —
// single-view layout (no wizard), mirroring pelvic_pain_detail_sheet.dart's
// mixed single/multi-select pattern.
//
// The sheet does NOT run red-flag detection — that's the caller's
// responsibility after the sheet returns (see chest_pain_red_flags.dart
// and sintomas_tab.dart). The sheet only intercepts the "tearing/
// ripping" character chip with an emergency-confirmation dialog,
// following abdominal's save-time pattern (not presyncope's tap-time
// pattern): the dialog fires on save attempt, not the instant the chip
// is tapped, so a patient can read the chip's definition via the info
// icon without being interrupted.
//
// First sheet in the app whose emergency dialog copy branches on
// Profile.conditions: when isLikelyVEDSFromConditions(profileConditions)
// is true, the dialog body references vEDS-specific emergency guidance
// (avoid chest compressions if possible, MRA/CT imaging is critical —
// both facts already in assets/zebra_wisdom.json) instead of general
// population guidance. Confirmed with Paulina before building — see
// docs/design_decisions/symptom_detail_layers.md §15. The sheet
// receives the plain conditions list, not the full Profile, keeping it
// decoupled from the model as with every other detail sheet.
//
// Returns null on:
//   - User taps "Skip" (saltar)
//   - User taps "Save" but marked no chips at all
// Returns the ChestPainDetail otherwise.

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/chest_pain_detail.dart';
import '../services/chest_pain_red_flags.dart';
import '../services/symptom_definitions_service.dart';
import 'symptom_definition_dialog.dart';

Future<ChestPainDetail?> showChestPainDetailSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required List<String> profileConditions,
  ChestPainDetail? existing,
}) async {
  await SymptomDefinitionsService.instance.ensureLoaded();
  if (!context.mounted) return null;

  return showModalBottomSheet<ChestPainDetail?>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (ctx) => _ChestPainDetailSheetBody(
      cc: contrastColor,
      ic: inverseContrastColor,
      profileConditions: profileConditions,
      existing: existing,
    ),
  );
}

class _ChestPainDetailSheetBody extends StatefulWidget {
  final Color cc;
  final Color ic;
  final List<String> profileConditions;
  final ChestPainDetail? existing;
  const _ChestPainDetailSheetBody({
    required this.cc,
    required this.ic,
    required this.profileConditions,
    this.existing,
  });

  @override
  State<_ChestPainDetailSheetBody> createState() =>
      _ChestPainDetailSheetBodyState();
}

class _ChestPainDetailSheetBodyState
    extends State<_ChestPainDetailSheetBody> {
  ChestPainLocation? _location;
  ChestPainCharacter? _character;
  late Set<ChestPainTrigger> _triggers;
  late Set<ChestPainAccompaniment> _accompaniments;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _location = e?.location;
    _character = e?.character;
    _triggers = e?.triggers.toSet() ?? <ChestPainTrigger>{};
    _accompaniments = e?.accompaniments.toSet() ?? <ChestPainAccompaniment>{};
  }

  ChestPainDetail _buildDetail() => ChestPainDetail(
    location: _location,
    character: _character,
    triggers: _triggers,
    accompaniments: _accompaniments,
  );

  bool _isChipSelected(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'location':
        final v = ChestPainLocation.fromKey(chipKey);
        return v != null && _location == v;
      case 'character':
        final v = ChestPainCharacter.fromKey(chipKey);
        return v != null && _character == v;
      case 'triggers':
        final v = ChestPainTrigger.fromKey(chipKey);
        return v != null && _triggers.contains(v);
      case 'accompaniments':
        final v = ChestPainAccompaniment.fromKey(chipKey);
        return v != null && _accompaniments.contains(v);
    }
    return false;
  }

  void _handleChipTap(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'location':
        final v = ChestPainLocation.fromKey(chipKey);
        if (v == null) return;
        setState(() => _location = _location == v ? null : v);
        break;
      case 'character':
        final v = ChestPainCharacter.fromKey(chipKey);
        if (v == null) return;
        setState(() => _character = _character == v ? null : v);
        break;
      case 'triggers':
        final v = ChestPainTrigger.fromKey(chipKey);
        if (v == null) return;
        setState(() {
          if (_triggers.contains(v)) {
            _triggers.remove(v);
          } else {
            _triggers.add(v);
          }
        });
        break;
      case 'accompaniments':
        final v = ChestPainAccompaniment.fromKey(chipKey);
        if (v == null) return;
        setState(() {
          if (_accompaniments.contains(v)) {
            _accompaniments.remove(v);
          } else {
            _accompaniments.add(v);
          }
        });
        break;
    }
  }

  /// D.5: if character = tearingOrRipping, show emergency dialog
  /// IN-SHEET before committing the save. Two branches: user changes
  /// character (stays in sheet) or acknowledges emergency (saves
  /// as-is). Fires on save attempt (not on chip selection), mirroring
  /// abdominal_detail_sheet.dart's tearing-quality pattern.
  Future<void> _attemptSave(BuildContext ctx) async {
    if (_character == ChestPainCharacter.tearingOrRipping) {
      final proceed = await _showTearingEmergencyDialog(ctx);
      if (!proceed) return; // User chose to change character — stay in sheet.
    }
    if (!mounted) return;
    final detail = _buildDetail();
    Navigator.pop(context, detail.isEmpty ? null : detail);
  }

  Future<bool> _showTearingEmergencyDialog(BuildContext ctx) async {
    final l10n = AppLocalizations.of(ctx)!;
    final isVEDS = isLikelyVEDSFromConditions(widget.profileConditions);
    final body = isVEDS
        ? l10n.chestPainTearingEmergencyBodyVEDS
        : l10n.chestPainTearingEmergencyBodyGeneral;
    final result = await showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (dctx) => AlertDialog(
        backgroundColor: widget.ic,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: widget.cc, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: widget.cc, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.chestPainTearingEmergencyTitle,
                style: TextStyle(
                  color: widget.cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            body,
            style: TextStyle(color: widget.cc, fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            style: TextButton.styleFrom(foregroundColor: widget.cc),
            child: Text(l10n.chestPainTearingEmergencyChangeCharacter),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: widget.cc),
            child: Text(
              l10n.chestPainTearingEmergencySaveAsIs,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;
    final svc = SymptomDefinitionsService.instance;
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

              // Title row with info button (opens master definition)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.chestPainSheetTitle,
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
                      symptomKey: 'chest_pain',
                      contrastColor: cc,
                      inverseContrastColor: ic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.chestPainSheetSubtitle,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // 4 groups in JSON insertion order
              ...svc.getGroupKeysInOrder('chest_pain').map((groupKey) {
                final header =
                    svc.getGroupHeader('chest_pain', groupKey, locale) ??
                    groupKey;
                final chipKeys = svc.getChipKeysInOrder(
                  'chest_pain',
                  groupKey,
                );
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
                              svc.getChipLabel(
                                'chest_pain',
                                groupKey,
                                chipKey,
                                locale,
                              ) ??
                              chipKey;
                          final isSelected = _isChipSelected(
                            groupKey,
                            chipKey,
                          );
                          return _ChestPainChip(
                            label: chipLabel,
                            selected: isSelected,
                            cc: cc,
                            ic: ic,
                            onToggle: () => _handleChipTap(groupKey, chipKey),
                            onInfo: () => showSymptomDefinitionDialog(
                              context: context,
                              symptomKey: 'chest_pain',
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
                      onPressed: () => Navigator.pop(context, null),
                      child: Text(
                        l10n.actionSkip,
                        style: TextStyle(
                          color: cc,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
                      onPressed: () => _attemptSave(context),
                      child: Text(
                        l10n.chestPainActionSaveDetail,
                        style: TextStyle(
                          color: ic,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom chip rendering label + info-icon. The whole chip is tappable
/// to toggle selection, the info icon area is its own gesture so taps
/// on it open the definition dialog without flipping the selection.
/// Self-contained per symptom, matching pelvic pain/presyncope/headache/
/// abdominal's convention — not shared from structural_chip.dart.
class _ChestPainChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color cc;
  final Color ic;
  final VoidCallback onToggle;
  final VoidCallback onInfo;

  const _ChestPainChip({
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
              // Inner gesture for info icon. Wrapping in Material+InkWell
              // creates a separate gesture arena, so taps here do NOT
              // bubble up to the outer InkWell.
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
