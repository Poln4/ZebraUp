// §12 rediseño de dolor estructural + rework 18-jul-2026 (flujo
// combinado zona+tipo).
//
// Default entry point when logging pain in a zone with no saved
// StructuralZoneHistoryEntry, AND the default target of the symptom
// vault ("el baúl") free-text detector (structural_text_detector.dart)
// when it recognizes structural vocabulary. Captures zone, kind
// (general — muscular/articular/tendinoso/ligamentoso/tejido
// blando/nervioso/sin causa clara), and the 4 detail groups
// (laterality/pain character/antecedent/mechanics) — whichever of
// zone/kind is already known (from a zone-chip tap, or detected from
// typed text) is pre-filled and its step is skipped; the sheet only
// asks for what's missing. Chip content for the 4 groups lives in
// assets/symptom_definitions.json under the "structural" key, resolved
// via SymptomDefinitionsService (same mechanism already used for
// headache/fatigue/abdominal_pain). Zone and kind labels come from ARB
// via the extensions in lib/services/structural_taxonomy.dart — never
// duplicated into the JSON.
//
// Unlike headache/fatigue/abdominal, completing this funnel does NOT
// attach to a SymptomEvent — the caller (sintomas_tab.dart) builds a
// StructuralEvent with the resolved zone/kind (type resolved via
// kGenericStructuralTypeForKind in models.dart) and this StructuralDetail
// attached.
//
// Four distinct outcomes, wrapped in StructuralDetailSheetResult since
// a plain nullable return can't distinguish "skip" from "use the
// classic kind→type picker instead":
//   - Skip (or dismiss): caller does nothing.
//   - "Ya sé qué es": caller opens the existing classic picker
//     (_openStructuralMenu) for the now-resolved zone — no precedent in
//     this codebase for "pop this sheet, then open a different one", so
//     the caller owns that sequencing, this sheet only signals intent.
//   - Save: caller gets zone + kind + StructuralDetail (empty detail is
//     still a legitimate save — with zone+kind always present, "no
//     laterality/character/antecedent/mechanics selected" is no longer
//     equivalent to "nothing happened").

import 'package:flutter/material.dart';
import '../extensions/context_ext.dart';
import '../models/models.dart';
import '../models/structural_detail.dart';
import '../services/structural_taxonomy.dart';
import '../services/symptom_definitions_service.dart';
import 'body_zone_picker_grid.dart';
import 'structural_chip.dart';
import 'symptom_definition_dialog.dart';

class StructuralDetailSheetResult {
  final String? zone;
  final StructuralEventKind? kind;
  final StructuralDetail? detail;

  /// §12.6b — populated instead of [detail] when `kind == softTissue`.
  final StructuralBleedingDetail? bleedingDetail;
  final bool useClassicPicker;

  const StructuralDetailSheetResult.skip()
    : zone = null,
      kind = null,
      detail = null,
      bleedingDetail = null,
      useClassicPicker = false;

  const StructuralDetailSheetResult.save({
    required this.zone,
    required this.kind,
    this.detail,
    this.bleedingDetail,
  }) : useClassicPicker = false;

  const StructuralDetailSheetResult.classicPicker({required this.zone})
    : kind = null,
      detail = null,
      bleedingDetail = null,
      useClassicPicker = true;
}

enum _StructuralSheetStep { zone, kind, groups }

Future<StructuralDetailSheetResult?> showStructuralDetailSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  String? initialZone,
  StructuralEventKind? initialKind,
  List<String>? candidateZones,
}) async {
  await SymptomDefinitionsService.instance.ensureLoaded();
  if (!context.mounted) return null;

  return showModalBottomSheet(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (ctx) => _StructuralDetailSheetBody(
      cc: contrastColor,
      ic: inverseContrastColor,
      initialZone: initialZone,
      initialKind: initialKind,
      candidateZones: candidateZones,
    ),
  );
}

class _StructuralDetailSheetBody extends StatefulWidget {
  final Color cc;
  final Color ic;
  final String? initialZone;
  final StructuralEventKind? initialKind;
  final List<String>? candidateZones;

  const _StructuralDetailSheetBody({
    required this.cc,
    required this.ic,
    this.initialZone,
    this.initialKind,
    this.candidateZones,
  });

  @override
  State<_StructuralDetailSheetBody> createState() =>
      _StructuralDetailSheetBodyState();
}

