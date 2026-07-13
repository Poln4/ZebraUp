// Sprint B.C — Feedback prompt banner.
//
// Weekly-cadence invitation for beta users to share feedback.
// Rendered in Hoy tab below informational widgets, above actionable
// banners. Respects flare mode via the parent's `if (!isInFlare)`
// wrap.
//
// Show gating:
//   • accessGranted — user completed B.A code entry
//   • researchConsentAccepted — user completed B.B consent accept
//     (per B.B copy, feedback = research anonimizada)
//   • feedbackPromptEnabled — user preference (default true; no UI
//     to toggle yet — deferred to B.C.1)
//   • ≥ 7 days since lastFeedbackPromptAt (or never shown)
//
// StatefulWidget with local setState — the widget mutates the
// service state directly and rebuilds itself. No parent callback
// plumbing needed since the state lives in Hive (global), not
// Profile.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/beta_access_state.dart';
import '../services/beta_access_service.dart';

class FeedbackPromptBanner extends StatefulWidget {
  final Color contrastColor;
  final Color inverseContrastColor;

  const FeedbackPromptBanner({
    super.key,
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  @override
  State<FeedbackPromptBanner> createState() => _FeedbackPromptBannerState();
}

class _FeedbackPromptBannerState extends State<FeedbackPromptBanner> {
  @override
  Widget build(BuildContext context) {
    final state = BetaAccessService.loadState();
    if (!_shouldShow(state)) return const SizedBox.shrink();
    return _buildBanner(context);
  }

  bool _shouldShow(BetaAccessState state) {
    if (!state.accessGranted) return false;
    if (!state.researchConsentAccepted) return false;
    if (!state.feedbackPromptEnabled) return false;
    if (state.lastFeedbackPromptAt == null) return true;
    return DateTime.now().difference(state.lastFeedbackPromptAt!) >=
        const Duration(days: 7);
  }

  Future<void> _markShown() async {
    final state = BetaAccessService.loadState();
    state.lastFeedbackPromptAt = DateTime.now();
    await BetaAccessService.saveState(state);
  }

  Future<void> _onSnooze() async {
    await _markShown();
    if (mounted) setState(() {});
  }

  Future<void> _onShareFeedback() async {
    await _markShown();
    if (mounted) setState(() {});
    final uri = Uri.parse(BetaAccessService.feedbackFormUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildBanner(BuildContext context) {
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cc.withValues(alpha: 0.05),
          border: Border.all(color: cc.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: cc, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¿Cinco minutos para contarnos cómo va?',
                    style: TextStyle(
                      color: cc,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                'Tu feedback ayuda a mejorar la app para toda la '
                'comunidad de cebras.',
                style: TextStyle(
                  color: cc.withValues(alpha: 0.75),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cc.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _onSnooze,
                    child: Text(
                      'Ahora no',
                      style: TextStyle(color: cc.withValues(alpha: 0.75)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cc,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _onShareFeedback,
                    child: Text(
                      'Compartir feedback',
                      style: TextStyle(color: ic, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
