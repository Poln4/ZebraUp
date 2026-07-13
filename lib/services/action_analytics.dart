// Sprint T0 — action analytics service.
//
// Pure aggregation over Profile data. No UI, no side effects, no
// async. Two responsibilities:
//
//   1. Botiquín scorecard: aggregate ActionTaken records that
//      reference a given MedicationDef.id and summarize
//      effectiveness distribution + best-fit indication + last use.
//
//   2. Weekly narrative digest: rolling 7-day window over
//      symptoms, actions, pacing, bowel, fever, sleep — plus a
//      natural-language text generator.
//
// Both structures are const-friendly, testable, and reusable by
// future features (PDF export, cross-tab widgets, Tier 1 nudges).

import '../models/models.dart';
import '../models/action_taken.dart';

// ============================================================
// BOTIQUÍN SCORECARD
// ============================================================

class MedScorecardStats {
  final String medicationId;
  final int totalUses;
  final Map<EffectivenessRating, int> ratingCounts;
  final DateTime? lastUsedAt;

  /// Symptom name with the highest positive-outcome count
  /// (muchRelief + someRelief). Null when no symptom-linked positive
  /// outcomes exist.
  final String? bestFitSymptom;
  final int bestFitCount;

  const MedScorecardStats({
    required this.medicationId,
    required this.totalUses,
    required this.ratingCounts,
    this.lastUsedAt,
    this.bestFitSymptom,
    this.bestFitCount = 0,
  });

  bool get hasNoData => totalUses == 0;

  /// True when the sample is too small to draw meaningful patterns
  /// (< 5 uses). UI should surface an epistemic caveat when true.
  bool get isSmallSample => totalUses > 0 && totalUses < 5;

  int countFor(EffectivenessRating r) => ratingCounts[r] ?? 0;

  int get ratedCount => ratingCounts.values.fold(0, (a, b) => a + b);
}

MedScorecardStats scorecardFor(String medicationId, Profile profile) {
  final matching = profile.actionsHistory
      .where((a) => a.medicationRefId == medicationId)
      .toList();

  if (matching.isEmpty) {
    return MedScorecardStats(
      medicationId: medicationId,
      totalUses: 0,
      ratingCounts: const {},
    );
  }

  final counts = <EffectivenessRating, int>{};
  DateTime? lastUsed;

  for (final a in matching) {
    if (a.effectivenessRating != null) {
      counts[a.effectivenessRating!] =
          (counts[a.effectivenessRating!] ?? 0) + 1;
    }
    if (lastUsed == null || a.timestamp.isAfter(lastUsed)) {
      lastUsed = a.timestamp;
    }
  }

  // Best-fit indication: for each symptom name linked to this med
  // with a positive outcome, count. Highest wins.
  final positiveRatings = <EffectivenessRating>{
    EffectivenessRating.muchRelief,
    EffectivenessRating.someRelief,
  };
  final symptomCounts = <String, int>{};
  for (final a in matching) {
    if (a.linkedEventType != LinkedEventType.symptom) continue;
    if (a.effectivenessRating == null) continue;
    if (!positiveRatings.contains(a.effectivenessRating)) continue;
    // Resolve linkedEventId → symptom name via timestamp match
    for (final s in profile.symptomHistory) {
      if (s.timestamp.toIso8601String() == a.linkedEventId) {
        final name = s.name.toLowerCase();
        symptomCounts[name] = (symptomCounts[name] ?? 0) + 1;
        break;
      }
    }
  }

  String? bestFit;
  int bestFitCount = 0;
  symptomCounts.forEach((name, count) {
    if (count > bestFitCount) {
      bestFit = name;
      bestFitCount = count;
    }
  });

  return MedScorecardStats(
    medicationId: medicationId,
    totalUses: matching.length,
    ratingCounts: counts,
    lastUsedAt: lastUsed,
    bestFitSymptom: bestFit,
    bestFitCount: bestFitCount,
  );
}

// ============================================================
// WEEKLY DIGEST
// ============================================================

class WeeklyDigest {
  /// Number of days actually covered by data (max 7). Used to decide
  /// between "Estos últimos 7 días" and "Hasta ahora" wording.
  final int daysCovered;

  final int symptomCount;

  /// Top symptoms by count (up to 3). Preserves ordering.
  final List<MapEntry<String, int>> topSymptoms;

  /// Med name → effectiveness distribution over the window.
  final Map<String, Map<EffectivenessRating, int>> medEffectiveness;

  final int pacingDays;
  final int bowelCount;
  final int feverCount;
  final int sleepEntries;
  final bool hasAnyData;

  const WeeklyDigest({
    required this.daysCovered,
    required this.symptomCount,
    required this.topSymptoms,
    required this.medEffectiveness,
    required this.pacingDays,
    required this.bowelCount,
    required this.feverCount,
    required this.sleepEntries,
    required this.hasAnyData,
  });

  bool get isSparse => daysCovered < 7;
}

