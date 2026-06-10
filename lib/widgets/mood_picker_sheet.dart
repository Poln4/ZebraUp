import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

/// Foxtale/Zebra-style mood picker.
/// Step 1: pick a quadrant. Step 2: multi-select state palette, view definitions,
/// optionally cross quadrants, optionally add context notes.
Future<MoodEntry?> showMoodPickerSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required Map<MoodQuadrant, List<EmaMood>> moodDictionary, // Pasamos el JSON cargado aquí
}) {
  return showModalBottomSheet<MoodEntry>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(side: BorderSide(color: contrastColor, width: 2)),
    builder: (_) => _MoodPickerSheetBody(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      moodDictionary: moodDictionary,
    ),
  );
}

class _MoodPickerSheetBody extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final Map<MoodQuadrant, List<EmaMood>> moodDictionary;

  const _MoodPickerSheetBody({
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.moodDictionary,
  });

  @override
  State<_MoodPickerSheetBody> createState() => _MoodPickerSheetBodyState();
}

class _MoodPickerSheetBodyState extends State<_MoodPickerSheetBody> {
  MoodQuadrant? _primary;
  final Set<String> _selected = {};
  bool _showOthers = false;
  final TextEditingController _notesController = TextEditingController();

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggle(String word) => setState(() {
        if (_selected.contains(word)) {
          _selected.remove(word);
        } else {
          _selected.add(word);
        }
      });

  void _save() {
    if (_primary == null || _selected.isEmpty) return;
    Navigator.pop(
      context,
      MoodEntry(
        timestamp: DateTime.now(),
        primaryQuadrant: _primary!,
        states: _selected.toList(),
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      ),
    );
  }

