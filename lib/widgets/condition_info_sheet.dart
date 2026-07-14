// =============================================================================
// ConditionInfoSheet — patient info for a user-entered condition string.
//
// Phase 3 completion (July 2026): rewritten to consume
// VademecumService.getConditionContent instead of calling MedlinePlus
// directly. Local-first, same shape as DrugInfoSheet:
//
//   - source == 'local'       → summary_es/notes_es from condition_codes.json,
//                                shown with an "unverified" caveat when the
//                                entry's content_verify flag is set
//   - source == 'medlineplus' → fallback for non-Spanish locales or
//                                conditions without local content yet
//   - source == 'none'        → reason-specific empty state
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/vademecum_service.dart';
import '../l10n/app_localizations.dart';

void showConditionInfoSheet({
  required BuildContext context,
  required String userCondition,
  required Color contrastColor,
  required Color inverseContrastColor,
  required VademecumService service,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: contrastColor, width: 2),
    ),
    builder: (_) => _ConditionInfoSheetBody(
      userCondition: userCondition,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      service: service,
    ),
  );
}

class _ConditionInfoSheetBody extends StatefulWidget {
  final String userCondition;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VademecumService service;

  const _ConditionInfoSheetBody({
    required this.userCondition,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.service,
  });

  @override
  State<_ConditionInfoSheetBody> createState() =>
      _ConditionInfoSheetBodyState();
}

class _ConditionInfoSheetBodyState extends State<_ConditionInfoSheetBody> {
  bool _loading = true;
  VademecumConditionContent? _content;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final locale = VademecumLocale.fromCode(
      Localizations.localeOf(context).languageCode,
    );
    final content = await widget.service.getConditionContent(
      widget.userCondition,
      locale,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _content = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
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
            Row(
              children: [
                Icon(Icons.health_and_safety_outlined, color: cc, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.userCondition,
                    style: TextStyle(
                      color: cc,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: cc.withValues(alpha: 0.6),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (_content != null) _headerSubrow(cc),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: cc))
                  : _buildBody(cc, ic, scrollCtrl, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerSubrow(Color cc) {
    final c = _content!;
    final showResolved =
        c.resolvedLabel.isNotEmpty &&
        c.resolvedLabel.toLowerCase() != widget.userCondition.toLowerCase();
    if (!showResolved) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        c.resolvedLabel,
        style: TextStyle(
          color: cc.withValues(alpha: 0.55),
          fontSize: 11,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildBody(
    Color cc,
    Color ic,
    ScrollController scrollCtrl,
    AppLocalizations l10n,
  ) {
    if (_content == null) return _errorState(cc, l10n);
    final c = _content!;

    return Scrollbar(
      controller: scrollCtrl,
      thumbVisibility: true,
      child: ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(bottom: 30, right: 8),
        children: [
          if (c.notes != null && c.notes!.isNotEmpty)
            _buildNotesBlock(cc, c.notes!),

          if (c.hasContent)
            _buildSummaryBlock(cc, c.summary!)
          else
            _buildNoContentBlock(cc, c, l10n),

          const SizedBox(height: 16),

          if (c.source == 'medlineplus' &&
              c.externalLink != null &&
              c.externalLink!.isNotEmpty)
            _buildExternalLinkButton(cc, c.externalLink!, l10n),

          const SizedBox(height: 12),

          if (c.contentUnverified) _buildUnverifiedBlock(cc, l10n),

          _buildSourceFooter(cc, c, l10n),
        ],
      ),
    );
  }

  Widget _buildNotesBlock(Color cc, String notes) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        border: Border.all(color: cc.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: cc, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              notes,
              style: TextStyle(
                color: cc,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBlock(Color cc, String summary) {
    return SelectableText(
      summary,
      style: TextStyle(color: cc, fontSize: 14, height: 1.55),
    );
  }

  Widget _buildNoContentBlock(
    Color cc,
    VademecumConditionContent c,
    AppLocalizations l10n,
  ) {
    final message = switch (c.noContentReason) {
      'unmapped' => l10n.conditionNoContentUnmapped,
      'no_icd10' => l10n.conditionNoContentNoIcd10,
      'medlineplus_empty' => l10n.conditionNoContentMedlineEmpty,
      _ => l10n.drugNoContentGeneric,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: cc.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 18,
            color: cc.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: cc.withValues(alpha: 0.75),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalLinkButton(
    Color cc,
    String link,
    AppLocalizations l10n,
  ) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: cc),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      icon: Icon(Icons.open_in_new, color: cc, size: 16),
      label: Text(
        l10n.drugReadMoreMedlinePlus,
        style: TextStyle(color: cc, fontWeight: FontWeight.bold, fontSize: 13),
      ),
      onPressed: () async {
        final uri = Uri.parse(link);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.drugBrowserOpenError),
                backgroundColor: cc,
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildUnverifiedBlock(Color cc, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: cc.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, size: 14, color: cc.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.conditionContentUnverifiedWarning,
              style: TextStyle(
                color: cc.withValues(alpha: 0.6),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceFooter(
    Color cc,
    VademecumConditionContent c,
    AppLocalizations l10n,
  ) {
    final msg = switch (c.source) {
      'local' => l10n.conditionSourceLocalCurated,
      'medlineplus' => l10n.drugSourceMedlinePlus,
      _ => l10n.drugSourceNoInfo,
    };
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: cc.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: cc.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: cc.withValues(alpha: 0.6),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(Color cc, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              color: cc.withValues(alpha: 0.5),
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.drugLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cc.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
