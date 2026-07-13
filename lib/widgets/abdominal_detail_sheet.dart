// D.2 — Abdominal detail bottom sheet
//
// Reusable modal sheet for capturing structured detail on an
// abdominal_pain log. Applies progressive disclosure semántico based
// on which alias variant triggered the sheet:
//   - 'pain'     : no pre-selections (full sheet)
//   - 'bloating' : bloating chip pre-marked in accompaniments
//   - 'gas'      : excessive_gas chip pre-marked in accompaniments
//   - null       : no pre-selections (defensive default)
//
// All 5 groups always visible — respects user autonomy to log
// combinations (bloating with cramps, gas with tender abdomen, etc.).
//
// In-sheet emergency dialog fires on save attempt when quality =
// tearing (SEDv-adjacent pattern). Two branches:
//   - "Cambiar calidad y guardar" — returns to sheet, user can revise
//   - "Guardar como está (emergencia)" — commits save as URGENT
//
// Fires on save attempt (not on chip selection) so the user can
// explore quality options without being warned repeatedly.

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/abdominal_detail.dart';
import '../services/symptom_definitions_service.dart';

/// Show the abdominal detail sheet and await the user's choice.
///
/// [symptomInput] is the exact string from the vault that triggered
/// this sheet — used for alias-variant detection to apply progressive
/// disclosure semántico.
Future<AbdominalDetail?> showAbdominalDetailSheet(
  BuildContext context, {
  required String symptomInput,
  required Color contrastColor,
  required Color inverseContrastColor,
  AbdominalDetail? existing,
}) {
  return showModalBottomSheet<AbdominalDetail?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: inverseContrastColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _AbdominalDetailSheetContent(
      symptomInput: symptomInput,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      existing: existing,
    ),
  );
}

class _AbdominalDetailSheetContent extends StatefulWidget {
  final String symptomInput;
  final Color contrastColor;
  final Color inverseContrastColor;
  final AbdominalDetail? existing;

  const _AbdominalDetailSheetContent({
    required this.symptomInput,
    required this.contrastColor,
    required this.inverseContrastColor,
    this.existing,
  });

  @override
  State<_AbdominalDetailSheetContent> createState() =>
      _AbdominalDetailSheetContentState();
}

