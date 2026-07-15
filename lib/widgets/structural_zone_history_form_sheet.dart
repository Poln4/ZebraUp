// §12.6 — Structural zone history form sheet.
//
// Records a known/chronic structural antecedent for a body zone (e.g.
// "Rodilla derecha: post-quirúrgica, 2 cirugías"), entered once and
// reused afterward as a shortcut — see structural_quick_log_sheet.dart.
// Pattern calcado de life_event_form_sheet.dart: a plain returning
// bottom sheet, no wiring back into a callback.
//
// Two entry points:
//   - From a specific zone (post-funnel "guardar esto como algo que ya
//     conozco" offer): `initialZone` is set, zone shown read-only.
//   - From Ajustes → Perfil ("Agregar antecedente"): `initialZone` is
//     null, a flat zone dropdown is shown (kBodyZones, not grouped by
//     BodyRegion — this is a secondary management path, not the
//     primary zone-tap flow, so a simple flat list is a reasonable
//     trade-off against building a second grouped picker UI).
//
// `kind` is restricted to the 6 classic StructuralEventKind values —
// the 7th (painWithoutClearCause) has no "known antecedent" by
// definition (see models.dart §12.5 doc comment).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../extensions/context_ext.dart';
import '../models/models.dart';
import '../services/structural_taxonomy.dart';

const _kClassicStructuralKinds = <StructuralEventKind>[
  StructuralEventKind.joint,
  StructuralEventKind.muscle,
  StructuralEventKind.tendon,
  StructuralEventKind.ligament,
  StructuralEventKind.softTissue,
  StructuralEventKind.nerve,
];

/// Returns the new/updated entry, or null if cancelled.
Future<StructuralZoneHistoryEntry?> showStructuralZoneHistoryFormSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  String? initialZone,
  StructuralZoneHistoryEntry? existing,
}) {
  return showModalBottomSheet<StructuralZoneHistoryEntry>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (_) => _StructuralZoneHistoryFormBody(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      initialZone: initialZone,
      existing: existing,
    ),
  );
}

class _StructuralZoneHistoryFormBody extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final String? initialZone;
  final StructuralZoneHistoryEntry? existing;

  const _StructuralZoneHistoryFormBody({
    required this.contrastColor,
    required this.inverseContrastColor,
    this.initialZone,
    this.existing,
  });

  @override
  State<_StructuralZoneHistoryFormBody> createState() =>
      _StructuralZoneHistoryFormBodyState();
}

class _StructuralZoneHistoryFormBodyState
    extends State<_StructuralZoneHistoryFormBody> {
  late TextEditingController _descriptionCtrl;
  late String _zone;
  late StructuralEventKind _kind;
  DateTime? _approximateDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _zone = e?.zone ?? widget.initialZone ?? kBodyZones.first;
    _kind = e?.kind ?? _kClassicStructuralKinds.first;
    _descriptionCtrl = TextEditingController(text: e?.description ?? '');
    _approximateDate = e?.approximateDate;
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _approximateDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _approximateDate = picked);
  }

  void _save() {
    final description = _descriptionCtrl.text.trim();
    if (description.isEmpty) return;
    final result = StructuralZoneHistoryEntry(
      id: widget.existing?.id,
      zone: _zone,
      kind: _kind,
      description: description,
      approximateDate: _approximateDate,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;
    final isEdit = widget.existing != null;
    final zoneIsFixed = widget.initialZone != null || isEdit;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit
                    ? l10n.structuralZoneHistoryFormEditTitle
                    : l10n.structuralZoneHistoryFormTitle,
                style: TextStyle(
                  color: cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                l10n.structuralZoneHistoryZoneLabel,
                style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
              ),
              const SizedBox(height: 4),
              if (zoneIsFixed)
                Text(
                  _zone.bodyZoneLabel(l10n),
                  style: TextStyle(
                    color: cc,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: cc)),
                  child: DropdownButton<String>(
                    value: _zone,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    dropdownColor: ic,
                    style: TextStyle(color: cc, fontSize: 13),
                    iconEnabledColor: cc,
                    items: kBodyZones.map((z) {
                      return DropdownMenuItem<String>(
                        value: z,
                        child: Text(z.bodyZoneLabel(l10n)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _zone = v);
                    },
                  ),
                ),
              const SizedBox(height: 16),

              Text(
                l10n.structuralZoneHistoryKindLabel,
                style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: cc)),
                child: DropdownButton<StructuralEventKind>(
                  value: _kind,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  dropdownColor: ic,
                  style: TextStyle(color: cc, fontSize: 13),
                  iconEnabledColor: cc,
                  items: _kClassicStructuralKinds.map((k) {
                    return DropdownMenuItem<StructuralEventKind>(
                      value: k,
                      child: Text(k.label(l10n)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _kind = v);
                  },
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _descriptionCtrl,
                autofocus: !isEdit,
                maxLines: 2,
                style: TextStyle(color: cc),
                decoration: InputDecoration(
                  hintText: l10n.structuralZoneHistoryDescriptionHint,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cc.withValues(alpha: 0.5)),
                ),
                icon: Icon(Icons.calendar_today, color: cc, size: 14),
                label: Text(
                  _approximateDate == null
                      ? l10n.structuralZoneHistoryDateLabel
                      : DateFormat('d MMM yyyy').format(_approximateDate!),
                  style: TextStyle(color: cc, fontSize: 12),
                ),
                onPressed: _pickDate,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cc,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _save,
                child: Text(
                  l10n.structuralZoneHistorySaveAction,
                  style: TextStyle(color: ic, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.actionCancel,
                    style: TextStyle(color: cc.withValues(alpha: 0.6)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
