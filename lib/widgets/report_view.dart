// =============================================================================
// ReportView — structured, collapsible replacement for the plain-text
// Reporte tab.
//
// Before: main_screen.dart's _buildReportContent rendered one giant
// SelectableText block (Courier monospace) built by _buildReportPlainText —
// every domain (symptoms, medications, fever, structural, mental, mood,
// detected patterns, effectiveness) flattened into a single TENDENCIAS:
// section with no hierarchy, no collapsing, no truncation. For a long
// history this is a wall of text — exactly the cognitive-load problem this
// widget exists to fix.
//
// _buildReportPlainText() itself is UNCHANGED — it's still what "Copiar al
// portapapeles" copies. This widget is a second, independent presentation
// of the same underlying data (ReportTrendsService + the same Profile
// getters), not a replacement for the text export.
//
// Structure splits on range length (2026-07-15 revision — the original
// version only showed the bare "today" snapshot for a single day and
// nothing else for short ranges, which was too thin):
//   - Short ranges (<=7 days, the día/semana presets): trend charts
//     aren't meaningful with so few data points, so _PeriodLog shows a
//     detailed day-by-day log instead (symptoms, doses, fever, mental,
//     mood, structural — everything _buildReportPlainText used to show
//     for a single day, generalized to N days).
//   - Longer ranges: the aggregated Resumen card + one CollapsibleSection
//     (lib/widgets/collapsible_section.dart — reused as-is, already the
//     pattern used for this exact purpose in Síntomas tab) per domain,
//     with charts. Most sections start collapsed; Fiebre and Patrones
//     detectados start expanded since they're worth seeing without a tap.
// Efectividad is all-time (not period-scoped) and always shows in both
// modes when there's data.
//
// Color discipline: contrast-only (cc), no new accent palette — matches
// the rule already codified in med_detail_screen.dart and
// pdf_export_sheet.dart ("F.E2 contrast-only palette. No accent colors").
// The one reused exception is the existing urgent-red precedent
// (botiquin_tab.dart's _InteractionList, pdf_report_renderer.dart's
// _kUrgentColor) for an active fever episode — not a new color.
//
// Mood/Estado mental/Estructural sections respect the persistent
// report_show_mood / report_show_mental / report_show_structural flags in
// profile.settings.optionalTrackers (see tracking_settings_screen.dart),
// defaulting to visible.
// =============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/report_trends.dart';
import '../services/report_time_series.dart';
import '../services/fever_analysis.dart';
import '../services/clinical_localizations.dart';
import '../services/structural_taxonomy.dart';
import '../l10n/app_localizations.dart';
import 'collapsible_section.dart';
import 'report_charts.dart';

const _kUrgentColor = Color(0xFFE57373);

class ReportView extends StatelessWidget {
  final Profile profile;
  final DateTime selectedDate;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final Color contrastColor;

