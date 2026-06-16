// =============================================================================
// ReportTrendsService — period aggregations for the clinical report.
//
// Called by main_screen.dart's _buildReportPlainText when the report range
// is greater than a single day. Returns a ReportTrends bundle that the
// emitter formats into plain text.
//
// Aggregations:
//   - Symptom trends: per symptom name, count of distinct days with at
//     least one entry, plus the worst severity recorded (excluding
//     "Ninguna" — the unrated sentinel — when computing worst).
//   - Dose counts by medication name.
//   - Fever episodes that overlap the range (using FeverAnalysis.detectEpisodes
//     over the full history, then filtered).
//   - Total distinct feverish-day count across all overlapping episodes
//     (clipped to the range).
//   - Average mental severity per MentalState.
//   - Structural event counts by zone.
//
// Notes:
//   - "Day" boundaries use local midnight (start-of-day).
//   - "Days appeared" for symptoms uses distinct yyyy-mm-dd of the timestamp
//     — multiple entries on the same day count once.
//   - Iterates with the existing getXxxForDay helpers on Profile to stay
//     decoupled from internal history field names.
// =============================================================================

import '../models/models.dart';
import 'fever_analysis.dart';

/// One symptom row in the trends section.
class SymptomTrend {
  final String name;
  final int daysAppeared;

  /// Worst severity recorded across the period. If every entry was
  /// unrated (SymptomSeverity.none), this is SymptomSeverity.none too;
  /// the emitter renders that case as "(sin rating)" instead of a label.
  final SymptomSeverity worstSeverity;

  /// True if all entries for this symptom were unrated.
  final bool allUnrated;

  const SymptomTrend({
    required this.name,
    required this.daysAppeared,
    required this.worstSeverity,
    required this.allUnrated,
  });
}

/// Bundle of period aggregations.
class ReportTrends {
  final List<SymptomTrend> symptoms;
  final Map<String, int> doseCountsByMed;
  final List<FeverEpisode> feverEpisodes;
  final int feverishDayCount;
  final Map<MentalState, double> mentalAvgByState;
  final Map<String, int> structuralCountsByZone;
  final int dayCount;

  const ReportTrends({
    required this.symptoms,
    required this.doseCountsByMed,
    required this.feverEpisodes,
    required this.feverishDayCount,
    required this.mentalAvgByState,
    required this.structuralCountsByZone,
    required this.dayCount,
  });

  /// True when every sub-bucket is empty. Caller uses this to suppress
  /// the TENDENCIAS section header entirely.
  bool get isEmpty =>
      symptoms.isEmpty &&
      doseCountsByMed.isEmpty &&
      feverEpisodes.isEmpty &&
      mentalAvgByState.isEmpty &&
      structuralCountsByZone.isEmpty;
}

class ReportTrendsService {
  /// Computes all period aggregations over [start..end] inclusive.
  ///
  /// Both bounds are interpreted in local time and normalized to
  /// start-of-day before iteration.
  static ReportTrends compute(Profile profile, DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    final dayCount = e.difference(s).inDays + 1;

    // Per-day accumulation buckets
    final symptomsByName = <String, List<SymptomEvent>>{};
    final doseCountsByMed = <String, int>{};
    final structuralCountsByZone = <String, int>{};
    final mentalByState = <MentalState, List<int>>{};

    for (int i = 0; i < dayCount; i++) {
      final day = s.add(Duration(days: i));

      for (final sym in profile.getSymptomsForDay(day)) {
        symptomsByName.putIfAbsent(sym.name, () => []).add(sym);
      }
      for (final dose in profile.getDosesForDay(day)) {
        doseCountsByMed[dose.medicationName] =
            (doseCountsByMed[dose.medicationName] ?? 0) + 1;
      }
      for (final ev in profile.getStructuralForDay(day)) {
        structuralCountsByZone[ev.zone] =
            (structuralCountsByZone[ev.zone] ?? 0) + 1;
      }
      for (final m in profile.getMentalForDay(day)) {
        mentalByState.putIfAbsent(m.state, () => []).add(m.severity);
      }
    }

    // Reduce symptoms: distinct days + worst severity (ignoring unrated
    // entries when computing the worst).
    final symptoms = <SymptomTrend>[];
    symptomsByName.forEach((name, list) {
      final dayKeys = list
          .map((sym) =>
              '${sym.timestamp.year}-${sym.timestamp.month}-${sym.timestamp.day}')
          .toSet();
      final ratedList =
          list.where((sym) => sym.severity != SymptomSeverity.none).toList();
      if (ratedList.isEmpty) {
        symptoms.add(SymptomTrend(
          name: name,
          daysAppeared: dayKeys.length,
          worstSeverity: SymptomSeverity.none,
          allUnrated: true,
        ));
      } else {
        final worstSym = ratedList.reduce(
            (a, b) => a.severity.index >= b.severity.index ? a : b);
        symptoms.add(SymptomTrend(
          name: name,
          daysAppeared: dayKeys.length,
          worstSeverity: worstSym.severity,
          allUnrated: false,
        ));
      }
    });
    // Sort: most-days first; tiebreak by worst severity desc.
    symptoms.sort((a, b) {
      final byDays = b.daysAppeared.compareTo(a.daysAppeared);
      if (byDays != 0) return byDays;
      return b.worstSeverity.index.compareTo(a.worstSeverity.index);
    });

    // Reduce mental: averages, skipping any state with no data.
    final mentalAvg = <MentalState, double>{};
    mentalByState.forEach((k, v) {
      if (v.isNotEmpty) {
        mentalAvg[k] = v.reduce((a, b) => a + b) / v.length;
      }
    });

    // Fever episodes that overlap the range, plus distinct feverish-day count
    // (each episode contributes the days it spans, clipped to range).
    final allEpisodes = FeverAnalysis.detectEpisodes(profile.feverHistory);
    final periodEndExcl = e.add(const Duration(days: 1));
    final feverEpisodes = allEpisodes
        .where((ep) =>
            ep.start.isBefore(periodEndExcl) && !ep.end.isBefore(s))
        .toList();

    final feverishDays = <String>{};
    for (final ep in feverEpisodes) {
      final epStart = ep.start.isBefore(s) ? s : ep.start;
      final epEnd = ep.end.isAfter(e) ? e : ep.end;
      final epStartDay =
          DateTime(epStart.year, epStart.month, epStart.day);
      final epEndDay = DateTime(epEnd.year, epEnd.month, epEnd.day);
      final epDays = epEndDay.difference(epStartDay).inDays + 1;
      for (int j = 0; j < epDays; j++) {
        final d = epStartDay.add(Duration(days: j));
        feverishDays.add('${d.year}-${d.month}-${d.day}');
      }
    }

    return ReportTrends(
      symptoms: symptoms,
      doseCountsByMed: doseCountsByMed,
      feverEpisodes: feverEpisodes,
      feverishDayCount: feverishDays.length,
      mentalAvgByState: mentalAvg,
      structuralCountsByZone: structuralCountsByZone,
      dayCount: dayCount,
    );
  }
}
