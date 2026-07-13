// =============================================================================
// BowelFormSheet — log or edit a BowelEvent.
//
// Modal bottom sheet matching the existing structural / symptom modal style
// in sintomas_tab.dart. Layout: timestamp -> 3-bucket picker -> optional
// 7-pt Bristol detail -> severity dots -> observation chips -> note -> save.
//
// Returns the new/edited BowelEvent (caller persists). Returns null if the
// user dismisses the sheet without saving.
//
// i18n Batch A.2: fully localized. All user-facing strings now resolve
// via AppLocalizations and the BowelBucketLocalization extension from
// clinical_localizations.dart. The Bristol legend uses an ICU template
// so each locale can rearrange the bucket-name positions if grammar
// requires it. Vocabulary remains neutral LatAm tuteo — no Castilian,
// no Rioplatense, no Chilean slang.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../screens/timestamp_picker.dart';
import '../services/clinical_localizations.dart';
import 'severity_picker.dart';

/// Opens the bowel form sheet.
///
/// `existing` is non-null only when editing. `prefilledBucket` is used when
/// the user tapped one of the 3 bucket cards on the Sintomas tab — the sheet
/// opens with that bucket pre-selected but the user can change it.
Future<BowelEvent?> showBowelFormSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required DateTime defaultTimestamp,
  BowelEvent? existing,
  BowelBucket? prefilledBucket,
}) {
  return showModalBottomSheet<BowelEvent>(
    context: context,
    backgroundColor: inverseContrastColor,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    isScrollControlled: true,
    builder: (ctx) => _BowelForm(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      defaultTimestamp: defaultTimestamp,
      existing: existing,
      prefilledBucket: prefilledBucket,
    ),
  );
}

class _BowelForm extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final DateTime defaultTimestamp;
  final BowelEvent? existing;
  final BowelBucket? prefilledBucket;

  const _BowelForm({
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.defaultTimestamp,
    this.existing,
    this.prefilledBucket,
  });

  @override
  State<_BowelForm> createState() => _BowelFormState();
}

class _BowelFormState extends State<_BowelForm> {
  late DateTime _timestamp;
  BowelBucket? _bucket;
  int? _bristolType;
  late SymptomSeverity _severity;
  late bool _urgency;
  late bool _bloodPresent;
  late bool _incompleteEvacuation;
  late TextEditingController _noteCtrl;
  bool _showBristol = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _timestamp = e?.timestamp ?? widget.defaultTimestamp;
    _bucket = e?.bucket ?? widget.prefilledBucket;
    _bristolType = e?.bristolType;
    _severity = e?.severity ?? SymptomSeverity.none;
    _urgency = e?.urgency ?? false;
    _bloodPresent = e?.bloodPresent ?? false;
    _incompleteEvacuation = e?.incompleteEvacuation ?? false;
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _showBristol = _bristolType != null;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;

  /// Map a Bristol Stool Scale type (1-7) to its 3-tier bucket.
  /// Source: Dale et al. (2024) — patient-expert agreement on bucket
  /// collapse is substantial.
  BowelBucket _bucketFromBristol(int bss) {
    if (bss <= 2) return BowelBucket.constipation;
    if (bss <= 5) return BowelBucket.normal;
    return BowelBucket.diarrhea;
  }

  void _save() {
    if (_bucket == null) return;
    final note = _noteCtrl.text.trim();
    final result = BowelEvent(
      // Preserve id on edit so list lookups by `indexOf` continue to work.
      id: widget.existing?.id,
      timestamp: _timestamp,
      bucket: _bucket!,
      bristolType: _bristolType,
      severity: _severity,
      urgency: _urgency,
      bloodPresent: _bloodPresent,
      incompleteEvacuation: _incompleteEvacuation,
      photoPath: widget.existing?.photoPath, // preserve any future-set value
      note: note.isEmpty ? null : note,
    );
    Navigator.pop(context, result);
  }

