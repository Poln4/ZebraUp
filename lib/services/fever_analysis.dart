// =============================================================================
// FeverAnalysis — episode detection + trend computation on FeverReading data.
//
// Episode detection groups feverish readings into contiguous clusters,
// allowing gaps up to `episodeGapHours`. Designed for the patient mental
// model: "this fever lasted from X to Y, peaked at Z, and these are the
// antipyretics I took".
//
// Thresholds:
//   - `feverThresholdC` (37.5°C): lower bound of "feverish". Conservative —
//     covers axillary readings, which run ~0.5°C below oral/rectal. Readings
//     below this are not part of any episode.
//   - `highFeverThresholdC` (38.0°C): stricter "fever" definition. Reserved
//     for future styling/messaging that wants a less ambiguous threshold.
//   - `episodeGapHours` (48): maximum hours between consecutive feverish
//     readings to still be considered the same episode. A larger gap implies
//     "I stopped measuring because I felt fine" — a recurrence after that is
//     a new episode.
//   - `activeEpisodeHours` (48): an episode is "active" if its last reading
//     is within this window from now.
//   - `chipMaxAgeHours` (24): maximum age of the latest reading to surface
//     it in the Hoy chip. Older than this and the chip hides — stale info
//     is worse than no info.
//
// Site-specific thresholds were deliberately NOT implemented. Users may
// switch sites within a single episode (e.g. axillary at home, oral at the
// clinic), and per-site normalization adds clinical complexity that has no
// research-backed payoff for self-tracking. The unified 37.5°C threshold is
// conservative — false positives at the low end (37.5 axillary ≈ 37.0 oral,
// arguably "normal") are tolerable; false negatives matter more.
//
// References:
//   - El-Radhi AS (2018). Clinical Manual of Fever in Children, 8th ed.
//     Springer. Chapter 1: definitions and thresholds across measurement
//     sites.
//   - Niven DJ et al. (2015). Accuracy of peripheral thermometers for
//     estimating temperature: a systematic review. Ann Intern Med 163:768.
// =============================================================================

import '../models/models.dart';
import '../l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
// FeverSite localization
//
// Moved here from fever_form_sheet.dart so that non-form-sheet callers
// (Hoy tab chip, clinical report, future analytics) can import the
// extension from a meaningful module path. fever_form_sheet.dart
// re-exports this so existing imports of the form sheet continue to see
// the extension.
// -----------------------------------------------------------------------------

extension FeverSiteLocalization on FeverSite {
  String label(AppLocalizations l10n) {
    return switch (this) {
      FeverSite.axillary => l10n.feverSiteAxillary,
      FeverSite.oral => l10n.feverSiteOral,
      FeverSite.tympanic => l10n.feverSiteTympanic,
      FeverSite.rectal => l10n.feverSiteRectal,
      FeverSite.forehead => l10n.feverSiteForehead,
    };
  }
}

// -----------------------------------------------------------------------------
// Models
// -----------------------------------------------------------------------------

enum FeverTrend { rising, falling, steady }

/// Latest reading plus the chronologically prior reading (if any), with
/// derived trend information.
///
/// `previous` may be arbitrarily old — its role is to provide the
/// most-recent prior data point for the directional comparison shown in
/// the Hoy chip. If the user logs sporadically, the trend is still
/// meaningful (it shows the direction since their last measurement).
class LatestFeverInfo {
  final FeverReading reading;
  final FeverReading? previous;

  const LatestFeverInfo({required this.reading, this.previous});

  /// Signed delta in °C: positive = rising, negative = falling.
  double? get delta =>
      previous == null ? null : reading.temperatureC - previous!.temperatureC;

  /// Coarse trend classification with a 0.1°C deadband to avoid
  /// noise-driven arrow flicker on small fluctuations.
  FeverTrend? get trend {
    final d = delta;
    if (d == null) return null;
    if (d > 0.1) return FeverTrend.rising;
    if (d < -0.1) return FeverTrend.falling;
    return FeverTrend.steady;
  }
}

/// A contiguous cluster of feverish readings with summary metrics.
///
/// "Contiguous" is defined by `FeverAnalysis.episodeGapHours`: consecutive
/// readings within that window belong to the same episode. The model is
/// intentionally read-only — for in-place updates use `copyWith`.
class FeverEpisode {
  final DateTime start;
  final DateTime end;
  final double peakTemperatureC;
  final DateTime peakTimestamp;
  final FeverSite peakSite;
  final int readingsCount;

  /// Deduplicated, sorted names of antipyretics taken during this
  /// episode (only entries where antipyreticTaken=true AND
  /// antipyreticName was provided).
  final List<String> antipyreticsUsed;

  /// Total count of antipyretic doses recorded across the episode
  /// (includes entries where the name was empty).
  final int antipyreticDosesCount;

  /// True if this is the last episode AND its end-time is within
  /// `FeverAnalysis.activeEpisodeHours` from now.
  final bool isActive;

