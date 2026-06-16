#!/usr/bin/env python3
"""
ZebraUp — Phase 5.2d.3a patch: lib/screens/hoy_tab.dart
=======================================================

Adds the fever chip — surfaces last reading + trend on Hoy, when there's
a reading in the last 24h.

Four surgical edits:
  1. Add import of '../services/fever_analysis.dart'
  2. Add `final feverInfo = FeverAnalysis.latestForChip(profile.feverHistory);`
     local in HoyTab.build()
  3. Insert the conditional `_FeverChip(...)` between the Pendientes
     section and the Weather section
  4. Append `_FeverChip` widget class at EOF (after `_DistentionBanner`)

The chip routes to Síntomas (index 1) on tap, reusing the existing
`onNavigate` callback wired in 5.2a.

Run from the repo root.
Idempotent: detects sentinel and reports SKIP on second run.
"""

import sys
from pathlib import Path

TARGET = Path("lib/screens/hoy_tab.dart")
SENTINEL = "// PHASE 5.2d.3a — Fever chip"

# ---------------------------------------------------------------------------
# Edit 1: import
# ---------------------------------------------------------------------------
IMPORTS_ANCHOR = """import '../widgets/severity_picker.dart';
import '../widgets/mood_picker_sheet.dart';
import '../l10n/app_localizations.dart';"""

IMPORTS_REPLACEMENT = """import '../widgets/severity_picker.dart';
import '../widgets/mood_picker_sheet.dart';
import '../l10n/app_localizations.dart';
import '../services/fever_analysis.dart';"""

# ---------------------------------------------------------------------------
# Edit 2: feverInfo local in build()
# ---------------------------------------------------------------------------
LOCALS_ANCHOR = """    final isPacing = profile.pacingDays.contains(_dateKey(selectedDate));
    final dueOutcomes = _isToday() ? profile.getDueOutcomes() : <MedicationOutcome>[];
    final l10n = context.l10n;"""

LOCALS_REPLACEMENT = """    final isPacing = profile.pacingDays.contains(_dateKey(selectedDate));
    final dueOutcomes = _isToday() ? profile.getDueOutcomes() : <MedicationOutcome>[];
    final l10n = context.l10n;
    final feverInfo = FeverAnalysis.latestForChip(profile.feverHistory);"""

# ---------------------------------------------------------------------------
# Edit 3: insert _FeverChip between Pendientes (closes with `],`) and Weather
# ---------------------------------------------------------------------------
SECTION_ANCHOR = """          ...dueOutcomes.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OutcomeAnswerCard(
                  outcome: o,
                  contrastColor: contrastColor,
                  inverseContrastColor: inverseContrastColor,
                  onAnswer: onAnswerOutcome,
                ),
              )),
          const SizedBox(height: 24),
        ],

        if (todayWeather != null) ...["""

SECTION_REPLACEMENT = """          ...dueOutcomes.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OutcomeAnswerCard(
                  outcome: o,
                  contrastColor: contrastColor,
                  inverseContrastColor: inverseContrastColor,
                  onAnswer: onAnswerOutcome,
                ),
              )),
          const SizedBox(height: 24),
        ],

        // PHASE 5.2d.3a — Fever chip
        if (feverInfo != null) ...[
          _FeverChip(
            info: feverInfo,
            contrastColor: contrastColor,
            onNavigate: onNavigate,
          ),
          const SizedBox(height: 20),
        ],

        if (todayWeather != null) ...["""

# ---------------------------------------------------------------------------
# Edit 4: append _FeverChip widget class at EOF (after _DistentionBanner)
# ---------------------------------------------------------------------------
EOF_ANCHOR = """              onPressed: onTapRegister,
            ),
          ),
        ],
      ),
    );
  }
}
"""

