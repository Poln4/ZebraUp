// =============================================================================
// DrugInfoSheet — Spanish patient education for medications via MedlinePlus
// Connect + RxNorm.
//
// Mirrors the structure of condition_info_sheet.dart but operates on
// MedicationDef objects and queries the drug-side methods of
// MedlinePlusService.
//
// Resolution cascade (handled by MedlinePlusService.resolveMedication):
//   activeIngredient -> name
//
// Confidence banner: shown when the resolved RxCUI was flagged as
// "medium" confidence in drug_codes.json. Reminds the reader to verify
// at RxNav if anything looks off.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/medline_plus_service.dart';

void showDrugInfoSheet({
  required BuildContext context,
  required MedicationDef med,
  required Color contrastColor,
  required Color inverseContrastColor,
  required MedlinePlusService service,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape:
        RoundedRectangleBorder(side: BorderSide(color: contrastColor, width: 2)),
    builder: (_) => _DrugInfoSheetBody(
      med: med,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      service: service,
    ),
  );
}

class _DrugInfoSheetBody extends StatefulWidget {
  final MedicationDef med;
  final Color contrastColor;
  final Color inverseContrastColor;
  final MedlinePlusService service;

  const _DrugInfoSheetBody({
    required this.med,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.service,
  });

  @override
  State<_DrugInfoSheetBody> createState() => _DrugInfoSheetBodyState();
}

class _DrugInfoSheetBodyState extends State<_DrugInfoSheetBody> {
  bool _loading = true;
  MedlinePlusDrugContent? _content;
  String? _errorMessage;
  String? _resolvedLabel;
  String? _mappingNotes;
  bool _isMediumConfidence = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mapping = await widget.service.resolveMedication(widget.med);
    if (mapping == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage =
              "No tenemos info detallada para este medicamento todavía. "
              "Puedes buscarlo manualmente en medlineplus.gov/spanish";
        });
      }
      return;
    }

    final content = await widget.service.getDrugInfo(mapping.rxcui);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _content = content;
      _resolvedLabel = mapping.label;
      _mappingNotes = mapping.notes;
      _isMediumConfidence = mapping.confidence != 'high';
      if (content == null) {
        _errorMessage = "MedlinePlus no devolvió información para este "
            "medicamento. Puede ser un problema temporal, o que el RxCUI "
            "(${mapping.rxcui}) no tenga contenido en español.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Semantics(
              label: "Deslizar para ajustar tamaño",
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cc.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.medication_outlined, color: cc, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.med.name,
                    style: TextStyle(
                        color: cc, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: cc.withValues(alpha: 0.6), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (_resolvedLabel != null &&
                _resolvedLabel!.toLowerCase() !=
                    widget.med.name.toLowerCase())
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  "MedlinePlus: $_resolvedLabel",
                  style: TextStyle(
                      color: cc.withValues(alpha: 0.55),
                      fontSize: 11,
                      fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: cc))
                  : _content == null
                      ? _errorState(cc)
                      : _contentBody(cc, ic, scrollCtrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(Color cc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                color: cc.withValues(alpha: 0.5), size: 36),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? "No se pudo cargar la información.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: cc.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentBody(Color cc, Color ic, ScrollController scrollCtrl) {
    final c = _content!;

    return Scrollbar(
      controller: scrollCtrl,
      thumbVisibility: true,
      child: ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(bottom: 30, right: 8),
        children: [
          // Curated clinical notes (e.g. discontinuation syndrome warning)
          if (_mappingNotes != null && _mappingNotes!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                border: Border.all(color: cc.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: cc, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      _mappingNotes!,
                      style: TextStyle(
                        color: cc,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (c.title.isNotEmpty)
            SelectableText(
              c.title,
              style: TextStyle(
                  color: cc, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 12),
          SelectableText(
            c.summary.isEmpty ? "Sin resumen disponible." : c.summary,
            style: TextStyle(color: cc, fontSize: 14, height: 1.55),
          ),
          const SizedBox(height: 20),
          if (c.link != null && c.link!.isNotEmpty)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cc),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(Icons.open_in_new, color: cc, size: 16),
              label: Text(
                "Leer más en MedlinePlus",
                style: TextStyle(
                    color: cc, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () async {
                final uri = Uri.parse(c.link!);
                try {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "No se pudo abrir el navegador. Revisa tu conexión."),
                        backgroundColor: cc,
                      ),
                    );
                  }
                }
              },
            ),
          const SizedBox(height: 12),
          if (_isMediumConfidence)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: cc.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.help_outline,
                      size: 14, color: cc.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Mapeo RxCUI con confianza media — verifica en RxNav "
                      "si la info no coincide con tu medicamento.",
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.6),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: cc.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: cc.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Fuente: MedlinePlus, Biblioteca Nacional de Medicina de "
                    "EE.UU. No reemplaza consejo médico.",
                    style: TextStyle(
                        color: cc.withValues(alpha: 0.6),
                        fontSize: 11,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
