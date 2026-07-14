// =============================================================================
// Botiquín tab — phase 2B redesign.
//
// Layout, top to bottom:
//   1. Interaction warnings (severe → warning → info, color-coded)
//   2. Medication groups section — SKELETON THIS PHASE
//      • List existing groups (read-only display) + "Crear grupo" CTA
//      • CTA opens a "próximamente" dialog; full creation flow is phase 2C
//   3. Tu botiquín — the med list
//      • Each row: tap to log dose, swipe left to delete (with confirm),
//        pencil icon to edit
//      • Empty state if botiquín is empty
//   4. "+ Crear medicamento" button → MedFormSheet
//
// Dose logging modal (private _DoseLogSheet) supports:
//   • Quantity stepper (half-pill increments)
//   • Optional linked symptom (with SeverityBadge)
//   • Outcome tracking toggle (when symptom linked + outcomeCheckHours set)
//   • Timestamp picker (defaults to now / selected date)
//   • Shows "= X mg total" when both strength and unit are set
//
// All mutations call `onProfileChanged` which the parent uses to setState +
// persist. BotiquinTab itself is stateless.
// =============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/interaction_engine.dart';
import '../services/vademecum_service.dart';
import '../widgets/dose_stepper.dart';
import '../widgets/drug_info_sheet.dart';
import '../widgets/group_form.dart';
import '../widgets/med_form.dart';
import '../widgets/severity_picker.dart';
import 'timestamp_picker.dart';
import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';
import 'med_detail_screen.dart';

class BotiquinTab extends StatelessWidget {
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final MedlinePlusService medlineService;

  /// Called after any mutation (med add/edit/delete, dose logged, etc.).
  /// Parent should setState + persist.
  final VoidCallback onProfileChanged;

