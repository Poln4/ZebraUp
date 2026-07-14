// Sprint P.C — Tracking settings, split out of the monolithic settings
// Drawer. Owns every toggle that lives on
// profile.settings.optionalTrackers: the F6 modules (sleep, hydration,
// HRV), the conditional symptom detail layers (headache/fatigue/
// abdominal — only shown when relevant to the profile), MCAS detail
// (Sprint E.E), action-tracking opt-out (Sprint F.F), and "modo
// cuidadoso" (careful_mode). All of these share the same underlying
// Map<String, bool> and toggle UI, which is why they're grouped in one
// screen rather than split further.

import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';

class TrackingSettingsScreen extends StatefulWidget {
  final Profile profile;
  final Color contrastColor;
  final Color inverseContrastColor;
  final VoidCallback onSave;
  final bool showHeadacheDetail;
  final bool showFatigueDetail;
  final bool showAbdominalDetail;

  const TrackingSettingsScreen({
    super.key,
    required this.profile,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.onSave,
    required this.showHeadacheDetail,
    required this.showFatigueDetail,
    required this.showAbdominalDetail,
  });

  @override
  State<TrackingSettingsScreen> createState() =>
      _TrackingSettingsScreenState();
}

class _TrackingSettingsScreenState extends State<TrackingSettingsScreen> {
  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.grey,
    ),
  );

  Widget _toggle({
    required Color cc,
    required String title,
    required String subtitle,
    required String key,
    bool defaultValue = false,
  }) {
    final tracked = widget.profile.settings.optionalTrackers;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: cc,
      title: Text(
        title,
        style: TextStyle(color: cc, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
      ),
      value: tracked[key] ?? defaultValue,
      onChanged: (v) {
        setState(() => tracked[key] = v);
        widget.onSave();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cc = widget.contrastColor;
    final ic = widget.inverseContrastColor;
    final t = AppLocalizations.of(context)!;

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
                      'Tracking opcional',
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
                    _sectionLabel(t.settingsOptionalModulesTitle),
                    const SizedBox(height: 4),
                    Text(
                      t.settingsOptionalModulesBlurb,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _toggle(
                      cc: cc,
                      title: t.settingsModuleSleepLabel,
                      subtitle: t.settingsModuleSleepDescription,
                      key: 'sleep',
                    ),
                    _toggle(
                      cc: cc,
                      title: t.settingsModuleHydrationLabel,
                      subtitle: t.settingsModuleHydrationDescription,
                      key: 'hydration',
                    ),
                    _toggle(
                      cc: cc,
                      title: t.settingsModuleHrvLabel,
                      subtitle: t.settingsModuleHrvDescription,
                      key: 'hrv',
                    ),
                    if (widget.showHeadacheDetail)
                      _toggle(
                        cc: cc,
                        title: t.settingsModuleHeadacheDetailLabel,
                        subtitle: t.settingsModuleHeadacheDetailDescription,
                        key: 'headache_detail',
                      ),
                    if (widget.showFatigueDetail)
                      _toggle(
                        cc: cc,
                        title: t.settingsModuleFatigueDetailLabel,
                        subtitle: t.settingsModuleFatigueDetailDescription,
                        key: 'fatigue_detail',
                      ),
                    if (widget.showAbdominalDetail)
                      _toggle(
                        cc: cc,
                        title: t.settingsModuleAbdominalDetailLabel,
                        subtitle: t.settingsModuleAbdominalDetailDescription,
                        key: 'abdominal_detail',
                      ),
                    _toggle(
                      cc: cc,
                      title: 'Detalle MCAS / alergias',
                      subtitle: 'Registra reacciones, gatillos y señales de alerta.',
                      key: 'mcas_detail',
                    ),
                    _toggle(
                      cc: cc,
                      title: 'Seguimiento de acciones',
                      subtitle:
                          'Pregunta qué hiciste después de registrar un síntoma o '
                          'evento, y cómo funcionó. Activo por defecto.',
                      key: 'action_taken',
                      defaultValue: true,
                    ),

                    const SizedBox(height: 24),
                    _sectionLabel(t.settingsViewPreferencesTitle),
                    const SizedBox(height: 8),
                    _toggle(
                      cc: cc,
                      title: t.settingsCarefulModeLabel,
                      subtitle: t.settingsCarefulModeDescription,
                      key: 'careful_mode',
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
