// Sprint Phase4.B — clinical PDF export, end-to-end.
//
// Thin glue: aggregate (pdf_report_aggregator) → render
// (pdf_report_renderer) → save (FileSaver). Mirrors the download
// pattern already used by ProfileIoService.exportProfile for JSON
// export — same package, same "browser download on web / share sheet
// on mobile" behavior.
//
// No UI here (Phase4.C — export configuration screen — is still
// pending). Call this directly with a PdfExportConfig until that
// screen exists.

import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

import '../models/models.dart';
import '../models/pdf_export_config.dart';
import 'pdf_report_aggregator.dart';
import 'pdf_report_renderer.dart';

class ClinicalExportService {
  /// Builds and downloads/shares a clinical PDF report for [profile]
  /// using [config]. Returns the suggested filename for confirmation.
  Future<String> exportClinicalReport(
    Profile profile,
    PdfExportConfig config,
  ) async {
    final data = aggregateClinicalReport(profile, config);
    final Uint8List bytes = config.isEmergencyCard
        ? await buildEmergencyCardPdf(aggregateEmergencyCard(profile))
        : await buildClinicalReportPdf(data);

    final filename = _filenameFor(profile, config);

    await FileSaver.instance.saveFile(
      name: filename,
      bytes: bytes,
      ext: 'pdf',
      mimeType: MimeType.pdf,
    );

    return '$filename.pdf';
  }

  String _filenameFor(Profile profile, PdfExportConfig config) {
    final safeName = profile.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final date = DateTime.now().toIso8601String().split('T').first;
    final kind = config.isEmergencyCard ? 'emergencia' : 'reporte';
    return 'zebraup-$kind-${safeName.isEmpty ? "perfil" : safeName}-$date';
  }
}
