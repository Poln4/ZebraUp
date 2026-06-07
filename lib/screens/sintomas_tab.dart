// =============================================================================
// Síntomas tab — phase 2C redesign.
//
// Research foundations:
//   • Maarj et al. (2022): the e-VAS pattern is clinically validated for
//     HSD/hEDS pain capture; our 0–4 dot picker is the discrete equivalent.
//     Prevents retrospective recall bias by capturing severity right now.
//   • Heiskari et al. (2026): rigid metric-pushing causes autonomy and
//     competence frustration in chronic-illness users. Severity is required
//     by default but the "Logear sin rating" link makes skip a first-class
//     option (skip = SymptomSeverity.none, displayed as "Sin rating").
//   • Hatem et al. (2022) #2 (consultations): the photo attach surfaces
//     the existing photoPath model field so patients can bring visual
//     evidence to appointments.
//   • Hatem et al. (2022) #4 (self-management): the custom symptom add
//     flow lets patients track conditions outside any predefined catalog.
//
// Layout:
//   1. "Hoy" — symptoms logged for selectedDate (tap to edit, swipe to delete)
//   2. "Tu vault" — chip grid; tap any to log
//   3. "+ Crear síntoma personalizado" — adds to the vault
//
// Photo attach uses the image_picker package. Add to pubspec.yaml:
//   image_picker: ^1.0.7
// (image_picker_for_web is bundled automatically.)
// =============================================================================

import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../widgets/severity_picker.dart';
import 'timestamp_picker.dart';

class SintomasTab extends StatelessWidget {
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onProfileChanged;

  const SintomasTab({
    super.key,
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    final todaySymptoms = profile.getSymptomsForDay(selectedDate)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // 1. Hoy
        _SectionHeader(
          title: 'Hoy',
          badge: todaySymptoms.isEmpty ? null : '${todaySymptoms.length}',
          contrastColor: contrastColor,
        ),
        const SizedBox(height: 8),
        if (todaySymptoms.isEmpty)
          _EmptyTodayCard(contrastColor: contrastColor)
        else
          ...todaySymptoms.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _SymptomLogRow(
                  event: e,
                  profile: profile,
                  contrastColor: contrastColor,
                  inverseContrastColor: inverseContrastColor,
                  onProfileChanged: onProfileChanged,
                ),
              )),
        const SizedBox(height: 24),