  const ReportView({
    super.key,
    required this.profile,
    required this.selectedDate,
    required this.rangeStart,
    required this.rangeEnd,
    required this.contrastColor,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final s = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
    final e = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
    final rangeDayCount = e.difference(s).inDays + 1;

    // Trend charts aren't meaningful with only a handful of data points
    // (día/semana presets) — show a detailed day-by-day log instead. See
    // the file header comment for the full rationale.
    final isShortRange = rangeDayCount <= 7;
    final trends = !isShortRange
        ? ReportTrendsService.compute(profile, rangeStart, rangeEnd)
        : null;
    // Charts need day-by-day data ReportTrends doesn't carry — see
    // report_time_series.dart. Top 3 symptoms by the same sort ReportTrends
    // already uses (most-days-first).
    final timeSeries = trends != null && trends.symptoms.isNotEmpty
        ? ReportTimeSeriesService.compute(
            profile,
            rangeStart,
            rangeEnd,
            topSymptomNames: trends.symptoms
                .take(3)
                .map((t) => t.name)
                .toList(),
          )
        : null;

    final tracked = profile.settings.optionalTrackers;
    final showMood = tracked['report_show_mood'] ?? true;
    final showMental = tracked['report_show_mental'] ?? true;
    final showStructural = tracked['report_show_structural'] ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isShortRange)
          _PeriodLog(
            profile: profile,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd,
            contrastColor: cc,
          )
        else
          _TodaySnapshot(
            symptoms: profile.getSymptomsForDay(selectedDate),
            doseCounts: _doseCountsFor(profile, selectedDate),
            contrastColor: cc,
          ),
        if (trends != null && !trends.isEmpty) ...[
          const SizedBox(height: 12),
          _SummaryCard(trends: trends, contrastColor: cc),
          const SizedBox(height: 12),
          if (trends.symptoms.isNotEmpty) ...[
            _SymptomsSection(
              trends: trends,
              timeSeries: timeSeries,
              rangeStart: rangeStart,
              contrastColor: cc,
            ),
            const SizedBox(height: 4),
          ],
          if (trends.doseCountsByMed.isNotEmpty) ...[
            _MedsSection(trends: trends, contrastColor: cc),
            const SizedBox(height: 4),
          ],
          if (trends.feverEpisodes.isNotEmpty) ...[
            _FeverSection(trends: trends, contrastColor: cc),
            const SizedBox(height: 4),
          ],
          if (showStructural && trends.structuralCountsByZone.isNotEmpty) ...[
            _StructuralSection(trends: trends, contrastColor: cc),
            const SizedBox(height: 4),
          ],
          if ((showMental && trends.mentalAvgByState.isNotEmpty) ||
              (showMood && trends.totalMoodEntries > 0)) ...[
            _MentalMoodSection(
              trends: trends,
              timeSeries: timeSeries,
              rangeStart: rangeStart,
              showMood: showMood,
              showMental: showMental,
              contrastColor: cc,
            ),
            const SizedBox(height: 4),
          ],
          if (trends.detectedPatterns.isNotEmpty) ...[
            _PatternsSection(trends: trends, contrastColor: cc),
            const SizedBox(height: 4),
          ],
        ],
        const SizedBox(height: 4),
        // All-time, not period-scoped — shows in both short and long
        // range modes (internally returns nothing if there's no data).
        _EffectivenessSection(profile: profile, contrastColor: cc),
      ],
    );
  }
}

Map<String, int> _doseCountsFor(Profile profile, DateTime day) {
  final counts = <String, int>{};
  for (final d in profile.getDosesForDay(day)) {
    counts[d.medicationName] = (counts[d.medicationName] ?? 0) + 1;
  }
  return counts;
}

