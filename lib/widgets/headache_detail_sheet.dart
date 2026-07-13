// C.4 — Headache detail sheet
//
// Bottom sheet that captures structured detail for a cefalea log.
// Renders the 5 groups from symptom_definitions.json with chips.
//
// The sheet does NOT run red-flag detection — that's the caller's
// responsibility after the sheet returns. The sheet only intercepts
// the thunderclap onset chip with an emergency-confirmation dialog
// because the patient may be in the middle of a medical emergency
// while logging.
//
// Returns null on:
//   - User taps "Skip" (saltar)
//   - User taps "Save" but marked no chips at all
// Returns the HeadacheDetail otherwise.

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/headache_detail.dart';
import '../services/symptom_definitions_service.dart';
import 'symptom_definition_dialog.dart';

Future<HeadacheDetail?> showHeadacheDetailSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  HeadacheDetail? existing,
}) async {
  await SymptomDefinitionsService.instance.ensureLoaded();
  if (!context.mounted) return null;

  return showModalBottomSheet<HeadacheDetail?>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (ctx) => _HeadacheDetailSheetBody(
      cc: contrastColor,
      ic: inverseContrastColor,
      existing: existing,
    ),
  );
}

class _HeadacheDetailSheetBody extends StatefulWidget {
  final Color cc;
  final Color ic;
  final HeadacheDetail? existing;
  const _HeadacheDetailSheetBody({
    required this.cc,
    required this.ic,
    this.existing,
  });

  @override
  State<_HeadacheDetailSheetBody> createState() =>
      _HeadacheDetailSheetBodyState();
}

class _HeadacheDetailSheetBodyState extends State<_HeadacheDetailSheetBody> {
  late Set<HeadacheLocation> _locations;
  HeadacheQuality? _quality;
  late Set<HeadacheAccompaniment> _accompaniments;
  HeadachePosturalPattern? _posturalPattern;
  HeadacheOnset? _onset;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _locations = e?.locations.toSet() ?? <HeadacheLocation>{};
    _quality = e?.quality;
    _accompaniments = e?.accompaniments.toSet() ?? <HeadacheAccompaniment>{};
    _posturalPattern = e?.posturalPattern;
    _onset = e?.onset;
  }

  HeadacheDetail _buildDetail() => HeadacheDetail(
    locations: _locations,
    quality: _quality,
    accompaniments: _accompaniments,
    posturalPattern: _posturalPattern,
    onset: _onset,
  );

  bool _isChipSelected(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'location':
        final v = HeadacheLocation.fromKey(chipKey);
        return v != null && _locations.contains(v);
      case 'quality':
        final v = HeadacheQuality.fromKey(chipKey);
        return v != null && _quality == v;
      case 'accompaniments':
        final v = HeadacheAccompaniment.fromKey(chipKey);
        return v != null && _accompaniments.contains(v);
      case 'postural_pattern':
        final v = HeadachePosturalPattern.fromKey(chipKey);
        return v != null && _posturalPattern == v;
      case 'onset':
        final v = HeadacheOnset.fromKey(chipKey);
        return v != null && _onset == v;
    }
    return false;
  }

  Future<void> _handleChipTap(
    BuildContext ctx,
    String groupKey,
    String chipKey,
  ) async {
    switch (groupKey) {
      case 'location':
        final v = HeadacheLocation.fromKey(chipKey);
        if (v == null) return;
        setState(() {
          if (_locations.contains(v)) {
            _locations.remove(v);
          } else {
            _locations.add(v);
          }
        });
        break;
      case 'quality':
        final v = HeadacheQuality.fromKey(chipKey);
        if (v == null) return;
        setState(() => _quality = _quality == v ? null : v);
        break;
      case 'accompaniments':
        final v = HeadacheAccompaniment.fromKey(chipKey);
        if (v == null) return;
        setState(() {
          if (_accompaniments.contains(v)) {
            _accompaniments.remove(v);
          } else {
            _accompaniments.add(v);
          }
        });
        break;
      case 'postural_pattern':
        final v = HeadachePosturalPattern.fromKey(chipKey);
        if (v == null) return;
        setState(() => _posturalPattern = _posturalPattern == v ? null : v);
        break;
      case 'onset':
        await _handleOnsetTap(ctx);
        break;
    }
  }

  /// Special handling for the thunderclap chip. Tapping while it's
  /// already selected just deselects. Tapping to select shows the
  /// emergency warning dialog first.
  Future<void> _handleOnsetTap(BuildContext ctx) async {
    if (_onset == HeadacheOnset.thunderclap) {
      setState(() => _onset = null);
      return;
    }

    final l10n = AppLocalizations.of(ctx)!;
    final locale = l10n.localeName;
    final defBody =
        SymptomDefinitionsService.instance.getChipDefinition(
          'headache',
          'onset',
          'thunderclap',
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
                l10n.headacheThunderclapWarningTitle,
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
              l10n.headacheThunderclapWarningConfirm,
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
      setState(() => _onset = HeadacheOnset.thunderclap);
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
                      l10n.headacheSheetTitle,
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
                      symptomKey: 'headache',
                      contrastColor: cc,
                      inverseContrastColor: ic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.headacheSheetSubtitle,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // 5 groups in JSON insertion order
              ...svc.getGroupKeysInOrder('headache').map((groupKey) {
                final header =
                    svc.getGroupHeader('headache', groupKey, locale) ??
                    groupKey;
                final chipKeys = svc.getChipKeysInOrder('headache', groupKey);
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
                                'headache',
                                groupKey,
                                chipKey,
                                locale,
                              ) ??
                              chipKey;
                          final isSelected = _isChipSelected(groupKey, chipKey);
                          return _HeadacheChip(
                            label: chipLabel,
                            selected: isSelected,
                            cc: cc,
                            ic: ic,
                            onToggle: () =>
                                _handleChipTap(context, groupKey, chipKey),
                            onInfo: () => showSymptomDefinitionDialog(
                              context: context,
                              symptomKey: 'headache',
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
                        l10n.headacheActionSaveDetail,
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
class _HeadacheChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color cc;
  final Color ic;
  final VoidCallback onToggle;
  final VoidCallback onInfo;

  const _HeadacheChip({
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
