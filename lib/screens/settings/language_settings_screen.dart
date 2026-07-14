// Sprint P.C — Language, its own top-level settings subsection.
//
// Previously lived buried inside the About screen alongside app
// description text — moved out because language is a setting people
// reach for often (vs. About, which you read once). One tap from the
// settings menu, not a scroll-and-hunt.

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class LanguageSettingsScreen extends StatelessWidget {
  final Color contrastColor;
  final Color inverseContrastColor;
  final Locale currentLocale;
  final ValueChanged<Locale> onChangeLocale;

  const LanguageSettingsScreen({
    super.key,
    required this.contrastColor,
    required this.inverseContrastColor,
    required this.currentLocale,
    required this.onChangeLocale,
  });

  static const _locales = [
    (Locale('es'), 'Español'),
    (Locale('en'), 'English'),
    (Locale('zh', 'TW'), '繁體中文'),
  ];

  @override
  Widget build(BuildContext context) {
    final cc = contrastColor;
    final ic = inverseContrastColor;
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
                      t.languageSectionTitle,
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _locales.map((opt) {
                        final isSelected =
                            currentLocale.languageCode == opt.$1.languageCode;
                        return InkWell(
                          onTap: () => onChangeLocale(opt.$1),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? cc : Colors.transparent,
                              border: Border.all(color: cc.withValues(alpha: 0.4)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              opt.$2,
                              style: TextStyle(
                                color: isSelected ? ic : cc.withValues(alpha: 0.8),
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.languageFootnote,
                      style: TextStyle(
                        color: cc.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
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
