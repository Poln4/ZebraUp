// =============================================================================
// DrugInfoSheet — bilingual/trilingual patient info for medications,
// supplements and herbal products.
//
// Phase 3a (June 2026): rewritten to consume VademecumService instead of
// MedlinePlusService directly. UI is now kind-aware:
//
//   - medication → standard layout, may show external MedlinePlus link
//   - supplement → header chip "Suplemento", disclaimer about regulation
//   - herbal    → header chip "Producto herbal", evidence disclaimer
//
// Interactions are detected against the full active botiquin and shown
// in a dedicated section ranked by severity. The interaction section is
// the most actionable thing in this sheet — it appears BEFORE the
// summary so the user sees it without scrolling.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/vademecum_service.dart'; // imports VademecumService
import '../l10n/app_localizations.dart';

void showDrugInfoSheet({
  required BuildContext context,
  required MedicationDef med,
  required List<MedicationDef> botiquin,
  required Color contrastColor,
  required Color inverseContrastColor,
  required VademecumService service,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: inverseContrastColor,
    isScrollControlled: true,
    shape:
        RoundedRectangleBorder(side: BorderSide(color: contrastColor, width: 2)),
    builder: (_) => _DrugInfoSheetBody(
      med: med,
      botiquin: botiquin,
      contrastColor: contrastColor,
      inverseContrastColor: inverseContrastColor,
      service: service,
    ),
  );
}

class _DrugInfoSheetBody extends StatefulWidget {
  final MedicationDef med;
  final List<MedicationDef> botiquin;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VademecumService service;

  const _DrugInfoSheetBody({
    required this.med,
    required this.botiquin,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.service,
  });

  @override
  State<_DrugInfoSheetBody> createState() => _DrugInfoSheetBodyState();
}

class _DrugInfoSheetBodyState extends State<_DrugInfoSheetBody> {
  bool _loading = true;
  VademecumDrugContent? _content;
  List<DetectedInteraction> _interactions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final locale = VademecumLocale.fromCode(
        Localizations.localeOf(context).languageCode);
    final content = await widget.service.getDrugContent(widget.med, locale);
    final inters = await widget.service.detectInteractions(
        widget.med, widget.botiquin, locale);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _content = content;
      _interactions = inters;
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

            // Header: icon + name + close
            Row(
              children: [
                Icon(_iconForKind(_content?.kind), color: cc, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.med.name,
                    style: TextStyle(
                        color: cc,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: cc.withValues(alpha: 0.6), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // Resolved label + kind chip
            if (_content != null) _headerSubrow(cc, l10n),

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

  Widget _headerSubrow(Color cc, AppLocalizations l10n) {
    final c = _content!;
    final showResolved = c.resolvedLabel.isNotEmpty &&
        c.resolvedLabel.toLowerCase() != widget.med.name.toLowerCase();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          _kindChip(c.kind, cc, l10n),
          if (showResolved) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                c.resolvedLabel,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: cc.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kindChip(VademecumKind kind, Color cc, AppLocalizations l10n) {
    final label = switch (kind) {
      VademecumKind.medication => l10n.drugKindMedication,
      VademecumKind.supplement => l10n.drugKindSupplement,
      VademecumKind.herbal => l10n.drugKindHerbal,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: cc.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: cc.withValues(alpha: 0.75),
          fontSize: 9,
          letterSpacing: 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _iconForKind(VademecumKind? kind) => switch (kind) {
        VademecumKind.supplement => Icons.eco_outlined,
        VademecumKind.herbal => Icons.spa_outlined,
        _ => Icons.medication_outlined,
      };

  Widget _buildBody(
    Color cc,
    Color ic,
    ScrollController scrollCtrl,
    AppLocalizations l10n,
  ) {
    if (_content == null) return _errorState(cc, l10n, null);
    final c = _content!;

    return Scrollbar(
      controller: scrollCtrl,
      thumbVisibility: true,
      child: ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(bottom: 30, right: 8),
        children: [
          // Interactions — first because most actionable
          if (_interactions.isNotEmpty) _buildInteractionsBlock(cc, l10n),

          // Curated notes specific to this med
          if (c.notes != null && c.notes!.isNotEmpty)
            _buildNotesBlock(cc, c.notes!),

          // Summary (or no-content placeholder)
          if (c.hasContent)
            _buildSummaryBlock(cc, c.summary!)
          else
            _buildNoContentBlock(cc, c, l10n),

          const SizedBox(height: 16),

          // External link (when MedlinePlus served the content)
          if (c.externalLink != null && c.externalLink!.isNotEmpty)
            _buildExternalLinkButton(cc, c.externalLink!, l10n),

          const SizedBox(height: 12),

          // Confidence disclaimer
          if (c.isMediumConfidence) _buildConfidenceBlock(cc, l10n),

          // Source footer
          _buildSourceFooter(cc, c, l10n),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-blocks
  // ---------------------------------------------------------------------------

  Widget _buildInteractionsBlock(Color cc, AppLocalizations l10n) {
    final highest = _interactions.first.severity;
    final color = _severityColor(highest, cc);
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz_rounded, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                l10n.drugInteractionsInBotiquinHeader.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._interactions.map((inter) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _severityColor(inter.severity, cc),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _severityLabel(inter.severity, l10n).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            inter.other.name,
                            style: TextStyle(
                              color: cc,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      inter.description,
                      style: TextStyle(
                          color: cc.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.4),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _severityColor(InteractionSeverity s, Color cc) => switch (s) {
        InteractionSeverity.high => const Color(0xFFB71C1C),
        InteractionSeverity.medium => const Color(0xFFE65100),
        InteractionSeverity.low => cc.withValues(alpha: 0.6),
      };

  String _severityLabel(InteractionSeverity s, AppLocalizations l10n) =>
      switch (s) {
        InteractionSeverity.high => l10n.drugInteractionSeverityHigh,
        InteractionSeverity.medium => l10n.drugInteractionSeverityMedium,
        InteractionSeverity.low => l10n.drugInteractionSeverityLow,
      };

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
    VademecumDrugContent c,
    AppLocalizations l10n,
  ) {
    final reason = c.noContentReason;
    final message = switch (reason) {
      'supplement_no_content' => l10n.drugNoContentSupplement,
      'herbal_no_content' => l10n.drugNoContentHerbal,
      'medlineplus_empty' => l10n.drugNoContentMedlineEmpty(c.rxcui ?? '?'),
      'unmapped' => l10n.drugNoContentUnmapped,
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
          Icon(Icons.cloud_off_outlined,
              size: 18, color: cc.withValues(alpha: 0.6)),
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
        style: TextStyle(
            color: cc, fontWeight: FontWeight.bold, fontSize: 13),
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

  Widget _buildConfidenceBlock(Color cc, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: cc.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline,
              size: 14, color: cc.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.drugConfidenceMediumWarning,
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
    VademecumDrugContent c,
    AppLocalizations l10n,
  ) {
    final msg = switch (c.source) {
      'local' => l10n.drugSourceLocalCurated,
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
          Icon(Icons.info_outline,
              size: 14, color: cc.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 11,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(Color cc, AppLocalizations l10n, String? msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                color: cc.withValues(alpha: 0.5), size: 36),
            const SizedBox(height: 12),
            Text(
              msg ?? l10n.drugLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: cc.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}