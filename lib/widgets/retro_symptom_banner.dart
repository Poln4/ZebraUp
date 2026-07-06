// Sprint F.E — Retro symptom check-in banner.
//
// Lists SymptomEvent that need a retro check-in. The Hoy tab
// pre-filters the list: age in (30 min, 24 h) AND no matching
// ActionTaken. Empty list → SizedBox.shrink().
//
// Tapping a card triggers onTap(symptom); caller opens the
// RetroSymptomDialog and receives the completed ActionTaken via
// its own onSaveRetroSymptom callback.
//
// Visual language: soft indigo accent. Distinguishes from
// FollowUpBanner (amber, bowel/hem/fever) and _OutcomeAnswerCard
// (red, dose outcomes).

import 'package:flutter/material.dart';
import '../models/models.dart';

class RetroSymptomBanner extends StatelessWidget {
  final List<SymptomEvent> pendingSymptoms;
  final Color contrastColor;
  final Color inverseContrastColor;
  final void Function(SymptomEvent symptom) onTap;

  const RetroSymptomBanner({
    super.key,
    required this.pendingSymptoms,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onTap,
  });

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return m == 0 ? 'hace $h h' : 'hace $h h $m min';
    }
    return 'hace 1 día';
  }

  @override
  Widget build(BuildContext context) {
    if (pendingSymptoms.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          for (int i = 0; i < pendingSymptoms.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _RetroSymptomCard(
              symptom: pendingSymptoms[i],
              timeAgo: _timeAgo(pendingSymptoms[i].timestamp),
              severityBefore: pendingSymptoms[i].severity.value,
              contrastColor: contrastColor,
              inverseContrastColor: inverseContrastColor,
              onTap: () => onTap(pendingSymptoms[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _RetroSymptomCard extends StatelessWidget {
  final SymptomEvent symptom;
  final String timeAgo;
  final int severityBefore;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onTap;

  const _RetroSymptomCard({
    required this.symptom,
    required this.timeAgo,
    required this.severityBefore,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registrado $timeAgo · nivel $severityBefore',
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.65),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    symptom.name,
                    style: TextStyle(
                      color: cc,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¿Qué tal ahora?',
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.85),
                      fontSize: 13,
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
                'Responder',
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
