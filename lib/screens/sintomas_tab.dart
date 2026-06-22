import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'timestamp_picker.dart';
import '../widgets/bowel_form_sheet.dart';
import '../widgets/hemorrhoidal_form_sheet.dart';
import '../widgets/fever_form_sheet.dart';
import '../widgets/sleep_form_sheet.dart';
import '../widgets/hydration_form_sheet.dart';
import '../widgets/hrv_form_sheet.dart';
import '../services/structural_taxonomy.dart';
import '../widgets/collapsible_section.dart';
import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';


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

  /// Row of colored severity dots. Single-source dot picker for both
  /// log + edit flows.
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
    final todaysBowel = _p.getBowelForDay(widget.selectedDate);
    final todaysHemorrhoidal = _p.getHemorrhoidalForDay(widget.selectedDate);
    final todaysFever = _p.getFeverForDay(widget.selectedDate);
    final todaysSleep = _p.getSleepForDay(widget.selectedDate);
    final todaysHydration = _p.getHydrationForDay(widget.selectedDate);
    final todaysHrv = _p.getHrvForDay(widget.selectedDate);
    final isSleepEnabled = _p.optionalTrackers['sleep'] ?? false;
    final isHydrationEnabled = _p.optionalTrackers['hydration'] ?? false;
    final isHrvEnabled = _p.optionalTrackers['hrv'] ?? false;
    final isCarefulMode = _p.optionalTrackers['careful_mode'] ?? false;
    final trending = _p.getTrendingSymptoms(); 
    final l10n = context.l10n;

    // F3: precompute each section's initial expanded state + hint label.
    // ValueKey on each CollapsibleSection includes isCarefulMode so toggling
    // it from settings forces a rebuild that re-applies initiallyExpanded.
    final structState = _sectionState(
        _p.structuralHistory.map((e) => e.timestamp), l10n, isCarefulMode);
    final bowelState = _sectionState(
        _p.bowelHistory.map((e) => e.timestamp).followedBy(
            _p.hemorrhoidalHistory.map((e) => e.timestamp)),
        l10n,
        isCarefulMode);
    final feverState = _sectionState(
        _p.feverHistory.map((e) => e.timestamp), l10n, isCarefulMode);
    final sleepState = _sectionState(
        _p.sleepHistory.map((e) => e.timestamp), l10n, isCarefulMode);
    final hydrationState = _sectionState(
        _p.hydrationHistory.map((e) => e.timestamp), l10n, isCarefulMode);
    final hrvState = _sectionState(
        _p.hrvHistory.map((e) => e.timestamp), l10n, isCarefulMode);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: BodyRegion.values.map((region) {
              final zones = kBodyRegionZones[region]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        region.label(l10n).toUpperCase(),
                        style: TextStyle(
                          color: _cc.withValues(alpha: 0.55),
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: zones
                          .map((zone) => ActionChip(
                                backgroundColor: Colors.transparent,
                                side: BorderSide(color: _cc.withValues(alpha: 0.6)),
                                label: Text(zone.bodyZoneLabel(l10n),
                                    style: TextStyle(color: _cc, fontSize: 11)),
                                onPressed: () => _openStructuralMenu(zone),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
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
                  _bucketCard(BowelBucket.constipation, Icons.remove_circle_outline, 'estreñimiento'),
                  _bucketCard(BowelBucket.normal, Icons.circle_outlined, 'normal'),
                  _bucketCard(BowelBucket.diarrhea, Icons.waves, 'diarrea'),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(side: BorderSide(color: _cc.withValues(alpha: 0.4))),
                  icon: Icon(Icons.add, color: _cc, size: 16),
                  label: Text(l10n.symptomsActionAddHemorrhoid, style: TextStyle(color: _cc, fontSize: 12)),
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
              style: OutlinedButton.styleFrom(side: BorderSide(color: _cc.withValues(alpha: 0.5))),
              icon: Icon(Icons.thermostat, color: _cc, size: 18),
              label: Text(l10n.feverActionAddReading,
                  style: TextStyle(color: _cc, fontSize: 12, fontWeight: FontWeight.bold)),
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
                    side: BorderSide(color: _cc.withValues(alpha: 0.5))),
                icon: Icon(Icons.bedtime_outlined, color: _cc, size: 18),
                label: Text(l10n.sleepActionAddEntry,
                    style: TextStyle(
                        color: _cc,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
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
                    side: BorderSide(color: _cc.withValues(alpha: 0.5))),
                icon: Icon(Icons.local_drink_outlined, color: _cc, size: 18),
                label: Text(l10n.hydrationActionAddEntry,
                    style: TextStyle(
                        color: _cc,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
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
                    side: BorderSide(color: _cc.withValues(alpha: 0.5))),
                icon: Icon(Icons.favorite_border, color: _cc, size: 18),
                label: Text(l10n.hrvActionAddEntry,
                    style: TextStyle(
                        color: _cc,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
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
          Text(l10n.symptomsSectionTodaysLogs,
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
                                "[${DateFormat('HH:mm').format(e.timestamp)}] "
                                "${e.zone.bodyZoneLabel(l10n)}: "
                                "${e.type.structuralTypeLabel(l10n)}"
                                "${e.isResolved ? ' ✓' : ''}",
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
                ...todaysBowel.map((e) => InkWell(
                      onLongPress: () => _editBowelEvent(e),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              switch (e.bucket) {
                                BowelBucket.constipation => Icons.remove_circle_outline,
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
                                    "[${DateFormat('HH:mm').format(e.timestamp)}] ${e.bucket.label}"
                                    "${e.bristolType != null ? ' · tipo ${e.bristolType}' : ''}"
                                    "${e.urgency ? ' · urgencia' : ''}"
                                    "${e.bloodPresent ? ' · sangrado' : ''}"
                                    "${e.incompleteEvacuation ? ' · incompleta' : ''}",
                                    style: TextStyle(color: _cc, fontSize: 13),
                                  ),
                                  if (e.note != null && e.note!.trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(e.note!,
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
                                setState(() => _p.bowelHistory.remove(e));
                                widget.onProfileChanged();
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
                ...todaysHemorrhoidal.map((e) => InkWell(
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
                                    "[${DateFormat('HH:mm').format(e.timestamp)}] hemorroide"
                                    "${e.bleeding ? ' · sangrado' : ''}"
                                    "${e.severity != SymptomSeverity.none ? ' (${e.severity.label.toLowerCase()})' : ''}",
                                    style: TextStyle(color: _cc, fontSize: 13),
                                  ),
                                  if (e.note != null && e.note!.trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(e.note!,
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
                                setState(() => _p.hemorrhoidalHistory.remove(e));
                                widget.onProfileChanged();
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
                ...todaysFever.map((e) => InkWell(
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
                                      child: Text(e.note!,
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
                                setState(() => _p.feverHistory.remove(e));
                                widget.onProfileChanged();
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
                ...todaysSleep.map((e) => InkWell(
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
                                      child: Text(e.note!,
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
                                setState(() => _p.sleepHistory.remove(e));
                                widget.onProfileChanged();
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
                ...todaysHydration.map((e) => InkWell(
                      onLongPress: () => _editHydrationEvent(e),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.local_drink_outlined, color: _cc, size: 14),
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
                                      child: Text(e.note!,
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
                                setState(() => _p.hydrationHistory.remove(e));
                                widget.onProfileChanged();
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
                ...todaysHrv.map((e) => InkWell(
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
                                      child: Text(e.note!,
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
                                setState(() => _p.hrvHistory.remove(e));
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
          Text(l10n.symptomsFootnoteLongPressEdit,
              style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
        ],

        // 3. TRENDING
        const SizedBox(height: 28),
        Text(l10n.symptomsSectionTrending,
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14, color: _cc)),
        const SizedBox(height: 8),
        if (trending.isEmpty)
          Text(l10n.symptomsTrendingEmpty,
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
        Text(l10n.symptomsSectionVault,
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
  // STRUCTURAL MODALS
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
                  Text(
                      context.l10n.symptomsModalLogHeader(
                          zone.bodyZoneLabel(context.l10n).toUpperCase()),
                      style: TextStyle(
                          color: _cc, fontSize: 16, fontWeight: FontWeight.bold)),
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
                  ...kStructuralTaxonomy.entries.expand((entry) => [
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
                        ...entry.value.map((type) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Icon(_iconForKind(entry.key), color: _cc, size: 18),
                              title: Text(type.structuralTypeLabel(context.l10n),
                                  style: TextStyle(color: _cc, fontSize: 13)),
                              onTap: () {
                                setState(() => _p.structuralHistory.add(StructuralEvent(
                                      timestamp: ts,
                                      zone: zone,
                                      kind: entry.key,
                                      type: type,
                                    )));
                                widget.onProfileChanged();
                                Navigator.pop(ctx);
                              },
                            )),
                      ]),
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                          event.type.structuralTypeLabel(context.l10n)),
                      style: TextStyle(
                          color: _cc, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(event.kind.label(context.l10n),
                      style: TextStyle(color: _cc.withValues(alpha: 0.55), fontSize: 11, letterSpacing: 0.5)),
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
                  const SizedBox(height: 20),

                  // Healing tracking section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: _cc.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 2),
                          child: Text('SEGUIMIENTO',
                              style: TextStyle(
                                color: _cc.withValues(alpha: 0.55),
                                fontSize: 10,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text('¿Está resuelto?', style: TextStyle(color: _cc, fontSize: 13)),
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
                              'Resuelto el ${DateFormat('d MMM yyyy').format(resolvedAt!)}',
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
                            title: Text('¿Todavía duele?', style: TextStyle(color: _cc, fontSize: 13)),
                            subtitle: Text(
                              'Cerró visiblemente pero el dolor sigue',
                              style: TextStyle(color: _cc.withValues(alpha: 0.5), fontSize: 11),
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
                        setState(() => _p.structuralHistory[idx] = event.copyWith(
                              timestamp: ts,
                              resolvedAt: resolvedAt,
                              clearResolvedAt: resolvedAt == null,
                              stillPainful: stillPainful,
                            ));
                        widget.onProfileChanged();
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(context.l10n.symptomsActionSave, style: TextStyle(color: _ic, fontWeight: FontWeight.bold)),
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
      };

  // ---------------------------------------------------------------------------
  // SYMPTOM MODALS
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
                    decoration: InputDecoration(
                      hintText: context.l10n.symptomsLabelOptionalNote,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(context.l10n.symptomsLabelSeverityGrading,
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.symptomsModalEditSymptomHeader(event.name.toUpperCase()),
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
                    decoration: InputDecoration(
                        hintText: context.l10n.symptomsLabelOptionalNoteSimple, hintStyle: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),
                  Text(context.l10n.symptomsLabelSeverityGrading,
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
                    child: Text(context.l10n.symptomsActionSaveChanges, style: TextStyle(color: _ic, fontWeight: FontWeight.bold)),
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
  // PHASE 5.1 — Bowel & hemorrhoidal handlers
  // ---------------------------------------------------------------------------

  Widget _bucketCard(BowelBucket bucket, IconData icon, String label) {
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
                label,
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
    final time = '[${e.timestamp.hour.toString().padLeft(2, "0")}:'
        '${e.timestamp.minute.toString().padLeft(2, "0")}]';
    final parts = <String>['$time ${l10n.sleepLogLabelSlept} ${e.quality.label(l10n)}'];
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
    final defaultTs = DateTime(widget.selectedDate.year,
        widget.selectedDate.month, widget.selectedDate.day, 7, 30);
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
    final time = '[${e.timestamp.hour.toString().padLeft(2, "0")}:'
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
    final time = '[${e.timestamp.hour.toString().padLeft(2, "0")}:'
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