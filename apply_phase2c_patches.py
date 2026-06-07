#!/usr/bin/env python3
"""
Apply phase-2C (Síntomas redesign) patch to lib/screens/main_screen.dart.

Run from project root in your codespace:
    python3 apply_phase2c_patches.py

This script:
  1. Adds  `import 'sintomas_tab.dart';`  next to the other tab imports.
  2. Replaces the entire `_buildSintomasTab(Color cc, Color ic) { ... }`
     method body with a thin wrapper that constructs `SintomasTab`.

It does NOT delete any of the old in-tab symptom-logging helpers
(`_openSeverityMenu`, `_editSymptomEvent`, etc.). They become unused after
this patch — analyzer will flag them as dead code. Safe to remove by hand
later; leaving them harms nothing.

Idempotent — second run reports SKIP on everything. Backup at
`main_screen.dart.bak3`.
"""

import re
import shutil
import sys
from pathlib import Path

TARGET = Path("lib/screens/main_screen.dart")
BACKUP = Path("lib/screens/main_screen.dart.bak3")

if not TARGET.exists():
    print(f"ERROR: {TARGET} not found. Run from the project root.")
    sys.exit(1)

src = TARGET.read_text()
original = src
log: list[str] = []


def find_matching_brace(text: str, open_idx: int) -> int:
    """Given the index of `{`, return the index immediately after the matching `}`.
    Honors // line comments, /* */ block comments, and string literals so braces
    inside them don't confuse the count."""
    assert text[open_idx] == "{"
    depth = 0
    i = open_idx
    n = len(text)
    in_line = False
    in_block = False
    in_string: str | None = None
    while i < n:
        c = text[i]
        nxt = text[i + 1] if i + 1 < n else ""
        if in_line:
            if c == "\n":
                in_line = False
        elif in_block:
            if c == "*" and nxt == "/":
                in_block = False
                i += 1
        elif in_string is not None:
            if c == "\\":
                i += 1
            elif c == in_string:
                in_string = None
        else:
            if c == "/" and nxt == "/":
                in_line = True
                i += 1
            elif c == "/" and nxt == "*":
                in_block = True
                i += 1
            elif c in ("'", '"'):
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
# Patch 1 — Add sintomas_tab.dart import.
# -----------------------------------------------------------------------------
if "'sintomas_tab.dart'" in src:
    log.append("SKIP  1 (sintomas_tab import): already present")
else:
    anchor_botiquin = "import 'botiquin_tab.dart';"
    anchor_hoy = "import 'hoy_tab.dart';"
    anchor_models = "import '../models/models.dart';"
    if anchor_botiquin in src:
        src = src.replace(
            anchor_botiquin,
            f"{anchor_botiquin}\nimport 'sintomas_tab.dart';",
            1,
        )
        log.append("OK    1 (sintomas_tab import): added next to botiquin_tab.dart import")
    elif anchor_hoy in src:
        src = src.replace(
            anchor_hoy,
            f"{anchor_hoy}\nimport 'sintomas_tab.dart';",
            1,
        )
        log.append("OK    1 (sintomas_tab import): added next to hoy_tab.dart import")
    elif anchor_models in src:
        src = src.replace(
            anchor_models,
            f"{anchor_models}\nimport 'sintomas_tab.dart';",
            1,
        )
        log.append("OK    1 (sintomas_tab import): added next to models.dart import")
    else:
        log.append(
            "SKIP  1 (sintomas_tab import): no anchor found; add manually: "
            "import 'sintomas_tab.dart';"
        )

# -----------------------------------------------------------------------------
# Patch 2 — Replace `_buildSintomasTab(Color cc, Color ic) { ... }` body.
# -----------------------------------------------------------------------------
new_method = """Widget _buildSintomasTab(Color cc, Color ic) {
    return SintomasTab(
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

if "return SintomasTab(" in src and "_buildSintomasTab" in src:
    log.append("SKIP  2 (_buildSintomasTab body): already returns SintomasTab")
else:
    m = re.search(
        r"Widget\s+_buildSintomasTab\s*\(\s*Color\s+cc\s*,\s*Color\s+ic\s*\)\s*\{",
        src,
    )
    if m is None:
        log.append(
            "SKIP  2 (_buildSintomasTab body): method signature not found"
        )
    else:
        method_start = m.start()
        brace_open = m.end() - 1
        method_end = find_matching_brace(src, brace_open)
        if method_end < 0:
            log.append(
                "SKIP  2 (_buildSintomasTab body): could not find matching closing brace"
            )
        else:
            old_method = src[method_start:method_end]
            old_lines = old_method.count("\n") + 1
            src = src[:method_start] + new_method + src[method_end:]
            log.append(
                f"OK    2 (_buildSintomasTab body): replaced "
                f"{old_lines}-line method with {new_method.count(chr(10)) + 1}-line wrapper"
            )

# -----------------------------------------------------------------------------
# Patch 3 — flag (don't auto-remove) likely-dead helpers.
# -----------------------------------------------------------------------------
dead_warnings: list[str] = []
for sym in (
    "_openSeverityMenu",
    "_editSymptomEvent",
    "_buildSymptomRow",
):
    occurrences = src.count(sym)
    if 0 < occurrences <= 2:
        dead_warnings.append(f"  • '{sym}' ({occurrences} occurrences)")
if dead_warnings:
    log.append(
        "INFO  3 (dead-code check): the following helpers may now be unused.\n"
        "      Safe to remove by hand for a clean analyzer pass:\n"
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
print("Don't forget to add image_picker to pubspec.yaml:")
print("  dependencies:")
print("    image_picker: ^1.0.7")
print()
print("Then run:")
print("  flutter pub get")
print("  flutter analyze")
print("  flutter run -d web-server")