// Sprint B.A — Beta access code entry screen.
//
// First screen a new user sees. Warm invitational tone; not adversarial.
// A single input for the beta code + a link for users who don't have
// one to request access via Google Form.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/beta_access_state.dart';
import '../services/beta_access_service.dart';

class BetaAccessScreen extends StatefulWidget {
  /// Called with the fresh BetaAccessState after a valid code.
  /// Parent (_OnboardingGate) uses this to advance to the next
  /// screen (research consent).
  final void Function(BetaAccessState) onCodeAccepted;

  const BetaAccessScreen({super.key, required this.onCodeAccepted});

  @override
  State<BetaAccessScreen> createState() => _BetaAccessScreenState();
}

class _BetaAccessScreenState extends State<BetaAccessScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _errorText = null;
    });

    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() {
        _busy = false;
        _errorText = 'Escribe el código para continuar.';
      });
      return;
    }

    if (!BetaAccessService.validateCode(input)) {
      setState(() {
        _busy = false;
        _errorText = 'Ese código no coincide. Revisa que esté bien escrito.';
      });
      return;
    }

    // Valid code — build state and hand up to gate
    final state = BetaAccessState(
      accessGranted: true,
      grantedAt: DateTime.now(),
    );
    await BetaAccessService.saveState(state);
    if (!mounted) return;
    widget.onCodeAccepted(state);
  }

  Future<void> _openRequestForm() async {
    final uri = Uri.parse(BetaAccessService.requestCodeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    bool showLogo = MediaQuery.of(context).size.width > 400;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //  / brand
                  if (showLogo)
                    Image.asset(
                      'assets/images/zebraup_logo.png',
                      width: 120,
                      height: 120,
                    )
                  else
                    Image.asset(
                      'assets/images/favicon.png',
                      width: 56,
                      height: 56,
                  ),
                  // Title
                  Text(
                    'Bienvenida a ZebraUp',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Intro copy
                  Text(
                    'Este es un beta cerrado para pacientes con síndromes '
                    'raros y complejos — cebras que necesitan una herramienta '
                    'que aún no existe en español.\n\n'
                    'Si tienes el código de acceso, adelante. Te acompañamos '
                    'en esto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: cs.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Access code input
                  TextField(
                    controller: _controller,
                    autofocus: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.2,
                      color: cs.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Código de acceso',
                      hintText: 'Ej: xxxxxx',
                      errorText: _errorText,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 16),

                  // Submit button
                  ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Request code link
                  Divider(color: cs.onSurface.withValues(alpha: 0.15)),
                  const SizedBox(height: 16),
                  Text(
                    '¿Todavía no tienes código?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: _openRequestForm,
                    child: const Text(
                      'Pide acceso al beta',
                      style: TextStyle(fontSize: 13),
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
}
