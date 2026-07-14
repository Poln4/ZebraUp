// =============================================================================
// report_charts.dart — fl_chart-based visualizations for the Reporte view.
//
// Isolates the fl_chart dependency to this one file. Color discipline: no
// new accent hues — the app's established "contrast-only, no accent
// colors" rule (med_detail_screen.dart, pdf_export_sheet.dart) extends
// here by differentiating multi-line data with dash pattern + alpha
// instead of hue. See docs/report_view_redesign.md for the fuller
// rationale and docs/report_charts.md for this file's.
//
// Gaps in the underlying data (a day with no entry) are NOT filled with
// zeros — see report_time_series.dart. The line charts below connect
// whatever points exist using each point's true day-offset as its X
// coordinate, so gaps still show up as a longer horizontal jump rather
// than being hidden — just not as a visually broken/dashed segment.
//
// fl_chart API note: written against the well-established LineChart/
// BarChart shape (stable across fl_chart's 0.6x-1.x history), but the
// exact installed version wasn't verified against live docs — no local
// Flutter toolchain this session. Check against the actual resolved
// version (`flutter pub get`) before trusting this compiles as-is.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/report_time_series.dart';

/// Line chart of daily worst rated severity (0-4) for up to 3 symptoms.
class SeverityOverTimeChart extends StatelessWidget {
  final Map<String, List<SeriesPoint>> severityBySymptom;
  final DateTime rangeStart;
  final Color contrastColor;

  const SeverityOverTimeChart({
    super.key,
    required this.severityBySymptom,
    required this.rangeStart,
    required this.contrastColor,
  });

  static const List<List<int>?> _dashPatterns = [null, [6, 3], [1, 2]];
  static const List<double> _alphas = [1.0, 0.7, 0.5];

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final entries = severityBySymptom.entries
        .where((e) => e.value.isNotEmpty)
        .take(3)
        .toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    final lines = <LineChartBarData>[];
    for (var i = 0; i < entries.length; i++) {
      final spots = entries[i].value
          .map(
            (p) => FlSpot(
              p.day.difference(rangeStart).inDays.toDouble(),
              p.value,
            ),
          )
          .toList();
      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: cc.withValues(alpha: _alphas[i]),
          barWidth: 2,
          dashArray: _dashPatterns[i],
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 4,
              lineBarsData: lines,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: cc.withValues(alpha: 0.08),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(),
                rightTitles: AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.5),
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTitlesWidget: (value, meta) {
                      final day = rangeStart.add(
                        Duration(days: value.toInt()),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${day.day}/${day.month}',
                          style: TextStyle(
                            color: cc.withValues(alpha: 0.5),
                            fontSize: 8,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(enabled: false),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (var i = 0; i < entries.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 2,
                    color: cc.withValues(alpha: _alphas[i]),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entries[i].key,
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Bar chart of symptom frequency (days appeared) — reuses already-
/// computed ReportTrends.symptoms data, no new aggregation needed.
class FrequencyBarChart extends StatelessWidget {
  /// name -> days appeared, already sorted/truncated by the caller.
  final List<MapEntry<String, int>> topSymptoms;
  final Color contrastColor;

  const FrequencyBarChart({
    super.key,
    required this.topSymptoms,
    required this.contrastColor,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    if (topSymptoms.isEmpty) return const SizedBox.shrink();
    final maxValue = topSymptoms
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxValue + 1,
          barGroups: [
            for (var i = 0; i < topSymptoms.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: topSymptoms[i].value.toDouble(),
                    color: cc.withValues(alpha: 0.75),
                    width: 16,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: cc.withValues(alpha: 0.08), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(),
            rightTitles: AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.5),
                    fontSize: 9,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= topSymptoms.length) {
                    return const SizedBox.shrink();
                  }
                  final name = topSymptoms[idx].key;
                  final short = name.length > 8
                      ? '${name.substring(0, 7)}…'
                      : name;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      short,
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.6),
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(enabled: false),
        ),
      ),
    );
  }
}

/// Line chart of daily mean mood valence (-1..1), with a zero reference
/// line so pleasant/unpleasant is visually legible without color.
class MoodOverTimeChart extends StatelessWidget {
  final List<SeriesPoint> dailyMoodValence;
  final DateTime rangeStart;
  final Color contrastColor;

  const MoodOverTimeChart({
    super.key,
    required this.dailyMoodValence,
    required this.rangeStart,
    required this.contrastColor,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    if (dailyMoodValence.isEmpty) return const SizedBox.shrink();

    final spots = dailyMoodValence
        .map(
          (p) => FlSpot(
            p.day.difference(rangeStart).inDays.toDouble(),
            p.value,
          ),
        )
        .toList();

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          minY: -1,
          maxY: 1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: cc.withValues(alpha: 0.85),
              barWidth: 2,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 0,
                color: cc.withValues(alpha: 0.3),
                strokeWidth: 1,
                dashArray: const [4, 4],
              ),
            ],
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: cc.withValues(alpha: 0.06), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(),
            rightTitles: AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final label = value == 1
                      ? 'bienestar'
                      : value == -1
                      ? 'malestar'
                      : '';
                  return Text(
                    label,
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.5),
                      fontSize: 8,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  final day = rangeStart.add(Duration(days: value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${day.day}/${day.month}',
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.5),
                        fontSize: 8,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
