#!/usr/bin/env python3
"""
ZebraUp — Phase 5.2d.3c patch: clinical report fever section
============================================================

Adds two new sections to _buildReportPlainText in lib/screens/main_screen.dart:

  - FIEBRE: bullet list of each fever reading logged on the selected day,
    with time, temperature, site, and antipyretic info if applicable.

  - EPISODIO ACTIVO / EPISODIO RECIENTE: summary of the episode that
    overlaps the selected day (if any). Shows start, peak, total
    readings, and antipyretics taken across the episode span.

Sections appear between "SÍNTOMAS" and "NIEBLA / FATIGA".

Three surgical edits:
  1. Add `import '../services/fever_analysis.dart';`
  2. Add data-prep locals (todaysFever, feverEpisodes) at the top of
     _buildReportPlainText
  3. Insert the FIEBRE + EPISODIO rendering block between SÍNTOMAS and
     the mentalSummary conditional

Run from the repo root.
Idempotent: detects sentinel and reports SKIP on second run.
"""

import sys
from pathlib import Path

TARGET = Path("lib/screens/main_screen.dart")
SENTINEL = "// PHASE 5.2d.3c — FIEBRE"

# ---------------------------------------------------------------------------
# Edit 1: import
#
# Anchored on the project import of models.dart — guaranteed present in
# main_screen.dart, and the relative path '../models/models.dart' is
# unambiguous for a file at lib/screens/.
# ---------------------------------------------------------------------------
IMPORT_ANCHOR = "import '../models/models.dart';"

IMPORT_REPLACEMENT = """import '../models/models.dart';
import '../services/fever_analysis.dart';"""

# ---------------------------------------------------------------------------
# Edit 2: data prep at top of _buildReportPlainText
#
# Anchored on the "<--- NUEVO" comment from her earlier mood-EMA addition,
# which is unique to that line.
# ---------------------------------------------------------------------------
DATA_ANCHOR = "    final todaysMoods = _activeProfile!.getMoodForDay(_selectedDate); // <--- NUEVO"

DATA_REPLACEMENT = """    final todaysMoods = _activeProfile!.getMoodForDay(_selectedDate); // <--- NUEVO
    final todaysFever = _activeProfile!.getFeverForDay(_selectedDate);
    final feverEpisodes = FeverAnalysis.detectEpisodes(_activeProfile!.feverHistory);"""

# ---------------------------------------------------------------------------
# Edit 3: FIEBRE + EPISODIO rendering between SÍNTOMAS and NIEBLA conditional
#
# Anchored on the closing of the SÍNTOMAS if/else block followed by the
# opening of the mentalSummary conditional — that pair is unique to this
# report method.
# ---------------------------------------------------------------------------
SECTION_ANCHOR = """    if (grouped.isEmpty) {
      buf.writeln(" • —");
    } else {
      for (final s in grouped.entries) {
        buf.writeln(" • ${s.key} [${s.value.label.toUpperCase()}]");
      }
    }
    if (mentalSummary.isNotEmpty) {"""

