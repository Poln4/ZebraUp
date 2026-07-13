// Sprint G.E — Flare suggestion + 48h check-in banner.
//
// One widget, two modes, unified UX pattern ("the system asks the
// user something about their state"):
//
//   • suggest — heuristic detection fired AND user is not in flare
//     mode AND not in dismissal cooldown. Subtle contrast (0.05 bg,
//     0.4 border), lightbulb icon, bullets for each triggered rule.
//     Actions: "No, gracias" (dismiss, 24h cooldown) or "Activar
//     modo crisis" (activate flare mode + add today to pacing).
//
//   • checkIn — user IS in flare mode AND 48h+ passed since start
//     or last prompt. Prominent contrast (0.08 bg, full border),
//     clock icon, question "¿Cómo estás?". Actions: "Sigo mal"
//     (increment promptCount + lastPromptAt = now) or "Ya estoy
//     mejor" (exit flare mode).
//
//   • none — Nothing to ask. Widget returns SizedBox.shrink.
//
// No confirmation dialogs — the user is answering a direct question
// posed by the app, not initiating an action. Adding a confirmation
// on top of the answer would be redundant.
//
// Heuristic evaluation happens in build() (runs on each rebuild of
// Hoy). Cost is negligible for the current 3 rules over typical
// history sizes (~a few dozen items scanned).

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/profile_state.dart';
import '../services/flare_detection_service.dart';

enum _Mode { none, suggest, checkIn }

class FlareSuggestionBanner extends StatelessWidget {
  final Profile profile;
  final Color contrastColor;
  final Color inverseContrastColor;

  /// suggest-mode: user accepts, activate flare mode
  final VoidCallback onAcceptSuggestion;

  /// suggest-mode: user declines, start 24h dismissal cooldown
  final VoidCallback onDismissSuggestion;

  /// check-in mode: user still in crisis, register the check-in
  /// (increments promptCount, updates lastPromptAt)
  final VoidCallback onCheckInContinue;

  /// check-in mode: user says they're better, exit flare mode
  final VoidCallback onCheckInBetter;

  const FlareSuggestionBanner({
    super.key,
    required this.profile,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onAcceptSuggestion,
    required this.onDismissSuggestion,
    required this.onCheckInContinue,
    required this.onCheckInBetter,
  });

  @override
  Widget build(BuildContext context) {
    final mode = _decideMode();
    if (mode == _Mode.none) return const SizedBox.shrink();
    if (mode == _Mode.checkIn) return _buildCheckIn(context);
    return _buildSuggest(context);
  }

  _Mode _decideMode() {
    final flare = profile.state.flare;

    // Check-in mode: in flare + 48h+ since start or last prompt
    if (flare != null && flare.isPromptDue) {
      return _Mode.checkIn;
    }

    // Suggest mode: not in flare + not in cooldown + heuristics fire
    if (flare == null && !profile.state.isSuggestionInCooldown) {
      final result = detectFlarePattern(profile);
      if (result.suggested) return _Mode.suggest;
    }

    return _Mode.none;
  }

  // ============================================================
  // Suggest mode UI
  // ============================================================

  Widget _buildSuggest(BuildContext context) {
    final result = detectFlarePattern(profile);
    final cc = contrastColor;
    final ic = inverseContrastColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cc.withValues(alpha: 0.05),
          border: Border.all(color: cc.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: cc, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¿Estás pasando un mal día?',
                    style: TextStyle(
                      color: cc,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...result.triggeredRules.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(left: 30, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: cc.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _ruleText(rule),
                        style: TextStyle(
                          color: cc.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                'Modo crisis oculta las sugerencias opcionales y marca '
                'el día como descanso.',
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cc.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onDismissSuggestion,
                    child: Text(
                      'No, gracias',
                      style: TextStyle(color: cc.withValues(alpha: 0.75)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cc,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onAcceptSuggestion,
                    child: Text(
                      'Activar modo crisis',
                      style: TextStyle(color: ic, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Check-in mode UI
  // ============================================================

  Widget _buildCheckIn(BuildContext context) {
    final flare = profile.state.flare!;
    final cc = contrastColor;
    final ic = inverseContrastColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cc.withValues(alpha: 0.08),
          border: Border.all(color: cc),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.access_time, color: cc, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estás en modo crisis desde hace '
                        '${_formatDuration(flare.duration)}',
                        style: TextStyle(
                          color: cc,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¿Cómo estás?',
                        style: TextStyle(
                          color: cc.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cc),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onCheckInContinue,
                    child: Text('Sigo mal', style: TextStyle(color: cc)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cc,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onCheckInBetter,
                    child: Text(
                      'Ya estoy mejor',
                      style: TextStyle(color: ic, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Helpers
  // ============================================================

  String _ruleText(FlareRule rule) => switch (rule) {
    FlareRule.severeSymptomAccumulation =>
      'Notamos varios síntomas intensos en las últimas 24 horas.',
    FlareRule.mcasRedFlagRecent =>
      'Registraste señales de alerta MCAS recientemente.',
    FlareRule.pemPattern =>
      'Posible PEM: movimiento hace 1-3 días + fatiga intensa hoy.',
  };

  String _formatDuration(Duration d) {
    if (d.inMinutes < 60) {
      final m = d.inMinutes < 1 ? 1 : d.inMinutes;
      return '$m ${m == 1 ? "minuto" : "minutos"}';
    }
    if (d.inHours < 24) {
      final h = d.inHours;
      return '$h ${h == 1 ? "hora" : "horas"}';
    }
    final days = d.inDays;
    final remainingHours = d.inHours - days * 24;
    if (remainingHours == 0) {
      return '$days ${days == 1 ? "día" : "días"}';
    }
    return '$days ${days == 1 ? "día" : "días"} '
        '$remainingHours ${remainingHours == 1 ? "hora" : "horas"}';
  }
}
