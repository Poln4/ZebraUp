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
// severity at dose-time and `selected` capturing the after-state — closing the
// loop on the "Mejor/Igual/Peor collapses information" problem.
// =============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/severity_picker.dart';

// Hardcoded Spanish to avoid requiring initializeDateFormatting('es') in main().
const _diasSemana = [
  'lunes', 'martes', 'miércoles', 'jueves',
  'viernes', 'sábado', 'domingo',
];
const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];
String _fechaLarga(DateTime d) {
  final dia = _diasSemana[d.weekday - 1]; // weekday is 1=Monday..7=Sunday
  final mes = _meses[d.month - 1];
  return '$dia ${d.day} de $mes';
}

class HoyTab extends StatelessWidget {
  final Profile profile;
  final DateTime selectedDate;
  final WisdomQuote wisdom;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onTogglePacing;
  final void Function(MentalState state, int severity, {DateTime? timestamp})
      onLogMental;
  final void Function(MedicationOutcome outcome,
      {required int severityAfter, OutcomeReason? reason}) onAnswerOutcome;
  final VoidCallback onChangeWisdom;

  const HoyTab({
    super.key,
    required this.profile,
    required this.selectedDate,
    required this.wisdom,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onTogglePacing,
    required this.onLogMental,
    required this.onAnswerOutcome,
    required this.onChangeWisdom,
  });

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  bool _isToday() {
    final n = DateTime.now();
    return n.year == selectedDate.year &&
        n.month == selectedDate.month &&
        n.day == selectedDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final isPacing = profile.pacingDays.contains(_dateKey(selectedDate));
    final dueOutcomes = _isToday() ? profile.getDueOutcomes() : <MedicationOutcome>[];
    final currentMood =
        profile.latestMentalSeverity(MentalState.mood, selectedDate);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // 1. Header — date + inline pacing toggle.
        _HoyHeader(
          date: selectedDate,
          isPacing: isPacing,
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
          onTogglePacing: onTogglePacing,
        ),

        const SizedBox(height: 20),

        // 2. URGENT — pending outcome check-ins. Surfaces above everything
        //    because they're time-sensitive and the user likely opened the
        //    app to address them. Hidden when viewing a non-today date.
        if (dueOutcomes.isNotEmpty) ...[
          _SectionHeader(
            title: 'Pendientes',
            badge: '${dueOutcomes.length}',
            badgeColor: const Color(0xFFE57373),
            contrastColor: contrastColor,
          ),
          const SizedBox(height: 8),
          ...dueOutcomes.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OutcomeAnswerCard(
                  outcome: o,
                  contrastColor: contrastColor,
                  inverseContrastColor: inverseContrastColor,
                  onAnswer: onAnswerOutcome,
                ),
              )),
          const SizedBox(height: 24),
        ],

        // 3. PRIMARY — single "how do you feel" decision.
        _SectionHeader(
          title: '¿Cómo te sientes ahora?',
          contrastColor: contrastColor,
        ),
        const SizedBox(height: 12),
        _FeelingSelector(
          current: currentMood,
          contrastColor: contrastColor,
          inverseContrastColor: inverseContrastColor,
          onSelect: (v) => onLogMental(MentalState.mood, v),
        ),
        if (currentMood != null) ...[
          const SizedBox(height: 6),
          Text(
            _moodTrailer(currentMood),
            style: TextStyle(
              fontSize: 12,
              color: contrastColor.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],

        const SizedBox(height: 24),

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

        const SizedBox(height: 32),

        // 6. WISDOM — demoted to bottom, smaller, ambient.
        _WisdomBlock(
          quote: wisdom,
          contrastColor: contrastColor,
          onChange: onChangeWisdom,
        ),
      ],
    );
  }

  String _moodTrailer(int v) {
    return switch (v) {
      1 => 'Día difícil. Validamos eso. 🫂',
      2 => 'Bajón hoy. Está bien tomártelo con calma.',
      3 => 'Tirando — un día regular.',
      4 => 'Bien. Disfrútalo.',
      5 => '✨ Brillando. Que dure.',
      _ => '',
    };
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

  const _HoyHeader({
    required this.date,
    required this.isPacing,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onTogglePacing,
  });

  @override
  Widget build(BuildContext context) {
    final dateLine = _fechaLarga(date);
    final capitalized =
        dateLine[0].toUpperCase() + dateLine.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoy es',
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
        InkWell(
          onTap: onTogglePacing,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isPacing
                  ? contrastColor
                  : contrastColor.withValues(alpha: 0.06),
              border: Border.all(
                color: contrastColor.withValues(alpha: isPacing ? 1.0 : 0.4),
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
                      ? 'Día de descanso — sin expectativas'
                      : 'Marcar como día de descanso',
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
      ],
    );
  }
}

// =============================================================================
// Section header — used by every section for visual rhythm
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
// Outcome answer card — wraps SeverityDotPicker with anchor + reason
// =============================================================================

