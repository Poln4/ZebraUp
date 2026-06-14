#!/usr/bin/env python3
"""
ZebraUp — Phase 5.0 patch: lib/services/profile_io_service.dart
===============================================================

- Bumps schemaVersion 1 → 2.
- Accepts v1 imports in validateJsonString (Profile.fromMap is additive-safe,
  so v1 payloads upcast to v2 with the new collections coming back empty).
- Adds ProfileIoService.migrateBoxIfNeeded() — backs up the v1 box state
  before stamping v2. Caller (main.dart) must await this AFTER Hive.openBox
  and BEFORE the UI builds.

Run from the repo root.
Idempotent: detects the sentinel and reports SKIP on second run.
"""

import sys
from pathlib import Path

TARGET = Path("lib/services/profile_io_service.dart")
SENTINEL = "// PHASE 5.0 — schema v2 migration"

# ---------------------------------------------------------------------------
# Edit 1: schemaVersion bump (1 → 2)
# ---------------------------------------------------------------------------
VERSION_ANCHOR = "  static const int schemaVersion = 1;"
VERSION_REPLACEMENT = "  static const int schemaVersion = 2;"

# ---------------------------------------------------------------------------
# Edit 2: validateJsonString — accept v1 imports
# ---------------------------------------------------------------------------
SCHEMA_CHECK_ANCHOR = """    if (data['schemaVersion'] is! int) {
      throw ImportException(ImportErrorCode.unknownSchema);
    }
    if (data['schemaVersion'] != schemaVersion) {
      throw ImportException(
        ImportErrorCode.schemaMismatch,
        data['schemaVersion'].toString(),
      );
    }"""

SCHEMA_CHECK_REPLACEMENT = """    if (data['schemaVersion'] is! int) {
      throw ImportException(ImportErrorCode.unknownSchema);
    }
    // PHASE 5.0 — schema v2 migration
    // Accept v1 exports verbatim: Profile.fromMap is additive-safe, so any
    // v1 payload upcasts to v2 by having the new collections come back
    // empty. Future versions (v3+) still mismatch.
    final importedVersion = data['schemaVersion'] as int;
    if (importedVersion != schemaVersion && importedVersion != 1) {
      throw ImportException(
        ImportErrorCode.schemaMismatch,
        importedVersion.toString(),
      );
    }"""

# ---------------------------------------------------------------------------
# Edit 3: add migrateBoxIfNeeded after wipeEverything
# ---------------------------------------------------------------------------
MIGRATE_ANCHOR = """  /// Wipes the entire app state for this device. Truly destructive.
  Future<void> wipeEverything() async {
    final box = Hive.box('zebraBox');
    await box.clear();
  }
}"""

MIGRATE_REPLACEMENT = """  /// Wipes the entire app state for this device. Truly destructive.
  Future<void> wipeEverything() async {
    final box = Hive.box('zebraBox');
    await box.clear();
  }

  // ---------------------------------------------------------------------------
  // PHASE 5.0 — Box migration
  // ---------------------------------------------------------------------------

  /// Migrates the local Hive box from schema v1 to v2 if needed.
  ///
  /// Idempotent: if the box is already at the current schema version (or
  /// newer), returns immediately without writing anything.
  ///
  /// Before stamping the new version, this method snapshots every existing
  /// key/value pair into a single backup entry at
  /// `zebraBox_v1_backup_<timestamp>` so a user can roll back manually if
  /// migration ever proves catastrophic. The backup is preserved for the
  /// rest of the v2 lifecycle.
  ///
  /// Wire this from main.dart at startup: AFTER `Hive.openBox('zebraBox')`
  /// completes and BEFORE any read that depends on the new schema. The call
  /// is safe to make on every startup — repeated calls after the first are
  /// no-ops.
  ///
  /// Static because the method depends only on Hive, not on instance state.
  /// Throws [StateError] if the backup write fails — the version stamp is
  /// only applied after the backup is durable.
  static Future<void> migrateBoxIfNeeded() async {
    final box = Hive.box('zebraBox');
    final currentVersion = box.get('schemaVersion') as int? ?? 1;
    if (currentVersion >= schemaVersion) return;

    // Snapshot every existing key/value before any new write. Skip prior
    // backup entries and the schemaVersion key itself so backups stay small
    // and the schemaVersion isn't double-recorded.
    final snapshot = <String, dynamic>{};
    for (final key in box.keys) {
      final keyStr = key.toString();
      if (keyStr.startsWith('zebraBox_v1_backup_')) continue;
      if (keyStr == 'schemaVersion') continue;
      snapshot[keyStr] = box.get(key);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupKey = 'zebraBox_v1_backup_$timestamp';

    try {
      await box.put(backupKey, snapshot);
    } catch (e) {
      // Backup failed — do NOT stamp v2. Leave the box untouched so the
      // user can retry on next launch (or roll back the app version).
      throw StateError(
          'zebraBox v1->v2 backup failed; migration aborted: $e');
    }

    // Only stamp v2 AFTER the backup is durable.
    await box.put('schemaVersion', schemaVersion);
  }
}"""


def main():
    if not TARGET.exists():
        print(f"ERROR: {TARGET} not found. Run from repo root.", file=sys.stderr)
        sys.exit(1)

    src = TARGET.read_text(encoding="utf-8")

    if SENTINEL in src:
        print(f"SKIP: {TARGET} already contains Phase 5.0 migration.")
        return

    edits = [
        (VERSION_ANCHOR, VERSION_REPLACEMENT, "schemaVersion bump"),
        (SCHEMA_CHECK_ANCHOR, SCHEMA_CHECK_REPLACEMENT, "import version check"),
        (MIGRATE_ANCHOR, MIGRATE_REPLACEMENT, "migrateBoxIfNeeded"),
    ]

    for anchor, _, label in edits:
        n = src.count(anchor)
        if n != 1:
            print(
                f"ERROR: anchor for '{label}' found {n} times (expected 1). Aborting; no changes written.",
                file=sys.stderr,
            )
            sys.exit(2)

    out = src
    for anchor, insertion, _ in edits:
        out = out.replace(anchor, insertion)

    TARGET.write_text(out, encoding="utf-8")
    print(f"OK: applied Phase 5.0 io-service changes to {TARGET}")
    print(f"  - schemaVersion: 1 -> 2")
    print(f"  - validateJsonString now accepts v1 imports (additive upcast)")
    print(f"  - ProfileIoService.migrateBoxIfNeeded() added (STATIC method)")
    print(f"")
    print(f"NEXT (manual): wire ProfileIoService.migrateBoxIfNeeded() into")
    print(f"  main.dart right after Hive.openBox('zebraBox') completes.")


if __name__ == "__main__":
    main()