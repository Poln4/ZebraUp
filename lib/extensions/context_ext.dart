import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

extension LocalizedBuildContext on BuildContext {
  /// Allows shortcut access to translations via context.l10n
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
