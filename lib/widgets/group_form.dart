// =============================================================================
// GroupFormSheet — bottom sheet for creating / editing a MedicationGroup.
//
// One sheet, two modes:
//   • Create: `existing` is null. Pop returns a fresh MedicationGroup.
//   • Edit:   `existing` is the current group. Pop returns an updated copy
//             with the SAME id. Delete option appears as a tertiary action.
//
// Pop conventions:
//   • Cancel       → pop with null
//   • Save         → pop with the new/updated MedicationGroup
//   • Delete (edit only) → pop with the constant `kGroupDeleted` sentinel,
//     which the caller checks via identity equality and treats as a deletion.
//
// Field set:
//   • name              — required (e.g. "Meds de la noche")
//   • defaultTimeMinutes— optional toggle + time picker
//   • entries           — checklist of meds from profile.botiquin, each with
//                         a quantity stepper visible only when checked
// =============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';
import 'dose_stepper.dart';

/// Sentinel returned from the sheet when the user taps "Eliminar grupo" in
/// edit mode. Use identity equality (`result == kGroupDeleted`) to detect.
final MedicationGroup kGroupDeleted = MedicationGroup(
  id: '__sentinel_deleted__',
  name: '',
);

/// Entry point. Shows the modal sheet and resolves to:
///   • a MedicationGroup (create or update)
///   • `kGroupDeleted` (delete from edit mode)
///   • null (user cancelled)
Future<MedicationGroup?> showGroupFormSheet(
  BuildContext context, {
  required Profile profile,
  required Color contrastColor,
  required Color inverseContrastColor,
  MedicationGroup? existing,
}) {
  return showModalBottomSheet<MedicationGroup>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => GroupFormSheet(
      profile: profile,
      existing: existing,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
    ),
  );
}

class GroupFormSheet extends StatefulWidget {
  final Profile profile;
  final MedicationGroup? existing;
  final Color contrastColor;
  final Color inverseContrastColor;