SECTION_REPLACEMENT = """    if (grouped.isEmpty) {
      buf.writeln(" • —");
    } else {
      for (final s in grouped.entries) {
        buf.writeln(" • ${s.key} [${s.value.label.toUpperCase()}]");
      }
    }

    // PHASE 5.2d.3c — FIEBRE
    if (todaysFever.isNotEmpty) {
      buf.writeln();
      buf.writeln("FIEBRE:");
      for (final r in todaysFever) {
        final timeStr = DateFormat('HH:mm').format(r.timestamp);
        final tempStr = r.temperatureC.toStringAsFixed(1);
        String line = " • [$timeStr] ${tempStr}°C (${r.site.defaultLabel})";
        if (r.antipyreticTaken) {
          final apName = r.antipyreticName?.trim();
          if (apName != null && apName.isNotEmpty) {
            line += " + antipirético: $apName";
          } else {
            line += " + antipirético";
          }
        }
        buf.writeln(line);
      }
    }

    // Episode context: find the episode (if any) overlapping _selectedDate.
    // Last match wins, so if multiple episodes touch the day we surface
    // the most recent one — important when readings are sparse and a new
    // episode starts on the same calendar day an old one ended.
    final feverStartOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final feverEndOfDayExcl = feverStartOfDay.add(const Duration(days: 1));
    FeverEpisode? relevantFeverEpisode;
    for (final ep in feverEpisodes) {
      if (ep.start.isBefore(feverEndOfDayExcl) && !ep.end.isBefore(feverStartOfDay)) {
        relevantFeverEpisode = ep;
      }
    }

    if (relevantFeverEpisode != null) {
      final ep = relevantFeverEpisode;
      final totalHours = ep.duration.inHours;
      final days = totalHours ~/ 24;
      final hours = totalHours % 24;
      final String durStr;
      if (days >= 1 && hours > 0) {
        durStr = "$days ${days == 1 ? 'día' : 'días'} ${hours}h";
      } else if (days >= 1) {
        durStr = "$days ${days == 1 ? 'día' : 'días'}";
      } else if (hours >= 1) {
        durStr = "${hours}h";
      } else {
        final mins = ep.duration.inMinutes;
        durStr = mins > 0 ? "${mins}min" : "lectura única";
      }
      final title = ep.isActive ? "EPISODIO ACTIVO" : "EPISODIO RECIENTE";

      buf.writeln();
      buf.writeln("$title ($durStr):");
      buf.writeln(" • Inicio: ${DateFormat('yyyy-MM-dd HH:mm').format(ep.start)}");
      buf.writeln(" • Pico: ${ep.peakTemperatureC.toStringAsFixed(1)}°C (${ep.peakSite.defaultLabel}) el ${DateFormat('yyyy-MM-dd HH:mm').format(ep.peakTimestamp)}");
      buf.writeln(" • Total lecturas: ${ep.readingsCount}");
      if (ep.antipyreticDosesCount > 0) {
        final String apStr;
        if (ep.antipyreticsUsed.isNotEmpty) {
          apStr = "${ep.antipyreticsUsed.join(', ')} (${ep.antipyreticDosesCount} dosis totales)";
        } else {
          apStr = "${ep.antipyreticDosesCount} dosis (sin nombre registrado)";
        }
        buf.writeln(" • Antipiréticos: $apStr");
      }
    }

    if (mentalSummary.isNotEmpty) {"""


def main():
    if not TARGET.exists():
        print(f"ERROR: {TARGET} not found. Run from repo root.", file=sys.stderr)
        sys.exit(1)

    src = TARGET.read_text(encoding="utf-8")

    if SENTINEL in src:
        print(f"SKIP: {TARGET} already contains Phase 5.2d.3c fever report section.")
        return

    edits = [
        (IMPORT_ANCHOR, IMPORT_REPLACEMENT, "fever_analysis import"),
        (DATA_ANCHOR, DATA_REPLACEMENT, "data-prep locals"),
        (SECTION_ANCHOR, SECTION_REPLACEMENT, "FIEBRE + EPISODIO rendering"),
    ]

    for anchor, _, label in edits:
        n = src.count(anchor)
        if n != 1:
            print(
                f"ERROR: anchor for '{label}' found {n} times (expected 1). "
                f"Aborting; no changes written.",
                file=sys.stderr,
            )
            if label == "fever_analysis import" and n == 0:
                print(
                    "       Expected anchor: import '../models/models.dart';",
                    file=sys.stderr,
                )
                print(
                    "       If main_screen.dart imports models with a different path, ",
                    file=sys.stderr,
                )
                print(
                    "       paste the imports block and I'll adjust.",
                    file=sys.stderr,
                )
            sys.exit(2)

    out = src
    for anchor, insertion, _ in edits:
        out = out.replace(anchor, insertion)

    TARGET.write_text(out, encoding="utf-8")
    print(f"OK: applied Phase 5.2d.3c to {TARGET}")
    print(f"  - fever_analysis imported")
    print(f"  - todaysFever + feverEpisodes locals in _buildReportPlainText")
    print(f"  - FIEBRE + EPISODIO sections inserted between SÍNTOMAS and NIEBLA")


if __name__ == "__main__":
    main()