// Sprint Phase4.B — clinical PDF report renderer.
//
// Purely presentational layer: given a ClinicalReportData (or
// EmergencyCardData), produces PDF bytes. No I/O, no Hive, no
// FileSaver — saving/sharing the result is the caller's job (see
// ClinicalExportService, which mirrors the FileSaver pattern already
// used by ProfileIoService.exportProfile for JSON export).
//
// Font choice: uses the `pdf` package's base14 Helvetica fonts. Their
// WinAnsi encoding covers the accented Latin characters ZebraUp's
// neutral LatAm Spanish needs (á é í ó ú ñ ¿ ¡) without bundling a
// custom TTF asset.
//
// Per docs/PHASE_5_ROADMAP.md §5.10: any clinical export must carry a
// clinician-facing caveat that the data is patient-logged, not
// clinician-validated — see _clinicianNote below. Do not remove this
// without an equivalent replacement; it's a trauma-informed / clinical
// accuracy requirement, not decoration.

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/clinical_report_data.dart';

const _kBodyFontSize = 10.0;
const _kHeadingColor = PdfColors.blueGrey800;
const _kMutedColor = PdfColors.grey600;
const _kUrgentColor = PdfColors.red800;

/// Renders a full clinical report (routine consult) to PDF bytes.
Future<Uint8List> buildClinicalReportPdf(ClinicalReportData data) async {
  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (context) => context.pageNumber == 1
          ? _buildTitleBlock(data.metadata)
          : pw.Container(),
      footer: (context) => _buildFooter(context),
      build: (context) => [
        _clinicianNote(),
        if (data.profile != null) _buildProfileSection(data.profile!),
        if (data.medications != null && !data.medications!.isEmpty)
          _buildMedicationsSection(data.medications!),
        if (data.symptoms != null && !data.symptoms!.isEmpty)
          _buildSymptomsSection(data.symptoms!),
        if (data.mcas != null) _buildMcasSection(data.mcas!),
        if (data.structural != null && !data.structural!.isEmpty)
          _buildStructuralSection(data.structural!),
        if (data.episodes != null && !data.episodes!.isEmpty)
          _buildEpisodesSection(data.episodes!),
        if (data.mentalState != null)
          _buildMentalStateSection(data.mentalState!),
        if (data.actions != null && !data.actions!.isEmpty)
          _buildActionsSection(data.actions!),
        if (data.patientNotes != null && data.patientNotes!.text.isNotEmpty)
          _buildPatientNotesSection(data.patientNotes!),
      ],
    ),
  );

  return doc.save();
}

/// Renders the compact single-page emergency card variant.
Future<Uint8List> buildEmergencyCardPdf(EmergencyCardData data) async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ZebraUp - Tarjeta de emergencia',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: _kHeadingColor,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generada ${_fmtDate(DateTime.now())} - datos autoreportados, no validados clínicamente',
            style: pw.TextStyle(fontSize: 8, color: _kMutedColor),
          ),
          pw.Divider(),
          if (data.patientDisplayName != null)
            _kv('Paciente', data.patientDisplayName!),
          if (data.dateOfBirth != null)
            _kv('Edad', '${_ageFrom(data.dateOfBirth!)} años'),
          if (data.conditions.isNotEmpty)
            _kv('Diagnósticos', data.conditions.join(', ')),
          if (data.allergiesAndTriggers.isNotEmpty)
            _kv(
              'Alergias / desencadenantes',
              data.allergiesAndTriggers.join(', '),
            ),
          if (data.activeMedications.isNotEmpty)
            _kv('Medicamentos', data.activeMedications.join('; ')),
          if (data.emergencyContacts.isNotEmpty)
            _kv('Contactos de emergencia', data.emergencyContacts.join('; ')),
          if (data.criticalNotes.isNotEmpty)
            _kv('Notas críticas', data.criticalNotes.join('; ')),
          if (data.recentRedFlags.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Señales de alerta MCAS recientes (últimos 30 días)',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _kUrgentColor,
              ),
            ),
            ...data.recentRedFlags.map(
              (f) => pw.Text(
                '${_fmtDate(f.occurredAt)} - ${_pdfSafe(f.label)}',
                style: pw.TextStyle(fontSize: _kBodyFontSize, color: _kUrgentColor),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  return doc.save();
}

// ============================================================
// Header / footer / caveat
// ============================================================

pw.Widget _buildTitleBlock(ReportMetadata metadata) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Text(
      'ZebraUp - Reporte clínico',
      style: pw.TextStyle(
        fontSize: 20,
        fontWeight: pw.FontWeight.bold,
        color: _kHeadingColor,
      ),
    ),
    pw.SizedBox(height: 4),
    pw.Text(
      '${metadata.rangeLabel} · generado ${_fmtDate(metadata.generatedAt)} · ZebraUp ${metadata.appVersion}',
      style: pw.TextStyle(fontSize: 9, color: _kMutedColor),
    ),
    pw.Divider(),
  ],
);

