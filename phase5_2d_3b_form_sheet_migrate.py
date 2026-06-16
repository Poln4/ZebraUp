#!/usr/bin/env python3
"""
ZebraUp — Phase 5.2d.3b patch: migrate FeverSiteLocalization out of
lib/widgets/fever_form_sheet.dart and into the fever_analysis service.

Two surgical edits:
  1. Add import + export of '../services/fever_analysis.dart' after the
     existing imports. The export keeps `sintomas_tab.dart`'s existing
     `import '../widgets/fever_form_sheet.dart';` working — the extension
     remains visible through re-export.
  2. Remove the local FeverSiteLocalization extension definition (now
     authoritative in fever_analysis.dart).

Run from the repo root.
Idempotent: detects sentinel and reports SKIP on second run.
"""

import sys
from pathlib import Path

TARGET = Path("lib/widgets/fever_form_sheet.dart")
SENTINEL = "export '../services/fever_analysis.dart' show FeverSiteLocalization;"

# ---------------------------------------------------------------------------
# Edit 1: add import + export after the existing imports
# ---------------------------------------------------------------------------
IMPORTS_ANCHOR = """import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';"""

IMPORTS_REPLACEMENT = """import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';
import '../services/fever_analysis.dart';

// Re-export FeverSiteLocalization so existing callers that import this
// file (e.g. sintomas_tab.dart) continue to see the extension. The
// authoritative definition now lives in services/fever_analysis.dart.
export '../services/fever_analysis.dart' show FeverSiteLocalization;"""

# ---------------------------------------------------------------------------
# Edit 2: remove the local extension definition
# ---------------------------------------------------------------------------
EXTENSION_BLOCK = """/// Public extension so callers (e.g. the Sintomas tab when rendering
/// today's logged readings) can localize site labels using the same
/// l10n keys this sheet uses.
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

"""

EXTENSION_REPLACEMENT = ""  # delete the block entirely (incl. trailing blank line)


def main():
    if not TARGET.exists():
        print(f"ERROR: {TARGET} not found. Run from repo root.", file=sys.stderr)
        sys.exit(1)

    src = TARGET.read_text(encoding="utf-8")

    if SENTINEL in src:
        print(f"SKIP: {TARGET} already migrated.")
        return

    edits = [
        (IMPORTS_ANCHOR, IMPORTS_REPLACEMENT, "imports + re-export"),
        (EXTENSION_BLOCK, EXTENSION_REPLACEMENT, "extension block removal"),
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
    print(f"OK: migrated {TARGET}")
    print(f"  - imports fever_analysis.dart (provides extension internally)")
    print(f"  - re-exports FeverSiteLocalization for downstream callers")
    print(f"  - removed local extension block")


if __name__ == "__main__":
    main()