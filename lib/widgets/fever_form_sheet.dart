// =============================================================================
// FeverFormSheet — log or edit a FeverReading.
//
// Modal bottom sheet matching the existing structural / bowel modal style
// in sintomas_tab.dart. Layout: timestamp -> temperature stepper (with
// tap-to-edit-directly) -> site picker (5 chips) -> antipyretic toggle
// (+ optional name field) -> note -> save.
//
// All user-facing strings are localized via context.l10n. The
// FeverSiteLocalization extension is exposed publicly so the calling tab
// can render the same labels without duplicating the switch.
//
// Clinical motivation: temperatures are quantitative and matter for
// clinical decisions in EDS + autoimmune + dysautonomia patients. The
// stepper is set to 0.1°C steps (medical thermometer precision); the
// direct-edit dialog handles cases where the user needs a quick reset
// (e.g. logging a reading that's far from the default 37.0°C).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../screens/timestamp_picker.dart';
import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';
import '../services/fever_analysis.dart';

// Re-export FeverSiteLocalization so existing callers that import this
// file (e.g. sintomas_tab.dart) continue to see the extension. The
// authoritative definition now lives in services/fever_analysis.dart.
export '../services/fever_analysis.dart' show FeverSiteLocalization;

/// Opens the fever form sheet. Returns the new/edited FeverReading, or
/// null if the user dismissed the sheet.
Future<FeverReading?> showFeverFormSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required DateTime defaultTimestamp,
  FeverReading? existing,
}) {
  return showModalBottomSheet<FeverReading>(
    context: context,
    backgroundColor: inverseContrastColor,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    isScrollControlled: true,
    builder: (ctx) => _FeverForm(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      defaultTimestamp: defaultTimestamp,
      existing: existing,
    ),
  );
}

class _FeverForm extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final DateTime defaultTimestamp;
  final FeverReading? existing;

  const _FeverForm({
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.defaultTimestamp,
    this.existing,
  });

  @override
  State<_FeverForm> createState() => _FeverFormState();
}

class _FeverFormState extends State<_FeverForm> {
  // Bounds clamp absurd inputs (e.g. user pastes Fahrenheit by mistake)
  // without showing an error — feels less harsh than rejecting input.
  static const double _minTemp = 30.0;
  static const double _maxTemp = 45.0;
  static const double _stepTemp = 0.1;
  static const double _defaultTemp = 37.0;

  late DateTime _timestamp;
  late double _temperatureC;
  late FeverSite _site;
  late bool _antipyreticTaken;
  late TextEditingController _antipyreticNameCtrl;
  late TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _timestamp = e?.timestamp ?? widget.defaultTimestamp;
    _temperatureC = e?.temperatureC ?? _defaultTemp;
    _site = e?.site ?? FeverSite.axillary;
    _antipyreticTaken = e?.antipyreticTaken ?? false;
    _antipyreticNameCtrl = TextEditingController(
      text: e?.antipyreticName ?? '',
    );
    _noteCtrl = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _antipyreticNameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;

  /// Apply a delta (positive or negative). Rounds to 1 decimal to avoid
  /// floating-point drift across many small steps.
  void _adjustTemp(double delta) {
    setState(() {
      final raw = _temperatureC + delta;
      final rounded = (raw * 10).round() / 10;
      _temperatureC = rounded.clamp(_minTemp, _maxTemp);
    });
  }

  Future<void> _editTempDirectly() async {
    final l10n = context.l10n;
    final ctrl = TextEditingController(text: _temperatureC.toStringAsFixed(1));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.feverDirectEditDialogTitle),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            // Accept digits + . and , (LatAm decimal separator). We
            // normalize comma to period before parsing.
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: InputDecoration(
            hintText: l10n.feverDirectEditDialogHint,
            suffixText: '°C',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () {
              final raw = ctrl.text.replaceAll(',', '.').trim();
              final parsed = double.tryParse(raw);
              if (parsed != null) Navigator.pop(ctx, parsed);
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        final rounded = (result * 10).round() / 10;
        _temperatureC = rounded.clamp(_minTemp, _maxTemp);
      });
    }
  }

  void _save() {
    final note = _noteCtrl.text.trim();
    final apName = _antipyreticNameCtrl.text.trim();
    final result = FeverReading(
      id: widget.existing?.id,
      timestamp: _timestamp,
      temperatureC: _temperatureC,
      site: _site,
      antipyreticTaken: _antipyreticTaken,
      antipyreticName: (_antipyreticTaken && apName.isNotEmpty) ? apName : null,
      note: note.isEmpty ? null : note,
    );
    Navigator.pop(context, result);
  }

  Widget _siteChip(FeverSite site, AppLocalizations l10n) {
    final selected = _site == site;
    return InkWell(
      onTap: () => setState(() => _site = site),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _cc : Colors.transparent,
          border: Border.all(
            color: _cc.withValues(alpha: selected ? 1.0 : 0.4),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          site.label(l10n),
          style: TextStyle(
            color: selected ? _ic : _cc.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.existing != null;
    final title = isEdit ? l10n.feverModalEditHeader : l10n.feverModalLogHeader;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: _cc,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _cc.withValues(alpha: 0.5)),
              ),
              icon: Icon(Icons.access_time, color: _cc, size: 16),
              label: Text(
                DateFormat('EEE d MMM, HH:mm').format(_timestamp),
                style: TextStyle(color: _cc, fontSize: 12),
              ),
              onPressed: () async {
                final picked = await pickTimestamp(
                  context: context,
                  initial: _timestamp,
                  contrastColor: _cc,
                  inverseContrastColor: _ic,
                );
                if (picked != null) setState(() => _timestamp = picked);
              },
            ),
            const SizedBox(height: 24),
            // Temperature stepper
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _adjustTemp(-_stepTemp),
                        icon: const Icon(Icons.remove_circle_outline, size: 36),
                        color: _cc,
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: _editTempDirectly,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Text(
                            '${_temperatureC.toStringAsFixed(1)}°C',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _cc,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => _adjustTemp(_stepTemp),
                        icon: const Icon(Icons.add_circle_outline, size: 36),
                        color: _cc,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.feverHintTapToEdit,
                    style: TextStyle(
                      color: _cc.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Site picker
            Text(
              l10n.feverFieldSiteLabel,
              style: TextStyle(
                color: _cc.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FeverSite.values
                  .map((s) => _siteChip(s, l10n))
                  .toList(),
            ),
            const SizedBox(height: 20),
            // Antipyretic
            Text(
              l10n.feverFieldAntipyreticLabel,
              style: TextStyle(
                color: _cc.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () =>
                  setState(() => _antipyreticTaken = !_antipyreticTaken),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _antipyreticTaken ? _cc : Colors.transparent,
                  border: Border.all(
                    color: _cc.withValues(alpha: _antipyreticTaken ? 1.0 : 0.4),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _antipyreticTaken
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: _antipyreticTaken
                          ? _ic
                          : _cc.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.feverFieldAntipyreticToggle,
                      style: TextStyle(
                        color: _antipyreticTaken
                            ? _ic
                            : _cc.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: _antipyreticTaken
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_antipyreticTaken) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _antipyreticNameCtrl,
                style: TextStyle(color: _cc),
                decoration: InputDecoration(
                  hintText: l10n.feverFieldAntipyreticNameHint,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              style: TextStyle(color: _cc),
              decoration: InputDecoration(
                hintText: l10n.symptomsLabelOptionalNoteSimple,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _cc,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _save,
              child: Text(
                l10n.symptomsActionSave,
                style: TextStyle(color: _ic, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