        // 2. Vault
        _SectionHeader(
          title: 'Tu vault de síntomas',
          badge: profile.symptomVault.isEmpty
              ? null
              : '${profile.symptomVault.length}',
          contrastColor: contrastColor,
        ),
        const SizedBox(height: 4),
        Text(
          'Toca un síntoma para registrarlo ahora.',
          style: TextStyle(
            color: contrastColor.withValues(alpha: 0.55),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        if (profile.symptomVault.isEmpty)
          _EmptyVaultCard(contrastColor: contrastColor)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.symptomVault
                .map((name) => _VaultChip(
                      name: name,
                      profile: profile,
                      selectedDate: selectedDate,
                      contrastColor: contrastColor,
                      inverseContrastColor: inverseContrastColor,
                      onProfileChanged: onProfileChanged,
                    ))
                .toList(),
          ),
        const SizedBox(height: 14),

        // 3. Custom add
        OutlinedButton.icon(
          onPressed: () => _openAddCustom(context),
          icon: Icon(Icons.add, size: 16, color: contrastColor),
          label: Text(
            'Crear síntoma personalizado',
            style: TextStyle(
                color: contrastColor, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: contrastColor.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _openAddCustom(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => _AddCustomSymptomDialog(
        contrastColor: contrastColor,
        inverseContrastColor: inverseContrastColor,
        existing: profile.symptomVault,
      ),
    );
    if (name != null && name.isNotEmpty) {
      profile.symptomVault.add(name);
      onProfileChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('"$name" añadido a tu vault'),
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }
}

// =============================================================================
// Section header — matches the visual language across tabs
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? badge;
  final Color contrastColor;

  const _SectionHeader({
    required this.title,
    required this.contrastColor,
    this.badge,
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
              color: contrastColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: contrastColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// Empty states
// =============================================================================

class _EmptyTodayCard extends StatelessWidget {
  final Color contrastColor;
  const _EmptyTodayCard({required this.contrastColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: contrastColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.healing_outlined,
              size: 32, color: contrastColor.withValues(alpha: 0.35)),
          const SizedBox(height: 8),
          Text(
            'Aún no has registrado síntomas hoy',
            style: TextStyle(
              color: contrastColor.withValues(alpha: 0.65),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyVaultCard extends StatelessWidget {
  final Color contrastColor;
  const _EmptyVaultCard({required this.contrastColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: contrastColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Tu vault está vacío. Crea tu primer síntoma personalizado abajo.',
        style: TextStyle(
          color: contrastColor.withValues(alpha: 0.65),
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}

// =============================================================================
// Today's symptom row — tap to edit, swipe to delete
// =============================================================================

class _SymptomLogRow extends StatelessWidget {
  final SymptomEvent event;
  final Profile profile;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onProfileChanged;

  const _SymptomLogRow({
    required this.event,
    required this.profile,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onProfileChanged,
  });

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final unrated = event.severity == SymptomSeverity.none;

    return Dismissible(
      key: ValueKey('sx-${event.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE57373),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: inverseContrastColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text('¿Eliminar este registro?',
              style: TextStyle(color: cc)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancelar',
                  style:
                      TextStyle(color: cc.withValues(alpha: 0.7))),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Eliminar',
                  style: TextStyle(
                      color: const Color(0xFFE57373),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        profile.symptomHistory.removeWhere((s) => s.id == event.id);
        onProfileChanged();
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openEdit(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cc.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cc.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.name,
                              style: TextStyle(
                                color: cc,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (event.photoPath != null) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.image_outlined,
                                size: 14,
                                color: cc.withValues(alpha: 0.5)),
                          ],
                          if (event.note != null &&
                              event.note!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.sticky_note_2_outlined,
                                size: 14,
                                color: cc.withValues(alpha: 0.5)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (unrated)
                            Text(
                              'Sin rating',
                              style: TextStyle(
                                color: cc.withValues(alpha: 0.5),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          else
                            SeverityBadge(
                                severity: event.severity, size: 10),
                          const SizedBox(width: 10),
                          Text(
                            _formatTime(event.timestamp),
                            style: TextStyle(
                              color: cc.withValues(alpha: 0.55),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: cc.withValues(alpha: 0.35), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: inverseContrastColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SymptomLogSheet(
        profile: profile,
        symptomName: event.name,
        existing: event,
        contrastColor: contrastColor,
        inverseContrastColor: inverseContrastColor,
      ),
    );
    onProfileChanged();
  }
}

// =============================================================================
// Vault chip — tap to log
// =============================================================================

class _VaultChip extends StatelessWidget {
  final String name;
  final Profile profile;
  final DateTime selectedDate;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onProfileChanged;

  const _VaultChip({
    required this.name,
    required this.profile,
    required this.selectedDate,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final loggedToday = profile
        .getSymptomsForDay(selectedDate)
        .where((s) => s.name == name)
        .toList();
    final hasLogToday = loggedToday.isNotEmpty;
    final maxSeverity = loggedToday.isEmpty
        ? null
        : loggedToday
            .map((s) => s.severity)
            .reduce((a, b) => a.value >= b.value ? a : b);
    final showBadge =
        maxSeverity != null && maxSeverity != SymptomSeverity.none;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openLog(context),
        onLongPress: () => _confirmRemoveFromVault(context),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: hasLogToday
                ? cc.withValues(alpha: 0.12)
                : cc.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color:
                    cc.withValues(alpha: hasLogToday ? 0.4 : 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showBadge) ...[
                SeverityBadge(severity: maxSeverity, size: 8),
                const SizedBox(width: 6),
              ],
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  color: cc,
                  fontWeight: hasLogToday
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (loggedToday.length > 1) ...[
                const SizedBox(width: 4),
                Text(
                  '×${loggedToday.length}',
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.55),
                    fontSize: 11,
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

  Future<void> _openLog(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: inverseContrastColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SymptomLogSheet(
        profile: profile,
        symptomName: name,
        contrastColor: contrastColor,
        inverseContrastColor: inverseContrastColor,
      ),
    );
    onProfileChanged();
  }

  Future<void> _confirmRemoveFromVault(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: inverseContrastColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('¿Quitar "$name" del vault?',
            style: TextStyle(color: contrastColor)),
        content: Text(
          'Tu historial de este síntoma se conserva. Solo dejará de aparecer en tu vault.',
          style: TextStyle(
              color: contrastColor.withValues(alpha: 0.8), height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar',
                style: TextStyle(
                    color: contrastColor.withValues(alpha: 0.7))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Quitar',
                style: TextStyle(
                    color: const Color(0xFFE57373),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      profile.symptomVault.remove(name);
      onProfileChanged();
    }
  }
}

// =============================================================================
// Symptom log sheet — dot picker + skip link + photo + notes + timestamp
// =============================================================================

class _SymptomLogSheet extends StatefulWidget {
  final Profile profile;
  final String symptomName;
  final SymptomEvent? existing;
  final Color contrastColor;
  final Color inverseContrastColor;

  const _SymptomLogSheet({
    required this.profile,
    required this.symptomName,
    required this.contrastColor,
    required this.inverseContrastColor,
    this.existing,
  });

  @override
  State<_SymptomLogSheet> createState() => _SymptomLogSheetState();
}

class _SymptomLogSheetState extends State<_SymptomLogSheet> {
  SymptomSeverity? _severity;
  late final TextEditingController _noteCtrl;
  late DateTime _timestamp;
  String? _photoPath;
  bool _saved = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _severity = e?.severity;
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _photoPath = e?.photoPath;
    _timestamp = e?.timestamp ?? DateTime.now();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() => _photoPath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No se pudo abrir la galería: $e'),
        ));
      }
    }
  }

  void _saveWithSeverity(SymptomSeverity severity) {
    if (_saved) return;
    _saved = true;
    final note = _noteCtrl.text.trim();
    final updated = SymptomEvent(
      id: widget.existing?.id,
      timestamp: _timestamp,
      name: widget.symptomName,
      severity: severity,
      note: note.isEmpty ? null : note,
      photoPath: _photoPath,
    );
    if (_isEditing) {
      final idx = widget.profile.symptomHistory
          .indexWhere((s) => s.id == widget.existing!.id);
      if (idx >= 0) {
        widget.profile.symptomHistory[idx] = updated;
      } else {
        widget.profile.symptomHistory.add(updated);
      }
    } else {
      widget.profile.symptomHistory.add(updated);
    }
    Navigator.of(context).pop();
  }

  String _formatTimestamp(DateTime t) {
    final now = DateTime.now();
    final today =
        t.year == now.year && t.month == now.month && t.day == now.day;
    final time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (today) return 'Hoy a las $time';
    return '${t.day}/${t.month} a las $time';
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final canSave = _severity != null;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Editar registro' : 'Registrar síntoma',
                          style: TextStyle(
                            color: cc.withValues(alpha: 0.6),
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.symptomName,
                          style: TextStyle(
                            color: cc,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: cc),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Severity dot picker (Maarj e-VAS pattern)
              Text(
                '¿Qué tan intenso?',
                style: TextStyle(
                  color: cc.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 10),
              SeverityDotPicker(
                selected: _severity == SymptomSeverity.none ? null : _severity,
                showLabels: true,
                onSelect: (sev) => setState(() => _severity = sev),
              ),
              const SizedBox(height: 6),

              // Skip link — Heiskari autonomy-frustration mitigation
              Center(
                child: TextButton(
                  onPressed: () => _saveWithSeverity(SymptomSeverity.none),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Logear sin rating',
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.6),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationColor: cc.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              Text(
                'Notas (opcional)',
                style: TextStyle(
                  color: cc.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _noteCtrl,
                style: TextStyle(color: cc),
                maxLines: 3,
                minLines: 2,
                decoration: _inputDeco(
                  'p. ej. después de subir escaleras, peor en la mañana...',
                  cc,
                ),
              ),
              const SizedBox(height: 16),

              // Photo attach
              _PhotoAttachRow(
                photoPath: _photoPath,
                contrastColor: cc,
                onPick: _pickPhoto,
                onRemove: () => setState(() => _photoPath = null),
              ),
              const SizedBox(height: 16),

              // Timestamp
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await pickTimestamp(
                    context: context,
                    initial: _timestamp,
                    contrastColor: cc,
                    inverseContrastColor: widget.inverseContrastColor,
                  );
                  if (picked != null) {
                    setState(() => _timestamp = picked);
                  }
                },
                icon: Icon(Icons.access_time,
                    size: 16, color: cc.withValues(alpha: 0.7)),
                label: Text(
                  _formatTimestamp(_timestamp),
                  style: TextStyle(
                      color: cc.withValues(alpha: 0.8), fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cc.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 24),

              // Save
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      canSave ? () => _saveWithSeverity(_severity!) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cc,
                    foregroundColor: widget.inverseContrastColor,
                    disabledBackgroundColor: cc.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isEditing ? 'Guardar cambios' : 'Registrar síntoma',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, Color cc) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: cc.withValues(alpha: 0.2)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: cc.withValues(alpha: 0.35), fontSize: 13),
      filled: true,
      fillColor: cc.withValues(alpha: 0.04),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cc, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    );
  }
}

// =============================================================================
// Photo attach row
// =============================================================================

class _PhotoAttachRow extends StatelessWidget {
  final String? photoPath;
  final Color contrastColor;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _PhotoAttachRow({
    required this.photoPath,
    required this.contrastColor,
    required this.onPick,
    required this.onRemove,
  });

  Widget _thumbnail() {
    if (photoPath == null) {
      return const SizedBox.shrink();
    }
    final path = photoPath!;
    // Web: image_picker returns a blob: URL (Image.network).
    // Mobile: real filesystem path (Image.file).
    if (kIsWeb || path.startsWith('blob:') || path.startsWith('http')) {
      return Image.network(
        path,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _brokenThumb(),
      );
    }
    return Image.file(
      File(path),
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _brokenThumb(),
    );
  }

  Widget _brokenThumb() => Container(
        width: 56,
        height: 56,
        color: contrastColor.withValues(alpha: 0.1),
        alignment: Alignment.center,
        child: Icon(Icons.broken_image_outlined,
            color: contrastColor.withValues(alpha: 0.5)),
      );

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final hasPhoto = photoPath != null;

    return Row(
      children: [
        if (hasPhoto) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _thumbnail(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📷 Foto adjunta',
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                TextButton.icon(
                  onPressed: onRemove,
                  icon: Icon(Icons.close,
                      size: 14, color: cc.withValues(alpha: 0.7)),
                  label: Text(
                    'Quitar',
                    style: TextStyle(
                      color: cc.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ],
            ),
          ),
        ] else
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPick,
              icon: Icon(Icons.camera_alt_outlined,
                  size: 16, color: cc.withValues(alpha: 0.7)),
              label: Text(
                'Adjuntar foto',
                style: TextStyle(
                  color: cc.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cc.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Add custom symptom dialog
// =============================================================================

class _AddCustomSymptomDialog extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final List<String> existing;

  const _AddCustomSymptomDialog({
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.existing,
  });

  @override
  State<_AddCustomSymptomDialog> createState() =>
      _AddCustomSymptomDialogState();
}

class _AddCustomSymptomDialogState extends State<_AddCustomSymptomDialog> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe un nombre');
      return;
    }
    if (widget.existing
        .any((e) => e.toLowerCase() == name.toLowerCase())) {
      setState(() => _error = 'Ya está en tu vault');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    return AlertDialog(
      backgroundColor: widget.inverseContrastColor,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Nuevo síntoma',
          style: TextStyle(color: cc)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Algo específico que quieras rastrear y no esté en tu vault.',
            style: TextStyle(
                color: cc.withValues(alpha: 0.7),
                fontSize: 12,
                height: 1.4),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            style: TextStyle(color: cc),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'p. ej. Tinnitus, espasmo cervical, picor en muñeca',
              hintStyle: TextStyle(
                  color: cc.withValues(alpha: 0.35), fontSize: 13),
              errorText: _error,
              filled: true,
              fillColor: cc.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: cc.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: cc.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cc, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              isDense: true,
            ),
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar',
              style:
                  TextStyle(color: cc.withValues(alpha: 0.7))),
        ),
        TextButton(
          onPressed: _submit,
          child: Text('Añadir',
              style: TextStyle(color: cc, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}