// =============================================================================
// SeverityDotPicker — Wave-style 0–4 colored-dot picker with optional
// functional anchor strip below.
//
// F5 (Batch 2 — June 2026): converted from StatelessWidget to
// StatefulWidget to support the "preview while dragging" gesture. When
// `showFunctionalAnchor` is true, a strip beneath the dot row shows the
// functional anchor of the active severity (selected by default; while
// the user is dragging across dots, it shows the anchor of the dot the
// finger is currently over — italic + dimmed — as a preview). On release
// the picker commits the selection.
//
// Also added in F5 Batch 2:
//   • `excludeNone` parameter — skips SymptomSeverity.none for flows that
//     reserve 0 as a "sin rating" sentinel reached through a separate
//     control (see sintomas_tab.dart).
//   • `contrastColor` parameter — explicit text color override so the
//     widget works on any background (was: `Theme.of(context)` only).
//   • Fix of an i18n bug: label under each dot now uses
//     `severityLabel(l10n)` from clinical_localizations.dart instead of
//     the Spanish-hardcoded `sev.label` field.
//
// Reused for:
//   • Initial symptom logging ("¿qué gravedad tiene este síntoma?")
//   • Outcome check-in BEFORE capture (when starting a dose linked to symptom)
//   • Outcome check-in AFTER capture (3h follow-up — uses same scale so the
//     user gets visual continuity between question and answer)
//   • Pre-filled "anchor" mode: show the previous value highlighted so the
//     user has a reference point when answering the follow-up.
// =============================================================================

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/clinical_localizations.dart';

class SeverityDotPicker extends StatefulWidget {
  /// Currently selected severity, or null if nothing chosen yet.
  final SymptomSeverity? selected;

  /// Optional anchor — used on follow-up check-ins to show "you were here
  /// 3 hours ago" as a translucent reference dot. Not to be confused with
  /// `showFunctionalAnchor` below, which is about the strip of functional
  /// text under the picker — different feature, similar name.
  final SymptomSeverity? anchor;

  final ValueChanged<SymptomSeverity> onSelect;

  /// Whether to show short text labels under the dots
  /// ("Leve", "Moderada", …). Off by default to keep the row compact.
  /// When on, labels are resolved via `severityLabel(l10n)`.
  final bool showLabels;

  /// Diameter of each dot in logical pixels.
  final double dotSize;

  /// F5: when true, displays a strip beneath the dot row with the
  /// "functional anchor" of the active severity — a one-line description
  /// of what that level means functionally (e.g. "me obliga a bajar el
  /// ritmo o pausar"). The strip animates between values on selection
  /// changes and shows preview text (italic, dimmed) while the user is
  /// dragging a finger across dots before releasing.
  final bool showFunctionalAnchor;

  /// F5: when true, hides SymptomSeverity.none from the picker. Used in
  /// flows where 0 is a sentinel reached via a separate "sin rating" link
  /// rather than the dot row.
  final bool excludeNone;

  /// F5: explicit text color for labels and the functional anchor strip.
  /// When null, falls back to Theme.of(context).textTheme.bodyMedium.
  final Color? contrastColor;

  const SeverityDotPicker({
    super.key,
    required this.onSelect,
    this.selected,
    this.anchor,
    this.showLabels = false,
    this.dotSize = 36,
    this.showFunctionalAnchor = false,
    this.excludeNone = false,
    this.contrastColor,
  });

  @override
  State<SeverityDotPicker> createState() => _SeverityDotPickerState();
}

class _SeverityDotPickerState extends State<SeverityDotPicker> {
  /// Index in `_severities` that the user is currently dragging over (or
  /// hovering with a mouse). Null = no preview, anchor strip falls back
  /// to the selected value if any.
  int? _previewIdx;

  List<SymptomSeverity> get _severities => widget.excludeNone
      ? SymptomSeverity.values.where((s) => s != SymptomSeverity.none).toList()
      : SymptomSeverity.values.toList();

  Color _resolveContrast(BuildContext context) =>
      widget.contrastColor ??
      Theme.of(context).textTheme.bodyMedium?.color ??
      Colors.black;

  Color _colorFor(SymptomSeverity s) {
    final hex = s.colorHex.substring(1); // strip '#'
    return Color(int.parse(hex, radix: 16) | 0xFF000000);
  }

  /// Map an X coordinate (local to the row) to the index of the dot
  /// directly under it. Clamps to valid range.
  int _indexFromX(double dx, double totalWidth) {
    final n = _severities.length;
    if (n == 0) return 0;
    final slice = totalWidth / n;
    return (dx / slice).floor().clamp(0, n - 1);
  }

  // ---------------------------------------------------------------------------
  // Gesture handlers
  // ---------------------------------------------------------------------------

  void _onTapDown(TapDownDetails d, double width) {
    setState(() => _previewIdx = _indexFromX(d.localPosition.dx, width));
  }

