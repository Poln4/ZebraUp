// "Cuadro temporal" (Episode) form sheet.
//
// Records an acute-but-not-chronic diagnosis (resfrío, amigdalitis,
// gastritis…) — see Episode in lib/models/models.dart. Pattern calcado de
// life_event_form_sheet.dart / structural_zone_history_form_sheet.dart: a
// plain returning bottom sheet, no wiring back into a callback.
//
// Only the edit path exposes the "resuelto" switch — a brand-new cuadro
// starts open by definition, so there's nothing to toggle yet.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../extensions/context_ext.dart';
import '../models/models.dart';

/// Returns the new/updated Episode, or null if cancelled.
/// Pass `existing` to open in edit mode.
Future<Episode?> showEpisodeFormSheet({
  required BuildContext context,
  required Color contrastColor,
  required Color inverseContrastColor,
  Episode? existing,
}) {
  return showModalBottomSheet<Episode>(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (_) => _EpisodeFormBody(
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      existing: existing,
    ),
  );
}

class _EpisodeFormBody extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final Episode? existing;

  const _EpisodeFormBody({
    required this.contrastColor,
    required this.inverseContrastColor,
    this.existing,
  });

  @override
  State<_EpisodeFormBody> createState() => _EpisodeFormBodyState();
}

class _EpisodeFormBodyState extends State<_EpisodeFormBody> {
  late TextEditingController _titleCtrl;
  late TextEditingController _noteCtrl;
  late DateTime _startDate;
  DateTime? _resolvedAt;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _startDate = e?.startDate ?? DateTime.now();
    _resolvedAt = e?.resolvedAt;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_resolvedAt != null && _resolvedAt!.isBefore(picked)) {
          _resolvedAt = picked;
        }
      });
    }
  }

  Future<void> _pickResolvedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _resolvedAt ?? DateTime.now(),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _resolvedAt = picked);
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final result = Episode(
      id: widget.existing?.id,
      title: title,
      startDate: _startDate,
      resolvedAt: _resolvedAt,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;
    final isEdit = widget.existing != null;

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
                isEdit ? l10n.episodeFormEditTitle : l10n.episodeFormTitle,
                style: TextStyle(
                  color: cc,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.episodeFormSubtitle,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                autofocus: !isEdit,
                style: TextStyle(color: cc),
                decoration: InputDecoration(
                  hintText: l10n.episodeFormTitleHint,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                l10n.episodeFormStartDateLabel,
                style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
              ),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cc.withValues(alpha: 0.5)),
                ),
                icon: Icon(Icons.calendar_today, color: cc, size: 14),
                label: Text(
                  DateFormat('d MMM yyyy').format(_startDate),
                  style: TextStyle(color: cc, fontSize: 12),
                ),
                onPressed: _pickStartDate,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                style: TextStyle(color: cc),
                decoration: InputDecoration(
                  hintText: l10n.episodeFormNoteHint,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),

              if (isEdit) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.episodeFormResolvedLabel,
                        style: TextStyle(
                          color: cc,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: _resolvedAt != null,
                      activeColor: cc,
                      onChanged: (v) async {
                        if (!v) {
                          setState(() => _resolvedAt = null);
                          return;
                        }
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: _startDate,
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _resolvedAt = picked);
                        }
                      },
                    ),
                  ],
                ),
                if (_resolvedAt != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc.withValues(alpha: 0.5)),
                      ),
                      icon: Icon(Icons.calendar_today, color: cc, size: 14),
                      label: Text(
                        "${l10n.episodeFormResolvedDateLabel}: "
                        "${DateFormat('d MMM yyyy').format(_resolvedAt!)}",
                        style: TextStyle(color: cc, fontSize: 12),
                      ),
                      onPressed: _pickResolvedDate,
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cc,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _save,
                child: Text(
                  isEdit
                      ? l10n.episodeActionSaveChanges
                      : l10n.episodeActionCreate,
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
