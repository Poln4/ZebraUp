import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/mood_localizations.dart';

/// Foxtale/Zebra-style mood picker.
///
/// Step 1: pick a primary quadrant (2D circumplex of valence × arousal).
/// Step 2: the primary palette is expanded by default; the three remaining
/// quadrants appear below as collapsible sections (initially collapsed,
/// each tap on its header expands). All quadrants are reachable from the
/// same step because emotions are not unidirectional — someone can feel
/// tired + frustrated + grateful within the same window.
///
/// Selection is keyed by English term (stable across locales), display
/// uses `EmaMood.label(localeCode)` with English fallback when the
/// localized string is empty. Definitions open via the `info_outline`
/// icon only; long-press was removed in mental tracker Batch 2 to avoid
/// gesture collision with mobile scrolling.
Future<MoodEntry?> showMoodPickerSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required Map<MoodQuadrant, List<EmaMood>> moodDictionary,
}) {
  return showModalBottomSheet<MoodEntry>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
        side: BorderSide(color: contrastColor, width: 2)),
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

  /// Selected mood IDs, keyed by `EmaMood.english` for cross-locale
  /// stability. The English term is always populated by the JSON so it
  /// works as a unique identifier even when other locales have empty
  /// fields.
  final Set<String> _selectedEnglish = {};

  /// Which non-primary quadrants are currently expanded in step 2.
  final Set<MoodQuadrant> _expandedSecondaries = {};

  final TextEditingController _notesController = TextEditingController();

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggle(EmaMood mood) => setState(() {
        if (_selectedEnglish.contains(mood.english)) {
          _selectedEnglish.remove(mood.english);
        } else {
          _selectedEnglish.add(mood.english);
        }
      });

  void _toggleSecondary(MoodQuadrant q) => setState(() {
        if (_expandedSecondaries.contains(q)) {
          _expandedSecondaries.remove(q);
        } else {
          _expandedSecondaries.add(q);
        }
      });

  /// Resolves the selected English IDs to localized strings (in the
  /// active locale) before persisting, so `MoodEntry.states` stays in
  /// the user's chosen language and the historical view reads naturally.
  void _save() {
    if (_primary == null || _selectedEnglish.isEmpty) return;
    final localeCode = Localizations.localeOf(context).languageCode;

    // Build a lookup table of all moods so we can resolve each selected
    // English ID to its localized label. Fallback chain (handled inside
    // EmaMood.label) ensures we never store an empty string.
    final allMoods = <String, EmaMood>{};
    for (final list in widget.moodDictionary.values) {
      for (final m in list) {
        allMoods[m.english] = m;
      }
    }

    final localizedStates = _selectedEnglish
        .map((en) => allMoods[en]?.label(localeCode) ?? en)
        .toList();

    Navigator.pop(
      context,
      MoodEntry(
        timestamp: DateTime.now(),
        primaryQuadrant: _primary!,
        states: localizedStates,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      ),
    );
  }

  void _showDefinitionDialog(EmaMood mood) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _ic,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _cc, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          mood.label(localeCode).toUpperCase(),
          style: TextStyle(
              color: _cc, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          mood.definition(localeCode),
          style: TextStyle(color: _cc, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.moodDefinitionDialogAction,
                style: TextStyle(color: _cc, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Keep the notes field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: _primary == null ? _step1() : _step2(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1 — quadrant picker
  // ---------------------------------------------------------------------------

  Widget _step1() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.moodSheetStep1Title,
          style: TextStyle(
              color: _cc,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1),
        ),
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
            child: Text(l10n.moodSheetCancel,
                style: TextStyle(color: _cc.withValues(alpha: 0.6))),
          ),
        ),
      ],
    );
  }

  Widget _quadrantCard(MoodQuadrant q) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => setState(() {
        _primary = q;
        _selectedEnglish.clear();
        _expandedSecondaries.clear();
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
            Text(q.quadrantLabel(l10n),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _cc.withValues(alpha: 0.6),
                    fontSize: 10,
                    letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(q.quadrantTeaser(l10n),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _cc, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2 — primary palette + collapsible secondaries
  // ---------------------------------------------------------------------------

  Widget _step2() {
    final l10n = AppLocalizations.of(context)!;
    final primary = _primary!;
    final primaryMoods = widget.moodDictionary[primary] ?? const <EmaMood>[];
    final secondaryQuadrants = MoodQuadrant.values
        .where((q) => q != primary)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _primaryHeader(primary, l10n),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: primaryMoods.map(_chip).toList(),
        ),
        const SizedBox(height: 20),

        // Secondary quadrants — each one a collapsible section.
        Text(
          l10n.moodSheetAlsoFeelingHeader,
          style: TextStyle(
              color: _cc.withValues(alpha: 0.6),
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...secondaryQuadrants
            .map((q) => _secondarySection(q, l10n))
            .toList(),

        const SizedBox(height: 24),

        // Context / notes section.
        Text(
          l10n.moodSheetNotesHeader,
          style: TextStyle(
              color: _cc.withValues(alpha: 0.6),
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(color: _cc, fontSize: 14),
          decoration: InputDecoration(
            hintText: l10n.moodSheetNotesPlaceholder,
            hintStyle: TextStyle(color: _cc.withValues(alpha: 0.3)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _cc,
            minimumSize: const Size.fromHeight(48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: _selectedEnglish.isEmpty ? null : _save,
          child: Text(l10n.moodSheetSaveButton,
              style: TextStyle(color: _ic, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.moodSheetCancel,
                style: TextStyle(color: _cc.withValues(alpha: 0.6))),
          ),
        ),
      ],
    );
  }

  Widget _primaryHeader(MoodQuadrant primary, AppLocalizations l10n) {
    return Container(
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
                Text(primary.quadrantLabel(l10n),
                    style: TextStyle(
                        color: _cc.withValues(alpha: 0.6), fontSize: 10)),
                Text(l10n.moodSheetStep2Prompt,
                    style: TextStyle(
                        color: _cc,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _primary = null;
              _selectedEnglish.clear();
              _expandedSecondaries.clear();
              _notesController.clear();
            }),
            child: Text(l10n.moodSheetChangeQuadrant,
                style: TextStyle(
                    color: _cc.withValues(alpha: 0.7), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _secondarySection(MoodQuadrant q, AppLocalizations l10n) {
    final isExpanded = _expandedSecondaries.contains(q);
    final moods = widget.moodDictionary[q] ?? const <EmaMood>[];
    // Selection count for this quadrant — shown in the header so the
    // user knows they have items there even when the section is folded.
    final selectedInThis = moods
        .where((m) => _selectedEnglish.contains(m.english))
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _toggleSecondary(q),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: _cc.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: _cc.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      q.quadrantLabel(l10n),
                      style: TextStyle(
                          color: _cc,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3),
                    ),
                  ),
                  if (selectedInThis > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _cc,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$selectedInThis',
                        style: TextStyle(
                            color: _ic,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 4, left: 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: moods.map(_chip).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Chip — locale-aware label, English fallback for missing zh-TW
  // ---------------------------------------------------------------------------

  Widget _chip(EmaMood mood) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final label = mood.label(localeCode);
    final selected = _selectedEnglish.contains(mood.english);

    final textColor = selected ? _ic : _cc;
    final borderColor = selected ? _cc : _cc.withValues(alpha: 0.4);
    final iconColor =
        selected ? _ic.withValues(alpha: 0.8) : _cc.withValues(alpha: 0.6);

    return InkWell(
      onTap: () => _toggle(mood),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding:
            const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
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
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Single gesture for the definition dialog — long-press was
            // removed in mental tracker Batch 2 to avoid scroll collision.
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
// MoodSection — day view component
// =============================================================================

class MoodSection extends StatelessWidget {
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final Map<MoodQuadrant, List<EmaMood>> moodDictionary;
  final void Function({
    required MoodQuadrant primaryQuadrant,
    required List<String> states,
    String? notes,
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
    final l10n = AppLocalizations.of(context)!;
    final todaysMoods = profile.getMoodForDay(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.moodSectionTitle,
            style: TextStyle(
                color: cc,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final entry = await showMoodPickerSheet(
              context: context,
              contrastColor: contrastColor,
              inverseContrastColor: inverseContrastColor,
              moodDictionary: moodDictionary,
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
                        ? l10n.moodSectionPrompt
                        : l10n.moodSectionRegisterAnother,
                    style: TextStyle(
                        color: cc,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(Icons.circle,
                            color: cc.withValues(alpha: 0.5), size: 8),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("[$timeStr] $statesStr",
                                style: TextStyle(
                                    color: cc,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            if (entry.notes != null &&
                                entry.notes!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(entry.notes!,
                                  style: TextStyle(
                                      color: cc.withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                            ]
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.red, size: 18),
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