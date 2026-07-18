// =============================================================================
// HydrationFormSheet — log or edit a HydrationEntry.
//
// Phase F6.b + Hydration module (17-jun-2026). Modal bottom sheet matching
// the SleepFormSheet style. Fields: timestamp picker → volume (ml) →
// beverage chips (4) → sodium chips (3, optional) → note → save.
//
// HydrationBeverageLocalization + SodiumSourceLocalization extensions
// live in this file (single consumer). When a Hoy chip or report
// integration is added, refactor out to a service file.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../screens/timestamp_picker.dart';
import '../extensions/context_ext.dart';
import '../l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
// i18n extensions (canonical FeverSiteLocalization pattern)
// -----------------------------------------------------------------------------

extension HydrationBeverageLocalization on HydrationBeverage {
  String label(AppLocalizations l10n) => switch (this) {
    HydrationBeverage.water => l10n.beverageWater,
    HydrationBeverage.electrolyte => l10n.beverageElectrolyte,
    HydrationBeverage.coffee => l10n.beverageCoffee,
    HydrationBeverage.other => l10n.beverageOther,
  };
}

extension SodiumSourceLocalization on SodiumSource {
  String label(AppLocalizations l10n) => switch (this) {
    SodiumSource.pinch => l10n.sodiumPinch,
    SodiumSource.sachet => l10n.sodiumSachet,
    SodiumSource.saltySnack => l10n.sodiumSaltySnack,
  };
}

// -----------------------------------------------------------------------------
// Public API
// -----------------------------------------------------------------------------

Future<HydrationEntry?> showHydrationFormSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  required DateTime defaultTimestamp,
  HydrationEntry? existing,
  List<String> customBeverages = const [],
  ValueChanged<String>? onAddCustomBeverage,
}) {
  return showModalBottomSheet<HydrationEntry>(
    context: context,
    backgroundColor: inverseContrastColor,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    isScrollControlled: true,
    builder: (ctx) => _HydrationForm(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      defaultTimestamp: defaultTimestamp,
      existing: existing,
      customBeverages: customBeverages,
      onAddCustomBeverage: onAddCustomBeverage,
    ),
  );
}

// -----------------------------------------------------------------------------
// Form widget
// -----------------------------------------------------------------------------

class _HydrationForm extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final DateTime defaultTimestamp;
  final HydrationEntry? existing;
  final List<String> customBeverages;
  final ValueChanged<String>? onAddCustomBeverage;

  const _HydrationForm({
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.defaultTimestamp,
    this.existing,
    this.customBeverages = const [],
    this.onAddCustomBeverage,
  });

  @override
  State<_HydrationForm> createState() => _HydrationFormState();
}

class _HydrationFormState extends State<_HydrationForm> {
  late DateTime _timestamp;
  late TextEditingController _volumeCtrl;
  late HydrationBeverage? _beverage;
  late String? _customBeverage;
  late SodiumSource? _sodium;
  late TextEditingController _noteCtrl;
  late TextEditingController _newBeverageCtrl;
  late List<String> _customBeverages;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _timestamp = e?.timestamp ?? widget.defaultTimestamp;
    _volumeCtrl = TextEditingController(
      text: e?.volumeMl != null ? e!.volumeMl!.round().toString() : '',
    );
    _customBeverage = e?.customBeverageName;
    _beverage = _customBeverage != null
        ? null
        : (e?.beverage ?? HydrationBeverage.water);
    _sodium = e?.sodium;
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _newBeverageCtrl = TextEditingController();
    _customBeverages = List<String>.from(widget.customBeverages);
  }

  @override
  void dispose() {
    _volumeCtrl.dispose();
    _noteCtrl.dispose();
    _newBeverageCtrl.dispose();
    super.dispose();
  }

  void _addCustomBeverage() {
    final name = _newBeverageCtrl.text.trim();
    if (name.isEmpty) return;
    if (!_customBeverages.contains(name)) {
      setState(() => _customBeverages.add(name));
      widget.onAddCustomBeverage?.call(name);
    }
    setState(() {
      _customBeverage = name;
      _beverage = null;
    });
    _newBeverageCtrl.clear();
  }

  Color get _cc => widget.contrastColor;
  Color get _ic => widget.inverseContrastColor;

  double? _parseVolume() {
    final raw = _volumeCtrl.text.trim();
    if (raw.isEmpty) return null;
    final v = double.tryParse(raw);
    if (v == null || v <= 0 || v > 5000) return null;
    return v;
  }

  void _save() {
    final note = _noteCtrl.text.trim();
    final result = HydrationEntry(
      id: widget.existing?.id,
      timestamp: _timestamp,
      volumeMl: _parseVolume(),
      beverage: _customBeverage == null ? _beverage : null,
      sodium: _sodium,
      note: note.isEmpty ? null : note,
      customBeverageName: _customBeverage,
    );
    Navigator.pop(context, result);
  }

  Widget _chip({
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _cc : Colors.transparent,
          border: Border.all(
            color: _cc.withValues(alpha: selected ? 1.0 : 0.4),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _ic : _cc.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = widget.existing != null
        ? l10n.hydrationModalEditHeader
        : l10n.hydrationModalLogHeader;

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
            const SizedBox(height: 20),

            // Volume
            Text(
              l10n.hydrationFieldVolumeLabel,
              style: TextStyle(
                color: _cc.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _volumeCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: _cc),
              decoration: InputDecoration(
                hintText: l10n.hydrationFieldVolumeHint,
                hintStyle: const TextStyle(color: Colors.grey),
                suffixText: 'ml',
              ),
            ),
            const SizedBox(height: 20),

            // Beverage
            Text(
              l10n.hydrationFieldBeverageLabel,
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
                ...HydrationBeverage.values.map(
                  (b) => _chip(
                    selected: _customBeverage == null && _beverage == b,
                    label: b.label(l10n),
                    onTap: () => setState(() {
                      _beverage = b;
                      _customBeverage = null;
                    }),
                  ),
                ),
                ..._customBeverages.map(
                  (name) => _chip(
                    selected: _customBeverage == name,
                    label: name,
                    onTap: () => setState(() {
                      _customBeverage = name;
                      _beverage = null;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newBeverageCtrl,
                    style: TextStyle(color: _cc, fontSize: 13),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addCustomBeverage(),
                    decoration: InputDecoration(
                      hintText: l10n.hydrationBeverageAddCustomHint,
                      hintStyle: const TextStyle(color: Colors.grey),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: _cc),
                  onPressed: _addCustomBeverage,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sodium (optional)
            Text(
              l10n.hydrationFieldSodiumLabel,
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
              children: SodiumSource.values
                  .map(
                    (s) => _chip(
                      selected: _sodium == s,
                      label: s.label(l10n),
                      onTap: () => setState(() {
                        _sodium = (_sodium == s) ? null : s;
                      }),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Note
            TextField(
              controller: _noteCtrl,
              style: TextStyle(color: _cc),
              decoration: InputDecoration(
                hintText: l10n.symptomsLabelOptionalNoteSimple,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _cc,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _save,
              child: Text(
                l10n.symptomsActionSave,
                style: TextStyle(color: _ic, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
