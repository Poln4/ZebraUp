// Sprint T0 — Weekly narrative widget.
//
// Renders the natural-language rolling 7-day digest in the Hoy tab.
// Placement: between the _HoyHeader SizedBox and the "// 1.5.
// FIRST-SESSION HINT" block. Uses the contrast palette only (no
// accent colors, per F.E2 design constraint).
//
// Hides entirely (SizedBox.shrink) when the digest has no data —
// first-session hint mechanism handles onboarding wording.

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/action_analytics.dart';

class WeeklyNarrative extends StatelessWidget {
  final Profile profile;
  final Color contrastColor;

  const WeeklyNarrative({
    super.key,
    required this.profile,
    required this.contrastColor,
  });

  @override
  Widget build(BuildContext context) {
    final digest = weeklyDigestFor(profile, DateTime.now());
    if (!digest.hasAnyData) return const SizedBox.shrink();

    final text = narrativeText(digest);
    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: contrastColor.withValues(alpha: 0.03),
          border: Border.all(color: contrastColor.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(color: contrastColor, fontSize: 13, height: 1.5),
        ),
      ),
    );
  }
}