  void _onTapUp(TapUpDetails d, double width) {
    final idx = _indexFromX(d.localPosition.dx, width);
    widget.onSelect(_severities[idx]);
    setState(() => _previewIdx = null);
  }

  void _onTapCancel() {
    setState(() => _previewIdx = null);
  }

  void _onDragStart(DragStartDetails d, double width) {
    setState(() => _previewIdx = _indexFromX(d.localPosition.dx, width));
  }

  void _onDragUpdate(DragUpdateDetails d, double width) {
    setState(() => _previewIdx = _indexFromX(d.localPosition.dx, width));
  }

  void _onDragEnd(DragEndDetails _) {
    final idx = _previewIdx;
    if (idx != null) {
      widget.onSelect(_severities[idx]);
    }
    setState(() => _previewIdx = null);
  }

  void _onHoverEnter(int i) {
    setState(() => _previewIdx = i);
  }

  void _onHoverExit(int i) {
    setState(() {
      if (_previewIdx == i) _previewIdx = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final width = constraints.maxWidth;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _onTapDown(d, width),
              onTapUp: (d) => _onTapUp(d, width),
              onTapCancel: _onTapCancel,
              onHorizontalDragStart: (d) => _onDragStart(d, width),
              onHorizontalDragUpdate: (d) => _onDragUpdate(d, width),
              onHorizontalDragEnd: _onDragEnd,
              child: _buildDotRow(ctx),
            ),
            if (widget.showFunctionalAnchor) _buildAnchorStrip(ctx),
          ],
        );
      },
    );
  }

  Widget _buildDotRow(BuildContext context) {
    final cc = _resolveContrast(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_severities.length, (i) {
        final sev = _severities[i];
        final color = _colorFor(sev);
        final isSelected = widget.selected == sev;
        final isPreview = _previewIdx == i && !isSelected;
        final isAnchorRef = widget.anchor == sev && !isSelected && !isPreview;
        final highlighted = isSelected || isPreview;

        return Expanded(
          child: MouseRegion(
            onEnter: (_) => _onHoverEnter(i),
            onExit: (_) => _onHoverExit(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: highlighted
                          ? color
                          : color.withValues(alpha: isAnchorRef ? 0.35 : 0.18),
                      border: Border.all(
                        color: isSelected
                            ? cc
                            : (isPreview
                                  ? color
                                  : (isAnchorRef
                                        ? color.withValues(alpha: 0.6)
                                        : Colors.transparent)),
                        width: isSelected
                            ? 2.5
                            : (isPreview ? 2 : (isAnchorRef ? 2 : 0)),
                      ),
                      boxShadow: highlighted
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                  if (widget.showLabels) ...[
                    const SizedBox(height: 6),
                    Text(
                      l10n != null ? sev.severityLabel(l10n) : sev.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: highlighted
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: highlighted ? color : cc.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnchorStrip(BuildContext context) {
    final cc = _resolveContrast(context);
    final l10n = AppLocalizations.of(context);

    // Pick the severity whose anchor we want to show. Preview wins over
    // selected. If neither is set, reserve the vertical space (so the
    // layout doesn't jump when the user makes a first selection) but
    // show nothing.
    SymptomSeverity? activeSev;
    final isPreview = _previewIdx != null;
    if (isPreview) {
      activeSev = _severities[_previewIdx!];
    } else if (widget.selected != null) {
      activeSev = widget.selected;
    }

    if (activeSev == null) {
      return const SizedBox(height: 32);
    }

    final anchorText = l10n != null
        ? activeSev.severityFunctionalAnchor(l10n)
        : (kSeverityFunctionalAnchorsEs[activeSev] ?? '');

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: SizedBox(
          // Key with severity name + preview-vs-committed so the
          // AnimatedSwitcher fires on every transition.
          key: ValueKey(
            '${activeSev.name}_${isPreview ? 'preview' : 'committed'}',
          ),
          width: double.infinity,
          child: Text(
            anchorText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontStyle: isPreview ? FontStyle.italic : FontStyle.normal,
              color: isPreview ? cc.withValues(alpha: 0.6) : cc,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact static badge — for rendering a symptom row's current severity in
/// lists ("Fatiga · Intensa"). Not interactive.
///
/// F5 Batch 2: now accepts an optional `AppLocalizations` so it can use
/// `severityLabel(l10n)` instead of the Spanish-hardcoded `sev.label`.
/// If l10n is null, falls back to the model-default Spanish label for
/// backwards compatibility with any caller that hasn't migrated yet.
class SeverityBadge extends StatelessWidget {
  final SymptomSeverity severity;
  final double size;
  final AppLocalizations? l10n;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.size = 12,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final hex = severity.colorHex.substring(1);
    final color = Color(int.parse(hex, radix: 16) | 0xFF000000);
    final effectiveL10n = l10n ?? AppLocalizations.of(context);
    final label = effectiveL10n != null
        ? severity.severityLabel(effectiveL10n)
        : severity.label;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ],
    );
  }
}