  void _showDefinitionDialog(EmaMood mood) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _ic,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _cc, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          mood.spanish.toUpperCase(),
          style: TextStyle(color: _cc, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          mood.definitionEs,
          style: TextStyle(color: _cc, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Entendido", style: TextStyle(color: _cc, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Evita que el teclado tape el campo de texto de notas
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: _primary == null ? _step1() : _step2(),
        ),
      ),
    );
  }

  Widget _step1() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("¿CÓMO TE SIENTES?",
            style: TextStyle(color: _cc, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _quadrantCard(MoodQuadrant.activatedUnpleasant)),
          const SizedBox(width: 8),
          Expanded(child: _quadrantCard(MoodQuadrant.activatedPleasant)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _quadrantCard(MoodQuadrant.calmUnpleasant)),
          const SizedBox(width: 8),
          Expanded(child: _quadrantCard(MoodQuadrant.calmPleasant)),
        ]),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancelar", style: TextStyle(color: _cc.withValues(alpha: 0.6))),
          ),
        ),
      ],
    );
  }

  Widget _quadrantCard(MoodQuadrant q) {
    return InkWell(
      onTap: () => setState(() {
        _primary = q;
        _selected.clear();
        _showOthers = false;
      }),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: _cc),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(q.label,
                textAlign: TextAlign.center,
                style: TextStyle(color: _cc.withValues(alpha: 0.6), fontSize: 10, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(q.teaserStates,
                textAlign: TextAlign.center,
                style: TextStyle(color: _cc, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _step2() {
    final primary = _primary!;
    final primaryMoods = widget.moodDictionary[primary] ?? [];
    
    // Obtener las emociones de los otros cuadrantes
    final otherMoods = widget.moodDictionary.entries
        .where((e) => e.key != primary)
        .expand((e) => e.value)
        .toSet()
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: _cc, width: 2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(primary.label,
                        style: TextStyle(color: _cc.withValues(alpha: 0.6), fontSize: 10)),
                    Text("¿cómo me siento?",
                        style: TextStyle(color: _cc, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _primary = null;
                  _selected.clear();
                  _showOthers = false;
                  _notesController.clear();
                }),
                child: Text("cambiar cuadrante",
                    style: TextStyle(color: _cc.withValues(alpha: 0.7), fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: primaryMoods.map(_chip).toList(),
        ),
        const SizedBox(height: 12),
        if (!_showOthers)
          TextButton(
            onPressed: () => setState(() => _showOthers = true),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
            child: Text("+ también siento… (otros cuadrantes)",
                style: TextStyle(color: _cc.withValues(alpha: 0.7), fontSize: 12)),
          )
        else ...[
          const SizedBox(height: 12),
          Text("TAMBIÉN SIENTO…",
              style: TextStyle(
                  color: _cc.withValues(alpha: 0.6),
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: otherMoods.map(_chip).toList()),
        ],
        const SizedBox(height: 24),
        
        // --- NUEVA SECCIÓN DE NOTAS ---
        Text("CONTEXTO (OPCIONAL)",
            style: TextStyle(
                color: _cc.withValues(alpha: 0.6),
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(color: _cc, fontSize: 14),
          decoration: InputDecoration(
            hintText: "Ej. Día con mucha niebla mental...",
            hintStyle: TextStyle(color: _cc.withValues(alpha: 0.3)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _cc.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _cc),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        // -----------------------------

        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _cc,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: _selected.isEmpty ? null : _save,
          child: Text("GUARDAR REGISTRO", style: TextStyle(color: _ic, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancelar", style: TextStyle(color: _cc.withValues(alpha: 0.6))),
          ),
        ),
      ],
    );
  }

  Widget _chip(EmaMood mood) {
    // Si el JSON falla y envía vacío, forzamos que diga "VACÍO" para poder verlo
    final displayText = mood.spanish.trim().isNotEmpty ? mood.spanish : "VACÍO";
    
    // Verificamos si ESTE texto específico está seleccionado
    final selected = _selected.contains(displayText);
    
    // Explicitly define text colors based on selection state to fix visibility issues
    final textColor = selected ? _ic : _cc; 
    final borderColor = selected ? _cc : _cc.withValues(alpha: 0.4);
    final iconColor = selected ? _ic.withValues(alpha: 0.8) : _cc.withValues(alpha: 0.6);

    return InkWell(
      onTap: () => _toggle(mood.spanish),
      // Permite mostrar la definición manteniendo presionado el botón entero
      onLongPress: () => _showDefinitionDialog(mood),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: selected ? _cc : Colors.transparent,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                mood.spanish,
                style: TextStyle(
                  color: textColor, // <--- Forzamos el color calculado aquí
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500, // Un poco más grueso para legibilidad
                )), 
            ),           
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showDefinitionDialog(mood), 
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// MoodSection UI Component Update
// =============================================================================

class MoodSection extends StatelessWidget {
  final Profile profile; // Asumo que es tu modelo de usuario/día
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final Map<MoodQuadrant, List<EmaMood>> moodDictionary; // Necesario inyectarlo aquí
  final void Function({
    required MoodQuadrant primaryQuadrant,
    required List<String> states,
    String? notes, // <--- Actualizado a notes
  }) onLogMood;
  final void Function(MoodEntry) onDeleteMood;

  const MoodSection({
    super.key,
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.moodDictionary,
    required this.onLogMood,
    required this.onDeleteMood,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final todaysMoods = profile.getMoodForDay(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("CÓMO ESTOY",
            style: TextStyle(color: cc, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final entry = await showMoodPickerSheet(
              context: context,
              contrastColor: contrastColor,
              inverseContrastColor: inverseContrastColor,
              moodDictionary: moodDictionary, // Se pasa el diccionario JSON cargado
            );
            if (entry != null) {
              onLogMood(
                primaryQuadrant: entry.primaryQuadrant,
                states: entry.states,
                notes: entry.notes,
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: cc, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.mood_outlined, color: cc, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    todaysMoods.isEmpty
                        ? "¿Cómo te sientes?"
                        : "Registrar otro estado",
                    style: TextStyle(color: cc, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.add, color: cc),
              ],
            ),
          ),
        ),
        if (todaysMoods.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: cc.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(6)),
            child: Column(
              children: todaysMoods.map((entry) {
                final timeStr = DateFormat('HH:mm').format(entry.timestamp);
                final statesStr = entry.states.join(', ');
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinea arriba si hay notas largas
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(Icons.circle, color: cc.withValues(alpha: 0.5), size: 8),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("[$timeStr] $statesStr", style: TextStyle(color: cc, fontSize: 13, fontWeight: FontWeight.w600)),
                            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                               const SizedBox(height: 2),
                               Text(entry.notes!, style: TextStyle(color: cc.withValues(alpha: 0.7), fontSize: 12, fontStyle: FontStyle.italic)),
                            ]
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => onDeleteMood(entry),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}