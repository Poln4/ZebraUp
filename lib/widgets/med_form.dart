// =============================================================================
// MedFormSheet — bottom sheet for creating or editing a MedicationDef.
//
// One sheet, two modes:
//   • Create: `existing` is null. Pop returns a fresh MedicationDef.
//   • Edit:   `existing` is the current med. Pop returns an updated copy
//             with the SAME id (so MedicationGroup entries keep working).
//
// Cancel = pop with null.
//
// Field set (all phase-1 schema):
//   • name            — required
//   • form            — dropdown (pastilla, cápsula, gota, parche, jarabe, spray)
//   • strength        — numeric (free-text, accepts decimals)
//   • unit            — dropdown (mg, mcg, IU, g, ml, ninguna)
//   • defaultQuantity — stepper, 0.5 increments
//   • outcomeCheckHours — switch + dropdown (off = don't track, on = hours)
//   • notes           — optional free text ("SOS", "con comida")
//   • activeIngredient — optional, for future CIMA matching
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'dose_stepper.dart';

/// Entry point. Shows the modal sheet and resolves to the saved
/// MedicationDef, or null if the user cancelled.
Future<MedicationDef?> showMedFormSheet(
  BuildContext context, {
  required Color contrastColor,
  required Color inverseContrastColor,
  MedicationDef? existing,
}) {
  return showModalBottomSheet<MedicationDef>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => MedFormSheet(
      existing: existing,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
    ),
  );
}

class MedFormSheet extends StatefulWidget {
  final MedicationDef? existing;
  final Color contrastColor;
  final Color inverseContrastColor;

  const MedFormSheet({
    super.key,
    this.existing,
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  @override
  State<MedFormSheet> createState() => _MedFormSheetState();
}

class _MedFormSheetState extends State<MedFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _strengthCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _ingredientCtrl;

  String _unit = 'mg';
  String _form = 'pastilla';
  double _defaultQuantity = 1.0;
  int? _outcomeCheckHours = 3;
  bool _trackOutcomes = true;

  static const List<String> _units = ['mg', 'mcg', 'IU', 'g', 'ml', 'ninguna'];
  static const List<String> _forms = [
    'pastilla',
    'cápsula',
    'gota',
    'parche',
    'jarabe',
    'spray',
  ];
  static const List<int> _outcomeHourOptions = [1, 2, 3, 4, 6, 8, 12];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _strengthCtrl = TextEditingController(
      text: (e == null || e.strength == 0) ? '' : _trimZero(e.strength),
    );
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _ingredientCtrl = TextEditingController(text: e?.activeIngredient ?? '');

    if (e != null) {
      _unit = e.unit.isEmpty ? 'ninguna' : e.unit;
      _form = _forms.contains(e.form) ? e.form : 'pastilla';
      _defaultQuantity = e.defaultQuantity == 0 ? 1.0 : e.defaultQuantity;
      _outcomeCheckHours = e.outcomeCheckHours;
      _trackOutcomes = _outcomeCheckHours != null;
    }
  }

