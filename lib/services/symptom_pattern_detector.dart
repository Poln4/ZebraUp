// =============================================================================
// symptom_pattern_detector.dart — shared descriptive pattern-finder over
// SymptomEvent lists. Used by both the PDF report (pdf_report_aggregator.dart)
// and the in-app plain-text report trends (report_trends.dart), so the two
// surfaces never drift into showing different "patterns" for the same data.
//
// Deliberately conservative: plain descriptive statistics with explicit
// minimum-sample gating, never causal language ("occurs mostly", never
// "causes"/"triggers"). This is NOT the correlation_engine.dart scaffold —
// that's reserved for statistically rigorous, confidence-graded, opt-in
// insights (Phase 6.4/6.9). This stays a lightweight heuristic that mirrors
// the single-symptom time-of-day check that already shipped in the PDF, plus
// a new co-occurrence pass: does symptom B cluster in time specifically on
// the days symptom A also showed up?
// =============================================================================

import '../models/models.dart';

/// Time-of-day bucket counts for a list of events.
Map<String, int> timeOfDayPattern(List<SymptomEvent> events) {
  final counts = <String, int>{
    'morning': 0,
    'afternoon': 0,
    'evening': 0,
    'night': 0,
  };
  for (final e in events) {
    final h = e.timestamp.hour;
    if (h >= 5 && h < 12) {
      counts['morning'] = counts['morning']! + 1;
    } else if (h >= 12 && h < 18) {
      counts['afternoon'] = counts['afternoon']! + 1;
    } else if (h >= 18 && h < 22) {
      counts['evening'] = counts['evening']! + 1;
    } else {
      counts['night'] = counts['night']! + 1;
    }
  }
  return counts;
}

String _dateKey(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

String _windowLabel(String bucket) => switch (bucket) {
  'morning' => 'por las mañanas',
  'afternoon' => 'por las tardes',
  'evening' => 'al anochecer',
  'night' => 'durante la noche',
  _ => '',
};

/// Detects descriptive patterns across a period's symptom events:
///   1. Co-occurrence: for symptom pairs sharing enough days, whether the
///      second symptom clusters in one time-of-day window specifically on
///      the days the first also occurred. Computed first so pass 2 can
///      skip a symptom whose single-symptom finding would just restate
///      the same window a co-occurrence finding already explains.
///   2. Single-symptom time-of-day dominance (top 3 by frequency),
///      excluding restatements caught by pass 1.
/// Returns natural-language Spanish sentences, or an empty list if there
/// isn't enough data to say anything with reasonable confidence.
List<String> detectSymptomPatterns(List<SymptomEvent> events) {
  final patterns = <String>[];
  if (events.length < 10) return patterns;

  // Group by symptom name once, reused by both passes below.
  final grouped = <String, List<SymptomEvent>>{};
  for (final e in events) {
    final key = e.name.trim().isEmpty ? '(sin nombre)' : e.name.trim();
    grouped.putIfAbsent(key, () => []).add(e);
  }

  final byOccurrence = grouped.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));

  // --- Pass 1: co-occurrence — does symptom B cluster in time on the days
  // symptom A also shows up? Computed before the single-symptom pass so
  // we know which (symptom, window) findings are already covered here. ---
  final dayKeysByName = <String, Set<String>>{
    for (final entry in grouped.entries)
      entry.key: entry.value.map((e) => _dateKey(e.timestamp)).toSet(),
  };

  final names = grouped.keys.toList();
  final coOccurrenceCandidates = <MapEntry<List<String>, int>>[];
  for (var i = 0; i < names.length; i++) {
    for (var j = 0; j < names.length; j++) {
      if (i == j) continue;
      final a = names[i];
      final b = names[j];
      final sharedDays = dayKeysByName[a]!.intersection(dayKeysByName[b]!);
      if (sharedDays.length < 5) continue;
      coOccurrenceCandidates.add(MapEntry([a, b], sharedDays.length));
    }
  }
  coOccurrenceCandidates.sort((x, y) => y.value.compareTo(x.value));

  final coOccurrenceSentences = <String>[];
  // Tracks, per conditioned symptom (b), which time-of-day window its
  // co-occurrence finding used — lets pass 2 suppress a redundant
  // single-symptom restatement of the exact same window.
  final coOccurrenceWindowByName = <String, String>{};
  final usedPairs = <String>{};
  var added = 0;
  for (final candidate in coOccurrenceCandidates) {
    if (added >= 3) break;
    final a = candidate.key[0];
    final b = candidate.key[1];
    final pairKey = ([a, b]..sort()).join('|');
    if (usedPairs.contains(pairKey)) continue;

    final sharedDays = dayKeysByName[a]!.intersection(dayKeysByName[b]!);
    final bEventsOnSharedDays = grouped[b]!
        .where((e) => sharedDays.contains(_dateKey(e.timestamp)))
        .toList();
    if (bEventsOnSharedDays.length < 5) continue;
    final tod = timeOfDayPattern(bEventsOnSharedDays);
    final maxEntry = tod.entries.reduce((x, y) => x.value > y.value ? x : y);
    final ratio = maxEntry.value / bEventsOnSharedDays.length;
    if (ratio < 0.5) continue;
    final windowLabel = _windowLabel(maxEntry.key);
    if (windowLabel.isEmpty) continue;

    coOccurrenceSentences.add(
      'En los días con $a, $b se reportó mayormente $windowLabel '
      '(${(ratio * 100).round()}% de esos episodios).',
    );
    coOccurrenceWindowByName[b] = maxEntry.key;
    usedPairs.add(pairKey);
    added++;
  }

  // --- Pass 2: single-symptom time-of-day dominance, skipping a symptom
  // whose dominant window is the same one already explained by a
  // co-occurrence finding above (avoids saying the same thing twice). ---
  for (final entry in byOccurrence.take(3)) {
    final occurrences = entry.value.length;
    if (occurrences < 5) continue;
    final tod = timeOfDayPattern(entry.value);
    final maxEntry = tod.entries.reduce((a, b) => a.value > b.value ? a : b);
    final ratio = maxEntry.value / occurrences;
    if (ratio < 0.5) continue;
    if (coOccurrenceWindowByName[entry.key] == maxEntry.key) continue;
    final windowLabel = _windowLabel(maxEntry.key);
    if (windowLabel.isEmpty) continue;
    patterns.add(
      '${entry.key} ocurre principalmente $windowLabel '
      '(${(ratio * 100).round()}% de los episodios).',
    );
  }

  patterns.addAll(coOccurrenceSentences);
  return patterns;
}
