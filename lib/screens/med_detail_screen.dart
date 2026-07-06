// Sprint T0 — Med detail screen.
//
// Full-page navigation destination reached by long-pressing a med
// card in the Botiquín tab. Shows:
//
//   • Header with med name + close button
//   • Efectividad section (scorecard):
//       - total uses count
//       - small-sample warning if N < 5
//       - rating distribution bars (contrast palette)
//       - best-fit indication (if any positive-outcome symptom)
//       - last used relative time
//   • Empty state when no ActionTaken references this med
//
// Colors follow the F.E2 contrast-only palette. No accent colors.

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/action_taken.dart';
import '../services/action_analytics.dart';

class MedDetailScreen extends StatelessWidget {
  final MedicationDef med;
  final Profile profile;
  final Color contrastColor;
  final Color inverseContrastColor;

  const MedDetailScreen({
    super.key,
    required this.med,
    required this.profile,
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  static const _ratingLabels = {
    EffectivenessRating.muchRelief: 'Mucho alivio',
    EffectivenessRating.someRelief: 'Algo de alivio',
    EffectivenessRating.partialReliefThenReturned:
        'Alivio parcial (que volvió)',
    EffectivenessRating.noChange: 'Sin cambio',
    EffectivenessRating.worse: 'Empeoró',
  };

  static const _ratingOrder = [
    EffectivenessRating.muchRelief,
    EffectivenessRating.someRelief,
    EffectivenessRating.partialReliefThenReturned,
    EffectivenessRating.noChange,
    EffectivenessRating.worse,
  ];

  String _relativeTime(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return h == 1 ? 'hace 1 h' : 'hace $h h';
    }
    final d = diff.inDays;
    if (d == 1) return 'ayer';
    if (d < 7) return 'hace $d días';
    if (d < 30) {
      final w = (d / 7).floor();
      return w == 1 ? 'hace 1 semana' : 'hace $w semanas';
    }
    final m = (d / 30).floor();
    return m == 1 ? 'hace 1 mes' : 'hace $m meses';
  }

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final ic = inverseContrastColor;
    final stats = scorecardFor(med.id, profile);

    return Scaffold(
      backgroundColor: ic,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      med.name,
                      style: TextStyle(
                        color: cc,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: cc),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section: Efectividad
                    Text(
                      'EFECTIVIDAD',
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.55),
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (stats.hasNoData)
                      _emptyState(cc)
                    else
                      _scorecard(cc, ic, stats),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(Color cc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: cc.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Sin registros de uso todavía. Cuando registres una dosis y '
        'respondas el seguimiento en Hoy, van a aparecer aquí los '
        'patrones de efectividad.',
        style: TextStyle(
          color: cc.withValues(alpha: 0.7),
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _scorecard(Color cc, Color ic, MedScorecardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total uses + optional small-sample caveat
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cc.withValues(alpha: 0.03),
            border: Border.all(color: cc.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${stats.totalUses}',
                    style: TextStyle(
                      color: cc,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      stats.totalUses == 1
                          ? 'uso registrado'
                          : 'usos registrados',
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              if (stats.isSmallSample) ...[
                const SizedBox(height: 8),
                Text(
                  'Muestra pequeña. Los patrones cobran claridad con '
                  'más registros.',
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (stats.lastUsedAt != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Último uso: ${_relativeTime(stats.lastUsedAt!)}',
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Rating distribution (only if we have any ratings)
        if (stats.ratedCount > 0) ...[
          const SizedBox(height: 16),
          Text(
            'RESULTADOS',
            style: TextStyle(
              color: cc.withValues(alpha: 0.55),
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._ratingOrder.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _ratingBar(cc, ic, r, stats),
            ),
          ),
        ],

        // Best-fit indication
        if (stats.bestFitSymptom != null && stats.bestFitCount > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: cc.withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: cc, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: cc, fontSize: 13),
                      children: [
                        const TextSpan(text: 'Mejor efecto con '),
                        TextSpan(
                          text: stats.bestFitSymptom,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              ' (${stats.bestFitCount} '
                              '${stats.bestFitCount == 1 ? "vez" : "veces"})',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _ratingBar(
    Color cc,
    Color ic,
    EffectivenessRating rating,
    MedScorecardStats stats,
  ) {
    final count = stats.countFor(rating);
    final total = stats.ratedCount;
    final ratio = total > 0 ? count / total : 0.0;
    final label = _ratingLabels[rating] ?? rating.serializationKey;

    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(color: cc.withValues(alpha: 0.85), fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              border: Border.all(color: cc.withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: cc.withValues(alpha: count > 0 ? 0.7 : 0.0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: count > 0 ? cc : cc.withValues(alpha: 0.35),
              fontSize: 12,
              fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