  const GroupFormSheet({
    super.key,
    required this.profile,
    this.existing,
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  @override
  State<GroupFormSheet> createState() => _GroupFormSheetState();
}

class _GroupFormSheetState extends State<GroupFormSheet> {
  late final TextEditingController _nameCtrl;
  bool _useDefaultTime = false;
  TimeOfDay _defaultTime = const TimeOfDay(hour: 22, minute: 0);

  /// Per-med-id quantity. Presence in map = checked. Absence = unchecked.
  final Map<String, double> _checkedQuantities = {};

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    if (e?.defaultTimeMinutes != null) {
      _useDefaultTime = true;
      final m = e!.defaultTimeMinutes!;
      _defaultTime = TimeOfDay(hour: m ~/ 60, minute: m % 60);
    }
    // Pre-check entries that already belong to this group.
    if (e != null) {
      for (final entry in e.entries) {
        _checkedQuantities[entry.medicationId] = entry.quantity;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameCtrl.text.trim().isNotEmpty && _checkedQuantities.isNotEmpty;

  void _save() {
    final entries = _checkedQuantities.entries
        .map((e) => MedicationGroupEntry(
              medicationId: e.key,
              quantity: e.value,
            ))
        .toList();

    final group = MedicationGroup(
      id: widget.existing?.id, // preserve id on edit
      name: _nameCtrl.text.trim(),
      defaultTimeMinutes:
          _useDefaultTime ? _defaultTime.hour * 60 + _defaultTime.minute : null,
      entries: entries,
    );
    Navigator.of(context).pop(group);
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.inverseContrastColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('¿Eliminar este grupo?',
            style: TextStyle(color: widget.contrastColor)),
        content: Text(
          'El grupo se elimina, pero los medicamentos siguen en tu botiquín.',
          style: TextStyle(
              color: widget.contrastColor.withValues(alpha: 0.8),
              height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar',
                style: TextStyle(
                    color:
                        widget.contrastColor.withValues(alpha: 0.7))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Eliminar',
                style: TextStyle(
                    color: const Color(0xFFE57373),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      Navigator.of(context).pop(kGroupDeleted);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _defaultTime,
    );
    if (picked != null) setState(() => _defaultTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final meds = widget.profile.botiquin;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Editar grupo' : 'Nuevo grupo',
                          style: TextStyle(
                            color: cc.withValues(alpha: 0.6),
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditing
                              ? widget.existing!.name
                              : 'Medicamentos juntos',
                          style: TextStyle(
                            color: cc,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: cc),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name
              _fieldLabel('Nombre', cc, required: true),
              TextField(
                controller: _nameCtrl,
                style: TextStyle(color: cc),
                decoration: _inputDeco(
                    'p. ej. Meds de la noche, Vitaminas mañana', cc),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Default time
              _fieldLabel('Hora por defecto', cc),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: cc.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cc.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Switch(
                      value: _useDefaultTime,
                      onChanged: (v) =>
                          setState(() => _useDefaultTime = v),
                      activeColor: cc,
                    ),
                    if (_useDefaultTime) ...[
                      const SizedBox(width: 4),
                      Text(
                        'Recordatorio a las',
                        style: TextStyle(
                          color: cc.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _pickTime,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: const Size(0, 32),
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _defaultTime.format(context),
                          style: TextStyle(
                            color: cc,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ] else
                      Text(
                        'Sin hora fija',
                        style: TextStyle(
                          color: cc.withValues(alpha: 0.55),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Med checklist
              _fieldLabel(
                  'Medicamentos${_checkedQuantities.isEmpty ? "" : " · ${_checkedQuantities.length} seleccionados"}',
                  cc,
                  required: true),
              if (meds.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cc.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Aún no tienes medicamentos en tu botiquín. '
                    'Crea uno primero y vuelve a este formulario.',
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.65),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                )
              else
                Column(
                  children: meds.map((m) => _MedCheckRow(
                        med: m,
                        contrastColor: cc,
                        checkedQuantity: _checkedQuantities[m.id],
                        onToggle: (checked) {
                          setState(() {
                            if (checked) {
                              _checkedQuantities[m.id] =
                                  m.defaultQuantity == 0
                                      ? 1.0
                                      : m.defaultQuantity;
                            } else {
                              _checkedQuantities.remove(m.id);
                            }
                          });
                        },
                        onQuantityChanged: (q) {
                          setState(() => _checkedQuantities[m.id] = q);
                        },
                      )).toList(),
                ),
              const SizedBox(height: 24),

              // Save
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cc,
                    foregroundColor: widget.inverseContrastColor,
                    disabledBackgroundColor: cc.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isEditing ? 'Guardar cambios' : 'Crear grupo',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),

              // Delete (edit mode only)
              if (_isEditing) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _confirmDelete,
                    icon: Icon(Icons.delete_outline,
                        size: 16, color: const Color(0xFFE57373)),
                    label: const Text(
                      'Eliminar grupo',
                      style: TextStyle(
                        color: Color(0xFFE57373),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, Color cc, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: cc.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          if (required)
            Text(' *',
                style: TextStyle(
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint, Color cc) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: cc.withValues(alpha: 0.2)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: cc.withValues(alpha: 0.35), fontSize: 13),
      filled: true,
      fillColor: cc.withValues(alpha: 0.04),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cc, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    );
  }
}

// =============================================================================
// _MedCheckRow — single med row in the checklist with collapsible stepper.
// =============================================================================

class _MedCheckRow extends StatelessWidget {
  final MedicationDef med;
  final Color contrastColor;
  final double? checkedQuantity;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onQuantityChanged;

  const _MedCheckRow({
    required this.med,
    required this.contrastColor,
    required this.checkedQuantity,
    required this.onToggle,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final checked = checkedQuantity != null;
    final subtitle = med.notes?.isNotEmpty == true
        ? '${med.displayDose} · ${med.notes}'
        : med.displayDose;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: checked
            ? cc.withValues(alpha: 0.08)
            : cc.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cc.withValues(alpha: checked ? 0.35 : 0.12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: checked,
                onChanged: (v) => onToggle(v ?? false),
                activeColor: cc,
                checkColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: TextStyle(
                        color: cc,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (checked) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(
                children: [
                  Text(
                    'Cantidad',
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  DoseQuantityStepper(
                    value: checkedQuantity!,
                    onChanged: onQuantityChanged,
                    formLabel: med.form,
                    contrastColor: cc,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}