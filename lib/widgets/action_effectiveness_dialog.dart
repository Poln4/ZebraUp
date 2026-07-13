// Sprint F.D — Effectiveness capture dialog.
//
// Bottom sheet opened when the user taps a FollowUpBanner card.
// Captures:
//   • severityAfterAction (0-4) — only rendered when the original
//     ActionTaken has severityBeforeAction set
//   • effectivenessRating (5 values, required to save)
//   • notes (optional)
//
// On save, returns the ORIGINAL action mutated via copyWith with
// followUpCompleted = true. Caller replaces the corresponding entry
// in Profile.actionsHistory.
//
// On cancel/close, returns null — banner stays visible in Hoy tab
// and the user gets prompted again next time.
//
// UI copy: hardcoded ES tuteo neutro. Migration to l10n in F.E+F.

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/action_taken.dart';

class ActionEffectivenessDialog extends StatefulWidget {
  final ActionTaken action;
  final List<MedicationDef> botiquin;
  final Color contrastColor;
  final Color inverseContrastColor;

  const ActionEffectivenessDialog({
    super.key,
    required this.action,
    required this.botiquin,
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  static Future<ActionTaken?> show({
    required BuildContext context,
    required ActionTaken action,
    required List<MedicationDef> botiquin,
    required Color contrastColor,
    required Color inverseContrastColor,
  }) {
    return showModalBottomSheet<ActionTaken>(
      context: context,
      isScrollControlled: true,
      backgroundColor: inverseContrastColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ActionEffectivenessDialog(
          action: action,
          botiquin: botiquin,
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
        ),
      ),
    );
  }

  @override
  State<ActionEffectivenessDialog> createState() =>
      _ActionEffectivenessDialogState();
}

class _ActionEffectivenessDialogState extends State<ActionEffectivenessDialog> {
  int? _severityAfter;
  EffectivenessRating? _rating;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _severityAfter = widget.action.severityAfterAction;
    _rating = widget.action.effectivenessRating;
    if (widget.action.notes != null) {
      _notesCtrl.text = widget.action.notes!;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  static const _ratingLabels = {
    EffectivenessRating.muchRelief: 'Mucho alivio',
    EffectivenessRating.someRelief: 'Algo de alivio',
    EffectivenessRating.partialReliefThenReturned:
        'Alivio parcial, luego volvió',
    EffectivenessRating.noChange: 'Sin cambio',
    EffectivenessRating.worse: 'Empeoró',
  };

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

  bool get _canSave => _rating != null;

  String _describe() {
    final a = widget.action;
    final base = _kindLabels[a.kind] ?? a.kind.serializationKey;
    if (a.kind == ActionKind.medication && a.medicationRefId != null) {
      final matches = widget.botiquin.where((m) => m.id == a.medicationRefId);
      if (matches.isNotEmpty) return '$base: ${matches.first.name}';
    }
    if (a.kind == ActionKind.custom && a.customLabel != null) {
      return '$base: ${a.customLabel}';
    }
    return base;
  }

  void _save() {
    if (!_canSave) return;
    final updated = widget.action.copyWith(
      followUpCompleted: true,
      severityAfterAction: _severityAfter,
      effectivenessRating: _rating,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;
    final a = widget.action;
    final showSeverityAfter = a.severityBeforeAction != null;
    final emoji = _kindEmojis[a.kind] ?? '•';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '¿Cómo te fue?',
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

              // ── Action summary ────────────────────────────────
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _describe(),
                      style: TextStyle(
                        color: cc,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Severity AFTER (only if BEFORE was captured) ──
              if (showSeverityAfter) ...[
                Text(
                  '¿Cómo está el síntoma ahora?',
                  style: TextStyle(
                    color: cc,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Antes: nivel ${a.severityBeforeAction}',
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.65),
                    fontSize: 11,
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
                          onTap: () => setState(() => _severityAfter = i),
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
                const SizedBox(height: 20),
              ],

              // ── Effectiveness rating (required) ───────────────
              Text(
                '¿Qué tal funcionó?',
                style: TextStyle(
                  color: cc,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              ...EffectivenessRating.values.map((r) {
                final selected = _rating == r;
                final label = _ratingLabels[r] ?? r.serializationKey;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => setState(() => _rating = r),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? cc : Colors.transparent,
                        border: Border.all(color: cc),
                        borderRadius: BorderRadius.circular(6),
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
                              label,
                              style: TextStyle(
                                color: selected ? ic : cc,
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // ── Notes ─────────────────────────────────────────
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
                  hintText: 'Contexto, efectos, patrón…',
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

              // ── Action buttons ────────────────────────────────
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
