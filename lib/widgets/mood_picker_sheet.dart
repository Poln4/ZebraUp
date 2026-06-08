import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

/// Foxtale-style mood picker.
/// Step 1: pick a quadrant. Step 2: multi-select state palette, optionally
/// cross quadrants, optionally set intensity. Returns a MoodEntry or null.
Future<MoodEntry?> showMoodPickerSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
}) {
  return showModalBottomSheet<MoodEntry>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(side: BorderSide(color: contrastColor, width: 2)),
    builder: (_) => _MoodPickerSheetBody(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
    ),
  );
}

class _MoodPickerSheetBody extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  const _MoodPickerSheetBody({
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  @override
  State<_MoodPickerSheetBody> createState() => _MoodPickerSheetBodyState();
}

class _MoodPickerSheetBodyState extends State<_MoodPickerSheetBody> {
  MoodQuadrant? _primary;
  final Set<String> _selected = {};
  bool _showOthers = false;
  bool _showIntensity = false;
  int _intensity = 3;

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;

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
        intensity: _showIntensity ? _intensity : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    final primaryWords = kMoodVocabulary[primary]!;
    final otherWords = kMoodVocabulary.entries
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
                }),
                child: Text("cambiar",
                    style: TextStyle(color: _cc.withValues(alpha: 0.7), fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: primaryWords.map(_chip).toList(),
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
          Text("TAMBIÉN SIENTO…",
              style: TextStyle(
                  color: _cc.withValues(alpha: 0.6),
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: otherWords.map(_chip).toList()),
        ],
        const SizedBox(height: 16),
        if (!_showIntensity)
          TextButton(
            onPressed: () => setState(() => _showIntensity = true),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
            child: Text("+ ajustar intensidad (opcional)",
                style: TextStyle(color: _cc.withValues(alpha: 0.7), fontSize: 12)),
          )
        else ...[
          Text("INTENSIDAD GENERAL",
              style: TextStyle(
                  color: _cc.withValues(alpha: 0.6),
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) {
              final v = i + 1;
              final selected = _intensity == v;
              return InkWell(
                onTap: () => setState(() => _intensity = v),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? _cc : Colors.transparent,
                      border: Border.all(color: _cc, width: selected ? 0 : 1),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _cc,
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _selected.isEmpty ? null : _save,
          child: Text("GUARDAR", style: TextStyle(color: _ic, fontWeight: FontWeight.bold)),
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

  Widget _chip(String word) {
    final selected = _selected.contains(word);
    return InkWell(
      onTap: () => _toggle(word),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _cc : Colors.transparent,
          border: Border.all(color: selected ? _cc : _cc.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(word,
            style: TextStyle(
              color: selected ? _ic : _cc,
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );
  }
}

// =============================================================================
// MoodSection — drop this into HoyTab where the old three-slider chunk was.
// =============================================================================

class MoodSection extends StatelessWidget {
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final void Function({
    required MoodQuadrant primaryQuadrant,
    required List<String> states,
    int? intensity,
  }) onLogMood;
  final void Function(MoodEntry) onDeleteMood;

  const MoodSection({
    super.key,
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
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
            );
            if (entry != null) {
              onLogMood(
                primaryQuadrant: entry.primaryQuadrant,
                states: entry.states,
                intensity: entry.intensity,
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
            decoration: BoxDecoration(border: Border.all(color: cc.withValues(alpha: 0.4))),
            child: Column(
              children: todaysMoods.map((entry) {
                final timeStr = DateFormat('HH:mm').format(entry.timestamp);
                final statesStr = entry.states.join(', ');
                final intensityStr =
                    entry.intensity != null ? ' · int. ${entry.intensity}/5' : '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: cc.withValues(alpha: 0.5), size: 8),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text("[$timeStr] $statesStr$intensityStr",
                            style: TextStyle(color: cc, fontSize: 13)),
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