  // i18n Batch A.2: card now takes the BowelBucket and resolves its label
  // internally via BowelBucketLocalization. No more hardcoded Spanish
  // `label` string parameter from the caller.
  Widget _bucketCard(BowelBucket bucket, IconData icon, AppLocalizations l10n) {
    final selected = _bucket == bucket;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _bucket = bucket;
          // If user changes bucket directly, clear conflicting BSS detail.
          if (_bristolType != null &&
              _bucketFromBristol(_bristolType!) != bucket) {
            _bristolType = null;
          }
        }),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? _cc : Colors.transparent,
            border: Border.all(
              color: _cc.withValues(alpha: selected ? 1.0 : 0.4),
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? _ic : _cc, size: 32),
              const SizedBox(height: 6),
              Text(
                bucket.bowelBucketLabel(l10n),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? _ic : _cc,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bristolPicker(AppLocalizations l10n) {
    // Resolve the three bucket labels once for use in the inline legend.
    final cLabel = BowelBucket.constipation.bowelBucketLabel(l10n);
    final nLabel = BowelBucket.normal.bowelBucketLabel(l10n);
    final dLabel = BowelBucket.diarrhea.bowelBucketLabel(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bowelFormBristolLabel,
          style: TextStyle(
            color: _cc.withValues(alpha: 0.6),
            fontSize: 11,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(7, (i) {
            final n = i + 1;
            final selected = _bristolType == n;
            final bucket = _bucketFromBristol(n);
            // Use bucket-aware accent so the user reads the BSS row's shape.
            final accent = switch (bucket) {
              BowelBucket.constipation => const Color(0xFFFFD54F),
              BowelBucket.normal => const Color(0xFF81C784),
              BowelBucket.diarrhea => const Color(0xFFE57373),
            };
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => setState(() {
                    _bristolType = n;
                    _bucket = bucket;
                  }),
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected ? accent : accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected ? accent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$n',
                      style: TextStyle(
                        color: selected ? Colors.black87 : _cc,
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
        const SizedBox(height: 4),
        Text(
          l10n.bowelFormBristolLegendTemplate(cLabel, nLabel, dLabel),
          style: TextStyle(
            color: _cc.withValues(alpha: 0.5),
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _toggleChip(String label, bool active, ValueChanged<bool> onTap) {
    return InkWell(
      onTap: () => onTap(!active),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _cc : Colors.transparent,
          border: Border.all(color: _cc.withValues(alpha: active ? 1.0 : 0.4)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? _ic : _cc.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.existing != null;
    final title = isEdit ? l10n.bowelFormTitleEdit : l10n.bowelFormTitleNew;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
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
                DateFormat('EEE d MMM, HH:mm').format(_timestamp),
                style: TextStyle(color: _cc, fontSize: 12),
              ),
              onPressed: () async {
                final picked = await pickTimestamp(
                  context: context,
                  initial: _timestamp,
                  contrastColor: _cc,
                  inverseContrastColor: _ic,
                );
                if (picked != null) setState(() => _timestamp = picked);
              },
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _showBristol = !_showBristol),
                icon: Icon(
                  _showBristol ? Icons.expand_less : Icons.expand_more,
                  color: _cc.withValues(alpha: 0.6),
                  size: 16,
                ),
                label: Text(
                  _showBristol
                      ? l10n.bowelFormHideBristolDetail
                      : l10n.bowelFormShowBristolDetail,
                  style: TextStyle(
                    color: _cc.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (_showBristol) ...[
              _bristolPicker(l10n),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 8),
            Text(
              l10n.formSectionHeaderDiscomfort,
              style: TextStyle(
                color: _cc.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            SeverityDotPicker(
              selected: _severity,
              showLabels: true,
              onSelect: (s) => setState(() => _severity = s),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.bowelFormSectionObservations,
              style: TextStyle(
                color: _cc.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _toggleChip(
                  l10n.bowelFormToggleUrgency,
                  _urgency,
                  (v) => setState(() => _urgency = v),
                ),
                _toggleChip(
                  l10n.formToggleBleeding,
                  _bloodPresent,
                  (v) => setState(() => _bloodPresent = v),
                ),
                _toggleChip(
                  l10n.bowelFormToggleIncompleteEvacuation,
                  _incompleteEvacuation,
                  (v) => setState(() => _incompleteEvacuation = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              style: TextStyle(color: _cc),
              decoration: InputDecoration(
                hintText: l10n.bowelFormNoteHint,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _cc,
                disabledBackgroundColor: _cc.withValues(alpha: 0.2),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _bucket == null ? null : _save,
              child: Text(
                l10n.formButtonSave,
                style: TextStyle(color: _ic, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
