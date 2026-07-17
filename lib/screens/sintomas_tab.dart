import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../models/headache_detail.dart';
import '../models/fatigue_detail.dart';
import '../models/abdominal_detail.dart';
import '../models/presyncope_detail.dart';
import '../models/pelvic_pain_detail.dart';
import '../models/structural_detail.dart';
import 'timestamp_picker.dart';
import '../widgets/bowel_form_sheet.dart';
import '../widgets/hemorrhoidal_form_sheet.dart';
import '../widgets/fever_form_sheet.dart';
import '../widgets/sleep_form_sheet.dart';
import '../widgets/hydration_form_sheet.dart';
import '../widgets/hrv_form_sheet.dart';
import '../widgets/headache_detail_sheet.dart';
import '../widgets/fatigue_detail_sheet.dart';
import '../widgets/abdominal_detail_sheet.dart';
import '../widgets/presyncope_detail_sheet.dart';
import '../widgets/pelvic_pain_detail_sheet.dart';
import '../widgets/structural_bleeding_sheet.dart';
import '../widgets/structural_checkin_sheet.dart';
import '../widgets/structural_detail_sheet.dart';
import '../widgets/structural_quick_log_sheet.dart';
import '../widgets/structural_zone_history_form_sheet.dart';
import '../widgets/body_zone_picker_grid.dart';
import '../services/structural_text_detector.dart';
import '../services/clinical_localizations.dart';
import '../services/structural_taxonomy.dart';
import '../services/symptom_definitions_service.dart';
import '../models/red_flag_severity.dart';
import '../services/headache_red_flags.dart';
import '../services/headache_detail_format.dart';
import '../services/fatigue_red_flags.dart';
import '../services/fatigue_detail_format.dart';
import '../services/abdominal_red_flags.dart';
import '../services/abdominal_detail_format.dart';
import '../services/presyncope_red_flags.dart';
import '../services/presyncope_detail_format.dart';
import '../services/pelvic_pain_red_flags.dart';
import '../services/pelvic_pain_detail_format.dart';
import '../services/structural_detail_format.dart';
import '../widgets/collapsible_section.dart';
import '../widgets/severity_picker.dart';
import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';
import '../widgets/action_taken_sheet.dart';
import '../models/action_taken.dart';
import '../widgets/mcas_detail_sheet.dart';
import '../services/mcas_red_flag_service.dart';
import '../widgets/mcas_advisory_dialog.dart';
import '../models/mcas.dart';
import '../widgets/symptom_frequency_dashboard.dart';
import '../models/profile_state.dart';

// ---------------------------------------------------------------------------
// Sprint E.B.2 — MCAS symptom heuristic.
// Keyword-matching against symptom name to decide whether to open the
// MCAS detail sheet. Temporary approach — migrate to
// svc.matchesSymptomKey(symptom, 'mcas_reaction') pattern once MCAS
// aliases are curated in symptom_definitions_service.dart.
// ---------------------------------------------------------------------------
bool _isMCASSymptom(String symptom) {
  final lower = symptom.toLowerCase();
  const keywords = [
    'urticaria',
    'roncha',
    'habon',
    'angioedema',
    'hinchazón',
    'moretón',
    'hematoma',
    'flush',
    'enrojec',
    'rubor',
    'picazón',
    'prurito',
    'comezón',
    'sangrado abundante',
    'palpita',
    'taquicard',
    'reacción alérgica',
    'alergia',
    'reacción histamínica',
  ];
  return keywords.any((k) => lower.contains(k));
}

