// Sprint F.D — Follow-up reminder banner.
//
// Renders one card per ActionTaken whose follow-up window has elapsed
// (followUpIsDue == true). Empty list → SizedBox.shrink().
//
// Tapping a card triggers onTap(action); the caller is responsible
// for opening the ActionEffectivenessDialog and passing the updated
// ActionTaken back up through onCompleteFollowUp.
//
// Visual language: soft amber accent, mirrors _OutcomeAnswerCard's
// pattern (soft red) but distinguishes the two subsystems visually.
// Once F.E+F unifies the two flows, this palette becomes the single
// "pending review" color.
//
// UI copy: hardcoded ES tuteo neutro. Migration to l10n happens in F.E+F.

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/action_taken.dart';

class FollowUpBanner extends StatelessWidget {
  final List<ActionTaken> pendingActions;
  final List<MedicationDef> botiquin;
  final Color contrastColor;
  final Color inverseContrastColor;
  final void Function(ActionTaken action) onTap;

  const FollowUpBanner({
    super.key,
    required this.pendingActions,
    required this.botiquin,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onTap,
  });

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

  String _describe(ActionTaken a) {
    final base = _kindLabels[a.kind] ?? a.kind.serializationKey;
    if (a.kind == ActionKind.medication && a.medicationRefId != null) {
      final matches = botiquin.where((m) => m.id == a.medicationRefId);
      if (matches.isNotEmpty) return '$base: ${matches.first.name}';
    }
    if (a.kind == ActionKind.custom && a.customLabel != null) {
      return '$base: ${a.customLabel}';
    }
    return base;
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return m == 0 ? 'hace $h h' : 'hace $h h $m min';
    }
    final d = diff.inDays;
    return d == 1 ? 'hace 1 día' : 'hace $d días';
  }

  @override
  Widget build(BuildContext context) {
    if (pendingActions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          for (int i = 0; i < pendingActions.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _FollowUpCard(
              action: pendingActions[i],
              description: _describe(pendingActions[i]),
              emoji: _kindEmojis[pendingActions[i].kind] ?? '•',
              timeAgo: _timeAgo(pendingActions[i].timestamp),
              contrastColor: contrastColor,
              inverseContrastColor: inverseContrastColor,
              onTap: () => onTap(pendingActions[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  final ActionTaken action;
  final String description;
  final String emoji;
  final String timeAgo;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onTap;

  const _FollowUpCard({
    required this.action,
    required this.description,
    required this.emoji,
    required this.timeAgo,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final ic = inverseContrastColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cc.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cc.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Cómo te fue con…?',
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.75),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: cc,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.65),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cc,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Revisar',
                style: TextStyle(
                  color: ic,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
