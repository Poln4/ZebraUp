#!/usr/bin/env python3
"""
ZebraUp — Phase 5.1d-lang patch: lib/screens/onboarding_screen.dart
====================================================================

Adds a language picker to the welcome step of onboarding so users can
choose their language BEFORE completing the flow (instead of having to
finish onboarding first and then hunt for the toggle in Settings).

Three surgical edits:

  1. Add two new optional ctor params to OnboardingScreen:
       - currentLocale: Locale?
       - onChangeLocale: ValueChanged<Locale>?
     Both must be non-null for the picker to render — backwards compatible
     when not supplied.

  2. Insert the picker call at the top of _welcomeStep() Column children,
     before the medical_information_outlined Icon.

  3. Append the _buildLanguagePicker() method to the class, before the
     class-closing brace.

Run from the repo root.
Idempotent: detects sentinel and reports SKIP on second run.

Each language label is shown in its own writing system (ES / EN / 中) —
standard UX convention for language pickers.
"""

import sys
from pathlib import Path

TARGET = Path("lib/screens/onboarding_screen.dart")
SENTINEL = "Widget _buildLanguagePicker()"

# ---------------------------------------------------------------------------
# Edit 1: add ctor params + fields
# ---------------------------------------------------------------------------
CTOR_ANCHOR = """  final Future<Profile?> Function()? onImportFlow;

  const OnboardingScreen({
    super.key,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onComplete,
    this.onImportFlow,
  });"""

CTOR_REPLACEMENT = """  final Future<Profile?> Function()? onImportFlow;

  // PHASE 5.1d-lang — optional locale + change callback for the
  // welcome-step language picker. Both must be non-null for the picker
  // to render; if either is null, the picker is hidden (backwards
  // compatible).
  final Locale? currentLocale;
  final ValueChanged<Locale>? onChangeLocale;

  const OnboardingScreen({
    super.key,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onComplete,
    this.onImportFlow,
    this.currentLocale,
    this.onChangeLocale,
  });"""

# ---------------------------------------------------------------------------
# Edit 2: insert picker in _welcomeStep above the medical icon
# ---------------------------------------------------------------------------
WELCOME_ANCHOR = """        children: [
          Icon(Icons.medical_information_outlined, color: _cc, size: 48),"""

WELCOME_REPLACEMENT = """        children: [
          if (widget.currentLocale != null && widget.onChangeLocale != null) ...[
            _buildLanguagePicker(),
            const SizedBox(height: 20),
          ],
          Icon(Icons.medical_information_outlined, color: _cc, size: 48),"""

# ---------------------------------------------------------------------------
# Edit 3: append _buildLanguagePicker method before class close
# ---------------------------------------------------------------------------
METHOD_ANCHOR = """                              onPressed: () =>
                                  setState(() => _meds.removeAt(e.key)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}"""

METHOD_REPLACEMENT = """                              onPressed: () =>
                                  setState(() => _meds.removeAt(e.key)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PHASE 5.1d-lang — Language picker (welcome step only)
  // ---------------------------------------------------------------------------
  //
  // Each language is labeled in its own writing system — standard UX
  // convention for language pickers (don't translate "Spanish" into
  // English for a Spanish-speaker who doesn't read English yet).
  //
  // Tapping calls onChangeLocale, which lives at the MaterialApp level
  // and triggers a rebuild of the whole tree with the new locale —
  // including this onboarding screen. The picker re-renders with the
  // new selection highlighted.
  Widget _buildLanguagePicker() {
    final loc = widget.currentLocale;
    final cb = widget.onChangeLocale;
    if (loc == null || cb == null) return const SizedBox.shrink();

    final options = <(Locale, String)>[
      (const Locale('es'), 'ES'),
      (const Locale('en'), 'EN'),
      (const Locale('zh', 'TW'), '中'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.language, color: _cc.withValues(alpha: 0.55), size: 16),
        const SizedBox(width: 8),
        ...options.map((opt) {
          final selected = loc.languageCode == opt.$1.languageCode &&
              (opt.$1.countryCode == null ||
                  loc.countryCode == opt.$1.countryCode);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () => cb(opt.$1),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: selected ? _cc : Colors.transparent,
                  border: Border.all(
                    color: _cc.withValues(alpha: selected ? 1.0 : 0.35),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  opt.$2,
                  style: TextStyle(
                    color: selected ? _ic : _cc.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}"""


def main():
    if not TARGET.exists():
        print(f"ERROR: {TARGET} not found. Run from repo root.", file=sys.stderr)
        sys.exit(1)

    src = TARGET.read_text(encoding="utf-8")

    if SENTINEL in src:
        print(f"SKIP: {TARGET} already contains _buildLanguagePicker.")
        return

    edits = [
        (CTOR_ANCHOR, CTOR_REPLACEMENT, "ctor params + fields"),
        (WELCOME_ANCHOR, WELCOME_REPLACEMENT, "picker insertion in welcome step"),
        (METHOD_ANCHOR, METHOD_REPLACEMENT, "_buildLanguagePicker method"),
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
    print(f"OK: applied 5.1d-lang to {TARGET}")
    print(f"  - currentLocale + onChangeLocale ctor params (both optional)")
    print(f"  - language picker rendered atop welcome step when locale provided")
    print(f"  - _buildLanguagePicker method appended")


if __name__ == "__main__":
    main()