/// Síntomas tab.
///
/// Sections:
/// 1. Zonas estructurales (chips) → structural event bottom sheet
/// 2. Registros de hoy (combined: symptoms + structurals, long-press to edit)
/// 3. En tendencia (últimos 7 días)
/// 4. Baúl de síntomas + inline add
///
/// Activity and therapy moved to MovimientoTab.
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

  // F6.b: zones are rendered grouped by BodyRegion. The picker iterates
  // kBodyRegionZones directly — no local _zones const needed. See the
  // STRUCTURAL ZONES section in build() below.

  // F4: structural taxonomy moved to models.dart as kStructuralTaxonomy.
  // Six kinds (joint/muscle/tendon/ligament/softTissue/nerve), 28 types
  // total. See lib/models/models.dart for the authoritative list.

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

  Color _severityColor(SymptomSeverity sev) {
    final hex = sev.colorHex.substring(1);
    return Color(int.parse(hex, radix: 16) | 0xFF000000);
  }

  /// "Ninguna" is repurposed as the "I didn't rate it" sentinel per Phase 2C.
  bool _isUnrated(SymptomSeverity sev) => sev.label.toLowerCase() == 'ninguna';

  // F5 Batch 2: `_ratableSeverities` getter removed — the SeverityDotPicker
  // now takes `excludeNone: true` and filters internally.

  // ---------------------------------------------------------------------------
  // F3 — Collapsible section helpers
  // ---------------------------------------------------------------------------

  /// Resolve a section's initial state from its history timestamps:
  /// returns hint ("último hoy / ayer / hace N días" or "sin registros aún")
  /// and `expanded` (true if there was activity in the last 7 days AND
  /// careful mode is off).
  ({bool expanded, String hint}) _sectionState(
    Iterable<DateTime> timestamps,
    AppLocalizations l10n,
    bool isCareful,
  ) {
    DateTime? mostRecent;
    for (final ts in timestamps) {
      if (mostRecent == null || ts.isAfter(mostRecent)) mostRecent = ts;
    }
    if (mostRecent == null) {
      return (expanded: false, hint: l10n.sectionHintNoActivity);
    }
    final daysAgo = DateTime.now().difference(mostRecent).inDays;
    final hint = _formatActivityHint(daysAgo, l10n);
    final expanded = !isCareful && daysAgo < 7;
    return (expanded: expanded, hint: hint);
  }

  String _formatActivityHint(int daysAgo, AppLocalizations l10n) {
    if (daysAgo <= 0) return l10n.sectionHintToday;
    if (daysAgo == 1) return l10n.sectionHintYesterday;
    return l10n.sectionHintDaysAgo(daysAgo);
  }

  // F5 Batch 2: inline _buildDotPicker removed. The two call sites now
  // use SeverityDotPicker directly with showFunctionalAnchor: true and
  // excludeNone: true.

  // ---------------------------------------------------------------------------
  // F.E3 — Retro action summary tag (rendered on symptom log entries
  // when a retro check-in has been completed for the SymptomEvent)
  // ---------------------------------------------------------------------------

  static const _kindNaturalLabels = {
    ActionKind.medication: 'medicación',
    ActionKind.rest: 'descanso',
    ActionKind.hydration: 'hidratación',
    ActionKind.breathing: 'respiración',
    ActionKind.heat: 'calor',
    ActionKind.cold: 'frío',
    ActionKind.elevation: 'piernas elevadas',
    ActionKind.sensoryReduction: 'menos estímulos',
    ActionKind.socialWithdrawal: 'aislamiento',
    ActionKind.food: 'algo de comer',
    ActionKind.movement: 'movimiento suave',
    // custom / nothing handled specially in _retroActionTag
  };

  /// Compact natural-language summary of the retro check-in linked
  /// to a SymptomEvent. Returns empty string when no completed retro
  /// exists.
  ///
  /// Uses the most recent matching ActionTaken (by ActionTaken.timestamp)
  /// in case of multiple edits/duplicates.
  String _retroActionTag(SymptomEvent event) {
    final linkedId = event.timestamp.toIso8601String();
    ActionTaken? match;
    for (final a in _p.actionsHistory) {
      if (a.linkedEventType != LinkedEventType.symptom) continue;
      if (a.linkedEventId != linkedId) continue;
      if (!a.followUpCompleted) continue;
      if (match == null || a.timestamp.isAfter(match.timestamp)) {
        match = a;
      }
    }
    if (match == null) return '';
    final rating = match.effectivenessRating;
    if (rating == null) return '';

    // Nothing kind: no action clause.
    if (match.kind == ActionKind.nothing) {
      return switch (rating) {
        EffectivenessRating.muchRelief => '⏳ mejoró mucho sin hacer nada',
        EffectivenessRating.someRelief => '⏳ mejoró un poco sin hacer nada',
        EffectivenessRating.partialReliefThenReturned =>
          '⏳ mejoró un poco y después volvió',
        EffectivenessRating.noChange => '⏳ sin cambios',
        EffectivenessRating.worse => '⏳ empeoró',
      };
    }

    // Action label — med name > custom label > kind natural label.
    String actionLabel;
    if (match.kind == ActionKind.medication && match.medicationRefId != null) {
      final meds = _p.botiquin.where((m) => m.id == match!.medicationRefId);
      actionLabel = meds.isNotEmpty ? meds.first.name : 'medicación';
    } else if (match.kind == ActionKind.custom && match.customLabel != null) {
      actionLabel = match.customLabel!;
    } else {
      actionLabel =
          _kindNaturalLabels[match.kind] ?? match.kind.serializationKey;
    }

    return switch (rating) {
      EffectivenessRating.muchRelief => '⏳ mejoró mucho con $actionLabel',
      EffectivenessRating.someRelief => '⏳ mejoró un poco con $actionLabel',
      EffectivenessRating.partialReliefThenReturned =>
        '⏳ mejoró con $actionLabel y después volvió',
      EffectivenessRating.noChange => '⏳ sin cambios con $actionLabel',
      EffectivenessRating.worse => '⏳ empeoró con $actionLabel',
    };
  }

  /// Wraps _retroActionTag in a Padding+Text matching the visual
  /// language of the existing detail compact summaries. Returns
  /// SizedBox.shrink() when the tag is empty (zero-cost absence).
  Widget _retroActionWidget(SymptomEvent event) {
    final tag = _retroActionTag(event);
    if (tag.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Text(
        tag,
        style: TextStyle(color: _cc.withValues(alpha: 0.6), fontSize: 11),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final todaysStructs = _p.getStructuralActiveForDay(widget.selectedDate);
    final todaysSymptoms = _p.getSymptomsForDay(widget.selectedDate);
    final todaysBowel = _p.getBowelForDay(widget.selectedDate);
    final todaysHemorrhoidal = _p.getHemorrhoidalForDay(widget.selectedDate);
    final todaysFever = _p.getFeverForDay(widget.selectedDate);
    final todaysSleep = _p.getSleepForDay(widget.selectedDate);
    final todaysHydration = _p.getHydrationForDay(widget.selectedDate);
    final todaysHrv = _p.getHrvForDay(widget.selectedDate);
    final isSleepEnabled = _p.settings.optionalTrackers['sleep'] ?? false;
    final isHydrationEnabled =
        _p.settings.optionalTrackers['hydration'] ?? false;
    final isHrvEnabled = _p.settings.optionalTrackers['hrv'] ?? false;
    final isCarefulMode = _p.settings.optionalTrackers['careful_mode'] ?? false;
    final trending = _p.getTrendingSymptoms();
    final l10n = context.l10n;

    // F3: precompute each section's initial expanded state + hint label.
    // ValueKey on each CollapsibleSection includes isCarefulMode so toggling
    // it from settings forces a rebuild that re-applies initiallyExpanded.
    final structState = _sectionState(
      _p.structuralHistory.map((e) => e.timestamp),
      l10n,
      isCarefulMode,
    );
    final bowelState = _sectionState(
      _p.bowelHistory
          .map((e) => e.timestamp)
          .followedBy(_p.hemorrhoidalHistory.map((e) => e.timestamp)),
      l10n,
      isCarefulMode,
    );
    final feverState = _sectionState(
      _p.feverHistory.map((e) => e.timestamp),
      l10n,
      isCarefulMode,
    );
    final sleepState = _sectionState(
      _p.sleepHistory.map((e) => e.timestamp),
      l10n,
      isCarefulMode,
    );
    final hydrationState = _sectionState(
      _p.hydrationHistory.map((e) => e.timestamp),
      l10n,
      isCarefulMode,
    );
    final hrvState = _sectionState(
      _p.hrvHistory.map((e) => e.timestamp),
      l10n,
      isCarefulMode,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. STRUCTURAL ZONES (wrapped in CollapsibleSection — F3)
        CollapsibleSection(
          key: ValueKey('struct_$isCarefulMode'),
          title: l10n.symptomsSectionStructuralZones,
          hint: structState.hint,
          initiallyExpanded: structState.expanded,
          contrastColor: _cc,
          child: BodyZonePickerGrid(
            contrastColor: _cc,
            onZoneTap: (zone) => _openStructuralEntry(zone),
          ),
        ),

        // PHASE 5.1 — TRÁNSITO INTESTINAL (wrapped F3)
        const SizedBox(height: 16),
        CollapsibleSection(
          key: ValueKey('bowel_$isCarefulMode'),
          title: l10n.symptomsSectionBowelTransit,
          hint: bowelState.hint,
          initiallyExpanded: bowelState.expanded,
          contrastColor: _cc,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _bucketCard(
                    BowelBucket.constipation,
                    Icons.remove_circle_outline,
                    l10n,
                  ),
                  _bucketCard(BowelBucket.normal, Icons.circle_outlined, l10n),
                  _bucketCard(BowelBucket.diarrhea, Icons.waves, l10n),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _cc.withValues(alpha: 0.4)),
                  ),
                  icon: Icon(Icons.add, color: _cc, size: 16),
                  label: Text(
                    l10n.symptomsActionAddHemorrhoid,
                    style: TextStyle(color: _cc, fontSize: 12),
                  ),
                  onPressed: _openHemorrhoidalForm,
                ),
              ),
            ],
          ),
        ),

        // PHASE 5.2d.2 — FIEBRE (wrapped F3)
        const SizedBox(height: 16),
        CollapsibleSection(
          key: ValueKey('fever_$isCarefulMode'),
          title: l10n.feverSectionTitle,
          hint: feverState.hint,
          initiallyExpanded: feverState.expanded,
          contrastColor: _cc,
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _cc.withValues(alpha: 0.5)),
              ),
              icon: Icon(Icons.thermostat, color: _cc, size: 18),
              label: Text(
                l10n.feverActionAddReading,
                style: TextStyle(
                  color: _cc,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _openFeverForm,
            ),
          ),
        ),

        // F6.a SLEEP — optional module + collapsible (F3)
        if (isSleepEnabled) ...[
          const SizedBox(height: 16),
          CollapsibleSection(
            key: ValueKey('sleep_$isCarefulMode'),
            title: l10n.sleepSectionTitle,
            hint: sleepState.hint,
            initiallyExpanded: sleepState.expanded,
            contrastColor: _cc,
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _cc.withValues(alpha: 0.5)),
                ),
                icon: Icon(Icons.bedtime_outlined, color: _cc, size: 18),
                label: Text(
                  l10n.sleepActionAddEntry,
                  style: TextStyle(
                    color: _cc,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _openSleepForm,
              ),
            ),
          ),
        ],

        // F6.b HIDRATACIÓN — optional module + collapsible (F3)
        if (isHydrationEnabled) ...[
          const SizedBox(height: 16),
          CollapsibleSection(
            key: ValueKey('hydration_$isCarefulMode'),
            title: l10n.hydrationSectionTitle,
            hint: hydrationState.hint,
            initiallyExpanded: hydrationState.expanded,
            contrastColor: _cc,
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _cc.withValues(alpha: 0.5)),
                ),
                icon: Icon(Icons.local_drink_outlined, color: _cc, size: 18),
                label: Text(
                  l10n.hydrationActionAddEntry,
                  style: TextStyle(
                    color: _cc,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _openHydrationForm,
              ),
            ),
          ),
        ],

        // F6.b HRV — optional module + collapsible (F3)
        if (isHrvEnabled) ...[
          const SizedBox(height: 16),
          CollapsibleSection(
            key: ValueKey('hrv_$isCarefulMode'),
            title: l10n.hrvSectionTitle,
            hint: hrvState.hint,
            initiallyExpanded: hrvState.expanded,
            contrastColor: _cc,
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _cc.withValues(alpha: 0.5)),
                ),
                icon: Icon(Icons.favorite_border, color: _cc, size: 18),
                label: Text(
                  l10n.hrvActionAddEntry,
                  style: TextStyle(
                    color: _cc,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _openHrvForm,
              ),
            ),
          ),
        ],

        // 2. TODAY'S COMBINED LOG
        if (todaysStructs.isNotEmpty ||
            todaysSymptoms.isNotEmpty ||
            todaysBowel.isNotEmpty ||
            todaysHemorrhoidal.isNotEmpty ||
            todaysFever.isNotEmpty ||
            todaysSleep.isNotEmpty ||
            todaysHydration.isNotEmpty ||
            todaysHrv.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            l10n.symptomsSectionTodaysLogs,
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
            child: Column(
              children: [
                ...todaysStructs.map((e) {
                  // 2026-07-18 — carried-over entries are unresolved
                  // pain logged on an earlier day, surfaced today by
                  // getStructuralActiveForDay so persistent pain
                  // doesn't need re-logging. Tagged distinctly and
                  // without the destructive delete: removing it here
                  // would erase the original log entry, which is
                  // surprising from a view that's just showing it's
                  // still ongoing.
                  final isCarriedOver = !DateUtils.isSameDay(
                    e.timestamp,
                    widget.selectedDate,
                  );
                  return InkWell(
                    onLongPress: () => _editStructuralEvent(e),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(_iconForKind(e.kind), color: _cc, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "[${DateFormat('HH:mm').format(e.timestamp)}] "
                                  "${e.zone.bodyZoneLabel(l10n)}: "
                                  "${e.type.structuralTypeLabel(l10n)}"
                                  "${e.isResolved ? ' ✓' : ''}",
                                  style: TextStyle(color: _cc, fontSize: 13),
                                ),
                                if (isCarriedOver)
                                  Text(
                                    l10n.structuralOngoingSinceTag(
                                      DateFormat('d MMM').format(e.timestamp),
                                    ),
                                    style: TextStyle(
                                      color: _cc.withValues(alpha: 0.6),
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                if (_structuralCompactSummary(e).isNotEmpty)
                                  Text(
                                    _structuralCompactSummary(e),
                                    style: TextStyle(
                                      color: _cc.withValues(alpha: 0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (!e.isResolved)
                            IconButton(
                              icon: Icon(
                                Icons.check_circle_outline,
                                color: _cc,
                                size: 18,
                              ),
                              tooltip: l10n.structuralCheckInSame,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _openStructuralCheckIn(e),
                            ),
                          if (!isCarriedOver)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 18,
                              ),
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
                  );
                }),
                ...todaysBowel.map(
                  (e) => InkWell(
                    onLongPress: () => _editBowelEvent(e),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            switch (e.bucket) {
                              BowelBucket.constipation =>
                                Icons.remove_circle_outline,
                              BowelBucket.normal => Icons.circle_outlined,
                              BowelBucket.diarrhea => Icons.waves,
                            },
                            color: _cc,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "[${DateFormat('HH:mm').format(e.timestamp)}] ${e.bucket.bowelBucketLabel(l10n)}"
                                  "${e.bristolType != null ? ' · ${l10n.bowelLogBristolTypeTemplate(e.bristolType!)}' : ''}"
                                  "${e.urgency ? ' · ${l10n.bowelLogTagUrgency}' : ''}"
                                  "${e.bloodPresent ? ' · ${l10n.bowelLogTagBleeding}' : ''}"
                                  "${e.incompleteEvacuation ? ' · ${l10n.bowelLogTagIncomplete}' : ''}",
                                  style: TextStyle(color: _cc, fontSize: 13),
                                ),
                                if (e.note != null && e.note!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      e.note!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
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
                            onPressed: () {
                              setState(() => _p.bowelHistory.remove(e));
                              widget.onProfileChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ...todaysHemorrhoidal.map(
                  (e) => InkWell(
                    onLongPress: () => _editHemorrhoidalEvent(e),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.healing, color: _cc, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "[${DateFormat('HH:mm').format(e.timestamp)}] ${l10n.hemorrhoidalLogLabel}"
                                  "${e.bleeding ? ' · ${l10n.hemorrhoidalLogTagBleeding}' : ''}"
                                  "${e.severity != SymptomSeverity.none ? ' (${e.severity.severityLabel(l10n).toLowerCase()})' : ''}",
                                  style: TextStyle(color: _cc, fontSize: 13),
                                ),
                                if (e.note != null && e.note!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      e.note!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
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
                            onPressed: () {
                              setState(() => _p.hemorrhoidalHistory.remove(e));
                              widget.onProfileChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ...todaysFever.map(
                  (e) => InkWell(
                    onLongPress: () => _editFeverEvent(e),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.thermostat, color: _cc, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "[${DateFormat('HH:mm').format(e.timestamp)}] "
                                  "${e.temperatureC.toStringAsFixed(1)}°C"
                                  " · ${e.site.label(l10n)}"
                                  "${e.antipyreticTaken ? ' · ${l10n.feverLogLabelWithAntipyretic}' : ''}",
                                  style: TextStyle(color: _cc, fontSize: 13),
                                ),
                                if (e.note != null && e.note!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      e.note!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
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
                            onPressed: () {
                              setState(() => _p.feverHistory.remove(e));
                              widget.onProfileChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ...todaysSleep.map(
                  (e) => InkWell(
                    onLongPress: () => _editSleepEvent(e),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.bedtime_outlined, color: _cc, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatSleepEntry(e, l10n),
                                  style: TextStyle(color: _cc, fontSize: 13),
                                ),
                                if (e.note != null && e.note!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      e.note!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
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
                            onPressed: () {
                              setState(() => _p.sleepHistory.remove(e));
                              widget.onProfileChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ...todaysHydration.map(
                  (e) => InkWell(
                    onLongPress: () => _editHydrationEvent(e),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_drink_outlined,
                            color: _cc,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatHydrationEntry(e, l10n),
                                  style: TextStyle(color: _cc, fontSize: 13),
                                ),
                                if (e.note != null && e.note!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      e.note!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
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
                            onPressed: () {
                              setState(() => _p.hydrationHistory.remove(e));
                              widget.onProfileChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ...todaysHrv.map(
                  (e) => InkWell(
                    onLongPress: () => _editHrvEvent(e),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.favorite_border, color: _cc, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatHrvEntry(e, l10n),
                                  style: TextStyle(color: _cc, fontSize: 13),
                                ),
                                if (e.note != null && e.note!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      e.note!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
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
                            onPressed: () {
                              setState(() => _p.hrvHistory.remove(e));
                              widget.onProfileChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ...todaysSymptoms.map((event) {
                  final unrated = _isUnrated(event.severity);
                  return InkWell(
                    onLongPress: () => _editSymptomEvent(event),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            unrated
                                ? Icons.radio_button_unchecked
                                : Icons.circle,
                            color: unrated
                                ? Colors.grey
                                : _severityColor(event.severity),
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  unrated
                                      ? "[${DateFormat('HH:mm').format(event.timestamp)}] ${event.name} · ${l10n.symptomLogTagUnrated}"
                                      : "[${DateFormat('HH:mm').format(event.timestamp)}] ${event.name} (${event.severity.severityLabel(l10n)})",
                                  style: TextStyle(
                                    color: _cc,
                                    fontSize: 13,
                                    fontStyle: unrated
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                ),
                                // C.4: headache detail compact summary
                                if (event.headacheDetail != null &&
                                    formatHeadacheDetailCompact(
                                      event.headacheDetail!,
                                      l10n,
                                    ).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      formatHeadacheDetailCompact(
                                        event.headacheDetail!,
                                        l10n,
                                      ),
                                      style: TextStyle(
                                        color: _cc.withValues(alpha: 0.6),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                // D.1: fatigue detail compact summary
                                if (event.fatigueDetail != null &&
                                    formatFatigueDetailCompact(
                                      event.fatigueDetail!,
                                      l10n.localeName,
                                    ).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      formatFatigueDetailCompact(
                                        event.fatigueDetail!,
                                        l10n.localeName,
                                      ),
                                      style: TextStyle(
                                        color: _cc.withValues(alpha: 0.6),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                // D.2: abdominal detail compact summary
                                if (event.abdominalDetail != null &&
                                    formatAbdominalDetailCompact(
                                      event.abdominalDetail!,
                                      l10n.localeName,
                                    ).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      formatAbdominalDetailCompact(
                                        event.abdominalDetail!,
                                        l10n.localeName,
                                      ),
                                      style: TextStyle(
                                        color: _cc.withValues(alpha: 0.6),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                // D.3: presyncope detail compact summary
                                if (event.presyncopeDetail != null &&
                                    formatPresyncopeDetailCompact(
                                      event.presyncopeDetail!,
                                      l10n.localeName,
                                    ).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      formatPresyncopeDetailCompact(
                                        event.presyncopeDetail!,
                                        l10n.localeName,
                                      ),
                                      style: TextStyle(
                                        color: _cc.withValues(alpha: 0.6),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                // D.4: pelvic pain detail compact summary
                                if (event.pelvicPainDetail != null &&
                                    formatPelvicPainDetailCompact(
                                      event.pelvicPainDetail!,
                                      l10n.localeName,
                                    ).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      formatPelvicPainDetailCompact(
                                        event.pelvicPainDetail!,
                                        l10n.localeName,
                                      ),
                                      style: TextStyle(
                                        color: _cc.withValues(alpha: 0.6),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                // E.D: MCAS detail compact summary
                                if (event.mcasDetail != null &&
                                    formatMCASDetailCompact(
                                      event.mcasDetail!,
                                      l10n.localeName,
                                    ).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      formatMCASDetailCompact(
                                        event.mcasDetail!,
                                        l10n.localeName,
                                      ),
                                      style: TextStyle(
                                        color: _cc.withValues(alpha: 0.6),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                if (event.note != null &&
                                    event.note!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      event.note!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                // Sprint F.E3 — retro action summary tag
                                _retroActionWidget(event),
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
          Text(
            l10n.symptomsFootnoteLongPressEdit,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],

        // 3. TRENDING
        const SizedBox(height: 28),
        Text(
          l10n.symptomsSectionTrending,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 14,
            color: _cc,
          ),
        ),
        const SizedBox(height: 8),
        if (trending.isEmpty)
          Text(
            l10n.symptomsTrendingEmpty,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
              fontSize: 14,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trending
                .map(
                  (s) => ActionChip(
                    backgroundColor: _ic,
                    side: BorderSide(color: _cc, width: 2),
                    label: Text(
                      s,
                      style: TextStyle(
                        color: _cc,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _dispatchSymptomInput(s),
                  ),
                )
                .toList(),
          ),

        // Sprint T0.3 — symptom frequency dashboard (rolling 30 days)
        // Sprint G.C — hide when in flare mode.
        if (!_p.state.isInFlare)
          SymptomFrequencyDashboard(profile: _p, contrastColor: _cc),

        // 4. SYMPTOM VAULT + INLINE ADD
        const SizedBox(height: 28),
        Text(
          l10n.symptomsSectionVault,
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
          children: _p.symptomVault
              .map(
                (s) => ActionChip(
                  backgroundColor: _ic,
                  side: const BorderSide(color: Colors.grey),
                  label: Text(
                    s,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  onPressed: () => _dispatchSymptomInput(s),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _newSymptomCtrl,
          style: TextStyle(color: _cc),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addSymptomToVault(),
          decoration: InputDecoration(
            hintText: l10n.symptomsVaultPlaceholder,
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
    if (!_p.symptomVault.contains(txt)) {
      setState(() => _p.symptomVault.insert(0, txt));
      widget.onProfileChanged();
    }
    _newSymptomCtrl.clear();
    _dispatchSymptomInput(txt);
  }

  // ---------------------------------------------------------------------------
  // STRUCTURAL MODALS
  // ---------------------------------------------------------------------------

  /// §12/§12.6b — compact summary line for the "Registros de hoy"
  /// timeline. Renders whichever of the three capture paths produced
  /// data: the 4-group pain funnel (structuralDetail), the bleeding
  /// detail (bleedingDetail, softTissue-kind events), or the
  /// zone-history quick-log (severity + comparedToUsual). Empty string
  /// when the event predates this sprint or came from the classic
  /// picker with nothing attached.
  ///
  /// 2026-07-18: a later _openStructuralCheckIn can set comparedToUsual
  /// on an event that ALSO has a funnel/bleeding detail attached (a
  /// check-in doesn't care how the event was originally created) — that
  /// case is appended after the base summary instead of being
  /// shadowed by it, so a check-in update stays visible in the timeline.
  String _structuralCompactSummary(StructuralEvent e) {
    final l10n = context.l10n;
    final bleedingDetail = e.bleedingDetail;
    final detail = e.structuralDetail;

    String base;
    if (bleedingDetail != null) {
      base = formatStructuralBleedingDetailCompact(
        bleedingDetail,
        l10n.localeName,
      );
    } else if (detail != null) {
      base = formatStructuralDetailCompact(detail, l10n.localeName);
    } else if (e.severity != null || e.comparedToUsual != null) {
      // Quick-log path already combines severity + comparedToUsual.
      return formatStructuralQuickLogCompact(e, l10n);
    } else {
      base = '';
    }

    final cmp = e.comparedToUsual;
    if (cmp == null) return base;
    final cmpLabel = switch (cmp) {
      StructuralComparisonToUsual.worse => l10n.structuralComparedToUsualWorse,
      StructuralComparisonToUsual.normal =>
        l10n.structuralComparedToUsualNormal,
      StructuralComparisonToUsual.better =>
        l10n.structuralComparedToUsualBetter,
    };
    return [
      if (base.isNotEmpty) base,
      cmpLabel.toLowerCase(),
    ].join(' · ');
  }

  /// §12 — entry point for tapping a zone chip (or for the vault
  /// free-text detector once it has resolved a zone).
  ///
  /// 2026-07-18: checked FIRST, ahead of both the quick-log and the
  /// funnel — if this zone already has an unresolved StructuralEvent
  /// (persistent pain that hasn't been marked better/resolved), route
  /// to the check-in sheet instead of starting a whole new entry. This
  /// is what makes structural pain "persistent" in practice: the
  /// patient updates the existing event instead of re-logging the same
  /// pain every day. Otherwise routes to the quick-log sheet when the
  /// zone has a saved StructuralZoneHistoryEntry (quick-log has no kind
  /// step — [initialKind] is ignored there, untouched by the 18-jul
  /// rework), otherwise to the combined sheet.
  void _openStructuralEntry(String zone, {StructuralEventKind? initialKind}) {
    final ongoing = _p.structuralHistory
        .where((e) => e.zone == zone && !e.isResolved)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (ongoing.isNotEmpty) {
      _openStructuralCheckIn(ongoing.first);
      return;
    }
    final known = _p.structuralZoneHistory.where((h) => h.zone == zone);
    if (known.isNotEmpty) {
      _openStructuralQuickLog(zone, known.first);
    } else {
      _openStructuralFunnel(zone, initialKind: initialKind);
    }
  }

  /// 2026-07-18 — quick status update for an unresolved (persistent)
  /// StructuralEvent: updates the SAME event in place (comparedToUsual,
  /// or resolvedAt) instead of creating a new one. Used both by the
  /// zone-tap shortcut in [_openStructuralEntry] and by the check-in
  /// icon on carried-over entries in "Registros de hoy".
  Future<void> _openStructuralCheckIn(StructuralEvent event) async {
    final outcome = await showStructuralCheckInSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      zoneLabel: event.zone.bodyZoneLabel(context.l10n),
      since: event.timestamp,
    );
    if (outcome == null || !mounted) return;
    final idx = _p.structuralHistory.indexOf(event);
    if (idx == -1) return;
    setState(() {
      _p.structuralHistory[idx] = switch (outcome) {
        StructuralCheckInOutcome.same => event.copyWith(
          comparedToUsual: StructuralComparisonToUsual.normal,
        ),
        StructuralCheckInOutcome.better => event.copyWith(
          comparedToUsual: StructuralComparisonToUsual.better,
        ),
        StructuralCheckInOutcome.worse => event.copyWith(
          comparedToUsual: StructuralComparisonToUsual.worse,
        ),
        StructuralCheckInOutcome.resolved => event.copyWith(
          resolvedAt: DateTime.now(),
        ),
      };
    });
    widget.onProfileChanged();
  }

  /// §12.6 — zones with a known antecedent skip straight to severity +
  /// "¿distinto a lo usual?", no picker, no funnel — unless the user
  /// flags the episode as a new/different issue (isNewIssue), in which
  /// case it's handed off to the full funnel instead of being bucketed
  /// under the saved history's kind.
  Future<void> _openStructuralQuickLog(
    String zone,
    StructuralZoneHistoryEntry history,
  ) async {
    final result = await showStructuralQuickLogSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
    );
    if (result == null) return;
    if (!mounted) return;
    if (result.isNewIssue) {
      await _openStructuralFunnel(zone);
      return;
    }
    if (result.severity == null) return;
    setState(
      () => _p.structuralHistory.add(
        StructuralEvent(
          timestamp: _timestampForLog(),
          zone: zone,
          kind: history.kind,
          type: 'known_condition_flare',
          severity: result.severity,
          comparedToUsual: result.comparedToUsual,
        ),
      ),
    );
    widget.onProfileChanged();
  }

  /// 18-jul-2026 rework — default path for zones with no saved
  /// history: the combined sheet, asking for whatever of zone/kind
  /// isn't already known plus the 4 detail groups. "Ya sé qué es"
  /// defers to the unchanged classic picker instead.
  Future<void> _openStructuralFunnel(
    String zone, {
    StructuralEventKind? initialKind,
  }) async {
    final result = await showStructuralDetailSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      initialZone: zone,
      initialKind: initialKind,
    );
    if (result == null || !mounted) return;
    await _handleStructuralSheetResult(
      result,
      fallbackZoneForClassicPicker: zone,
    );
  }

  /// Shared save/dispatch logic for the combined sheet, used by both
  /// the zone-tap path ([_openStructuralFunnel]) and the vault
  /// free-text path ([_openCombinedSheetForVault]).
  Future<void> _handleStructuralSheetResult(
    StructuralDetailSheetResult result, {
    required String? fallbackZoneForClassicPicker,
  }) async {
    if (result.useClassicPicker) {
      final zone = result.zone ?? fallbackZoneForClassicPicker;
      if (zone == null) return;
      _openStructuralMenu(zone);
      return;
    }
    final zone = result.zone;
    final kind = result.kind;
    if (zone == null || kind == null) return; // skip outcome

    setState(
      () => _p.structuralHistory.add(
        StructuralEvent(
          timestamp: _timestampForLog(),
          zone: zone,
          kind: kind,
          type: kGenericStructuralTypeForKind[kind]!,
          structuralDetail: result.detail,
          bleedingDetail: result.bleedingDetail,
        ),
      ),
    );
    widget.onProfileChanged();

    final noHistoryYet = _p.structuralZoneHistory.every((h) => h.zone != zone);
    if (result.detail?.antecedent == StructuralAntecedent.knownCondition &&
        noHistoryYet) {
      await _offerSaveZoneHistory(zone);
    }
  }

  /// 18-jul-2026 rework — entry point for the vault free-text path
  /// when the detector resolved a kind but not a zone (e.g. "dolor
  /// muscular"). Zone-resolved matches instead reuse
  /// [_openStructuralEntry] verbatim (see [_dispatchSymptomInput]) so
  /// they also benefit from zone-history quick-log routing.
  Future<void> _openCombinedSheetForVault({
    StructuralEventKind? initialKind,
    List<String>? candidateZones,
  }) async {
    final result = await showStructuralDetailSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      initialKind: initialKind,
      candidateZones: candidateZones,
    );
    if (result == null || !mounted) return;
    await _handleStructuralSheetResult(
      result,
      fallbackZoneForClassicPicker: null,
    );
  }

  /// 18-jul-2026 rework — central dispatcher for any free-text symptom
  /// name (vault chip tap/add, trending chip tap). Checked BEFORE the
  /// structural detector, in this exact order, so existing flows keep
  /// working unchanged: headache/fatigue/abdominal_pain/presyncope/
  /// pelvic_pain (JSON alias match) and MCAS (keyword heuristic) always
  /// win over structural detection — e.g. "dolor de cabeza" and "dolor
  /// de guata" must never be intercepted here. Only when none of those
  /// match does the structural zone/kind detector get a chance; if it
  /// finds nothing either, falls through to the original generic
  /// severity menu.
  void _dispatchSymptomInput(String symptom) {
    final svc = SymptomDefinitionsService.instance;
    final isKnownNonStructural =
        svc.matchesSymptomKey(symptom, 'headache') ||
        svc.matchesSymptomKey(symptom, 'fatigue') ||
        svc.matchesSymptomKey(symptom, 'abdominal_pain') ||
        svc.matchesSymptomKey(symptom, 'presyncope') ||
        svc.matchesSymptomKey(symptom, 'pelvic_pain') ||
        _isMCASSymptom(symptom);
    if (!isKnownNonStructural) {
      final match = detectStructuralTextMatch(symptom);
      if (!match.isEmpty) {
        if (match.zone != null) {
          _openStructuralEntry(match.zone!, initialKind: match.kind);
        } else {
          _openCombinedSheetForVault(
            initialKind: match.kind,
            candidateZones: match.ambiguousZoneCandidates,
          );
        }
        return;
      }
    }
    _openSeverityMenu(symptom);
  }

  /// §12.6.3 — post-funnel offer to save a known antecedent, shown
  /// only the first time "Condición conocida/antigua" is marked for a
  /// zone that doesn't have a history entry yet.
  Future<void> _offerSaveZoneHistory(String zone) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final accept = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _ic,
        shape: RoundedRectangleBorder(side: BorderSide(color: _cc, width: 2)),
        title: Text(
          l10n.structuralZoneHistoryOfferTitle,
          style: TextStyle(
            color: _cc,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          l10n.structuralZoneHistoryOfferBody,
          style: TextStyle(color: _cc, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              l10n.structuralZoneHistoryOfferDecline,
              style: TextStyle(color: _cc.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _cc),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              l10n.structuralZoneHistoryOfferAccept,
              style: TextStyle(color: _ic, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (accept != true) return;
    if (!mounted) return;
    final entry = await showStructuralZoneHistoryFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      initialZone: zone,
    );
    if (entry == null) return;
    setState(() => _p.structuralZoneHistory.add(entry));
    widget.onProfileChanged();
  }

  void _openStructuralMenu(String zone) {
    DateTime ts = _timestampForLog();
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
                    context.l10n.symptomsModalLogHeader(
                      zone.bodyZoneLabel(context.l10n).toUpperCase(),
                    ),
                    style: TextStyle(
                      color: _cc,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 16),
                  ...kStructuralTaxonomy.entries.expand(
                    (entry) => [
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 2),
                        child: Text(
                          entry.key.label(context.l10n).toUpperCase(),
                          style: TextStyle(
                            color: _cc.withValues(alpha: 0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ...entry.value.map(
                        (type) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(
                            _iconForKind(entry.key),
                            color: _cc,
                            size: 18,
                          ),
                          title: Text(
                            type.structuralTypeLabel(context.l10n),
                            style: TextStyle(color: _cc, fontSize: 13),
                          ),
                          onTap: () async {
                            // §12.6b — softTissue types (except 'burn', not
                            // a bleeding phenomenon) ask for
                            // origin+severity (ISTH-BAT adaptado) before
                            // saving. Pop this picker first, then await the
                            // standalone sheet — same "caller owns
                            // sequencing" pattern as the "Ya sé qué es"
                            // shortcut (see structural_detail_sheet.dart).
                            Navigator.pop(ctx);
                            StructuralBleedingDetail? bleedingDetail;
                            if (entry.key == StructuralEventKind.softTissue &&
                                type != 'burn') {
                              bleedingDetail =
                                  await showStructuralBleedingDetailSheet(
                                    context: context,
                                    contrastColor: _cc,
                                    inverseContrastColor: _ic,
                                  );
                              if (!mounted) return;
                            }
                            setState(
                              () => _p.structuralHistory.add(
                                StructuralEvent(
                                  timestamp: ts,
                                  zone: zone,
                                  kind: entry.key,
                                  type: type,
                                  bleedingDetail: bleedingDetail,
                                ),
                              ),
                            );
                            widget.onProfileChanged();
                          },
                        ),
                      ),
                    ],
                  ),
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
    DateTime? resolvedAt = event.resolvedAt;
    bool stillPainful = event.stillPainful;

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
                    context.l10n.symptomsModalEditHeader(
                      event.zone.bodyZoneLabel(context.l10n).toUpperCase(),
                      event.type.structuralTypeLabel(context.l10n),
                    ),
                    style: TextStyle(
                      color: _cc,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.kind.label(context.l10n),
                    style: TextStyle(
                      color: _cc.withValues(alpha: 0.55),
                      fontSize: 11,
                      letterSpacing: 0.5,
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
                  const SizedBox(height: 20),

                  // Healing tracking section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: _cc.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 2),
                          child: Text(
                            context.l10n.structuralFormFollowupHeader,
                            style: TextStyle(
                              color: _cc.withValues(alpha: 0.55),
                              fontSize: 10,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            context.l10n.structuralFormFollowupResolvedQuestion,
                            style: TextStyle(color: _cc, fontSize: 13),
                          ),
                          value: resolvedAt != null,
                          activeColor: _cc,
                          onChanged: (v) async {
                            if (v) {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: DateTime.now(),
                                firstDate: event.timestamp,
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setSheet(() => resolvedAt = picked);
                              }
                            } else {
                              setSheet(() {
                                resolvedAt = null;
                                stillPainful = false;
                              });
                            }
                          },
                        ),
                        if (resolvedAt != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              context.l10n
                                  .structuralFormFollowupResolvedDateTemplate(
                                    DateFormat(
                                      'd MMM yyyy',
                                    ).format(resolvedAt!),
                                  ),
                              style: TextStyle(
                                color: _cc.withValues(alpha: 0.65),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              context
                                  .l10n
                                  .structuralFormFollowupStillPainfulQuestion,
                              style: TextStyle(color: _cc, fontSize: 13),
                            ),
                            subtitle: Text(
                              context
                                  .l10n
                                  .structuralFormFollowupStillPainfulSubtitle,
                              style: TextStyle(
                                color: _cc.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                            value: stillPainful,
                            activeColor: _cc,
                            onChanged: (v) => setSheet(() => stillPainful = v),
                          ),
                        ],
                      ],
                    ),
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
                        setState(
                          () => _p.structuralHistory[idx] = event.copyWith(
                            timestamp: ts,
                            resolvedAt: resolvedAt,
                            clearResolvedAt: resolvedAt == null,
                            stillPainful: stillPainful,
                          ),
                        );
                        widget.onProfileChanged();
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      context.l10n.symptomsActionSave,
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

  // F4: icon per kind for the cascading picker
  IconData _iconForKind(StructuralEventKind kind) => switch (kind) {
    StructuralEventKind.joint => Icons.adjust,
    StructuralEventKind.muscle => Icons.fitness_center,
    StructuralEventKind.tendon => Icons.gesture,
    StructuralEventKind.ligament => Icons.link,
    StructuralEventKind.softTissue => Icons.healing,
    StructuralEventKind.nerve => Icons.flash_on,
    StructuralEventKind.painWithoutClearCause => Icons.help_outline,
  };

  // ---------------------------------------------------------------------------
  // SYMPTOM MODALS
  // ---------------------------------------------------------------------------

  void _openSeverityMenu(String symptom) {
    final noteCtrl = TextEditingController();
    DateTime ts = _timestampForLog();

    Future<void> saveWith(SymptomSeverity sev, BuildContext ctx) async {
      final note = noteCtrl.text.trim();

      // C.4 / D.1 / D.2: offer the appropriate detail layer when
      // the symptom matches cefalea, fatiga or dolor abdominal
      // (including bloating/gas variants) AND the corresponding
      // tracker is enabled. Aliases for the three symptoms do not
      // overlap, so at most one branch fires per save.
      final svc = SymptomDefinitionsService.instance;
      final isHeadache = svc.matchesSymptomKey(symptom, 'headache');
      final headacheLayerEnabled =
          _p.settings.optionalTrackers['headache_detail'] ?? false;
      final isFatigue = svc.matchesSymptomKey(symptom, 'fatigue');
      final fatigueLayerEnabled =
          _p.settings.optionalTrackers['fatigue_detail'] ?? false;
      final isAbdominal = svc.matchesSymptomKey(symptom, 'abdominal_pain');
      final abdominalLayerEnabled =
          _p.settings.optionalTrackers['abdominal_detail'] ?? false;
      final isPresyncope = svc.matchesSymptomKey(symptom, 'presyncope');
      final presyncopeLayerEnabled =
          _p.settings.optionalTrackers['presyncope_detail'] ?? false;
      final isPelvicPain = svc.matchesSymptomKey(symptom, 'pelvic_pain');
      final pelvicPainLayerEnabled =
          _p.settings.optionalTrackers['pelvic_pain_detail'] ?? false;
      final isMCAS = _isMCASSymptom(symptom);
      final mcasLayerEnabled =
          _p.settings.optionalTrackers['mcas_detail'] ?? false;

      HeadacheDetail? headacheDetail;
      FatigueDetail? fatigueDetail;
      AbdominalDetail? abdominalDetail;
      PresyncopeDetail? presyncopeDetail;
      PelvicPainDetail? pelvicPainDetail;
      MCASDetail? mcasDetail;
      if (isHeadache && headacheLayerEnabled) {
        // Close the severity sheet first so the detail sheet stacks
        // over the SintomasTab, not over the severity modal.
        Navigator.pop(ctx);
        if (!mounted) return;
        headacheDetail = await showHeadacheDetailSheet(
          context: context,
          contrastColor: _cc,
          inverseContrastColor: _ic,
        );
        if (!mounted) return;
      } else if (isFatigue && fatigueLayerEnabled) {
        Navigator.pop(ctx);
        if (!mounted) return;
        fatigueDetail = await showFatigueDetailSheet(
          context,
          contrastColor: _cc,
          inverseContrastColor: _ic,
        );
        if (!mounted) return;
      } else if (isAbdominal && abdominalLayerEnabled) {
        Navigator.pop(ctx);
        if (!mounted) return;
        abdominalDetail = await showAbdominalDetailSheet(
          context,
          symptomInput: symptom,
          contrastColor: _cc,
          inverseContrastColor: _ic,
        );
        if (!mounted) return;
      } else if (isPresyncope && presyncopeLayerEnabled) {
        Navigator.pop(ctx);
        if (!mounted) return;
        presyncopeDetail = await showPresyncopeDetailSheet(
          context: context,
          contrastColor: _cc,
          inverseContrastColor: _ic,
        );
        if (!mounted) return;
      } else if (isPelvicPain && pelvicPainLayerEnabled) {
        Navigator.pop(ctx);
        if (!mounted) return;
        pelvicPainDetail = await showPelvicPainDetailSheet(
          context: context,
          contrastColor: _cc,
          inverseContrastColor: _ic,
        );
        if (!mounted) return;
      } else if (isMCAS && mcasLayerEnabled) {
        Navigator.pop(ctx);
        if (!mounted) return;
        mcasDetail = await showMCASDetailSheet(
          context,
          symptomInput: symptom,
          contrastColor: _cc,
          inverseContrastColor: _ic,
        );
        if (!mounted) return;
      } else {
        Navigator.pop(ctx);
      }

      // D.2.E: reverse integration on save.
      if (abdominalDetail != null) {
        abdominalDetail = await _maybeLinkToBowelEvent(abdominalDetail, ts);
        if (!mounted) return;
      }

      final newSymptomEvent = SymptomEvent(
        timestamp: ts,
        name: symptom,
        severity: sev,
        note: note.isEmpty ? null : note,
        headacheDetail: headacheDetail,
        fatigueDetail: fatigueDetail,
        abdominalDetail: abdominalDetail,
        presyncopeDetail: presyncopeDetail,
        pelvicPainDetail: pelvicPainDetail,
        mcasDetail: mcasDetail,
      );
      setState(() => _p.symptomHistory.add(newSymptomEvent));
      widget.onProfileChanged();

      // Surface advisory / urgent red flags after save.
      // - Cefalea thunderclap handled IN-SHEET.
      // - Fatiga has no URGENT flags.
      // - Abdominal tearing pain handled IN-SHEET; hematochezia
      //   and hematemesis surfaced here as URGENT.
      if (headacheDetail != null) {
        final flags = detectHeadacheRedFlags(
          detail: headacheDetail,
          severityIndex: sev.value,
        );
        await _showHeadacheAdvisoryFlags(flags);
      }
      if (fatigueDetail != null) {
        final flags = detectFatigueRedFlags(
          detail: fatigueDetail,
          severityIndex: sev.value,
        );
        await _showFatigueAdvisoryFlags(flags);
      }
      if (abdominalDetail != null) {
        final flags = detectAbdominalRedFlags(
          detail: abdominalDetail,
          severityIndex: sev.value,
          noteText: note.isEmpty ? null : note,
        );
        await _showAbdominalUrgentFlags(flags);
        if (!mounted) return;
        await _showAbdominalAdvisoryFlags(flags);
      }
      // D.3: brief loss of consciousness handled IN-SHEET; exertional
      // and no-position-change triggers surfaced here as ADVISORY.
      if (presyncopeDetail != null) {
        final flags = detectPresyncopeRedFlags(
          detail: presyncopeDetail,
          severityIndex: sev.value,
        );
        await _showPresyncopeAdvisoryFlags(flags);
      }

      // D.4: sudden severe onset handled IN-SHEET; abnormal bleeding
      // and fever surfaced here as URGENT; bladder pattern and pelvic
      // floor tension surfaced as ADVISORY.
      if (pelvicPainDetail != null) {
        final flags = detectPelvicPainRedFlags(
          detail: pelvicPainDetail,
          severityIndex: sev.value,
          hasFeverToday: _p.getFeverForDay(ts).isNotEmpty,
        );
        await _showPelvicPainUrgentFlags(flags);
        if (!mounted) return;
        await _showPelvicPainAdvisoryFlags(flags);
      }

      // Sprint E.C — MCAS red flag surfacing.
      if (mcasDetail != null) {
        final flags = detectMCASRedFlags(
          detail: mcasDetail,
          severityIndex: sev.value,
        );
        if (flags.isNotEmpty && mounted) {
          await showMCASAdvisoryDialog(
            context,
            flags: flags,
            contrastColor: _cc,
            inverseContrastColor: _ic,
          );
        }
      }
    }

    final unratedSentinel = SymptomSeverity.values.firstWhere(
      (s) => _isUnrated(s),
      orElse: () => SymptomSeverity.values.first,
    );

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
                    symptom.toUpperCase(),
                    style: TextStyle(
                      color: _cc,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  TextField(
                    controller: noteCtrl,
                    style: TextStyle(color: _cc),
                    decoration: InputDecoration(
                      hintText: context.l10n.symptomsLabelOptionalNote,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.symptomsLabelSeverityGrading,
                    style: TextStyle(
                      color: _cc.withValues(alpha: 0.7),
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SeverityDotPicker(
                    showLabels: true,
                    showFunctionalAnchor: true,
                    excludeNone: true,
                    contrastColor: _cc,
                    onSelect: (sev) => saveWith(sev, ctx),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => saveWith(unratedSentinel, ctx),
                      child: Text(
                        context.l10n.symptomsActionLogUnrated,
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
                    context.l10n.symptomsModalEditSymptomHeader(
                      event.name.toUpperCase(),
                    ),
                    style: TextStyle(
                      color: _cc,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  TextField(
                    controller: noteCtrl,
                    style: TextStyle(color: _cc),
                    decoration: InputDecoration(
                      hintText: context.l10n.symptomsLabelOptionalNoteSimple,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.symptomsLabelSeverityGrading,
                    style: TextStyle(
                      color: _cc.withValues(alpha: 0.7),
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SeverityDotPicker(
                    showLabels: true,
                    showFunctionalAnchor: true,
                    excludeNone: true,
                    contrastColor: _cc,
                    selected: _isUnrated(sev) ? null : sev,
                    onSelect: (s) => setSheet(() => sev = s),
                  ),
                  if (_isUnrated(sev))
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        context.l10n.symptomsUnratedInlineWarning,
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
                    onPressed: () async {
                      final note = noteCtrl.text.trim();
                      final idx = _p.symptomHistory.indexOf(event);
                      if (idx < 0) {
                        Navigator.pop(ctx);
                        return;
                      }

                      // C.4 / D.1 / D.2: offer the appropriate detail
                      // layer on edit too. Null result from the sheet
                      // means "preserve existing detail" — explicit
                      // clearing is deferred (would need a clear flag
                      // on copyWith). Aliases for the three symptoms
                      // do not overlap, so at most one branch fires.
                      final svc = SymptomDefinitionsService.instance;
                      final isHeadache = svc.matchesSymptomKey(
                        event.name,
                        'headache',
                      );
                      final headacheLayerEnabled =
                          _p.settings.optionalTrackers['headache_detail'] ??
                          false;
                      final isFatigue = svc.matchesSymptomKey(
                        event.name,
                        'fatigue',
                      );
                      final fatigueLayerEnabled =
                          _p.settings.optionalTrackers['fatigue_detail'] ??
                          false;
                      final isAbdominal = svc.matchesSymptomKey(
                        event.name,
                        'abdominal_pain',
                      );
                      final abdominalLayerEnabled =
                          _p.settings.optionalTrackers['abdominal_detail'] ??
                          false;
                      final isPresyncope = svc.matchesSymptomKey(
                        event.name,
                        'presyncope',
                      );
                      final presyncopeLayerEnabled =
                          _p.settings.optionalTrackers['presyncope_detail'] ??
                          false;
                      final isPelvicPain = svc.matchesSymptomKey(
                        event.name,
                        'pelvic_pain',
                      );
                      final pelvicPainLayerEnabled =
                          _p.settings.optionalTrackers['pelvic_pain_detail'] ??
                          false;

                      HeadacheDetail? headacheDetail = event.headacheDetail;
                      FatigueDetail? fatigueDetail = event.fatigueDetail;
                      AbdominalDetail? abdominalDetail = event.abdominalDetail;
                      PresyncopeDetail? presyncopeDetail =
                          event.presyncopeDetail;
                      PelvicPainDetail? pelvicPainDetail =
                          event.pelvicPainDetail;
                      if (isHeadache && headacheLayerEnabled) {
                        Navigator.pop(ctx);
                        if (!mounted) return;
                        final result = await showHeadacheDetailSheet(
                          context: context,
                          contrastColor: _cc,
                          inverseContrastColor: _ic,
                          existing: event.headacheDetail,
                        );
                        if (!mounted) return;
                        if (result != null) headacheDetail = result;
                      } else if (isFatigue && fatigueLayerEnabled) {
                        Navigator.pop(ctx);
                        if (!mounted) return;
                        final result = await showFatigueDetailSheet(
                          context,
                          contrastColor: _cc,
                          inverseContrastColor: _ic,
                          existing: event.fatigueDetail,
                        );
                        if (!mounted) return;
                        if (result != null) fatigueDetail = result;
                      } else if (isAbdominal && abdominalLayerEnabled) {
                        Navigator.pop(ctx);
                        if (!mounted) return;
                        final result = await showAbdominalDetailSheet(
                          context,
                          symptomInput: event.name,
                          contrastColor: _cc,
                          inverseContrastColor: _ic,
                          existing: event.abdominalDetail,
                        );
                        if (!mounted) return;
                        if (result != null) abdominalDetail = result;
                      } else if (isPresyncope && presyncopeLayerEnabled) {
                        Navigator.pop(ctx);
                        if (!mounted) return;
                        final result = await showPresyncopeDetailSheet(
                          context: context,
                          contrastColor: _cc,
                          inverseContrastColor: _ic,
                          existing: event.presyncopeDetail,
                        );
                        if (!mounted) return;
                        if (result != null) presyncopeDetail = result;
                      } else if (isPelvicPain && pelvicPainLayerEnabled) {
                        Navigator.pop(ctx);
                        if (!mounted) return;
                        final result = await showPelvicPainDetailSheet(
                          context: context,
                          contrastColor: _cc,
                          inverseContrastColor: _ic,
                          existing: event.pelvicPainDetail,
                        );
                        if (!mounted) return;
                        if (result != null) pelvicPainDetail = result;
                      } else {
                        Navigator.pop(ctx);
                      }

                      // D.2.E: reverse integration on edit.
                      if (abdominalDetail != null) {
                        abdominalDetail = await _maybeLinkToBowelEvent(
                          abdominalDetail,
                          ts,
                        );
                        if (!mounted) return;
                      }

                      setState(
                        () => _p.symptomHistory[idx] = event.copyWith(
                          timestamp: ts,
                          severity: sev,
                          note: note.isEmpty ? null : note,
                          headacheDetail: headacheDetail,
                          fatigueDetail: fatigueDetail,
                          abdominalDetail: abdominalDetail,
                          presyncopeDetail: presyncopeDetail,
                          pelvicPainDetail: pelvicPainDetail,
                        ),
                      );
                      widget.onProfileChanged();

                      if (headacheDetail != null) {
                        final flags = detectHeadacheRedFlags(
                          detail: headacheDetail,
                          severityIndex: sev.value,
                        );
                        await _showHeadacheAdvisoryFlags(flags);
                      }
                      if (fatigueDetail != null) {
                        final flags = detectFatigueRedFlags(
                          detail: fatigueDetail,
                          severityIndex: sev.value,
                        );
                        await _showFatigueAdvisoryFlags(flags);
                      }
                      if (abdominalDetail != null) {
                        final flags = detectAbdominalRedFlags(
                          detail: abdominalDetail,
                          severityIndex: sev.value,
                          noteText: note.isEmpty ? null : note,
                        );
                        await _showAbdominalUrgentFlags(flags);
                        if (!mounted) return;
                        await _showAbdominalAdvisoryFlags(flags);
                      }
                      if (presyncopeDetail != null) {
                        final flags = detectPresyncopeRedFlags(
                          detail: presyncopeDetail,
                          severityIndex: sev.value,
                        );
                        await _showPresyncopeAdvisoryFlags(flags);
                      }
                      if (pelvicPainDetail != null) {
                        final flags = detectPelvicPainRedFlags(
                          detail: pelvicPainDetail,
                          severityIndex: sev.value,
                          hasFeverToday: _p.getFeverForDay(ts).isNotEmpty,
                        );
                        await _showPelvicPainUrgentFlags(flags);
                        if (!mounted) return;
                        await _showPelvicPainAdvisoryFlags(flags);
                      }
                    },
                    child: Text(
                      context.l10n.symptomsActionSaveChanges,
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

  // ---------------------------------------------------------------------------
  // C.4 — Headache detail layer: advisory red-flag presentation
  // ---------------------------------------------------------------------------

  /// Shows a dialog summarising advisory red flags after saving a
  /// headache log. URGENT flags (thunderclap) are handled inside the
  /// sheet with their own emergency-confirmation dialog, so this
  /// method silently skips them.
  Future<void> _showHeadacheAdvisoryFlags(List<HeadacheRedFlag> flags) async {
    final advisories = flags
        .where((f) => f.severity == RedFlagSeverity.advisory)
        .toList();
    if (advisories.isEmpty) return;
    if (!mounted) return;
    final l10n = context.l10n;

    final messages = <String>[];
    for (final f in advisories) {
      switch (f) {
        case HeadacheRedFlag.csfLeakPattern:
          messages.add(l10n.headacheRedFlagCsfLeakAdvisory);
          break;
        case HeadacheRedFlag.intracranialHypertension:
          messages.add(l10n.headacheRedFlagIntracranialAdvisory);
          break;
        case HeadacheRedFlag.thunderclap:
          break; // urgent — handled inside the sheet
      }
    }
    if (messages.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _ic,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _cc.withValues(alpha: 0.5), width: 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: _cc, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.headacheAdvisoryDialogTitle,
                style: TextStyle(
                  color: _cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      m,
                      style: TextStyle(color: _cc, fontSize: 13, height: 1.5),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10n.actionUnderstood,
              style: TextStyle(color: _cc, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // D.1 — Fatigue detail layer: advisory red-flag presentation
  // ---------------------------------------------------------------------------

  /// Shows a dialog summarising advisory red flags after saving a
  /// fatigue log. Fatigue has no URGENT flags at this stage, so all
  /// detected patterns surface as advisories only. Mirrors the shape
  /// of _showHeadacheAdvisoryFlags.
  Future<void> _showFatigueAdvisoryFlags(List<FatigueRedFlag> flags) async {
    final advisories = flags
        .where((f) => f.severity == RedFlagSeverity.advisory)
        .toList();
    if (advisories.isEmpty) return;
    if (!mounted) return;
    final l10n = context.l10n;

    final messages = <String>[];
    for (final f in advisories) {
      switch (f) {
        case FatigueRedFlag.pemPattern:
          messages.add(l10n.fatigueRedFlagPemAdvisory);
          break;
        case FatigueRedFlag.orthostaticPattern:
          messages.add(l10n.fatigueRedFlagOrthostaticAdvisory);
          break;
        case FatigueRedFlag.hpaPattern:
          messages.add(l10n.fatigueRedFlagHpaAdvisory);
          break;
      }
    }
    if (messages.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _ic,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _cc.withValues(alpha: 0.5), width: 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: _cc, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.fatigueAdvisoryDialogTitle,
                style: TextStyle(
                  color: _cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      m,
                      style: TextStyle(color: _cc, fontSize: 13, height: 1.5),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10n.actionUnderstood,
              style: TextStyle(color: _cc, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // D.2 — Abdominal detail layer: urgent + advisory red-flag presentation
  // ---------------------------------------------------------------------------

  /// Shows a prominent dialog for URGENT flags detected post-save.
  /// EXPLICITLY SKIPS `tearingPainSedv` because that flag was already
  /// handled IN-SHEET by the abdominal sheet's emergency dialog —
  /// surfacing it again would create alarm fatigue for someone who
  /// just acknowledged the in-sheet warning.
  Future<void> _showAbdominalUrgentFlags(List<AbdominalRedFlag> flags) async {
    final urgents = flags
        .where((f) => f.severity == RedFlagSeverity.urgent)
        .where((f) => f != AbdominalRedFlag.tearingPainSedv)
        .toList();
    if (urgents.isEmpty) return;
    if (!mounted) return;
    final l10n = context.l10n;

    final messages = <String>[];
    for (final f in urgents) {
      switch (f) {
        case AbdominalRedFlag.massiveHematochezia:
          messages.add(l10n.abdominalRedFlagMassiveHematocheziaUrgent);
          break;
        case AbdominalRedFlag.hematemesis:
          messages.add(l10n.abdominalRedFlagHematemesisUrgent);
          break;
        case AbdominalRedFlag.tearingPainSedv:
        case AbdominalRedFlag.nocturnalPainAdvisory:
        case AbdominalRedFlag.gastroparesisPatternAdvisory:
          break;
      }
    }
    if (messages.isEmpty) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _ic,
        shape: RoundedRectangleBorder(side: BorderSide(color: _cc, width: 2)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _cc, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.abdominalAdvisoryDialogTitle,
                style: TextStyle(
                  color: _cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      m,
                      style: TextStyle(color: _cc, fontSize: 13, height: 1.5),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10n.actionUnderstood,
              style: TextStyle(color: _cc, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog summarising ADVISORY flags for the abdominal
  /// detail layer. URGENT flags are handled by
  /// _showAbdominalUrgentFlags (and tearingPainSedv by the sheet).
  Future<void> _showAbdominalAdvisoryFlags(List<AbdominalRedFlag> flags) async {
    final advisories = flags
        .where((f) => f.severity == RedFlagSeverity.advisory)
        .toList();
    if (advisories.isEmpty) return;
    if (!mounted) return;
    final l10n = context.l10n;

    final messages = <String>[];
    for (final f in advisories) {
      switch (f) {
        case AbdominalRedFlag.nocturnalPainAdvisory:
          messages.add(l10n.abdominalRedFlagNocturnalPainAdvisory);
          break;
        case AbdominalRedFlag.gastroparesisPatternAdvisory:
          messages.add(l10n.abdominalRedFlagGastroparesisAdvisory);
          break;
        case AbdominalRedFlag.tearingPainSedv:
        case AbdominalRedFlag.massiveHematochezia:
        case AbdominalRedFlag.hematemesis:
          break;
      }
    }
    if (messages.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _ic,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _cc.withValues(alpha: 0.5), width: 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: _cc, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.abdominalAdvisoryDialogTitle,
                style: TextStyle(
                  color: _cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      m,
                      style: TextStyle(color: _cc, fontSize: 13, height: 1.5),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10n.actionUnderstood,
              style: TextStyle(color: _cc, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // D.3 — Presyncope detail layer: advisory red-flag presentation
  // ---------------------------------------------------------------------------

  /// Shows a dialog summarising ADVISORY flags for the presyncope
  /// detail layer. `briefLossOfConsciousness` (URGENT) is handled
  /// IN-SHEET by the presyncope sheet's emergency dialog — it never
  /// reaches detectPresyncopeRedFlags callers post-save, so there is
  /// no separate urgent-flags method here (mirrors fatigue, which also
  /// has no URGENT tier).
  Future<void> _showPresyncopeAdvisoryFlags(
    List<PresyncopeRedFlag> flags,
  ) async {
    final advisories = flags
        .where((f) => f.severity == RedFlagSeverity.advisory)
        .toList();
    if (advisories.isEmpty) return;
    if (!mounted) return;
    final l10n = context.l10n;

    final messages = <String>[];
    for (final f in advisories) {
      switch (f) {
        case PresyncopeRedFlag.exertionalTrigger:
          messages.add(l10n.presyncopeRedFlagExertionalTriggerAdvisory);
          break;
        case PresyncopeRedFlag.noPositionChangeTrigger:
          messages.add(l10n.presyncopeRedFlagNoPositionChangeTriggerAdvisory);
          break;
        case PresyncopeRedFlag.briefLossOfConsciousness:
          break;
      }
    }
    if (messages.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _ic,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _cc.withValues(alpha: 0.5), width: 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: _cc, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.presyncopeAdvisoryDialogTitle,
                style: TextStyle(
                  color: _cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      m,
                      style: TextStyle(color: _cc, fontSize: 13, height: 1.5),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10n.actionUnderstood,
              style: TextStyle(color: _cc, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // D.4 — Pelvic pain detail layer: urgent + advisory red-flag presentation
  // ---------------------------------------------------------------------------

  /// Shows a prominent dialog for URGENT flags detected post-save.
  /// EXPLICITLY SKIPS `suddenSevereOnset` because that flag was already
  /// handled IN-SHEET by the pelvic pain sheet's emergency dialog —
  /// surfacing it again would create alarm fatigue for someone who
  /// just acknowledged the in-sheet warning. Mirrors
  /// _showAbdominalUrgentFlags.
  Future<void> _showPelvicPainUrgentFlags(List<PelvicPainRedFlag> flags) async {
    final urgents = flags
        .where((f) => f.severity == RedFlagSeverity.urgent)
        .where((f) => f != PelvicPainRedFlag.suddenSevereOnset)
        .toList();
    if (urgents.isEmpty) return;
    if (!mounted) return;
    final l10n = context.l10n;

    final messages = <String>[];
    for (final f in urgents) {
      switch (f) {
        case PelvicPainRedFlag.abnormalBleedingUrgent:
          messages.add(l10n.pelvicPainRedFlagAbnormalBleedingUrgent);
          break;
        case PelvicPainRedFlag.feverUrgent:
          messages.add(l10n.pelvicPainRedFlagFeverUrgent);
          break;
        case PelvicPainRedFlag.suddenSevereOnset:
        case PelvicPainRedFlag.bladderPatternAdvisory:
        case PelvicPainRedFlag.pelvicFloorTensionAdvisory:
          break;
      }
    }
    if (messages.isEmpty) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _ic,
        shape: RoundedRectangleBorder(side: BorderSide(color: _cc, width: 2)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _cc, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.pelvicPainUrgentDialogTitle,
                style: TextStyle(
                  color: _cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      m,
                      style: TextStyle(color: _cc, fontSize: 13, height: 1.5),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10n.actionUnderstood,
              style: TextStyle(color: _cc, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog summarising ADVISORY flags for the pelvic pain
  /// detail layer. URGENT flags are handled by
  /// _showPelvicPainUrgentFlags (and suddenSevereOnset by the sheet).
  Future<void> _showPelvicPainAdvisoryFlags(
    List<PelvicPainRedFlag> flags,
  ) async {
    final advisories = flags
        .where((f) => f.severity == RedFlagSeverity.advisory)
        .toList();
    if (advisories.isEmpty) return;
    if (!mounted) return;
    final l10n = context.l10n;

    final messages = <String>[];
    for (final f in advisories) {
      switch (f) {
        case PelvicPainRedFlag.bladderPatternAdvisory:
          messages.add(l10n.pelvicPainRedFlagBladderPatternAdvisory);
          break;
        case PelvicPainRedFlag.pelvicFloorTensionAdvisory:
          messages.add(l10n.pelvicPainRedFlagPelvicFloorTensionAdvisory);
          break;
        case PelvicPainRedFlag.suddenSevereOnset:
        case PelvicPainRedFlag.abnormalBleedingUrgent:
        case PelvicPainRedFlag.feverUrgent:
          break;
      }
    }
    if (messages.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _ic,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _cc.withValues(alpha: 0.5), width: 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: _cc, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.pelvicPainAdvisoryDialogTitle,
                style: TextStyle(
                  color: _cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      m,
                      style: TextStyle(color: _cc, fontSize: 13, height: 1.5),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10n.actionUnderstood,
              style: TextStyle(color: _cc, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // D.2.E — Bidirectional integration BowelEvent <-> AbdominalDetail
  // ---------------------------------------------------------------------------

  Future<void> _promptBowelToAbdominal(BowelEvent bowelEvent) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: _ic,
        title: Text(
          l10n.bowelToAbdominalPromptTitle,
          style: TextStyle(
            color: _cc,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.bowelToAbdominalPromptBody,
          style: TextStyle(color: _cc, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            style: TextButton.styleFrom(foregroundColor: _cc),
            child: Text(l10n.abdominalIntegrationNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dctx, true),
            style: TextButton.styleFrom(foregroundColor: _cc),
            child: Text(
              l10n.abdominalIntegrationYes,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (proceed != true || !mounted) return;

    final canonicalName =
        SymptomDefinitionsService.instance
            .getMasterLabel('abdominal_pain', l10n.localeName)
            ?.toLowerCase() ??
        'dolor abdominal';
    final detail = await showAbdominalDetailSheet(
      context,
      symptomInput: canonicalName,
      contrastColor: _cc,
      inverseContrastColor: _ic,
    );
    if (!mounted || detail == null || detail.isEmpty) return;

    final linkedDetail = detail.copyWith(linkedBowelEventId: bowelEvent.id);
    final defaultSeverity = SymptomSeverity.fromValue(2);
    setState(
      () => _p.symptomHistory.add(
        SymptomEvent(
          timestamp: bowelEvent.timestamp,
          name: canonicalName,
          severity: defaultSeverity,
          abdominalDetail: linkedDetail,
        ),
      ),
    );
    widget.onProfileChanged();

    final flags = detectAbdominalRedFlags(
      detail: linkedDetail,
      severityIndex: defaultSeverity.value,
      noteText: null,
    );
    await _showAbdominalUrgentFlags(flags);
    if (!mounted) return;
    await _showAbdominalAdvisoryFlags(flags);
  }

  Future<AbdominalDetail> _maybeLinkToBowelEvent(
    AbdominalDetail detail,
    DateTime eventTime,
  ) async {
    if (detail.timing != AbdominalTiming.bowelRelated) return detail;
    if (detail.linkedBowelEventId != null) return detail;
    if (!mounted) return detail;

    final windowStart = eventTime.subtract(const Duration(hours: 1));
    final windowEnd = eventTime.add(const Duration(hours: 1));
    BowelEvent? candidate;
    Duration? minDelta;
    for (final b in _p.bowelHistory) {
      if (b.timestamp.isAfter(windowStart) && b.timestamp.isBefore(windowEnd)) {
        final delta = b.timestamp.difference(eventTime).abs();
        if (candidate == null || delta < minDelta!) {
          candidate = b;
          minDelta = delta;
        }
      }
    }
    if (candidate == null || !mounted) return detail;

    final l10n = context.l10n;
    final formattedTime = TimeOfDay.fromDateTime(
      candidate.timestamp,
    ).format(context);
    final proceed = await showDialog<bool?>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: _ic,
        title: Text(
          l10n.abdominalToBowelPromptTitle,
          style: TextStyle(
            color: _cc,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.abdominalToBowelPromptBody(formattedTime),
          style: TextStyle(color: _cc, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, null),
            style: TextButton.styleFrom(foregroundColor: _cc),
            child: Text(l10n.abdominalIntegrationDontKnow),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            style: TextButton.styleFrom(foregroundColor: _cc),
            child: Text(l10n.abdominalIntegrationNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dctx, true),
            style: TextButton.styleFrom(foregroundColor: _cc),
            child: Text(
              l10n.abdominalIntegrationYes,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (proceed == true) {
      return detail.copyWith(linkedBowelEventId: candidate.id);
    }
    return detail;
  }

  // ---------------------------------------------------------------------------
  // PHASE 5.1 — Bowel & hemorrhoidal handlers
  // ---------------------------------------------------------------------------

  // i18n Batch A.3: helper now takes the BowelBucket itself and resolves
  // its display label via BowelBucketLocalization. No more literal Spanish
  // 'estreñimiento'/'normal'/'diarrea' strings flowing in from the caller.
  Widget _bucketCard(BowelBucket bucket, IconData icon, AppLocalizations l10n) {
    return Expanded(
      child: InkWell(
        onTap: () => _openBowelForm(prefilledBucket: bucket),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: _cc.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: _cc, size: 32),
              const SizedBox(height: 6),
              Text(
                bucket.bowelBucketLabel(l10n),
                textAlign: TextAlign.center,
                style: TextStyle(color: _cc, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBowelForm({BowelBucket? prefilledBucket}) async {
    final result = await showBowelFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: _timestampForLog(),
      prefilledBucket: prefilledBucket,
    );
    if (result == null) return;
    setState(() => _p.bowelHistory.add(result));
    widget.onProfileChanged();

    // Sprint F.B+C — post-save action capture prompt (bowel)
    if (!mounted) return;
    // Sprint F.E2 — bowel: skip when bucket == normal.
    // Routine tracking of normal transit shouldn't prompt.
    if ((_p.settings.optionalTrackers['action_taken'] ?? true) &&
        result.bucket != BowelBucket.normal) {
      final actionBowel = await ActionTakenSheet.show(
        context: context,
        contrastColor: _cc,
        inverseContrastColor: _ic,
        linkedEventId: result.timestamp.toIso8601String(),
        linkedEventType: LinkedEventType.bowel,
        botiquin: _p.botiquin,
      );
      if (!mounted) return;
      if (actionBowel != null && !actionBowel.isEmpty) {
        setState(() => _p.actionsHistory.add(actionBowel));
        widget.onProfileChanged();
      }
    }

    // D.2.E: forward integration.
    if (_p.settings.optionalTrackers['abdominal_detail'] ?? false) {
      await _promptBowelToAbdominal(result);
      if (!mounted) return;
    }
  }

  Future<void> _editBowelEvent(BowelEvent event) async {
    final result = await showBowelFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: event.timestamp,
      existing: event,
    );
    if (result == null) return;
    final idx = _p.bowelHistory.indexOf(event);
    if (idx >= 0) {
      setState(() => _p.bowelHistory[idx] = result);
      widget.onProfileChanged();
    }
  }

  Future<void> _openHemorrhoidalForm() async {
    final result = await showHemorrhoidalFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: _timestampForLog(),
    );
    if (result == null) return;
    setState(() => _p.hemorrhoidalHistory.add(result));
    widget.onProfileChanged();

    // Sprint F.B+C — post-save action capture prompt (hemorrhoidal)
    if (!mounted) return;
    if (_p.settings.optionalTrackers['action_taken'] ?? true) {
      final actionHem = await ActionTakenSheet.show(
        context: context,
        contrastColor: _cc,
        inverseContrastColor: _ic,
        linkedEventId: result.timestamp.toIso8601String(),
        linkedEventType: LinkedEventType.hemorrhoidal,
        botiquin: _p.botiquin,
      );
      if (!mounted) return;
      if (actionHem != null && !actionHem.isEmpty) {
        setState(() => _p.actionsHistory.add(actionHem));
        widget.onProfileChanged();
      }
    }
  }

  Future<void> _editHemorrhoidalEvent(HemorrhoidalEvent event) async {
    final result = await showHemorrhoidalFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: event.timestamp,
      existing: event,
    );
    if (result == null) return;
    final idx = _p.hemorrhoidalHistory.indexOf(event);
    if (idx >= 0) {
      setState(() => _p.hemorrhoidalHistory[idx] = result);
      widget.onProfileChanged();
    }
  }

  // ---------------------------------------------------------------------------
  // PHASE 5.2d.2 — Fever handlers
  // ---------------------------------------------------------------------------

  Future<void> _openFeverForm() async {
    final result = await showFeverFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: _timestampForLog(),
    );
    if (result == null) return;
    setState(() => _p.feverHistory.add(result));
    widget.onProfileChanged();

    // Sprint F.B+C — post-save action capture prompt (fever)
    if (!mounted) return;
    if (_p.settings.optionalTrackers['action_taken'] ?? true) {
      final actionFever = await ActionTakenSheet.show(
        context: context,
        contrastColor: _cc,
        inverseContrastColor: _ic,
        linkedEventId: result.timestamp.toIso8601String(),
        linkedEventType: LinkedEventType.fever,
        botiquin: _p.botiquin,
      );
      if (!mounted) return;
      if (actionFever != null && !actionFever.isEmpty) {
        setState(() => _p.actionsHistory.add(actionFever));
        widget.onProfileChanged();
      }
    }
  }

  Future<void> _editFeverEvent(FeverReading event) async {
    final result = await showFeverFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: event.timestamp,
      existing: event,
    );
    if (result == null) return;
    final idx = _p.feverHistory.indexOf(event);
    if (idx >= 0) {
      setState(() => _p.feverHistory[idx] = result);
      widget.onProfileChanged();
    }
  }

  // ---------------------------------------------------------------------------
  // SLEEP — optional module handlers (F6.a + Sleep)
  // ---------------------------------------------------------------------------

  /// Compact display for a sleep entry in the TODAY block.
  /// Shape: "[HH:mm] dormí <quality> · <Xh> · <N>× despertares · pesadilla"
  /// Optional details only appear when present.
  String _formatSleepEntry(SleepEntry e, AppLocalizations l10n) {
    final time =
        '[${e.timestamp.hour.toString().padLeft(2, "0")}:'
        '${e.timestamp.minute.toString().padLeft(2, "0")}]';
    final parts = <String>[
      '$time ${l10n.sleepLogLabelSlept} ${e.quality.label(l10n)}',
    ];
    if (e.durationMinutes != null) {
      final hours = (e.durationMinutes! / 60).toStringAsFixed(1);
      parts.add(l10n.sleepLogLabelHours(hours));
    }
    if (e.onsetLatencyMinutes != null && e.onsetLatencyMinutes! > 0) {
      parts.add(l10n.sleepLogLabelOnsetLatency(e.onsetLatencyMinutes!));
    }
    if (e.wakeCount != null && e.wakeCount! > 0) {
      parts.add(l10n.sleepLogLabelWakes(e.wakeCount!));
    }
    if (e.nightmare == true) {
      parts.add(l10n.sleepLogLabelWithNightmare);
    }
    return parts.join(' · ');
  }

  Future<void> _openSleepForm() async {
    // Default to the morning of the selected date (waking time convention).
    final defaultTs = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      7,
      30,
    );
    final result = await showSleepFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: defaultTs,
    );
    if (result == null) return;
    setState(() => _p.sleepHistory.add(result));
    widget.onProfileChanged();
  }

  Future<void> _editSleepEvent(SleepEntry event) async {
    final result = await showSleepFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: event.timestamp,
      existing: event,
    );
    if (result == null) return;
    final idx = _p.sleepHistory.indexOf(event);
    if (idx >= 0) {
      setState(() => _p.sleepHistory[idx] = result);
      widget.onProfileChanged();
    }
  }

  // ---------------------------------------------------------------------------
  // F6.b — Hydration handlers
  // ---------------------------------------------------------------------------

  /// Compact display for a hydration entry. Shape:
  ///   "[HH:mm] 250 ml · agua · pizca de sal"
  String _formatHydrationEntry(HydrationEntry e, AppLocalizations l10n) {
    final time =
        '[${e.timestamp.hour.toString().padLeft(2, "0")}:'
        '${e.timestamp.minute.toString().padLeft(2, "0")}]';
    final parts = <String>[time];
    if (e.volumeMl != null) {
      parts.add(l10n.hydrationLogLabelVolume(e.volumeMl!.round().toString()));
    }
    if (e.beverage != null) {
      parts.add(e.beverage!.label(l10n));
    }
    if (e.sodium != null) {
      parts.add(e.sodium!.label(l10n));
    }
    return parts.join(' · ');
  }

  Future<void> _openHydrationForm() async {
    final result = await showHydrationFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: _timestampForLog(),
    );
    if (result == null) return;
    setState(() => _p.hydrationHistory.add(result));
    widget.onProfileChanged();
  }

  Future<void> _editHydrationEvent(HydrationEntry event) async {
    final result = await showHydrationFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: event.timestamp,
      existing: event,
    );
    if (result == null) return;
    final idx = _p.hydrationHistory.indexOf(event);
    if (idx >= 0) {
      setState(() => _p.hydrationHistory[idx] = result);
      widget.onProfileChanged();
    }
  }

  // ---------------------------------------------------------------------------
  // F6.b — HRV handlers
  // ---------------------------------------------------------------------------

  /// Compact display for an HRV reading. Shape:
  ///   "[HH:mm] 35 ms · matinal · Apple Watch"
  String _formatHrvEntry(HrvReading e, AppLocalizations l10n) {
    final time =
        '[${e.timestamp.hour.toString().padLeft(2, "0")}:'
        '${e.timestamp.minute.toString().padLeft(2, "0")}]';
    return '$time · '
        '${l10n.hrvLogLabelRmssd(e.rmssdMs.round().toString())} · '
        '${e.context.label(l10n)} · '
        '${e.source.hrvSourceLabel(l10n)}';
  }

  Future<void> _openHrvForm() async {
    final result = await showHrvFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: _timestampForLog(),
    );
    if (result == null) return;
    setState(() => _p.hrvHistory.add(result));
    widget.onProfileChanged();
  }

  Future<void> _editHrvEvent(HrvReading event) async {
    final result = await showHrvFormSheet(
      context: context,
      contrastColor: _cc,
      inverseContrastColor: _ic,
      defaultTimestamp: event.timestamp,
      existing: event,
    );
    if (result == null) return;
    final idx = _p.hrvHistory.indexOf(event);
    if (idx >= 0) {
      setState(() => _p.hrvHistory[idx] = result);
      widget.onProfileChanged();
    }
  }
}
