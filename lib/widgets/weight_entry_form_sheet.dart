// Weight entry form sheet — see docs/design_decisions/
// weight_height_tracking.md. Pattern calcado de
// structural_zone_history_form_sheet.dart: a plain returning bottom sheet,
// no wiring back into a callback.
//
// Deliberately no BMI display or computation here, no trend/history chart
// entry point, and `reason` is required — a weight number without clinical
// context is the exact pattern the design doc's research grounding flags
// as both misleading (EDS/MCAS weight change is physiological, not
// behavioral) and risky (elevated disordered-eating comorbidity in this
// population).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';

/// Returns the new/updated entry, or null if cancelled.
Future<WeightEntry?> showWeightEntryFormSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  WeightEntry? existing,
}) {
  return showModalBottomSheet<WeightEntry>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (_) => _WeightEntryFormBody(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      existing: existing,
    ),
  );
}

String _reasonLabel(WeightChangeReason reason, AppLocalizations l10n) {
  switch (reason) {
    case WeightChangeReason.giFlare:
      return l10n.weightEntryReasonGiFlare;
    case WeightChangeReason.medicationChange:
      return l10n.weightEntryReasonMedicationChange;
    case WeightChangeReason.fluidRetention:
      return l10n.weightEntryReasonFluidRetention;
    case WeightChangeReason.appetiteChange:
      return l10n.weightEntryReasonAppetiteChange;
    case WeightChangeReason.other:
      return l10n.weightEntryReasonOther;
  }
}

class _WeightEntryFormBody extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final WeightEntry? existing;

  const _WeightEntryFormBody({
    required this.contrastColor,
    required this.inverseContrastColor,
    this.existing,
  });

  @override
  State<_WeightEntryFormBody> createState() => _WeightEntryFormBodyState();
}

class _WeightEntryFormBodyState extends State<_WeightEntryFormBody> {
  late TextEditingController _weightCtrl;
  late TextEditingController _noteCtrl;
  late WeightChangeReason _reason;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _weightCtrl = TextEditingController(
      text: e == null ? '' : _formatWeight(e.weightKg),
    );
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _reason = e?.reason ?? WeightChangeReason.other;
    _date = e?.timestamp ?? DateTime.now();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatWeight(double kg) {
    if (kg == kg.roundToDouble()) return kg.toInt().toString();
    return kg.toString();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final weight = double.tryParse(_weightCtrl.text.trim().replaceAll(',', '.'));
    if (weight == null || weight <= 0) return;
    final note = _noteCtrl.text.trim();
    final result = WeightEntry(
      id: widget.existing?.id,
      timestamp: _date,
      weightKg: weight,
      reason: _reason,
      note: note.isEmpty ? null : note,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? l10n.weightEntryFormEditTitle : l10n.weightEntryFormTitle,
                style: TextStyle(
                  color: cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                l10n.weightEntryWeightLabel,
                style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _weightCtrl,
                autofocus: !isEdit,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(color: cc, fontSize: 16),
              ),
              const SizedBox(height: 16),

              Text(
                l10n.weightEntryReasonLabel,
                style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: cc)),
                child: DropdownButton<WeightChangeReason>(
                  value: _reason,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  dropdownColor: ic,
                  style: TextStyle(color: cc, fontSize: 13),
                  iconEnabledColor: cc,
                  items: WeightChangeReason.values.map((r) {
                    return DropdownMenuItem<WeightChangeReason>(
                      value: r,
                      child: Text(_reasonLabel(r, l10n)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _reason = v);
                  },
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                style: TextStyle(color: cc),
                decoration: InputDecoration(
                  hintText: l10n.weightEntryNoteHint,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cc.withValues(alpha: 0.5)),
                ),
                icon: Icon(Icons.calendar_today, color: cc, size: 14),
                label: Text(
                  DateFormat('d MMM yyyy').format(_date),
                  style: TextStyle(color: cc, fontSize: 12),
                ),
                onPressed: _pickDate,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cc,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _save,
                child: Text(
                  l10n.weightEntrySaveAction,
                  style: TextStyle(color: ic, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.actionCancel,
                    style: TextStyle(color: cc.withValues(alpha: 0.6)),
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