  const FeverEpisode({
    required this.start,
    required this.end,
    required this.peakTemperatureC,
    required this.peakTimestamp,
    required this.peakSite,
    required this.readingsCount,
    required this.antipyreticsUsed,
    required this.antipyreticDosesCount,
    required this.isActive,
  });

  Duration get duration => end.difference(start);

  FeverEpisode copyWith({bool? isActive}) {
    return FeverEpisode(
      start: start,
      end: end,
      peakTemperatureC: peakTemperatureC,
      peakTimestamp: peakTimestamp,
      peakSite: peakSite,
      readingsCount: readingsCount,
      antipyreticsUsed: antipyreticsUsed,
      antipyreticDosesCount: antipyreticDosesCount,
      isActive: isActive ?? this.isActive,
    );
  }
}

// -----------------------------------------------------------------------------
// Analysis
// -----------------------------------------------------------------------------

class FeverAnalysis {
  /// Minimum temperature (°C) to be considered "feverish". Conservative;
  /// covers axillary readings.
  static const double feverThresholdC = 37.5;

  /// Stricter "fever" threshold for UI styling and report classification.
  static const double highFeverThresholdC = 38.0;

  /// Maximum hours between consecutive readings to still be the same
  /// episode. Wider than typical inter-measurement intervals during
  /// active monitoring.
  static const int episodeGapHours = 48;

  /// An episode is "active" if its last reading is within this window
  /// from now.
  static const int activeEpisodeHours = 48;

  /// Maximum age of the latest reading to surface it in the Hoy chip.
  /// Older than this and the chip hides — stale temperature info is
  /// worse than no info at all.
  static const int chipMaxAgeHours = 24;

  /// Returns the most recent reading (regardless of whether it's
  /// feverish) plus the chronologically prior reading for trend display.
  ///
  /// Returns null if:
  ///   - no readings at all
  ///   - latest reading is older than `chipMaxAgeHours`
  ///
  /// The "previous" reading may be arbitrarily old — it's only used to
  /// compute the direction since the last measurement.
  static LatestFeverInfo? latestForChip(List<FeverReading> readings) {
    if (readings.isEmpty) return null;
    final sorted = [...readings]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final last = sorted.last;
    final age = DateTime.now().difference(last.timestamp);
    if (age.inHours > chipMaxAgeHours) return null;
    final prev = sorted.length > 1 ? sorted[sorted.length - 2] : null;
    return LatestFeverInfo(reading: last, previous: prev);
  }

  /// Groups feverish readings into contiguous episodes.
  ///
  /// Algorithm:
  ///   1. Filter readings >= `feverThresholdC`
  ///   2. Sort chronologically
  ///   3. Walk forward: same episode if next reading is within
  ///      `episodeGapHours` of the prior; otherwise start a new episode
  ///   4. Build FeverEpisode with summary metrics for each cluster
  ///   5. Mark the latest cluster as active if it ended within
  ///      `activeEpisodeHours` from now
  ///
  /// Returns episodes oldest-first.
  static List<FeverEpisode> detectEpisodes(List<FeverReading> readings) {
    final feverish =
        readings.where((r) => r.temperatureC >= feverThresholdC).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (feverish.isEmpty) return const [];

    final episodes = <FeverEpisode>[];
    var clusterStart = 0;

    for (var i = 1; i <= feverish.length; i++) {
      final isLast = i == feverish.length;
      final gapTooLarge =
          !isLast &&
          feverish[i].timestamp.difference(feverish[i - 1].timestamp).inHours >
              episodeGapHours;

      if (isLast || gapTooLarge) {
        final cluster = feverish.sublist(clusterStart, i);
        episodes.add(_buildEpisode(cluster));
        clusterStart = i;
      }
    }

    // Mark active status on the latest episode.
    if (episodes.isNotEmpty) {
      final lastEp = episodes.last;
      final age = DateTime.now().difference(lastEp.end);
      if (age.inHours <= activeEpisodeHours) {
        episodes[episodes.length - 1] = lastEp.copyWith(isActive: true);
      }
    }

    return episodes;
  }

  static FeverEpisode _buildEpisode(List<FeverReading> cluster) {
    // cluster is non-empty and chronologically sorted.
    final start = cluster.first.timestamp;
    final end = cluster.last.timestamp;
    final peak = cluster.reduce(
      (a, b) => a.temperatureC >= b.temperatureC ? a : b,
    );

    final antipyreticDoses = cluster.where((r) => r.antipyreticTaken).toList();
    final names = <String>{};
    for (final r in antipyreticDoses) {
      final n = r.antipyreticName?.trim();
      if (n != null && n.isNotEmpty) names.add(n);
    }

    return FeverEpisode(
      start: start,
      end: end,
      peakTemperatureC: peak.temperatureC,
      peakTimestamp: peak.timestamp,
      peakSite: peak.site,
      readingsCount: cluster.length,
      antipyreticsUsed: names.toList()..sort(),
      antipyreticDosesCount: antipyreticDoses.length,
      isActive: false, // overridden in detectEpisodes for the last cluster
    );
  }
}
