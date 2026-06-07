// =============================================================================
// SeverityDotPicker — Wave-style 0–4 colored-dot picker.
//
// Reused for:
//   • Initial symptom logging ("¿qué gravedad tiene este síntoma?")
//   • Outcome check-in BEFORE capture (when starting a dose linked to symptom)
//   • Outcome check-in AFTER capture (3h follow-up — uses same scale so the
//     user gets visual continuity between question and answer)
//   • Pre-filled "anchor" mode: show the previous value highlighted so the
//     user has a reference point when answering the follow-up.
//
// Pure Flutter; no model imports beyond `SymptomSeverity`.
// =============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';

class SeverityDotPicker extends StatelessWidget {
  /// Currently selected severity, or null if nothing chosen yet.
  final SymptomSeverity? selected;

  /// Optional anchor — used on follow-up check-ins to show "you were here
  /// 3 hours ago" as a translucent reference dot.
  final SymptomSeverity? anchor;

  final ValueChanged<SymptomSeverity> onSelect;

  /// Whether to show text labels under the dots ("Leve", "Moderada", ...).
  /// Off by default to keep the row compact.
  final bool showLabels;

  /// Diameter of each dot in logical pixels.
  final double dotSize;

  const SeverityDotPicker({
    super.key,
    required this.onSelect,
    this.selected,
    this.anchor,
    this.showLabels = false,
    this.dotSize = 36,
  });

  Color _colorFor(SymptomSeverity s) {
    final hex = s.colorHex.substring(1); // strip '#'
    return Color(int.parse(hex, radix: 16) | 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: SymptomSeverity.values.map((sev) {
        final isSelected = selected == sev;
        final isAnchor = anchor == sev && !isSelected;
        final color = _colorFor(sev);
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(sev),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? color
                          : color.withValues(alpha: isAnchor ? 0.35 : 0.18),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : (isAnchor ? color.withValues(alpha: 0.6) : Colors.transparent),
                        width: isSelected ? 0 : (isAnchor ? 2 : 0),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                  ),
                  if (showLabels) ...[
                    const SizedBox(height: 6),
                    Text(
                      sev.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? color
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Compact static badge — for rendering a symptom row's current severity in
/// lists ("Fatiga · Intensa"). Not interactive.
class SeverityBadge extends StatelessWidget {
  final SymptomSeverity severity;
  final double size;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    final hex = severity.colorHex.substring(1);
    final color = Color(int.parse(hex, radix: 16) | 0xFF000000);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          severity.label,
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