  const BotiquinTab({
    super.key,
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.medlineService,
    required this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dosesToday = profile.getDosesForDay(selectedDate);
    final medsToday = dosesToday.map((d) => d.medicationName).toSet().toList();
    final interactions = InteractionEngine.evaluate(
      medicationsToday: medsToday,
      conditions: profile.conditions,
    );
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // 0. Today's doses (delete-by-event surface for fixing logging mistakes)
        if (dosesToday.isNotEmpty) ...[
          _TodaysDoses(
            doses: dosesToday,
            profile: profile,
            contrastColor: contrastColor,
            onProfileChanged: onProfileChanged,
          ),
          const SizedBox(height: 20),
        ],

        // 1. Interactions
        if (interactions.isNotEmpty) ...[
          _InteractionList(rules: interactions, contrastColor: contrastColor),
          const SizedBox(height: 20),
        ],

        // 2. Groups skeleton
        _GroupsSection(
          profile: profile,
          selectedDate: selectedDate,
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
          onProfileChanged: onProfileChanged,
        ),
        const SizedBox(height: 24),

        // 3. Med list
        _MedListSection(
          profile: profile,
          selectedDate: selectedDate,
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
          medlineService: medlineService,
          onProfileChanged: onProfileChanged,
        ),

        const SizedBox(height: 12),

        // 4. Create medication
        OutlinedButton.icon(
          onPressed: () => _openCreateMed(context),
          icon: Icon(Icons.add, color: contrastColor, size: 18),
          label: Text(
            l10n.botiquinActionCreate,
            style: TextStyle(color: contrastColor, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: contrastColor.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _openCreateMed(BuildContext context) async {
    final med = await showMedFormSheet(
      context,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
    );
    if (med != null) {
      profile.botiquin.add(med);
      onProfileChanged();
    }
  }
}

// =============================================================================
// Section header — matches Hoy tab's visual language
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? badge;
  final Color? badgeColor;
  final Color contrastColor;

  const _SectionHeader({
    required this.title,
    required this.contrastColor,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: contrastColor,
            letterSpacing: 0.3,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor ?? contrastColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// Interaction list
// =============================================================================

class _InteractionList extends StatelessWidget {
  final List<InteractionRule> rules;
  final Color contrastColor;

  const _InteractionList({required this.rules, required this.contrastColor});

  Color _colorFor(InteractionLevel level) => switch (level) {
    InteractionLevel.severe => const Color(0xFFE57373),
    InteractionLevel.warning => const Color(0xFFFFB74D),
    InteractionLevel.info => contrastColor.withValues(alpha: 0.5),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Interacciones detectadas',
          badge: '${rules.length}',
          badgeColor: _colorFor(rules.first.level),
          contrastColor: contrastColor,
        ),
        const SizedBox(height: 8),
        ...rules.map((r) {
          final color = _colorFor(r.level);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.45),
                  width: 1,
                ),
              ),
              child: Text(
                r.message,
                style: TextStyle(
                  color: contrastColor,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// =============================================================================
// Groups section — full CRUD wired to GroupFormSheet, batch logging on tap
// =============================================================================

class _GroupsSection extends StatelessWidget {
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onProfileChanged;

  const _GroupsSection({
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final l10n = context.l10n;
    final groups = profile.medicationGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Grupos',
          badge: groups.isEmpty ? null : '${groups.length}',
          contrastColor: cc,
        ),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cc.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.botiquinGroupsEmptyHeadline,
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.botiquinGroupsEmptyBody,
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.6),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        else
          ...groups.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _GroupRow(
                group: g,
                profile: profile,
                selectedDate: selectedDate,
                contrastColor: cc,
                inverseContrastColor: inverseContrastColor,
                onProfileChanged: onProfileChanged,
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _openCreateGroup(context),
          icon: Icon(Icons.add, size: 16, color: cc.withValues(alpha: 0.7)),
          label: Text(
            l10n.botiquinActionCreateGroup,
            style: TextStyle(color: cc.withValues(alpha: 0.7), fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: cc.withValues(alpha: 0.25)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
        ),
      ],
    );
  }

  Future<void> _openCreateGroup(BuildContext context) async {
    if (profile.botiquin.isEmpty) {
      // Friendly nudge instead of an empty group form.
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: inverseContrastColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            context.l10n.botiquinNoMedsDialogTitle,
            style: TextStyle(color: contrastColor),
          ),
          content: Text(
            context.l10n.botiquinNoMedsDialogBody,
            style: TextStyle(
              color: contrastColor.withValues(alpha: 0.8),
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: contrastColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }
    final result = await showGroupFormSheet(
      context,
      profile: profile,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
    );
    if (result != null && !identical(result, kGroupDeleted)) {
      profile.medicationGroups.add(result);
      onProfileChanged();
    }
  }
}

class _GroupRow extends StatelessWidget {
  final MedicationGroup group;
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onProfileChanged;

  const _GroupRow({
    required this.group,
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final m = group.defaultTimeMinutes;
    final timeStr = m == null
        ? null
        : '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
    final entryCount = group.entries.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openLogBatch(context),
        onLongPress: () => _openEditGroup(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cc.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cc.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        color: cc,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$entryCount ${entryCount == 1 ? 'medicamento' : 'medicamentos'}${timeStr != null ? ' · $timeStr' : ''}',
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: cc.withValues(alpha: 0.6),
                ),
                onPressed: () => _openEditGroup(context),
                tooltip: 'Editar',
                visualDensity: VisualDensity.compact,
              ),
              Icon(
                Icons.play_arrow_rounded,
                color: cc.withValues(alpha: 0.7),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditGroup(BuildContext context) async {
    final result = await showGroupFormSheet(
      context,
      profile: profile,
      existing: group,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
    );
    if (result == null) return;
    if (identical(result, kGroupDeleted)) {
      profile.medicationGroups.removeWhere((g) => g.id == group.id);
      onProfileChanged();
      return;
    }
    final idx = profile.medicationGroups.indexWhere((g) => g.id == group.id);
    if (idx >= 0) {
      profile.medicationGroups[idx] = result;
      onProfileChanged();
    }
  }

  Future<void> _openLogBatch(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: inverseContrastColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _GroupBatchLogSheet(
        group: group,
        profile: profile,
        selectedDate: selectedDate,
        contrastColor: contrastColor,
        inverseContrastColor: inverseContrastColor,
      ),
    );
    onProfileChanged();
  }
}

// =============================================================================
// _GroupBatchLogSheet — confirm timestamp and one-tap-log the whole group.
// =============================================================================

class _GroupBatchLogSheet extends StatefulWidget {
  final MedicationGroup group;
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;

  const _GroupBatchLogSheet({
    required this.group,
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  @override
  State<_GroupBatchLogSheet> createState() => _GroupBatchLogSheetState();
}

class _GroupBatchLogSheetState extends State<_GroupBatchLogSheet> {
  late DateTime _timestamp;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _timestamp = _initialTimestamp();
  }

  DateTime _initialTimestamp() {
    final now = DateTime.now();
    final d = widget.selectedDate;
    final isToday =
        d.year == now.year && d.month == now.month && d.day == now.day;
    final base = isToday
        ? now
        : DateTime(d.year, d.month, d.day, now.hour, now.minute);
    // If the group has a default time set, prefer that for "today" logging.
    final defaultTs = widget.group.defaultTimeOn(d);
    if (defaultTs != null && isToday) {
      // Only use default time if it's in the past today; future-time
      // defaults would feel weird as a "log now" timestamp.
      if (defaultTs.isBefore(now)) return defaultTs;
    } else if (defaultTs != null) {
      return defaultTs;
    }
    return base;
  }

  void _save() {
    if (_saved) return;
    _saved = true;
    widget.profile.logGroup(widget.group, timestamp: _timestamp);
    Navigator.of(context).pop();
  }

  String _formatTimestamp(DateTime t) {
    final now = DateTime.now();
    final today =
        t.year == now.year && t.month == now.month && t.day == now.day;
    final time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (today) return 'Hoy a las $time';
    return '${t.day}/${t.month} a las $time';
  }

  String _formatQty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final l10n = context.l10n;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final entries = widget.group.entries;
    final orphanCount = entries
        .where((e) => widget.profile.findMedById(e.medicationId) == null)
        .length;
    final validEntries = entries
        .where((e) => widget.profile.findMedById(e.medicationId) != null)
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.botiquinBatchSheetTitle,
                          style: TextStyle(
                            color: cc.withValues(alpha: 0.6),
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.group.name,
                          style: TextStyle(
                            color: cc,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: cc),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.botiquinBatchSheetSubtitle,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cc.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cc.withValues(alpha: 0.12)),
                ),
                child: Column(
                  children: validEntries.map((e) {
                    final med = widget.profile.findMedById(e.medicationId)!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 14,
                            color: cc.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              med.name,
                              style: TextStyle(
                                color: cc,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${_formatQty(e.quantity)} ${med.form}${e.quantity == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: cc.withValues(alpha: 0.65),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (orphanCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '⚠️ $orphanCount medicamento${orphanCount == 1 ? '' : 's'} eliminado${orphanCount == 1 ? '' : 's'} del botiquín — se omitirá${orphanCount == 1 ? '' : 'n'}.',
                  style: TextStyle(
                    color: const Color(0xFFFFB74D),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Timestamp
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await pickTimestamp(
                    context: context,
                    initial: _timestamp,
                    contrastColor: cc,
                    inverseContrastColor: widget.inverseContrastColor,
                  );
                  if (picked != null) {
                    setState(() => _timestamp = picked);
                  }
                },
                icon: Icon(
                  Icons.access_time,
                  size: 16,
                  color: cc.withValues(alpha: 0.7),
                ),
                label: Text(
                  _formatTimestamp(_timestamp),
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cc.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: validEntries.isEmpty ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cc,
                    foregroundColor: widget.inverseContrastColor,
                    disabledBackgroundColor: cc.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Registrar ${validEntries.length} ${validEntries.length == 1 ? 'dosis' : 'dosis'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
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

// =============================================================================
// Med list section — header + search filter + A-Z sort toggle + rows.
// Filtering/sorting are view-only (not persisted); the underlying
// profile.botiquin order is never mutated.
// =============================================================================

class _MedListSection extends StatefulWidget {
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final MedlinePlusService medlineService;
  final VoidCallback onProfileChanged;

  const _MedListSection({
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.medlineService,
    required this.onProfileChanged,
  });

  @override
  State<_MedListSection> createState() => _MedListSectionState();
}

class _MedListSectionState extends State<_MedListSection> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _sortAlpha = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matches(MedicationDef med, String q) {
    if (q.isEmpty) return true;
    return med.name.toLowerCase().contains(q) ||
        (med.notes?.toLowerCase().contains(q) ?? false) ||
        (med.activeIngredient?.toLowerCase().contains(q) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final l10n = context.l10n;
    final all = widget.profile.botiquin;
    final q = _query.trim().toLowerCase();
    final filtered = all.where((m) => _matches(m, q)).toList();
    if (_sortAlpha) {
      filtered.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                title: l10n.botiquinTabTitle,
                badge: all.isEmpty ? null : '${all.length}',
                contrastColor: cc,
              ),
            ),
            if (all.length > 1)
              _SortToggleButton(
                active: _sortAlpha,
                contrastColor: cc,
                onTap: () => setState(() => _sortAlpha = !_sortAlpha),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (all.isEmpty)
          _EmptyMedsCard(contrastColor: cc)
        else ...[
          if (all.length > 1) ...[
            _SearchField(
              controller: _searchCtrl,
              contrastColor: cc,
              hintText: l10n.botiquinSearchHint,
              onChanged: (v) => setState(() => _query = v),
              onClear: () => setState(() {
                _searchCtrl.clear();
                _query = '';
              }),
            ),
            const SizedBox(height: 10),
          ],
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.botiquinSearchNoResults,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            )
          else
            ...filtered.map(
              (med) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MedRow(
                  med: med,
                  profile: widget.profile,
                  selectedDate: widget.selectedDate,
                  contrastColor: cc,
                  inverseContrastColor: widget.inverseContrastColor,
                  medlineService: widget.medlineService,
                  onProfileChanged: widget.onProfileChanged,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Color contrastColor;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.contrastColor,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: cc.withValues(alpha: 0.15)),
    );
    return TextField(
      controller: controller,
      style: TextStyle(color: cc, fontSize: 14),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: cc.withValues(alpha: 0.4), fontSize: 13),
        prefixIcon: Icon(
          Icons.search,
          size: 18,
          color: cc.withValues(alpha: 0.5),
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: cc.withValues(alpha: 0.5),
                ),
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
              ),
        filled: true,
        fillColor: cc.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        isDense: true,
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cc, width: 1.5),
        ),
      ),
    );
  }
}

class _SortToggleButton extends StatelessWidget {
  final bool active;
  final Color contrastColor;
  final VoidCallback onTap;

  const _SortToggleButton({
    required this.active,
    required this.contrastColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? cc.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cc.withValues(alpha: active ? 0.4 : 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sort_by_alpha,
                size: 14,
                color: cc.withValues(alpha: active ? 1.0 : 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                'A-Z',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: cc.withValues(alpha: active ? 1.0 : 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Empty meds card
// =============================================================================

class _EmptyMedsCard extends StatelessWidget {
  final Color contrastColor;

  const _EmptyMedsCard({required this.contrastColor});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: contrastColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.medication_outlined,
            size: 40,
            color: contrastColor.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.botiquinEmptyStateHeadline,
            style: TextStyle(
              color: contrastColor.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.botiquinEmptyStateSubtitle,
            style: TextStyle(
              color: contrastColor.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Med row — tap to log, pencil to edit, swipe to delete
// =============================================================================

class _MedRow extends StatelessWidget {
  final MedicationDef med;
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final MedlinePlusService medlineService;
  final VoidCallback onProfileChanged;

  const _MedRow({
    required this.med,
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.medlineService,
    required this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final l10n = context.l10n;
    final qtyToday = profile.getDoseQuantityForDayAndMed(
      selectedDate,
      med.name,
    );
    final subtitle = med.notes?.isNotEmpty == true
        ? '${med.displayDose} · ${med.notes}'
        : med.displayDose;

    return Dismissible(
      key: ValueKey('med-${med.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE57373),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) {
        profile.deleteMedication(med.id);
        onProfileChanged();
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLogDose(context),
          onLongPress: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MedDetailScreen(
                med: med,
                profile: profile,
                contrastColor: contrastColor,
                inverseContrastColor: inverseContrastColor,
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cc.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cc.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: TextStyle(
                          color: cc,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: cc.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (qtyToday > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF81C784).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.botiquinDoseLoggedTodayBadge(_formatQty(qtyToday)),
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: cc.withValues(alpha: 0.6),
                  ),
                  onPressed: () => _openDrugInfo(context),
                  tooltip: 'Información',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: cc.withValues(alpha: 0.6),
                  ),
                  onPressed: () => _openEditMed(context),
                  tooltip: 'Editar',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatQty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: inverseContrastColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.l10n.botiquinDeleteConfirmTitle(med.name),
          style: TextStyle(color: contrastColor),
        ),
        content: Text(
          context.l10n.botiquinDeleteConfirmBody(med.name),
          style: TextStyle(
            color: contrastColor.withValues(alpha: 0.8),
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              context.l10n.actionCancel,
              style: TextStyle(color: contrastColor.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              context.l10n.botiquinActionDelete,
              style: TextStyle(
                color: const Color(0xFFE57373),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditMed(BuildContext context) async {
    final updated = await showMedFormSheet(
      context,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      existing: med,
    );
    if (updated != null) {
      final idx = profile.botiquin.indexWhere((m) => m.id == med.id);
      if (idx >= 0) {
        profile.botiquin[idx] = updated;
        onProfileChanged();
      }
    }
  }

  Future<void> _openDrugInfo(BuildContext context) async {
    showDrugInfoSheet(
      context: context,
      med: med,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      service: medlineService,
      botiquin: profile.botiquin,
    );
  }

  Future<void> _openLogDose(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: inverseContrastColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _DoseLogSheet(
        med: med,
        profile: profile,
        selectedDate: selectedDate,
        contrastColor: contrastColor,
        inverseContrastColor: inverseContrastColor,
      ),
    );
    // _DoseLogSheet mutates profile directly; trigger setState in parent.
    onProfileChanged();
  }
}

// =============================================================================
// Dose log sheet — quantity stepper, optional linked symptom, outcome toggle
// =============================================================================

class _DoseLogSheet extends StatefulWidget {
  final MedicationDef med;
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;

  const _DoseLogSheet({
    required this.med,
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  @override
  State<_DoseLogSheet> createState() => _DoseLogSheetState();
}

class _DoseLogSheetState extends State<_DoseLogSheet> {
  late double _quantity;
  late DateTime _timestamp;
  SymptomEvent? _linkedSymptom;
  bool _trackOutcome = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.med.defaultQuantity == 0
        ? 1.0
        : widget.med.defaultQuantity;
    _timestamp = _initialTimestamp();
  }

  DateTime _initialTimestamp() {
    final now = DateTime.now();
    final d = widget.selectedDate;
    final isToday =
        d.year == now.year && d.month == now.month && d.day == now.day;
    return isToday
        ? now
        : DateTime(d.year, d.month, d.day, now.hour, now.minute);
  }

  void _save() {
    if (_saved) return; // prevent double-tap
    _saved = true;
    final med = widget.med;

    final severityBefore = <String, int>{};
    if (_linkedSymptom != null) {
      severityBefore[_linkedSymptom!.id] = _linkedSymptom!.severity.value;
    }

    final dose = DoseEvent(
      timestamp: _timestamp,
      medicationName: med.name,
      medicationId: med.id,
      quantity: _quantity,
      strengthAtDose: med.strength,
      unitAtDose: med.unit,
      formAtDose: med.form,
      linkedSymptomIds: _linkedSymptom != null
          ? [_linkedSymptom!.id]
          : const [],
      severityBefore: severityBefore,
    );
    widget.profile.doseHistory.add(dose);

    if (_trackOutcome &&
        _linkedSymptom != null &&
        med.outcomeCheckHours != null) {
      widget.profile.medicationOutcomes.add(
        MedicationOutcome(
          doseId: dose.id,
          symptomId: _linkedSymptom!.id,
          medicationName: med.name,
          symptomName: _linkedSymptom!.name,
          doseTimestamp: _timestamp,
          checkAt: _timestamp.add(Duration(hours: med.outcomeCheckHours!)),
          severityBefore: _linkedSymptom!.severity.value,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  String _formatQty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1);

  String _formatTimestamp(DateTime t) {
    final now = DateTime.now();
    final today =
        t.year == now.year && t.month == now.month && t.day == now.day;
    final time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (today) return 'Hoy a las $time';
    return '${t.day}/${t.month} a las $time';
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final med = widget.med;
    final l10n = context.l10n;
    final recent = widget.profile.recentSignificantSymptoms();
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.botiquinLogDoseSheetTitle,
                          style: TextStyle(
                            color: cc.withValues(alpha: 0.6),
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          med.name,
                          style: TextStyle(
                            color: cc,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: cc),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quantity stepper
              Center(
                child: DoseQuantityStepper(
                  value: _quantity,
                  onChanged: (v) => setState(() => _quantity = v),
                  formLabel: med.form,
                  contrastColor: cc,
                ),
              ),
              if (med.strength > 0 && med.unit.isNotEmpty) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '= ${_formatQty(_quantity * med.strength)} ${med.unit} total',
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              if (med.components.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cc.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cc.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: med.components.map((c) {
                      final amount = _formatQty(_quantity * c.strength);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.name,
                                style: TextStyle(
                                  color: cc.withValues(alpha: 0.85),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              '$amount ${c.unit}',
                              style: TextStyle(
                                color: cc.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Linked symptom (only if recent symptoms exist)
              if (recent.isNotEmpty) ...[
                Text(
                  l10n.botiquinLogDoseSymptomPrompt,
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _symptomChip(null, 'Ninguno'),
                    ...recent.take(5).map((s) => _symptomChip(s, s.name)),
                  ],
                ),
                if (_linkedSymptom != null &&
                    med.outcomeCheckHours != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cc.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cc.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Switch(
                          value: _trackOutcome,
                          onChanged: (v) => setState(() => _trackOutcome = v),
                          activeColor: cc,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l10n.botiquinLogDoseTrackOutcomeToggle(
                              med.outcomeCheckHours!,
                            ),
                            style: TextStyle(
                              color: cc.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Timestamp
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await pickTimestamp(
                    context: context,
                    initial: _timestamp,
                    contrastColor: cc,
                    inverseContrastColor: widget.inverseContrastColor,
                  );
                  if (picked != null) {
                    setState(() => _timestamp = picked);
                  }
                },
                icon: Icon(
                  Icons.access_time,
                  size: 16,
                  color: cc.withValues(alpha: 0.7),
                ),
                label: Text(
                  _formatTimestamp(_timestamp),
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cc.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cc,
                    foregroundColor: widget.inverseContrastColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.botiquinLogDoseSheetTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _symptomChip(SymptomEvent? s, String label) {
    final cc = widget.contrastColor;
    final selected =
        _linkedSymptom?.id == s?.id || (_linkedSymptom == null && s == null);
    return InkWell(
      onTap: () => setState(() => _linkedSymptom = s),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cc.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cc.withValues(alpha: selected ? 0.5 : 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (s != null) ...[
              SeverityBadge(severity: s.severity, size: 8),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: cc.withValues(alpha: selected ? 1.0 : 0.75),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// =============================================================================
// _TodaysDoses — chronological list of today's doses with per-event delete.
// Solves the "I typed the med name wrong and need it out of my records" case.
// =============================================================================

class _TodaysDoses extends StatelessWidget {
  final List<DoseEvent> doses;
  final Profile profile;
  final Color contrastColor;
  final VoidCallback onProfileChanged;

  const _TodaysDoses({
    required this.doses,
    required this.profile,
    required this.contrastColor,
    required this.onProfileChanged,
  });

  String _formatQty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final l10n = context.l10n;
    final sorted = [...doses]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.botiquinDoseListTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: cc,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cc.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${sorted.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cc.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cc.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: sorted.map((d) {
              final timeStr =
                  '${d.timestamp.hour.toString().padLeft(2, '0')}:${d.timestamp.minute.toString().padLeft(2, '0')}';
              final qtyLabel = '${_formatQty(d.quantity)} ${d.formAtDose}';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 14,
                      color: cc.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '[$timeStr] ${d.medicationName}',
                            style: TextStyle(
                              color: cc,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            qtyLabel,
                            style: TextStyle(
                              color: cc.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Eliminar esta dosis',
                      onPressed: () => _confirmDelete(context, d),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.botiquinDoseListFootnote,
          style: TextStyle(
            color: cc.withValues(alpha: 0.5),
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, DoseEvent d) async {
    final l10n = context.l10n;
    final timeStr =
        '${d.timestamp.hour.toString().padLeft(2, '0')}:${d.timestamp.minute.toString().padLeft(2, '0')}';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.botiquinDoseItemDeleteConfirmTitle),
        content: Text(
          l10n.botiquinDoseItemDeleteConfirmBody(d.medicationName, timeStr),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.l10n.botiquinActionDelete,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    profile.doseHistory.removeWhere((x) => x.id == d.id);
    // Also remove any pending outcome tied to this dose.
    profile.medicationOutcomes.removeWhere((o) => o.doseId == d.id);
    onProfileChanged();
  }
}
