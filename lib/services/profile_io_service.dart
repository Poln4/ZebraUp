import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

// =============================================================================
// Typed import errors
// =============================================================================
// The service stays UI-framework-free, so it never produces user-facing text.
// It throws ImportException with a code; the UI layer maps each code to a
// localized string via AppLocalizations. This is what makes the error messages
// translatable without dragging BuildContext into the service.

enum ImportErrorCode {
  unreadableFile,
  invalidJson,
  notZebraUp,
  unknownSchema,
  schemaMismatch,
  missingProfile,
  corruptProfile,
}

class ImportException implements Exception {
  final ImportErrorCode code;

  /// Optional machine detail — e.g. the schema version found, or the raw
  /// plugin error for debugging. Never shown to the user directly.
  final String? detail;

  ImportException(this.code, [this.detail]);

  @override
  String toString() =>
      'ImportException(${code.name}${detail == null ? '' : ': $detail'})';
}

// =============================================================================
// ProfileIoService
// =============================================================================

/// Handles ARCO-rights operations on a profile: export, import, delete.
/// Schema version is embedded so future changes can be migrated.
class ProfileIoService {
  // PHASE 5.2d — schema v3 (fever readings added; v1/v2 imports upcast)
  static const int schemaVersion = 3;

  // ---------------------------------------------------------------------------
  // EXPORT
  // ---------------------------------------------------------------------------

  /// Builds the export payload for a single profile.
  /// Includes the profile itself + companion Hive keys (hint state, wisdom).
  Map<String, dynamic> buildExportPayload(Profile profile) {
    final box = Hive.box('zebraBox');
    return {
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'ZebraUp',
      'profile': profile.toMap(),
      'companionKeys': {
        'hoyHintFirstSeen': box.get('hoyHintFirstSeen'),
        'hoyHintAcked': box.get('hoyHintAcked'),
        'wisdomDateKey': box.get('wisdomDateKey'),
        'wisdomIndex': box.get('wisdomIndex'),
      },
    };
  }

  /// Triggers a browser download (web) or share sheet (mobile).
  /// Returns the suggested filename for confirmation.
  Future<String> exportProfile(Profile profile) async {
    final payload = buildExportPayload(profile);
    final jsonStr = const JsonEncoder.withIndent('  ').convert(payload);
    final bytes = Uint8List.fromList(utf8.encode(jsonStr));

    final safeName = profile.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final date = DateTime.now().toIso8601String().split('T').first;
    final filename = 'zebraup-${safeName.isEmpty ? "perfil" : safeName}-$date';

    await FileSaver.instance.saveFile(
      name: filename,
      bytes: bytes,
      ext: 'json',
      mimeType: MimeType.json,
    );

    return '$filename.json';
  }

  // ---------------------------------------------------------------------------
  // IMPORT — shared validation core
  // ---------------------------------------------------------------------------

  /// Validates a raw JSON string and returns an ImportPreview.
  ///
  /// This is the single source of truth for import validation. Both entry
  /// points — file picker and paste-text — funnel through here, so the
  /// validation rules can never drift apart.
  ///
  /// Throws [ImportException] with a typed code on any failure.
  ImportPreview validateJsonString(String raw) {
    final Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(raw);
      data = Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      throw ImportException(ImportErrorCode.invalidJson);
    }

    if (data['app'] != 'ZebraUp') {
      throw ImportException(ImportErrorCode.notZebraUp);
    }
    if (data['schemaVersion'] is! int) {
      throw ImportException(ImportErrorCode.unknownSchema);
    }
    // PHASE 5.0 / 5.2d — schema version acceptance.
    // All historical versions are additive-safe: Profile.fromMap tolerates
    // missing keys, so v1 and v2 payloads upcast to v3 by having the new
    // collections come back empty. Extend `acceptedVersions` whenever a
    // new schema version is introduced and the upcast remains lossless.
    final importedVersion = data['schemaVersion'] as int;
    const acceptedVersions = {1, 2, 3};
    if (!acceptedVersions.contains(importedVersion)) {
      throw ImportException(
        ImportErrorCode.schemaMismatch,
        importedVersion.toString(),
      );
    }
    final profileMap = data['profile'];
    if (profileMap is! Map) {
      throw ImportException(ImportErrorCode.missingProfile);
    }

    final Profile profile;
    try {
      profile = Profile.fromMap(Map<String, dynamic>.from(profileMap));
    } catch (e) {
      throw ImportException(ImportErrorCode.corruptProfile, e.toString());
    }

