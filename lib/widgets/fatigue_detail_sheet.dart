// D.1 — Fatigue detail bottom sheet
//
// Reusable modal sheet for capturing structured detail on a fatigue log.
// Called from sintomas_tab immediately after the user selects "fatiga"
// (or an alias) and confirms severity. Returns FatigueDetail? — null
// when the user taps "Saltar" or dismisses. Non-null when the user
// taps "Guardar detalle" (may still be "empty" if no chips were
// selected; caller handles that via FatigueDetail.isEmpty).
//
// UI mirrors headache_detail_sheet.dart:
//   - Handle bar + title + subtitle + info icon (opens master definition)
//   - 4 group sections, each with header + info icon + chip Wrap
//   - InputChips: selected state via .selected; info icon lives in the
//     deleteIcon slot so it renders whether the chip is selected or not
//   - Bottom actions: outlined "Saltar" + filled "Guardar detalle"
//
// Unlike cefalea, no thunderclap-equivalent emergency dialog is
// intercepted mid-sheet. All fatigue red flags are ADVISORY and
// surfaced post-save by sintomas_tab (D.1.D.1).

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/fatigue_detail.dart';
import '../services/symptom_definitions_service.dart';

/// Show the fatigue detail sheet and await the user's choice.
///
/// [contrastColor] / [inverseContrastColor] are passed in by the caller
/// so the sheet obeys the app's B&W theme (light: black on white;
/// dark: white on black).
///
/// [existing] pre-populates the sheet in edit mode.
Future<FatigueDetail?> showFatigueDetailSheet(
  BuildContext context, {
  required Color contrastColor,
  required Color inverseContrastColor,
  FatigueDetail? existing,
}) {
  return showModalBottomSheet<FatigueDetail?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: inverseContrastColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _FatigueDetailSheetContent(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      existing: existing,
    ),
  );
}

class _FatigueDetailSheetContent extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final FatigueDetail? existing;

  const _FatigueDetailSheetContent({
    required this.contrastColor,
    required this.inverseContrastColor,
    this.existing,
  });

  @override
  State<_FatigueDetailSheetContent> createState() =>
      _FatigueDetailSheetContentState();
}