EOF_REPLACEMENT = """              onPressed: onTapRegister,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PHASE 5.2d.3a — Fever chip
// =============================================================================

/// Compact status chip surfacing the most recent fever reading.
///
/// Renders nothing when no reading exists within the last
/// `FeverAnalysis.chipMaxAgeHours` (24h by default). Visual weight matches
/// the bowel counter — outlined pill, no urgency styling. The temperature
/// number itself is the signal; we deliberately avoid color/bold variation
/// by severity to keep the B&W aesthetic consistent.
///
/// Tap navigates to Síntomas (tab index 1) — same shortcut pattern as the
/// distention banner. From there the user can log another reading or
/// review history.
///
/// Trend arrow uses a 0.1°C deadband (computed in LatestFeverInfo) so
/// noise-level fluctuations don't trigger flicker between ↑ and ↓.
class _FeverChip extends StatelessWidget {
  final LatestFeverInfo info;
  final Color contrastColor;
  final ValueChanged<int> onNavigate;

  const _FeverChip({
    required this.info,
    required this.contrastColor,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = info.reading;
    final timeAgo = DateTime.now().difference(r.timestamp);
    final trend = info.trend;
    final delta = info.delta;

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => onNavigate(1),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: contrastColor.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.thermostat,
                  color: contrastColor.withValues(alpha: 0.7), size: 14),
              const SizedBox(width: 6),
              Text(
                '${r.temperatureC.toStringAsFixed(1)}°C',
                style: TextStyle(
                  color: contrastColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' · ${r.site.label(l10n)}',
                style: TextStyle(
                  color: contrastColor.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
              Text(
                ' · ${_formatTimeAgo(timeAgo, l10n)}',
                style: TextStyle(
                  color: contrastColor.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
              if (trend != null && delta != null) ...[
                const SizedBox(width: 4),
                Text(
                  '· ${_formatTrend(trend, delta)}',
                  style: TextStyle(
                    color: contrastColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(Duration d, AppLocalizations l10n) {
    if (d.inHours >= 1) return l10n.timeAgoHours(d.inHours);
    return l10n.timeAgoMinutes(d.inMinutes.clamp(1, 59));
  }

  String _formatTrend(FeverTrend trend, double delta) {
    return switch (trend) {
      FeverTrend.rising => '↑${delta.toStringAsFixed(1)}',
      FeverTrend.falling => '↓${delta.abs().toStringAsFixed(1)}',
      FeverTrend.steady => '→',
    };
  }
}
"""


def main():
    if not TARGET.exists():
        print(f"ERROR: {TARGET} not found. Run from repo root.", file=sys.stderr)
        sys.exit(1)

    src = TARGET.read_text(encoding="utf-8")

    if SENTINEL in src:
        print(f"SKIP: {TARGET} already contains Phase 5.2d.3a fever chip.")
        return

    edits = [
        (IMPORTS_ANCHOR, IMPORTS_REPLACEMENT, "imports"),
        (LOCALS_ANCHOR, LOCALS_REPLACEMENT, "feverInfo local"),
        (SECTION_ANCHOR, SECTION_REPLACEMENT, "fever chip insertion"),
        (EOF_ANCHOR, EOF_REPLACEMENT, "_FeverChip widget class"),
    ]

    for anchor, _, label in edits:
        n = src.count(anchor)
        if n != 1:
            print(
                f"ERROR: anchor for '{label}' found {n} times (expected 1). "
                f"Aborting; no changes written.",
                file=sys.stderr,
            )
            sys.exit(2)

    out = src
    for anchor, insertion, _ in edits:
        out = out.replace(anchor, insertion)

    TARGET.write_text(out, encoding="utf-8")
    print(f"OK: applied Phase 5.2d.3a to {TARGET}")
    print(f"  - fever_analysis.dart imported")
    print(f"  - feverInfo local in HoyTab.build()")
    print(f"  - _FeverChip inserted between Pendientes and Weather")
    print(f"  - _FeverChip widget class appended at EOF")


if __name__ == "__main__":
    main()