WeeklyDigest weeklyDigestFor(Profile profile, DateTime now) {
  final windowStart = now.subtract(const Duration(days: 7));

  final symptoms = profile.symptomHistory
      .where(
        (s) => s.timestamp.isAfter(windowStart) && s.timestamp.isBefore(now),
      )
      .toList();

  final actions = profile.actionsHistory
      .where(
        (a) => a.timestamp.isAfter(windowStart) && a.timestamp.isBefore(now),
      )
      .toList();

  final bowel = profile.bowelHistory
      .where(
        (b) => b.timestamp.isAfter(windowStart) && b.timestamp.isBefore(now),
      )
      .toList();

  final fever = profile.feverHistory
      .where(
        (f) => f.timestamp.isAfter(windowStart) && f.timestamp.isBefore(now),
      )
      .toList();

  final sleep = profile.sleepHistory
      .where(
        (s) => s.timestamp.isAfter(windowStart) && s.timestamp.isBefore(now),
      )
      .toList();

  // Top symptoms
  final symptomCounts = <String, int>{};
  for (final s in symptoms) {
    final name = s.name.toLowerCase();
    symptomCounts[name] = (symptomCounts[name] ?? 0) + 1;
  }
  final sorted = symptomCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topSymptoms = sorted.take(3).toList();

  // Med effectiveness — only completed ActionTakens with med refs and ratings
  final medEff = <String, Map<EffectivenessRating, int>>{};
  for (final a in actions) {
    if (!a.followUpCompleted) continue;
    if (a.effectivenessRating == null) continue;
    if (a.medicationRefId == null) continue;
    String? medName;
    for (final m in profile.botiquin) {
      if (m.id == a.medicationRefId) {
        medName = m.name;
        break;
      }
    }
    if (medName == null) continue;
    final bucket = medEff.putIfAbsent(medName, () => {});
    bucket[a.effectivenessRating!] = (bucket[a.effectivenessRating] ?? 0) + 1;
  }

  // Pacing — check each of the last 7 date keys
  int pacingDays = 0;
  for (int i = 0; i < 7; i++) {
    final d = now.subtract(Duration(days: i));
    final key =
        "${d.year}-${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
    if (profile.pacingDays.contains(key)) pacingDays++;
  }

  // Days covered — earliest activity to now, capped at 7
  DateTime? earliest;
  final allTimestamps = [
    ...symptoms.map((e) => e.timestamp),
    ...actions.map((e) => e.timestamp),
    ...bowel.map((e) => e.timestamp),
    ...fever.map((e) => e.timestamp),
    ...sleep.map((e) => e.timestamp),
  ];
  for (final ts in allTimestamps) {
    if (earliest == null || ts.isBefore(earliest)) earliest = ts;
  }

  int daysCovered;
  if (earliest != null) {
    final raw = now.difference(earliest).inDays + 1;
    daysCovered = raw < 7 ? raw : 7;
  } else {
    daysCovered = 0;
  }

  final hasAnyData =
      symptoms.isNotEmpty ||
      actions.isNotEmpty ||
      bowel.isNotEmpty ||
      fever.isNotEmpty ||
      sleep.isNotEmpty ||
      pacingDays > 0;

  return WeeklyDigest(
    daysCovered: daysCovered,
    symptomCount: symptoms.length,
    topSymptoms: topSymptoms,
    medEffectiveness: medEff,
    pacingDays: pacingDays,
    bowelCount: bowel.length,
    feverCount: fever.length,
    sleepEntries: sleep.length,
    hasAnyData: hasAnyData,
  );
}

// ============================================================
// NARRATIVE TEXT GENERATION
// ============================================================

/// Generates the natural-language narrative for a WeeklyDigest.
/// Returns empty string when nothing meaningful to say.
///
/// LatAm tuteo neutro estricto. No voseo forms.
String narrativeText(WeeklyDigest digest) {
  if (!digest.hasAnyData) {
    return 'No hay registros esta semana. Empieza registrando algo en Síntomas.';
  }

  final sentences = <String>[];
  final opening = digest.isSparse ? 'Hasta ahora' : 'Estos últimos 7 días';

  // Sentence 1: opening + symptoms
  if (digest.symptomCount > 0) {
    final list = digest.topSymptoms
        .map((e) => _symptomLabel(e.key, e.value))
        .join(', ');
    sentences.add('$opening: registraste $list');
  } else {
    sentences.add('$opening sin síntomas registrados');
  }

  // Sentence 2: top med effectiveness
  if (digest.medEffectiveness.isNotEmpty) {
    String? topMed;
    int topPositive = 0;
    int topTotal = 0;
    digest.medEffectiveness.forEach((med, counts) {
      final positive =
          (counts[EffectivenessRating.muchRelief] ?? 0) +
          (counts[EffectivenessRating.someRelief] ?? 0);
      final total = counts.values.fold(0, (a, b) => a + b);
      if (positive > topPositive ||
          (positive == topPositive && total > topTotal)) {
        topMed = med;
        topPositive = positive;
        topTotal = total;
      }
    });
    if (topMed != null && topTotal > 0 && topPositive > 0) {
      if (topPositive == topTotal) {
        final vez = topTotal == 1 ? 'ocasión' : 'ocasiones';
        sentences.add('$topMed funcionó en $topTotal $vez');
      } else {
        sentences.add('$topMed funcionó $topPositive de $topTotal veces');
      }
    }
  }

  // Sentence 3: pacing (number-first structure for sentence flow)
  if (digest.pacingDays == 1) {
    sentences.add('1 día marcado como descanso');
  } else if (digest.pacingDays > 1) {
    sentences.add('${digest.pacingDays} días marcados como descanso');
  }

  // Sentence 4: bowel
  if (digest.bowelCount == 1) {
    sentences.add('1 registro de tránsito');
  } else if (digest.bowelCount > 1) {
    sentences.add('${digest.bowelCount} registros de tránsito');
  }

  // Sentence 5: fever
  if (digest.feverCount == 1) {
    sentences.add('1 episodio de fiebre');
  } else if (digest.feverCount > 1) {
    sentences.add('${digest.feverCount} episodios de fiebre');
  }

  // Sentence 6: sleep
  if (digest.sleepEntries == 1) {
    sentences.add('1 noche con registro de sueño');
  } else if (digest.sleepEntries > 1) {
    sentences.add('${digest.sleepEntries} noches con registro de sueño');
  }

  // Sparse tail
  if (digest.isSparse && sentences.length <= 2) {
    sentences.add('Sigue registrando para ver patrones');
  }

  return '${sentences.join('. ')}.';
}

