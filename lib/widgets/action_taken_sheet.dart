// Sprint F.B+C — Post-event action capture sheet.
//
// Shown after a SymptomEvent, BowelEvent, HemorrhoidalEvent or FeverReading
// is saved when `_p.settings.optionalTrackers['action_taken']` is enabled.
//
// Captures:
//   • ActionKind (12 kinds — medication / rest / hydration / breathing /
//     heat / cold / elevation / sensory_reduction / social_withdrawal /
//     food / movement / custom)
//   • Optional medicationRefId (if kind == medication)
//   • Optional customLabel (if kind == custom)
//   • Optional severityBeforeAction (only for symptom-linked events)
//   • Optional followUpMinutes (30 / 60 / 90 / 1440)
//   • Optional notes
//
// Movement kind: closes without saving an ActionTaken. Caller should
// route user to movement_tab (F.E+F will wire this).
//
// Follow-up effectiveness capture (banner + dialog) is F.D territory.
//
// UI copy: hardcoded ES (LatAm tuteo neutro estricto). Migration to
// l10n / ARB happens in F.E+F alongside settings toggle.

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/action_taken.dart';

class ActionTakenSheet extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final String linkedEventId;
  final LinkedEventType linkedEventType;

  /// Severity of the linked symptom immediately before the action, on the
  /// 0-4 SymptomSeverity scale. Only meaningful when linkedEventType ==
  /// symptom; null hides the severity-before row for non-symptom events.
  final int? severityBefore;

  /// User's Botiquín — used to populate the medication picker when
  /// ActionKind.medication is chosen.
  final List<MedicationDef> botiquin;

  const ActionTakenSheet({
    super.key,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.linkedEventId,
    required this.linkedEventType,
    this.severityBefore,
    required this.botiquin,
  });

  static Future<ActionTaken?> show({
    required BuildContext context,
    required Color contrastColor,
    required Color inverseContrastColor,
    required String linkedEventId,
    required LinkedEventType linkedEventType,
    int? severityBefore,
    required List<MedicationDef> botiquin,
  }) {
    return showModalBottomSheet<ActionTaken>(
      context: context,
      isScrollControlled: true,
      backgroundColor: inverseContrastColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ActionTakenSheet(
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
          linkedEventId: linkedEventId,
          linkedEventType: linkedEventType,
          severityBefore: severityBefore,
          botiquin: botiquin,
        ),
      ),
    );
  }

  @override
  State<ActionTakenSheet> createState() => _ActionTakenSheetState();
}

class _ActionTakenSheetState extends State<ActionTakenSheet> {
  ActionKind? _kind;
  String? _medicationRefId;
  final TextEditingController _customCtrl = TextEditingController();
  int? _severityBefore;
  int? _followUpMinutes;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _severityBefore = widget.severityBefore;
    // Default follow-up: 60 min for symptom-linked events; none for others.
    // Bowel/hem/fever tend to be discrete events without a clean check-in
    // window; user can still opt in to a follow-up manually.
    _followUpMinutes = widget.linkedEventType == LinkedEventType.symptom
        ? 60
        : null;
  }

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

  bool get _canSave {
    if (_kind == null) return false;
    if (_kind == ActionKind.movement) return true; // save = go-to-movement
    if (_kind == ActionKind.medication && _medicationRefId == null) {
      return false;
    }
    if (_kind == ActionKind.custom && _customCtrl.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void _save() {
    if (!_canSave) return;
    if (_kind == ActionKind.movement) {
      // Movement kind is a pointer to movement_tab — no ActionTaken saved.
      // Caller receives null and can route the user. F.E+F wires the
      // actual navigation.
      Navigator.of(context).pop(null);
      return;
    }
    final action = ActionTaken(
      timestamp: DateTime.now(),
      kind: _kind!,
      linkedEventId: widget.linkedEventId,
      linkedEventType: widget.linkedEventType,
      medicationRefId: _kind == ActionKind.medication ? _medicationRefId : null,
      customLabel: _kind == ActionKind.custom ? _customCtrl.text.trim() : null,
      severityBeforeAction: _severityBefore,
      followUpMinutes: _followUpMinutes,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    Navigator.of(context).pop(action);
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;
    final isMovement = _kind == ActionKind.movement;
    final showExtras = _kind != null && !isMovement;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '¿Hiciste algo para esto?',
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
                'Opcional — si tomaste alguna acción, la registramos para ver qué funciona.',
                style: TextStyle(color: cc, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // ── ActionKind chips (12) ────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ActionKind.values
                    .where((k) => k != ActionKind.nothing)
                    .map((k) {
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
                            }
                            if (k != ActionKind.custom) {
                              _customCtrl.clear();
                            }
                          });
                        },
                      );
                    })
                    .toList(),
              ),

              // ── Movement redirect message ────────────────────────────
              if (isMovement) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: cc)),
                  child: Text(
                    'El movimiento va en su pestaña. Registra acupuntura, TENS, '
                    'estiramiento o cualquier ejercicio en Movimiento para tener '
                    'el detalle completo.',
                    style: TextStyle(color: cc, fontSize: 12),
                  ),
                ),
              ],

              // ── Medication picker ────────────────────────────────────
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
                if (widget.botiquin.isEmpty)
                  Text(
                    'Sin medicamentos en el botiquín todavía.',
                    style: TextStyle(color: cc, fontSize: 12),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(border: Border.all(color: cc)),
                    child: DropdownButton<String>(
                      value: _medicationRefId,
                      hint: Text(
                        'Elegir',
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

              // ── Custom label field ───────────────────────────────────
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

              // ── Severity BEFORE (symptom-linked only) ────────────────
              if (showExtras &&
                  widget.linkedEventType == LinkedEventType.symptom) ...[
                const SizedBox(height: 20),
                Text(
                  '¿Cómo estaba el síntoma justo antes?',
                  style: TextStyle(
                    color: cc,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) {
                    final selected = _severityBefore == i;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          onTap: () => setState(() => _severityBefore = i),
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
                    color: cc.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],

              // ── Follow-up window ─────────────────────────────────────
              if (showExtras) ...[
                const SizedBox(height: 20),
                Text(
                  '¿Cuándo lo revisamos?',
                  style: TextStyle(
                    color: cc,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _followUpChip(null, 'No revisar', cc, ic),
                    _followUpChip(30, 'En 30 min', cc, ic),
                    _followUpChip(60, 'En 1 h', cc, ic),
                    _followUpChip(90, 'En 1 h 30', cc, ic),
                    _followUpChip(1440, 'En 24 h', cc, ic),
                  ],
                ),
              ],

              // ── Notes ────────────────────────────────────────────────
              if (showExtras) ...[
                const SizedBox(height: 16),
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
                    hintText: 'Detalles, dosis, contexto…',
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
                ),
              ],

              // ── Action buttons ───────────────────────────────────────
              const SizedBox(height: 20),
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
                      child: Text(
                        isMovement ? 'Ir a Movimiento' : 'Registrar acción',
                        style: TextStyle(color: ic),
                      ),
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

  Widget _followUpChip(int? minutes, String label, Color cc, Color ic) {
    final selected = _followUpMinutes == minutes;
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? ic : cc,
          fontSize: 12,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: selected ? cc : Colors.transparent,
      side: BorderSide(color: cc),
      onPressed: () => setState(() => _followUpMinutes = minutes),
    );
  }
}