pw.Widget _clinicianNote() => pw.Container(
  margin: const pw.EdgeInsets.only(bottom: 12),
  padding: const pw.EdgeInsets.all(8),
  decoration: pw.BoxDecoration(
    border: pw.Border.all(color: _kMutedColor, width: 0.5),
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
  ),
  child: pw.Text(
    'Nota para el equipo clínico: los datos de este reporte son autoreportados '
    'por la paciente a través de la aplicación ZebraUp; no han sido validados '
    'clínicamente. Se presentan como apoyo para la conversación en consulta, '
    'no como diagnóstico. Los factores relacionados con sueño, ánimo o estado '
    'mental deben leerse en contexto trauma-informado.',
    style: pw.TextStyle(fontSize: 8, color: _kMutedColor),
  ),
);

pw.Widget _buildFooter(pw.Context context) => pw.Container(
  alignment: pw.Alignment.centerRight,
  margin: const pw.EdgeInsets.only(top: 8),
  child: pw.Text(
    'Página ${context.pageNumber} de ${context.pagesCount}',
    style: pw.TextStyle(fontSize: 8, color: _kMutedColor),
  ),
);

// ============================================================
// Sections
// ============================================================

pw.Widget _buildProfileSection(PatientProfileSection s) {
  final rows = <pw.Widget>[];
  if (s.displayName != null && s.displayName!.isNotEmpty) {
    rows.add(_kv('Paciente', s.displayName!));
  }
  if (s.dateOfBirth != null) {
    rows.add(_kv('Edad', '${_ageFrom(s.dateOfBirth!)} años'));
  }
  if (s.conditions.isNotEmpty) {
    rows.add(_kv('Diagnósticos', s.conditions.join(', ')));
  }
  if (s.allergies.isNotEmpty) {
    rows.add(_kv('Alergias / desencadenantes conocidos', s.allergies.join(', ')));
  }
  if (s.emergencyContacts.isNotEmpty) {
    rows.add(_kv('Contactos de emergencia', s.emergencyContacts.join('; ')));
  }
  if (rows.isEmpty) return pw.SizedBox();

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [_sectionHeading('Datos del paciente'), ...rows],
  );
}

pw.Widget _buildMedicationsSection(MedicationSection s) {
  pw.Widget table(String title, List<MedicationEntry> meds) {
    if (meds.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(2),
          },
          children: [
            _tableHeaderRow(['Medicamento', 'Dosis', 'Tomas', 'Cambio de severidad']),
            for (final m in meds)
              pw.TableRow(
                children: [
                  _cell(
                    m.name + (m.hadAdverseOutcomes ? ' (!)' : ''),
                    color: m.hadAdverseOutcomes ? _kUrgentColor : null,
                  ),
                  _cell(m.doseText ?? '-'),
                  _cell('${m.totalDoses}'),
                  _cell(_fmtImprovement(m.meanEffectiveness)),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 4),
      ],
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionHeading('Medicamentos'),
      table('Usados en el período', s.active),
      table('En Botiquín, sin uso registrado en el período', s.inactive),
      pw.Text(
        'Cambio de severidad = severidad reportada antes menos después de la '
        'dosis (positivo = mejora). (!) = al menos una toma con empeoramiento '
        'reportado tras la dosis.',
        style: pw.TextStyle(fontSize: 7, color: _kMutedColor),
      ),
    ],
  );
}

pw.Widget _buildSymptomsSection(SymptomSection s) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionHeading('Síntomas'),
      _kv('Total de eventos', '${s.totalEvents}'),
      _kv('Días con síntomas severos (intensa o más)', '${s.severeSymptomDays}'),
      pw.SizedBox(height: 4),
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(2),
        },
        children: [
          _tableHeaderRow(['Síntoma', 'Veces', 'Severidad media (0-4)']),
          for (final agg in s.topSymptoms)
            pw.TableRow(
              children: [
                _cell(agg.name),
                _cell('${agg.occurrences}'),
                _cell(agg.meanSeverity.toStringAsFixed(1)),
              ],
            ),
        ],
      ),
      if (s.otherSymptomsCount > 0)
        pw.Text(
          'y ${s.otherSymptomsCount} síntomas adicionales no mostrados.',
          style: pw.TextStyle(fontSize: 8, color: _kMutedColor),
        ),
      if (s.detectedPatterns.isNotEmpty) ...[
        pw.SizedBox(height: 6),
        pw.Text(
          'Patrones detectados',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        for (final p in s.detectedPatterns)
          pw.Text(
            '- ${_pdfSafe(p)}',
            style: const pw.TextStyle(fontSize: _kBodyFontSize),
          ),
      ],
    ],
  );
}

