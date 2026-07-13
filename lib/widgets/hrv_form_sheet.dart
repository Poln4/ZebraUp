// =============================================================================
// HrvFormSheet — log or edit an HrvReading.
//
// Phase F6.b + HRV module (17-jun-2026). Modal bottom sheet matching the
// FeverFormSheet stepper-with-direct-edit pattern. Fields: timestamp →
// RMSSD stepper (10–150ms, step 1, tap-to-edit) → context chips →
// source chips (manual, Apple Watch, Welltory, other) → note → save.
//
// HrvContextLocalization + HrvSourceLocalization extensions live in this
// file (single consumer). Source is a free-form string in the model
// (`HrvReading.source`) to future-proof for arbitrary wearables; the
// extension handles the 4 known values and falls back to the raw string.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../screens/timestamp_picker.dart';
import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
// i18n extensions
// -----------------------------------------------------------------------------

extension HrvContextLocalization on HrvContext {
  String label(AppLocalizations l10n) => switch (this) {
    HrvContext.morning => l10n.hrvContextMorning,
    HrvContext.afternoon => l10n.hrvContextAfternoon,
    HrvContext.evening => l10n.hrvContextEvening,
    HrvContext.postExercise => l10n.hrvContextPostExercise,
    HrvContext.other => l10n.hrvContextOther,
  };
}

/// Known HRV source IDs. Stored as free-form strings on HrvReading.source
/// to allow future wearable integrations without schema changes.
const List<String> kHrvSources = ['manual', 'apple_watch', 'welltory', 'other'];

extension HrvSourceLocalization on String {
  String hrvSourceLabel(AppLocalizations l10n) => switch (this) {
    'manual' => l10n.hrvSourceManual,
    'apple_watch' => l10n.hrvSourceAppleWatch,
    'welltory' => l10n.hrvSourceWelltory,
    'other' => l10n.hrvSourceOther,
    _ => this,
  };
}

// -----------------------------------------------------------------------------
// Public API
// -----------------------------------------------------------------------------

Future<HrvReading?> showHrvFormSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required DateTime defaultTimestamp,
  HrvReading? existing,
}) {
  return showModalBottomSheet<HrvReading>(
    context: context,
    backgroundColor: inverseContrastColor,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    isScrollControlled: true,
    builder: (ctx) => _HrvForm(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      defaultTimestamp: defaultTimestamp,
      existing: existing,
    ),
  );
}

// -----------------------------------------------------------------------------
// Form widget
// -----------------------------------------------------------------------------

class _HrvForm extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final DateTime defaultTimestamp;
  final HrvReading? existing;

  const _HrvForm({
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.defaultTimestamp,
    this.existing,
  });

  @override
  State<_HrvForm> createState() => _HrvFormState();
}

class _HrvFormState extends State<_HrvForm> {
  // Conservative clamps for RMSSD. Pathologically low or absurdly high
  // values are most likely typos; clamping silently is friendlier than
  // rejecting input.
  static const double _minRmssd = 5.0;
  static const double _maxRmssd = 200.0;
  static const double _stepRmssd = 1.0;
  static const double _defaultRmssd = 30.0;

  late DateTime _timestamp;
  late double _rmssd;
  late HrvContext _context;
  late String _source;
  late TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _timestamp = e?.timestamp ?? widget.defaultTimestamp;
    _rmssd = e?.rmssdMs ?? _defaultRmssd;
    _context = e?.context ?? HrvContext.morning;
    _source = e?.source ?? 'manual';
    _noteCtrl = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;

  void _adjust(double delta) {
    setState(() {
      final raw = _rmssd + delta;
      _rmssd = raw.clamp(_minRmssd, _maxRmssd);
    });
  }

  Future<void> _editDirectly() async {
    final l10n = context.l10n;
    final ctrl = TextEditingController(text: _rmssd.round().toString());
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.hrvDirectEditDialogTitle),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: l10n.hrvDirectEditDialogHint,
            suffixText: 'ms',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () {
              final parsed = double.tryParse(ctrl.text.trim());
              if (parsed != null) Navigator.pop(ctx, parsed);
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => _rmssd = result.clamp(_minRmssd, _maxRmssd));
    }
  }

  void _save() {
    final note = _noteCtrl.text.trim();
    final result = HrvReading(
      id: widget.existing?.id,
      timestamp: _timestamp,
      rmssdMs: _rmssd,
      context: _context,
      source: _source,
      note: note.isEmpty ? null : note,
    );
    Navigator.pop(context, result);
  }

  Widget _chip({
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
          label,
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
    final title = widget.existing != null
        ? l10n.hrvModalEditHeader
        : l10n.hrvModalLogHeader;

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

            // RMSSD stepper
            Text(
              l10n.hrvFieldRmssdLabel,
              style: TextStyle(
                color: _cc.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _adjust(-_stepRmssd),
                        icon: const Icon(Icons.remove_circle_outline, size: 36),
                        color: _cc,
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: _editDirectly,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Text(
                            '${_rmssd.round()} ms',
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
                        onPressed: () => _adjust(_stepRmssd),
                        icon: const Icon(Icons.add_circle_outline, size: 36),
                        color: _cc,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.hrvHintTapToEdit,
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

            // Context
            Text(
              l10n.hrvFieldContextLabel,
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
              children: HrvContext.values
                  .map(
                    (c) => _chip(
                      selected: _context == c,
                      label: c.label(l10n),
                      onTap: () => setState(() => _context = c),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Source
            Text(
              l10n.hrvFieldSourceLabel,
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
              children: kHrvSources
                  .map(
                    (s) => _chip(
                      selected: _source == s,
                      label: s.hrvSourceLabel(l10n),
                      onTap: () => setState(() => _source = s),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Note
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
