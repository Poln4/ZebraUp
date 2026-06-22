// =============================================================================
// CollapsibleSection — reusable wrapper for symptom-tab sections.
//
// Phase F3 (17-jun-2026): each registration section in Síntomas (Zonas
// estructurales, Tránsito, Fiebre, Sueño, Hidratación, HRV) is wrapped
// in this widget so users can hide sections they aren't actively using.
//
// Behavior:
//   - Header is always visible: caret + title (uppercase) + optional hint
//     (shown only when collapsed).
//   - Tap toggles expansion.
//   - `initiallyExpanded` is read once in initState. To force a reset
//     (e.g. when toggling "modo cuidadoso"), the caller passes a Key
//     that changes — Flutter rebuilds and initState runs again.
//
// Design language: matches the minimalist black/white headers used
// elsewhere in the tab. No borders, no shadows, no fill colors.
// =============================================================================

import 'package:flutter/material.dart';

class CollapsibleSection extends StatefulWidget {
  /// Section title, rendered uppercase with the standard letter-spacing.
  final String title;

  /// Optional hint shown next to the title when collapsed (e.g.
  /// "último hace 3 días" or "sin registros aún"). Hidden when expanded.
  final String? hint;

  /// Whether the section starts expanded. Read once in initState; to
  /// force a reset, pass a different Key.
  final bool initiallyExpanded;

  /// The section content shown beneath the header when expanded.
  final Widget child;

  /// Theme contrast color (typically Colors.black or Colors.white).
  final Color contrastColor;

  const CollapsibleSection({
    super.key,
    required this.title,
    this.hint,
    this.initiallyExpanded = true,
    required this.child,
    required this.contrastColor,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_more : Icons.chevron_right,
                  color: cc,
                  size: 20,
                ),
                const SizedBox(width: 2),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 14,
                    color: cc,
                  ),
                ),
                if (!_expanded && widget.hint != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '· ${widget.hint!}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: widget.child,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}