// Combined zone+kind entry flow (18-jul-2026 rework): body-zone chip
// grid, grouped by BodyRegion, extracted out of sintomas_tab.dart's
// "Zonas estructurales" section so it can be reused verbatim as the
// zone-pick step inside the combined structural sheet
// (structural_detail_sheet.dart). Same visual shape as before — this
// is a pure extraction, no behavior change at either call site.

import 'package:flutter/material.dart';
import '../extensions/context_ext.dart';
import '../models/models.dart';
import '../services/structural_taxonomy.dart';

class BodyZonePickerGrid extends StatelessWidget {
  final Color contrastColor;
  final ValueChanged<String> onZoneTap;

  /// When provided, restricts the grid to just these zone IDs (regions
  /// left with none are skipped entirely) — used when the vault
  /// free-text detector recognized a broad body-region word (e.g.
  /// "pierna") that narrows the plausible zones without resolving one
  /// specific ID. Null shows the full grid, unchanged from before.
  final Set<String>? candidateZones;

  const BodyZonePickerGrid({
    super.key,
    required this.contrastColor,
    required this.onZoneTap,
    this.candidateZones,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cc = contrastColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: BodyRegion.values.map((region) {
        final allZones = kBodyRegionZones[region]!;
        final zones = candidateZones == null
            ? allZones
            : allZones.where(candidateZones!.contains).toList();
        if (zones.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  region.label(l10n).toUpperCase(),
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.55),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: zones
                    .map(
                      (zone) => ActionChip(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: cc.withValues(alpha: 0.6)),
                        label: Text(
                          zone.bodyZoneLabel(l10n),
                          style: TextStyle(color: cc, fontSize: 11),
                        ),
                        onPressed: () => onZoneTap(zone),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