/// Shared "label — value" row used by every section below.
Widget _row(Color cc, String left, String right, {bool urgent = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              color: urgent ? _kUrgentColor : cc,
              fontSize: 13,
              fontWeight: urgent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          right,
          style: TextStyle(
            color: urgent ? _kUrgentColor : cc.withValues(alpha: 0.65),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// =============================================================================
// Period log — short-range (<=7 days) mode. Shows every symptom, dose,
// fever reading, mental entry, mood entry and structural event day by
// day, most recent day first. No charts/aggregation here on purpose —
// with so few days, individual events are more legible than a trend.
// Days with nothing logged are skipped entirely (no empty day blocks).
// =============================================================================

class _PeriodLog extends StatelessWidget {
  final Profile profile;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final Color contrastColor;

  const _PeriodLog({
    required this.profile,
    required this.rangeStart,
    required this.rangeEnd,
    required this.contrastColor,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final l10n = AppLocalizations.of(context)!;
    final s = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
    final e = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
    final dayCount = e.difference(s).inDays + 1;

    final dayBlocks = <Widget>[];
    for (var i = 0; i < dayCount; i++) {
      final day = s.add(Duration(days: i));
      final block = _buildDayBlock(cc, l10n, day);
      if (block != null) dayBlocks.add(block);
    }

    if (dayBlocks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cc.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cc.withValues(alpha: 0.12)),
        ),
        child: Text(
          'Sin registros en este período.',
          style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 13),
        ),
      );
    }

    final ordered = dayBlocks.reversed.toList(); // most recent day first
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < ordered.length; i++) ...[
          ordered[i],
          if (i != ordered.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget? _buildDayBlock(Color cc, AppLocalizations l10n, DateTime day) {
    final symptoms = profile.getSymptomsForDay(day);
    final doses = profile.getDosesForDay(day);
    final fever = profile.getFeverForDay(day);
    final mental = profile.getMentalForDay(day);
    final moods = profile.getMoodForDay(day);
    final structural = profile.getStructuralForDay(day);

    if (symptoms.isEmpty &&
        doses.isEmpty &&
        fever.isEmpty &&
        mental.isEmpty &&
        moods.isEmpty &&
        structural.isEmpty) {
      return null;
    }

    final symptomGroups = <String, SymptomSeverity>{};
    for (final sym in symptoms) {
      final existing = symptomGroups[sym.name];
      if (existing == null || sym.severity.index > existing.index) {
        symptomGroups[sym.name] = sym.severity;
      }
    }
    final doseCounts = <String, int>{};
    for (final d in doses) {
      doseCounts[d.medicationName] = (doseCounts[d.medicationName] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cc.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cc.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _dayLabel(day),
            style: TextStyle(
              color: cc,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          for (final entry in symptomGroups.entries)
            _row(
              cc,
              entry.key,
              entry.value.severityLabel(l10n).toUpperCase(),
            ),
          for (final entry in doseCounts.entries)
            _row(cc, entry.key, '${entry.value} dosis'),
          for (final r in fever)
            _row(
              cc,
              'Fiebre — ${r.site.label(l10n)}',
              '${r.temperatureC.toStringAsFixed(1)}°C · ${_timeLabel(r.timestamp)}',
              urgent: r.temperatureC >= 38.0,
            ),
          for (final m in mental)
            _row(
              cc,
              m.state.mentalStateLabel(l10n),
              '${m.severity}/5 · ${_timeLabel(m.timestamp)}',
            ),
          for (final mo in moods)
            _row(
              cc,
              mo.notes != null && mo.notes!.isNotEmpty
                  ? '${mo.states.join(', ')} — ${mo.notes}'
                  : mo.states.join(', '),
              _timeLabel(mo.timestamp),
            ),
          for (final ev in structural)
            _row(
              cc,
              '${ev.zone.bodyZoneLabel(l10n)}: ${ev.type.structuralTypeLabel(l10n)}',
              _timeLabel(ev.timestamp),
            ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime day) =>
      '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}';

  String _timeLabel(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// =============================================================================
// Today snapshot — long-range mode's quick "what happened today" block,
// shown alongside the aggregated trend sections below it. Deliberately
// kept simple (just symptoms + doses): the detailed day-by-day view
// lives in _PeriodLog above for short ranges.
// =============================================================================

class _TodaySnapshot extends StatelessWidget {
  final List<SymptomEvent> symptoms;
  final Map<String, int> doseCounts;
  final Color contrastColor;

  const _TodaySnapshot({
    required this.symptoms,
    required this.doseCounts,
    required this.contrastColor,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final l10n = AppLocalizations.of(context)!;
    if (symptoms.isEmpty && doseCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final grouped = <String, SymptomSeverity>{};
    for (final s in symptoms) {
      final existing = grouped[s.name];
      if (existing == null || s.severity.index > existing.index) {
        grouped[s.name] = s.severity;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cc.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cc.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOY',
            style: TextStyle(
              color: cc.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          if (grouped.isEmpty)
            Text(
              'Sin síntomas registrados hoy.',
              style: TextStyle(
                color: cc.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            )
          else
            ...grouped.entries.map(
              (entry) => _row(
                cc,
                entry.key,
                entry.value.severityLabel(l10n).toUpperCase(),
              ),
            ),
          if (doseCounts.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...doseCounts.entries.map(
              (entry) => _row(cc, entry.key, '${entry.value} dosis'),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Resumen — always visible headline card, no collapse. The "read this and
// you're done" layer.
// =============================================================================

class _SummaryCard extends StatelessWidget {
  final ReportTrends trends;
  final Color contrastColor;

  const _SummaryCard({required this.trends, required this.contrastColor});

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final hasFever = trends.feverEpisodes.isNotEmpty;

    final lines = <String>[
      '${trends.dayCount} días · ${trends.symptoms.length} síntomas distintos',
    ];
    if (trends.symptoms.isNotEmpty) {
      final top = trends.symptoms.first;
      lines.add('Más persistente: ${top.name} (${top.daysAppeared} días)');
    }
    if (trends.detectedPatterns.isNotEmpty) {
      final n = trends.detectedPatterns.length;
      lines.add(n == 1 ? '1 patrón detectado' : '$n patrones detectados');
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cc.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFever
              ? _kUrgentColor.withValues(alpha: 0.5)
              : cc.withValues(alpha: 0.15),
          width: hasFever ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMEN',
            style: TextStyle(
              color: cc.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          if (hasFever)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _feverHeadline(trends.feverEpisodes),
                style: TextStyle(
                  color: _kUrgentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(l, style: TextStyle(color: cc, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  String _feverHeadline(List<FeverEpisode> episodes) {
    final peak = episodes
        .map((e) => e.peakTemperatureC)
        .reduce((a, b) => a > b ? a : b);
    final label = episodes.length == 1
        ? '1 episodio de fiebre'
        : '${episodes.length} episodios de fiebre';
    return '$label (pico ${peak.toStringAsFixed(1)}°C)';
  }
}

// =============================================================================
// Reusable "top N + ver más" list, used by Síntomas and Medicamentos.
// =============================================================================

class _TruncatedList extends StatefulWidget {
  final List<Widget> rows;
  final Color contrastColor;
  final String Function(int remaining) moreLabel;
  final int visibleCount;

  const _TruncatedList({
    required this.rows,
    required this.contrastColor,
    required this.moreLabel,
    this.visibleCount = 8,
  });

  @override
  State<_TruncatedList> createState() => _TruncatedListState();
}

class _TruncatedListState extends State<_TruncatedList> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final rows = widget.rows;
    final remaining = rows.length - widget.visibleCount;
    final visible = _showAll ? rows : rows.take(widget.visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visible,
        if (!_showAll && remaining > 0)
          InkWell(
            onTap: () => setState(() => _showAll = true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                widget.moreLabel(remaining),
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Domain sections — each a CollapsibleSection wrapping its own rows.
// =============================================================================

class _SymptomsSection extends StatelessWidget {
  final ReportTrends trends;
  final ReportTimeSeries? timeSeries;
  final DateTime rangeStart;
  final Color contrastColor;

  const _SymptomsSection({
    required this.trends,
    required this.timeSeries,
    required this.rangeStart,
    required this.contrastColor,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final l10n = AppLocalizations.of(context)!;
    final symptoms = trends.symptoms;
    final topLabel = symptoms.isNotEmpty ? symptoms.first.name : '';

    final severityBySymptom = timeSeries?.severityBySymptom ?? const {};
    final hasSeverityChart = severityBySymptom.values.any(
      (points) => points.isNotEmpty,
    );
    final topForBarChart = symptoms
        .take(6)
        .map((t) => MapEntry(t.name, t.daysAppeared))
        .toList();

    return CollapsibleSection(
      title: 'SÍNTOMAS',
      hint: '${symptoms.length} distintos · peor: $topLabel',
      initiallyExpanded: false,
      contrastColor: cc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topForBarChart.isNotEmpty) ...[
            Text(
              'Frecuencia',
              style: TextStyle(
                color: cc.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            FrequencyBarChart(topSymptoms: topForBarChart, contrastColor: cc),
            const SizedBox(height: 12),
          ],
          if (hasSeverityChart) ...[
            Text(
              'Severidad en el tiempo',
              style: TextStyle(
                color: cc.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            SeverityOverTimeChart(
              severityBySymptom: severityBySymptom,
              rangeStart: rangeStart,
              contrastColor: cc,
            ),
            const SizedBox(height: 12),
          ],
          _TruncatedList(
            contrastColor: cc,
            moreLabel: (n) => '+ $n más',
            rows: symptoms.map((t) {
              final severityText = t.allUnrated
                  ? '(sin rating)'
                  : t.worstSeverity.severityLabel(l10n).toUpperCase();
              final dayLabel = t.daysAppeared == 1 ? 'día' : 'días';
              return _row(
                cc,
                t.name,
                '${t.daysAppeared} $dayLabel · $severityText',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MedsSection extends StatelessWidget {
  final ReportTrends trends;
  final Color contrastColor;

  const _MedsSection({required this.trends, required this.contrastColor});

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final sorted = trends.doseCountsByMed.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topLabel = sorted.isNotEmpty ? sorted.first.key : '';

    return CollapsibleSection(
      title: 'MEDICAMENTOS',
      hint: '${sorted.length} usados · más frecuente: $topLabel',
      initiallyExpanded: false,
      contrastColor: cc,
      child: _TruncatedList(
        contrastColor: cc,
        moreLabel: (n) => '+ $n con pocas dosis',
        rows: sorted.map((e) {
          final perDay = (e.value / trends.dayCount).toStringAsFixed(1);
          return _row(cc, e.key, '${e.value} dosis ($perDay/día)');
        }).toList(),
      ),
    );
  }
}

class _FeverSection extends StatelessWidget {
  final ReportTrends trends;
  final Color contrastColor;

  const _FeverSection({required this.trends, required this.contrastColor});

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final episodes = trends.feverEpisodes;
    final episodeLabel = episodes.length == 1 ? 'episodio' : 'episodios';

    return CollapsibleSection(
      title: 'FIEBRE',
      hint:
          '${episodes.length} $episodeLabel · ${trends.feverishDayCount} días',
      // Exception to "collapsed by default": an active/recent fever
      // episode is urgent enough to not start hidden.
      initiallyExpanded: true,
      contrastColor: cc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: episodes.map((ep) {
          final startStr = '${ep.start.day}/${ep.start.month}';
          final endStr = '${ep.end.day}/${ep.end.month}';
          final activeTag = ep.isActive ? ' (activo)' : '';
          return _row(
            cc,
            '$startStr → $endStr$activeTag',
            'pico ${ep.peakTemperatureC.toStringAsFixed(1)}°C',
            urgent: ep.isActive,
          );
        }).toList(),
      ),
    );
  }
}

class _StructuralSection extends StatelessWidget {
  final ReportTrends trends;
  final Color contrastColor;

  const _StructuralSection({
    required this.trends,
    required this.contrastColor,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final l10n = AppLocalizations.of(context)!;
    final sorted = trends.structuralCountsByZone.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topLabel = sorted.isNotEmpty
        ? sorted.first.key.bodyZoneLabel(l10n)
        : '';

    return CollapsibleSection(
      title: 'ESTRUCTURALES',
      hint: '${sorted.length} zonas · más frecuente: $topLabel',
      initiallyExpanded: false,
      contrastColor: cc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sorted.map((e) {
          final evLabel = e.value == 1 ? 'evento' : 'eventos';
          return _row(cc, e.key.bodyZoneLabel(l10n), '${e.value} $evLabel');
        }).toList(),
      ),
    );
  }
}

class _MentalMoodSection extends StatelessWidget {
  final ReportTrends trends;
  final ReportTimeSeries? timeSeries;
  final DateTime rangeStart;
  final bool showMood;
  final bool showMental;
  final Color contrastColor;

  const _MentalMoodSection({
    required this.trends,
    required this.timeSeries,
    required this.rangeStart,
    required this.showMood,
    required this.showMental,
    required this.contrastColor,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final l10n = AppLocalizations.of(context)!;
    final rows = <Widget>[];
    final hintParts = <String>[];

    if (showMental && trends.mentalAvgByState.isNotEmpty) {
      hintParts.add('estado mental');
      final sorted = trends.mentalAvgByState.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final e in sorted) {
        rows.add(
          _row(
            cc,
            e.key.mentalStateLabel(l10n),
            '${e.value.toStringAsFixed(1)}/5',
          ),
        );
      }
    }

    if (showMood && trends.totalMoodEntries > 0) {
      hintParts.add('${trends.totalMoodEntries} registros de ánimo');
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 6));
      final moodSeries = timeSeries?.dailyMoodValence ?? const [];
      if (moodSeries.isNotEmpty) {
        rows.add(
          Text(
            'Ánimo en el tiempo',
            style: TextStyle(
              color: cc.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        );
        rows.add(const SizedBox(height: 4));
        rows.add(
          MoodOverTimeChart(
            dailyMoodValence: moodSeries,
            rangeStart: rangeStart,
            contrastColor: cc,
          ),
        );
        rows.add(const SizedBox(height: 12));
      }
      final sortedQuadrants = trends.moodQuadrantCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final e in sortedQuadrants) {
        rows.add(_row(cc, e.key, '${e.value}'));
      }
      if (trends.topMoodWords.isNotEmpty) {
        final sortedWords = trends.topMoodWords.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topWords = sortedWords
            .take(6)
            .map((e) => '${e.key} (${e.value})')
            .join(', ');
        rows.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Más frecuentes: $topWords',
              style: TextStyle(
                color: cc.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ),
        );
      }
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return CollapsibleSection(
      title: 'ESTADO MENTAL Y ÁNIMO',
      hint: hintParts.join(' · '),
      initiallyExpanded: false,
      contrastColor: cc,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
    );
  }
}

class _PatternsSection extends StatelessWidget {
  final ReportTrends trends;
  final Color contrastColor;

  const _PatternsSection({required this.trends, required this.contrastColor});

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final patterns = trends.detectedPatterns;

    return CollapsibleSection(
      title: 'PATRONES DETECTADOS',
      hint: '${patterns.length}',
      // Exception to "collapsed by default": this is the feature the
      // redesign was specifically about — collapsing it by default would
      // defeat the point.
      initiallyExpanded: true,
      contrastColor: cc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: patterns
            .map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  p,
                  style: TextStyle(color: cc, fontSize: 13, height: 1.4),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _EffectivenessSection extends StatelessWidget {
  final Profile profile;
  final Color contrastColor;

  const _EffectivenessSection({
    required this.profile,
    required this.contrastColor,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final effPairs = <String>{};
    for (final o in profile.medicationOutcomes) {
      effPairs.add('${o.medicationName}→${o.symptomName}');
    }

    final rows = <Widget>[];
    for (final pair in effPairs) {
      final parts = pair.split('→');
      final eff = profile.effectivenessFor(parts[0], parts[1]);
      if (eff == null) continue;
      final pct = (eff.improved / eff.total * 100).toStringAsFixed(0);
      final avg = (-eff.meanDelta).toStringAsFixed(1);
      rows.add(_row(cc, '${parts[0]} → ${parts[1]}', '$pct% mejora ($avg pts)'));
    }
    if (rows.isEmpty) return const SizedBox.shrink();

    return CollapsibleSection(
      title: 'EFECTIVIDAD',
      hint: '${rows.length}',
      initiallyExpanded: false,
      contrastColor: cc,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
    );
  }
}
