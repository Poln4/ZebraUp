// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHoy => 'Today';

  @override
  String get navSintomas => 'Symptoms';

  @override
  String get navMovimiento => 'Movement';

  @override
  String get navBotiquin => 'Med Kit';

  @override
  String get navClinica => 'Clinical';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionImport => 'Import';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionUnderstood => 'Got it';

  @override
  String get languageSectionTitle => 'IDIOMA / LANGUAGE';

  @override
  String get languageFootnote =>
      'The language applies to the whole app. Your data does not change.';

  @override
  String get myDataTitle => 'MY DATA';

  @override
  String get arcoRightsBlurb =>
      'You have the right to access, export, import, or delete your data at any time.';

  @override
  String get exportDataButton => 'EXPORT MY DATA';

  @override
  String get importFileButton => 'IMPORT FROM FILE';

  @override
  String get importPasteButton => 'IMPORT BY PASTING TEXT';

  @override
  String get wipeAllButton => 'DELETE EVERYTHING';

  @override
  String get wipeWarningFootnote =>
      'This deletes all profiles, records, and settings. Irreversible.';

  @override
  String exportSuccess(String filename) {
    return 'Data exported: $filename';
  }

  @override
  String exportError(String reason) {
    return 'Export error: $reason';
  }

  @override
  String importCancelled(String reason) {
    return 'Import cancelled: $reason';
  }

  @override
  String get importSuccess => 'Profile imported successfully.';

  @override
  String get importDialogTitle => 'Import this profile';

  @override
  String importDialogName(String name) {
    return 'Name: $name';
  }

  @override
  String importDialogExportedAt(String date) {
    return 'Exported: $date';
  }

  @override
  String importDialogContains(int count) {
    return 'Contains $count records:';
  }

  @override
  String get importDialogFootnote =>
      'This will be added as a new profile. Your current profile is not deleted.';

  @override
  String get nounSymptoms => 'symptoms';

  @override
  String get nounDoses => 'doses';

  @override
  String get nounStructural => 'structural events';

  @override
  String get nounActivities => 'activities';

  @override
  String get nounTherapies => 'therapies';

  @override
  String get nounMoods => 'mood entries';

  @override
  String get nounMental => 'mental records';

  @override
  String get pasteImportTitle => 'Import by pasting text';

  @override
  String get pasteImportInstructions =>
      'Open your exported .json file (for example, from the Files app), select all the text, copy it, and paste it here.';

  @override
  String get pasteImportHint => 'Paste the file contents here…';

  @override
  String get errImportUnreadable => 'The file could not be read.';

  @override
  String get errImportInvalidJson => 'The text is not valid JSON.';

  @override
  String get errImportNotZebra =>
      'This file does not appear to be from ZebraUpp.';

  @override
  String get errImportUnknownSchema => 'Unknown schema version.';

  @override
  String errImportSchemaMismatch(String found, String expected) {
    return 'This file is from a different version (v$found). Expected version: v$expected.';
  }

  @override
  String get errImportMissingProfile => 'No profile found in the file.';

  @override
  String get errImportCorruptProfile =>
      'The profile is damaged or has an unexpected format.';
}
