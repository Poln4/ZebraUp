// Sprint F.E — Retro symptom check-in dialog.
//
// Unified capture (severity-after + action + effectiveness) in one
// sheet. Shown when the user taps a RetroSymptomBanner card.
//
// Fields captured:
//   • severityAfter (0-4) — required
//   • kind — required; includes ActionKind.nothing for
//     "checked in but did nothing"
//   • medicationRefId (if kind == medication) — from filtered recent
//     doses (after symptom.timestamp); fallback to full botiquín via
//     inline switch
//   • customLabel (if kind == custom)
//   • notes (optional)
//   • effectivenessRating — INFERRED from severity delta + optional
//     "aliviaste algo pero después volvió" checkbox
//
// Returns Future<ActionTaken?>:
//   • ActionTaken with followUpCompleted=true on save
//   • null on cancel/close (banner stays visible)

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/action_taken.dart';

class RetroSymptomDialog extends StatefulWidget {
  final SymptomEvent symptom;
  final List<MedicationDef> botiquin;
  final List<DoseEvent> doseHistory;
  final Color contrastColor;
  final Color inverseContrastColor;

  const RetroSymptomDialog({
    super.key,
    required this.symptom,
    required this.botiquin,
    required this.doseHistory,
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  static Future<ActionTaken?> show({
    required BuildContext context,
    required SymptomEvent symptom,
    required List<MedicationDef> botiquin,
    required List<DoseEvent> doseHistory,
    required Color contrastColor,
    required Color inverseContrastColor,
  }) {
    return showModalBottomSheet<ActionTaken>(
      context: context,
      isScrollControlled: true,
      backgroundColor: inverseContrastColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: RetroSymptomDialog(
          symptom: symptom,
          botiquin: botiquin,
          doseHistory: doseHistory,
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
        ),
      ),
    );
  }

  @override
  State<RetroSymptomDialog> createState() => _RetroSymptomDialogState();
}

class _RetroSymptomDialogState extends State<RetroSymptomDialog> {
  int? _severityAfter;
  ActionKind? _kind;
  String? _medicationRefId;
  bool _showFullBotiquin = false;
  final TextEditingController _customCtrl = TextEditingController();
  bool _reliefThenReturned = false;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  static const _kindLabels = {
    ActionKind.medication: 'Medicamento',
    ActionKind.rest: 'Descanso',
    ActionKind.hydration: 'Hidratación',
    ActionKind.breathing: 'Respiración',
    ActionKind.heat: 'Calor',
    ActionKind.cold: 'Frío',
    ActionKind.elevation: 'Elevar piernas',
    ActionKind.sensoryReduction: 'Reducir estímulos',
    ActionKind.socialWithdrawal: 'Aislamiento social',
    ActionKind.food: 'Comer algo',
    ActionKind.movement: 'Movimiento suave',
    ActionKind.nothing: 'Nada / esperé',
    ActionKind.custom: 'Otro',
  };

  static const _kindEmojis = {
    ActionKind.medication: '💊',
    ActionKind.rest: '🛏️',
    ActionKind.hydration: '💧',
    ActionKind.breathing: '🧘',
    ActionKind.heat: '🔥',
    ActionKind.cold: '❄️',
    ActionKind.elevation: '🦵',
    ActionKind.sensoryReduction: '🕶️',
    ActionKind.socialWithdrawal: '🚪',
    ActionKind.food: '🍽️',
    ActionKind.movement: '🚶',
    ActionKind.nothing: '⏳',
    ActionKind.custom: '✏️',
  };

  List<DoseEvent> get _recentDoses {
    final now = DateTime.now();
    return widget.doseHistory.where((d) {
      return d.medicationId != null &&
          d.timestamp.isAfter(widget.symptom.timestamp) &&
          d.timestamp.isBefore(now);
    }).toList();
  }

