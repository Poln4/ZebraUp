// D.4 — Pelvic pain detail sheet
//
// Bottom sheet that captures structured detail for a pelvic_pain log.
// Renders the 5 groups from symptom_definitions.json with chips —
// single-view layout (no wizard), mirroring presyncope_detail_sheet.dart's
// mixed single/multi-select pattern.
//
// The sheet does NOT run red-flag detection — that's the caller's
// responsibility after the sheet returns (see pelvic_pain_red_flags.dart
// and sintomas_tab.dart). The sheet only intercepts the "sudden severe
// onset" character chip with an emergency-confirmation dialog — but,
// unlike presyncope's tap-time interception, this follows abdominal's
// save-time pattern: the dialog fires when the user attempts to save
// with that chip selected, not the instant they tap it, so a patient
// can read the chip's definition via the info icon without being
// interrupted.
//
// Returns null on:
//   - User taps "Skip" (saltar)
//   - User taps "Save" but marked no chips at all
// Returns the PelvicPainDetail otherwise.

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/pelvic_pain_detail.dart';
import '../services/symptom_definitions_service.dart';
import 'symptom_definition_dialog.dart';

Future<PelvicPainDetail?> showPelvicPainDetailSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  PelvicPainDetail? existing,
}) async {
  await SymptomDefinitionsService.instance.ensureLoaded();
  if (!context.mounted) return null;

  return showModalBottomSheet<PelvicPainDetail?>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (ctx) => _PelvicPainDetailSheetBody(
      cc: contrastColor,
      ic: inverseContrastColor,
      existing: existing,
    ),
  );
}

class _PelvicPainDetailSheetBody extends StatefulWidget {
  final Color cc;
  final Color ic;
  final PelvicPainDetail? existing;
  const _PelvicPainDetailSheetBody({
    required this.cc,
    required this.ic,
    this.existing,
  });

  @override
  State<_PelvicPainDetailSheetBody> createState() =>
      _PelvicPainDetailSheetBodyState();
}

class _PelvicPainDetailSheetBodyState
    extends State<_PelvicPainDetailSheetBody> {
  PelvicPainLocation? _location;
  PelvicPainCharacter? _character;
  PelvicPainTiming? _timing;
  late Set<PelvicPainTrigger> _triggers;
  late Set<PelvicPainAccompaniment> _accompaniments;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _location = e?.location;
    _character = e?.character;
    _timing = e?.timing;
    _triggers = e?.triggers.toSet() ?? <PelvicPainTrigger>{};
    _accompaniments = e?.accompaniments.toSet() ?? <PelvicPainAccompaniment>{};
  }

  PelvicPainDetail _buildDetail() => PelvicPainDetail(
    location: _location,
    character: _character,
    timing: _timing,
    triggers: _triggers,
    accompaniments: _accompaniments,
  );

  bool _isChipSelected(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'location':
        final v = PelvicPainLocation.fromKey(chipKey);
        return v != null && _location == v;
      case 'character':
        final v = PelvicPainCharacter.fromKey(chipKey);
        return v != null && _character == v;
      case 'timing':
        final v = PelvicPainTiming.fromKey(chipKey);
        return v != null && _timing == v;
      case 'triggers':
        final v = PelvicPainTrigger.fromKey(chipKey);
        return v != null && _triggers.contains(v);
      case 'accompaniments':
        final v = PelvicPainAccompaniment.fromKey(chipKey);
        return v != null && _accompaniments.contains(v);
    }
    return false;
  }

  void _handleChipTap(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'location':
        final v = PelvicPainLocation.fromKey(chipKey);
        if (v == null) return;
        setState(() => _location = _location == v ? null : v);
        break;
      case 'character':
        final v = PelvicPainCharacter.fromKey(chipKey);
        if (v == null) return;
        setState(() => _character = _character == v ? null : v);
        break;
      case 'timing':
        final v = PelvicPainTiming.fromKey(chipKey);
        if (v == null) return;
        setState(() => _timing = _timing == v ? null : v);
        break;
      case 'triggers':
        final v = PelvicPainTrigger.fromKey(chipKey);
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
        final v = PelvicPainAccompaniment.fromKey(chipKey);
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

  /// D.4: if character = suddenSevereOnset, show emergency dialog
  /// IN-SHEET before committing the save. Two branches: user changes
  /// character (stays in sheet) or acknowledges emergency (saves
  /// as-is). Fires on save attempt (not on chip selection), mirroring
  /// abdominal_detail_sheet.dart's tearing-quality pattern.
  Future<void> _attemptSave(BuildContext ctx) async {
    if (_character == PelvicPainCharacter.suddenSevereOnset) {
      final proceed = await _showSuddenOnsetEmergencyDialog(ctx);
      if (!proceed) return; // User chose to change character — stay in sheet.
    }
    if (!mounted) return;
    final detail = _buildDetail();
    Navigator.pop(context, detail.isEmpty ? null : detail);
  }

  Future<bool> _showSuddenOnsetEmergencyDialog(BuildContext ctx) async {
    final l10n = AppLocalizations.of(ctx)!;
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
                l10n.pelvicPainSuddenOnsetEmergencyTitle,
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
            l10n.pelvicPainSuddenOnsetEmergencyBody,
            style: TextStyle(color: widget.cc, fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            style: TextButton.styleFrom(foregroundColor: widget.cc),
            child: Text(l10n.pelvicPainSuddenOnsetEmergencyChangeCharacter),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: widget.cc),
            child: Text(
              l10n.pelvicPainSuddenOnsetEmergencySaveAsIs,
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
                      l10n.pelvicPainSheetTitle,
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
                      symptomKey: 'pelvic_pain',
                      contrastColor: cc,
                      inverseContrastColor: ic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.pelvicPainSheetSubtitle,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // 5 groups in JSON insertion order
              ...svc.getGroupKeysInOrder('pelvic_pain').map((groupKey) {
                final header =
                    svc.getGroupHeader('pelvic_pain', groupKey, locale) ??
                    groupKey;
                final chipKeys = svc.getChipKeysInOrder(
                  'pelvic_pain',
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
                                'pelvic_pain',
                                groupKey,
                                chipKey,
                                locale,
                              ) ??
                              chipKey;
                          final isSelected = _isChipSelected(
                            groupKey,
                            chipKey,
                          );
                          return _PelvicPainChip(
                            label: chipLabel,
                            selected: isSelected,
                            cc: cc,
                            ic: ic,
                            onToggle: () => _handleChipTap(groupKey, chipKey),
                            onInfo: () => showSymptomDefinitionDialog(
                              context: context,
                              symptomKey: 'pelvic_pain',
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
                        l10n.pelvicPainActionSaveDetail,
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
/// Self-contained per symptom, matching presyncope/headache/abdominal's
/// convention — not imported from structural_chip.dart, which is
/// shared only within structural's own two sheets.
class _PelvicPainChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color cc;
  final Color ic;
  final VoidCallback onToggle;
  final VoidCallback onInfo;

  const _PelvicPainChip({
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
