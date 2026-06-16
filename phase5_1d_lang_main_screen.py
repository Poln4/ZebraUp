#!/usr/bin/env python3
"""
ZebraUp — Phase 5.1d-lang patch: lib/screens/main_screen.dart
==============================================================

Passes the existing widget.locale and widget.onChangeLocale (already
plumbed at the MaterialApp level) down to OnboardingScreen so the
welcome-step language picker can render and operate.

One surgical edit on _buildEmptyProfileScaffold: appends two named
arguments to the OnboardingScreen constructor call.

REQUIRES that phase5_1d_followup_redo.py has been applied first (this
patch anchors on the `onImportFlow: _onboardingImportFlow,` line that
that script adds).

Run from the repo root.
Idempotent: detects sentinel and reports SKIP on second run.
"""

import sys
from pathlib import Path

TARGET = Path("lib/screens/main_screen.dart")
SENTINEL = "currentLocale: widget.locale,"

ANCHOR = """      onImportFlow: _onboardingImportFlow,
    );
  }

  // -------------------------------------------------------------------------
  // CALENDAR STRIP"""

REPLACEMENT = """      onImportFlow: _onboardingImportFlow,
      currentLocale: widget.locale,
      onChangeLocale: widget.onChangeLocale,
    );
  }

  // -------------------------------------------------------------------------
  // CALENDAR STRIP"""


def main():
    if not TARGET.exists():
        print(f"ERROR: {TARGET} not found. Run from repo root.", file=sys.stderr)
        sys.exit(1)

    src = TARGET.read_text(encoding="utf-8")

    if SENTINEL in src:
        print(f"SKIP: {TARGET} already passes locale to OnboardingScreen.")
        return

    n = src.count(ANCHOR)
    if n != 1:
        print(
            f"ERROR: anchor found {n} times (expected 1). "
            f"Did you run phase5_1d_followup_redo.py first? It adds the "
            f"`onImportFlow: _onboardingImportFlow,` line this script "
            f"anchors on. Aborting; no changes written.",
            file=sys.stderr,
        )
        sys.exit(2)

    out = src.replace(ANCHOR, REPLACEMENT)
    TARGET.write_text(out, encoding="utf-8")
    print(f"OK: applied 5.1d-lang main_screen wiring to {TARGET}")
    print(f"  - currentLocale: widget.locale passed to OnboardingScreen")
    print(f"  - onChangeLocale: widget.onChangeLocale passed to OnboardingScreen")


if __name__ == "__main__":
    main()