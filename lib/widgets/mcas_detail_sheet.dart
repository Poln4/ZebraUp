// Sprint E.B — MCAS detail bottom sheet.
//
// Reusable modal sheet for capturing MCAS-specific detail on a
// symptom log. Applies progressive disclosure semántico based on
// which symptom keyword triggered the sheet:
//   - 'urticaria' / 'ronchas' / 'habones' → pre-mark urticaria kind
//   - 'hinchazón' / 'angioedema' → pre-mark angioedema kind
//   - 'moretón' / 'moretones' / 'hematoma' → pre-mark bruising kind
//   - 'flush' / 'enrojecimiento' → pre-mark flushing kind
//   - 'picazón' / 'prurito' → pre-mark itching kind
//   - 'sangrado abundante' → pre-mark heavyBleeding kind
//   - 'palpitaciones' / 'mareo' → pre-mark cardiovascular kind
//   - null / other → no pre-selection (full sheet)
//
// All 5 sections always visible — respects user autonomy to log
// combinations (flushing with GI, urticaria with respiratory, etc.).
//
// Red flag capture happens here (multi-select markers); the emergency
// dialog on save fires in Sprint E.C (this sheet just returns the
// MCASDetail with redFlags populated).
//
// Empty MCASDetail on save is a legitimate choice — user may have
// cancelled thoughtfully. isEmpty getter lets the caller decide.

import 'package:flutter/material.dart';
import '../models/mcas.dart';

/// Show the MCAS detail sheet and await the user's choice.
///
/// [symptomInput] is the exact string from the vault that triggered
/// this sheet — used for keyword-based progressive disclosure.
///
/// Returns null on cancel; returns a (potentially empty) MCASDetail
/// on save. Caller uses `detail.isEmpty` to decide whether to persist.
Future<MCASDetail?> showMCASDetailSheet(
  BuildContext context, {
  required String symptomInput,
  required Color contrastColor,
  required Color inverseContrastColor,
  MCASDetail? existing,
}) {
  return showModalBottomSheet<MCASDetail?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: inverseContrastColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _MCASDetailSheetContent(
      symptomInput: symptomInput,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      existing: existing,
    ),
  );
}

class _MCASDetailSheetContent extends StatefulWidget {
  final String symptomInput;
  final Color contrastColor;
  final Color inverseContrastColor;
  final MCASDetail? existing;

  const _MCASDetailSheetContent({
    required this.symptomInput,
    required this.contrastColor,
    required this.inverseContrastColor,
    this.existing,
  });

  @override
  State<_MCASDetailSheetContent> createState() =>
      _MCASDetailSheetContentState();
}

class _MCASDetailSheetContentState extends State<_MCASDetailSheetContent> {
  late Set<MCASReactionKind> _reactionKinds;
  MCASOnsetWindow? _onsetWindow;
  late Set<MCASRedFlag> _redFlags;

  /// One text controller per selected TriggerKind. Presence in this
  /// map == kind is selected. Controller text == optional label.
  final Map<TriggerKind, TextEditingController> _triggerControllers = {};

  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reactionKinds = Set.of(widget.existing?.reactionKinds ?? const {});
    _onsetWindow = widget.existing?.onsetWindow;
    _redFlags = Set.of(widget.existing?.redFlags ?? const {});
    if (widget.existing?.notes != null) {
      _notesCtrl.text = widget.existing!.notes!;
    }

    // Restore trigger controllers from existing tags
    if (widget.existing != null) {
      for (final tag in widget.existing!.suspectedTriggers) {
        _triggerControllers[tag.kind] = TextEditingController(
          text: tag.label ?? '',
        );
      }
    }

    // Progressive disclosure — pre-mark based on symptomInput keywords
    _applyProgressiveDisclosure(widget.symptomInput);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final ctrl in _triggerControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _applyProgressiveDisclosure(String input) {
    final lower = input.toLowerCase();
    void mark(MCASReactionKind k) {
      if (!_reactionKinds.contains(k)) _reactionKinds.add(k);
    }

    if (RegExp(r'urticaria|roncha|habon').hasMatch(lower)) {
      mark(MCASReactionKind.urticaria);
    }
    if (RegExp(r'hincha|angioedema|edema').hasMatch(lower)) {
      mark(MCASReactionKind.angioedema);
    }
    if (RegExp(r'moret|hematoma|equimosis').hasMatch(lower)) {
      mark(MCASReactionKind.bruising);
    }
    if (RegExp(r'flush|enrojec|rubor').hasMatch(lower)) {
      mark(MCASReactionKind.flushing);
    }
    if (RegExp(r'pica|prurito|comez').hasMatch(lower)) {
      mark(MCASReactionKind.itching);
    }
    if (RegExp(
      r'sangrado abundante|menorragia|regla intensa',
    ).hasMatch(lower)) {
      mark(MCASReactionKind.heavyBleeding);
    }
    if (RegExp(r'palpitaci|taquicard|mareo|vahído').hasMatch(lower)) {
      mark(MCASReactionKind.cardiovascular);
    }
  }

