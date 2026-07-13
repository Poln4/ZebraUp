// Sprint E.C — MCAS red flag advisory dialog.
//
// Shown after saving a SymptomEvent with mcasDetail red flags marked.
// Matches the visual language of the headache thunderclap advisory:
// red iconography for the alert layer, contrast palette for the body.
//
// Response guidance is anaphylaxis-specific per Weiler CR et al. 2019
// AAAAI consensus: use of epinephrine autoinjector as first-line if
// available; escalation to emergency services; do-not-drive guidance
// during vasomotor instability.
//
// barrierDismissible=false forces the user to acknowledge before
// returning to the log — an accidental tap-outside shouldn't dismiss
// a potential anaphylaxis warning.

import 'package:flutter/material.dart';
import '../models/mcas.dart';

Future<void> showMCASAdvisoryDialog(
  BuildContext context, {
  required List<MCASRedFlag> flags,
  required Color contrastColor,
  required Color inverseContrastColor,
}) {
  if (flags.isEmpty) return Future.value();

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: inverseContrastColor,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.red,
        size: 44,
      ),
      title: Text(
        'Señales de alerta',
        style: TextStyle(
          color: contrastColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Marcaste las siguientes señales al registrar la reacción:',
              style: TextStyle(
                color: contrastColor.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            ...flags.map(
              (f) => Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _flagLabel(f),
                        style: TextStyle(
                          color: contrastColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esta combinación puede indicar anafilaxia.',
                    style: TextStyle(
                      color: contrastColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Si tienes autoinyector de epinefrina (EpiPen, '
                    'Jext), este es el momento de usarlo.\n'
                    '• Llama a emergencias si los síntomas no ceden en '
                    'pocos minutos o si empeoran.\n'
                    '• No manejes. Pide compañía.',
                    style: TextStyle(
                      color: contrastColor,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            'Entendido',
            style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

String _flagLabel(MCASRedFlag flag) => switch (flag) {
  MCASRedFlag.throatTightness => 'Garganta cerrada',
  MCASRedFlag.breathingDifficulty => 'Dificultad para respirar',
  MCASRedFlag.tongueSwelling => 'Lengua o glotis hinchada',
  MCASRedFlag.faintness => 'Desmayo o casi desmayo',
  MCASRedFlag.drasticBPChange => 'Presión cambió mucho',
  MCASRedFlag.confusion => 'Confusión o desorientación',
};