class _OutcomeAnswerCard extends StatefulWidget {
  final MedicationOutcome outcome;
  final Color contrastColor;
  final Color inverseContrastColor;
  final void Function(MedicationOutcome,
      {required int severityAfter, OutcomeReason? reason}) onAnswer;

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
          // Context line
          RichText(
            text: TextSpan(
              style: TextStyle(color: cc, fontSize: 13, height: 1.4),
              children: [
                TextSpan(
                  text: 'Hace ${hoursAgo.toStringAsFixed(1)}h tomaste ',
                  style: TextStyle(color: cc.withValues(alpha: 0.8)),
                ),
                TextSpan(
                  text: o.medicationName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' para tu ',
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

          // Before-anchor: "estaba en"
          Row(
            children: [
              Text(
                'Estaba en ',
                style: TextStyle(
                  fontSize: 12,
                  color: cc.withValues(alpha: 0.65),
                ),
              ),
              SeverityBadge(severity: before, size: 10),
            ],
          ),
          const SizedBox(height: 12),

          // The question
          Text(
            '¿Cómo está ahora?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cc,
            ),
          ),
          const SizedBox(height: 8),

          // Dot picker with anchor (so user sees where they were)
          SeverityDotPicker(
            anchor: before,
            selected: _selected,
            showLabels: true,
            onSelect: (sev) => setState(() => _selected = sev),
          ),
          const SizedBox(height: 12),

          // Optional reason picker — collapsed by default
          if (_showReasonPicker) ...[
            Text(
              '¿A qué lo atribuyes?',
              style: TextStyle(
                fontSize: 12,
                color: cc.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: OutcomeReason.values.map((r) {
                final sel = _reason == r;
                return ChoiceChip(
                  selected: sel,
                  label: Text(r.label, style: const TextStyle(fontSize: 11)),
                  onSelected: (v) =>
                      setState(() => _reason = v ? r : null),
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

          // Footer: reason toggle + save
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
                  _showReasonPicker ? 'Ocultar' : 'Otro factor',
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
                  disabledBackgroundColor:
                      cc.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
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
// FeelingSelector — primary "how do you feel" entry, faces + colors
// =============================================================================

class _FeelingSelector extends StatelessWidget {
  final int? current;
  final Color contrastColor;
  final Color inverseContrastColor;
  final ValueChanged<int> onSelect;

  const _FeelingSelector({
    required this.current,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onSelect,
  });

  static const _faces = ['😩', '😟', '😐', '🙂', '😄'];
  static const _labels = ['Muy mal', 'Mal', 'Regular', 'Bien', 'Muy bien'];
  static const _colors = [
    Color(0xFFE57373), // 1 — red
    Color(0xFFFFB74D), // 2 — orange
    Color(0xFFFFD54F), // 3 — yellow
    Color(0xFFAED581), // 4 — light green
    Color(0xFF81C784), // 5 — green
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final v = i + 1;
        final selected = current == v;
        final color = _colors[i];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () => onSelect(v),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? color
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? color
                        : color.withValues(alpha: 0.3),
                    width: selected ? 0 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(_faces[i], style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.w500,
                        color: selected
                            ? (color.computeLuminance() > 0.5
                                ? Colors.black87
                                : Colors.white)
                            : contrastColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// =============================================================================
// MentalDetailsSection — collapsed by default
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
    // Count how many extra dimensions are already logged today — surface as
    // a small badge so the user knows there's already data here.
    final loggedToday = <MentalState>{
      MentalState.anxiety,
      MentalState.emotionalEnergy,
      MentalState.brainFog,
      MentalState.dissociation,
      MentalState.irritability,
    }
        .where((s) =>
            widget.profile.latestMentalSeverity(s, widget.selectedDate) != null)
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
                    'Detalles mentales',
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
                          horizontal: 7, vertical: 1),
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
                  // Detailed sliders for the two secondary core dimensions.
                  _MentalSlider(
                    state: MentalState.anxiety,
                    current: widget.profile.latestMentalSeverity(
                        MentalState.anxiety, widget.selectedDate),
                    contrastColor: cc,
                    onChanged: (v) => widget.onLogMental(MentalState.anxiety, v),
                  ),
                  const SizedBox(height: 14),
                  _MentalSlider(
                    state: MentalState.emotionalEnergy,
                    current: widget.profile.latestMentalSeverity(
                        MentalState.emotionalEnergy, widget.selectedDate),
                    contrastColor: cc,
                    onChanged: (v) =>
                        widget.onLogMental(MentalState.emotionalEnergy, v),
                  ),
                  const SizedBox(height: 16),
                  // Less-common states as chips.
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      MentalState.brainFog,
                      MentalState.dissociation,
                      MentalState.irritability,
                    ].map((s) {
                      final latest = widget.profile
                          .latestMentalSeverity(s, widget.selectedDate);
                      final logged = latest != null;
                      return InkWell(
                        onTap: () => _showMentalChipPicker(context, s),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: logged
                                ? cc.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cc.withValues(alpha: logged ? 0.4 : 0.25),
                            ),
                          ),
                          child: Text(
                            logged
                                ? '${s.emoji} ${s.label} · $latest'
                                : '${s.emoji} ${s.label}',
                            style: TextStyle(
                              fontSize: 12,
                              color: cc.withValues(alpha: logged ? 1.0 : 0.7),
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
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.emoji} ${state.label}',
                  style: TextStyle(
                    color: widget.contrastColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Intensidad ahora',
                  style: TextStyle(
                    color: widget.contrastColor.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                _MentalSlider(
                  state: state,
                  current: widget.profile
                      .latestMentalSeverity(state, widget.selectedDate),
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

/// 5-segment slider for mental dimensions. Kept compact; this is detail UX.
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
            Text(
              state.label,
              style: TextStyle(
                color: contrastColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
                            alpha: selected ? 1.0 : 0.25),
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
// NarrativeSummary — sentence-form recap, not counts
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

    final sentences = _buildSentences(
      syms: syms,
      structs: structs,
      doses: doses,
      mentals: mentals,
      isPacing: isPacing,
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
              Icon(Icons.auto_stories_outlined,
                  size: 16, color: contrastColor.withValues(alpha: 0.6)),
              const SizedBox(width: 6),
              Text(
                'Tu día en pocas palabras',
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
          ...sentences.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  s,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: contrastColor,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  List<String> _buildSentences({
    required List<SymptomEvent> syms,
    required List<StructuralEvent> structs,
    required List<DoseEvent> doses,
    required List<MentalEvent> mentals,
    required bool isPacing,
  }) {
    final out = <String>[];

    // Empty-state — gentle, not chastising.
    if (syms.isEmpty &&
        structs.isEmpty &&
        doses.isEmpty &&
        mentals.isEmpty) {
      out.add(isPacing
          ? '🛡️ Día de descanso. Aún no has registrado nada — está bien.'
          : 'Aún no has registrado nada hoy. ¿Cómo va todo?');
      return out;
    }

    // Symptoms line — surface the strongest, not a count.
    if (syms.isNotEmpty) {
      final worst = syms.reduce((a, b) =>
          a.severity.value >= b.severity.value ? a : b);
      final n = syms.length;
      if (n == 1) {
        out.add(
            'Registraste 1 síntoma: ${worst.name.toLowerCase()} (${worst.severity.label.toLowerCase()}).');
      } else {
        out.add(
            'Registraste $n síntomas — el más fuerte fue ${worst.name.toLowerCase()} (${worst.severity.label.toLowerCase()}).');
      }
    }

    // Structural — zebra-specific, surface even one event.
    if (structs.isNotEmpty) {
      final n = structs.length;
      out.add(n == 1
          ? 'Tuviste 1 evento estructural en ${structs.first.zone.toLowerCase()}.'
          : 'Tuviste $n eventos estructurales hoy.');
    }

    // Doses — group by med, list top 3 by count.
    if (doses.isNotEmpty) {
      final byMed = <String, double>{};
      for (final d in doses) {
        byMed[d.medicationName] = (byMed[d.medicationName] ?? 0) + d.quantity;
      }
      final sorted = byMed.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final shown = sorted.take(3).map((e) {
        final q = e.value;
        final qStr = q == q.roundToDouble() ? q.toInt().toString() : q.toString();
        return '${e.key} ($qStr)';
      }).join(', ');
      final extra = sorted.length > 3 ? ' y ${sorted.length - 3} más' : '';
      final totalDoses = doses.length;
      out.add(
          'Tomaste $totalDoses ${totalDoses == 1 ? 'dosis' : 'dosis'}: $shown$extra.');
    }

    // Mental average — surface mood specifically (the primary slider).
    final moodEvents =
        mentals.where((m) => m.state == MentalState.mood).toList();
    if (moodEvents.isNotEmpty) {
      final avg =
          moodEvents.map((m) => m.severity).reduce((a, b) => a + b) /
              moodEvents.length;
      final emoji = avg < 2
          ? '😩'
          : avg < 3
              ? '😟'
              : avg < 4
                  ? '😐'
                  : avg < 4.5
                      ? '🙂'
                      : '😄';
      out.add('Tu ánimo promedio: $emoji ${avg.toStringAsFixed(1)}/5.');
    }

    // Pacing footer — reframes the day for what it was.
    if (isPacing) {
      out.add('🛡️ Te diste permiso para descansar. Eso cuenta.');
    }

    return out;
  }
}

// =============================================================================
// Wisdom block — bottom, ambient, tappable to rotate
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
                  '✨ Sabiduría zebra',
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
              '"${quote.text}"',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: contrastColor.withValues(alpha: 0.85),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '— ${quote.category}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: contrastColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}