    return ImportPreview(
      profile: profile,
      rawPayload: data,
      exportedAt: DateTime.tryParse(data['exportedAt'] as String? ?? ''),
      symptomCount: profile.symptomHistory.length,
      doseCount: profile.doseHistory.length,
      structuralCount: profile.structuralHistory.length,
      activityCount: profile.activityHistory.length,
      therapyCount: profile.therapyHistory.length,
      moodCount: profile.moodHistory.length,
      mentalCount: profile.mentalHistory.length,
    );
  }

  // ---------------------------------------------------------------------------
  // IMPORT — entry point A: file picker
  // ---------------------------------------------------------------------------

  /// Opens the file picker, reads the file, and validates via
  /// [validateJsonString]. Returns null if the user cancelled the picker.
  ///
  /// The FilePicker call itself is wrapped: if the plugin fails at the
  /// platform level (e.g. the web plugin registrant was not initialized —
  /// the LateInitializationError we hit in production), the raw error is
  /// converted into a typed ImportException instead of leaking a minified
  /// stack trace to the user.
  Future<ImportPreview?> pickAndValidateImport() async {
    final FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
    } catch (e) {
      throw ImportException(ImportErrorCode.unreadableFile, e.toString());
    }
    if (result == null || result.files.isEmpty) return null;

    final bytes = result.files.first.bytes;
    if (bytes == null) {
      throw ImportException(ImportErrorCode.unreadableFile);
    }

    final String raw;
    try {
      raw = utf8.decode(bytes);
    } catch (_) {
      throw ImportException(ImportErrorCode.unreadableFile);
    }

    return validateJsonString(raw);
  }

  // ---------------------------------------------------------------------------
  // IMPORT — entry point B: pasted text (plugin-free, PWA-safe)
  // ---------------------------------------------------------------------------
  // No dedicated method needed: the UI passes the pasted string directly to
  // validateJsonString(). Kept as a note so future readers know this is
  // intentional — the paste path must never grow plugin dependencies.

  // ---------------------------------------------------------------------------
  // FINALIZE
  // ---------------------------------------------------------------------------

  /// Applies the companion Hive keys from a validated import.
  /// Caller is responsible for adding the profile to memory + saving.
  Profile finalizeImport(ImportPreview preview) {
    final box = Hive.box('zebraBox');
    final companion = preview.rawPayload['companionKeys'];
    if (companion is Map) {
      if (companion['hoyHintFirstSeen'] != null) {
        box.put('hoyHintFirstSeen', companion['hoyHintFirstSeen']);
      }
      if (companion['hoyHintAcked'] != null) {
        box.put('hoyHintAcked', companion['hoyHintAcked']);
      }
      if (companion['wisdomDateKey'] != null) {
        box.put('wisdomDateKey', companion['wisdomDateKey']);
      }
      if (companion['wisdomIndex'] != null) {
        box.put('wisdomIndex', companion['wisdomIndex']);
      }
    }
    return preview.profile;
  }

  // ---------------------------------------------------------------------------
  // WIPE
  // ---------------------------------------------------------------------------

  /// Wipes the entire app state for this device. Truly destructive.
  Future<void> wipeEverything() async {
    final box = Hive.box('zebraBox');
    await box.clear();
  }

  // ---------------------------------------------------------------------------
  // PHASE 5.0 — Box migration
  // ---------------------------------------------------------------------------

  /// Migrates the local Hive box from any prior schema version to the
  /// current `schemaVersion`. Handles all upcast paths (v1->v3, v2->v3)
  /// from a single code path because every schema bump in Phase 5 is
  /// additive — only new collections appear, no existing field shapes
  /// change.
  ///
  /// Idempotent: if the box is already at the current schema version (or
  /// newer), returns immediately without writing anything.
  ///
  /// Before stamping the new version, this method snapshots every existing
  /// key/value pair into a single backup entry at
  /// `zebraBox_v{currentVersion}_backup_<timestamp>` so a user can roll
  /// back manually if migration ever proves catastrophic. The from-version
  /// is encoded in the backup key so historical migrations leave
  /// distinguishable artifacts (a v1->v3 backup vs a v2->v3 backup).
  ///
  /// Wire this from main.dart at startup: AFTER `Hive.openBox('zebraBox')`
  /// completes and BEFORE any read that depends on the new schema. The
  /// call is safe to make on every startup — repeated calls after the
  /// first are no-ops.
  ///
  /// Static because the method depends only on Hive, not on instance
  /// state. Throws [StateError] if the backup write fails — the version
  /// stamp is only applied after the backup is durable.
  static Future<void> migrateBoxIfNeeded() async {
    final box = Hive.box('zebraBox');
    final currentVersion = box.get('schemaVersion') as int? ?? 1;
    if (currentVersion >= schemaVersion) return;

    // Snapshot every existing key/value before any new write. Skip prior
    // backup entries (regardless of source version) and the schemaVersion
    // key itself so backups stay small and the version isn't double-recorded.
    final snapshot = <String, dynamic>{};
    for (final key in box.keys) {
      final keyStr = key.toString();
      if (keyStr.startsWith('zebraBox_v') && keyStr.contains('_backup_')) {
        continue;
      }
      if (keyStr == 'schemaVersion') continue;
      snapshot[keyStr] = box.get(key);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Dynamic key: encodes the FROM-version so backups are self-describing.
    final backupKey = 'zebraBox_v${currentVersion}_backup_$timestamp';

    try {
      await box.put(backupKey, snapshot);
    } catch (e) {
      // Backup failed — do NOT stamp the new version. Leave the box
      // untouched so the user can retry on next launch (or roll back the
      // app version).
      throw StateError(
          'zebraBox v$currentVersion->v$schemaVersion backup failed; migration aborted: $e');
    }

    // Only stamp the new schemaVersion AFTER the backup is durable.
    await box.put('schemaVersion', schemaVersion);
  }
}

// =============================================================================
// ImportPreview
// =============================================================================

class ImportPreview {
  final Profile profile;

  /// The full decoded payload, retained so finalizeImport can read
  /// companionKeys without re-parsing.
  final Map<String, dynamic> rawPayload;

  final DateTime? exportedAt;
  final int symptomCount;
  final int doseCount;
  final int structuralCount;
  final int activityCount;
  final int therapyCount;
  final int moodCount;
  final int mentalCount;

  ImportPreview({
    required this.profile,
    required this.rawPayload,
    required this.exportedAt,
    required this.symptomCount,
    required this.doseCount,
    required this.structuralCount,
    required this.activityCount,
    required this.therapyCount,
    required this.moodCount,
    required this.mentalCount,
  });

  int get totalEvents =>
      symptomCount +
      doseCount +
      structuralCount +
      activityCount +
      therapyCount +
      moodCount +
      mentalCount;
}