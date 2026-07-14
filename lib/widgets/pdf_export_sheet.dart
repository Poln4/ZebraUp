// Sprint Phase4.C — PDF export configuration sheet.
//
// Lets the user pick which sections, time range, and optional notes go
// into the clinical PDF report, then returns a PdfExportConfig for the
// caller to hand to ClinicalExportService. Pure UI — no I/O here,
// mirroring the TherapyLoggerSheet / MCAS detail sheet pattern (sheet
// returns a value; the calling screen does the async work).
//
// Color discipline: contrast-only palette (cc/ic), no accent colors —
// matches the rule codified after Sprint F.E2 beta feedback (see
// CLAUDE.md "Disciplina de Color").

import 'package:flutter/material.dart';
import '../models/pdf_export_config.dart';

/// Returns the user-configured PdfExportConfig, or null if cancelled.
Future<PdfExportConfig?> showPdfExportSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
}) {
  return showModalBottomSheet<PdfExportConfig>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (_) => _PdfExportBody(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
    ),
  );
}

class _PdfExportBody extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;

  const _PdfExportBody({
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  @override
  State<_PdfExportBody> createState() => _PdfExportBodyState();
}

class _PdfExportBodyState extends State<_PdfExportBody> {
  late Set<PdfSection> _sections;
  PdfTimeRange _range = PdfTimeRange.thirtyDays;
  late TextEditingController _notesCtrl;

  // Enum order drives visual order — matches PdfSection's own doc
  // comment convention in pdf_export_config.dart. emergencyCard is
  // deliberately excluded: it's a separate one-tap export, not a
  // toggle in the routine-consult configurator.
  static const _sectionLabels = {
    PdfSection.patientProfile: 'Datos del paciente',
    PdfSection.medications: 'Medicamentos',
    PdfSection.symptomsSummary: 'Resumen de síntomas',
    PdfSection.symptomsPatterns: 'Patrones detectados',
    PdfSection.mcasEvents: 'Eventos MCAS / alergias',
    PdfSection.structuralEvents: 'Eventos estructurales',
    PdfSection.mentalState: 'Estado mental (agregado)',
    PdfSection.actionsEffectiveness: 'Acciones y efectividad',
    PdfSection.patientNotes: 'Notas para tu especialista',
  };

  @override
  void initState() {
    super.initState();
    _sections = Set.of(PdfExportConfig.routineConsult().enabledSections);
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _toggleSection(PdfSection s) {
    setState(() {
      if (_sections.contains(s)) {
        _sections.remove(s);
      } else {
        _sections.add(s);
      }
    });
  }

  void _generate() {
    final notes = _notesCtrl.text.trim();
    final sections = Set<PdfSection>.from(_sections);
    // Notes only render if the section is enabled — auto-enable it
    // when the user typed something, so they don't lose it silently.
    if (notes.isNotEmpty) sections.add(PdfSection.patientNotes);

    Navigator.of(context).pop(
      PdfExportConfig(
        enabledSections: sections,
        timeRange: _range,
        patientNotes: notes,
      ),
    );
  }

  void _cancel() => Navigator.of(context).pop(null);

  Widget _sectionTitle(Color cc, String text) {
    return Text(
      text,
      style: TextStyle(
        color: cc.withValues(alpha: 0.6),
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required Color cc,
    required Color ic,
    required VoidCallback onTap,
  }) {
    final borderColor = selected ? cc : cc.withValues(alpha: 0.35);
    final bgColor = selected ? cc : Colors.transparent;
    final textColor = selected ? ic : cc;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: textColor, fontSize: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Exportar reporte clínico',
                      style: TextStyle(
                        color: cc,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: cc),
                    onPressed: _cancel,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Genera un PDF con tus datos para compartir en consulta. '
                'La información es autoreportada; no reemplaza una evaluación clínica.',
                style: TextStyle(color: cc.withValues(alpha: 0.65), fontSize: 12),
              ),

              const SizedBox(height: 20),
              _sectionTitle(cc, 'PERÍODO'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PdfTimeRange.values.map((r) {
                  final selected = _range == r;
                  return _chip(
                    label: r.label,
                    selected: selected,
                    cc: cc,
                    ic: ic,
                    onTap: () => setState(() => _range = r),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              _sectionTitle(cc, 'INCLUIR EN EL REPORTE'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sectionLabels.entries.map((entry) {
                  final selected = _sections.contains(entry.key);
                  return _chip(
                    label: entry.value,
                    selected: selected,
                    cc: cc,
                    ic: ic,
                    onTap: () => _toggleSection(entry.key),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              _sectionTitle(cc, 'NOTAS PARA TU ESPECIALISTA (OPCIONAL)'),
              const SizedBox(height: 6),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                style: TextStyle(color: cc, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Algo que quieras destacar antes de tu consulta…',
                  hintStyle: TextStyle(color: cc.withValues(alpha: 0.4)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: cc.withValues(alpha: 0.35)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: cc),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cc,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _sections.isEmpty ? null : _generate,
                  child: Text('Generar PDF', style: TextStyle(color: ic)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
