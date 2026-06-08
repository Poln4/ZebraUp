import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'timestamp_picker.dart';

/// Síntomas tab.
///
/// Sections:
/// 1. Zonas estructurales (chips) → structural event bottom sheet
/// 2. Registros de hoy (combined: symptoms + structurals, long-press to edit)
/// 3. En tendencia (últimos 7 días)
/// 4. Baúl de síntomas + inline add
/// 5. Actividad del día (catálogo + registros)
class SintomasTab extends StatefulWidget {
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onProfileChanged;

  const SintomasTab({
    super.key,
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onProfileChanged,
  });

  @override
  State<SintomasTab> createState() => _SintomasTabState();
}

class _SintomasTabState extends State<SintomasTab> {
  final _newSymptomCtrl = TextEditingController();

  static const _zones = [
    "Cervicales", "Hombros", "Muñecas", "Manos",
    "Lumbar/Pelvis", "Caderas", "Rodillas", "Tobillos",
  ];

  static const _structuralTypes = [
    "Subluxación", "Dislocación", "Inestabilidad Articular",
    "Dolor Articular", "Dolor Miofascial", "Dolor Neuropático",
  ];

  @override
  void dispose() {
    _newSymptomCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;
  Profile get _p => widget.profile;

  DateTime _timestampForLog() {
    final now = DateTime.now();
    final sel = widget.selectedDate;
    final isToday = sel.year == now.year && sel.month == now.month && sel.day == now.day;
    if (isToday) return now;
    return DateTime(sel.year, sel.month, sel.day, now.hour, now.minute, now.second);
  }

  Color _severityColor(SymptomSeverity sev) {
    final hex = sev.colorHex.substring(1);
    return Color(int.parse(hex, radix: 16) | 0xFF000000);
  }

  /// "Ninguna" is repurposed as the "I didn't rate it" sentinel per Phase 2C.
  bool _isUnrated(SymptomSeverity sev) => sev.label.toLowerCase() == 'ninguna';

  /// All severities EXCEPT "ninguna" — that one is reached via the skip link instead.
  List<SymptomSeverity> get _ratableSeverities =>
      SymptomSeverity.values.where((s) => !_isUnrated(s)).toList();

  /// Row of colored severity dots. Single-source dot picker for both
  /// log + edit flows. If `onTap` is provided, it fires immediately on tap;
  /// `selected` shows a ring around the chosen dot.
  Widget _buildDotPicker({
    SymptomSeverity? selected,
    required ValueChanged<SymptomSeverity> onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _ratableSeverities.map((sev) {
        final isSelected = selected == sev;
        return InkWell(
          onTap: () => onTap(sev),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _severityColor(sev),
                    border: Border.all(
                      color: isSelected ? _cc : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sev.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _cc,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final todaysStructs = _p.getStructuralForDay(widget.selectedDate);
    final todaysSymptoms = _p.getSymptomsForDay(widget.selectedDate);
    final todaysActivity = _p.getActivityForDay(widget.selectedDate);
    final trending = _p.getTrendingSymptoms();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. STRUCTURAL ZONES
        Text("ZONAS ESTRUCTURALES",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: _cc)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _zones
              .map((zone) => ActionChip(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: _cc),
                    label: Text(zone, style: TextStyle(color: _cc, fontSize: 12)),
                    onPressed: () => _openStructuralMenu(zone),
                  ))
              .toList(),
        ),

        // 2. TODAY'S COMBINED LOG
        if (todaysStructs.isNotEmpty || todaysSymptoms.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text("REGISTROS DE HOY",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: _cc)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: _cc)),
            child: Column(
              children: [
                ...todaysStructs.map((e) => InkWell(
                      onLongPress: () => _editStructuralEvent(e),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: _cc, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "[${DateFormat('HH:mm').format(e.timestamp)}] ${e.zone}: ${e.type}",
                                style: TextStyle(color: _cc, fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() => _p.structuralHistory.remove(e));
                                widget.onProfileChanged();
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
                ...todaysSymptoms.map((event) {
                  final unrated = _isUnrated(event.severity);
                  return InkWell(
                    onLongPress: () => _editSymptomEvent(event),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            unrated ? Icons.radio_button_unchecked : Icons.circle,
                            color: unrated ? Colors.grey : _severityColor(event.severity),
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  unrated
                                      ? "[${DateFormat('HH:mm').format(event.timestamp)}] ${event.name} · sin rating"
                                      : "[${DateFormat('HH:mm').format(event.timestamp)}] ${event.name} (${event.severity.label})",
                                  style: TextStyle(
                                    color: _cc,
                                    fontSize: 13,
                                    fontStyle: unrated ? FontStyle.italic : FontStyle.normal,
                                  ),
                                ),
                                if (event.note != null && event.note!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(event.note!,
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic)),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() => _p.symptomHistory.remove(event));
                              widget.onProfileChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text("Mantén pulsado un registro para editar fecha/gravedad/nota.",
              style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
        ],

        // 3. TRENDING
        const SizedBox(height: 28),
        Text("EN TENDENCIA (ÚLTIMOS 7 DÍAS)",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: _cc)),
        const SizedBox(height: 8),
        if (trending.isEmpty)
          const Text("No hay síntomas consistentes esta semana.",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 14))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trending
                .map((s) => ActionChip(
                      backgroundColor: _ic,
                      side: BorderSide(color: _cc, width: 2),
                      label: Text(s,
                          style: TextStyle(color: _cc, fontSize: 14, fontWeight: FontWeight.bold)),
                      onPressed: () => _openSeverityMenu(s),
                    ))
                .toList(),
          ),

        // 4. SYMPTOM VAULT + INLINE ADD
        const SizedBox(height: 28),
        Text("BAÚL DE SÍNTOMAS",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: _cc)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _p.symptomVault
              .map((s) => ActionChip(
                    backgroundColor: _ic,
                    side: const BorderSide(color: Colors.grey),
                    label: Text(s, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    onPressed: () => _openSeverityMenu(s),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _newSymptomCtrl,
          style: TextStyle(color: _cc),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addSymptomToVault(),
          decoration: InputDecoration(
            hintText: "+ Añadir síntoma al baúl...",
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(Icons.add, color: _cc),
              onPressed: _addSymptomToVault,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _addSymptomToVault() {
    final txt = _newSymptomCtrl.text.trim();
    if (txt.isEmpty) return;
    if (_p.symptomVault.contains(txt)) {
      _newSymptomCtrl.clear();
      return;
    }
    setState(() {
      _p.symptomVault.insert(0, txt);
      _newSymptomCtrl.clear();
    });
    widget.onProfileChanged();
  }

  // ---------------------------------------------------------------------------
  // STRUCTURAL MODALS (unchanged)
  // ---------------------------------------------------------------------------

  void _openStructuralMenu(String zone) {
    DateTime ts = _timestampForLog();
    showModalBottomSheet(
      context: context,
      backgroundColor: _ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: _cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("REGISTRAR EN: ${zone.toUpperCase()}",
                      style: TextStyle(color: _cc, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: BorderSide(color: _cc.withValues(alpha: 0.5))),
                    icon: Icon(Icons.access_time, color: _cc, size: 16),
                    label: Text(DateFormat('EEE d MMM, HH:mm').format(ts),
                        style: TextStyle(color: _cc, fontSize: 12)),
                    onPressed: () async {
                      final picked = await pickTimestamp(
                          context: ctx, initial: ts, contrastColor: _cc, inverseContrastColor: _ic);
                      if (picked != null) setSheet(() => ts = picked);
                    },
                  ),
                  const SizedBox(height: 16),
                  ..._structuralTypes.map((type) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.warning_amber_rounded, color: _cc),
                        title: Text(type, style: TextStyle(color: _cc, fontSize: 14)),
                        onTap: () {
                          setState(() => _p.structuralHistory
                              .add(StructuralEvent(timestamp: ts, zone: zone, type: type)));
                          widget.onProfileChanged();
                          Navigator.pop(ctx);
                        },
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editStructuralEvent(StructuralEvent event) {
    DateTime ts = event.timestamp;
    showModalBottomSheet(
      context: context,
      backgroundColor: _ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: _cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("EDITAR: ${event.zone.toUpperCase()} / ${event.type}",
                    style: TextStyle(color: _cc, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(side: BorderSide(color: _cc.withValues(alpha: 0.5))),
                  icon: Icon(Icons.access_time, color: _cc, size: 16),
                  label: Text(DateFormat('EEE d MMM, HH:mm').format(ts),
                      style: TextStyle(color: _cc, fontSize: 12)),
                  onPressed: () async {
                    final picked = await pickTimestamp(
                        context: ctx, initial: ts, contrastColor: _cc, inverseContrastColor: _ic);
                    if (picked != null) setSheet(() => ts = picked);
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cc,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    final idx = _p.structuralHistory.indexOf(event);
                    if (idx >= 0) {
                      setState(() => _p.structuralHistory[idx] = event.copyWith(timestamp: ts));
                      widget.onProfileChanged();
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text('GUARDAR', style: TextStyle(color: _ic, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SYMPTOM MODALS — now with dot picker + skip-rating link
  // ---------------------------------------------------------------------------

  void _openSeverityMenu(String symptom) {
    final noteCtrl = TextEditingController();
    DateTime ts = _timestampForLog();

    void saveWith(SymptomSeverity sev, BuildContext ctx) {
      final note = noteCtrl.text.trim();
      setState(() => _p.symptomHistory.add(SymptomEvent(
            timestamp: ts,
            name: symptom,
            severity: sev,
            note: note.isEmpty ? null : note,
          )));
      widget.onProfileChanged();
      Navigator.pop(ctx);
    }

    final unratedSentinel =
        SymptomSeverity.values.firstWhere((s) => _isUnrated(s), orElse: () => SymptomSeverity.values.first);

    showModalBottomSheet(
      context: context,
      backgroundColor: _ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: _cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symptom.toUpperCase(),
                      style: TextStyle(color: _cc, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: BorderSide(color: _cc.withValues(alpha: 0.5))),
                    icon: Icon(Icons.access_time, color: _cc, size: 16),
                    label: Text(DateFormat('EEE d MMM, HH:mm').format(ts),
                        style: TextStyle(color: _cc, fontSize: 12)),
                    onPressed: () async {
                      final picked = await pickTimestamp(
                          context: ctx, initial: ts, contrastColor: _cc, inverseContrastColor: _ic);
                      if (picked != null) setSheet(() => ts = picked);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    style: TextStyle(color: _cc),
                    decoration: const InputDecoration(
                      hintText: "Nota opcional (contexto, gatillo, etc.)",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("GRAVEDAD",
                      style: TextStyle(
                          color: _cc.withValues(alpha: 0.7),
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildDotPicker(onTap: (sev) => saveWith(sev, ctx)),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => saveWith(unratedSentinel, ctx),
                      child: Text(
                        "Logear sin rating",
                        style: TextStyle(
                          color: _cc.withValues(alpha: 0.7),
                          decoration: TextDecoration.underline,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editSymptomEvent(SymptomEvent event) {
    final noteCtrl = TextEditingController(text: event.note ?? '');
    DateTime ts = event.timestamp;
    SymptomSeverity sev = event.severity;

    showModalBottomSheet(
      context: context,
      backgroundColor: _ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: _cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("EDITAR: ${event.name.toUpperCase()}",
                      style: TextStyle(color: _cc, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: BorderSide(color: _cc.withValues(alpha: 0.5))),
                    icon: Icon(Icons.access_time, color: _cc, size: 16),
                    label: Text(DateFormat('EEE d MMM, HH:mm').format(ts),
                        style: TextStyle(color: _cc, fontSize: 12)),
                    onPressed: () async {
                      final picked = await pickTimestamp(
                          context: ctx, initial: ts, contrastColor: _cc, inverseContrastColor: _ic);
                      if (picked != null) setSheet(() => ts = picked);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    style: TextStyle(color: _cc),
                    decoration: const InputDecoration(
                        hintText: "Nota opcional", hintStyle: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),
                  Text("GRAVEDAD",
                      style: TextStyle(
                          color: _cc.withValues(alpha: 0.7),
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildDotPicker(
                    selected: _isUnrated(sev) ? null : sev,
                    onTap: (s) => setSheet(() => sev = s),
                  ),
                  if (_isUnrated(sev))
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        "Este registro no tiene rating. Tocá un punto para asignar uno.",
                        style: TextStyle(
                          color: _cc.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cc,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      final note = noteCtrl.text.trim();
                      final idx = _p.symptomHistory.indexOf(event);
                      if (idx >= 0) {
                        setState(() => _p.symptomHistory[idx] = event.copyWith(
                              timestamp: ts,
                              severity: sev,
                              note: note.isEmpty ? null : note,
                            ));
                        widget.onProfileChanged();
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text('GUARDAR CAMBIOS', style: TextStyle(color: _ic, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  