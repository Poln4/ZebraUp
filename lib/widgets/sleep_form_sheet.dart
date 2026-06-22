// =============================================================================
// SleepFormSheet — log or edit a SleepEntry.
//
// Phase F6.a + Sleep module (16-jun-2026). Modal bottom sheet matching the
// FeverFormSheet style. Fields: timestamp picker → quality picker (4 chips)
// → optional duration (hours) → optional onset latency (minutes) → optional
// wake count → optional nightmare toggle → optional note → save.
//
// Convention (from SleepEntry docstring): `dateKey` is the YYYY-MM-DD of
// the *waking* day. An entry logged Monday morning carries Monday's dateKey
// and refers to Sunday-night → Monday-morning sleep. The form derives
// dateKey from the chosen timestamp's calendar date.
//
// SleepQualityLocalization extension lives in this file (single consumer
// for now). When the module gets a Hoy chip or report integration, refactor
// out to lib/services/sleep_localization.dart.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../screens/timestamp_picker.dart';
import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
// SleepQuality i18n extension (canonical FeverSiteLocalization pattern)
// -----------------------------------------------------------------------------

extension SleepQualityLocalization on SleepQuality {
  String label(AppLocalizations l10n) => switch (this) {
        SleepQuality.bad => l10n.sleepQualityBad,
        SleepQuality.regular => l10n.sleepQualityRegular,
        SleepQuality.good => l10n.sleepQualityGood,
        SleepQuality.veryGood => l10n.sleepQualityVeryGood,
      };
}

// -----------------------------------------------------------------------------
// Public API
// -----------------------------------------------------------------------------