  // ────────────────────────────────────────────────────────────
  // Labels (fuller than the compact labels exported by mcas.dart)
  // ────────────────────────────────────────────────────────────

  static const _reactionKindLabels = {
    MCASReactionKind.flushing: '🔥 Enrojecimiento',
    MCASReactionKind.urticaria: '🟠 Habones / urticaria',
    MCASReactionKind.itching: '💥 Picazón sin lesión',
    MCASReactionKind.angioedema: '🎈 Hinchazón / angioedema',
    MCASReactionKind.gi: '🌀 Digestivo',
    MCASReactionKind.respiratory: '💨 Respiratorio',
    MCASReactionKind.cardiovascular: '💓 Cardiovascular',
    MCASReactionKind.bruising: '🟣 Moretones',
    MCASReactionKind.heavyBleeding: '🩸 Sangrado abundante',
    MCASReactionKind.other: '❓ Otra reacción',
  };

  static const _onsetLabels = {
    MCASOnsetWindow.immediate: 'Inmediato (<5 min)',
    MCASOnsetWindow.earlyMinutes: '5-30 min',
    MCASOnsetWindow.lateMinutes: '30 min - 2 h',
    MCASOnsetWindow.earlyHours: '2-6 h',
    MCASOnsetWindow.lateHours: '6-24 h',
    MCASOnsetWindow.unknown: 'No lo sé',
  };

  static const _triggerKindLabels = {
    TriggerKind.food: '🍽️ Comida',
    TriggerKind.medication: '💊 Medicamento',
    TriggerKind.environmental: '🌫️ Ambiental',
    TriggerKind.thermal: '🌡️ Térmico',
    TriggerKind.hormonal: '🌙 Hormonal',
    TriggerKind.stress: '⚡ Estrés',
    TriggerKind.unknown: '❓ No sé',
  };

  static const _triggerHints = {
    TriggerKind.food: 'ej: queso añejo, embutidos, alcohol, chocolate…',
    TriggerKind.medication: 'ej: ibuprofeno, contraste iodado, opioide…',
    TriggerKind.environmental: 'ej: perfume, limpiador, moho, polvo…',
    TriggerKind.thermal: 'ej: ducha caliente, frío intenso, ejercicio…',
    TriggerKind.hormonal: 'ej: menstruación, ovulación…',
    TriggerKind.stress: 'ej: discusión, poco sueño, ansiedad…',
    TriggerKind.unknown: '',
  };

  static const _redFlagLabels = {
    MCASRedFlag.throatTightness: 'Garganta cerrada',
    MCASRedFlag.breathingDifficulty: 'Dificultad para respirar',
    MCASRedFlag.tongueSwelling: 'Lengua o glotis hinchada',
    MCASRedFlag.faintness: 'Desmayo o casi desmayo',
    MCASRedFlag.drasticBPChange: 'Presión cambió mucho',
    MCASRedFlag.confusion: 'Confusión o desorientación',
  };

  // ────────────────────────────────────────────────────────────
  // State mutators
  // ────────────────────────────────────────────────────────────

  void _toggleReactionKind(MCASReactionKind k) {
    setState(() {
      if (_reactionKinds.contains(k)) {
        _reactionKinds.remove(k);
      } else {
        _reactionKinds.add(k);
      }
    });
  }

  void _setOnsetWindow(MCASOnsetWindow? w) {
    setState(() => _onsetWindow = w);
  }

  void _toggleTriggerKind(TriggerKind k) {
    setState(() {
      if (_triggerControllers.containsKey(k)) {
        _triggerControllers.remove(k)?.dispose();
      } else {
        _triggerControllers[k] = TextEditingController();
      }
    });
  }

  void _toggleRedFlag(MCASRedFlag f) {
    setState(() {
      if (_redFlags.contains(f)) {
        _redFlags.remove(f);
      } else {
        _redFlags.add(f);
      }
    });
  }

  Set<TriggerTag> _collectTriggers() {
    return _triggerControllers.entries.map((e) {
      final label = e.value.text.trim();
      return TriggerTag(kind: e.key, label: label.isEmpty ? null : label);
    }).toSet();
  }

