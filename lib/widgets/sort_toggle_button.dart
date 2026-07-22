import 'package:flutter/material.dart';

/// Small "A-Z" pill toggle. Extracted from botiquin_tab.dart's private
/// `_SortToggleButton` when sintomas_tab.dart (Baúl de síntomas) became a
/// second real host for the same pattern. Purely presentational — callers
/// own persistence (e.g. `profile.settings.optionalTrackers['...sort_alpha']`)
/// and must only sort their own transient render list, never the
/// underlying stored order.
class SortToggleButton extends StatelessWidget {
  final bool active;
  final Color contrastColor;
  final VoidCallback onTap;

  const SortToggleButton({
    super.key,
    required this.active,
    required this.contrastColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? cc.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cc.withValues(alpha: active ? 0.4 : 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sort_by_alpha,
                size: 14,
                color: cc.withValues(alpha: active ? 1.0 : 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                'A-Z',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: cc.withValues(alpha: active ? 1.0 : 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