/// Opens the sleep form sheet. Returns the new/edited SleepEntry, or
/// null if dismissed. `defaultTimestamp` is the suggested wake time
/// (typically morning of the calendar day being logged).
Future<SleepEntry?> showSleepFormSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required DateTime defaultTimestamp,
  SleepEntry? existing,
}) {
  return showModalBottomSheet<SleepEntry>(
    context: context,
    backgroundColor: inverseContrastColor,
    shape: RoundedRectangleBorder(
        side: BorderSide(color: contrastColor, width: 2)),
    isScrollControlled: true,
    builder: (ctx) => _SleepForm(
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

class _SleepForm extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final DateTime defaultTimestamp;
  final SleepEntry? existing;

  const _SleepForm({
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.defaultTimestamp,
    this.existing,
  });

  @override
  State<_SleepForm> createState() => _SleepFormState();
}

class _SleepFormState extends State<_SleepForm> {
  late DateTime _timestamp;
  late SleepQuality _quality;
  late TextEditingController _durationCtrl; // hours, decimal
  late TextEditingController _onsetCtrl; // minutes
  late int? _wakeCount;
  late bool _nightmare;
  late TextEditingController _noteCtrl;

  static const int _maxWakeCount = 20;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _timestamp = e?.timestamp ?? widget.defaultTimestamp;
    _quality = e?.quality ?? SleepQuality.regular;
    _durationCtrl = TextEditingController(
      text: e?.durationMinutes != null
          ? (e!.durationMinutes! / 60).toStringAsFixed(1)
          : '',
    );
    _onsetCtrl = TextEditingController(
      text: e?.onsetLatencyMinutes?.toString() ?? '',
    );
    _wakeCount = e?.wakeCount;
    _nightmare = e?.nightmare ?? false;
    _noteCtrl = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    _onsetCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;

  /// dateKey for this entry = the calendar date of the timestamp.
  /// Convention: timestamp = wake time, so calendar date = waking day.
  String get _dateKey =>
      "${_timestamp.year}-"
      "${_timestamp.month.toString().padLeft(2, '0')}-"
      "${_timestamp.day.toString().padLeft(2, '0')}";

  int? _parseDurationMinutes() {
    final raw = _durationCtrl.text.replaceAll(',', '.').trim();
    if (raw.isEmpty) return null;
    final hours = double.tryParse(raw);
    if (hours == null || hours <= 0 || hours > 24) return null;
    return (hours * 60).round();
  }

  int? _parseOnsetMinutes() {
    final raw = _onsetCtrl.text.trim();
    if (raw.isEmpty) return null;
    final mins = int.tryParse(raw);
    if (mins == null || mins < 0 || mins > 600) return null;
    return mins;
  }

  void _save() {
    final note = _noteCtrl.text.trim();
    final result = SleepEntry(
      id: widget.existing?.id,
      timestamp: _timestamp,
      dateKey: _dateKey,
      quality: _quality,
      durationMinutes: _parseDurationMinutes(),
      onsetLatencyMinutes: _parseOnsetMinutes(),
      wakeCount: _wakeCount,
      nightmare: _nightmare ? true : null,
      note: note.isEmpty ? null : note,
    );
    Navigator.pop(context, result);
  }

  Widget _qualityChip(SleepQuality q, AppLocalizations l10n) {
    final selected = _quality == q;
    return InkWell(
      onTap: () => setState(() => _quality = q),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _cc : Colors.transparent,
          border: Border.all(
              color: _cc.withValues(alpha: selected ? 1.0 : 0.4)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          q.label(l10n),
          style: TextStyle(
            color: selected ? _ic : _cc.withValues(alpha: 0.8),
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _wakeCountStepper(AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          onPressed: _wakeCount == null
              ? null
              : () => setState(() {
                    final next = (_wakeCount ?? 0) - 1;
                    _wakeCount = next < 0 ? null : next;
                  }),
          icon: const Icon(Icons.remove_circle_outline, size: 24),
          color: _cc,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            _wakeCount?.toString() ?? '–',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _cc,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: (_wakeCount ?? -1) >= _maxWakeCount
              ? null
              : () => setState(() {
                    _wakeCount = (_wakeCount ?? 0) + 1;
                  }),
          icon: const Icon(Icons.add_circle_outline, size: 24),
          color: _cc,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.existing != null;
    final title =
        isEdit ? l10n.sleepModalEditHeader : l10n.sleepModalLogHeader;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            const SizedBox(height: 20),

            // Quality (required)
            Text(
              l10n.sleepFieldQualityLabel,
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
              children: SleepQuality.values
                  .map((q) => _qualityChip(q, l10n))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Duration (optional)
            Text(
              l10n.sleepFieldDurationLabel,
              style: TextStyle(
                color: _cc.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _durationCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              style: TextStyle(color: _cc),
              decoration: InputDecoration(
                hintText: l10n.sleepFieldDurationHint,
                hintStyle: const TextStyle(color: Colors.grey),
                suffixText: 'h',
              ),
            ),
            const SizedBox(height: 16),

            // Onset latency (optional)
            Text(
              l10n.sleepFieldOnsetLatencyLabel,
              style: TextStyle(
                color: _cc.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _onsetCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: _cc),
              decoration: InputDecoration(
                hintText: l10n.sleepFieldOnsetLatencyHint,
                hintStyle: const TextStyle(color: Colors.grey),
                suffixText: 'min',
              ),
            ),
            const SizedBox(height: 16),

            // Wake count (optional)
            Text(
              l10n.sleepFieldWakeCountLabel,
              style: TextStyle(
                color: _cc.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            _wakeCountStepper(l10n),
            const SizedBox(height: 16),

            // Nightmare toggle
            InkWell(
              onTap: () => setState(() => _nightmare = !_nightmare),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _nightmare ? _cc : Colors.transparent,
                  border: Border.all(
                      color:
                          _cc.withValues(alpha: _nightmare ? 1.0 : 0.4)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _nightmare
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: _nightmare
                          ? _ic
                          : _cc.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.sleepFieldNightmareToggle,
                      style: TextStyle(
                        color: _nightmare
                            ? _ic
                            : _cc.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: _nightmare
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Optional note
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
                style:
                    TextStyle(color: _ic, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}