  void _save() {
    final detail = MCASDetail(
      reactionKinds: Set.unmodifiable(_reactionKinds),
      onsetWindow: _onsetWindow,
      suspectedTriggers: Set.unmodifiable(_collectTriggers()),
      redFlags: Set.unmodifiable(_redFlags),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    Navigator.of(context).pop(detail);
  }

  void _cancel() {
    Navigator.of(context).pop(null);
  }

  // ────────────────────────────────────────────────────────────
  // Build
  // ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detalle MCAS',
                      style: TextStyle(
                        color: cc,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: cc),
                    onPressed: _cancel,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Reacción sobre: ${widget.symptomInput}',
                style: TextStyle(
                  color: cc.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              // 1. Reaction kinds
              _sectionTitle(cc, '¿QUÉ TIPO DE REACCIÓN?'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MCASReactionKind.values.map((k) {
                  final selected = _reactionKinds.contains(k);
                  return _chip(
                    label: _reactionKindLabels[k] ?? k.serializationKey,
                    selected: selected,
                    cc: cc,
                    ic: ic,
                    onTap: () => _toggleReactionKind(k),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 2. Onset window
              _sectionTitle(cc, '¿CUÁNTO TARDÓ EN APARECER?'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MCASOnsetWindow.values.map((w) {
                  final selected = _onsetWindow == w;
                  return _chip(
                    label: _onsetLabels[w] ?? w.serializationKey,
                    selected: selected,
                    cc: cc,
                    ic: ic,
                    onTap: () => _setOnsetWindow(selected ? null : w),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 3. Suspected triggers
              _sectionTitle(cc, '¿SOSPECHAS DE ALGÚN GATILLO?'),
              Text(
                'Opcional. Puedes dejar el detalle en blanco.',
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TriggerKind.values.map((k) {
                  final selected = _triggerControllers.containsKey(k);
                  return _chip(
                    label: _triggerKindLabels[k] ?? k.serializationKey,
                    selected: selected,
                    cc: cc,
                    ic: ic,
                    onTap: () => _toggleTriggerKind(k),
                  );
                }).toList(),
              ),
              // Inline label input for each selected trigger kind
              ..._triggerControllers.entries.map((entry) {
                final kind = entry.key;
                final ctrl = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 88,
                        child: Text(
                          '${_triggerKindLabels[kind] ?? ""}:',
                          style: TextStyle(
                            color: cc.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          style: TextStyle(color: cc, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: _triggerHints[kind] ?? '',
                            hintStyle: TextStyle(
                              color: cc.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: cc.withValues(alpha: 0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: cc.withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: cc, width: 1.5),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              // 4. Red flags
              _sectionTitle(cc, 'SEÑALES DE ALERTA'),
              Text(
                'Marca cualquier señal que haya aparecido. Si hay alguna, '
                'te vamos a mostrar una advertencia al guardar.',
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MCASRedFlag.values.map((f) {
                  final selected = _redFlags.contains(f);
                  return _chip(
                    label: _redFlagLabels[f] ?? f.serializationKey,
                    selected: selected,
                    cc: cc,
                    ic: ic,
                    onTap: () => _toggleRedFlag(f),
                    urgent: true,
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 5. Notes
              _sectionTitle(cc, 'NOTAS (OPCIONAL)'),
              const SizedBox(height: 6),
              TextField(
                controller: _notesCtrl,
                style: TextStyle(color: cc, fontSize: 13),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Contexto, dosis, patrón, lo que sea útil recordar…',
                  hintStyle: TextStyle(
                    color: cc.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: cc.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: cc.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: cc, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _cancel,
                      child: Text('Cancelar', style: TextStyle(color: cc)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cc,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _save,
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

  // ────────────────────────────────────────────────────────────
  // Small helpers
  // ────────────────────────────────────────────────────────────

  Widget _sectionTitle(Color cc, String text) {
    return Text(
      text,
      style: TextStyle(
        color: cc.withValues(alpha: 0.6),
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required Color cc,
    required Color ic,
    required VoidCallback onTap,
    bool urgent = false,
  }) {
    // urgent chips get a red border tint when selected — reserved for red flags
    final borderColor = selected
        ? (urgent ? Colors.red.withValues(alpha: 0.6) : cc)
        : cc.withValues(alpha: 0.35);
    final bgColor = selected
        ? (urgent ? Colors.red.withValues(alpha: 0.85) : cc)
        : Colors.transparent;
    final textColor = selected ? ic : cc;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
