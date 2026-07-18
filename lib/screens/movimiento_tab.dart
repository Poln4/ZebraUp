// =============================================================================
// Movimiento y Recuperación tab.
//
// Activity and therapy live here as PEERS, not as primary/secondary. Both are
// equally valid forms of body care for EDS/HSD/MPS patients managing kinesio-
// phobia and pacing requirements.
//
// Sources informing the design:
//   • Buryk-Iggers et al. (2022) — exercise & rehab in EDS; pacing
//   • Maarj et al. (2022) — e-VAS for pre/post pain rating
//   • Steen, Jaiswal & Kumbhare (2025) — MPS modalities catalog
//   • Heiskari et al. (2026) — autonomy-supportive design, anti-streak
//   • Lee et al. (2025) — reward parity for active and passive interventions
//
// Layout:
//   1. Pacing acknowledgment (if today is a rest day)
//   2. "Hoy hiciste…" — combined chronological log, both event types
//   3. Actividad — catalog + custom add
//   4. Terapia — catalog + custom add
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../widgets/therapy_logger_sheet.dart';
import 'timestamp_picker.dart';
import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';

class MovimientoTab extends StatefulWidget {
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onProfileChanged;

  const MovimientoTab({
    super.key,
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onProfileChanged,
  });

  @override
  State<MovimientoTab> createState() => _MovimientoTabState();
}

class _MovimientoTabState extends State<MovimientoTab> {
  final _newExerciseCtrl = TextEditingController();
  final _newTherapyModalityCtrl = TextEditingController();

  @override
  void dispose() {
    _newExerciseCtrl.dispose();
    _newTherapyModalityCtrl.dispose();
    super.dispose();
  }

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;
  Profile get _p => widget.profile;

  DateTime _timestampForLog() {
    final now = DateTime.now();
    final sel = widget.selectedDate;
    final isToday =
        sel.year == now.year && sel.month == now.month && sel.day == now.day;
    if (isToday) return now;
    return DateTime(
      sel.year,
      sel.month,
      sel.day,
      now.hour,
      now.minute,
      now.second,
    );
  }

  String _getDateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPacing = _p.state.pacingDays.contains(
      _getDateKey(widget.selectedDate),
    );
    final todaysActivity = _p.getActivityForDay(widget.selectedDate);
    final todaysTherapy = _p.getTherapyForDay(widget.selectedDate);

