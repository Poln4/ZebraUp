import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'timestamp_picker.dart';

/// Hoy (Today) tab.
///
/// Sections, in order:
/// 1. Daily wisdom card
/// 2. Three quick-log sliders (Ánimo, Ansiedad, Energía emocional) — 1-5
/// 3. Mental chips for less common states (brain fog, dissociation, etc)
/// 4. Pending medication outcome check-ins (if any due)
/// 5. Potato Day toggle
/// 6. Day summary counts
class HoyTab extends StatelessWidget {
  final Profile profile;
  final DateTime selectedDate;
  final WisdomQuote wisdom;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onTogglePacing;
  final void Function(MentalState state, int severity, {DateTime? timestamp}) onLogMental;
  final void Function(MedicationOutcome outcome, {required int severityAfter, OutcomeReason? reason}) onAnswerOutcome;
  final VoidCallback onChangeWisdom; // <-- NUEVO: Función para cambiar la frase

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
    required this.onChangeWisdom, // <-- NUEVO: Requerido en el constructor
  });

  String _getDateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final dateKey = _getDateKey(selectedDate);
    final isPacing = profile.pacingDays.contains(dateKey);
    final todaysStructs = profile.getStructuralForDay(selectedDate);
    final todaysSymptoms = profile.getSymptomsForDay(selectedDate);
    final todaysMental = profile.getMentalForDay(selectedDate);
    final dosesTaken = profile.getDosesForDay(selectedDate).length;
    final dueOutcomes = profile.getDueOutcomes();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Wisdom card (Ahora envuelta en un InkWell para detectar toques)
        InkWell(
          onTap: onChangeWisdom, // <-- NUEVO: Llama a la función al tocar
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: contrastColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("SABIDURÍA ZEBRA",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1,
                            color: contrastColor)),
                    Icon(Icons.touch_app_outlined, size: 16, color: contrastColor.withOpacity(0.5)), // Pequeño indicador visual
                  ],
                ),
                const SizedBox(height: 8),
                Text('"${wisdom.text}"',
                    style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: contrastColor)),
                const SizedBox(height: 4),
                Text('— ${wisdom.category}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: contrastColor.withOpacity(0.7))),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Pending outcome check-ins — only shown if any are due
        if (dueOutcomes.isNotEmpty) ...[
          _OutcomeCheckinCard(
            outcomes: dueOutcomes,
            contrastColor: contrastColor,
            inverseContrastColor: inverseContrastColor,
            onAnswer: onAnswerOutcome,
          ),
          const SizedBox(height: 24),
        ],

        // The three primary mental sliders
        Text("CÓMO ESTOY (1–5)",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontSize: 14,
                color: contrastColor)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: contrastColor)),
          child: Column(
            children: [
              _MentalSlider(
                state: MentalState.mood,
                current: profile.latestMentalSeverity(MentalState.mood, selectedDate),
                contrastColor: contrastColor,
                onChanged: (v) => onLogMental(MentalState.mood, v),
              ),
              const Divider(color: Colors.grey, height: 24),
              _MentalSlider(
                state: MentalState.anxiety,
                current: profile.latestMentalSeverity(MentalState.anxiety, selectedDate),
                contrastColor: contrastColor,
                onChanged: (v) => onLogMental(MentalState.anxiety, v),
              ),
              const Divider(color: Colors.grey, height: 24),
              _MentalSlider(
                state: MentalState.emotionalEnergy,
                current: profile.latestMentalSeverity(MentalState.emotionalEnergy, selectedDate),
                contrastColor: contrastColor,
                onChanged: (v) => onLogMental(MentalState.emotionalEnergy, v),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Mental chips for additional states
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MentalState.brainFog,
            MentalState.dissociation,
            MentalState.irritability,
          ].map((s) {
            final latest = profile.latestMentalSeverity(s, selectedDate);
            final logged = latest != null;
            return ActionChip(
              backgroundColor: logged ? contrastColor : Colors.transparent,
              side: BorderSide(color: contrastColor),
              label: Text(
                logged ? '${s.emoji} ${s.label} ($latest)' : '${s.emoji} ${s.label}',
                style: TextStyle(
                    color: logged ? inverseContrastColor : contrastColor,
                    fontSize: 12),
              ),
              onPressed: () => _showMentalChipPicker(context, s),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Potato Day
        InkWell(
          onTap: onTogglePacing,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPacing ? contrastColor : Colors.transparent,
              border: Border.all(color: contrastColor, width: 2),
            ),
            child: Row(
              children: [
                Icon(isPacing ? Icons.shield : Icons.shield_outlined,
                    color: isPacing ? inverseContrastColor : contrastColor,
                    size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("POTATO DAY (RECUPERACIÓN)",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isPacing ? inverseContrastColor : contrastColor)),
                      Text("Validar el descanso preventivo.",
                          style: TextStyle(
                              fontSize: 12,
                              color: isPacing ? inverseContrastColor : Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Day summary
        Text("RESUMEN DEL DÍA",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontSize: 14,
                color: contrastColor)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: contrastColor)),
          child: Column(
            children: [
              _summaryRow(Icons.accessibility_new, "Eventos estructurales:",
                  "${todaysStructs.length}", contrastColor),
              const Divider(color: Colors.grey),
              _summaryRow(Icons.healing, "Síntomas:",
                  "${todaysSymptoms.length}", contrastColor),
              const Divider(color: Colors.grey),
              _summaryRow(Icons.psychology_outlined, "Salud mental:",
                  "${todaysMental.length}", contrastColor),
              const Divider(color: Colors.grey),
              _summaryRow(Icons.medical_information_outlined, "Medicación:",
                  "$dosesTaken dosis", contrastColor),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _summaryRow(IconData icon, String label, String value, Color c) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: c)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );

  void _showMentalChipPicker(BuildContext context, MentalState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: inverseContrastColor,
      shape: RoundedRectangleBorder(side: BorderSide(color: contrastColor, width: 2)),
      isScrollControlled: true,
      builder: (ctx) {
        DateTime ts = _now();
        final noteCtrl = TextEditingController();
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${state.emoji} ${state.label.toUpperCase()}',
                        style: TextStyle(
                            color: contrastColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: contrastColor.withOpacity(0.5)),
                      ),
                      icon: Icon(Icons.access_time, color: contrastColor, size: 16),
                      label: Text(
                        DateFormat('EEE d MMM, HH:mm').format(ts),
                        style: TextStyle(color: contrastColor, fontSize: 12),
                      ),
                      onPressed: () async {
                        final picked = await pickTimestamp(
                          context: ctx,
                          initial: ts,
                          contrastColor: contrastColor,
                          inverseContrastColor: inverseContrastColor,
                        );
                        if (picked != null) setSheet(() => ts = picked);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      style: TextStyle(color: contrastColor),
                      decoration: const InputDecoration(
                        hintText: "Nota opcional",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...[1, 2, 3, 4, 5].map((v) => ListTile(
                          leading: Text('$v',
                              style: TextStyle(
                                  color: contrastColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          title: Text(_severityLabel(v),
                              style: TextStyle(color: contrastColor)),
                          onTap: () {
                            onLogMental(state, v, timestamp: ts);
                            Navigator.pop(ctx);
                          },
                        )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _severityLabel(int v) => switch (v) {
        1 => 'Muy bajo / ninguno',
        2 => 'Leve',
        3 => 'Moderado',
        4 => 'Alto',
        5 => 'Severo / abrumador',
        _ => '$v',
      };

  DateTime _now() {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    return isToday
        ? now
        : DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
            now.hour, now.minute);
  }
}

/// One row of the slider for a mental state.
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
            Text(state.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(state.label,
                style: TextStyle(
                    color: contrastColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const Spacer(),
            if (current != null)
              Text('$current/5',
                  style: TextStyle(
                      color: contrastColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [1, 2, 3, 4, 5].map((v) {
            final selected = current == v;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: InkWell(
                  onTap: () => onChanged(v),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? contrastColor : Colors.transparent,
                      border: Border.all(color: contrastColor, width: 1),
                    ),
                    child: Center(
                      child: Text('$v',
                          style: TextStyle(
                            color: selected
                                ? (contrastColor == Colors.white
                                    ? Colors.black
                                    : Colors.white)
                                : contrastColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Card surfacing pending medication outcome check-ins.
class _OutcomeCheckinCard extends StatelessWidget {
  final List<MedicationOutcome> outcomes;
  final Color contrastColor;
  final Color inverseContrastColor;
  final void Function(MedicationOutcome, MedicationOutcomeStatus) onAnswer;

  const _OutcomeCheckinCard({
    required this.outcomes,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: contrastColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("¿CÓMO TE SIENTES AHORA?",
              style: TextStyle(
                  color: contrastColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          ...outcomes.map((o) {
            final hoursAgo =
                DateTime.now().difference(o.doseTimestamp).inMinutes / 60.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: contrastColor, fontSize: 13),
                      children: [
                        TextSpan(
                            text: 'Hace ${hoursAgo.toStringAsFixed(1)}h tomaste '),
                        TextSpan(
                            text: o.medicationName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' para tu '),
                        TextSpan(
                            text: o.symptomName.toLowerCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _outcomeBtn(o, MedicationOutcomeStatus.better, 'Mejor'),
                      _outcomeBtn(o, MedicationOutcomeStatus.same, 'Igual'),
                      _outcomeBtn(o, MedicationOutcomeStatus.worse, 'Peor'),
                      _outcomeBtn(o, MedicationOutcomeStatus.unknown, 'No sé'),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _outcomeBtn(MedicationOutcome o, MedicationOutcomeStatus s, String label) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: contrastColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      onPressed: () => onAnswer(o, s),
      child: Text(label,
          style: TextStyle(color: contrastColor, fontSize: 12)),
    );
  }
}
