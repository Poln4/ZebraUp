import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/medline_plus_service.dart';

void showConditionInfoSheet({
  required BuildContext context,
  required String userCondition,
  required Color contrastColor,
  required Color inverseContrastColor,
  required MedlinePlusService service,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(side: BorderSide(color: contrastColor, width: 2)),
    builder: (_) => _ConditionInfoSheetBody(
      userCondition: userCondition,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      service: service,
    ),
  );
}

class _ConditionInfoSheetBody extends StatefulWidget {
  final String userCondition;
  final Color contrastColor;
  final Color inverseContrastColor;
  final MedlinePlusService service;

  const _ConditionInfoSheetBody({
    required this.userCondition,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.service,
  });

  @override
  State<_ConditionInfoSheetBody> createState() => _ConditionInfoSheetBodyState();
}

class _ConditionInfoSheetBodyState extends State<_ConditionInfoSheetBody> {
  bool _loading = true;
  MedlinePlusContent? _content;
  String? _errorMessage;
  String? _resolvedLabel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mapping = await widget.service.resolveCondition(widget.userCondition);
    if (mapping == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = "No tenemos esta condición en nuestro mapa todavía. "
              "Puedes buscarla manualmente en medlineplus.gov/spanish";
        });
      }
      return;
    }
    final content = await widget.service.getContent(mapping.icd10);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _content = content;
      _resolvedLabel = mapping.label;
      if (content == null) {
        _errorMessage = "Sin conexión, o MedlinePlus no respondió. Intenta de nuevo.";
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
        // Removido el padding inferior para que el ListView llegue hasta el final
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle con Semantics para lectores de pantalla
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
                Icon(Icons.health_and_safety_outlined, color: cc, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.userCondition,
                    style: TextStyle(color: cc, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: cc.withValues(alpha: 0.6), size: 22),
                  padding: EdgeInsets.zero,
                  // Reduce el tamaño del área de toque para que no empuje el layout
                  constraints: const BoxConstraints(), 
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (_resolvedLabel != null && _resolvedLabel != widget.userCondition)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  "MedlinePlus: $_resolvedLabel",
                  style: TextStyle(color: cc.withValues(alpha: 0.55), fontSize: 11, fontStyle: FontStyle.italic),
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
            Icon(Icons.cloud_off_outlined, color: cc.withValues(alpha: 0.5), size: 36),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? "No se pudo cargar la información.",
              textAlign: TextAlign.center,
              style: TextStyle(color: cc.withValues(alpha: 0.7), fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentBody(Color cc, Color ic, ScrollController scrollCtrl) {
    final c = _content!;
    
    // Envolvemos en Scrollbar explícito para mejorar visibilidad
    return Scrollbar(
      controller: scrollCtrl,
      thumbVisibility: true, 
      child: ListView(
        controller: scrollCtrl,
        // Agregamos padding inferior aquí para que no quede pegado al borde del teléfono
        padding: const EdgeInsets.only(bottom: 30, right: 8), 
        children: [
          if (c.title.isNotEmpty)
            SelectableText(
              c.title,
              style: TextStyle(color: cc, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 12),
          // ¡MEJORA UX CLAVE! SelectableText en lugar de Text
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
                style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () async {
                final uri = Uri.parse(c.link!);
                // Bypass del problema de 'canLaunchUrl' en Android 11+
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("No se pudo abrir el navegador. Revisa tu conexión."),
                        backgroundColor: cc,
                      ),
                    );
                  }
                }
              },
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: cc.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: cc.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Fuente: MedlinePlus, Biblioteca Nacional de Medicina de EE.UU. "
                    "No reemplaza consejo médico.",
                    style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11, height: 1.4),
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