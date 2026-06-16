#!/usr/bin/env python3
"""
ZebraUp — Phase 5.1d follow-up (re-delivery)
============================================

Wires the onboarding import flow that was supposed to land in 5.1d but
never did (the follow-up script aborted last time on the zh-TW locale
anchor in main_screen.dart, and the remaining edits were never re-run).

Two surgical edits on lib/screens/main_screen.dart:

  1. Add `onImportFlow: _onboardingImportFlow,` to the OnboardingScreen
     constructor call inside _buildEmptyProfileScaffold.

  2. Append the _onboardingImportFlow method after _confirmAndApplyImport.
     Mirrors the validation logic of _importProfileFromFile and
     _importProfileFromPaste but returns Future<Profile?> instead of
     mutating _profiles directly. The OnboardingScreen passes the
     returned profile to onComplete, which uses the same persistence
     path as a fresh onboarding profile.

Run from the repo root.
Idempotent: detects sentinel and reports SKIP on second run.
"""

import sys
from pathlib import Path

TARGET = Path("lib/screens/main_screen.dart")
SENTINEL = "Future<Profile?> _onboardingImportFlow() async {"

# ---------------------------------------------------------------------------
# Edit 1: wire onImportFlow in _buildEmptyProfileScaffold
# ---------------------------------------------------------------------------
WIRING_ANCHOR = """        });
        await _fetchTodayWeather();
      },
    );
  }

  // -------------------------------------------------------------------------
  // CALENDAR STRIP"""

WIRING_REPLACEMENT = """        });
        await _fetchTodayWeather();
      },
      onImportFlow: _onboardingImportFlow,
    );
  }

  // -------------------------------------------------------------------------
  // CALENDAR STRIP"""

# ---------------------------------------------------------------------------
# Edit 2: append _onboardingImportFlow method after _confirmAndApplyImport.
# Anchored on the unique closing of that method (the importSuccess snack
# followed by the _wipeAllData method declaration).
# ---------------------------------------------------------------------------
METHOD_ANCHOR = """    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.importSuccess)));
    }
  }

  Future<void> _wipeAllData() async {"""

METHOD_REPLACEMENT = """    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.importSuccess)));
    }
  }

  // PHASE 5.1d follow-up — Onboarding import flow.
  //
  // Self-contained version of the file/paste import flow that returns
  // a Profile? for the OnboardingScreen to consume. The caller passes
  // the result to onComplete, which persists via the same path as a
  // fresh-onboarding profile. Validation logic mirrors
  // _importProfileFromFile + _importProfileFromPaste +
  // _confirmAndApplyImport, but skips the snackbar at the end (the
  // onboarding screen will dismiss itself on success).
  Future<Profile?> _onboardingImportFlow() async {
    final t = AppLocalizations.of(context)!;

    // Step 1: pick file vs paste
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(t.onboardingImportChoiceTitle),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'file'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.upload_file_outlined),
                  const SizedBox(width: 12),
                  Text(t.onboardingImportFromFile),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'paste'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.content_paste_go_outlined),
                  const SizedBox(width: 12),
                  Text(t.onboardingImportFromPaste),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return null;

    // Step 2: get ImportPreview based on chosen method
    ImportPreview? preview;
    try {
      if (choice == 'file') {
        preview = await _profileIo.pickAndValidateImport();
      } else {
        final ctrl = TextEditingController();
        final raw = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t.pasteImportTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.pasteImportInstructions,
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  maxLines: 6,
                  autofocus: true,
                  style: const TextStyle(fontSize: 11, fontFamily: 'Courier'),
                  decoration: InputDecoration(
                    hintText: t.pasteImportHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(t.actionCancel)),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, ctrl.text),
                  child: Text(t.actionImport)),
            ],
          ),
        );
        if (raw == null || raw.trim().isEmpty || !mounted) return null;
        preview = _profileIo.validateJsonString(raw.trim());
      }
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.importCancelled(_importErrorMessage(e, t)))),
      );
      return null;
    }

    if (preview == null || !mounted) return null;
    final p = preview; // local alias to satisfy null-safety in dialog builder

    // Step 3: confirmation dialog with preview details
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.importDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.importDialogName(p.profile.name),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (p.exportedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                t.importDialogExportedAt(
                    p.exportedAt!.toLocal().toString().split('.').first),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            Text(t.importDialogContains(p.totalEvents)),
            const SizedBox(height: 4),
            Text(
              '• ${p.symptomCount} ${t.nounSymptoms}\\n'
              '• ${p.doseCount} ${t.nounDoses}\\n'
              '• ${p.structuralCount} ${t.nounStructural}\\n'
              '• ${p.activityCount} ${t.nounActivities}\\n'
              '• ${p.therapyCount} ${t.nounTherapies}\\n'
              '• ${p.moodCount} ${t.nounMoods}\\n'
              '• ${p.mentalCount} ${t.nounMental}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(t.importDialogFootnote,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.actionCancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.actionImport)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return null;

    _profileIo.finalizeImport(p);

    // Return Profile with fresh id. The OnboardingScreen will pass this
    // to onComplete, which handles persistence (setState + _saveData).
    return Profile.fromMap({
      ...p.profile.toMap(),
      'id': '${DateTime.now().millisecondsSinceEpoch}-imported',
    });
  }

  Future<void> _wipeAllData() async {"""


def main():
    if not TARGET.exists():
        print(f"ERROR: {TARGET} not found. Run from repo root.", file=sys.stderr)
        sys.exit(1)

    src = TARGET.read_text(encoding="utf-8")

    if SENTINEL in src:
        print(f"SKIP: {TARGET} already contains _onboardingImportFlow.")
        return

    edits = [
        (WIRING_ANCHOR, WIRING_REPLACEMENT, "onImportFlow wiring"),
        (METHOD_ANCHOR, METHOD_REPLACEMENT, "_onboardingImportFlow method"),
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
    print(f"OK: applied 5.1d follow-up to {TARGET}")
    print(f"  - onImportFlow wired in _buildEmptyProfileScaffold")
    print(f"  - _onboardingImportFlow method appended")


if __name__ == "__main__":
    main()