// =============================================================================
// BloodPressureFormSheet — log or edit a BloodPressureReading.
//
// Panel de Signos Vitales §5.1 (docs/design_decisions/vital_signs_panel.md).
// Modal bottom sheet matching the HrvFormSheet stepper-with-direct-edit
// pattern. Fields: timestamp → systolic/diastolic steppers (tap-to-edit) →
// optional heart rate stepper → position chips → note → save.
//
// Deliberately no interpretation shown here (no "this looks high/low", no
// comparison against a prior reading) — a single loose reading has no
// baseline to interpret against. That logic belongs to OrthostaticTest
// (deferred — see design doc §7 for the pending standing-test safety
// design), which pairs a baseline reading with standing readings.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../screens/timestamp_picker.dart';
import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';

extension BloodPressurePositionLocalization on BloodPressurePosition {
  String label(AppLocalizations l10n) => switch (this) {
    BloodPressurePosition.sitting => l10n.bloodPressurePositionSitting,
    BloodPressurePosition.lying => l10n.bloodPressurePositionLying,
    BloodPressurePosition.standing => l10n.bloodPressurePositionStanding,
  };
}

// -----------------------------------------------------------------------------
// Public API
// -----------------------------------------------------------------------------

Future<BloodPressureReading?> showBloodPressureFormSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required DateTime defaultTimestamp,
  BloodPressureReading? existing,
}) {
  return showModalBottomSheet<BloodPressureReading>(
    context: context,
    backgroundColor: inverseContrastColor,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    isScrollControlled: true,
    builder: (ctx) => _BloodPressureForm(
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

class _BloodPressureForm extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final DateTime defaultTimestamp;
  final BloodPressureReading? existing;

  const _BloodPressureForm({
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.defaultTimestamp,
    this.existing,
  });

  @override
  State<_BloodPressureForm> createState() => _BloodPressureFormState();
}

class _BloodPressureFormState extends State<_BloodPressureForm> {
  // Conservative clamps. Values outside these are most likely typos;
  // clamping silently is friendlier than rejecting input.
  static const int _minSystolic = 60;
  static const int _maxSystolic = 220;
  static const int _minDiastolic = 30;
  static const int _maxDiastolic = 140;
  static const int _minHeartRate = 30;
  static const int _maxHeartRate = 200;
  static const int _defaultSystolic = 110;
  static const int _defaultDiastolic = 70;

  late DateTime _timestamp;
  late int _systolic;
  late int _diastolic;
  int? _heartRate;
  late BloodPressurePosition _position;
  late TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _timestamp = e?.timestamp ?? widget.defaultTimestamp;
    _systolic = e?.systolic ?? _defaultSystolic;
    _diastolic = e?.diastolic ?? _defaultDiastolic;
    _heartRate = e?.heartRate;
    _position = e?.position ?? BloodPressurePosition.sitting;
    _noteCtrl = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;

  Future<void> _editDirectly({
    required String title,
    required String hint,
    required int current,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) async {
    final l10n = context.l10n;
    final ctrl = TextEditingController(text: current.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () {
              final parsed = int.tryParse(ctrl.text.trim());
              if (parsed != null) Navigator.pop(ctx, parsed);
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    if (result != null) {
      onChanged(result.clamp(min, max));
    }
  }

  void _save() {
    final note = _noteCtrl.text.trim();
    final result = BloodPressureReading(
      id: widget.existing?.id,
      timestamp: _timestamp,
      systolic: _systolic,
      diastolic: _diastolic,
      heartRate: _heartRate,
      position: _position,
      note: note.isEmpty ? null : note,
    );
    Navigator.pop(context, result);
  }

  Widget _stepperRow({
    required String label,
    required int value,
    required int min,
    required int max,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required VoidCallback onTapValue,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: _cc.withValues(alpha: 0.7),
            fontSize: 11,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_circle_outline, size: 28),
              color: _cc,
            ),
            InkWell(
              onTap: onTapValue,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _cc,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add_circle_outline, size: 28),
              color: _cc,
            ),
          ],
        ),
      ],
    );
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
        ? l10n.bloodPressureModalEditHeader
        : l10n.bloodPressureModalLogHeader;

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
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stepperRow(
                  label: l10n.bloodPressureFieldSystolicLabel,
                  value: _systolic,
                  min: _minSystolic,
                  max: _maxSystolic,
                  onDecrement: () => setState(
                    () => _systolic = (_systolic - 1).clamp(
                      _minSystolic,
                      _maxSystolic,
                    ),
                  ),
                  onIncrement: () => setState(
                    () => _systolic = (_systolic + 1).clamp(
                      _minSystolic,
                      _maxSystolic,
                    ),
                  ),
                  onTapValue: () => _editDirectly(
                    title: l10n.bloodPressureFieldSystolicLabel,
                    hint: l10n.bloodPressureFieldSystolicLabel,
                    current: _systolic,
                    min: _minSystolic,
                    max: _maxSystolic,
                    onChanged: (v) => setState(() => _systolic = v),
                  ),
                ),
                Text(
                  '/',
                  style: TextStyle(
                    color: _cc.withValues(alpha: 0.5),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _stepperRow(
                  label: l10n.bloodPressureFieldDiastolicLabel,
                  value: _diastolic,
                  min: _minDiastolic,
                  max: _maxDiastolic,
                  onDecrement: () => setState(
                    () => _diastolic = (_diastolic - 1).clamp(
                      _minDiastolic,
                      _maxDiastolic,
                    ),
                  ),
                  onIncrement: () => setState(
                    () => _diastolic = (_diastolic + 1).clamp(
                      _minDiastolic,
                      _maxDiastolic,
                    ),
                  ),
                  onTapValue: () => _editDirectly(
                    title: l10n.bloodPressureFieldDiastolicLabel,
                    hint: l10n.bloodPressureFieldDiastolicLabel,
                    current: _diastolic,
                    min: _minDiastolic,
                    max: _maxDiastolic,
                    onChanged: (v) => setState(() => _diastolic = v),
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                'mmHg',
                style: TextStyle(
                  color: _cc.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Heart rate (optional)
            Text(
              l10n.bloodPressureFieldHeartRateLabel,
              style: TextStyle(
                color: _cc.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: _heartRate == null
                  ? OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _cc.withValues(alpha: 0.4)),
                      ),
                      icon: Icon(Icons.add, color: _cc, size: 14),
                      label: Text(
                        l10n.bloodPressureFieldHeartRateLabel,
                        style: TextStyle(color: _cc, fontSize: 12),
                      ),
                      onPressed: () => setState(() => _heartRate = 70),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => setState(
                            () => _heartRate = (_heartRate! - 1).clamp(
                              _minHeartRate,
                              _maxHeartRate,
                            ),
                          ),
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            size: 24,
                          ),
                          color: _cc,
                        ),
                        InkWell(
                          onTap: () => _editDirectly(
                            title: l10n.bloodPressureFieldHeartRateLabel,
                            hint: l10n.bloodPressureHeartRateUnit,
                            current: _heartRate!,
                            min: _minHeartRate,
                            max: _maxHeartRate,
                            onChanged: (v) => setState(() => _heartRate = v),
                          ),
                          child: Text(
                            '${_heartRate!} ${l10n.bloodPressureHeartRateUnit}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _cc,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(
                            () => _heartRate = (_heartRate! + 1).clamp(
                              _minHeartRate,
                              _maxHeartRate,
                            ),
                          ),
                          icon: const Icon(Icons.add_circle_outline, size: 24),
                          color: _cc,
                        ),
                        IconButton(
                          onPressed: () => setState(() => _heartRate = null),
                          icon: Icon(
                            Icons.close,
                            color: _cc.withValues(alpha: 0.5),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // Position
            Text(
              l10n.bloodPressureFieldPositionLabel,
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
              children: BloodPressurePosition.values
                  .map(
                    (p) => _chip(
                      selected: _position == p,
                      label: p.label(l10n),
                      onTap: () => setState(() => _position = p),
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
