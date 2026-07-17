// Sprint P.C — Profile settings, split out of the monolithic settings
// Drawer (main_screen.dart _buildSettingsDrawer, ~824 lines covering
// profile identity, tracking toggles, language, and account data all
// in one flat scroll). This screen owns profile identity: name, date
// of birth, conditions, allergies, relationship, life events,
// location, and the add/delete-profile actions.
//
// dateOfBirth/allergies were added to Profile in Phase4.A (PDF export)
// as additive fields with no edit UI yet — this is that UI.
// emergencyContacts (also added in Phase4.A) intentionally has no UI
// here yet; see CLAUDE.md Fase 4 for the deferred plan.
//
// Mutations write directly to `profile` (passed by reference from
// main_screen.dart) and call `onSave` (== _saveData) afterward — same
// contract the original drawer code used, just relocated. Actions that
// need main_screen.dart's private helpers (life event sheet, location
// dialog, profile create/delete) are injected as callbacks rather than
// duplicated here.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../services/structural_taxonomy.dart';

String _weightReasonLabel(WeightChangeReason reason, AppLocalizations t) {
  switch (reason) {
    case WeightChangeReason.giFlare:
      return t.weightEntryReasonGiFlare;
    case WeightChangeReason.medicationChange:
      return t.weightEntryReasonMedicationChange;
    case WeightChangeReason.fluidRetention:
      return t.weightEntryReasonFluidRetention;
    case WeightChangeReason.appetiteChange:
      return t.weightEntryReasonAppetiteChange;
    case WeightChangeReason.other:
      return t.weightEntryReasonOther;
  }
}

class ProfileSettingsScreen extends StatefulWidget {
  final Profile profile;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onSave;
  final int profileCount;
  final VoidCallback onAddProfile;
  final Future<void> Function() onDeleteProfile;
  final Future<void> Function() onEditLocation;
  final Future<void> Function() onAddLifeEvent;
  final Future<void> Function(LifeEvent existing) onEditLifeEvent;

  /// §12.6 — historial estructural por zona. Mismo patrón que
  /// onAddLifeEvent/onEditLifeEvent: la pantalla de settings no
  /// conoce el sheet, solo expone callbacks inyectados desde
  /// main_screen.dart.
  final Future<void> Function() onAddStructuralZoneHistory;
  final Future<void> Function(StructuralZoneHistoryEntry existing)
  onEditStructuralZoneHistory;

  /// Narrow clinical weight log — see docs/design_decisions/
  /// weight_height_tracking.md. Same injected-callback contract as
  /// onAddStructuralZoneHistory/onEditStructuralZoneHistory. Section is
  /// only rendered when settings.optionalTrackers['weight_tracking']
  /// is on (off by default, toggled in TrackingSettingsScreen).
  final Future<void> Function() onAddWeightEntry;
  final Future<void> Function(WeightEntry existing) onEditWeightEntry;

