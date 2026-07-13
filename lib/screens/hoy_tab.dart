// =============================================================================
// Hoy tab — aggressive redesign for zebra patients.
//
// Layout priorities (research-backed):
//   1. URGENCY: pending outcome check-ins surface first (Starkoff: action items
//      before ambient content for low-cognitive-load populations).
//   2. ANCHOR: one big "how do you feel right now" segmented slider — Wave's
//      primary-feeling pattern, condensed to a single decision instead of
//      three competing sliders.
//   3. PROGRESSIVE DISCLOSURE: mental detail (anxiety, energy, brain fog) is
//      collapsible. The 80% case is one tap.
//   4. NARRATIVE SUMMARY: sentence-form recap instead of the old count grid
//      (Alzate: emotional benefit > functional benefit as a retention driver).
//   5. WISDOM RETREATS: demoted to bottom, smaller, ambient. Narejo: 1×/day,
//      not blocking the entry.
//
// Outcome check-ins use the new SeverityDotPicker with `anchor` showing the
// severity at dose-time and `selected` capturing the after-state.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../extensions/context_ext.dart';
import '../models/models.dart';
import '../widgets/severity_picker.dart';
import '../widgets/mood_picker_sheet.dart';
import '../l10n/app_localizations.dart';
import '../services/clinical_localizations.dart';
import '../services/fever_analysis.dart';
import '../services/structural_taxonomy.dart';
import '../services/headache_detail_format.dart';
import '../services/fatigue_detail_format.dart';
import '../services/abdominal_detail_format.dart';
import '../services/flare_detection_service.dart';
import '../models/action_taken.dart';
import '../widgets/follow_up_banner.dart';
import '../widgets/action_effectiveness_dialog.dart';
import '../widgets/retro_symptom_banner.dart';
import '../widgets/retro_symptom_dialog.dart';
import '../widgets/weekly_narrative.dart';
import '../widgets/flare_control.dart';
import '../models/profile_state.dart';
import '../widgets/flare_suggestion_banner.dart';
import '../widgets/feedback_prompt_banner.dart';

// B.2: Date is now formatted via DateFormat using a locale-driven
// pattern from the ARB (`hoyHeaderDatePattern`). main.dart must call
// `initializeDateFormatting()` at startup for each supported locale —
// without that init, DateFormat in non-default locales throws.

class HoyTab extends StatelessWidget {
  final Profile profile;
  final DateTime selectedDate;
  final WisdomQuote wisdom;
  final WeatherDay? todayWeather;
  final Color contrastColor;
  final Color inverseContrastColor;

  // NUEVO: Recibimos el diccionario EMA JSON desde MainAppScreen
  final Map<MoodQuadrant, List<EmaMood>> moodDictionary;

  final VoidCallback onTogglePacing;
  final void Function(MentalState state, int severity, {DateTime? timestamp})
  onLogMental;

  // ACTUALIZADO: Cambiamos intensity por notes
  final void Function({
    required MoodQuadrant primaryQuadrant,
    required List<String> states,
    String? notes,
  })
  onLogMood;

  final void Function(MoodEntry) onDeleteMood;
  final void Function(
    MedicationOutcome outcome, {
    required int severityAfter,
    OutcomeReason? reason,
  })
  onAnswerOutcome;
  final VoidCallback onChangeWisdom;

  final bool showHint;
  final VoidCallback onDismissHint;
  // PHASE 5.2a — navigate to another tab (banner shortcut uses this).
  final ValueChanged<int> onNavigate;

  // Sprint F.D — invoked when a follow-up effectiveness capture
  // is saved. Parent replaces the matching entry in
  // Profile.actionsHistory and persists.
  final void Function(ActionTaken updated) onCompleteFollowUp;

  // Sprint F.E — invoked when the retro symptom dialog saves a
  // fresh ActionTaken (kind picked, severityAfter captured,
  // rating inferred). Parent appends to Profile.actionsHistory.
  final void Function(ActionTaken action) onSaveRetroSymptom;

  // Sprint G.B — flare mode change callback.
  final VoidCallback onFlareChange;

