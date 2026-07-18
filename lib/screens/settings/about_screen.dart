// Sprint P.C — About screen. Didn't exist before this refactor; the
// settings Drawer had no "about the app" section at all. Content
// condensed from README.md into neutral LatAm Spanish.
//
// The language picker used to live here but moved to its own
// LanguageSettingsScreen — language is a setting people reach for
// often, About is something you read once, so burying one inside the
// other made it harder to find.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/beta_access_service.dart';
import '../../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  final Color contrastColor;
  final Color inverseContrastColor;

  const AboutScreen({
    super.key,
    required this.contrastColor,
    required this.inverseContrastColor,
  });

  Future<void> _openFollowUpQuestionnaire() async {
    final uri = Uri.parse(BetaAccessService.followUpQuestionnaireUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openBluesky() async {
    final uri = Uri.parse(BetaAccessService.blueskyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final ic = inverseContrastColor;
    final l10n = AppLocalizations.of(context)!;
    // Follow-up questionnaire is Spanish-only (Paulina, 2026-07-18) —
    // hidden entirely outside the Spanish locale, not just untranslated.
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';

    return Scaffold(
      backgroundColor: ic,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Acerca de',
                      style: TextStyle(
                        color: cc,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: cc),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'ZebraUp',
                          style: TextStyle(
                            color: cc,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: cc.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'BETA',
                            style: TextStyle(
                              color: cc.withValues(alpha: 0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Datos clínicos, no memoria borrosa.',
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ZebraUp es una aplicación de seguimiento de salud pensada '
                      'para personas con enfermedades raras — las "cebras" de la '
                      'medicina, donde lo común no aplica. Existe para que las '
                      'consultas médicas breves rindan más: llegar con datos '
                      'concretos en vez de recuerdos difusos.',
                      style: TextStyle(color: cc, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'La construye Paulina, desarrolladora y paciente con '
                      'síndrome de Ehlers-Danlos clásico-like (clEDS), POTS y '
                      'otras condiciones. Nace de una frustración concreta: '
                      'después de una semana difícil, la memoria — afectada por '
                      'la niebla mental de la disautonomía — no alcanza para '
                      'reconstruir lo que pasó.',
                      style: TextStyle(color: cc, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Misión: ayudar a llegar a cada consulta con datos '
                      'objetivos y estructurados, para que el tiempo limitado '
                      'con el equipo médico se use en decisiones, no en '
                      'reconstruir semanas de historia.',
                      style: TextStyle(
                        color: cc,
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cc),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      icon: Icon(Icons.alternate_email, color: cc),
                      label: Text(
                        l10n.aboutBlueskyLinkLabel,
                        style: TextStyle(
                          color: cc,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: _openBluesky,
                    ),
                    if (isSpanish) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cc),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: Icon(Icons.assignment_outlined, color: cc),
                        label: Text(
                          'Cuestionario de seguimiento',
                          style: TextStyle(
                            color: cc,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        onPressed: _openFollowUpQuestionnaire,
                      ),
                    ],
                    const SizedBox(height: 28),
                    Text(
                      'zebraup.netlify.app',
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