class _StructuralDetailSheetBodyState
    extends State<_StructuralDetailSheetBody> {
  String? _zone;
  StructuralEventKind? _kind;
  late _StructuralSheetStep _step;

  StructuralLaterality? _laterality;
  StructuralPainCharacter? _painCharacter;
  StructuralAntecedent? _antecedent;
  StructuralMechanics? _mechanics;

  // §12.6b — bleeding-detail state, used instead of the 4 fields above
  // when `_kind == StructuralEventKind.softTissue`.
  BleedingOnset? _bleedingOnset;
  BleedingSeverity? _bleedingSeverity;

  // 2026-07-18 — optional free-text laterality clarification (see
  // StructuralDetail.contextNote).
  final _contextNoteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _zone = widget.initialZone;
    _kind = widget.initialKind;
    _step = _computeStep();
  }

  @override
  void dispose() {
    _contextNoteCtrl.dispose();
    super.dispose();
  }

  _StructuralSheetStep _computeStep() {
    if (_zone == null) return _StructuralSheetStep.zone;
    if (_kind == null) return _StructuralSheetStep.kind;
    return _StructuralSheetStep.groups;
  }

  StructuralDetail _buildDetail() => StructuralDetail(
    laterality: _laterality,
    painCharacter: _painCharacter,
    antecedent: _antecedent,
    mechanics: _mechanics,
    contextNote: _contextNoteCtrl.text.trim().isEmpty
        ? null
        : _contextNoteCtrl.text.trim(),
  );

  StructuralBleedingDetail _buildBleedingDetail() => StructuralBleedingDetail(
    onset: _bleedingOnset,
    severity: _bleedingSeverity,
  );

  bool _isChipSelected(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'laterality':
        final v = StructuralLaterality.fromKey(chipKey);
        return v != null && _laterality == v;
      case 'pain_character':
        final v = StructuralPainCharacter.fromKey(chipKey);
        return v != null && _painCharacter == v;
      case 'antecedent':
        final v = StructuralAntecedent.fromKey(chipKey);
        return v != null && _antecedent == v;
      case 'mechanics':
        final v = StructuralMechanics.fromKey(chipKey);
        return v != null && _mechanics == v;
      case 'bleeding_onset':
        final v = BleedingOnset.fromKey(chipKey);
        return v != null && _bleedingOnset == v;
      case 'bleeding_severity':
        final v = BleedingSeverity.fromKey(chipKey);
        return v != null && _bleedingSeverity == v;
    }
    return false;
  }

  void _handleChipTap(String groupKey, String chipKey) {
    switch (groupKey) {
      case 'laterality':
        final v = StructuralLaterality.fromKey(chipKey);
        if (v == null) return;
        setState(() => _laterality = _laterality == v ? null : v);
        break;
      case 'pain_character':
        final v = StructuralPainCharacter.fromKey(chipKey);
        if (v == null) return;
        setState(() => _painCharacter = _painCharacter == v ? null : v);
        break;
      case 'antecedent':
        final v = StructuralAntecedent.fromKey(chipKey);
        if (v == null) return;
        setState(() => _antecedent = _antecedent == v ? null : v);
        break;
      case 'mechanics':
        final v = StructuralMechanics.fromKey(chipKey);
        if (v == null) return;
        setState(() => _mechanics = _mechanics == v ? null : v);
        break;
      case 'bleeding_onset':
        final v = BleedingOnset.fromKey(chipKey);
        if (v == null) return;
        setState(() => _bleedingOnset = _bleedingOnset == v ? null : v);
        break;
      case 'bleeding_severity':
        final v = BleedingSeverity.fromKey(chipKey);
        if (v == null) return;
        setState(() => _bleedingSeverity = _bleedingSeverity == v ? null : v);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.cc;
    final ic = widget.ic;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cc.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              switch (_step) {
                _StructuralSheetStep.zone => _buildZoneStep(context, cc),
                _StructuralSheetStep.kind => _buildKindStep(context, cc),
                _StructuralSheetStep.groups => _buildGroupsStep(
                  context,
                  cc,
                  ic,
                ),
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneStep(BuildContext context, Color cc) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.structuralZonePickTitle,
          style: TextStyle(color: cc, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.structuralZonePickSubtitle,
          style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 16),
        BodyZonePickerGrid(
          contrastColor: cc,
          candidateZones: widget.candidateZones == null
              ? null
              : Set.of(widget.candidateZones!),
          onZoneTap: (zone) => setState(() {
            _zone = zone;
            _step = _computeStep();
          }),
        ),
      ],
    );
  }

  Widget _buildKindStep(BuildContext context, Color cc) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.structuralKindPickTitle,
          style: TextStyle(color: cc, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.structuralKindPickSubtitle,
          style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: StructuralEventKind.values.map((k) {
            return ActionChip(
              backgroundColor: Colors.transparent,
              side: BorderSide(color: cc.withValues(alpha: 0.6)),
              label: Text(
                k.label(l10n),
                style: TextStyle(color: cc, fontSize: 13),
              ),
              onPressed: () => setState(() {
                _kind = k;
                _step = _computeStep();
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGroupsStep(BuildContext context, Color cc, Color ic) {
    final l10n = context.l10n;
    final locale = l10n.localeName;
    final svc = SymptomDefinitionsService.instance;
    final zone = _zone!;
    final kind = _kind!;
    // §12.6b — tejido blando no encaja en los 4 grupos de dolor
    // (lateralidad/carácter/antecedente/mecánica no describen bien un
    // hematoma o un corte); usa Origen + Gravedad (ISTH-BAT adaptado)
    // en su lugar. Ver docs/design_decisions/symptom_detail_layers.md §12.6b.
    final isBleeding = kind == StructuralEventKind.softTissue;
    final groupKeys = isBleeding
        ? const ['bleeding_onset', 'bleeding_severity']
        : const ['laterality', 'pain_character', 'antecedent', 'mechanics'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with info button (opens master definition)
        Row(
          children: [
            Expanded(
              child: Text(
                isBleeding
                    ? l10n.structuralBleedingSheetTitle
                    : l10n.structuralSheetTitle,
                style: TextStyle(
                  color: cc,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: cc.withValues(alpha: 0.7),
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: l10n.actionUnderstood,
              onPressed: () => showSymptomDefinitionDialog(
                context: context,
                symptomKey: 'structural',
                contrastColor: cc,
                inverseContrastColor: ic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isBleeding
              ? l10n.structuralBleedingSheetSubtitle
              : l10n.structuralSheetSubtitle,
          style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 8),
        // Passive confirmation of the zone+kind resolved by the
        // previous steps (or pre-filled from a chip tap / vault
        // detection) — lets the user notice a misdetection before
        // saving, since the vault path can silently pre-fill both.
        Text(
          '${zone.bodyZoneLabel(l10n)} · ${kind.label(l10n)}',
          style: TextStyle(color: cc, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // "Ya sé qué es" — prominent shortcut to the classic
        // kind→tipo picker, for users who already know the
        // clinical term. Same visual weight as the funnel's own
        // Skip button below (§3 item 6 — Saltar prominente).
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: cc, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => Navigator.pop(
            context,
            StructuralDetailSheetResult.classicPicker(zone: zone),
          ),
          child: Text(
            l10n.structuralKnownTermShortcut,
            style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 20),

        // Groups for this kind (4 pain groups, or Origen+Gravedad for
        // tejido blando) — subset of svc.getGroupKeysInOrder('structural').
        ...groupKeys.map((groupKey) {
          final header =
              svc.getGroupHeader('structural', groupKey, locale) ?? groupKey;
          final chipKeys = svc.getChipKeysInOrder('structural', groupKey);
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    header,
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.55),
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: chipKeys.map((chipKey) {
                    final chipLabel =
                        svc.getChipLabel('structural', groupKey, chipKey, locale) ??
                        chipKey;
                    final isSelected = _isChipSelected(groupKey, chipKey);
                    return StructuralChip(
                      label: chipLabel,
                      selected: isSelected,
                      cc: cc,
                      ic: ic,
                      onToggle: () => _handleChipTap(groupKey, chipKey),
                      onInfo: () => showSymptomDefinitionDialog(
                        context: context,
                        symptomKey: 'structural',
                        groupKey: groupKey,
                        chipKey: chipKey,
                        contrastColor: cc,
                        inverseContrastColor: ic,
                      ),
                    );
                  }).toList(),
                ),
                // 2026-07-18 — optional laterality context note: picking
                // a side doesn't always pin down which zone(s) it
                // covers ("me duele el lado derecho" can be broader or
                // narrower than the precise zone already chosen).
                if (groupKey == 'laterality') ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contextNoteCtrl,
                    style: TextStyle(color: cc, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: l10n.structuralContextZoneLabel,
                      labelStyle: TextStyle(
                        color: cc.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                      hintText: l10n.structuralContextZoneHint,
                      hintStyle: TextStyle(
                        color: cc.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: cc.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),

        const SizedBox(height: 4),

        // Footer: Skip (prominent, secondary) + Save (primary)
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cc, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(
                  context,
                  const StructuralDetailSheetResult.skip(),
                ),
                child: Text(
                  l10n.actionSkip,
                  style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cc,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (isBleeding) {
                    final bleedingDetail = _buildBleedingDetail();
                    Navigator.pop(
                      context,
                      StructuralDetailSheetResult.save(
                        zone: zone,
                        kind: kind,
                        bleedingDetail: bleedingDetail.isEmpty
                            ? null
                            : bleedingDetail,
                      ),
                    );
                    return;
                  }
                  final detail = _buildDetail();
                  Navigator.pop(
                    context,
                    StructuralDetailSheetResult.save(
                      zone: zone,
                      kind: kind,
                      detail: detail.isEmpty ? null : detail,
                    ),
                  );
                },
                child: Text(
                  l10n.actionSave,
                  style: TextStyle(color: ic, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

