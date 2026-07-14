import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

/// Returns the new/updated LifeEvent, or null if cancelled.
/// Pass `existing` to open in edit mode.
Future<LifeEvent?> showLifeEventFormSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  LifeEvent? existing,
}) {
  return showModalBottomSheet<LifeEvent>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (_) => _LifeEventFormBody(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      existing: existing,
    ),
  );
}

class _LifeEventFormBody extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final LifeEvent? existing;

  const _LifeEventFormBody({
    required this.contrastColor,
    required this.inverseContrastColor,
    this.existing,
  });

  @override
  State<_LifeEventFormBody> createState() => _LifeEventFormBodyState();
}

class _LifeEventFormBodyState extends State<_LifeEventFormBody> {
  late TextEditingController _titleCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _noteCtrl;
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _categoryCtrl = TextEditingController(text: e?.category ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _startDate = e?.startDate ?? DateTime.now();
    _endDate = e?.endDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final result = LifeEvent(
      id: widget.existing?.id,
      title: title,
      startDate: _startDate,
      endDate: _endDate,
      category: _categoryCtrl.text.trim().isEmpty
          ? null
          : _categoryCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
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
                isEdit ? "EDITAR EVENTO" : "REGISTRAR EVENTO",
                style: TextStyle(
                  color: cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Eventos que pueden haber impactado tu cuerpo o tu ánimo: un viaje, un accidente, una mudanza, un duelo, algo bueno.",
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                autofocus: !isEdit,
                style: TextStyle(color: cc),
                decoration: const InputDecoration(
                  hintText: "Título (ej. Viaje a Bariloche)",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Date range
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc.withValues(alpha: 0.5)),
                      ),
                      icon: Icon(Icons.calendar_today, color: cc, size: 14),
                      label: Text(
                        "Inicio: ${DateFormat('d MMM yyyy').format(_startDate)}",
                        style: TextStyle(color: cc, fontSize: 11),
                      ),
                      onPressed: _pickStartDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc.withValues(alpha: 0.5)),
                      ),
                      icon: Icon(Icons.calendar_today, color: cc, size: 14),
                      label: Text(
                        _endDate == null
                            ? "+ fin (opcional)"
                            : "Fin: ${DateFormat('d MMM yyyy').format(_endDate!)}",
                        style: TextStyle(color: cc, fontSize: 11),
                      ),
                      onPressed: _pickEndDate,
                    ),
                  ),
                ],
              ),
              if (_endDate != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _endDate = null),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      "quitar fecha de fin",
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Category
              TextField(
                controller: _categoryCtrl,
                style: TextStyle(color: cc),
                decoration: const InputDecoration(
                  hintText: "Categoría (opcional)",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: kLifeEventCategorySuggestions.map((cat) {
                  final isSelected =
                      _categoryCtrl.text.trim().toLowerCase() == cat;
                  return InkWell(
                    onTap: () => setState(() => _categoryCtrl.text = cat),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? cc : Colors.transparent,
                        border: Border.all(color: cc.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? ic : cc.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                style: TextStyle(color: cc),
                decoration: const InputDecoration(
                  hintText: "Nota (opcional)",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cc,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _save,
                child: Text(
                  isEdit ? 'GUARDAR CAMBIOS' : 'REGISTRAR EVENTO',
                  style: TextStyle(color: ic, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "cancelar",
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