    // Combined chronological list, newest first.
    final combined = <_DayLogEntry>[
      ...todaysActivity.map((a) => _DayLogEntry.activity(a, l10n)),
      ...todaysTherapy.map((t) => _DayLogEntry.therapy(t, l10n)),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. PACING ACKNOWLEDGMENT
        if (isPacing) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: _cc.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: _cc, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.movementSectionPacingActive,
                    style: TextStyle(
                      color: _cc,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 2. COMBINED TODAY LOG
        if (combined.isNotEmpty) ...[
          Text(
            l10n.movementSectionHistoryTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 14,
              color: _cc,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: _cc)),
            child: Column(children: combined.map(_buildLogRow).toList()),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.movementFootnoteLongPressEdit,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 28),
        ] else if (!isPacing) ...[
          // Soft empty state, anti-kinesiophobia framing
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: _cc.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.movementEmptyStateHeadline,
                  style: TextStyle(
                    color: _cc,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.movementEmptyStateSubtitle,
                  style: TextStyle(
                    color: _cc.withValues(alpha: 0.7),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 3. ACTIVITY CATALOG
        Text(
          l10n.movementSectionActivityTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 14,
            color: _cc,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...kExerciseCatalog.map(
              (ex) => ActionChip(
                backgroundColor: Colors.transparent,
                side: BorderSide(color: _cc),
                avatar: Icon(Icons.fitness_center, color: _cc, size: 14),
                label: Text(
                  ex.name,
                  style: TextStyle(color: _cc, fontSize: 12),
                ),
                onPressed: () => _openActivityMenu(ex),
              ),
            ),
            ..._p.customExercises.map(
              (name) => _customCatalogChip(
                label: name,
                icon: Icons.fitness_center,
                onTap: () => _openActivityMenu(
                  ExerciseDef(name, 'Custom', durationBased: true),
                ),
                onDelete: () => _deleteCustomExercise(name),
                onRename: () => _renameCustomExercise(name),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _newExerciseCtrl,
          style: TextStyle(color: _cc),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addCustomExercise(),
          decoration: InputDecoration(
            hintText: l10n.movementActivityPlaceholder,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(Icons.add, color: _cc),
              onPressed: _addCustomExercise,
            ),
          ),
        ),

        // 4. THERAPY CATALOG
        const SizedBox(height: 28),
        Text(
          l10n.movementSectionTherapyTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 14,
            color: _cc,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...kTherapyCatalog.map(
              (m) => ActionChip(
                backgroundColor: Colors.transparent,
                side: BorderSide(color: _cc),
                avatar: Icon(Icons.healing_outlined, color: _cc, size: 14),
                label: Text(m, style: TextStyle(color: _cc, fontSize: 12)),
                onPressed: () => _logTherapy(m),
              ),
            ),
            ..._p.customTherapyModalities.map(
              (m) => _customCatalogChip(
                label: m,
                icon: Icons.healing_outlined,
                onTap: () => _logTherapy(m),
                onDelete: () => _deleteCustomTherapyModality(m),
                onRename: () => _renameCustomTherapyModality(m),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _newTherapyModalityCtrl,
          style: TextStyle(color: _cc),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addCustomTherapyModality(),
          decoration: InputDecoration(
            hintText: l10n.movementTherapyPlaceholder,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(Icons.add, color: _cc),
              onPressed: _addCustomTherapyModality,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // COMBINED LOG ROW
  // ---------------------------------------------------------------------------

  Widget _buildLogRow(_DayLogEntry entry) {
    final time = DateFormat('HH:mm').format(entry.timestamp);
    return InkWell(
      onLongPress: entry.isActivity
          ? () => _editActivity(entry.activity!)
          : () => _editTherapy(entry.therapy!),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(entry.icon, color: _cc, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "[$time] ${entry.title}",
                    style: TextStyle(
                      color: _cc,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (entry.subtitle.isNotEmpty)
                    Text(
                      entry.subtitle,
                      style: TextStyle(
                        color: _cc.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  if (entry.isActivity) {
                    _p.activityHistory.remove(entry.activity);
                  } else {
                    _p.therapyHistory.remove(entry.therapy);
                  }
                });
                widget.onProfileChanged();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CUSTOM ADDS
  // ---------------------------------------------------------------------------

  void _addCustomExercise() {
    final txt = _newExerciseCtrl.text.trim();
    if (txt.isEmpty || _p.customExercises.contains(txt)) {
      _newExerciseCtrl.clear();
      return;
    }
    setState(() => _p.customExercises = [..._p.customExercises, txt]);
    _newExerciseCtrl.clear();
    widget.onProfileChanged();
  }

  void _addCustomTherapyModality() {
    final txt = _newTherapyModalityCtrl.text.trim();
    if (txt.isEmpty ||
        _p.customTherapyModalities.contains(txt) ||
        kTherapyCatalog.contains(txt)) {
      _newTherapyModalityCtrl.clear();
      return;
    }
    setState(
      () => _p.customTherapyModalities = [..._p.customTherapyModalities, txt],
    );
    _newTherapyModalityCtrl.clear();
    widget.onProfileChanged();
  }

  // ---------------------------------------------------------------------------
  // CUSTOM CATALOG CHIP — tap logs (unchanged behavior), delete icon removes
  // it from the catalog, long-press renames. Only for user-added entries —
  // kExerciseCatalog/kTherapyCatalog stay as plain ActionChip (not editable).
  // ---------------------------------------------------------------------------

  Widget _customCatalogChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onDelete,
    required VoidCallback onRename,
  }) {
    return GestureDetector(
      onLongPress: onRename,
      child: InputChip(
        backgroundColor: Colors.transparent,
        side: BorderSide(color: _cc),
        avatar: Icon(icon, color: _cc, size: 14),
        label: Text(label, style: TextStyle(color: _cc, fontSize: 12)),
        deleteIconColor: _cc,
        onPressed: onTap,
        onDeleted: onDelete,
      ),
    );
  }

  void _deleteCustomExercise(String name) {
    setState(
      () => _p.customExercises = _p.customExercises
          .where((e) => e != name)
          .toList(),
    );
    widget.onProfileChanged();
  }

  void _deleteCustomTherapyModality(String name) {
    setState(
      () => _p.customTherapyModalities = _p.customTherapyModalities
          .where((e) => e != name)
          .toList(),
    );
    widget.onProfileChanged();
  }

  Future<String?> _promptRename(String currentName) {
    final ctrl = TextEditingController(text: currentName);
    final l10n = context.l10n;
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.movementRenameDialogTitle),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  Future<void> _renameCustomExercise(String oldName) async {
    final newName = await _promptRename(oldName);
    if (newName == null || newName.isEmpty || newName == oldName) return;
    final idx = _p.customExercises.indexOf(oldName);
    if (idx < 0) return;
    setState(() {
      final updated = List<String>.from(_p.customExercises);
      updated[idx] = newName;
      _p.customExercises = updated;
    });
    widget.onProfileChanged();
  }

  Future<void> _renameCustomTherapyModality(String oldName) async {
    final newName = await _promptRename(oldName);
    if (newName == null || newName.isEmpty || newName == oldName) return;
    final idx = _p.customTherapyModalities.indexOf(oldName);
    if (idx < 0) return;
    setState(() {
      final updated = List<String>.from(_p.customTherapyModalities);
      updated[idx] = newName;
      _p.customTherapyModalities = updated;
    });
    widget.onProfileChanged();
  }

  // ---------------------------------------------------------------------------
  // THERAPY
  // ---------------------------------------------------------------------------

  Future<void> _logTherapy(String modality) async {
    final result = await showTherapyLoggerSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      modality: modality,
      defaultTimestamp: _timestampForLog(),
    );
    if (result == null) return;
    setState(() => _p.therapyHistory.add(result));
    widget.onProfileChanged();
  }

  Future<void> _editTherapy(TherapyEvent existing) async {
    final result = await showTherapyLoggerSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      modality: existing.modality,
      defaultTimestamp: existing.timestamp,
      existing: existing,
    );
    if (result == null) return;
    final idx = _p.therapyHistory.indexOf(existing);
    if (idx >= 0) {
      setState(() => _p.therapyHistory[idx] = result);
      widget.onProfileChanged();
    }
  }

  // ---------------------------------------------------------------------------
  // ACTIVITY (with optional pre/post pain e-VAS)
  // ---------------------------------------------------------------------------

  static const _painColors = [
    Color(0xFF81C784), // 0
    Color(0xFFAED581), // 1
    Color(0xFFFFD54F), // 2
    Color(0xFFFFB74D), // 3
    Color(0xFFE57373), // 4
  ];

  void _openActivityMenu(ExerciseDef ex) {
    _showActivitySheet(ex: ex);
  }

  void _editActivity(ActivityEvent existing) {
    _showActivitySheet(existing: existing);
  }

  void _showActivitySheet({ExerciseDef? ex, ActivityEvent? existing}) {
    final isEdit = existing != null;
    DateTime ts = existing?.timestamp ?? _timestampForLog();
    final name = existing?.name ?? ex!.name;
    final durationBased = existing != null
        ? (existing.durationMinutes != null && existing.durationMinutes! > 0)
        : ex!.durationBased;

    final setsCtrl = TextEditingController(
      text: existing?.sets?.toString() ?? '',
    );
    final repsCtrl = TextEditingController(
      text: existing?.reps?.toString() ?? '',
    );
    final durationCtrl = TextEditingController(
      text: existing?.durationMinutes?.toString() ?? '',
    );
    final hhrCtrl = TextEditingController(text: existing?.hhr ?? '');
    final noteCtrl = TextEditingController(text: existing?.note ?? '');
    int effort = existing?.effort ?? 5;
    int feeling = existing?.feeling ?? 3;
    int? painBefore = existing?.painBefore;
    int? painAfter = existing?.painAfter;
    bool showPain = painBefore != null || painAfter != null;

    final l10n = context.l10n;
    String feelingLabel(int v) => switch (v) {
      1 => l10n.movementFeelingPainOrInjury,
      2 => l10n.movementFeelingUncomfortable,
      3 => l10n.movementFeelingNeutral,
      4 => l10n.movementFeelingRelaxed,
      5 => l10n.movementFeelingStrongConfident,
      _ => '$v',
    };
    final painLabels = <String>[
      l10n.movementPainLevelNone,
      l10n.movementPainLevelMild,
      l10n.movementPainLevelModerate,
      l10n.movementPainLevelIntense,
      l10n.movementPainLevelSevere,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: _ic,
      shape: RoundedRectangleBorder(side: BorderSide(color: _cc, width: 2)),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit
                        ? l10n.movementModalTitleEditTemplate(
                            name.toUpperCase(),
                          )
                        : l10n.movementModalTitleRegisterTemplate(
                            name.toUpperCase(),
                          ),
                    style: TextStyle(
                      color: _cc,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _cc.withValues(alpha: 0.5)),
                    ),
                    icon: Icon(Icons.access_time, color: _cc, size: 16),
                    label: Text(
                      DateFormat('EEE d MMM, HH:mm').format(ts),
                      style: TextStyle(color: _cc, fontSize: 12),
                    ),
                    onPressed: () async {
                      final picked = await pickTimestamp(
                        context: ctx,
                        initial: ts,
                        contrastColor: _cc,
                        inverseContrastColor: _ic,
                      );
                      if (picked != null) setSheet(() => ts = picked);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Sets/reps OR duration
                  if (durationBased)
                    TextField(
                      controller: durationCtrl,
                      style: TextStyle(color: _cc),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: l10n.movementModalHintDuration,
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: setsCtrl,
                            style: TextStyle(color: _cc),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: l10n.movementModalHintSets,
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: repsCtrl,
                            style: TextStyle(color: _cc),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: l10n.movementModalHintReps,
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: hhrCtrl,
                    style: TextStyle(color: _cc),
                    decoration: InputDecoration(
                      hintText: l10n.movementModalHintHeartRate,
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Effort
                  Text(
                    l10n.movementModalEffortLabelTemplate(effort),
                    style: TextStyle(
                      color: _cc,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Slider(
                    value: effort.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    activeColor: _cc,
                    label: '$effort',
                    onChanged: (v) => setSheet(() => effort = v.toInt()),
                  ),

                  // Feeling
                  Text(
                    l10n.movementModalFeelingLabelTemplate(feeling),
                    style: TextStyle(
                      color: _cc,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    feelingLabel(feeling),
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  Slider(
                    value: feeling.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: _cc,
                    label: '$feeling',
                    onChanged: (v) => setSheet(() => feeling = v.toInt()),
                  ),

                  const SizedBox(height: 8),

                  // Optional pre/post pain rating (e-VAS)
                  if (!showPain)
                    TextButton.icon(
                      onPressed: () => setSheet(() => showPain = true),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      icon: Icon(
                        Icons.add,
                        color: _cc.withValues(alpha: 0.7),
                        size: 14,
                      ),
                      label: Text(
                        context.l10n.activityActionTogglePainRating,
                        style: TextStyle(
                          color: _cc.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    )
                  else ...[
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.activityLabelPainBefore,
                      style: TextStyle(
                        color: _cc.withValues(alpha: 0.7),
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _painRow(
                      painBefore,
                      painLabels,
                      (v) => setSheet(() => painBefore = v),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.activityLabelPainAfter,
                      style: TextStyle(
                        color: _cc.withValues(alpha: 0.7),
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _painRow(
                      painAfter,
                      painLabels,
                      (v) => setSheet(() => painAfter = v),
                    ),
                    if (painBefore != null && painAfter != null) ...[
                      const SizedBox(height: 8),
                      _painDeltaHint(painBefore!, painAfter!),
                    ],
                  ],

                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    style: TextStyle(color: _cc),
                    decoration: InputDecoration(
                      hintText: context.l10n.symptomsLabelOptionalNoteSimple,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cc,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      final activity = ActivityEvent(
                        id: existing?.id,
                        timestamp: ts,
                        name: name,
                        sets: int.tryParse(setsCtrl.text),
                        reps: int.tryParse(repsCtrl.text),
                        durationMinutes: int.tryParse(durationCtrl.text),
                        effort: effort,
                        feeling: feeling,
                        hhr: hhrCtrl.text.trim().isEmpty
                            ? null
                            : hhrCtrl.text.trim(),
                        note: noteCtrl.text.trim().isEmpty
                            ? null
                            : noteCtrl.text.trim(),
                        painBefore: showPain ? painBefore : null,
                        painAfter: showPain ? painAfter : null,
                      );
                      if (isEdit) {
                        final idx = _p.activityHistory.indexOf(existing);
                        if (idx >= 0) {
                          setState(() => _p.activityHistory[idx] = activity);
                        }
                      } else {
                        setState(() => _p.activityHistory.add(activity));
                      }
                      widget.onProfileChanged();
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      isEdit
                          ? context.l10n.symptomsActionSaveChanges
                          : context.l10n.activityActionSubmitLog,
                      style: TextStyle(color: _ic, fontWeight: FontWeight.bold),
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

  Widget _painRow(
    int? value,
    List<String> painLabels,
    ValueChanged<int?> onTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (i) {
        final isSelected = value == i;
        return InkWell(
          onTap: () => onTap(isSelected ? null : i),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _painColors[i],
                    border: Border.all(
                      color: isSelected ? _cc : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  painLabels[i],
                  style: TextStyle(
                    color: _cc,
                    fontSize: 9,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _painDeltaHint(int before, int after) {
    final l10n = context.l10n;
    final delta = before - after;
    String label;
    Color color;
    IconData icon;
    if (delta > 0) {
      label = l10n.movementPainDeltaImprovedTemplate(delta);
      color = const Color(0xFF81C784);
      icon = Icons.trending_down;
    } else if (delta < 0) {
      label = l10n.movementPainDeltaWorseTemplate(-delta);
      color = const Color(0xFFE57373);
      icon = Icons.trending_up;
    } else {
      label = l10n.movementPainDeltaUnchanged;
      color = _cc.withValues(alpha: 0.5);
      icon = Icons.trending_flat;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Internal helper — unified row representation for the chronological log
// =============================================================================

class _DayLogEntry {
  final DateTime timestamp;
  final IconData icon;
  final String title;
  final String subtitle;
  final ActivityEvent? activity;
  final TherapyEvent? therapy;

  _DayLogEntry._({
    required this.timestamp,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.activity,
    this.therapy,
  });

  bool get isActivity => activity != null;

  factory _DayLogEntry.activity(ActivityEvent a, AppLocalizations l10n) {
    final detail = (a.durationMinutes != null && a.durationMinutes! > 0)
        ? '${a.durationMinutes}min'
        : '${a.sets ?? "?"}×${a.reps ?? "?"}';
    final parts = <String>[
      detail,
      l10n.movementLogEntryEffortTemplate(a.effort),
      l10n.movementLogEntryFeelingTemplate(a.feeling),
    ];
    if (a.painDelta != null) {
      final d = a.painDelta!;
      parts.add(
        d > 0
            ? l10n.movementLogEntryDeltaImprovedTemplate(d)
            : d < 0
            ? l10n.movementLogEntryDeltaWorseTemplate(-d)
            : l10n.movementLogEntryDeltaUnchanged,
      );
    }
    return _DayLogEntry._(
      timestamp: a.timestamp,
      icon: Icons.fitness_center,
      title: a.name,
      subtitle: parts.join(' · '),
      activity: a,
    );
  }

  factory _DayLogEntry.therapy(TherapyEvent t, AppLocalizations l10n) {
    final parts = <String>[];
    if (t.bodyArea != null) parts.add(t.bodyArea!);
    if (t.durationMinutes != null) parts.add('${t.durationMinutes}min');
    if (t.severityDelta != null) {
      final d = t.severityDelta!;
      parts.add(
        d > 0
            ? l10n.movementLogEntryDeltaImprovedTemplate(d)
            : d < 0
            ? l10n.movementLogEntryDeltaWorseTemplate(-d)
            : l10n.movementLogEntryTherapyDeltaSteady,
      );
    }
    if (t.therapistOrPlace != null) parts.add(t.therapistOrPlace!);
    if (t.cost != null) parts.add('\$${t.cost}');
    return _DayLogEntry._(
      timestamp: t.timestamp,
      icon: Icons.healing_outlined,
      title: t.modality,
      subtitle: parts.join(' · '),
      therapy: t,
    );
  }
}