  const ProfileSettingsScreen({
    super.key,
    required this.profile,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onSave,
    required this.profileCount,
    required this.onAddProfile,
    required this.onDeleteProfile,
    required this.onEditLocation,
    required this.onAddLifeEvent,
    required this.onEditLifeEvent,
    required this.onAddStructuralZoneHistory,
    required this.onEditStructuralZoneHistory,
    required this.onAddWeightEntry,
    required this.onEditWeightEntry,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _preferredNameCtrl;
  late final TextEditingController _diagnosisCtrl;
  late final TextEditingController _allergyCtrl;
  late final TextEditingController _heightCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _preferredNameCtrl = TextEditingController(
      text: widget.profile.preferredName,
    );
    _diagnosisCtrl = TextEditingController();
    _allergyCtrl = TextEditingController();
    _heightCtrl = TextEditingController(
      text: widget.profile.heightCm == null
          ? ''
          : _formatHeight(widget.profile.heightCm!),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _preferredNameCtrl.dispose();
    _diagnosisCtrl.dispose();
    _allergyCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  String _formatHeight(double cm) {
    if (cm == cm.roundToDouble()) return cm.toInt().toString();
    return cm.toString();
  }

  int _ageFrom(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.profile.dateOfBirth ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Guardar',
    );
    if (picked == null) return;
    setState(() => widget.profile.dateOfBirth = picked);
    widget.onSave();
  }

  Widget _label(Color cc, String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.grey,
    ),
  );

  Widget _helper(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.grey,
      fontSize: 11,
      fontStyle: FontStyle.italic,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;
    final t = AppLocalizations.of(context)!;
    final profile = widget.profile;

    return Scaffold(
      backgroundColor: ic,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.settingsProfileConfigTitle,
                      style: TextStyle(
                        color: cc,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: cc),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(cc, t.settingsPatientNameLabel),
                    const SizedBox(height: 2),
                    _helper(t.settingsPatientNameHelper),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _nameCtrl,
                      style: TextStyle(color: cc, fontSize: 16),
                      onChanged: (val) {
                        profile.name = val;
                        widget.onSave();
                      },
                    ),
                    const SizedBox(height: 16),

                    _label(cc, t.settingsPreferredNameLabel),
                    const SizedBox(height: 2),
                    _helper(t.settingsPreferredNameHelper),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _preferredNameCtrl,
                      style: TextStyle(color: cc, fontSize: 16),
                      onChanged: (val) {
                        profile.preferredName = val;
                        widget.onSave();
                      },
                    ),
                    const SizedBox(height: 24),

                    _label(cc, 'Fecha de nacimiento'),
                    const SizedBox(height: 4),
                    Text(
                      profile.dateOfBirth == null
                          ? 'No especificada'
                          : '${DateFormat('d MMM yyyy').format(profile.dateOfBirth!)} '
                                '(${_ageFrom(profile.dateOfBirth!)} años)',
                      style: TextStyle(color: cc, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: cc)),
                      icon: Icon(Icons.cake_outlined, color: cc),
                      label: Text(
                        profile.dateOfBirth == null
                            ? 'Agregar fecha de nacimiento'
                            : 'Editar fecha de nacimiento',
                        style: TextStyle(
                          color: cc,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: _pickDateOfBirth,
                    ),

                    const SizedBox(height: 24),

                    _label(cc, t.settingsHeightLabel),
                    const SizedBox(height: 2),
                    _helper(t.settingsHeightHint),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _heightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(color: cc, fontSize: 16),
                      onChanged: (val) {
                        profile.heightCm = double.tryParse(
                          val.trim().replaceAll(',', '.'),
                        );
                        widget.onSave();
                      },
                    ),

                    const SizedBox(height: 24),

                    _label(cc, t.settingsConditionsLabel),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _diagnosisCtrl,
                            style: TextStyle(color: cc, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: cc),
                          onPressed: () {
                            final val = _diagnosisCtrl.text.trim();
                            if (val.isEmpty) return;
                            setState(() {
                              profile.conditions.add(val);
                              _diagnosisCtrl.clear();
                            });
                            widget.onSave();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _helper(t.settingsConditionsHelper),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: profile.conditions
                          .map(
                            (condition) => InputChip(
                              label: Text(
                                condition,
                                style: TextStyle(color: ic, fontSize: 14),
                              ),
                              backgroundColor: cc,
                              onDeleted: () {
                                setState(() => profile.conditions.remove(condition));
                                widget.onSave();
                              },
                              deleteIconColor: ic,
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 24),
                    _label(cc, 'Alergias / desencadenantes conocidos'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _allergyCtrl,
                            style: TextStyle(color: cc, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: cc),
                          onPressed: () {
                            final val = _allergyCtrl.text.trim();
                            if (val.isEmpty) return;
                            setState(() {
                              profile.allergies.add(val);
                              _allergyCtrl.clear();
                            });
                            widget.onSave();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _helper(
                      'Medicamentos, alimentos o gatillos ambientales conocidos. '
                      'Aparece en el reporte PDF y en la tarjeta de emergencia.',
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: profile.allergies
                          .map(
                            (allergy) => InputChip(
                              label: Text(
                                allergy,
                                style: TextStyle(color: ic, fontSize: 14),
                              ),
                              backgroundColor: cc,
                              onDeleted: () {
                                setState(() => profile.allergies.remove(allergy));
                                widget.onSave();
                              },
                              deleteIconColor: ic,
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 24),
                    _label(cc, t.settingsRelationshipLabel),
                    const SizedBox(height: 4),
                    _helper(t.settingsRelationshipHelper),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (ctx) {
                        final relOptions = <(String?, String)>[
                          (null, t.settingsRelationshipNone),
                          ('Yo', t.settingsRelationshipSelf),
                          ('Mi hijo/a', t.settingsRelationshipChild),
                          ('Mi pareja', t.settingsRelationshipPartner),
                          ('Mi madre/padre', t.settingsRelationshipParent),
                          ('Otro', t.settingsRelationshipOther),
                        ];
                        return Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: relOptions.map((opt) {
                            final rel = opt.$1;
                            final isSelected =
                                profile.relationship == rel ||
                                (rel == null && profile.relationship == null);
                            return InkWell(
                              onTap: () {
                                setState(() => profile.relationship = rel);
                                widget.onSave();
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? cc : Colors.transparent,
                                  border: Border.all(
                                    color: cc.withValues(alpha: 0.4),
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  opt.$2,
                                  style: TextStyle(
                                    color: isSelected
                                        ? ic
                                        : cc.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    _label(cc, t.settingsLifeEventsLabel),
                    const SizedBox(height: 4),
                    _helper(t.settingsLifeEventsHelper),
                    const SizedBox(height: 8),
                    if (profile.lifeEvents.isEmpty)
                      Text(
                        t.settingsLifeEventsEmpty,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      Column(
                        children:
                            (profile.lifeEvents.toList()
                                  ..sort(
                                    (a, b) => b.startDate.compareTo(a.startDate),
                                  ))
                                .map((e) {
                                  final dateLabel = e.endDate == null
                                      ? DateFormat('d MMM yyyy').format(e.startDate)
                                      : "${DateFormat('d MMM').format(e.startDate)} → "
                                            "${DateFormat('d MMM yyyy').format(e.endDate!)}";
                                  return InkWell(
                                    onTap: () async {
                                      await widget.onEditLifeEvent(e);
                                      if (mounted) setState(() {});
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: cc.withValues(alpha: 0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF9C27B0),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e.title,
                                                  style: TextStyle(
                                                    color: cc,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  e.category != null
                                                      ? "$dateLabel · ${e.category}"
                                                      : dateLabel,
                                                  style: TextStyle(
                                                    color: cc.withValues(
                                                      alpha: 0.6,
                                                    ),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              setState(
                                                () => profile.lifeEvents.remove(e),
                                              );
                                              widget.onSave();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(Icons.add, color: cc),
                      label: Text(
                        t.settingsAddEventButton,
                        style: TextStyle(
                          color: cc,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () async {
                        await widget.onAddLifeEvent();
                        if (mounted) setState(() {});
                      },
                    ),

                    const SizedBox(height: 24),
                    _label(cc, t.structuralZoneHistorySectionTitle),
                    const SizedBox(height: 8),
                    if (profile.structuralZoneHistory.isEmpty)
                      Text(
                        t.structuralZoneHistoryEmptyState,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      Column(
                        children: profile.structuralZoneHistory.map((h) {
                          return InkWell(
                            onTap: () async {
                              await widget.onEditStructuralZoneHistory(h);
                              if (mounted) setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: cc.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${h.zone.bodyZoneLabel(t)}: "
                                          "${h.kind.label(t)}",
                                          style: TextStyle(
                                            color: cc,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          h.description,
                                          style: TextStyle(
                                            color: cc.withValues(alpha: 0.6),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(
                                        () => profile.structuralZoneHistory
                                            .remove(h),
                                      );
                                      widget.onSave();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(Icons.add, color: cc),
                      label: Text(
                        t.structuralZoneHistoryAddAction,
                        style: TextStyle(
                          color: cc,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () async {
                        await widget.onAddStructuralZoneHistory();
                        if (mounted) setState(() {});
                      },
                    ),

                    if (profile.settings.optionalTrackers['weight_tracking'] ==
                        true) ...[
                      const SizedBox(height: 24),
                      _label(cc, t.weightEntrySectionTitle),
                      const SizedBox(height: 8),
                      if (profile.weightEntries.isEmpty)
                        Text(
                          t.weightEntryEmptyState,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        Column(
                          children:
                              (profile.weightEntries.toList()..sort(
                                    (a, b) =>
                                        b.timestamp.compareTo(a.timestamp),
                                  ))
                                  .map((w) {
                                    return InkWell(
                                      onTap: () async {
                                        await widget.onEditWeightEntry(w);
                                        if (mounted) setState(() {});
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: cc.withValues(alpha: 0.3),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${w.weightKg} kg · '
                                                    '${DateFormat('d MMM yyyy').format(w.timestamp)}',
                                                    style: TextStyle(
                                                      color: cc,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    _weightReasonLabel(w.reason, t),
                                                    style: TextStyle(
                                                      color: cc.withValues(
                                                        alpha: 0.6,
                                                      ),
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () {
                                                setState(
                                                  () => profile.weightEntries
                                                      .remove(w),
                                                );
                                                widget.onSave();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cc),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(Icons.add, color: cc),
                        label: Text(
                          t.weightEntryAddAction,
                          style: TextStyle(
                            color: cc,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        onPressed: () async {
                          await widget.onAddWeightEntry();
                          if (mounted) setState(() {});
                        },
                      ),
                    ],

                    const SizedBox(height: 24),
                    _label(cc, t.settingsLocationLabel),
                    const SizedBox(height: 4),
                    Text(
                      profile.homeLatitude == null
                          ? t.settingsLocationNone
                          : "lat ${profile.homeLatitude!.toStringAsFixed(2)}, "
                                "lng ${profile.homeLongitude!.toStringAsFixed(2)}",
                      style: TextStyle(color: cc, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc),
                      ),
                      icon: Icon(Icons.place_outlined, color: cc),
                      label: Text(
                        profile.homeLatitude == null
                            ? t.settingsLocationButtonAdd
                            : t.settingsLocationButtonEdit,
                        style: TextStyle(
                          color: cc,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () async {
                        await widget.onEditLocation();
                        if (mounted) setState(() {});
                      },
                    ),

                    const SizedBox(height: 40),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: Icon(Icons.person_add_alt_1_rounded, color: cc),
                      label: Text(
                        t.settingsAddProfileButton,
                        style: TextStyle(
                          color: cc,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        widget.onAddProfile();
                        Navigator.of(context).pop();
                      },
                    ),
                    if (widget.profileCount > 1) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        label: Text(
                          t.settingsDeleteProfileButton,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () => widget.onDeleteProfile(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