class _AbdominalDetailSheetContentState
    extends State<_AbdominalDetailSheetContent> {
  AbdominalLocation? _location;
  AbdominalQuality? _quality;
  AbdominalTiming? _timing;
  late Set<AbdominalAccompaniment> _accompaniments;
  late Set<AbdominalTrigger> _triggers;

  @override
  void initState() {
    super.initState();
    _location = widget.existing?.location;
    _quality = widget.existing?.quality;
    _timing = widget.existing?.timing;
    _accompaniments = Set<AbdominalAccompaniment>.from(
      widget.existing?.accompaniments ?? const {},
    );
    _triggers = Set<AbdominalTrigger>.from(
      widget.existing?.triggers ?? const {},
    );

    // D.2: Progressive disclosure semántico.
    // Only apply variant pre-selection when NOT editing existing detail
    // — in edit mode, the user's stored selections take precedence.
    if (widget.existing == null) {
      final variant = SymptomDefinitionsService.instance.detectAliasVariant(
        widget.symptomInput,
        'abdominal_pain',
      );
      switch (variant) {
        case 'bloating':
          _accompaniments.add(AbdominalAccompaniment.bloating);
          break;
        case 'gas':
          _accompaniments.add(AbdominalAccompaniment.excessiveGas);
          break;
      }
    }
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
              _handleBar(),
              _titleRow(ctx, l10n, locale),
              Divider(color: widget.contrastColor.withOpacity(0.15)),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildGroup(
                      ctx,
                      locale,
                      groupKey: 'location',
                      single: true,
                    ),
                    _buildGroup(ctx, locale, groupKey: 'quality', single: true),
                    _buildGroup(ctx, locale, groupKey: 'timing', single: true),
                    _buildGroup(
                      ctx,
                      locale,
                      groupKey: 'accompaniments',
                      single: false,
                    ),
                    _buildGroup(
                      ctx,
                      locale,
                      groupKey: 'trigger',
                      single: false,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              _actionBar(ctx, l10n),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Layout helpers
  // ---------------------------------------------------------------------

  Widget _handleBar() => Container(
    margin: const EdgeInsets.only(top: 8),
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: widget.contrastColor.withOpacity(0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _titleRow(BuildContext ctx, AppLocalizations l10n, String locale) =>
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
                    l10n.abdominalSheetTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: widget.contrastColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.abdominalSheetSubtitle,
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
              tooltip: l10n.abdominalSheetTitle,
              onPressed: () => _showMasterDefinition(ctx, locale),
            ),
          ],
        ),
      );

  Widget _actionBar(BuildContext ctx, AppLocalizations l10n) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
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
              onPressed: _canSave() ? () => _attemptSave(ctx) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: widget.contrastColor,
                foregroundColor: widget.inverseContrastColor,
                disabledBackgroundColor: widget.contrastColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.abdominalActionSaveDetail),
            ),
          ),
        ],
      ),
    ),
  );

  // ---------------------------------------------------------------------
  // Selection state
  // ---------------------------------------------------------------------

  bool _canSave() {
    return _location != null ||
        _quality != null ||
        _timing != null ||
        _accompaniments.isNotEmpty ||
        _triggers.isNotEmpty;
  }

  Future<void> _attemptSave(BuildContext ctx) async {
    // D.2: If quality = tearing, show emergency dialog IN-SHEET before
    // committing the save. Two branches: user changes quality (returns
    // to sheet) or acknowledges emergency (saves as-is).
    if (_quality == AbdominalQuality.tearing) {
      final proceed = await _showTearingEmergencyDialog(ctx);
      if (!proceed) return; // User chose to change quality — stay in sheet.
    }
    if (!mounted) return;
    Navigator.of(context).pop(
      AbdominalDetail(
        location: _location,
        quality: _quality,
        timing: _timing,
        accompaniments: _accompaniments,
        triggers: _triggers,
      ),
    );
  }

  /// Returns true when the user acknowledged the emergency and chose
  /// to save as-is. Returns false when the user chose to change the
  /// quality (stay in sheet, sheet regains focus).
  Future<bool> _showTearingEmergencyDialog(BuildContext ctx) async {
    final l10n = AppLocalizations.of(ctx)!;
    final result = await showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (dctx) => AlertDialog(
        backgroundColor: widget.inverseContrastColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: widget.contrastColor, width: 2),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: widget.contrastColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.abdominalTearingEmergencyTitle,
                style: TextStyle(
                  color: widget.contrastColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            l10n.abdominalTearingEmergencyBody,
            style: TextStyle(
              color: widget.contrastColor,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            style: TextButton.styleFrom(foregroundColor: widget.contrastColor),
            child: Text(l10n.abdominalTearingEmergencyChangeQuality),
          ),
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: widget.contrastColor),
            child: Text(
              l10n.abdominalTearingEmergencySaveAsIs,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  bool _isSelected(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'location':
        return _location?.serializationKey == chipKey;
      case 'quality':
        return _quality?.serializationKey == chipKey;
      case 'timing':
        return _timing?.serializationKey == chipKey;
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
        case 'location':
          _location = selected ? AbdominalLocation.fromKey(chipKey) : null;
          break;
        case 'quality':
          _quality = selected ? AbdominalQuality.fromKey(chipKey) : null;
          break;
        case 'timing':
          _timing = selected ? AbdominalTiming.fromKey(chipKey) : null;
          break;
        case 'accompaniments':
          final val = AbdominalAccompaniment.fromKey(chipKey);
          if (val == null) break;
          if (selected) {
            _accompaniments.add(val);
          } else {
            _accompaniments.remove(val);
          }
          break;
        case 'trigger':
          final val = AbdominalTrigger.fromKey(chipKey);
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
    required bool single,
  }) {
    final svc = SymptomDefinitionsService.instance;
    final header =
        svc.getGroupHeader('abdominal_pain', groupKey, locale) ?? groupKey;
    final chipKeys = svc.getChipKeysInOrder('abdominal_pain', groupKey);

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
                .map(
                  (chipKey) => _buildChip(
                    ctx,
                    locale,
                    groupKey: groupKey,
                    chipKey: chipKey,
                  ),
                )
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
  }) {
    final svc = SymptomDefinitionsService.instance;
    final label =
        svc.getChipLabel('abdominal_pain', groupKey, chipKey, locale) ??
        chipKey;
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
      labelStyle: TextStyle(color: widget.contrastColor, fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  // ---------------------------------------------------------------------
  // Definition dialogs
  // ---------------------------------------------------------------------

  void _showMasterDefinition(BuildContext ctx, String locale) {
    final svc = SymptomDefinitionsService.instance;
    final label =
        svc.getMasterLabel('abdominal_pain', locale) ?? 'Dolor abdominal';
    final definition = svc.getMasterDefinition('abdominal_pain', locale) ?? '';
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
        svc.getChipLabel('abdominal_pain', groupKey, chipKey, locale) ??
        chipKey;
    final definition =
        svc.getChipDefinition('abdominal_pain', groupKey, chipKey, locale) ??
        '';
    _showDefinitionDialog(ctx, label, definition);
  }

  void _showDefinitionDialog(
    BuildContext ctx,
    String title,
    String definition,
  ) {
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