pw.Widget _buildMcasSection(MCASSection s) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionHeading('MCAS / alergias'),
      _kv('Eventos con detalle MCAS', '${s.totalEvents}'),
      if (s.commonReactions.isNotEmpty)
        _kv('Reacciones más frecuentes', s.commonReactions.join(', ')),
      if (s.commonTriggers.isNotEmpty)
        _kv('Desencadenantes más frecuentes', s.commonTriggers.join(', ')),
      if (s.redFlags.isNotEmpty) ...[
        pw.SizedBox(height: 6),
        pw.Text(
          'Señales de alerta',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _kUrgentColor,
          ),
        ),
        for (final f in s.redFlags)
          pw.Text(
            '${_fmtDate(f.occurredAt)} - ${_pdfSafe(f.label)}',
            style: pw.TextStyle(fontSize: _kBodyFontSize, color: _kUrgentColor),
          ),
      ],
    ],
  );
}

pw.Widget _buildStructuralSection(StructuralSection s) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionHeading('Eventos estructurales'),
      _kv('Total de eventos', '${s.totalEvents}'),
      for (final agg in s.byKind)
        pw.Text(
          '${_pdfSafe(agg.kindLabel)}: ${agg.occurrences} '
          '(${agg.regionCounts.entries.map((e) => '${_pdfSafe(e.key)}: ${e.value}').join(', ')})',
          style: const pw.TextStyle(fontSize: _kBodyFontSize),
        ),
    ],
  );
}

pw.Widget _buildEpisodesSection(EpisodeSection s) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionHeading('Cuadros temporales'),
      for (final ep in s.episodes) ...[
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4, bottom: 2),
          child: pw.Text(
            _pdfSafe(ep.title),
            style: pw.TextStyle(
              fontSize: _kBodyFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        _kv(
          'Periodo',
          ep.resolvedAt != null
              ? '${_fmtDate(ep.startDate)} - ${_fmtDate(ep.resolvedAt!)}'
              : '${_fmtDate(ep.startDate)} - en curso',
        ),
        if (ep.note != null && ep.note!.isNotEmpty) _kv('Nota', ep.note!),
        for (final occ in ep.symptoms)
          pw.Text(
            '- ${_fmtDate(occ.timestamp)}: ${_pdfSafe(occ.name)} '
            '(gravedad ${occ.severity})',
            style: const pw.TextStyle(fontSize: _kBodyFontSize),
          ),
      ],
    ],
  );
}

pw.Widget _buildMentalStateSection(MentalStateSection s) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionHeading('Estado mental y ánimo (agregado)'),
      _kv('Entradas registradas (niebla/fatiga, etc.)', '${s.totalEntries}'),
      if (s.cognitiveStateFrequency.isNotEmpty)
        _kv(
          'Estados más frecuentes',
          s.cognitiveStateFrequency.entries
              .map((e) => '${e.key} (${e.value})')
              .join(', '),
        ),
      if (s.totalMoodEntries > 0) ...[
        pw.SizedBox(height: 4),
        _kv('Registros de ánimo (EMA)', '${s.totalMoodEntries}'),
        if (s.meanValence != null && s.meanArousal != null)
          _kv(
            'Tendencia general',
            _moodTendencyLabel(s.meanValence!, s.meanArousal!),
          ),
        if (s.moodQuadrantFrequency.isNotEmpty)
          _kv(
            'Distribución por cuadrante',
            s.moodQuadrantFrequency.entries
                .map((e) => '${e.key} (${e.value})')
                .join(', '),
          ),
        if (s.moodWordFrequency.isNotEmpty)
          _kv(
            'Estados de ánimo más frecuentes',
            (s.moodWordFrequency.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .take(6)
                .map((e) => '${e.key} (${e.value})')
                .join(', '),
          ),
      ],
    ],
  );
}

