import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../screens/timestamp_picker.dart';
import '../l10n/app_localizations.dart';

/// Returns the logged/edited TherapyEvent, or null if cancelled.
/// If `existing` is provided, opens in edit mode.
Future<TherapyEvent?> showTherapyLoggerSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required String modality,
  required DateTime defaultTimestamp,
  TherapyEvent? existing,
}) {
  return showModalBottomSheet<TherapyEvent>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(side: BorderSide(color: contrastColor, width: 2)),
    builder: (_) => _TherapyLoggerBody(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      modality: modality,
      defaultTimestamp: defaultTimestamp,
      existing: existing,
    ),
  );
}

class _TherapyLoggerBody extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final String modality;
  final DateTime defaultTimestamp;
  final TherapyEvent? existing;

  const _TherapyLoggerBody({
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.modality,
    required this.defaultTimestamp,
    this.existing,
  });

  @override
  State<_TherapyLoggerBody> createState() => _TherapyLoggerBodyState();
}

class _TherapyLoggerBodyState extends State<_TherapyLoggerBody> {
  late DateTime _ts;
  late TextEditingController _areaCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _therapistCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _noteCtrl;
  int? _before;
  int? _after;
  bool _showExtras = false;

  // 0–4 e-VAS scale, matching SymptomSeverity numeric values.
  // Labels are now resolved per-locale inside build(); see severityLabels list.
  static const _severityColors = [
    Color(0xFF81C784), // 0 — green
    Color(0xFFAED581), // 1 — light green
    Color(0xFFFFD54F), // 2 — yellow
    Color(0xFFFFB74D), // 3 — orange
    Color(0xFFE57373), // 4 — red
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _ts = e?.timestamp ?? widget.defaultTimestamp;
    _areaCtrl = TextEditingController(text: e?.bodyArea ?? '');
    _durationCtrl = TextEditingController(text: e?.durationMinutes?.toString() ?? '');
    _therapistCtrl = TextEditingController(text: e?.therapistOrPlace ?? '');
    _costCtrl = TextEditingController(text: e?.cost?.toString() ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _before = e?.severityBefore;
    _after = e?.severityAfter;
    _showExtras = (e?.therapistOrPlace?.isNotEmpty == true) ||
        (e?.cost != null) ||
        (e?.note?.isNotEmpty == true);
  }

  @override
  void dispose() {
    _areaCtrl.dispose();
    _durationCtrl.dispose();
    _therapistCtrl.dispose();
    _costCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final result = TherapyEvent(
      id: widget.existing?.id,
      timestamp: _ts,
      modality: widget.modality,
      bodyArea: _areaCtrl.text.trim().isEmpty ? null : _areaCtrl.text.trim(),
      durationMinutes: int.tryParse(_durationCtrl.text.trim()),
      therapistOrPlace: _therapistCtrl.text.trim().isEmpty ? null : _therapistCtrl.text.trim(),
      cost: int.tryParse(_costCtrl.text.trim()),
      severityBefore: _before,
      severityAfter: _after,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;
    final isEdit = widget.existing != null;
    final l10n = AppLocalizations.of(context)!;
    final severityLabels = <String>[
      l10n.movementPainLevelNone,
      l10n.movementPainLevelMild,
      l10n.movementPainLevelModerate,
      l10n.movementPainLevelIntense,
      l10n.movementPainLevelSevere,
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit
                    ? l10n.movementModalTitleEditTemplate(widget.modality.toUpperCase())
                    : l10n.movementModalTitleRegisterTemplate(widget.modality.toUpperCase()),
                style: TextStyle(color: cc, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Timestamp
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: BorderSide(color: cc.withValues(alpha: 0.5))),
                icon: Icon(Icons.access_time, color: cc, size: 16),
                label: Text(DateFormat('EEE d MMM, HH:mm').format(_ts),
                    style: TextStyle(color: cc, fontSize: 12)),
                onPressed: () async {
                  final picked = await pickTimestamp(
                      context: context, initial: _ts, contrastColor: cc, inverseContrastColor: ic);
                  if (picked != null) setState(() => _ts = picked);
                },
              ),
              const SizedBox(height: 16),

              // Body area + duration row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _areaCtrl,
                      style: TextStyle(color: cc),
                      decoration: InputDecoration(
                        hintText: l10n.therapyHintArea,
                        hintStyle: const TextStyle(color: Colors.grey),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _durationCtrl,
                      style: TextStyle(color: cc),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: l10n.movementModalHintDuration,
                        hintStyle: const TextStyle(color: Colors.grey),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // e-VAS before
              Text(l10n.therapySectionPainBefore,
                  style: TextStyle(
                      color: cc.withValues(alpha: 0.7),
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _severityRow(_before, severityLabels, (v) => setState(() => _before = v)),

              const SizedBox(height: 16),

              // e-VAS after
              Text(l10n.therapySectionPainAfter,
                  style: TextStyle(
                      color: cc.withValues(alpha: 0.7),
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _severityRow(_after, severityLabels, (v) => setState(() => _after = v)),

              // Delta hint
              if (_before != null && _after != null) ...[
                const SizedBox(height: 10),
                _deltaHint(cc),
              ],

              const SizedBox(height: 16),

              // Expand for extras
              if (!_showExtras)
                TextButton.icon(
                  onPressed: () => setState(() => _showExtras = true),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  icon: Icon(Icons.add, color: cc.withValues(alpha: 0.7), size: 14),
                  label: Text(l10n.therapyActionMoreDetails,
                      style: TextStyle(color: cc.withValues(alpha: 0.7), fontSize: 12)),
                )
              else ...[
                TextField(
                  controller: _therapistCtrl,
                  style: TextStyle(color: cc),
                  decoration: InputDecoration(
                    hintText: l10n.therapyHintTherapist,
                    hintStyle: const TextStyle(color: Colors.grey),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _costCtrl,
                  style: TextStyle(color: cc),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: l10n.therapyHintCost,
                    hintStyle: const TextStyle(color: Colors.grey),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  style: TextStyle(color: cc),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: l10n.therapyHintNote,
                    hintStyle: const TextStyle(color: Colors.grey),
                    isDense: true,
                  ),
                ),
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cc,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _save,
                child: Text(isEdit ? l10n.therapyActionSaveChanges : l10n.therapyActionLog,
                    style: TextStyle(color: ic, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.actionCancel.toLowerCase(),
                      style: TextStyle(color: cc.withValues(alpha: 0.6))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _severityRow(int? value, List<String> severityLabels, ValueChanged<int?> onTap) {
    final cc = widget.contrastColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (i) {
        final isSelected = value == i;
        return InkWell(
          onTap: () => onTap(isSelected ? null : i),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _severityColors[i],
                    border: Border.all(
                      color: isSelected ? cc : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  severityLabels[i],
                  style: TextStyle(
                    color: cc,
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _deltaHint(Color cc) {
    final l10n = AppLocalizations.of(context)!;
    final delta = (_before ?? 0) - (_after ?? 0);
    String label;
    Color color;
    IconData icon;
    if (delta > 0) {
      label = l10n.movementPainDeltaImprovedTemplate(delta);
      color = const Color(0xFF81C784);
      icon = Icons.trending_down;
    } else if (delta < 0) {
      label = l10n.movementPainDeltaWorseTemplate(-delta);
      color = const Color(0xFFE57373);
      icon = Icons.trending_up;
    } else {
      label = l10n.movementPainDeltaUnchanged;
      color = cc.withValues(alpha: 0.5);
      icon = Icons.trending_flat;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}