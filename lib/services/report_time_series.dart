// =============================================================================
// ReportTimeSeriesService — day-by-day series for the Reporte view's charts.
//
// ReportTrends (report_trends.dart) only carries period-level aggregates
// (worst severity, total days appeared) — nothing day-by-day, which is
// what a line chart needs. This is a separate, additive computation so
// report_trends.dart (just fixed a regression there this same session)
// stays untouched.
//
// Gaps are gaps: a day with no entry for a symptom/mood is simply absent
// from that series, not recorded as zero — a missing day and "severity 0"
// mean different things and shouldn't be conflated on a chart.
// =============================================================================

import '../models/models.dart';

class SeriesPoint {
  final DateTime day;
  final double value;

  const SeriesPoint({required this.day, required this.value});
}

class ReportTimeSeries {
  /// One series per requested symptom name — that day's worst rated
  /// severity (0-4), only for days the symptom was actually logged with
  /// a rating (unrated entries are skipped, same as
  /// ReportTrends.symptoms' "worst severity" computation).
  final Map<String, List<SeriesPoint>> severityBySymptom;

  /// Daily mean mood valence (-1..1, pleasant=+1/unpleasant=-1 per
  /// MoodQuadrant.valenceSign), only for days with mood entries.
  final List<SeriesPoint> dailyMoodValence;

  const ReportTimeSeries({
    required this.severityBySymptom,
    required this.dailyMoodValence,
  });

  bool get isEmpty =>
      severityBySymptom.values.every((s) => s.isEmpty) &&
      dailyMoodValence.isEmpty;
}

class ReportTimeSeriesService {
  /// Computes day-by-day series over [start..end] inclusive for the
  /// given [topSymptomNames] (caller passes e.g. the top 3 names from
  /// ReportTrends.symptoms) plus daily mood valence.
  static ReportTimeSeries compute(
    Profile profile,
    DateTime start,
    DateTime end, {
    required List<String> topSymptomNames,
  }) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    final dayCount = e.difference(s).inDays + 1;

    final severityBySymptom = <String, List<SeriesPoint>>{
      for (final name in topSymptomNames) name: <SeriesPoint>[],
    };
    final dailyMoodValence = <SeriesPoint>[];

    for (int i = 0; i < dayCount; i++) {
      final day = s.add(Duration(days: i));

      if (topSymptomNames.isNotEmpty) {
        final daySymptoms = profile.getSymptomsForDay(day);
        for (final name in topSymptomNames) {
          final matches = daySymptoms
              .where(
                (sym) =>
                    sym.name == name && sym.severity != SymptomSeverity.none,
              )
              .toList();
          if (matches.isEmpty) continue;
          final worst = matches.reduce(
            (a, b) => a.severity.index >= b.severity.index ? a : b,
          );
          severityBySymptom[name]!.add(
            SeriesPoint(day: day, value: worst.severity.value.toDouble()),
          );
        }
      }

      final dayMoods = profile.getMoodForDay(day);
      if (dayMoods.isNotEmpty) {
        final sum = dayMoods.fold<double>(
          0,
          (acc, m) => acc + m.primaryQuadrant.valenceSign,
        );
        dailyMoodValence.add(
          SeriesPoint(day: day, value: sum / dayMoods.length),
        );
      }
    }

    return ReportTimeSeries(
      severityBySymptom: severityBySymptom,
      dailyMoodValence: dailyMoodValence,
    );
  }
}
