// D.3 — Presyncope detail sheet
//
// Bottom sheet that captures structured detail for a presyncope log.
// Renders the 4 groups from symptom_definitions.json with chips —
// single-view layout (no wizard), mirroring headache_detail_sheet.dart's
// mixed single/multi-select pattern.
//
// The sheet does NOT run red-flag detection — that's the caller's
// responsibility after the sheet returns (see presyncope_red_flags.dart
// and sintomas_tab.dart). The sheet only intercepts the "brief loss of
// consciousness" outcome chip with an emergency-confirmation dialog,
// mirroring headache's thunderclap-onset interception, because losing
// consciousness (even briefly) warrants a distinct pause before saving.
//
// Returns null on:
//   - User taps "Skip" (saltar)
//   - User taps "Save" but marked no chips at all
// Returns the PresyncopeDetail otherwise.

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/presyncope_detail.dart';
import '../services/symptom_definitions_service.dart';
import 'symptom_definition_dialog.dart';

Future<PresyncopeDetail?> showPresyncopeDetailSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  PresyncopeDetail? existing,
}) async {
  await SymptomDefinitionsService.instance.ensureLoaded();
  if (!context.mounted) return null;

  return showModalBottomSheet<PresyncopeDetail?>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (ctx) => _PresyncopeDetailSheetBody(
      cc: contrastColor,
      ic: inverseContrastColor,
      existing: existing,
    ),
  );
}

class _PresyncopeDetailSheetBody extends StatefulWidget {
  final Color cc;
  final Color ic;
  final PresyncopeDetail? existing;
  const _PresyncopeDetailSheetBody({
    required this.cc,
    required this.ic,
    this.existing,
  });

  @override
  State<_PresyncopeDetailSheetBody> createState() =>
      _PresyncopeDetailSheetBodyState();
}

class _PresyncopeDetailSheetBodyState
    extends State<_PresyncopeDetailSheetBody> {
  PresyncopeMechanism? _mechanism;
  late Set<PresyncopeProdromeSymptom> _prodrome;
  PresyncopeOutcome? _outcome;
  PresyncopeRecovery? _recovery;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _mechanism = e?.mechanism;
    _prodrome = e?.prodrome.toSet() ?? <PresyncopeProdromeSymptom>{};
    _outcome = e?.outcome;
    _recovery = e?.recovery;
  }

  PresyncopeDetail _buildDetail() => PresyncopeDetail(
    mechanism: _mechanism,
    prodrome: _prodrome,
    outcome: _outcome,
    recovery: _recovery,
  );

  bool _isChipSelected(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'mechanism':
        final v = PresyncopeMechanism.fromKey(chipKey);
        return v != null && _mechanism == v;
      case 'prodrome':
        final v = PresyncopeProdromeSymptom.fromKey(chipKey);
        return v != null && _prodrome.contains(v);
      case 'outcome':
        final v = PresyncopeOutcome.fromKey(chipKey);
        return v != null && _outcome == v;
      case 'recovery':
        final v = PresyncopeRecovery.fromKey(chipKey);
        return v != null && _recovery == v;
    }
    return false;
  }

  Future<void> _handleChipTap(
    BuildContext ctx,
    String groupKey,
    String chipKey,
  ) async {
    switch (groupKey) {
      case 'mechanism':
        final v = PresyncopeMechanism.fromKey(chipKey);
        if (v == null) return;
        setState(() => _mechanism = _mechanism == v ? null : v);
        break;
      case 'prodrome':
        final v = PresyncopeProdromeSymptom.fromKey(chipKey);
        if (v == null) return;
        setState(() {
          if (_prodrome.contains(v)) {
            _prodrome.remove(v);
          } else {
            _prodrome.add(v);
          }
        });
        break;
      case 'outcome':
        await _handleOutcomeTap(ctx, chipKey);
        break;
      case 'recovery':
        final v = PresyncopeRecovery.fromKey(chipKey);
        if (v == null) return;
        setState(() => _recovery = _recovery == v ? null : v);
        break;
    }
  }

  /// Special handling for the "brief loss of consciousness" chip.
  /// Tapping while it's already selected just deselects. Tapping to
  /// select shows a confirmation dialog first, mirroring headache's
  /// thunderclap-onset interception.
  Future<void> _handleOutcomeTap(BuildContext ctx, String chipKey) async {
    final v = PresyncopeOutcome.fromKey(chipKey);
    if (v == null) return;

    if (v != PresyncopeOutcome.briefLossOfConsciousness) {
      setState(() => _outcome = _outcome == v ? null : v);
      return;
    }

    if (_outcome == PresyncopeOutcome.briefLossOfConsciousness) {
      setState(() => _outcome = null);
      return;
    }

    final l10n = AppLocalizations.of(ctx)!;
    final locale = l10n.localeName;
    final defBody =
        SymptomDefinitionsService.instance.getChipDefinition(
          'presyncope',
          'outcome',
          'brief_loc',
          locale,
        ) ??
        '';

    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: widget.ic,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.red, width: 2),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.presyncopeLossOfConsciousnessDialogTitle,
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
            defBody,
            style: TextStyle(color: widget.cc, fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              l10n.actionCancel,
              style: TextStyle(color: widget.cc.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              l10n.presyncopeLossOfConsciousnessDialogConfirm,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _outcome = PresyncopeOutcome.briefLossOfConsciousness);
    }
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
                      l10n.presyncopeSheetTitle,
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
                      symptomKey: 'presyncope',
                      contrastColor: cc,
                      inverseContrastColor: ic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.presyncopeSheetSubtitle,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // 4 groups in JSON insertion order
              ...svc.getGroupKeysInOrder('presyncope').map((groupKey) {
                final header =
                    svc.getGroupHeader('presyncope', groupKey, locale) ??
                    groupKey;
                final chipKeys = svc.getChipKeysInOrder(
                  'presyncope',
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
                                'presyncope',
                                groupKey,
                                chipKey,
                                locale,
                              ) ??
                              chipKey;
                          final isSelected = _isChipSelected(groupKey, chipKey);
                          return _PresyncopeChip(
                            label: chipLabel,
                            selected: isSelected,
                            cc: cc,
                            ic: ic,
                            onToggle: () =>
                                _handleChipTap(context, groupKey, chipKey),
                            onInfo: () => showSymptomDefinitionDialog(
                              context: context,
                              symptomKey: 'presyncope',
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
                      onPressed: () {
                        final detail = _buildDetail();
                        // Empty detail = treat as skip.
                        Navigator.pop(context, detail.isEmpty ? null : detail);
                      },
                      child: Text(
                        l10n.presyncopeActionSaveDetail,
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
/// Self-contained per symptom, matching headache/abdominal's
/// convention — not imported from structural_chip.dart, which is
/// shared only within structural's own two sheets.
class _PresyncopeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color cc;
  final Color ic;
  final VoidCallback onToggle;
  final VoidCallback onInfo;

  const _PresyncopeChip({
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
