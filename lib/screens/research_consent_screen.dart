// Sprint B.B — Research consent onboarding screen.
//
// Shown after B.A (access code). Soft-consent format — not a formal
// IRB document. Explains:
//   1. The app is local-first (data lives on your device)
//   2. Optional feedback + research use with anonymization
//   3. No personal identifiers ever shared
//   4. You can withdraw or opt out anytime
//
// If the user taps "Ahora no", researchConsentAccepted stays false
// and the app opens normally. A passive reminder in Hoy (B.C, not
// yet built) will let the user reconsider.

import 'package:flutter/material.dart';
import '../models/beta_access_state.dart';
import '../services/beta_access_service.dart';

class ResearchConsentScreen extends StatefulWidget {
  /// Current state (already has accessGranted=true from B.A).
  final BetaAccessState state;

  /// Called with the updated state after the user chooses.
  /// Parent (_OnboardingGate) uses this to advance to the app.
  final void Function(BetaAccessState) onDecision;

  const ResearchConsentScreen({
    super.key,
    required this.state,
    required this.onDecision,
  });

  @override
  State<ResearchConsentScreen> createState() => _ResearchConsentScreenState();
}

class _ResearchConsentScreenState extends State<ResearchConsentScreen> {
  bool _busy = false;

  Future<void> _accept() async {
    if (_busy) return;
    setState(() => _busy = true);

    final updated = BetaAccessState(
      accessGranted: widget.state.accessGranted,
      grantedAt: widget.state.grantedAt,
      researchConsentAccepted: true,
      researchConsentAt: DateTime.now(),
      lastFeedbackPromptAt: widget.state.lastFeedbackPromptAt,
      feedbackPromptEnabled: widget.state.feedbackPromptEnabled,
    );
    await BetaAccessService.saveState(updated);
    if (!mounted) return;
    widget.onDecision(updated);
  }

  Future<void> _decline() async {
    if (_busy) return;
    setState(() => _busy = true);

    // Persist state as-is (accepted=false) so we don't re-show this
    // screen every launch. The passive reminder in Hoy (B.C) will
    // let the user reconsider.
    final updated = BetaAccessState(
      accessGranted: widget.state.accessGranted,
      grantedAt: widget.state.grantedAt,
      researchConsentAccepted: false,
      researchConsentAt: null,
      lastFeedbackPromptAt: widget.state.lastFeedbackPromptAt,
      feedbackPromptEnabled: widget.state.feedbackPromptEnabled,
    );
    await BetaAccessService.saveState(updated);
    if (!mounted) return;
    widget.onDecision(updated);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Icon(
                    Icons.favorite_outline,
                    size: 48,
                    color: cs.onSurface.withValues(alpha: 0.85),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Un momento antes de arrancar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Queremos ser transparentes sobre cómo se usa tu '
                    'información en ZebraUp.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 4 points
                  _point(
                    context,
                    Icons.smartphone,
                    'Tus datos viven en tu dispositivo',
                    'ZebraUp es local-first: los síntomas, medicamentos '
                        'y notas que registras se guardan en tu teléfono o '
                        'navegador, no en un servidor.',
                  ),
                  _point(
                    context,
                    Icons.chat_outlined,
                    'El feedback es opcional y anónimo',
                    'Si decides compartir feedback o completar encuestas, '
                        'esa información puede usarse — anonimizada — para '
                        'mejorar la app y para investigación sobre '
                        'enfermedades raras.',
                  ),
                  _point(
                    context,
                    Icons.no_accounts,
                    'Nunca compartimos datos personales',
                    'Nombre, email y datos de identificación se mantienen '
                        'separados del contenido de la app y nunca se '
                        'publican junto a tus registros clínicos.',
                  ),
                  _point(
                    context,
                    Icons.logout,
                    'Puedes retirarte en cualquier momento',
                    'Aceptar o rechazar esto no cambia cómo funciona la '
                        'app. Y puedes cambiar de decisión más adelante desde '
                        'la configuración.',
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  ElevatedButton(
                    onPressed: _busy ? null : _accept,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'Acepto participar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _busy ? null : _decline,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'Ahora no',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _point(
    BuildContext context,
    IconData icon,
    String title,
    String body,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              icon,
              size: 22,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