String _symptomLabel(String name, int count) {
  final vez = count == 1 ? 'vez' : 'veces';
  return '$name $count $vez';
}

// ============================================================
// SYMPTOM FREQUENCY DASHBOARD (Sprint T0.3)
// ============================================================

/// Frequency statistics for a single symptom name over a rolling
/// window. Consumed by SymptomFrequencyDashboard widget.
///
/// `dailyCounts` is chronologically ordered — first element is the
/// oldest day in the window, last element is today.
class SymptomFrequencyStats {
  final String name;
  final int totalCount;
  final List<int> dailyCounts;
  final DateTime? lastLoggedAt;

  const SymptomFrequencyStats({
    required this.name,
    required this.totalCount,
    required this.dailyCounts,
    this.lastLoggedAt,
  });

  bool get hasRecentActivity => totalCount > 0;

  int get peak {
    if (dailyCounts.isEmpty) return 0;
    return dailyCounts.reduce((a, b) => a > b ? a : b);
  }
}

/// Compute per-symptom frequency stats over a rolling window of
/// [windowDays] ending at [now] (or DateTime.now() if omitted).
///
/// Returns up to [topN] symptoms sorted by totalCount desc, with
/// lastLoggedAt desc as tiebreaker. Empty list when no symptom
/// activity in the window.
///
/// Symptom names are normalized to lowercase + trim before grouping,
/// so "Migraña" and "migraña " count as the same symptom.
List<SymptomFrequencyStats> symptomFrequencyStats(
  Profile profile, {
  int windowDays = 30,
  int topN = 10,
  DateTime? now,
}) {
  final referenceNow = now ?? DateTime.now();
  final windowStart = referenceNow.subtract(Duration(days: windowDays));

  final byName = <String, List<SymptomEvent>>{};
  for (final s in profile.symptomHistory) {
    if (s.timestamp.isBefore(windowStart)) continue;
    if (s.timestamp.isAfter(referenceNow)) continue;
    final key = s.name.toLowerCase().trim();
    if (key.isEmpty) continue;
    byName.putIfAbsent(key, () => []).add(s);
  }

  if (byName.isEmpty) return const [];

  final stats = <SymptomFrequencyStats>[];
  for (final entry in byName.entries) {
    final events = entry.value;
    final dailyCounts = List<int>.filled(windowDays, 0);
    DateTime? lastLoggedAt;

    for (final e in events) {
      final daysAgo = referenceNow.difference(e.timestamp).inDays;
      // Map daysAgo (0 = today, windowDays-1 = oldest) into index
      // (0 = oldest, windowDays-1 = today) for chronological ordering.
      final idx = windowDays - 1 - daysAgo;
      if (idx >= 0 && idx < windowDays) {
        dailyCounts[idx]++;
      }
      if (lastLoggedAt == null || e.timestamp.isAfter(lastLoggedAt)) {
        lastLoggedAt = e.timestamp;
      }
    }

    stats.add(
      SymptomFrequencyStats(
        name: entry.key,
        totalCount: events.length,
        dailyCounts: dailyCounts,
        lastLoggedAt: lastLoggedAt,
      ),
    );
  }

  stats.sort((a, b) {
    final byCount = b.totalCount.compareTo(a.totalCount);
    if (byCount != 0) return byCount;
    final aTime = a.lastLoggedAt?.millisecondsSinceEpoch ?? 0;
    final bTime = b.lastLoggedAt?.millisecondsSinceEpoch ?? 0;
    return bTime.compareTo(aTime);
  });

  return stats.take(topN).toList();
}