/// Mirrors MoodQuadrantLabels.label (models.dart) using the aggregated
/// valence/arousal signs — kept as plain strings here so the renderer
/// stays decoupled from the mood model, per this file's presentational-
/// only design.
String _moodTendencyLabel(double valence, double arousal) {
  final pleasant = valence >= 0;
  final activated = arousal >= 0;
  if (activated && !pleasant) return 'activación · malestar';
  if (activated && pleasant) return 'activación · bienestar';
  if (!activated && !pleasant) return 'calma · malestar';
  return 'calma · bienestar';
}

pw.Widget _buildActionsSection(ActionsSection s) {
  pw.Widget table(String title, List<ActionEffectivenessEntry> entries) {
    if (entries.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(3),
          },
          children: [
            _tableHeaderRow(['Acción', 'Usos', 'Efectividad (0-4)', 'Usada con']),
            for (final e in entries)
              pw.TableRow(
                children: [
                  _cell(e.label),
                  _cell('${e.uses}'),
                  _cell(e.meanEffectiveness.toStringAsFixed(1)),
                  _cell(e.commonLinkedTo.join(', ')),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 4),
      ],
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _sectionHeading('Acciones y efectividad'),
      _kv('Total de acciones registradas', '${s.totalActions}'),
      table('Más efectivas', s.mostEffective),
      table('Menos efectivas', s.leastEffective),
    ],
  );
}

pw.Widget _buildPatientNotesSection(PatientNotesSection s) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    _sectionHeading('Para tu especialista'),
    pw.Text(_pdfSafe(s.text), style: const pw.TextStyle(fontSize: _kBodyFontSize)),
  ],
);

// ============================================================
// Small building blocks
// ============================================================

pw.Widget _sectionHeading(String title) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 12, bottom: 6),
  child: pw.Text(
    title,
    style: pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: _kHeadingColor,
    ),
  ),
);

pw.Widget _kv(String label, String value) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 2),
  child: pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: '${_pdfSafe(label)}: ',
          style: pw.TextStyle(
            fontSize: _kBodyFontSize,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.TextSpan(
          text: _pdfSafe(value),
          style: const pw.TextStyle(fontSize: _kBodyFontSize),
        ),
      ],
    ),
  ),
);

pw.TableRow _tableHeaderRow(List<String> labels) => pw.TableRow(
  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
  children: labels
      .map(
        (l) => pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            l,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ),
      )
      .toList(),
);

pw.Widget _cell(String text, {PdfColor? color}) => pw.Padding(
  padding: const pw.EdgeInsets.all(4),
  child: pw.Text(_pdfSafe(text), style: pw.TextStyle(fontSize: 9, color: color)),
);

/// CORRECTED 2026-07-16: an earlier version of this function assumed the
/// `pdf` package's base14 Helvetica supported the full WinAnsi (cp1252)
/// range, including the 0x80-0x9F typography extras (em/en dash, smart
/// quotes, bullet, ellipsis, trademark) — it doesn't. In practice it only
/// renders plain Latin-1 (ASCII + the accented Latin letters ZebraUp's
/// Spanish needs: á é í ó ú ñ ¿ ¡). Anything else — emoji, math symbols
/// (⚠, ≥), CJK, *and* those typography extras (confirmed broken: an em
/// dash rendered as a missing-glyph block) — shows as a broken glyph.
///
/// So this now does two passes: translate the handful of known-common
/// typography characters to plain ASCII equivalents (dashes → "-",
/// smart quotes → straight quotes, bullet → "-", ellipsis → "...",
/// trademark → "(TM)"), then drop anything still outside plain Latin-1.
/// Every dynamic string bound for the PDF passes through here — medication
/// names, symptom names, and free-text notes are user-entered and can
/// contain anything.
String _pdfSafe(String text) {
  final translated = text
      .replaceAll('–', '-') // en dash
      .replaceAll('—', '-') // em dash
      .replaceAll('‘', "'") // left single quote
      .replaceAll('’', "'") // right single quote
      .replaceAll('“', '"') // left double quote
      .replaceAll('”', '"') // right double quote
      .replaceAll('•', '-') // bullet
      .replaceAll('…', '...') // ellipsis
      .replaceAll('™', '(TM)'); // trademark
  final buf = StringBuffer();
  for (final rune in translated.runes) {
    if (rune <= 0x7F || (rune >= 0xA0 && rune <= 0xFF)) {
      buf.writeCharCode(rune);
    }
  }
  return buf.toString();
}

String _fmtImprovement(double? v) {
  if (v == null) return 'sin datos';
  final sign = v > 0 ? '+' : '';
  return '$sign${v.toStringAsFixed(1)}';
}

String _fmtDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

int _ageFrom(DateTime dob) {
  final now = DateTime.now();
  var age = now.year - dob.year;
  if (now.month < dob.month ||
      (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  return age;
}
