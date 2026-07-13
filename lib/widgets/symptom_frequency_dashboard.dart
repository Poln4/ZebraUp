// Sprint T0.3 — Symptom frequency dashboard.
//
// Rolling 30-day view of the user's most-frequent symptoms with
// sparklines. Placed in the Síntomas tab between the "En tendencia"
// (7-day chips) section and the "Baúl de síntomas" vault.
//
// Sparklines use per-row normalization: each row's bars scale to
// that row's max count. Low-count symptoms remain visible next to
// high-count ones. Days with zero events render as thin baseline
// marks so the temporal grid remains legible.
//
// Contrast palette only (F.E2 constraint). Zero external chart
// dependencies — pure CustomPaint.

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/action_analytics.dart';

class SymptomFrequencyDashboard extends StatelessWidget {
  final Profile profile;
  final Color contrastColor;
  final int windowDays;
  final int topN;

  const SymptomFrequencyDashboard({
    super.key,
    required this.profile,
    required this.contrastColor,
    this.windowDays = 30,
    this.topN = 10,
  });

  @override
  Widget build(BuildContext context) {
    final stats = symptomFrequencyStats(
      profile,
      windowDays: windowDays,
      topN: topN,
    );
    if (stats.isEmpty) return const SizedBox.shrink();

    final cc = contrastColor;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cc.withValues(alpha: 0.03),
          border: Border.all(color: cc.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'FRECUENCIA',
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.55),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· últimos $windowDays días',
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.45),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...stats.map((s) => _FrequencyRow(stats: s, contrastColor: cc)),
          ],
        ),
      ),
    );
  }
}

class _FrequencyRow extends StatelessWidget {
  final SymptomFrequencyStats stats;
  final Color contrastColor;

  const _FrequencyRow({required this.stats, required this.contrastColor});

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              stats.name,
              style: TextStyle(color: cc, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '${stats.totalCount}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: cc,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            height: 18,
            child: CustomPaint(
              painter: _SparklinePainter(counts: stats.dailyCounts, color: cc),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> counts;
  final Color color;

  _SparklinePainter({required this.counts, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (counts.isEmpty) return;
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) return;

    final barCount = counts.length;
    final slot = size.width / barCount;
    final barW = slot * 0.75;
    final gap = slot * 0.25;

    final activePaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final zeroPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final count = counts[i];
      final x = i * slot + gap / 2;
      if (count == 0) {
        canvas.drawRect(Rect.fromLTWH(x, size.height - 1, barW, 1), zeroPaint);
      } else {
        final h = (count / maxCount) * size.height;
        canvas.drawRect(
          Rect.fromLTWH(x, size.height - h, barW, h),
          activePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) => true;
}