  bool get _canSave {
    if (_severityAfter == null) return false;
    if (_kind == null) return false;
    if (_kind == ActionKind.medication && _medicationRefId == null) {
      return false;
    }
    if (_kind == ActionKind.custom && _customCtrl.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  EffectivenessRating _computeRating() {
    final before = widget.symptom.severity.value;
    final after = _severityAfter!;
    if (_reliefThenReturned) {
      return EffectivenessRating.partialReliefThenReturned;
    }
    final delta = before - after;
    if (delta >= 2) return EffectivenessRating.muchRelief;
    if (delta == 1) return EffectivenessRating.someRelief;
    if (delta == 0) return EffectivenessRating.noChange;
    return EffectivenessRating.worse;
  }

  int _minutesSinceSymptom() {
    return DateTime.now().difference(widget.symptom.timestamp).inMinutes;
  }

  String _describeDose(DoseEvent d) {
    final diff = DateTime.now().difference(d.timestamp);
    final ago = diff.inMinutes < 60
        ? 'hace ${diff.inMinutes} min'
        : 'hace ${diff.inHours} h';
    return '${d.medicationName} · $ago';
  }

  void _save() {
    if (!_canSave) return;
    final action = ActionTaken(
      timestamp: DateTime.now(),
      kind: _kind!,
      linkedEventId: widget.symptom.timestamp.toIso8601String(),
      linkedEventType: LinkedEventType.symptom,
      medicationRefId: _kind == ActionKind.medication ? _medicationRefId : null,
      customLabel: _kind == ActionKind.custom ? _customCtrl.text.trim() : null,
      severityBeforeAction: widget.symptom.severity.value,
      severityAfterAction: _severityAfter,
      followUpMinutes: _minutesSinceSymptom(),
      followUpCompleted: true,
      effectivenessRating: _computeRating(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    Navigator.of(context).pop(action);
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;
    final before = widget.symptom.severity.value;
    final showReliefCheckbox =
        _severityAfter != null && _severityAfter! < before;
    final doses = _recentDoses;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '¿Qué tal ahora?',
                      style: TextStyle(
                        color: cc,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: cc),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                '${widget.symptom.name} · antes: nivel $before · '
                'hace ${_minutesSinceSymptom()} min',
                style: TextStyle(
                  color: cc.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              // ── Severity NOW (required) ─────────────────────
              Text(
                '¿Cómo está ahora?',
                style: TextStyle(
                  color: cc,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: List.generate(5, (i) {
                  final selected = _severityAfter == i;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () => setState(() {
                          _severityAfter = i;
                          if (_severityAfter! >= before) {
                            _reliefThenReturned = false;
                          }
                        }),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: selected ? cc : Colors.transparent,
                            border: Border.all(color: cc),
                          ),
                          child: Center(
                            child: Text(
                              '$i',
                              style: TextStyle(
                                color: selected ? ic : cc,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 2),
              Text(
                '0 = sin síntoma · 4 = incapacitante',
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),

              // ── Relief-then-returned checkbox (conditional) ──
              if (showReliefCheckbox) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => setState(
                    () => _reliefThenReturned = !_reliefThenReturned,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _reliefThenReturned
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: cc,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aliviaste algo, pero después volvió',
                          style: TextStyle(color: cc, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Kind picker (13 with "Nada / esperé") ────────
              Text(
                '¿Hiciste algo?',
                style: TextStyle(
                  color: cc,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ActionKind.values.map((k) {
                  final selected = _kind == k;
                  final label = _kindLabels[k] ?? k.serializationKey;
                  final emoji = _kindEmojis[k] ?? '•';
                  return ActionChip(
                    label: Text(
                      '$emoji  $label',
                      style: TextStyle(
                        color: selected ? ic : cc,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: selected ? cc : Colors.transparent,
                    side: BorderSide(color: cc),
                    onPressed: () {
                      setState(() {
                        _kind = k;
                        if (k != ActionKind.medication) {
                          _medicationRefId = null;
                          _showFullBotiquin = false;
                        }
                        if (k != ActionKind.custom) {
                          _customCtrl.clear();
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              // ── Medication picker ────────────────────────────
              if (_kind == ActionKind.medication) ...[
                const SizedBox(height: 16),
                Text(
                  '¿Qué medicamento?',
                  style: TextStyle(
                    color: cc,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (doses.isNotEmpty && !_showFullBotiquin) ...[
                  ...doses.map((d) {
                    final selected = _medicationRefId == d.medicationId;
                    return InkWell(
                      onTap: () =>
                          setState(() => _medicationRefId = d.medicationId),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? cc : Colors.transparent,
                          border: Border.all(color: cc),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: selected ? ic : cc,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _describeDose(d),
                                style: TextStyle(
                                  color: selected ? ic : cc,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => setState(() => _showFullBotiquin = true),
                    child: Text(
                      'Otro del botiquín…',
                      style: TextStyle(
                        color: cc,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ] else ...[
                  if (doses.isEmpty)
                    Text(
                      'Sin dosis registradas después del síntoma.',
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (widget.botiquin.isEmpty)
                    Text(
                      'Sin medicamentos en el botiquín.',
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(border: Border.all(color: cc)),
                      child: DropdownButton<String>(
                        value: _medicationRefId,
                        hint: Text(
                          'Elegir del botiquín',
                          style: TextStyle(color: cc, fontSize: 13),
                        ),
                        dropdownColor: ic,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        style: TextStyle(color: cc, fontSize: 13),
                        iconEnabledColor: cc,
                        items: widget.botiquin.map((m) {
                          return DropdownMenuItem<String>(
                            value: m.id,
                            child: Text(m.name, style: TextStyle(color: cc)),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _medicationRefId = v),
                      ),
                    ),
                ],
              ],

              // ── Custom label ─────────────────────────────────
              if (_kind == ActionKind.custom) ...[
                const SizedBox(height: 16),
                Text(
                  '¿Qué hiciste?',
                  style: TextStyle(
                    color: cc,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _customCtrl,
                  style: TextStyle(color: cc, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Escribe brevemente',
                    hintStyle: TextStyle(color: cc.withValues(alpha: 0.5)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: cc),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: cc),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: cc, width: 2),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],

              const SizedBox(height: 16),

              // ── Notes ────────────────────────────────────────
              Text(
                'Notas (opcional)',
                style: TextStyle(
                  color: cc,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _notesCtrl,
                style: TextStyle(color: cc, fontSize: 13),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Contexto, dosis, patrón…',
                  hintStyle: TextStyle(color: cc.withValues(alpha: 0.5)),
                  border: OutlineInputBorder(borderSide: BorderSide(color: cc)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: cc),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: cc, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Action buttons ───────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => Navigator.of(context).pop(null),
                      child: Text('Ahora no', style: TextStyle(color: cc)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cc,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _canSave ? _save : null,
                      child: Text('Guardar', style: TextStyle(color: ic)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
