import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// Handles ARCO-rights operations on a profile: export, import, delete.
/// Schema version is embedded so future changes can be migrated.
class ProfileIoService {
  static const int schemaVersion = 1;

  /// Builds the export payload for a single profile.
  /// Includes the profile itself + companion Hive keys (hint state, wisdom).
  Map<String, dynamic> buildExportPayload(Profile profile) {
    final box = Hive.box('zebraBox');
    return {
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'ZebraUpp',
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
    final filename = 'zebraupp-${safeName.isEmpty ? "perfil" : safeName}-$date';

    await FileSaver.instance.saveFile(
      name: filename,
      bytes: bytes,
      ext: 'json',
      mimeType: MimeType.json,
    );

    return '$filename.json';
  }

  /// Opens the file picker, validates the payload, returns an ImportPreview
  /// so the UI can show the user what's about to land. Throws on validation
  /// failure with a human-readable message.
  Future<ImportPreview?> pickAndValidateImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final bytes = result.files.first.bytes;
    if (bytes == null) {
      throw 'No se pudo leer el archivo.';
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } catch (_) {
      throw 'El archivo no es JSON válido.';
    }

    if (data['app'] != 'ZebraUpp') {
      throw 'Este archivo no parece ser de ZebraUpp.';
    }
    if (data['schemaVersion'] is! int) {
      throw 'Versión de esquema desconocida.';
    }
    if (data['schemaVersion'] != schemaVersion) {
      throw 'Este archivo es de una versión diferente '
          '(v${data['schemaVersion']}). Versión esperada: v$schemaVersion.';
    }
    final profileMap = data['profile'];
    if (profileMap is! Map) {
      throw 'No se encontró perfil en el archivo.';
    }

    final Profile profile;
    try {
      profile = Profile.fromMap(Map<String, dynamic>.from(profileMap));
    } catch (e) {
      throw 'El perfil está dañado o tiene un formato inesperado.';
    }

    return ImportPreview(
      profile: profile,
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

  /// Applies a validated import as the active profile.
  /// Caller is responsible for replacing the in-memory profile + saving.
  Profile finalizeImport(ImportPreview preview, Map<String, dynamic> rawPayload) {
    final box = Hive.box('zebraBox');
    final companion = rawPayload['companionKeys'];
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

  /// Wipes the entire app state for this device. Truly destructive.
  Future<void> wipeEverything() async {
    final box = Hive.box('zebraBox');
    await box.clear();
  }
}

class ImportPreview {
  final Profile profile;
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
      symptomCount + doseCount + structuralCount + activityCount +
      therapyCount + moodCount + mentalCount;
}