  const HoyTab({
    super.key,
    required this.profile,
    required this.selectedDate,
    required this.wisdom,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.moodDictionary, // Inyectado
    required this.onTogglePacing,
    required this.onLogMental,
    required this.onLogMood,
    required this.onDeleteMood,
    required this.onAnswerOutcome,
    required this.onChangeWisdom,
    required this.showHint,
    required this.onDismissHint,
    required this.onNavigate,
    required this.onCompleteFollowUp,
    required this.onSaveRetroSymptom,
    required this.onFlareChange,
    this.todayWeather,
  });

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  bool _isToday() {
    final n = DateTime.now();
    return n.year == selectedDate.year &&
        n.month == selectedDate.month &&
        n.day == selectedDate.day;
  }

  // Sprint F.E — pending retro symptoms: age in (30 min, 24 h)
  // AND no matching ActionTaken with linkedEventType == symptom.
  List<SymptomEvent> _pendingRetroSymptoms(Profile p) {
    // Sprint F.F — respect the settings opt-out toggle.
    // When off, the retro banner disappears entirely. Existing
    // ActionTakens with pending follow-ups are unaffected — they
    // live in FollowUpBanner which doesn't gate on this flag.
    if (!(p.settings.optionalTrackers['action_taken'] ?? true)) return const [];
    final now = DateTime.now();
    final windowStart = now.subtract(const Duration(hours: 24));
    final windowEnd = now.subtract(const Duration(minutes: 90));
    final linkedIds = <String>{};
    for (final a in p.actionsHistory) {
      if (a.linkedEventType == LinkedEventType.symptom) {
        linkedIds.add(a.linkedEventId);
      }
    }
    return p.symptomHistory.where((s) {
      if (s.timestamp.isAfter(windowEnd)) return false;
      if (s.timestamp.isBefore(windowStart)) return false;
      return !linkedIds.contains(s.timestamp.toIso8601String());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isPacing = profile.state.pacingDays.contains(_dateKey(selectedDate));
    final dueOutcomes = _isToday()
        ? profile.getDueOutcomes()
        : <MedicationOutcome>[];
    final l10n = context.l10n;
    final feverInfo = FeverAnalysis.latestForChip(profile.feverHistory);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // Sprint G.B.2 — Flare banner (visible only when in flare mode)
        FlareBanner(
          profile: profile,
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
          onDeactivate: () {
            profile.state.flare = null;
            onFlareChange();
          },
        ),

        // Sprint G.E — Flare suggestion + 48h check-in banner (auto).
        FlareSuggestionBanner(
          profile: profile,
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
          onAcceptSuggestion: () {
            profile.state.flare = FlareState(startedAt: DateTime.now());
            final now = DateTime.now();
            final todayKey =
                '${now.year}-${now.month.toString().padLeft(2, '0')}-'
                '${now.day.toString().padLeft(2, '0')}';
            profile.state.pacingDays.add(todayKey);
            onFlareChange();
          },
          onDismissSuggestion: () {
            profile.state.flareSuggestionDismissedAt = DateTime.now();
            onFlareChange();
          },
          onCheckInContinue: () {
            final flare = profile.state.flare;
            if (flare != null) {
              flare.promptCount += 1;
              flare.lastPromptAt = DateTime.now();
            }
            onFlareChange();
          },
          onCheckInBetter: () {
            profile.state.flare = null;
            onFlareChange();
          },
        ),

        // 1. Header — date + inline pacing toggle + flare chip
        _HoyHeader(
          date: selectedDate,
          isPacing: isPacing,
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
          onTogglePacing: onTogglePacing,
          profile: profile,
          onActivateFlare: () {
            profile.state.flare = FlareState(startedAt: DateTime.now());
            final now = DateTime.now();
            final todayKey =
                '${now.year}-${now.month.toString().padLeft(2, '0')}-'
                '${now.day.toString().padLeft(2, '0')}';
            profile.state.pacingDays.add(todayKey);
            onFlareChange();
          },
        ),

        const SizedBox(height: 20),

        // Sprint T0 — weekly narrative summary (rolling 7 days)
        // Sprint G.C — hide when in flare mode.
        if (!profile.state.isInFlare)
          WeeklyNarrative(profile: profile, contrastColor: contrastColor),

        // Sprint B.C — Feedback prompt banner (weekly cadence).
        if (!profile.state.isInFlare)
          FeedbackPromptBanner(
            contrastColor: contrastColor,
            inverseContrastColor: inverseContrastColor,
          ),

        // 1.5. FIRST-SESSION HINT
        if (showHint) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: contrastColor.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: contrastColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.hintTapTip,
                    style: TextStyle(
                      color: contrastColor.withValues(alpha: 0.8),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onDismissHint,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      color: contrastColor.withValues(alpha: 0.6),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Sprint F.D — follow-up reminder banner
        // (renders SizedBox.shrink when no follow-ups are due)
        // Sprint G.C — hide when in flare mode.
        if (!profile.state.isInFlare)
          FollowUpBanner(
            pendingActions: profile.actionsHistory
                .where((a) => a.followUpIsDue)
                .toList(),
            botiquin: profile.botiquin,
            contrastColor: contrastColor,
            inverseContrastColor: inverseContrastColor,
            onTap: (action) {
              ActionEffectivenessDialog.show(
                context: context,
                action: action,
                botiquin: profile.botiquin,
                contrastColor: contrastColor,
                inverseContrastColor: inverseContrastColor,
              ).then((updated) {
                if (updated != null) {
                  onCompleteFollowUp(updated);
                }
              });
            },
          ),

        // Sprint F.E — retro symptom check-in banner
        // (90 min < age < 24 h, no matching ActionTaken)
        // Sprint G.C — hide when in flare mode.
        if (!profile.state.isInFlare)
          RetroSymptomBanner(
            pendingSymptoms: _pendingRetroSymptoms(profile),
            contrastColor: contrastColor,
            inverseContrastColor: inverseContrastColor,
            onTap: (symptom) {
              RetroSymptomDialog.show(
                context: context,
                symptom: symptom,
                botiquin: profile.botiquin,
                doseHistory: profile.doseHistory,
                contrastColor: contrastColor,
                inverseContrastColor: inverseContrastColor,
              ).then((action) {
                if (action != null) {
                  onSaveRetroSymptom(action);
                }
              });
            },
          ),

        // 2. URGENT — pending outcome check-ins.
        if (dueOutcomes.isNotEmpty) ...[
          _SectionHeader(
            title: l10n.hoySectionPendingHeader,
            badge: '${dueOutcomes.length}',
            badgeColor: const Color(0xFFE57373),
            contrastColor: contrastColor,
          ),
          const SizedBox(height: 8),
          ...dueOutcomes.map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OutcomeAnswerCard(
                outcome: o,
                contrastColor: contrastColor,
                inverseContrastColor: inverseContrastColor,
                onAnswer: onAnswerOutcome,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // PHASE 5.2d.3a — Fever chip
        if (feverInfo != null) ...[
          _FeverChip(
            info: feverInfo,
            contrastColor: contrastColor,
            onNavigate: onNavigate,
          ),
          const SizedBox(height: 20),
        ],

        if (todayWeather != null) ...[
          const SizedBox(height: 12),
          Text(
            l10n.sectionWeather,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: contrastColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: contrastColor.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_outlined,
                  color: contrastColor.withValues(alpha: 0.7),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  todayWeather!.shortSummary(),
                  style: TextStyle(
                    color: contrastColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 3. New Mood section.
        MoodSection(
          profile: profile,
          selectedDate: selectedDate,
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
          moodDictionary: moodDictionary, // Pasamos el diccionario JSON
          onLogMood: onLogMood,
          onDeleteMood: onDeleteMood,
        ),

        const SizedBox(height: 16),

        // 4. PROGRESSIVE — mental details collapsed by default.
        _MentalDetailsSection(
          profile: profile,
          selectedDate: selectedDate,
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
          onLogMental: onLogMental,
        ),

        const SizedBox(height: 24),

        // 5. NARRATIVE — sentence-form day summary, not counts.
        _NarrativeSummary(
          profile: profile,
          selectedDate: selectedDate,
          isPacing: isPacing,
          contrastColor: contrastColor,
        ),

        const SizedBox(height: 16),

        // PHASE 5.1 — Bowel counter (null-safe; hidden when no bowel history).
        _BowelCounter(profile: profile, contrastColor: contrastColor),

        // PHASE 5.2a — Distention banner (visible only when daysSinceLastBM >= 3).
        _DistentionBanner(
          profile: profile,
          contrastColor: contrastColor,
          onTapRegister: () => onNavigate(1),
        ),

        const SizedBox(height: 16),

        // 6. WISDOM — demoted to bottom, smaller, ambient.
        _WisdomBlock(
          quote: wisdom,
          contrastColor: contrastColor,
          onChange: onChangeWisdom,
        ),
      ],
    );
  }
}

// =============================================================================
// Header — date + inline Potato Day toggle
// =============================================================================

class _HoyHeader extends StatelessWidget {
  final DateTime date;
  final bool isPacing;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onTogglePacing;
  // Sprint G.B.2 - inline flare chip alongside the potato day chip.
  final Profile profile;
  final VoidCallback onActivateFlare;

  const _HoyHeader({
    required this.date,
    required this.isPacing,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onTogglePacing,
    required this.profile,
    required this.onActivateFlare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Each locale controls its own date pattern through the ARB. The
    // pattern is a DateFormat skeleton (not an ICU template) so
    // single-quoted literals like 'de' in Spanish pass through verbatim.
    final dateLine = DateFormat(
      l10n.hoyHeaderDatePattern,
      l10n.localeName,
    ).format(date);
    // Capitalize the first character for languages where the natural
    // form starts lowercase (Spanish weekday names). Locales whose first
    // character is already uppercase (English) or non-cased (zh-TW)
    // are unaffected by this no-op transformation.
    final capitalized = dateLine.isEmpty
        ? dateLine
        : dateLine[0].toUpperCase() + dateLine.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.headerTodayIs,
          style: TextStyle(
            fontSize: 12,
            color: contrastColor.withValues(alpha: 0.55),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          capitalized,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        const SizedBox(height: 10),
        // G.B.2 wrap — potato day chip + flare chip inline
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InkWell(
              onTap: onTogglePacing,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isPacing
                      ? contrastColor
                      : contrastColor.withValues(alpha: 0.06),
                  border: Border.all(
                    color: contrastColor.withValues(
                      alpha: isPacing ? 1.0 : 0.4,
                    ),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPacing ? Icons.shield : Icons.shield_outlined,
                      size: 16,
                      color: isPacing ? inverseContrastColor : contrastColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPacing
                          ? l10n.pacingActiveState
                          : l10n.pacingInactiveState,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPacing ? inverseContrastColor : contrastColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FlareChip(
              profile: profile,
              contrastColor: contrastColor,
              inverseContrastColor: inverseContrastColor,
              onActivate: onActivateFlare,
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// Section header
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
// Outcome answer card
// =============================================================================

class _OutcomeAnswerCard extends StatefulWidget {
  final MedicationOutcome outcome;
  final Color contrastColor;
  final Color inverseContrastColor;
  final void Function(
    MedicationOutcome, {
    required int severityAfter,
    OutcomeReason? reason,
  })
  onAnswer;

  const _OutcomeAnswerCard({
    required this.outcome,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onAnswer,
  });

  @override
  State<_OutcomeAnswerCard> createState() => _OutcomeAnswerCardState();
}

class _OutcomeAnswerCardState extends State<_OutcomeAnswerCard> {
  SymptomSeverity? _selected;
  OutcomeReason? _reason;
  bool _showReasonPicker = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.outcome;
    final l10n = context.l10n;
    final cc = widget.contrastColor;
    final before = SymptomSeverity.fromValue(o.severityBefore);
    final hoursAgo =
        DateTime.now().difference(o.doseTimestamp).inMinutes / 60.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE57373).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE57373).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(color: cc, fontSize: 13, height: 1.4),
              children: [
                TextSpan(
                  text: l10n.outcomeCardTimePrefix(hoursAgo.toStringAsFixed(1)),
                  style: TextStyle(color: cc.withValues(alpha: 0.8)),
                ),
                TextSpan(
                  text: o.medicationName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: l10n.hoyOutcomeForYour,
                  style: TextStyle(color: cc.withValues(alpha: 0.8)),
                ),
                TextSpan(
                  text: o.symptomName.toLowerCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                l10n.outcomeCardInitialState,
                style: TextStyle(
                  fontSize: 12,
                  color: cc.withValues(alpha: 0.65),
                ),
              ),
              SeverityBadge(severity: before, size: 10),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.outcomeCardQuestionNow,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cc,
            ),
          ),
          const SizedBox(height: 8),
          SeverityDotPicker(
            anchor: before,
            selected: _selected,
            showLabels: true,
            onSelect: (sev) => setState(() => _selected = sev),
          ),
          const SizedBox(height: 12),
          if (_showReasonPicker) ...[
            Text(
              l10n.outcomeCardAttributionQuestion,
              style: TextStyle(fontSize: 12, color: cc.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: OutcomeReason.values.map((r) {
                final sel = _reason == r;
                return ChoiceChip(
                  selected: sel,
                  label: Text(
                    r.outcomeReasonLabel(l10n),
                    style: const TextStyle(fontSize: 11),
                  ),
                  onSelected: (v) => setState(() => _reason = v ? r : null),
                  selectedColor: cc,
                  labelStyle: TextStyle(
                    color: sel ? widget.inverseContrastColor : cc,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: cc.withValues(alpha: 0.05),
                  side: BorderSide(color: cc.withValues(alpha: 0.3)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              TextButton.icon(
                onPressed: () =>
                    setState(() => _showReasonPicker = !_showReasonPicker),
                icon: Icon(
                  _showReasonPicker
                      ? Icons.expand_less
                      : Icons.add_circle_outline,
                  size: 16,
                  color: cc.withValues(alpha: 0.7),
                ),
                label: Text(
                  _showReasonPicker
                      ? l10n.hoyOutcomeHideReasons
                      : l10n.outcomeActionAddFactor,
                  style: TextStyle(
                    fontSize: 12,
                    color: cc.withValues(alpha: 0.7),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => widget.onAnswer(
                        o,
                        severityAfter: _selected!.value,
                        reason: _reason,
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cc,
                  foregroundColor: widget.inverseContrastColor,
                  disabledBackgroundColor: cc.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  l10n.actionSave,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MentalDetailsSection
// =============================================================================

class _MentalDetailsSection extends StatefulWidget {
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final void Function(MentalState state, int severity, {DateTime? timestamp})
  onLogMental;

  const _MentalDetailsSection({
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onLogMental,
  });

  @override
  State<_MentalDetailsSection> createState() => _MentalDetailsSectionState();
}

class _MentalDetailsSectionState extends State<_MentalDetailsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final l10n = context.l10n;
    final loggedToday =
        <MentalState>{
              MentalState.anxiety,
              MentalState.emotionalEnergy,
              MentalState.brainFog,
              MentalState.dissociation,
              MentalState.irritability,
            }
            .where(
              (s) =>
                  widget.profile.latestMentalSeverity(s, widget.selectedDate) !=
                  null,
            )
            .length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cc.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 18,
                    color: cc.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.sectionMentalDetails,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cc,
                    ),
                  ),
                  if (loggedToday > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: cc.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$loggedToday',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: cc,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: cc.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _MentalSlider(
                    state: MentalState.anxiety,
                    current: widget.profile.latestMentalSeverity(
                      MentalState.anxiety,
                      widget.selectedDate,
                    ),
                    contrastColor: cc,
                    onChanged: (v) =>
                        widget.onLogMental(MentalState.anxiety, v),
                  ),
                  const SizedBox(height: 14),
                  _MentalSlider(
                    state: MentalState.emotionalEnergy,
                    current: widget.profile.latestMentalSeverity(
                      MentalState.emotionalEnergy,
                      widget.selectedDate,
                    ),
                    contrastColor: cc,
                    onChanged: (v) =>
                        widget.onLogMental(MentalState.emotionalEnergy, v),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        [
                          MentalState.brainFog,
                          MentalState.dissociation,
                          MentalState.irritability,
                        ].map((s) {
                          final latest = widget.profile.latestMentalSeverity(
                            s,
                            widget.selectedDate,
                          );
                          final logged = latest != null;
                          return InkWell(
                            onTap: () => _showMentalChipPicker(context, s),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: logged
                                    ? cc.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: cc.withValues(
                                    alpha: logged ? 0.4 : 0.25,
                                  ),
                                ),
                              ),
                              child: Text(
                                logged
                                    ? '${s.emoji} ${s.mentalStateLabel(l10n)} · $latest'
                                    : '${s.emoji} ${s.mentalStateLabel(l10n)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cc.withValues(
                                    alpha: logged ? 1.0 : 0.7,
                                  ),
                                  fontWeight: logged
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showMentalChipPicker(BuildContext context, MentalState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.inverseContrastColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.emoji} ${state.mentalStateLabel(context.l10n)}',
                  style: TextStyle(
                    color: widget.contrastColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.mentalIntensitySubtitle,
                  style: TextStyle(
                    color: widget.contrastColor.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                _MentalSlider(
                  state: state,
                  current: widget.profile.latestMentalSeverity(
                    state,
                    widget.selectedDate,
                  ),
                  contrastColor: widget.contrastColor,
                  onChanged: (v) {
                    widget.onLogMental(state, v);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MentalSlider extends StatelessWidget {
  final MentalState state;
  final int? current;
  final Color contrastColor;
  final ValueChanged<int> onChanged;

  const _MentalSlider({
    required this.state,
    required this.current,
    required this.contrastColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(state.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Builder(
              builder: (ctx) => Text(
                state.mentalStateLabel(AppLocalizations.of(ctx)!),
                style: TextStyle(
                  color: contrastColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const Spacer(),
            if (current != null)
              Text(
                '$current/5',
                style: TextStyle(
                  color: contrastColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (i) {
            final v = i + 1;
            final selected = current == v;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => onChanged(v),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected
                          ? contrastColor
                          : contrastColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: contrastColor.withValues(
                          alpha: selected ? 1.0 : 0.25,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$v',
                      style: TextStyle(
                        color: selected
                            ? (contrastColor.computeLuminance() > 0.5
                                  ? Colors.black87
                                  : Colors.white)
                            : contrastColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// =============================================================================
// NarrativeSummary
// =============================================================================

class _NarrativeSummary extends StatelessWidget {
  final Profile profile;
  final DateTime selectedDate;
  final bool isPacing;
  final Color contrastColor;

  const _NarrativeSummary({
    required this.profile,
    required this.selectedDate,
    required this.isPacing,
    required this.contrastColor,
  });

  @override
  Widget build(BuildContext context) {
    final syms = profile.getSymptomsForDay(selectedDate);
    final structs = profile.getStructuralForDay(selectedDate);
    final doses = profile.getDosesForDay(selectedDate);
    final mentals = profile.getMentalForDay(selectedDate);
    final emaMoods = profile.getMoodForDay(selectedDate); // NUEVO
    final l10n = context.l10n;

    final sentences = _buildSentences(
      syms: syms,
      structs: structs,
      doses: doses,
      mentals: mentals,
      emaMoods: emaMoods,
      isPacing: isPacing,
      l10n: l10n,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: contrastColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 16,
                color: contrastColor.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.summaryTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: contrastColor.withValues(alpha: 0.6),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...sentences.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                s,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: contrastColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildSentences({
    required List<SymptomEvent> syms,
    required List<StructuralEvent> structs,
    required List<DoseEvent> doses,
    required List<MentalEvent> mentals,
    required List<MoodEntry> emaMoods,
    required bool isPacing,
    required AppLocalizations l10n,
  }) {
    final out = <String>[];

    if (syms.isEmpty &&
        structs.isEmpty &&
        doses.isEmpty &&
        mentals.isEmpty &&
        emaMoods.isEmpty) {
      out.add(isPacing ? l10n.hoyNarrativeEmptyPacing : l10n.hoyNarrativeEmpty);
      return out;
    }

    if (syms.isNotEmpty) {
      final worst = syms.reduce(
        (a, b) => a.severity.value >= b.severity.value ? a : b,
      );
      final n = syms.length;
      final worstName = worst.name.toLowerCase();
      final worstSev = worst.severity.severityLabel(l10n).toLowerCase();
      if (n == 1) {
        out.add(l10n.hoyNarrativeSymptomsSingleTemplate(worstName, worstSev));
      } else {
        out.add(l10n.hoyNarrativeSymptomsManyTemplate(n, worstName, worstSev));
      }
      // C.4: if the worst symptom of the day has headache detail, append
      // its chip summary as a separate sentence.
      if (worst.headacheDetail != null) {
        final summary = formatHeadacheDetailCompact(
          worst.headacheDetail!,
          l10n,
        );
        if (summary.isNotEmpty) out.add(summary);
      }
      // D.1: same treatment for fatigue detail. Mutually exclusive
      // with headache detail per non-overlapping symptom aliases,
      // but the two blocks stay independent for defensive rendering.
      if (worst.fatigueDetail != null) {
        final summary = formatFatigueDetailCompact(
          worst.fatigueDetail!,
          l10n.localeName,
        );
        if (summary.isNotEmpty) out.add(summary);
      }
      // D.2: same treatment for abdominal detail. Aliases for the
      // three symptoms do not overlap, so the three blocks are
      // mutually exclusive in practice but remain independent for
      // defensive rendering.
      if (worst.abdominalDetail != null) {
        final summary = formatAbdominalDetailCompact(
          worst.abdominalDetail!,
          l10n.localeName,
        );
        if (summary.isNotEmpty) out.add(summary);
      }
    }

    if (structs.isNotEmpty) {
      final n = structs.length;
      if (n == 1) {
        out.add(
          l10n.hoyNarrativeStructuralSingleTemplate(
            structs.first.zone.bodyZoneLabel(l10n).toLowerCase(),
          ),
        );
      } else {
        out.add(l10n.hoyNarrativeStructuralManyTemplate(n));
      }
    }

    if (doses.isNotEmpty) {
      final byMed = <String, double>{};
      for (final d in doses) {
        byMed[d.medicationName] = (byMed[d.medicationName] ?? 0) + d.quantity;
      }
      final sorted = byMed.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final shown = sorted
          .take(3)
          .map((e) {
            final q = e.value;
            final qStr = q == q.roundToDouble()
                ? q.toInt().toString()
                : q.toString();
            return '${e.key} ($qStr)';
          })
          .join(', ');
      final extra = sorted.length > 3
          ? l10n.hoyNarrativeDosesAndMore(sorted.length - 3)
          : '';
      final totalDoses = doses.length;
      final medsStr = '$shown$extra';
      if (totalDoses == 1) {
        out.add(l10n.hoyNarrativeDosesSingleTemplate(medsStr));
      } else {
        out.add(l10n.hoyNarrativeDosesManyTemplate(totalDoses, medsStr));
      }
    }

    if (emaMoods.isNotEmpty) {
      final allStates = emaMoods.expand((e) => e.states).toSet().toList();
      if (allStates.isNotEmpty) {
        final statesStr = allStates.take(4).join(', ');
        final extra = allStates.length > 4
            ? l10n.hoyNarrativeEmaStatesEllipsis
            : '';
        out.add(l10n.hoyNarrativeEmaStatesTemplate('$statesStr$extra'));
      }
    }

    if (isPacing) {
      out.add(l10n.hoyNarrativePacingTrailer);
    }

    return out;
  }
}

// =============================================================================
// Wisdom block
// =============================================================================

class _WisdomBlock extends StatelessWidget {
  final WisdomQuote quote;
  final Color contrastColor;
  final VoidCallback onChange;

  const _WisdomBlock({
    required this.quote,
    required this.contrastColor,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onChange,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: contrastColor.withValues(alpha: 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.wisdomBannerTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: contrastColor.withValues(alpha: 0.5),
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.refresh,
                  size: 14,
                  color: contrastColor.withValues(alpha: 0.4),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '"${quote.text(l10n.localeName)}"',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: contrastColor.withValues(alpha: 0.85),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '— ${quote.source}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: contrastColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '- ${quote.category}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: contrastColor.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PHASE 5.1 — Bowel counter
// =============================================================================

/// Passive chip that surfaces `daysSinceLastBM` from the profile.
///
/// Renders nothing when bowel history is empty (null). Once data exists,
/// shows "última evacuación: hoy" / "ayer" / "hace N días". Visual weight
/// matches the weather chip — no urgency styling. The distention banner
/// (phase 5.2) will handle alerting when delays cross clinical thresholds.
class _BowelCounter extends StatelessWidget {
  final Profile profile;
  final Color contrastColor;

  const _BowelCounter({required this.profile, required this.contrastColor});

  @override
  Widget build(BuildContext context) {
    final days = profile.daysSinceLastBM;
    final l10n = context.l10n;
    if (days == null) return const SizedBox.shrink();

    final label = switch (days) {
      0 => l10n.hoyBowelCounterToday,
      1 => l10n.hoyBowelCounterYesterday,
      _ => l10n.hoyBowelCounterDaysAgoTemplate(days),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: contrastColor.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timeline,
              color: contrastColor.withValues(alpha: 0.7),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: contrastColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PHASE 5.2a — Distention banner
// =============================================================================

/// Soft-tone banner shown on Hoy when bowel transit has been absent for
/// `_thresholdDays` or more. Informational, never alarming — no red colors,
/// no exclamation marks, no countdown anxiety. Includes a shortcut button
/// that takes the user to the Síntomas tab to register.
///
/// The threshold of 3 days is aligned with the Rome IV clinical definition
/// of constipation (≥3 days without a bowel movement is the lower bound for
/// chronic constipation criteria). Below 3 days, this widget renders nothing.
///
/// Research grounding: Palsson et al. (2012) — defecation-vs-distention pain
/// mechanism separation; distention pain accumulates without a discrete trigger.
class _DistentionBanner extends StatelessWidget {
  final Profile profile;
  final Color contrastColor;
  final VoidCallback onTapRegister;

  static const int _thresholdDays = 3;

  const _DistentionBanner({
    required this.profile,
    required this.contrastColor,
    required this.onTapRegister,
  });

  @override
  Widget build(BuildContext context) {
    final days = profile.daysSinceLastBM;
    final l10n = context.l10n;
    if (days == null || days < _thresholdDays) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border.all(color: contrastColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: contrastColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.distentionBannerMessage(days),
                  style: TextStyle(
                    color: contrastColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: contrastColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
              ),
              icon: Icon(Icons.arrow_forward, color: contrastColor, size: 14),
              label: Text(
                l10n.distentionBannerAction,
                style: TextStyle(
                  color: contrastColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: onTapRegister,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PHASE 5.2d.3a — Fever chip
// =============================================================================

/// Compact status chip surfacing the most recent fever reading.
///
/// Renders nothing when no reading exists within the last
/// `FeverAnalysis.chipMaxAgeHours` (24h by default). Visual weight matches
/// the bowel counter — outlined pill, no urgency styling. The temperature
/// number itself is the signal; we deliberately avoid color/bold variation
/// by severity to keep the B&W aesthetic consistent.
///
/// Tap navigates to Síntomas (tab index 1) — same shortcut pattern as the
/// distention banner. From there the user can log another reading or
/// review history.
///
/// Trend arrow uses a 0.1°C deadband (computed in LatestFeverInfo) so
/// noise-level fluctuations don't trigger flicker between ↑ and ↓.
class _FeverChip extends StatelessWidget {
  final LatestFeverInfo info;
  final Color contrastColor;
  final ValueChanged<int> onNavigate;

  const _FeverChip({
    required this.info,
    required this.contrastColor,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = info.reading;
    final timeAgo = DateTime.now().difference(r.timestamp);
    final trend = info.trend;
    final delta = info.delta;

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => onNavigate(1),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: contrastColor.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.thermostat,
                color: contrastColor.withValues(alpha: 0.7),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                '${r.temperatureC.toStringAsFixed(1)}°C',
                style: TextStyle(
                  color: contrastColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' · ${r.site.label(l10n)}',
                style: TextStyle(
                  color: contrastColor.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
              Text(
                ' · ${_formatTimeAgo(timeAgo, l10n)}',
                style: TextStyle(
                  color: contrastColor.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
              if (trend != null && delta != null) ...[
                const SizedBox(width: 4),
                Text(
                  '· ${_formatTrend(trend, delta)}',
                  style: TextStyle(
                    color: contrastColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(Duration d, AppLocalizations l10n) {
    if (d.inHours >= 1) return l10n.timeAgoHours(d.inHours);
    return l10n.timeAgoMinutes(d.inMinutes.clamp(1, 59));
  }

  String _formatTrend(FeverTrend trend, double delta) {
    return switch (trend) {
      FeverTrend.rising => '↑${delta.toStringAsFixed(1)}',
      FeverTrend.falling => '↓${delta.abs().toStringAsFixed(1)}',
      FeverTrend.steady => '→',
    };
  }
}
