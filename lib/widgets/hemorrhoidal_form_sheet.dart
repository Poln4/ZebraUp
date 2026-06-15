// =============================================================================
// HemorrhoidalFormSheet — log or edit a HemorrhoidalEvent.
//
// Smaller sheet than BowelFormSheet. Hemorrhoidal events are tracked
// independently from bowel movements because they can occur without one,
// or persist across multiple bowel events.
//
// EDS-hemorrhoid connective tissue link: Plackett 2014, Parol 2025,
// Sandler 2019.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../screens/timestamp_picker.dart';
import 'severity_picker.dart';

Future<HemorrhoidalEvent?> showHemorrhoidalFormSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required DateTime defaultTimestamp,
  HemorrhoidalEvent? existing,
}) {
  return showModalBottomSheet<HemorrhoidalEvent>(
    context: context,
    backgroundColor: inverseContrastColor,
    shape: RoundedRectangleBorder(
        side: BorderSide(color: contrastColor, width: 2)),
    isScrollControlled: true,
    builder: (ctx) => _HemorrhoidalForm(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      defaultTimestamp: defaultTimestamp,
      existing: existing,
    ),
  );
}

class _HemorrhoidalForm extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final DateTime defaultTimestamp;
  final HemorrhoidalEvent? existing;

  const _HemorrhoidalForm({
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.defaultTimestamp,
    this.existing,
  });

  @override
  State<_HemorrhoidalForm> createState() => _HemorrhoidalFormState();
}

class _HemorrhoidalFormState extends State<_HemorrhoidalForm> {
  late DateTime _timestamp;
  late SymptomSeverity _severity;
  late bool _bleeding;
  late TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _timestamp = e?.timestamp ?? widget.defaultTimestamp;
    _severity = e?.severity ?? SymptomSeverity.none;
    _bleeding = e?.bleeding ?? false;
    _noteCtrl = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;

  void _save() {
    final note = _noteCtrl.text.trim();
    final result = HemorrhoidalEvent(
      id: widget.existing?.id,
      timestamp: _timestamp,
      bleeding: _bleeding,
      severity: _severity,
      note: note.isEmpty ? null : note,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final title = isEdit ? 'EDITAR HEMORROIDE' : 'REGISTRAR HEMORROIDE';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            const SizedBox(height: 16),
            Text(
              'MOLESTIA',
              style: TextStyle(
                color: _cc.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            SeverityDotPicker(
              selected: _severity,
              showLabels: true,
              onSelect: (s) => setState(() => _severity = s),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => setState(() => _bleeding = !_bleeding),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _bleeding ? _cc : Colors.transparent,
                  border: Border.all(
                      color: _cc.withValues(alpha: _bleeding ? 1.0 : 0.4)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _bleeding
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: _bleeding ? _ic : _cc.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'sangrado',
                      style: TextStyle(
                        color: _bleeding ? _ic : _cc.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: _bleeding
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              style: TextStyle(color: _cc),
              decoration: const InputDecoration(
                hintText: 'Nota opcional',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _cc,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _save,
              child: Text(
                'GUARDAR',
                style: TextStyle(color: _ic, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