class _FatigueDetailSheetContentState
    extends State<_FatigueDetailSheetContent> {
  FatigueType? _type;
  FatigueTemporalPattern? _temporalPattern;
  late Set<FatigueAccompaniment> _accompaniments;
  late Set<FatigueTrigger> _triggers;

  @override
  void initState() {
    super.initState();
    _type = widget.existing?.type;
    _temporalPattern = widget.existing?.temporalPattern;
    _accompaniments =
        Set<FatigueAccompaniment>.from(widget.existing?.accompaniments ?? {});
    _triggers = Set<FatigueTrigger>.from(widget.existing?.triggers ?? {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Handle bar.
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.contrastColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title row.
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.fatigueSheetTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: widget.contrastColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.fatigueSheetSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.contrastColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: widget.contrastColor.withOpacity(0.6),
                        size: 20,
                      ),
                      tooltip: l10n.fatigueSheetTitle,
                      onPressed: () => _showMasterDefinition(ctx, locale),
                    ),
                  ],
                ),
              ),
              Divider(color: widget.contrastColor.withOpacity(0.15)),
              // Groups.
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildGroup(
                      ctx,
                      locale,
                      groupKey: 'type',
                      isSingleSelect: true,
                    ),
                    _buildGroup(
                      ctx,
                      locale,
                      groupKey: 'temporal_pattern',
                      isSingleSelect: true,
                    ),
                    _buildGroup(
                      ctx,
                      locale,
                      groupKey: 'accompaniments',
                      isSingleSelect: false,
                    ),
                    _buildGroup(
                      ctx,
                      locale,
                      groupKey: 'trigger',
                      isSingleSelect: false,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // Bottom actions.
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(null),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: widget.contrastColor),
                            foregroundColor: widget.contrastColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(l10n.actionSkip),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _canSave() ? _save : null,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: widget.contrastColor,
                            foregroundColor: widget.inverseContrastColor,
                            disabledBackgroundColor:
                                widget.contrastColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(l10n.fatigueActionSaveDetail),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Selection state
  // ---------------------------------------------------------------------

  bool _canSave() {
    return _type != null ||
        _temporalPattern != null ||
        _accompaniments.isNotEmpty ||
        _triggers.isNotEmpty;
  }

  void _save() {
    Navigator.of(context).pop(
      FatigueDetail(
        type: _type,
        temporalPattern: _temporalPattern,
        accompaniments: _accompaniments,
        triggers: _triggers,
      ),
    );
  }

  bool _isSelected(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'type':
        return _type?.serializationKey == chipKey;
      case 'temporal_pattern':
        return _temporalPattern?.serializationKey == chipKey;
      case 'accompaniments':
        return _accompaniments.any((a) => a.serializationKey == chipKey);
      case 'trigger':
        return _triggers.any((t) => t.serializationKey == chipKey);
    }
    return false;
  }

  void _toggleSelection(String groupKey, String chipKey, bool selected) {
    setState(() {
      switch (groupKey) {
        case 'type':
          if (selected) {
            _type = FatigueType.fromKey(chipKey);
          } else {
            _type = null;
          }
          break;
        case 'temporal_pattern':
          if (selected) {
            _temporalPattern = FatigueTemporalPattern.fromKey(chipKey);
          } else {
            _temporalPattern = null;
          }
          break;
        case 'accompaniments':
          final val = FatigueAccompaniment.fromKey(chipKey);
          if (val == null) break;
          if (selected) {
            _accompaniments.add(val);
          } else {
            _accompaniments.remove(val);
          }
          break;
        case 'trigger':
          final val = FatigueTrigger.fromKey(chipKey);
          if (val == null) break;
          if (selected) {
            _triggers.add(val);
          } else {
            _triggers.remove(val);
          }
          break;
      }
    });
  }

  // ---------------------------------------------------------------------
  // Widget builders
  // ---------------------------------------------------------------------

  Widget _buildGroup(
    BuildContext ctx,
    String locale, {
    required String groupKey,
    required bool isSingleSelect,
  }) {
    final svc = SymptomDefinitionsService.instance;
    final header = svc.getGroupHeader('fatigue', groupKey, locale) ?? groupKey;
    final chipKeys = svc.getChipKeysInOrder('fatigue', groupKey);

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  header,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: widget.contrastColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showMasterDefinition(ctx, locale),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.info_outline,
                    color: widget.contrastColor.withOpacity(0.5),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chipKeys
                .map((chipKey) => _buildChip(
                      ctx,
                      locale,
                      groupKey: groupKey,
                      chipKey: chipKey,
                      isSingleSelect: isSingleSelect,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext ctx,
    String locale, {
    required String groupKey,
    required String chipKey,
    required bool isSingleSelect,
  }) {
    final svc = SymptomDefinitionsService.instance;
    final label =
        svc.getChipLabel('fatigue', groupKey, chipKey, locale) ?? chipKey;
    final selected = _isSelected(groupKey, chipKey);

    return InputChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (v) => _toggleSelection(groupKey, chipKey, v),
      deleteIcon: Icon(
        Icons.info_outline,
        size: 14,
        color: widget.contrastColor.withOpacity(0.55),
      ),
      onDeleted: () => _showChipDefinition(ctx, groupKey, chipKey, locale),
      backgroundColor: widget.inverseContrastColor,
      selectedColor: widget.contrastColor.withOpacity(0.15),
      side: BorderSide(
        color: widget.contrastColor.withOpacity(selected ? 0.6 : 0.25),
      ),
      labelStyle: TextStyle(
        color: widget.contrastColor,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  // ---------------------------------------------------------------------
  // Definition dialogs
  // ---------------------------------------------------------------------

  void _showMasterDefinition(BuildContext ctx, String locale) {
    final svc = SymptomDefinitionsService.instance;
    final label = svc.getMasterLabel('fatigue', locale) ?? 'Fatiga';
    final definition = svc.getMasterDefinition('fatigue', locale) ?? '';
    _showDefinitionDialog(ctx, label, definition);
  }

  void _showChipDefinition(
    BuildContext ctx,
    String groupKey,
    String chipKey,
    String locale,
  ) {
    final svc = SymptomDefinitionsService.instance;
    final label =
        svc.getChipLabel('fatigue', groupKey, chipKey, locale) ?? chipKey;
    final definition =
        svc.getChipDefinition('fatigue', groupKey, chipKey, locale) ?? '';
    _showDefinitionDialog(ctx, label, definition);
  }

  void _showDefinitionDialog(
      BuildContext ctx, String title, String definition) {
    showDialog<void>(
      context: ctx,
      builder: (dctx) {
        final l10n = AppLocalizations.of(dctx)!;
        return AlertDialog(
          backgroundColor: widget.inverseContrastColor,
          title: Text(
            title,
            style: TextStyle(color: widget.contrastColor, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Text(
              definition.trim().isEmpty ? '—' : definition,
              style: TextStyle(
                color: widget.contrastColor.withOpacity(0.85),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: widget.contrastColor,
              ),
              child: Text(l10n.actionUnderstood),
            ),
          ],
        );
      },
    );
  }
}
