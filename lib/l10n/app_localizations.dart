import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @navHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get navHoy;

  /// No description provided for @navSintomas.
  ///
  /// In es, this message translates to:
  /// **'Síntomas'**
  String get navSintomas;

  /// No description provided for @navMovimiento.
  ///
  /// In es, this message translates to:
  /// **'Movimiento'**
  String get navMovimiento;

  /// No description provided for @navBotiquin.
  ///
  /// In es, this message translates to:
  /// **'Botiquín'**
  String get navBotiquin;

  /// No description provided for @navClinica.
  ///
  /// In es, this message translates to:
  /// **'Clínica'**
  String get navClinica;

  /// No description provided for @actionCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get actionSave;

  /// No description provided for @actionImport.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get actionImport;

  /// No description provided for @actionContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get actionContinue;

  /// No description provided for @actionUnderstood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get actionUnderstood;

  /// No description provided for @languageSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'IDIOMA / LANGUAGE'**
  String get languageSectionTitle;

  /// No description provided for @languageFootnote.
  ///
  /// In es, this message translates to:
  /// **'El idioma se aplica a toda la aplicación. Tus datos no cambian.'**
  String get languageFootnote;

  /// No description provided for @myDataTitle.
  ///
  /// In es, this message translates to:
  /// **'MIS DATOS'**
  String get myDataTitle;

  /// No description provided for @arcoRightsBlurb.
  ///
  /// In es, this message translates to:
  /// **'Tienes derecho a acceder, exportar, importar o eliminar tus datos en cualquier momento.'**
  String get arcoRightsBlurb;

  /// No description provided for @exportDataButton.
  ///
  /// In es, this message translates to:
  /// **'EXPORTAR MIS DATOS'**
  String get exportDataButton;

  /// No description provided for @importFileButton.
  ///
  /// In es, this message translates to:
  /// **'IMPORTAR DESDE ARCHIVO'**
  String get importFileButton;

  /// No description provided for @importPasteButton.
  ///
  /// In es, this message translates to:
  /// **'IMPORTAR PEGANDO TEXTO'**
  String get importPasteButton;

  /// No description provided for @wipeAllButton.
  ///
  /// In es, this message translates to:
  /// **'BORRAR TODO'**
  String get wipeAllButton;

  /// No description provided for @wipeWarningFootnote.
  ///
  /// In es, this message translates to:
  /// **'Esta acción borra todos los perfiles, registros y configuraciones. Irreversible.'**
  String get wipeWarningFootnote;

  /// No description provided for @exportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Datos exportados: {filename}'**
  String exportSuccess(String filename);

  /// No description provided for @exportError.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar: {reason}'**
  String exportError(String reason);

  /// No description provided for @importCancelled.
  ///
  /// In es, this message translates to:
  /// **'Importación cancelada: {reason}'**
  String importCancelled(String reason);

  /// No description provided for @importSuccess.
  ///
  /// In es, this message translates to:
  /// **'Perfil importado correctamente.'**
  String get importSuccess;

  /// No description provided for @importDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Importar este perfil'**
  String get importDialogTitle;

  /// No description provided for @importDialogName.
  ///
  /// In es, this message translates to:
  /// **'Nombre: {name}'**
  String importDialogName(String name);

  /// No description provided for @importDialogExportedAt.
  ///
  /// In es, this message translates to:
  /// **'Exportado: {date}'**
  String importDialogExportedAt(String date);

  /// No description provided for @importDialogContains.
  ///
  /// In es, this message translates to:
  /// **'Contiene {count} registros:'**
  String importDialogContains(int count);

  /// No description provided for @importDialogFootnote.
  ///
  /// In es, this message translates to:
  /// **'Esto se agregará como un perfil nuevo. Tu perfil actual no se borra.'**
  String get importDialogFootnote;

  /// No description provided for @nounSymptoms.
  ///
  /// In es, this message translates to:
  /// **'síntomas'**
  String get nounSymptoms;

  /// No description provided for @nounDoses.
  ///
  /// In es, this message translates to:
  /// **'dosis'**
  String get nounDoses;

  /// No description provided for @nounStructural.
  ///
  /// In es, this message translates to:
  /// **'eventos estructurales'**
  String get nounStructural;

  /// No description provided for @nounActivities.
  ///
  /// In es, this message translates to:
  /// **'actividades'**
  String get nounActivities;

  /// No description provided for @nounTherapies.
  ///
  /// In es, this message translates to:
  /// **'terapias'**
  String get nounTherapies;

  /// No description provided for @nounMoods.
  ///
  /// In es, this message translates to:
  /// **'estados de ánimo'**
  String get nounMoods;

  /// No description provided for @nounMental.
  ///
  /// In es, this message translates to:
  /// **'registros mentales'**
  String get nounMental;

  /// No description provided for @pasteImportTitle.
  ///
  /// In es, this message translates to:
  /// **'Importar pegando texto'**
  String get pasteImportTitle;

  /// No description provided for @pasteImportInstructions.
  ///
  /// In es, this message translates to:
  /// **'Abre tu archivo .json exportado (por ejemplo, desde la app Archivos), selecciona todo el texto, cópialo y pégalo aquí.'**
  String get pasteImportInstructions;

  /// No description provided for @pasteImportHint.
  ///
  /// In es, this message translates to:
  /// **'Pega aquí el contenido del archivo…'**
  String get pasteImportHint;

  /// No description provided for @errImportUnreadable.
  ///
  /// In es, this message translates to:
  /// **'No se pudo leer el archivo.'**
  String get errImportUnreadable;

  /// No description provided for @errImportInvalidJson.
  ///
  /// In es, this message translates to:
  /// **'El texto no es JSON válido.'**
  String get errImportInvalidJson;

  /// No description provided for @errImportNotZebra.
  ///
  /// In es, this message translates to:
  /// **'Este archivo no parece ser de ZebraUpp.'**
  String get errImportNotZebra;

  /// No description provided for @errImportUnknownSchema.
  ///
  /// In es, this message translates to:
  /// **'Versión de esquema desconocida.'**
  String get errImportUnknownSchema;

  /// No description provided for @errImportSchemaMismatch.
  ///
  /// In es, this message translates to:
  /// **'Este archivo es de una versión diferente (v{found}). Versión esperada: v{expected}.'**
  String errImportSchemaMismatch(String found, String expected);

  /// No description provided for @errImportMissingProfile.
  ///
  /// In es, this message translates to:
  /// **'No se encontró perfil en el archivo.'**
  String get errImportMissingProfile;

  /// No description provided for @errImportCorruptProfile.
  ///
  /// In es, this message translates to:
  /// **'El perfil está dañado o tiene un formato inesperado.'**
  String get errImportCorruptProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
