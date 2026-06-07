#!/usr/bin/env python3
"""
Apply phase-2B (Botiquín redesign) patches to lib/screens/main_screen.dart.

Run from project root in your codespace:
    python3 apply_phase2b_patches.py

This script:
  1. Adds  `import 'botiquin_tab.dart';`  next to the other screen imports.
  2. Replaces the entire `_buildBotiquinTab(Color cc, Color ic) { ... }`
     method body with a thin wrapper that constructs `BotiquinTab`.

It does NOT delete `_buildMedRow`, `_logDose`, `_newMedNameController`, or
`_newMedDoseController`. They become unused after this patch — the analyzer
will flag them as dead code. You can remove them by hand later, but leaving
them in place is harmless and safer (in case any other tab references them).

Idempotent — running twice is safe. Backup at main_screen.dart.bak.bak2.
"""

import re
import shutil
import sys
from pathlib import Path

TARGET = Path("lib/screens/main_screen.dart")
BACKUP = Path("lib/screens/main_screen.dart.bak2")

if not TARGET.exists():
    print(f"ERROR: {TARGET} not found. Run from the project root.")
    sys.exit(1)

src = TARGET.read_text()
original = src
log: list[str] = []


def find_matching_brace(text: str, open_idx: int) -> int:
    """Given the index of `{`, return the index immediately after the matching `}`.
    Returns -1 if no match. Ignores braces inside `//` line comments and string
    literals (single/double-quoted)."""
    assert text[open_idx] == "{"
    depth = 0
    i = open_idx
    n = len(text)
    in_line_comment = False
    in_block_comment = False
    in_string: str | None = None  # quote char if inside a string, else None
    while i < n:
        c = text[i]
        nxt = text[i + 1] if i + 1 < n else ""

        if in_line_comment:
            if c == "\n":
                in_line_comment = False
        elif in_block_comment:
            if c == "*" and nxt == "/":
                in_block_comment = False
                i += 1
        elif in_string is not None:
            if c == "\\":
                i += 1  # skip escaped char
            elif c == in_string:
                in_string = None
        else:
            if c == "/" and nxt == "/":
                in_line_comment = True
                i += 1
            elif c == "/" and nxt == "*":
                in_block_comment = True
                i += 1
            elif c == "'" or c == '"':
                in_string = c
            elif c == "{":
                depth += 1
            elif c == "}":
                depth -= 1
                if depth == 0:
                    return i + 1
        i += 1
    return -1


# -----------------------------------------------------------------------------
# Patch 1 — Add botiquin_tab.dart import next to hoy_tab.dart import
# (or, failing that, next to the models import).
# -----------------------------------------------------------------------------
if "'botiquin_tab.dart'" in src:
    log.append("SKIP  1 (botiquin_tab import): already present")
else:
    anchor_hoy = "import 'hoy_tab.dart';"
    anchor_models = "import '../models/models.dart';"
    if anchor_hoy in src:
        src = src.replace(
            anchor_hoy,
            f"{anchor_hoy}\nimport 'botiquin_tab.dart';",
            1,
        )
        log.append("OK    1 (botiquin_tab import): added next to hoy_tab.dart import")
    elif anchor_models in src:
        src = src.replace(
            anchor_models,
            f"{anchor_models}\nimport 'botiquin_tab.dart';",
            1,
        )
        log.append("OK    1 (botiquin_tab import): added next to models.dart import")
    else:
        log.append(
            "SKIP  1 (botiquin_tab import): no anchor found; add manually: "
            "import 'botiquin_tab.dart';"
        )

# -----------------------------------------------------------------------------
# Patch 2 — Replace `_buildBotiquinTab(Color cc, Color ic) { ... }` whole method.
# Uses brace-counting so any-size method body is handled.
# -----------------------------------------------------------------------------
new_method = """Widget _buildBotiquinTab(Color cc, Color ic) {
    return BotiquinTab(
      profile: _activeProfile!,
      selectedDate: _selectedDate,
      contrastColor: cc,
      inverseContrastColor: ic,
      onProfileChanged: () {
        setState(() {});
        _saveData();
      },
    );
  }"""

# Detect already-migrated state
if "return BotiquinTab(" in src and "_buildBotiquinTab" in src:
    log.append("SKIP  2 (_buildBotiquinTab body): already returns BotiquinTab")
else:
    m = re.search(
        r"Widget\s+_buildBotiquinTab\s*\(\s*Color\s+cc\s*,\s*Color\s+ic\s*\)\s*\{",
        src,
    )
    if m is None:
        log.append(
            "SKIP  2 (_buildBotiquinTab body): method signature not found"
        )
    else:
        method_start = m.start()
        brace_open = m.end() - 1
        method_end = find_matching_brace(src, brace_open)
        if method_end < 0:
            log.append(
                "SKIP  2 (_buildBotiquinTab body): could not find matching closing brace"
            )
        else:
            old_method = src[method_start:method_end]
            old_line_count = old_method.count("\n") + 1
            src = src[:method_start] + new_method + src[method_end:]
            log.append(
                f"OK    2 (_buildBotiquinTab body): replaced "
                f"{old_line_count}-line method with {new_method.count(chr(10)) + 1}-line wrapper"
            )

# -----------------------------------------------------------------------------
# Patch 3 — flag (don't auto-remove) likely-dead code so the user knows.
# -----------------------------------------------------------------------------
dead_warnings: list[str] = []
for sym in (
    "_buildMedRow",
    "_logDose",
    "_newMedNameController",
    "_newMedDoseController",
):
    occurrences = src.count(sym)
    if occurrences > 0:
        # Only warn if the symbol is still defined AND has at most 1 reference
        # (the definition itself). Otherwise it's probably used elsewhere.
        if occurrences <= 2:
            dead_warnings.append(f"  • '{sym}' ({occurrences} occurrences)")
if dead_warnings:
    log.append(
        "INFO  3 (dead-code check): the following symbols are now likely unused.\n"
        "      Safe to remove by hand if you want a clean analyzer pass:\n"
        + "\n".join(dead_warnings)
    )

# -----------------------------------------------------------------------------
# Write back.
# -----------------------------------------------------------------------------
if src == original:
    print("No changes were necessary — file already migrated or no patterns matched.")
else:
    shutil.copy2(TARGET, BACKUP)
    TARGET.write_text(src)
    print(f"Backup saved to {BACKUP}")
    print(f"Wrote {TARGET}")

print()
print("Patch log:")
for line in log:
    print(f"  {line}")

print()
print("Now run:")
print("  flutter analyze")
print("  flutter run -d web-server")
print()
print("If any SKIP indicates a pattern wasn't found, paste the relevant")
print("region of main_screen.dart and we'll wire it up by hand.")