  String _trimZero(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _strengthCtrl.dispose();
    _notesCtrl.dispose();
    _ingredientCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  void _save() {
    final strength = double.tryParse(_strengthCtrl.text.trim()) ?? 0;
    final med = MedicationDef(
      id: widget.existing?.id, // preserve id on edit; null = generate new
      name: _nameCtrl.text.trim(),
      strength: strength,
      unit: _unit == 'ninguna' ? '' : _unit,
      form: _form,
      defaultQuantity: _defaultQuantity,
      outcomeCheckHours: _trackOutcomes ? _outcomeCheckHours : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      activeIngredient: _ingredientCtrl.text.trim().isEmpty
          ? null
          : _ingredientCtrl.text.trim(),
      cimaCode: widget.existing?.cimaCode, // preserve any prior CIMA match
    );
    Navigator.of(context).pop(med);
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final viewInsets = MediaQuery.of(context).viewInsets;

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
                          _isEditing ? 'Editar' : 'Nuevo',
                          style: TextStyle(
                            color: cc.withValues(alpha: 0.55),
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isEditing ? widget.existing!.name : 'Medicamento',
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
                decoration: _inputDeco('p. ej. Ibuprofeno', cc),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Form (presentation)
              _fieldLabel('Presentación', cc),
              _Dropdown<String>(
                value: _form,
                items: _forms,
                contrastColor: cc,
                inverseContrastColor: widget.inverseContrastColor,
                itemLabel: (s) => s,
                onChanged: (v) => setState(() => _form = v),
              ),
              const SizedBox(height: 14),

              // Strength + unit row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Concentración', cc),
                        TextField(
                          controller: _strengthCtrl,
                          style: TextStyle(color: cc),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          decoration: _inputDeco('p. ej. 400', cc),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Unidad', cc),
                        _Dropdown<String>(
                          value: _unit,
                          items: _units,
                          contrastColor: cc,
                          inverseContrastColor: widget.inverseContrastColor,
                          itemLabel: (s) => s,
                          onChanged: (v) => setState(() => _unit = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Default quantity
              _fieldLabel('Cantidad por dosis', cc),
              const SizedBox(height: 6),
              Center(
                child: DoseQuantityStepper(
                  value: _defaultQuantity,
                  onChanged: (v) => setState(() => _defaultQuantity = v),
                  formLabel: _form,
                  contrastColor: cc,
                ),
              ),
              const SizedBox(height: 14),

              // Outcome tracking
              _fieldLabel('Rastrear si funcionó', cc),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cc.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cc.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Switch(
                      value: _trackOutcomes,
                      onChanged: (v) => setState(() {
                        _trackOutcomes = v;
                        if (v && _outcomeCheckHours == null) {
                          _outcomeCheckHours = 3;
                        }
                      }),
                      activeColor: cc,
                    ),
                    if (_trackOutcomes) ...[
                      const SizedBox(width: 4),
                      Text(
                        'Revisar en',
                        style: TextStyle(
                          color: cc.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _HoursDropdown(
                        value: _outcomeCheckHours ?? 3,
                        contrastColor: cc,
                        inverseContrastColor: widget.inverseContrastColor,
                        onChanged: (v) =>
                            setState(() => _outcomeCheckHours = v),
                      ),
                    ] else
                      Text(
                        'No preguntar después de tomar',
                        style: TextStyle(
                          color: cc.withValues(alpha: 0.55),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Notes
              _fieldLabel('Notas (opcional)', cc),
              TextField(
                controller: _notesCtrl,
                style: TextStyle(color: cc),
                maxLines: 2,
                decoration: _inputDeco('p. ej. tomar con comida; SOS', cc),
              ),
              const SizedBox(height: 14),

              // Active ingredient — future CIMA matching
              _fieldLabel('Principio activo (opcional)', cc),
              TextField(
                controller: _ingredientCtrl,
                style: TextStyle(color: cc),
                decoration: _inputDeco('p. ej. Ibuprofeno', cc),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Guardar cambios' : 'Crear medicamento',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
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
            Text(
              ' *',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
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
      hintStyle: TextStyle(color: cc.withValues(alpha: 0.35), fontSize: 13),
      filled: true,
      fillColor: cc.withValues(alpha: 0.04),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cc, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    );
  }
}

/// Generic dropdown styled to match the form's text fields.
class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;
  final Color contrastColor;
  final Color inverseContrastColor;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: contrastColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: contrastColor.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: inverseContrastColor,
          style: TextStyle(color: contrastColor, fontSize: 14),
          iconEnabledColor: contrastColor.withValues(alpha: 0.6),
          items: items
              .map(
                (it) => DropdownMenuItem(
                  value: it,
                  child: Text(
                    itemLabel(it),
                    style: TextStyle(color: contrastColor),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _HoursDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final Color contrastColor;
  final Color inverseContrastColor;

  static const List<int> _options = [1, 2, 3, 4, 6, 8, 12];

  const _HoursDropdown({
    required this.value,
    required this.onChanged,
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _options.contains(value) ? value : 3,
        dropdownColor: inverseContrastColor,
        style: TextStyle(
          color: contrastColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        iconEnabledColor: contrastColor.withValues(alpha: 0.6),
        items: _options
            .map(
              (h) => DropdownMenuItem(
                value: h,
                child: Text('${h}h', style: TextStyle(color: contrastColor)),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
