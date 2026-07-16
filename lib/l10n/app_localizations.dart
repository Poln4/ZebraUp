import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh'),
    Locale('zh', 'TW'),
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

  /// No description provided for @actionHide.
  ///
  /// In es, this message translates to:
  /// **'Ocultar'**
  String get actionHide;

  /// No description provided for @hintTapTip.
  ///
  /// In es, this message translates to:
  /// **'Tip: en Síntomas, toca un chip del baúl para registrar. Mantén pulsado un registro para editar.'**
  String get hintTapTip;

  /// No description provided for @sectionPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get sectionPending;

  /// No description provided for @sectionWeather.
  ///
  /// In es, this message translates to:
  /// **'EL CLIMA HOY'**
  String get sectionWeather;

  /// No description provided for @headerTodayIs.
  ///
  /// In es, this message translates to:
  /// **'Hoy es'**
  String get headerTodayIs;

  /// No description provided for @pacingActiveState.
  ///
  /// In es, this message translates to:
  /// **'Día de descanso — sin expectativas'**
  String get pacingActiveState;

  /// No description provided for @pacingInactiveState.
  ///
  /// In es, this message translates to:
  /// **'Marcar como día de descanso'**
  String get pacingInactiveState;

  /// No description provided for @outcomeCardTimePrefix.
  ///
  /// In es, this message translates to:
  /// **'Hace {hours}h tomaste'**
  String outcomeCardTimePrefix(String hours);

  /// No description provided for @outcomeCardForSymptom.
  ///
  /// In es, this message translates to:
  /// **'para tu'**
  String get outcomeCardForSymptom;

  /// No description provided for @outcomeCardInitialState.
  ///
  /// In es, this message translates to:
  /// **'Estaba en '**
  String get outcomeCardInitialState;

  /// No description provided for @outcomeCardQuestionNow.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo está ahora?'**
  String get outcomeCardQuestionNow;

  /// No description provided for @outcomeCardAttributionQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿A qué lo atribuyes?'**
  String get outcomeCardAttributionQuestion;

  /// No description provided for @outcomeActionAddFactor.
  ///
  /// In es, this message translates to:
  /// **'Otro factor'**
  String get outcomeActionAddFactor;

  /// No description provided for @sectionMentalDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles mentales'**
  String get sectionMentalDetails;

  /// No description provided for @mentalIntensitySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Intensidad ahora'**
  String get mentalIntensitySubtitle;

  /// No description provided for @summaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu día en pocas palabras'**
  String get summaryTitle;

  /// No description provided for @summaryEmptyPacing.
  ///
  /// In es, this message translates to:
  /// **'🛡️ Día de descanso. Aún no has registrado nada — está bien.'**
  String get summaryEmptyPacing;

  /// No description provided for @summaryEmptyNormal.
  ///
  /// In es, this message translates to:
  /// **'Aún no has registrado nada hoy. ¿Cómo va todo?'**
  String get summaryEmptyNormal;

  /// No description provided for @summarySymptomSingle.
  ///
  /// In es, this message translates to:
  /// **'Registraste 1 síntoma: {name} ({label}).'**
  String summarySymptomSingle(String name, String label);

  /// No description provided for @summarySymptomPlural.
  ///
  /// In es, this message translates to:
  /// **'Registraste {count} síntomas — el más fuerte fue {name} ({label}).'**
  String summarySymptomPlural(int count, String name, String label);

  /// No description provided for @summaryStructuralSingle.
  ///
  /// In es, this message translates to:
  /// **'Tuviste 1 evento estructural en {zone}.'**
  String summaryStructuralSingle(String zone);

  /// No description provided for @summaryStructuralPlural.
  ///
  /// In es, this message translates to:
  /// **'Tuviste {count} eventos estructurales hoy.'**
  String summaryStructuralPlural(int count);

  /// No description provided for @summaryDosesSentence.
  ///
  /// In es, this message translates to:
  /// **'Tomaste {totalDoses} {totalDoses, plural, one{dosis} other{dosis}}: {shown}{extraCount, plural, =0{} other{ y {extraCount} más}}.'**
  String summaryDosesSentence(int totalDoses, String shown, int extraCount);

  /// No description provided for @summaryMoodSentence.
  ///
  /// In es, this message translates to:
  /// **'Tus estados y sensaciones registradas: {statesStr}{extra}.'**
  String summaryMoodSentence(String statesStr, String extra);

  /// No description provided for @summaryPacingFooter.
  ///
  /// In es, this message translates to:
  /// **'🛡️ Te diste permiso para descansar. Eso cuenta.'**
  String get summaryPacingFooter;

  /// No description provided for @wisdomBannerTitle.
  ///
  /// In es, this message translates to:
  /// **'✨ Sabiduría cebra 🦓'**
  String get wisdomBannerTitle;

  /// No description provided for @bowelCountToday.
  ///
  /// In es, this message translates to:
  /// **'última evacuación: hoy'**
  String get bowelCountToday;

  /// No description provided for @bowelCountYesterday.
  ///
  /// In es, this message translates to:
  /// **'última evacuación: ayer'**
  String get bowelCountYesterday;

  /// No description provided for @bowelCountDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'última evacuación: hace {days} días'**
  String bowelCountDaysAgo(int days);

  /// No description provided for @distentionBannerMessage.
  ///
  /// In es, this message translates to:
  /// **'Llevas {days} días sin tránsito intestinal — la distensión y el dolor abdominal pueden acumularse.'**
  String distentionBannerMessage(int days);

  /// No description provided for @distentionBannerAction.
  ///
  /// In es, this message translates to:
  /// **'Ir a Síntomas'**
  String get distentionBannerAction;

  /// No description provided for @severityNone.
  ///
  /// In es, this message translates to:
  /// **'Ninguna'**
  String get severityNone;

  /// No description provided for @severityMild.
  ///
  /// In es, this message translates to:
  /// **'Leve'**
  String get severityMild;

  /// No description provided for @severityModerate.
  ///
  /// In es, this message translates to:
  /// **'Moderada'**
  String get severityModerate;

  /// No description provided for @severityIntense.
  ///
  /// In es, this message translates to:
  /// **'Intensa'**
  String get severityIntense;

  /// No description provided for @severityUnbearable.
  ///
  /// In es, this message translates to:
  /// **'Insoportable'**
  String get severityUnbearable;

  /// No description provided for @reasonNatural.
  ///
  /// In es, this message translates to:
  /// **'Cambio natural del síntoma'**
  String get reasonNatural;

  /// No description provided for @reasonMedicationHelped.
  ///
  /// In es, this message translates to:
  /// **'Creo que ayudó este medicamento'**
  String get reasonMedicationHelped;

  /// No description provided for @reasonOtherTrigger.
  ///
  /// In es, this message translates to:
  /// **'Otro gatillo (comida, estrés, clima…)'**
  String get reasonOtherTrigger;

  /// No description provided for @reasonAdditionalMed.
  ///
  /// In es, this message translates to:
  /// **'Tomé otro medicamento también'**
  String get reasonAdditionalMed;

  /// No description provided for @reasonUnsure.
  ///
  /// In es, this message translates to:
  /// **'Sin certeza absoluta'**
  String get reasonUnsure;

  /// No description provided for @mentalStateMood.
  ///
  /// In es, this message translates to:
  /// **'Ánimo'**
  String get mentalStateMood;

  /// No description provided for @mentalStateAnxiety.
  ///
  /// In es, this message translates to:
  /// **'Ansiedad'**
  String get mentalStateAnxiety;

  /// No description provided for @mentalStateBrainFog.
  ///
  /// In es, this message translates to:
  /// **'Niebla mental'**
  String get mentalStateBrainFog;

  /// No description provided for @mentalStateDissociation.
  ///
  /// In es, this message translates to:
  /// **'Disociación'**
  String get mentalStateDissociation;

  /// No description provided for @mentalStateIrritability.
  ///
  /// In es, this message translates to:
  /// **'Irritabilidad'**
  String get mentalStateIrritability;

  /// No description provided for @mentalStateEmotionalEnergy.
  ///
  /// In es, this message translates to:
  /// **'Energía emocional'**
  String get mentalStateEmotionalEnergy;

  /// No description provided for @outcomeCoarsePending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get outcomeCoarsePending;

  /// No description provided for @outcomeCoarseMuchBetter.
  ///
  /// In es, this message translates to:
  /// **'Mucho mejor'**
  String get outcomeCoarseMuchBetter;

  /// No description provided for @outcomeCoarseBetter.
  ///
  /// In es, this message translates to:
  /// **'Mejor'**
  String get outcomeCoarseBetter;

  /// No description provided for @outcomeCoarseEqual.
  ///
  /// In es, this message translates to:
  /// **'Igual'**
  String get outcomeCoarseEqual;

  /// No description provided for @outcomeCoarseWorse.
  ///
  /// In es, this message translates to:
  /// **'Peor'**
  String get outcomeCoarseWorse;

  /// No description provided for @outcomeCoarseMuchWorse.
  ///
  /// In es, this message translates to:
  /// **'Mucho peor'**
  String get outcomeCoarseMuchWorse;

  /// No description provided for @pubMedNoAuthor.
  ///
  /// In es, this message translates to:
  /// **'Sin autoría registrada'**
  String get pubMedNoAuthor;

  /// No description provided for @quadrantActivatedUnpleasant.
  ///
  /// In es, this message translates to:
  /// **'activación · malestar'**
  String get quadrantActivatedUnpleasant;

  /// No description provided for @quadrantActivatedPleasant.
  ///
  /// In es, this message translates to:
  /// **'activación · bienestar'**
  String get quadrantActivatedPleasant;

  /// No description provided for @quadrantCalmUnpleasant.
  ///
  /// In es, this message translates to:
  /// **'calma · malestar'**
  String get quadrantCalmUnpleasant;

  /// No description provided for @quadrantCalpleasant.
  ///
  /// In es, this message translates to:
  /// **'calma · bienestar'**
  String get quadrantCalpleasant;

  /// No description provided for @quadrantTeaserActivatedUnpleasant.
  ///
  /// In es, this message translates to:
  /// **'tensión, ansiedad'**
  String get quadrantTeaserActivatedUnpleasant;

  /// No description provided for @quadrantTeaserActivatedPleasant.
  ///
  /// In es, this message translates to:
  /// **'energía, alegría'**
  String get quadrantTeaserActivatedPleasant;

  /// No description provided for @quadrantTeaserCalmUnpleasant.
  ///
  /// In es, this message translates to:
  /// **'agotamiento, tristeza'**
  String get quadrantTeaserCalmUnpleasant;

  /// No description provided for @quadrantTeaserCalmPleasant.
  ///
  /// In es, this message translates to:
  /// **'tranquilidad, paz'**
  String get quadrantTeaserCalmPleasant;

  /// No description provided for @bowelBucketConstipation.
  ///
  /// In es, this message translates to:
  /// **'estreñimiento'**
  String get bowelBucketConstipation;

  /// No description provided for @bowelBucketNormal.
  ///
  /// In es, this message translates to:
  /// **'normal'**
  String get bowelBucketNormal;

  /// No description provided for @bowelBucketDiarrhea.
  ///
  /// In es, this message translates to:
  /// **'diarrea'**
  String get bowelBucketDiarrhea;

  /// No description provided for @sleepQualityBad.
  ///
  /// In es, this message translates to:
  /// **'mal'**
  String get sleepQualityBad;

  /// No description provided for @sleepQualityRegular.
  ///
  /// In es, this message translates to:
  /// **'regular'**
  String get sleepQualityRegular;

  /// No description provided for @sleepQualityGood.
  ///
  /// In es, this message translates to:
  /// **'bien'**
  String get sleepQualityGood;

  /// No description provided for @sleepQualityVeryGood.
  ///
  /// In es, this message translates to:
  /// **'muy bien'**
  String get sleepQualityVeryGood;

  /// No description provided for @beverageWater.
  ///
  /// In es, this message translates to:
  /// **'agua'**
  String get beverageWater;

  /// No description provided for @beverageElectrolyte.
  ///
  /// In es, this message translates to:
  /// **'electrolitos'**
  String get beverageElectrolyte;

  /// No description provided for @beverageCoffee.
  ///
  /// In es, this message translates to:
  /// **'café'**
  String get beverageCoffee;

  /// No description provided for @beverageOther.
  ///
  /// In es, this message translates to:
  /// **'otro'**
  String get beverageOther;

  /// No description provided for @sodiumPinch.
  ///
  /// In es, this message translates to:
  /// **'pizca de sal'**
  String get sodiumPinch;

  /// No description provided for @sodiumSachet.
  ///
  /// In es, this message translates to:
  /// **'sobre de electrolitos'**
  String get sodiumSachet;

  /// No description provided for @sodiumSaltySnack.
  ///
  /// In es, this message translates to:
  /// **'snack salado'**
  String get sodiumSaltySnack;

  /// No description provided for @hrvContextMorning.
  ///
  /// In es, this message translates to:
  /// **'matinal'**
  String get hrvContextMorning;

  /// No description provided for @hrvContextAfternoon.
  ///
  /// In es, this message translates to:
  /// **'tarde'**
  String get hrvContextAfternoon;

  /// No description provided for @hrvContextEvening.
  ///
  /// In es, this message translates to:
  /// **'noche'**
  String get hrvContextEvening;

  /// No description provided for @hrvContextPostExercise.
  ///
  /// In es, this message translates to:
  /// **'post-ejercicio'**
  String get hrvContextPostExercise;

  /// No description provided for @hrvContextOther.
  ///
  /// In es, this message translates to:
  /// **'otro'**
  String get hrvContextOther;

  /// No description provided for @legacyIntensityLabel.
  ///
  /// In es, this message translates to:
  /// **'Intensidad anterior: {value}/5'**
  String legacyIntensityLabel(String value);

  /// No description provided for @botiquinTabTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu botiquín'**
  String get botiquinTabTitle;

  /// No description provided for @botiquinActionCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear medicamento'**
  String get botiquinActionCreate;

  /// No description provided for @botiquinSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar medicamento...'**
  String get botiquinSearchHint;

  /// No description provided for @botiquinSearchNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron medicamentos'**
  String get botiquinSearchNoResults;

  /// No description provided for @botiquinInteractionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Interacciones detectadas'**
  String get botiquinInteractionsTitle;

  /// No description provided for @botiquinGroupsTitle.
  ///
  /// In es, this message translates to:
  /// **'Grupos'**
  String get botiquinGroupsTitle;

  /// No description provided for @botiquinGroupsEmptyHeadline.
  ///
  /// In es, this message translates to:
  /// **'🌙 Meds de la noche · ☀️ Meds de la mañana'**
  String get botiquinGroupsEmptyHeadline;

  /// No description provided for @botiquinGroupsEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Agrupa los medicamentos que tomas juntos. Un toque registra todas las dosis a la vez.'**
  String get botiquinGroupsEmptyBody;

  /// No description provided for @botiquinActionCreateGroup.
  ///
  /// In es, this message translates to:
  /// **'Crear grupo'**
  String get botiquinActionCreateGroup;

  /// No description provided for @botiquinNoMedsDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin medicamentos'**
  String get botiquinNoMedsDialogTitle;

  /// No description provided for @botiquinNoMedsDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Crea al menos un medicamento en tu botiquín antes de formar un grupo.'**
  String get botiquinNoMedsDialogBody;

  /// No description provided for @botiquinRowMedsCountLabel.
  ///
  /// In es, this message translates to:
  /// **'{count} {count, plural, one{medicamento} other{medicamentos}}'**
  String botiquinRowMedsCountLabel(int count);

  /// No description provided for @botiquinActionEditTooltip.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get botiquinActionEditTooltip;

  /// No description provided for @botiquinBatchSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar grupo'**
  String get botiquinBatchSheetTitle;

  /// No description provided for @botiquinBatchSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Se registrarán estas dosis:'**
  String get botiquinBatchSheetSubtitle;

  /// No description provided for @botiquinBatchOrphanWarning.
  ///
  /// In es, this message translates to:
  /// **'⚠️ {count} {count, plural, one{medicamento eliminado} other{medicamentos eliminados}} del botiquín — se {count, plural, one{omitirá} other{omitirán}}.'**
  String botiquinBatchOrphanWarning(int count);

  /// No description provided for @botiquinBatchActionSubmit.
  ///
  /// In es, this message translates to:
  /// **'Registrar {count} {count, plural, one{dosis} other{dosis}}'**
  String botiquinBatchActionSubmit(int count);

  /// No description provided for @botiquinEmptyStateHeadline.
  ///
  /// In es, this message translates to:
  /// **'Aún no has añadido medicamentos'**
  String get botiquinEmptyStateHeadline;

  /// No description provided for @botiquinEmptyStateSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea uno con el botón de abajo.'**
  String get botiquinEmptyStateSubtitle;

  /// No description provided for @botiquinDoseLoggedTodayBadge.
  ///
  /// In es, this message translates to:
  /// **'{qty} hoy'**
  String botiquinDoseLoggedTodayBadge(String qty);

  /// No description provided for @botiquinDeleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar {name}?'**
  String botiquinDeleteConfirmTitle(String name);

  /// No description provided for @botiquinDeleteConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Se conservará el historial de dosis para tus reportes, pero {name} se quitará de tu botiquín.'**
  String botiquinDeleteConfirmBody(String name);

  /// No description provided for @botiquinActionDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get botiquinActionDelete;

  /// No description provided for @botiquinLogDoseSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar dosis'**
  String get botiquinLogDoseSheetTitle;

  /// No description provided for @botiquinLogDoseTotalCalculated.
  ///
  /// In es, this message translates to:
  /// **'= {total} {unit} total'**
  String botiquinLogDoseTotalCalculated(String total, String unit);

  /// No description provided for @botiquinLogDoseSymptomPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Para un síntoma específico?'**
  String get botiquinLogDoseSymptomPrompt;

  /// No description provided for @botiquinLogDoseSymptomNone.
  ///
  /// In es, this message translates to:
  /// **'Ninguno'**
  String get botiquinLogDoseSymptomNone;

  /// No description provided for @botiquinLogDoseTrackOutcomeToggle.
  ///
  /// In es, this message translates to:
  /// **'Preguntar en {hours}h si ayudó'**
  String botiquinLogDoseTrackOutcomeToggle(int hours);

  /// No description provided for @botiquinDoseListTitle.
  ///
  /// In es, this message translates to:
  /// **'Dosis de hoy'**
  String get botiquinDoseListTitle;

  /// No description provided for @botiquinDoseListFootnote.
  ///
  /// In es, this message translates to:
  /// **'Toca × para eliminar una dosis específica (útil si registraste mal el nombre).'**
  String get botiquinDoseListFootnote;

  /// No description provided for @botiquinDoseItemDeleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar esta dosis'**
  String get botiquinDoseItemDeleteConfirmTitle;

  /// No description provided for @botiquinDoseItemDeleteConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar la dosis de {name} registrada a las {time}? Esta acción no se puede deshacer.'**
  String botiquinDoseItemDeleteConfirmBody(String name, String time);

  /// No description provided for @botiquinTimeTodayAt.
  ///
  /// In es, this message translates to:
  /// **'Hoy a las {time}'**
  String botiquinTimeTodayAt(String time);

  /// No description provided for @botiquinTimePastAt.
  ///
  /// In es, this message translates to:
  /// **'{day}/{month} a las {time}'**
  String botiquinTimePastAt(int day, int month, String time);

  /// No description provided for @onboardingActionBack.
  ///
  /// In es, this message translates to:
  /// **'atrás'**
  String get onboardingActionBack;

  /// No description provided for @onboardingActionSkip.
  ///
  /// In es, this message translates to:
  /// **'saltar'**
  String get onboardingActionSkip;

  /// No description provided for @onboardingActionNext.
  ///
  /// In es, this message translates to:
  /// **'SIGUIENTE'**
  String get onboardingActionNext;

  /// No description provided for @onboardingActionFinish.
  ///
  /// In es, this message translates to:
  /// **'EMPEZAR'**
  String get onboardingActionFinish;

  /// No description provided for @onboardingFallbackProfileName.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get onboardingFallbackProfileName;

  /// No description provided for @onboardingStepWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'ZebraUp'**
  String get onboardingStepWelcomeTitle;

  /// No description provided for @onboardingStepWelcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu copiloto para las citas médicas.'**
  String get onboardingStepWelcomeSubtitle;

  /// No description provided for @onboardingStepWelcomeBody.
  ///
  /// In es, this message translates to:
  /// **'Las consultas son cortas. Tu memoria, después de una semana difícil, también. ZebraUp registra tus síntomas, medicamentos y patrones para que llegues a cada cita con datos concretos — no con frases sueltas que se te olvidan apenas te sientas frente al médico. Y porque sabemos que cuidas de otros, puedes agregar a tus familiares y mascotas.'**
  String get onboardingStepWelcomeBody;

  /// No description provided for @onboardingStepWelcomePrivacyNote.
  ///
  /// In es, this message translates to:
  /// **'Todos tus datos se guardan en este dispositivo. No subimos nada a internet.'**
  String get onboardingStepWelcomePrivacyNote;

  /// No description provided for @onboardingStepWelcomeMedicalDisclaimer.
  ///
  /// In es, this message translates to:
  /// **'Esta aplicación no es un dispositivo médico. No diagnostica, trata, cura ni previene ninguna condición médica.'**
  String get onboardingStepWelcomeMedicalDisclaimer;

  /// No description provided for @onboardingStepNameTitle.
  ///
  /// In es, this message translates to:
  /// **'Empecemos.'**
  String get onboardingStepNameTitle;

  /// No description provided for @onboardingStepNameQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te llamamos?'**
  String get onboardingStepNameQuestion;

  /// No description provided for @onboardingStepNameFootnote.
  ///
  /// In es, this message translates to:
  /// **'Solo se usa para personalizar la app. Puedes cambiarlo después.'**
  String get onboardingStepNameFootnote;

  /// No description provided for @onboardingStepNameHint.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre o apodo'**
  String get onboardingStepNameHint;

  /// No description provided for @onboardingStepConditionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus diagnósticos.'**
  String get onboardingStepConditionsTitle;

  /// No description provided for @onboardingStepConditionsBody.
  ///
  /// In es, this message translates to:
  /// **'¿Qué condiciones manejas? Las usamos para contextualizar interacciones y reportes. Puedes agregar, editar o saltar este paso.'**
  String get onboardingStepConditionsBody;

  /// No description provided for @onboardingStepConditionsHint.
  ///
  /// In es, this message translates to:
  /// **'ej. hEDS, POTS, MCAS…'**
  String get onboardingStepConditionsHint;

  /// No description provided for @onboardingStepConditionsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no agregaste ninguno. Puedes saltar este paso.'**
  String get onboardingStepConditionsEmpty;

  /// No description provided for @onboardingStepMedsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu botiquín.'**
  String get onboardingStepMedsTitle;

  /// No description provided for @onboardingStepMedsBody.
  ///
  /// In es, this message translates to:
  /// **'Agrega los medicamentos que tomas habitualmente. Vas a poder registrar cada dosis con un toque desde la pestaña Botiquín.'**
  String get onboardingStepMedsBody;

  /// No description provided for @onboardingStepMedsNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get onboardingStepMedsNameHint;

  /// No description provided for @onboardingStepMedsDoseHint.
  ///
  /// In es, this message translates to:
  /// **'Notas (ej. tomar con comida)'**
  String get onboardingStepMedsDoseHint;

  /// No description provided for @onboardingStepMedsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin medicamentos por ahora. Puedes saltar este paso.'**
  String get onboardingStepMedsEmpty;

  /// No description provided for @symptomsSectionStructuralZones.
  ///
  /// In es, this message translates to:
  /// **'ZONAS ESTRUCTURALES'**
  String get symptomsSectionStructuralZones;

  /// No description provided for @symptomsSectionBowelTransit.
  ///
  /// In es, this message translates to:
  /// **'TRÁNSITO INTESTINAL'**
  String get symptomsSectionBowelTransit;

  /// No description provided for @symptomsActionAddHemorrhoid.
  ///
  /// In es, this message translates to:
  /// **'hemorroide'**
  String get symptomsActionAddHemorrhoid;

  /// No description provided for @symptomsSectionTodaysLogs.
  ///
  /// In es, this message translates to:
  /// **'REGISTROS DE HOY'**
  String get symptomsSectionTodaysLogs;

  /// No description provided for @symptomsFootnoteLongPressEdit.
  ///
  /// In es, this message translates to:
  /// **'Mantén presionado un registro para editar fecha/gravedad/nota.'**
  String get symptomsFootnoteLongPressEdit;

  /// No description provided for @symptomsSectionTrending.
  ///
  /// In es, this message translates to:
  /// **'EN TENDENCIA (ÚLTIMOS 7 DÍAS)'**
  String get symptomsSectionTrending;

  /// No description provided for @symptomsTrendingEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay síntomas consistentes esta semana.'**
  String get symptomsTrendingEmpty;

  /// No description provided for @symptomsSectionVault.
  ///
  /// In es, this message translates to:
  /// **'BAÚL DE SÍNTOMAS'**
  String get symptomsSectionVault;

  /// No description provided for @symptomsVaultPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'+ Añadir síntoma al baúl...'**
  String get symptomsVaultPlaceholder;

  /// No description provided for @symptomsModalLogHeader.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR EN: {zone}'**
  String symptomsModalLogHeader(String zone);

  /// No description provided for @symptomsModalEditHeader.
  ///
  /// In es, this message translates to:
  /// **'EDITAR: {zone} / {type}'**
  String symptomsModalEditHeader(String zone, String type);

  /// No description provided for @symptomsModalEditSymptomHeader.
  ///
  /// In es, this message translates to:
  /// **'EDITAR: {name}'**
  String symptomsModalEditSymptomHeader(String name);

  /// No description provided for @symptomsLabelOptionalNote.
  ///
  /// In es, this message translates to:
  /// **'Nota opcional (contexto, gatillo, etc.)'**
  String get symptomsLabelOptionalNote;

  /// No description provided for @symptomsLabelOptionalNoteSimple.
  ///
  /// In es, this message translates to:
  /// **'Nota opcional'**
  String get symptomsLabelOptionalNoteSimple;

  /// No description provided for @symptomsLabelSeverityGrading.
  ///
  /// In es, this message translates to:
  /// **'GRAVEDAD'**
  String get symptomsLabelSeverityGrading;

  /// No description provided for @symptomsActionLogUnrated.
  ///
  /// In es, this message translates to:
  /// **'Registrar sin rating'**
  String get symptomsActionLogUnrated;

  /// No description provided for @symptomsUnratedLabelSuffix.
  ///
  /// In es, this message translates to:
  /// **'sin rating'**
  String get symptomsUnratedLabelSuffix;

  /// No description provided for @symptomsUnratedInlineWarning.
  ///
  /// In es, this message translates to:
  /// **'Este registro no tiene rating. Toca un punto para asignar uno.'**
  String get symptomsUnratedInlineWarning;

  /// No description provided for @symptomsActionSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR CAMBIOS'**
  String get symptomsActionSaveChanges;

  /// No description provided for @symptomsActionSave.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR'**
  String get symptomsActionSave;

  /// No description provided for @zoneCervical.
  ///
  /// In es, this message translates to:
  /// **'Cervicales'**
  String get zoneCervical;

  /// No description provided for @zoneHombros.
  ///
  /// In es, this message translates to:
  /// **'Hombros'**
  String get zoneHombros;

  /// No description provided for @zoneMunecas.
  ///
  /// In es, this message translates to:
  /// **'Muñecas'**
  String get zoneMunecas;

  /// No description provided for @zoneManos.
  ///
  /// In es, this message translates to:
  /// **'Manos'**
  String get zoneManos;

  /// No description provided for @zoneLumbarPelvis.
  ///
  /// In es, this message translates to:
  /// **'Lumbar/Pelvis'**
  String get zoneLumbarPelvis;

  /// No description provided for @zoneCaderas.
  ///
  /// In es, this message translates to:
  /// **'Caderas'**
  String get zoneCaderas;

  /// No description provided for @zoneRodillas.
  ///
  /// In es, this message translates to:
  /// **'Rodillas'**
  String get zoneRodillas;

  /// No description provided for @zoneTobillos.
  ///
  /// In es, this message translates to:
  /// **'Tobillos'**
  String get zoneTobillos;

  /// No description provided for @structTypeSubluxation.
  ///
  /// In es, this message translates to:
  /// **'Subluxación'**
  String get structTypeSubluxation;

  /// No description provided for @structTypeDislocation.
  ///
  /// In es, this message translates to:
  /// **'Dislocación'**
  String get structTypeDislocation;

  /// No description provided for @structTypeInstability.
  ///
  /// In es, this message translates to:
  /// **'Inestabilidad Articular'**
  String get structTypeInstability;

  /// No description provided for @structTypeJointPain.
  ///
  /// In es, this message translates to:
  /// **'Dolor Articular'**
  String get structTypeJointPain;

  /// No description provided for @structTypeMyofascial.
  ///
  /// In es, this message translates to:
  /// **'Dolor Miofascial'**
  String get structTypeMyofascial;

  /// No description provided for @structTypeNeuropathic.
  ///
  /// In es, this message translates to:
  /// **'Dolor Neuropático'**
  String get structTypeNeuropathic;

  /// No description provided for @bowelLabelBristolType.
  ///
  /// In es, this message translates to:
  /// **'tipo {type}'**
  String bowelLabelBristolType(String type);

  /// No description provided for @bowelLabelUrgency.
  ///
  /// In es, this message translates to:
  /// **'urgencia'**
  String get bowelLabelUrgency;

  /// No description provided for @bowelLabelBleeding.
  ///
  /// In es, this message translates to:
  /// **'sangrado'**
  String get bowelLabelBleeding;

  /// No description provided for @bowelLabelIncomplete.
  ///
  /// In es, this message translates to:
  /// **'incompleta'**
  String get bowelLabelIncomplete;

  /// No description provided for @movementSectionPacingActive.
  ///
  /// In es, this message translates to:
  /// **'Hoy es día de descanso. Descansar también cuenta.'**
  String get movementSectionPacingActive;

  /// No description provided for @movementSectionHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'HOY HICISTE…'**
  String get movementSectionHistoryTitle;

  /// No description provided for @movementFootnoteLongPressEdit.
  ///
  /// In es, this message translates to:
  /// **'Mantén presionado un registro para editar.'**
  String get movementFootnoteLongPressEdit;

  /// No description provided for @movementEmptyStateHeadline.
  ///
  /// In es, this message translates to:
  /// **'Movimiento y recuperación son lo mismo.'**
  String get movementEmptyStateHeadline;

  /// No description provided for @movementEmptyStateSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Caminar, estirar, una sesión de kinesio, un masaje — todo cuenta como cuidado del cuerpo.'**
  String get movementEmptyStateSubtitle;

  /// No description provided for @movementSectionActivityTitle.
  ///
  /// In es, this message translates to:
  /// **'ACTIVIDAD'**
  String get movementSectionActivityTitle;

  /// No description provided for @movementActivityPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'+ Añadir actividad (natación, bici, baile…)'**
  String get movementActivityPlaceholder;

  /// No description provided for @movementSectionTherapyTitle.
  ///
  /// In es, this message translates to:
  /// **'TERAPIA'**
  String get movementSectionTherapyTitle;

  /// No description provided for @movementTherapyPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'+ Añadir modalidad (reiki, flotación…)'**
  String get movementTherapyPlaceholder;

  /// No description provided for @activityModalLogHeader.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR: {name}'**
  String activityModalLogHeader(String name);

  /// No description provided for @activityModalEditHeader.
  ///
  /// In es, this message translates to:
  /// **'EDITAR: {name}'**
  String activityModalEditHeader(String name);

  /// No description provided for @activityFieldDurationHint.
  ///
  /// In es, this message translates to:
  /// **'Duración (min)'**
  String get activityFieldDurationHint;

  /// No description provided for @activityFieldSetsHint.
  ///
  /// In es, this message translates to:
  /// **'Sets'**
  String get activityFieldSetsHint;

  /// No description provided for @activityFieldRepsHint.
  ///
  /// In es, this message translates to:
  /// **'Reps'**
  String get activityFieldRepsHint;

  /// No description provided for @activityFieldHhrHint.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia cardíaca opcional (ej. 70→110)'**
  String get activityFieldHhrHint;

  /// No description provided for @activityLabelEffortSlider.
  ///
  /// In es, this message translates to:
  /// **'Esfuerzo: {value}/10'**
  String activityLabelEffortSlider(int value);

  /// No description provided for @activityLabelFeelingSlider.
  ///
  /// In es, this message translates to:
  /// **'Cómo me sentí: {value}/5'**
  String activityLabelFeelingSlider(int value);

  /// No description provided for @activityActionTogglePainRating.
  ///
  /// In es, this message translates to:
  /// **'evaluar dolor antes/después (opcional)'**
  String get activityActionTogglePainRating;

  /// No description provided for @activityLabelPainBefore.
  ///
  /// In es, this message translates to:
  /// **'DOLOR ANTES'**
  String get activityLabelPainBefore;

  /// No description provided for @activityLabelPainAfter.
  ///
  /// In es, this message translates to:
  /// **'DOLOR DESPUÉS'**
  String get activityLabelPainAfter;

  /// No description provided for @activityActionSubmitLog.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR ACTIVIDAD'**
  String get activityActionSubmitLog;

  /// No description provided for @activityActionSubmitChanges.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR CAMBIOS'**
  String get activityActionSubmitChanges;

  /// No description provided for @painLabelNone.
  ///
  /// In es, this message translates to:
  /// **'nada'**
  String get painLabelNone;

  /// No description provided for @painLabelMild.
  ///
  /// In es, this message translates to:
  /// **'leve'**
  String get painLabelMild;

  /// No description provided for @painLabelModerate.
  ///
  /// In es, this message translates to:
  /// **'moderado'**
  String get painLabelModerate;

  /// No description provided for @painLabelIntense.
  ///
  /// In es, this message translates to:
  /// **'intenso'**
  String get painLabelIntense;

  /// No description provided for @painLabelSevere.
  ///
  /// In es, this message translates to:
  /// **'severo'**
  String get painLabelSevere;

  /// No description provided for @painDeltaLabelImproved.
  ///
  /// In es, this message translates to:
  /// **'Mejoraste {count} {count, plural, one{nivel} other{niveles}}'**
  String painDeltaLabelImproved(int count);

  /// No description provided for @painDeltaLabelWorsened.
  ///
  /// In es, this message translates to:
  /// **'Empeoraste {count} {count, plural, one{nivel} other{niveles}}'**
  String painDeltaLabelWorsened(int count);

  /// No description provided for @painDeltaLabelUnchanged.
  ///
  /// In es, this message translates to:
  /// **'Sin cambios'**
  String get painDeltaLabelUnchanged;

  /// No description provided for @logSubtitleMetricDuration.
  ///
  /// In es, this message translates to:
  /// **'{minutes}min'**
  String logSubtitleMetricDuration(int minutes);

  /// No description provided for @logSubtitleMetricSetsReps.
  ///
  /// In es, this message translates to:
  /// **'{sets}×{reps}'**
  String logSubtitleMetricSetsReps(String sets, String reps);

  /// No description provided for @logSubtitleActivityTemplate.
  ///
  /// In es, this message translates to:
  /// **'{detail} · esfuerzo {effort}/10 · sentir {feeling}/5{painSuffix}'**
  String logSubtitleActivityTemplate(
    String detail,
    int effort,
    int feeling,
    String pain,
    Object painSuffix,
  );

  /// No description provided for @logSubtitlePainDeltaImproved.
  ///
  /// In es, this message translates to:
  /// **'↓{levels} niv.'**
  String logSubtitlePainDeltaImproved(int levels);

  /// No description provided for @logSubtitlePainDeltaWorsened.
  ///
  /// In es, this message translates to:
  /// **'↑{levels} niv.'**
  String logSubtitlePainDeltaWorsened(int levels);

  /// No description provided for @logSubtitlePainDeltaUnchanged.
  ///
  /// In es, this message translates to:
  /// **'sin cambio'**
  String get logSubtitlePainDeltaUnchanged;

  /// No description provided for @feelingLabelLevel1.
  ///
  /// In es, this message translates to:
  /// **'🤕 En dolor / lesión'**
  String get feelingLabelLevel1;

  /// No description provided for @feelingLabelLevel2.
  ///
  /// In es, this message translates to:
  /// **'😟 Incomodidad / preocupación'**
  String get feelingLabelLevel2;

  /// No description provided for @feelingLabelLevel3.
  ///
  /// In es, this message translates to:
  /// **'😐 Neutralidad'**
  String get feelingLabelLevel3;

  /// No description provided for @feelingLabelLevel4.
  ///
  /// In es, this message translates to:
  /// **'😊 Relajación'**
  String get feelingLabelLevel4;

  /// No description provided for @feelingLabelLevel5.
  ///
  /// In es, this message translates to:
  /// **'💪 Fuerza y seguridad'**
  String get feelingLabelLevel5;

  /// No description provided for @onboardingHaveProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo un perfil guardado'**
  String get onboardingHaveProfileTitle;

  /// No description provided for @onboardingHaveProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Importar desde un archivo JSON'**
  String get onboardingHaveProfileSubtitle;

  /// No description provided for @onboardingImportChoiceTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo importar?'**
  String get onboardingImportChoiceTitle;

  /// No description provided for @onboardingImportFromFile.
  ///
  /// In es, this message translates to:
  /// **'Desde archivo'**
  String get onboardingImportFromFile;

  /// No description provided for @onboardingImportFromPaste.
  ///
  /// In es, this message translates to:
  /// **'Pegar texto'**
  String get onboardingImportFromPaste;

  /// No description provided for @feverSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'FIEBRE'**
  String get feverSectionTitle;

  /// No description provided for @feverActionAddReading.
  ///
  /// In es, this message translates to:
  /// **'+ medir temperatura'**
  String get feverActionAddReading;

  /// No description provided for @feverModalLogHeader.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR TEMPERATURA'**
  String get feverModalLogHeader;

  /// No description provided for @feverModalEditHeader.
  ///
  /// In es, this message translates to:
  /// **'EDITAR LECTURA'**
  String get feverModalEditHeader;

  /// No description provided for @feverFieldSiteLabel.
  ///
  /// In es, this message translates to:
  /// **'SITIO'**
  String get feverFieldSiteLabel;

  /// No description provided for @feverFieldAntipyreticLabel.
  ///
  /// In es, this message translates to:
  /// **'ANTIPIRÉTICO'**
  String get feverFieldAntipyreticLabel;

  /// No description provided for @feverFieldAntipyreticToggle.
  ///
  /// In es, this message translates to:
  /// **'tomé algo para bajarla'**
  String get feverFieldAntipyreticToggle;

  /// No description provided for @feverFieldAntipyreticNameHint.
  ///
  /// In es, this message translates to:
  /// **'nombre (paracetamol, ibuprofeno...)'**
  String get feverFieldAntipyreticNameHint;

  /// No description provided for @feverHintTapToEdit.
  ///
  /// In es, this message translates to:
  /// **'tocá el número para editar'**
  String get feverHintTapToEdit;

  /// No description provided for @feverDirectEditDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar temperatura'**
  String get feverDirectEditDialogTitle;

  /// No description provided for @feverDirectEditDialogHint.
  ///
  /// In es, this message translates to:
  /// **'ej. 38.7'**
  String get feverDirectEditDialogHint;

  /// No description provided for @feverLogLabelWithAntipyretic.
  ///
  /// In es, this message translates to:
  /// **'con antipirético'**
  String get feverLogLabelWithAntipyretic;

  /// No description provided for @feverSiteAxillary.
  ///
  /// In es, this message translates to:
  /// **'axilar'**
  String get feverSiteAxillary;

  /// No description provided for @feverSiteOral.
  ///
  /// In es, this message translates to:
  /// **'oral'**
  String get feverSiteOral;

  /// No description provided for @feverSiteTympanic.
  ///
  /// In es, this message translates to:
  /// **'timpánica'**
  String get feverSiteTympanic;

  /// No description provided for @feverSiteRectal.
  ///
  /// In es, this message translates to:
  /// **'rectal'**
  String get feverSiteRectal;

  /// No description provided for @feverSiteForehead.
  ///
  /// In es, this message translates to:
  /// **'frente'**
  String get feverSiteForehead;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In es, this message translates to:
  /// **'hace {minutes} min'**
  String timeAgoMinutes(int minutes);

  /// No description provided for @timeAgoHours.
  ///
  /// In es, this message translates to:
  /// **'hace {hours}h'**
  String timeAgoHours(int hours);

  /// No description provided for @researchEmptyConfig.
  ///
  /// In es, this message translates to:
  /// **'Añade un diagnóstico en configuración para ver investigación relevante.'**
  String get researchEmptyConfig;

  /// No description provided for @researchTitleRecent.
  ///
  /// In es, this message translates to:
  /// **'Resultados recientes de PubMed'**
  String get researchTitleRecent;

  /// No description provided for @researchDisclaimer.
  ///
  /// In es, this message translates to:
  /// **'Desliza para actualizar. Solo informativo, no es consejo médico.'**
  String get researchDisclaimer;

  /// No description provided for @researchTooltipOffline.
  ///
  /// In es, this message translates to:
  /// **'Resultados guardados (sin conexión)'**
  String get researchTooltipOffline;

  /// No description provided for @researchStateNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos. Tira hacia abajo para buscar.'**
  String get researchStateNoData;

  /// No description provided for @researchStateNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron resultados recientes.'**
  String get researchStateNoResults;

  /// No description provided for @researchLastUpdated.
  ///
  /// In es, this message translates to:
  /// **'Actualizado: {time}'**
  String researchLastUpdated(String time);

  /// No description provided for @researchActionSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardado'**
  String get researchActionSaved;

  /// No description provided for @researchActionSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get researchActionSave;

  /// No description provided for @researchActionOpenPubMed.
  ///
  /// In es, this message translates to:
  /// **'Abrir en PubMed'**
  String get researchActionOpenPubMed;

  /// No description provided for @researchActionCopyPmid.
  ///
  /// In es, this message translates to:
  /// **'Copiar PMID'**
  String get researchActionCopyPmid;

  /// No description provided for @researchSnackPmidCopied.
  ///
  /// In es, this message translates to:
  /// **'PMID {pmid} copiado.'**
  String researchSnackPmidCopied(String pmid);

  /// No description provided for @researchLoadingAbstract.
  ///
  /// In es, this message translates to:
  /// **'Cargando resumen…'**
  String get researchLoadingAbstract;

  /// No description provided for @researchEmptyAbstract.
  ///
  /// In es, this message translates to:
  /// **'Resumen no disponible. Abre el artículo en PubMed para más detalles.'**
  String get researchEmptyAbstract;

  /// No description provided for @reportRangeDay.
  ///
  /// In es, this message translates to:
  /// **'1 día'**
  String get reportRangeDay;

  /// No description provided for @reportRangeWeek.
  ///
  /// In es, this message translates to:
  /// **'7 días'**
  String get reportRangeWeek;

  /// No description provided for @reportRangeMonth.
  ///
  /// In es, this message translates to:
  /// **'30 días'**
  String get reportRangeMonth;

  /// No description provided for @reportRangeCustomTooltip.
  ///
  /// In es, this message translates to:
  /// **'Rango personalizado'**
  String get reportRangeCustomTooltip;

  /// No description provided for @reportRangeCustomActiveLabel.
  ///
  /// In es, this message translates to:
  /// **'Rango: {start} → {end}'**
  String reportRangeCustomActiveLabel(String start, String end);

  /// No description provided for @structKindJoint.
  ///
  /// In es, this message translates to:
  /// **'Articulación'**
  String get structKindJoint;

  /// No description provided for @structKindMuscle.
  ///
  /// In es, this message translates to:
  /// **'Músculo'**
  String get structKindMuscle;

  /// No description provided for @structKindTendon.
  ///
  /// In es, this message translates to:
  /// **'Tendón'**
  String get structKindTendon;

  /// No description provided for @structKindLigament.
  ///
  /// In es, this message translates to:
  /// **'Ligamento'**
  String get structKindLigament;

  /// No description provided for @structKindSoftTissue.
  ///
  /// In es, this message translates to:
  /// **'Tejido blando'**
  String get structKindSoftTissue;

  /// No description provided for @structKindNerve.
  ///
  /// In es, this message translates to:
  /// **'Nervio'**
  String get structKindNerve;

  /// No description provided for @structKindPainWithoutClearCause.
  ///
  /// In es, this message translates to:
  /// **'Dolor sin causa estructural clara'**
  String get structKindPainWithoutClearCause;

  /// No description provided for @structTypeMuscleStrain.
  ///
  /// In es, this message translates to:
  /// **'Tirón muscular'**
  String get structTypeMuscleStrain;

  /// No description provided for @structTypeMuscleDistension.
  ///
  /// In es, this message translates to:
  /// **'Distensión muscular'**
  String get structTypeMuscleDistension;

  /// No description provided for @structTypeMuscleTear.
  ///
  /// In es, this message translates to:
  /// **'Desgarro muscular'**
  String get structTypeMuscleTear;

  /// No description provided for @structTypeContracture.
  ///
  /// In es, this message translates to:
  /// **'Contractura'**
  String get structTypeContracture;

  /// No description provided for @structTypeMuscleSpasm.
  ///
  /// In es, this message translates to:
  /// **'Espasmo muscular'**
  String get structTypeMuscleSpasm;

  /// No description provided for @structTypeTendinitis.
  ///
  /// In es, this message translates to:
  /// **'Tendinitis'**
  String get structTypeTendinitis;

  /// No description provided for @structTypeTendinosis.
  ///
  /// In es, this message translates to:
  /// **'Tendinosis'**
  String get structTypeTendinosis;

  /// No description provided for @structTypeBursitis.
  ///
  /// In es, this message translates to:
  /// **'Bursitis'**
  String get structTypeBursitis;

  /// No description provided for @structTypeEnthesitis.
  ///
  /// In es, this message translates to:
  /// **'Entesitis'**
  String get structTypeEnthesitis;

  /// No description provided for @structTypeTendonFissure.
  ///
  /// In es, this message translates to:
  /// **'Fisura tendinosa'**
  String get structTypeTendonFissure;

  /// No description provided for @structTypeMildSprain.
  ///
  /// In es, this message translates to:
  /// **'Esguince leve'**
  String get structTypeMildSprain;

  /// No description provided for @structTypeSevereSprain.
  ///
  /// In es, this message translates to:
  /// **'Esguince grave'**
  String get structTypeSevereSprain;

  /// No description provided for @structTypeLigamentTear.
  ///
  /// In es, this message translates to:
  /// **'Desgarro ligamentario'**
  String get structTypeLigamentTear;

  /// No description provided for @structTypeSuperficialCut.
  ///
  /// In es, this message translates to:
  /// **'Corte superficial'**
  String get structTypeSuperficialCut;

  /// No description provided for @structTypeSkinFissure.
  ///
  /// In es, this message translates to:
  /// **'Fisura cutánea'**
  String get structTypeSkinFissure;

  /// No description provided for @structTypeDeepWound.
  ///
  /// In es, this message translates to:
  /// **'Herida profunda'**
  String get structTypeDeepWound;

  /// No description provided for @structTypeHematoma.
  ///
  /// In es, this message translates to:
  /// **'Hematoma'**
  String get structTypeHematoma;

  /// No description provided for @structTypeContusion.
  ///
  /// In es, this message translates to:
  /// **'Contusión'**
  String get structTypeContusion;

  /// No description provided for @structTypeBurn.
  ///
  /// In es, this message translates to:
  /// **'Quemadura'**
  String get structTypeBurn;

  /// No description provided for @structTypeAbrasion.
  ///
  /// In es, this message translates to:
  /// **'Abrasión'**
  String get structTypeAbrasion;

  /// No description provided for @structTypeParesthesia.
  ///
  /// In es, this message translates to:
  /// **'Parestesia'**
  String get structTypeParesthesia;

  /// No description provided for @structTypeUnclearCause.
  ///
  /// In es, this message translates to:
  /// **'Dolor sin causa estructural clara'**
  String get structTypeUnclearCause;

  /// No description provided for @structTypeKnownConditionFlare.
  ///
  /// In es, this message translates to:
  /// **'Episodio de condición conocida'**
  String get structTypeKnownConditionFlare;

  /// No description provided for @structTypeMuscleGeneral.
  ///
  /// In es, this message translates to:
  /// **'Dolor muscular'**
  String get structTypeMuscleGeneral;

  /// No description provided for @structTypeTendonGeneral.
  ///
  /// In es, this message translates to:
  /// **'Dolor de tendón'**
  String get structTypeTendonGeneral;

  /// No description provided for @structTypeLigamentGeneral.
  ///
  /// In es, this message translates to:
  /// **'Dolor de ligamento'**
  String get structTypeLigamentGeneral;

  /// No description provided for @structTypeSoftTissueGeneral.
  ///
  /// In es, this message translates to:
  /// **'Dolor de tejido blando'**
  String get structTypeSoftTissueGeneral;

  /// No description provided for @structTypeNerveGeneral.
  ///
  /// In es, this message translates to:
  /// **'Dolor nervioso'**
  String get structTypeNerveGeneral;

  /// No description provided for @structuralZonePickTitle.
  ///
  /// In es, this message translates to:
  /// **'¿En qué zona?'**
  String get structuralZonePickTitle;

  /// No description provided for @structuralZonePickSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Toca la zona donde sientes el dolor.'**
  String get structuralZonePickSubtitle;

  /// No description provided for @structuralKindPickTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tipo de dolor es?'**
  String get structuralKindPickTitle;

  /// No description provided for @structuralKindPickSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige la opción que más se acerque. Si no sabes, puedes elegir \"sin causa clara\".'**
  String get structuralKindPickSubtitle;

  /// No description provided for @structuralSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle del dolor'**
  String get structuralSheetTitle;

  /// No description provided for @structuralSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos más sobre este dolor, con tus propias palabras.'**
  String get structuralSheetSubtitle;

  /// No description provided for @structuralKnownTermShortcut.
  ///
  /// In es, this message translates to:
  /// **'Ya sé qué es'**
  String get structuralKnownTermShortcut;

  /// No description provided for @structuralBleedingSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle del sangrado o moretón'**
  String get structuralBleedingSheetTitle;

  /// No description provided for @structuralBleedingSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos el origen y qué tan grave fue.'**
  String get structuralBleedingSheetSubtitle;

  /// No description provided for @structuralBleedingLogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo fue esta vez?'**
  String get structuralBleedingLogTitle;

  /// No description provided for @structuralBleedingLogSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Origen y gravedad de este episodio.'**
  String get structuralBleedingLogSubtitle;

  /// No description provided for @structuralQuickLogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tan intenso está hoy?'**
  String get structuralQuickLogTitle;

  /// No description provided for @structuralQuickLogSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes un antecedente guardado para esta zona.'**
  String get structuralQuickLogSubtitle;

  /// No description provided for @structuralQuickLogNewIssueLink.
  ///
  /// In es, this message translates to:
  /// **'¿Es un problema nuevo o distinto? Descríbelo aparte'**
  String get structuralQuickLogNewIssueLink;

  /// No description provided for @structuralComparedToUsualWorse.
  ///
  /// In es, this message translates to:
  /// **'Peor que de costumbre'**
  String get structuralComparedToUsualWorse;

  /// No description provided for @structuralComparedToUsualNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal para mí'**
  String get structuralComparedToUsualNormal;

  /// No description provided for @structuralComparedToUsualBetter.
  ///
  /// In es, this message translates to:
  /// **'Mejor que de costumbre'**
  String get structuralComparedToUsualBetter;

  /// No description provided for @structuralZoneHistoryFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar antecedente de zona'**
  String get structuralZoneHistoryFormTitle;

  /// No description provided for @structuralZoneHistoryFormEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar antecedente de zona'**
  String get structuralZoneHistoryFormEditTitle;

  /// No description provided for @structuralZoneHistoryZoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Zona'**
  String get structuralZoneHistoryZoneLabel;

  /// No description provided for @structuralZoneHistoryKindLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get structuralZoneHistoryKindLabel;

  /// No description provided for @structuralZoneHistoryDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Descripción (ej. post-quirúrgica, 2 cirugías)'**
  String get structuralZoneHistoryDescriptionHint;

  /// No description provided for @structuralZoneHistoryDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha aproximada (opcional)'**
  String get structuralZoneHistoryDateLabel;

  /// No description provided for @structuralZoneHistorySaveAction.
  ///
  /// In es, this message translates to:
  /// **'Guardar antecedente'**
  String get structuralZoneHistorySaveAction;

  /// No description provided for @structuralZoneHistoryOfferTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Guardar esto como algo que ya conoces?'**
  String get structuralZoneHistoryOfferTitle;

  /// No description provided for @structuralZoneHistoryOfferBody.
  ///
  /// In es, this message translates to:
  /// **'La próxima vez que registres dolor en esta zona, puedes saltar directo a la severidad.'**
  String get structuralZoneHistoryOfferBody;

  /// No description provided for @structuralZoneHistoryOfferAccept.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get structuralZoneHistoryOfferAccept;

  /// No description provided for @structuralZoneHistoryOfferDecline.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get structuralZoneHistoryOfferDecline;

  /// No description provided for @structuralZoneHistorySectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial estructural por zona'**
  String get structuralZoneHistorySectionTitle;

  /// No description provided for @structuralZoneHistoryAddAction.
  ///
  /// In es, this message translates to:
  /// **'Agregar antecedente'**
  String get structuralZoneHistoryAddAction;

  /// No description provided for @structuralZoneHistoryEmptyState.
  ///
  /// In es, this message translates to:
  /// **'Sin antecedentes guardados todavía.'**
  String get structuralZoneHistoryEmptyState;

  /// No description provided for @sleepSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'SUEÑO'**
  String get sleepSectionTitle;

  /// No description provided for @sleepActionAddEntry.
  ///
  /// In es, this message translates to:
  /// **'+ registrar sueño'**
  String get sleepActionAddEntry;

  /// No description provided for @sleepModalLogHeader.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR SUEÑO'**
  String get sleepModalLogHeader;

  /// No description provided for @sleepModalEditHeader.
  ///
  /// In es, this message translates to:
  /// **'EDITAR SUEÑO'**
  String get sleepModalEditHeader;

  /// No description provided for @sleepFieldQualityLabel.
  ///
  /// In es, this message translates to:
  /// **'CALIDAD'**
  String get sleepFieldQualityLabel;

  /// No description provided for @sleepFieldDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'DURACIÓN'**
  String get sleepFieldDurationLabel;

  /// No description provided for @sleepFieldDurationHint.
  ///
  /// In es, this message translates to:
  /// **'horas (ej. 7.5)'**
  String get sleepFieldDurationHint;

  /// No description provided for @sleepFieldOnsetLatencyLabel.
  ///
  /// In es, this message translates to:
  /// **'TIEMPO EN DORMIRSE'**
  String get sleepFieldOnsetLatencyLabel;

  /// No description provided for @sleepFieldOnsetLatencyHint.
  ///
  /// In es, this message translates to:
  /// **'minutos'**
  String get sleepFieldOnsetLatencyHint;

  /// No description provided for @sleepFieldWakeCountLabel.
  ///
  /// In es, this message translates to:
  /// **'DESPERTARES'**
  String get sleepFieldWakeCountLabel;

  /// No description provided for @sleepFieldNightmareToggle.
  ///
  /// In es, this message translates to:
  /// **'tuve pesadilla(s)'**
  String get sleepFieldNightmareToggle;

  /// No description provided for @sleepLogLabelSlept.
  ///
  /// In es, this message translates to:
  /// **'dormí'**
  String get sleepLogLabelSlept;

  /// No description provided for @sleepLogLabelHours.
  ///
  /// In es, this message translates to:
  /// **'{hours}h'**
  String sleepLogLabelHours(String hours);

  /// No description provided for @sleepLogLabelWakes.
  ///
  /// In es, this message translates to:
  /// **'{count}× despertares'**
  String sleepLogLabelWakes(int count);

  /// No description provided for @sleepLogLabelOnsetLatency.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min para dormir'**
  String sleepLogLabelOnsetLatency(int minutes);

  /// No description provided for @sleepLogLabelWithNightmare.
  ///
  /// In es, this message translates to:
  /// **'pesadilla'**
  String get sleepLogLabelWithNightmare;

  /// No description provided for @settingsOptionalModulesTitle.
  ///
  /// In es, this message translates to:
  /// **'MÓDULOS OPCIONALES'**
  String get settingsOptionalModulesTitle;

  /// No description provided for @settingsOptionalModulesBlurb.
  ///
  /// In es, this message translates to:
  /// **'Activa solo lo que quieras trackear. Los módulos desactivados no aparecen en Síntomas.'**
  String get settingsOptionalModulesBlurb;

  /// No description provided for @settingsModuleSleepLabel.
  ///
  /// In es, this message translates to:
  /// **'Sueño'**
  String get settingsModuleSleepLabel;

  /// No description provided for @settingsModuleSleepDescription.
  ///
  /// In es, this message translates to:
  /// **'Calidad, duración y despertares por noche.'**
  String get settingsModuleSleepDescription;

  /// No description provided for @bodyRegionHeadNeck.
  ///
  /// In es, this message translates to:
  /// **'Cabeza y cuello'**
  String get bodyRegionHeadNeck;

  /// No description provided for @bodyRegionShouldersUpperBack.
  ///
  /// In es, this message translates to:
  /// **'Hombros y espalda alta'**
  String get bodyRegionShouldersUpperBack;

  /// No description provided for @bodyRegionArms.
  ///
  /// In es, this message translates to:
  /// **'Brazos'**
  String get bodyRegionArms;

  /// No description provided for @bodyRegionChestAbdomen.
  ///
  /// In es, this message translates to:
  /// **'Pecho y abdomen'**
  String get bodyRegionChestAbdomen;

  /// No description provided for @bodyRegionLowerBackPelvis.
  ///
  /// In es, this message translates to:
  /// **'Espalda baja y pelvis'**
  String get bodyRegionLowerBackPelvis;

  /// No description provided for @bodyRegionLegs.
  ///
  /// In es, this message translates to:
  /// **'Piernas'**
  String get bodyRegionLegs;

  /// No description provided for @zoneJaw.
  ///
  /// In es, this message translates to:
  /// **'Mandíbula'**
  String get zoneJaw;

  /// No description provided for @zoneTemple.
  ///
  /// In es, this message translates to:
  /// **'Sien'**
  String get zoneTemple;

  /// No description provided for @zoneShoulderBlades.
  ///
  /// In es, this message translates to:
  /// **'Omóplatos'**
  String get zoneShoulderBlades;

  /// No description provided for @zoneUpperBack.
  ///
  /// In es, this message translates to:
  /// **'Espalda alta'**
  String get zoneUpperBack;

  /// No description provided for @zoneUpperArm.
  ///
  /// In es, this message translates to:
  /// **'Brazo'**
  String get zoneUpperArm;

  /// No description provided for @zoneElbow.
  ///
  /// In es, this message translates to:
  /// **'Codo'**
  String get zoneElbow;

  /// No description provided for @zoneForearm.
  ///
  /// In es, this message translates to:
  /// **'Antebrazo'**
  String get zoneForearm;

  /// No description provided for @zoneChest.
  ///
  /// In es, this message translates to:
  /// **'Pecho'**
  String get zoneChest;

  /// No description provided for @zoneSide.
  ///
  /// In es, this message translates to:
  /// **'Costado'**
  String get zoneSide;

  /// No description provided for @zoneRibs.
  ///
  /// In es, this message translates to:
  /// **'Costillas'**
  String get zoneRibs;

  /// No description provided for @zoneAbdomen.
  ///
  /// In es, this message translates to:
  /// **'Abdomen'**
  String get zoneAbdomen;

  /// No description provided for @zoneGlutes.
  ///
  /// In es, this message translates to:
  /// **'Glúteos'**
  String get zoneGlutes;

  /// No description provided for @zoneFrontThigh.
  ///
  /// In es, this message translates to:
  /// **'Muslo (delante)'**
  String get zoneFrontThigh;

  /// No description provided for @zoneBackThigh.
  ///
  /// In es, this message translates to:
  /// **'Atrás del muslo'**
  String get zoneBackThigh;

  /// No description provided for @zoneCalf.
  ///
  /// In es, this message translates to:
  /// **'Pantorrilla'**
  String get zoneCalf;

  /// No description provided for @zoneFeet.
  ///
  /// In es, this message translates to:
  /// **'Pies'**
  String get zoneFeet;

  /// No description provided for @hydrationSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'HIDRATACIÓN'**
  String get hydrationSectionTitle;

  /// No description provided for @hydrationActionAddEntry.
  ///
  /// In es, this message translates to:
  /// **'+ registrar hidratación'**
  String get hydrationActionAddEntry;

  /// No description provided for @hydrationModalLogHeader.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR HIDRATACIÓN'**
  String get hydrationModalLogHeader;

  /// No description provided for @hydrationModalEditHeader.
  ///
  /// In es, this message translates to:
  /// **'EDITAR HIDRATACIÓN'**
  String get hydrationModalEditHeader;

  /// No description provided for @hydrationFieldVolumeLabel.
  ///
  /// In es, this message translates to:
  /// **'CANTIDAD'**
  String get hydrationFieldVolumeLabel;

  /// No description provided for @hydrationFieldVolumeHint.
  ///
  /// In es, this message translates to:
  /// **'ml (ej. 250)'**
  String get hydrationFieldVolumeHint;

  /// No description provided for @hydrationFieldBeverageLabel.
  ///
  /// In es, this message translates to:
  /// **'BEBIDA'**
  String get hydrationFieldBeverageLabel;

  /// No description provided for @hydrationFieldSodiumLabel.
  ///
  /// In es, this message translates to:
  /// **'SODIO (opcional)'**
  String get hydrationFieldSodiumLabel;

  /// No description provided for @hydrationLogLabelVolume.
  ///
  /// In es, this message translates to:
  /// **'{volume} ml'**
  String hydrationLogLabelVolume(String volume);

  /// No description provided for @hrvSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'HRV'**
  String get hrvSectionTitle;

  /// No description provided for @hrvActionAddEntry.
  ///
  /// In es, this message translates to:
  /// **'+ registrar HRV'**
  String get hrvActionAddEntry;

  /// No description provided for @hrvModalLogHeader.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR LECTURA HRV'**
  String get hrvModalLogHeader;

  /// No description provided for @hrvModalEditHeader.
  ///
  /// In es, this message translates to:
  /// **'EDITAR LECTURA HRV'**
  String get hrvModalEditHeader;

  /// No description provided for @hrvFieldRmssdLabel.
  ///
  /// In es, this message translates to:
  /// **'RMSSD'**
  String get hrvFieldRmssdLabel;

  /// No description provided for @hrvFieldContextLabel.
  ///
  /// In es, this message translates to:
  /// **'CONTEXTO'**
  String get hrvFieldContextLabel;

  /// No description provided for @hrvFieldSourceLabel.
  ///
  /// In es, this message translates to:
  /// **'FUENTE'**
  String get hrvFieldSourceLabel;

  /// No description provided for @hrvHintTapToEdit.
  ///
  /// In es, this message translates to:
  /// **'tocá el número para editar'**
  String get hrvHintTapToEdit;

  /// No description provided for @hrvDirectEditDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar RMSSD'**
  String get hrvDirectEditDialogTitle;

  /// No description provided for @hrvDirectEditDialogHint.
  ///
  /// In es, this message translates to:
  /// **'ej. 35'**
  String get hrvDirectEditDialogHint;

  /// No description provided for @hrvLogLabelRmssd.
  ///
  /// In es, this message translates to:
  /// **'{value} ms'**
  String hrvLogLabelRmssd(String value);

  /// No description provided for @hrvSourceManual.
  ///
  /// In es, this message translates to:
  /// **'manual'**
  String get hrvSourceManual;

  /// No description provided for @hrvSourceAppleWatch.
  ///
  /// In es, this message translates to:
  /// **'Apple Watch'**
  String get hrvSourceAppleWatch;

  /// No description provided for @hrvSourceWelltory.
  ///
  /// In es, this message translates to:
  /// **'Welltory'**
  String get hrvSourceWelltory;

  /// No description provided for @hrvSourceOther.
  ///
  /// In es, this message translates to:
  /// **'otro'**
  String get hrvSourceOther;

  /// No description provided for @settingsModuleHydrationLabel.
  ///
  /// In es, this message translates to:
  /// **'Hidratación'**
  String get settingsModuleHydrationLabel;

  /// No description provided for @settingsModuleHydrationDescription.
  ///
  /// In es, this message translates to:
  /// **'Volumen, bebida y aporte de sodio.'**
  String get settingsModuleHydrationDescription;

  /// No description provided for @settingsModuleHrvLabel.
  ///
  /// In es, this message translates to:
  /// **'HRV'**
  String get settingsModuleHrvLabel;

  /// No description provided for @settingsModuleHrvDescription.
  ///
  /// In es, this message translates to:
  /// **'Variabilidad cardíaca por contexto y fuente.'**
  String get settingsModuleHrvDescription;

  /// No description provided for @sectionHintNoActivity.
  ///
  /// In es, this message translates to:
  /// **'sin registros aún'**
  String get sectionHintNoActivity;

  /// No description provided for @sectionHintToday.
  ///
  /// In es, this message translates to:
  /// **'último hoy'**
  String get sectionHintToday;

  /// No description provided for @sectionHintYesterday.
  ///
  /// In es, this message translates to:
  /// **'último ayer'**
  String get sectionHintYesterday;

  /// No description provided for @sectionHintDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'último hace {days, plural, =1{1 día} other{{days} días}}'**
  String sectionHintDaysAgo(int days);

  /// No description provided for @settingsViewPreferencesTitle.
  ///
  /// In es, this message translates to:
  /// **'VISUALIZACIÓN'**
  String get settingsViewPreferencesTitle;

  /// No description provided for @settingsCarefulModeLabel.
  ///
  /// In es, this message translates to:
  /// **'Modo cuidadoso'**
  String get settingsCarefulModeLabel;

  /// No description provided for @settingsCarefulModeDescription.
  ///
  /// In es, this message translates to:
  /// **'Reduce el ruido visual: las secciones empiezan colapsadas. Tap el header para expandir lo que quieras ver.'**
  String get settingsCarefulModeDescription;

  /// No description provided for @drugKindMedication.
  ///
  /// In es, this message translates to:
  /// **'Medicamento'**
  String get drugKindMedication;

  /// No description provided for @drugKindSupplement.
  ///
  /// In es, this message translates to:
  /// **'Suplemento'**
  String get drugKindSupplement;

  /// No description provided for @drugKindHerbal.
  ///
  /// In es, this message translates to:
  /// **'Producto herbal'**
  String get drugKindHerbal;

  /// No description provided for @drugInteractionsInBotiquinHeader.
  ///
  /// In es, this message translates to:
  /// **'Interacciones en tu botiquín'**
  String get drugInteractionsInBotiquinHeader;

  /// No description provided for @drugInteractionSeverityHigh.
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get drugInteractionSeverityHigh;

  /// No description provided for @drugInteractionSeverityMedium.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get drugInteractionSeverityMedium;

  /// No description provided for @drugInteractionSeverityLow.
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get drugInteractionSeverityLow;

  /// No description provided for @drugNoContentSupplement.
  ///
  /// In es, this message translates to:
  /// **'Suplemento — no regulado como medicamento. Consulta con tu equipo médico antes de combinarlo con otros tratamientos.'**
  String get drugNoContentSupplement;

  /// No description provided for @drugNoContentHerbal.
  ///
  /// In es, this message translates to:
  /// **'Producto herbal — evidencia clínica limitada. Consulta con tu equipo médico antes de combinarlo con otros tratamientos.'**
  String get drugNoContentHerbal;

  /// No description provided for @drugNoContentMedlineEmpty.
  ///
  /// In es, this message translates to:
  /// **'MedlinePlus no devolvió información para este medicamento (RxCUI {rxcui}). Puede ser un problema temporal o que la base no tenga contenido para este código.'**
  String drugNoContentMedlineEmpty(String rxcui);

  /// No description provided for @drugNoContentUnmapped.
  ///
  /// In es, this message translates to:
  /// **'Aún no tenemos información detallada para este producto. Puedes buscarlo manualmente en medlineplus.gov/spanish.'**
  String get drugNoContentUnmapped;

  /// No description provided for @drugNoContentGeneric.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la información.'**
  String get drugNoContentGeneric;

  /// No description provided for @drugReadMoreMedlinePlus.
  ///
  /// In es, this message translates to:
  /// **'Leer más en MedlinePlus'**
  String get drugReadMoreMedlinePlus;

  /// No description provided for @drugBrowserOpenError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el navegador. Revisa tu conexión.'**
  String get drugBrowserOpenError;

  /// No description provided for @drugConfidenceMediumWarning.
  ///
  /// In es, this message translates to:
  /// **'Mapeo de confianza media — verifica con tu equipo médico si la información no coincide con tu medicamento.'**
  String get drugConfidenceMediumWarning;

  /// No description provided for @drugSourceLocalCurated.
  ///
  /// In es, this message translates to:
  /// **'Fuente: información clínica curada localmente para esta app. No reemplaza consejo médico.'**
  String get drugSourceLocalCurated;

  /// No description provided for @drugSourceMedlinePlus.
  ///
  /// In es, this message translates to:
  /// **'Fuente: MedlinePlus, Biblioteca Nacional de Medicina de EE.UU. No reemplaza consejo médico.'**
  String get drugSourceMedlinePlus;

  /// No description provided for @drugSourceNoInfo.
  ///
  /// In es, this message translates to:
  /// **'Sin información clínica disponible en nuestras fuentes.'**
  String get drugSourceNoInfo;

  /// No description provided for @drugLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la información.'**
  String get drugLoadError;

  /// No description provided for @conditionSourceLocalCurated.
  ///
  /// In es, this message translates to:
  /// **'Fuente: información local de ZebraUp sobre esta condición. No reemplaza consejo médico.'**
  String get conditionSourceLocalCurated;

  /// No description provided for @conditionContentUnverifiedWarning.
  ///
  /// In es, this message translates to:
  /// **'Este resumen fue redactado a partir de conocimiento médico general, no de una revisión clínica confirmada. Si algo no coincide con lo que te ha dicho tu equipo médico, confía en tu equipo médico.'**
  String get conditionContentUnverifiedWarning;

  /// No description provided for @conditionNoContentUnmapped.
  ///
  /// In es, this message translates to:
  /// **'Aún no tenemos esta condición en nuestro mapa. Puedes buscarla manualmente en medlineplus.gov/spanish.'**
  String get conditionNoContentUnmapped;

  /// No description provided for @conditionNoContentNoIcd10.
  ///
  /// In es, this message translates to:
  /// **'Esta condición no tiene código ICD-10, así que no podemos consultar MedlinePlus, y todavía no tenemos un resumen local para ella.'**
  String get conditionNoContentNoIcd10;

  /// No description provided for @conditionNoContentMedlineEmpty.
  ///
  /// In es, this message translates to:
  /// **'MedlinePlus no devolvió información para esta condición. Puede ser un problema temporal o falta de contenido para este código.'**
  String get conditionNoContentMedlineEmpty;

  /// No description provided for @moodQuadrantActivatedUnpleasant.
  ///
  /// In es, this message translates to:
  /// **'activación · malestar'**
  String get moodQuadrantActivatedUnpleasant;

  /// No description provided for @moodQuadrantActivatedPleasant.
  ///
  /// In es, this message translates to:
  /// **'activación · bienestar'**
  String get moodQuadrantActivatedPleasant;

  /// No description provided for @moodQuadrantCalmUnpleasant.
  ///
  /// In es, this message translates to:
  /// **'calma · malestar'**
  String get moodQuadrantCalmUnpleasant;

  /// No description provided for @moodQuadrantCalmPleasant.
  ///
  /// In es, this message translates to:
  /// **'calma · bienestar'**
  String get moodQuadrantCalmPleasant;

  /// No description provided for @moodTeaserActivatedUnpleasant.
  ///
  /// In es, this message translates to:
  /// **'tensión, ansiedad'**
  String get moodTeaserActivatedUnpleasant;

  /// No description provided for @moodTeaserActivatedPleasant.
  ///
  /// In es, this message translates to:
  /// **'energía, alegría'**
  String get moodTeaserActivatedPleasant;

  /// No description provided for @moodTeaserCalmUnpleasant.
  ///
  /// In es, this message translates to:
  /// **'agotamiento, tristeza'**
  String get moodTeaserCalmUnpleasant;

  /// No description provided for @moodTeaserCalmPleasant.
  ///
  /// In es, this message translates to:
  /// **'tranquilidad, paz'**
  String get moodTeaserCalmPleasant;

  /// No description provided for @moodSheetStep1Title.
  ///
  /// In es, this message translates to:
  /// **'¿CÓMO TE SIENTES?'**
  String get moodSheetStep1Title;

  /// No description provided for @moodSheetCancel.
  ///
  /// In es, this message translates to:
  /// **'cancelar'**
  String get moodSheetCancel;

  /// No description provided for @moodSheetStep2Prompt.
  ///
  /// In es, this message translates to:
  /// **'¿cómo me siento?'**
  String get moodSheetStep2Prompt;

  /// No description provided for @moodSheetChangeQuadrant.
  ///
  /// In es, this message translates to:
  /// **'cambiar cuadrante'**
  String get moodSheetChangeQuadrant;

  /// No description provided for @moodSheetAlsoFeelingHeader.
  ///
  /// In es, this message translates to:
  /// **'TAMBIÉN SIENTO…'**
  String get moodSheetAlsoFeelingHeader;

  /// No description provided for @moodSheetNotesHeader.
  ///
  /// In es, this message translates to:
  /// **'CONTEXTO (OPCIONAL)'**
  String get moodSheetNotesHeader;

  /// No description provided for @moodSheetNotesPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Ej. Día con mucha niebla mental…'**
  String get moodSheetNotesPlaceholder;

  /// No description provided for @moodSheetSaveButton.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR REGISTRO'**
  String get moodSheetSaveButton;

  /// No description provided for @moodDefinitionDialogAction.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get moodDefinitionDialogAction;

  /// No description provided for @moodSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'CÓMO ESTOY'**
  String get moodSectionTitle;

  /// No description provided for @moodSectionPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te sientes?'**
  String get moodSectionPrompt;

  /// No description provided for @moodSectionRegisterAnother.
  ///
  /// In es, this message translates to:
  /// **'Registrar otro estado'**
  String get moodSectionRegisterAnother;

  /// No description provided for @severityFunctionalAnchorNone.
  ///
  /// In es, this message translates to:
  /// **'no lo noto'**
  String get severityFunctionalAnchorNone;

  /// No description provided for @severityFunctionalAnchorMild.
  ///
  /// In es, this message translates to:
  /// **'lo noto, pero no me detiene'**
  String get severityFunctionalAnchorMild;

  /// No description provided for @severityFunctionalAnchorModerate.
  ///
  /// In es, this message translates to:
  /// **'me obliga a bajar el ritmo o pausar'**
  String get severityFunctionalAnchorModerate;

  /// No description provided for @severityFunctionalAnchorIntense.
  ///
  /// In es, this message translates to:
  /// **'no puedo hacer lo que tenía planeado'**
  String get severityFunctionalAnchorIntense;

  /// No description provided for @severityFunctionalAnchorUnbearable.
  ///
  /// In es, this message translates to:
  /// **'no puedo funcionar; necesito detenerme'**
  String get severityFunctionalAnchorUnbearable;

  /// No description provided for @outcomeReasonNatural.
  ///
  /// In es, this message translates to:
  /// **'Cambio natural del síntoma'**
  String get outcomeReasonNatural;

  /// No description provided for @outcomeReasonMedicationHelped.
  ///
  /// In es, this message translates to:
  /// **'Creo que ayudó este medicamento'**
  String get outcomeReasonMedicationHelped;

  /// No description provided for @outcomeReasonOtherTrigger.
  ///
  /// In es, this message translates to:
  /// **'Otro gatillo (comida, estrés, clima…)'**
  String get outcomeReasonOtherTrigger;

  /// No description provided for @outcomeReasonAdditionalMed.
  ///
  /// In es, this message translates to:
  /// **'Tomé otro medicamento también'**
  String get outcomeReasonAdditionalMed;

  /// No description provided for @outcomeReasonUnsure.
  ///
  /// In es, this message translates to:
  /// **'No estoy seguro/a'**
  String get outcomeReasonUnsure;

  /// No description provided for @medicationOutcomeCoarsePending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get medicationOutcomeCoarsePending;

  /// No description provided for @medicationOutcomeCoarseMuchBetter.
  ///
  /// In es, this message translates to:
  /// **'Mucho mejor'**
  String get medicationOutcomeCoarseMuchBetter;

  /// No description provided for @medicationOutcomeCoarseBetter.
  ///
  /// In es, this message translates to:
  /// **'Mejor'**
  String get medicationOutcomeCoarseBetter;

  /// No description provided for @medicationOutcomeCoarseSame.
  ///
  /// In es, this message translates to:
  /// **'Igual'**
  String get medicationOutcomeCoarseSame;

  /// No description provided for @medicationOutcomeCoarseWorse.
  ///
  /// In es, this message translates to:
  /// **'Peor'**
  String get medicationOutcomeCoarseWorse;

  /// No description provided for @medicationOutcomeCoarseMuchWorse.
  ///
  /// In es, this message translates to:
  /// **'Mucho peor'**
  String get medicationOutcomeCoarseMuchWorse;

  /// No description provided for @bowelFormTitleNew.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR TRÁNSITO'**
  String get bowelFormTitleNew;

  /// No description provided for @bowelFormTitleEdit.
  ///
  /// In es, this message translates to:
  /// **'EDITAR TRÁNSITO'**
  String get bowelFormTitleEdit;

  /// No description provided for @bowelFormBristolLabel.
  ///
  /// In es, this message translates to:
  /// **'tipo Bristol'**
  String get bowelFormBristolLabel;

  /// Legend below the Bristol Stool Scale picker, showing which BSS numbers map to which bucket. Placeholders receive the localized BowelBucket labels so the legend stays in sync with the bucket cards above.
  ///
  /// In es, this message translates to:
  /// **'1-2: {constipation}  ·  3-5: {normal}  ·  6-7: {diarrhea}'**
  String bowelFormBristolLegendTemplate(
    String constipation,
    String normal,
    String diarrhea,
  );

  /// No description provided for @bowelFormHideBristolDetail.
  ///
  /// In es, this message translates to:
  /// **'ocultar detalle'**
  String get bowelFormHideBristolDetail;

  /// No description provided for @bowelFormShowBristolDetail.
  ///
  /// In es, this message translates to:
  /// **'más detalle (escala de Bristol)'**
  String get bowelFormShowBristolDetail;

  /// No description provided for @bowelFormSectionObservations.
  ///
  /// In es, this message translates to:
  /// **'OBSERVACIONES'**
  String get bowelFormSectionObservations;

  /// No description provided for @bowelFormToggleUrgency.
  ///
  /// In es, this message translates to:
  /// **'urgencia'**
  String get bowelFormToggleUrgency;

  /// No description provided for @bowelFormToggleIncompleteEvacuation.
  ///
  /// In es, this message translates to:
  /// **'evacuación incompleta'**
  String get bowelFormToggleIncompleteEvacuation;

  /// No description provided for @bowelFormNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Nota opcional (contexto, gatillo, etc.)'**
  String get bowelFormNoteHint;

  /// No description provided for @hemorrhoidalFormTitleNew.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR HEMORROIDE'**
  String get hemorrhoidalFormTitleNew;

  /// No description provided for @hemorrhoidalFormTitleEdit.
  ///
  /// In es, this message translates to:
  /// **'EDITAR HEMORROIDE'**
  String get hemorrhoidalFormTitleEdit;

  /// No description provided for @hemorrhoidalFormNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Nota opcional'**
  String get hemorrhoidalFormNoteHint;

  /// No description provided for @formSectionHeaderDiscomfort.
  ///
  /// In es, this message translates to:
  /// **'MOLESTIA'**
  String get formSectionHeaderDiscomfort;

  /// No description provided for @formToggleBleeding.
  ///
  /// In es, this message translates to:
  /// **'sangrado'**
  String get formToggleBleeding;

  /// No description provided for @formButtonSave.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR'**
  String get formButtonSave;

  /// No description provided for @structuralFormFollowupHeader.
  ///
  /// In es, this message translates to:
  /// **'SEGUIMIENTO'**
  String get structuralFormFollowupHeader;

  /// No description provided for @structuralFormFollowupResolvedQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Está resuelto?'**
  String get structuralFormFollowupResolvedQuestion;

  /// Label shown below the 'is it resolved?' switch once the user has set a resolved-at date. The {date} placeholder receives a pre-formatted date string from the Dart side (using DateFormat for the active locale).
  ///
  /// In es, this message translates to:
  /// **'Resuelto el {date}'**
  String structuralFormFollowupResolvedDateTemplate(String date);

  /// No description provided for @structuralFormFollowupStillPainfulQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Todavía duele?'**
  String get structuralFormFollowupStillPainfulQuestion;

  /// No description provided for @structuralFormFollowupStillPainfulSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cerró visiblemente pero el dolor sigue'**
  String get structuralFormFollowupStillPainfulSubtitle;

  /// Suffix shown after the bucket name in the bowel render line when the user has expanded the Bristol detail and picked a 1-7 type. Rendered inline as 'tipo 4', 'type 4', '類型 4'.
  ///
  /// In es, this message translates to:
  /// **'tipo {type}'**
  String bowelLogBristolTypeTemplate(int type);

  /// No description provided for @bowelLogTagUrgency.
  ///
  /// In es, this message translates to:
  /// **'urgencia'**
  String get bowelLogTagUrgency;

  /// No description provided for @bowelLogTagBleeding.
  ///
  /// In es, this message translates to:
  /// **'sangrado'**
  String get bowelLogTagBleeding;

  /// No description provided for @bowelLogTagIncomplete.
  ///
  /// In es, this message translates to:
  /// **'incompleta'**
  String get bowelLogTagIncomplete;

  /// No description provided for @hemorrhoidalLogLabel.
  ///
  /// In es, this message translates to:
  /// **'hemorroide'**
  String get hemorrhoidalLogLabel;

  /// No description provided for @hemorrhoidalLogTagBleeding.
  ///
  /// In es, this message translates to:
  /// **'sangrado'**
  String get hemorrhoidalLogTagBleeding;

  /// No description provided for @symptomLogTagUnrated.
  ///
  /// In es, this message translates to:
  /// **'sin rating'**
  String get symptomLogTagUnrated;

  /// No description provided for @hoySectionPendingHeader.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get hoySectionPendingHeader;

  /// Connective phrase inside the outcome card RichText. Bridges the medication name with the symptom name. In Spanish it's ' para tu ' (with leading and trailing spaces). zh-TW likely needs no spaces.
  ///
  /// In es, this message translates to:
  /// **' para tu '**
  String get hoyOutcomeForYour;

  /// No description provided for @hoyOutcomeHideReasons.
  ///
  /// In es, this message translates to:
  /// **'Ocultar'**
  String get hoyOutcomeHideReasons;

  /// No description provided for @hoyBowelCounterToday.
  ///
  /// In es, this message translates to:
  /// **'última evacuación: hoy'**
  String get hoyBowelCounterToday;

  /// No description provided for @hoyBowelCounterYesterday.
  ///
  /// In es, this message translates to:
  /// **'última evacuación: ayer'**
  String get hoyBowelCounterYesterday;

  /// Days-ago label in the bowel counter chip.
  ///
  /// In es, this message translates to:
  /// **'última evacuación: hace {days} días'**
  String hoyBowelCounterDaysAgoTemplate(int days);

  /// No description provided for @hoyNarrativeEmptyPacing.
  ///
  /// In es, this message translates to:
  /// **'🛡️ Día de descanso. Aún no has registrado nada — está bien.'**
  String get hoyNarrativeEmptyPacing;

  /// No description provided for @hoyNarrativeEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no has registrado nada hoy. ¿Cómo va todo?'**
  String get hoyNarrativeEmpty;

  /// Narrative summary when exactly 1 symptom was logged. {name} is the symptom name lowercased, {severity} is the localized severity label lowercased.
  ///
  /// In es, this message translates to:
  /// **'Registraste 1 síntoma: {name} ({severity}).'**
  String hoyNarrativeSymptomsSingleTemplate(String name, String severity);

  /// Narrative summary when 2+ symptoms were logged.
  ///
  /// In es, this message translates to:
  /// **'Registraste {count} síntomas — el más fuerte fue {name} ({severity}).'**
  String hoyNarrativeSymptomsManyTemplate(
    int count,
    String name,
    String severity,
  );

  /// Narrative summary for 1 structural event.
  ///
  /// In es, this message translates to:
  /// **'Tuviste 1 evento estructural en {zone}.'**
  String hoyNarrativeStructuralSingleTemplate(String zone);

  /// Narrative summary for 2+ structural events.
  ///
  /// In es, this message translates to:
  /// **'Tuviste {count} eventos estructurales hoy.'**
  String hoyNarrativeStructuralManyTemplate(int count);

  /// Narrative summary for 1 dose. {meds} is a pre-formatted comma-separated string of med names with quantities, e.g. 'Duloxetina (1), Sertralina (2)'.
  ///
  /// In es, this message translates to:
  /// **'Tomaste 1 dosis: {meds}.'**
  String hoyNarrativeDosesSingleTemplate(String meds);

  /// Narrative summary for 2+ doses.
  ///
  /// In es, this message translates to:
  /// **'Tomaste {count} dosis: {meds}.'**
  String hoyNarrativeDosesManyTemplate(int count, String meds);

  /// Suffix appended to the meds list when more than 3 distinct meds were taken (the rest are summarised as 'and N more').
  ///
  /// In es, this message translates to:
  /// **' y {count} más'**
  String hoyNarrativeDosesAndMore(int count);

  /// Narrative summary of mood/EMA states logged. {states} is a pre-formatted comma-separated string.
  ///
  /// In es, this message translates to:
  /// **'Tus estados y sensaciones registradas: {states}.'**
  String hoyNarrativeEmaStatesTemplate(String states);

  /// No description provided for @hoyNarrativeEmaStatesEllipsis.
  ///
  /// In es, this message translates to:
  /// **'...'**
  String get hoyNarrativeEmaStatesEllipsis;

  /// No description provided for @hoyNarrativePacingTrailer.
  ///
  /// In es, this message translates to:
  /// **'🛡️ Te diste permiso para descansar. Eso cuenta.'**
  String get hoyNarrativePacingTrailer;

  /// No description provided for @hoyHeaderDatePattern.
  ///
  /// In es, this message translates to:
  /// **'EEEE d \'de\' MMMM'**
  String get hoyHeaderDatePattern;

  /// Modal title when logging a new activity. {name} is the exercise name uppercased by the call site.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR: {name}'**
  String movementModalTitleRegisterTemplate(String name);

  /// Modal title when editing an existing activity.
  ///
  /// In es, this message translates to:
  /// **'EDITAR: {name}'**
  String movementModalTitleEditTemplate(String name);

  /// No description provided for @movementModalHintDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración (min)'**
  String get movementModalHintDuration;

  /// No description provided for @movementModalHintSets.
  ///
  /// In es, this message translates to:
  /// **'Sets'**
  String get movementModalHintSets;

  /// No description provided for @movementModalHintReps.
  ///
  /// In es, this message translates to:
  /// **'Reps'**
  String get movementModalHintReps;

  /// Hint text for the optional heart rate field. The example '70→110' (resting → peak) stays in the Spanish string and translates as needed.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia cardíaca opcional (ej. 70→110)'**
  String get movementModalHintHeartRate;

  /// Slider label showing current effort value out of 10.
  ///
  /// In es, this message translates to:
  /// **'Esfuerzo: {value}/10'**
  String movementModalEffortLabelTemplate(int value);

  /// Slider label showing current feeling value out of 5.
  ///
  /// In es, this message translates to:
  /// **'Cómo me sentí: {value}/5'**
  String movementModalFeelingLabelTemplate(int value);

  /// No description provided for @movementFeelingPainOrInjury.
  ///
  /// In es, this message translates to:
  /// **'🤕 Con dolor / lesión'**
  String get movementFeelingPainOrInjury;

  /// No description provided for @movementFeelingUncomfortable.
  ///
  /// In es, this message translates to:
  /// **'😟 Con incomodidad / preocupación'**
  String get movementFeelingUncomfortable;

  /// No description provided for @movementFeelingNeutral.
  ///
  /// In es, this message translates to:
  /// **'😐 Neutral'**
  String get movementFeelingNeutral;

  /// No description provided for @movementFeelingRelaxed.
  ///
  /// In es, this message translates to:
  /// **'😊 Bien'**
  String get movementFeelingRelaxed;

  /// No description provided for @movementFeelingStrongConfident.
  ///
  /// In es, this message translates to:
  /// **'💪 Con fuerza y seguridad'**
  String get movementFeelingStrongConfident;

  /// No description provided for @movementPainLevelNone.
  ///
  /// In es, this message translates to:
  /// **'nada'**
  String get movementPainLevelNone;

  /// No description provided for @movementPainLevelMild.
  ///
  /// In es, this message translates to:
  /// **'leve'**
  String get movementPainLevelMild;

  /// No description provided for @movementPainLevelModerate.
  ///
  /// In es, this message translates to:
  /// **'moderado'**
  String get movementPainLevelModerate;

  /// No description provided for @movementPainLevelIntense.
  ///
  /// In es, this message translates to:
  /// **'intenso'**
  String get movementPainLevelIntense;

  /// No description provided for @movementPainLevelSevere.
  ///
  /// In es, this message translates to:
  /// **'severo'**
  String get movementPainLevelSevere;

  /// Shown when post-activity pain is lower than pre. ICU plural agreement on nivel/niveles.
  ///
  /// In es, this message translates to:
  /// **'Mejoraste {delta, plural, =1{1 nivel} other{{delta} niveles}}'**
  String movementPainDeltaImprovedTemplate(int delta);

  /// Shown when post-activity pain is higher than pre.
  ///
  /// In es, this message translates to:
  /// **'Empeoraste {delta, plural, =1{1 nivel} other{{delta} niveles}}'**
  String movementPainDeltaWorseTemplate(int delta);

  /// No description provided for @movementPainDeltaUnchanged.
  ///
  /// In es, this message translates to:
  /// **'Sin cambios'**
  String get movementPainDeltaUnchanged;

  /// Compact log-row chip showing effort. Lowercased intentionally — it sits in a parts-joined sentence.
  ///
  /// In es, this message translates to:
  /// **'esfuerzo {value}/10'**
  String movementLogEntryEffortTemplate(int value);

  /// Compact log-row chip showing feeling.
  ///
  /// In es, this message translates to:
  /// **'sentir {value}/5'**
  String movementLogEntryFeelingTemplate(int value);

  /// Compact arrow notation for level improvement. Used by both activity (pain) and therapy (severity) rows. 'niv.' is the Spanish abbreviation for 'niveles'.
  ///
  /// In es, this message translates to:
  /// **'↓{delta} niv.'**
  String movementLogEntryDeltaImprovedTemplate(int delta);

  /// Compact arrow notation for level worsening.
  ///
  /// In es, this message translates to:
  /// **'↑{delta} niv.'**
  String movementLogEntryDeltaWorseTemplate(int delta);

  /// No description provided for @movementLogEntryDeltaUnchanged.
  ///
  /// In es, this message translates to:
  /// **'sin cambio'**
  String get movementLogEntryDeltaUnchanged;

  /// Compact marker for therapy with no severity change. Single character — '=' is the universal default.
  ///
  /// In es, this message translates to:
  /// **'='**
  String get movementLogEntryTherapyDeltaSteady;

  /// No description provided for @appBarTooltipFontSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de texto'**
  String get appBarTooltipFontSize;

  /// No description provided for @appBarTooltipDarkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get appBarTooltipDarkMode;

  /// No description provided for @appBarTooltipLightMode.
  ///
  /// In es, this message translates to:
  /// **'Modo claro'**
  String get appBarTooltipLightMode;

  /// No description provided for @appBarTooltipSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get appBarTooltipSettings;

  /// No description provided for @actionDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get actionDelete;

  /// No description provided for @settingsProfileConfigTitle.
  ///
  /// In es, this message translates to:
  /// **'CONFIGURACIÓN DE PERFIL'**
  String get settingsProfileConfigTitle;

  /// No description provided for @settingsMyDataTitle.
  ///
  /// In es, this message translates to:
  /// **'MIS DATOS'**
  String get settingsMyDataTitle;

  /// No description provided for @settingsPatientNameLabel.
  ///
  /// In es, this message translates to:
  /// **'NOMBRE DEL PACIENTE'**
  String get settingsPatientNameLabel;

  /// No description provided for @settingsPatientNameHelper.
  ///
  /// In es, this message translates to:
  /// **'Nombre legal completo. Se usa en el PDF para el especialista.'**
  String get settingsPatientNameHelper;

  /// No description provided for @settingsPreferredNameLabel.
  ///
  /// In es, this message translates to:
  /// **'NOMBRE PREFERIDO (OPCIONAL)'**
  String get settingsPreferredNameLabel;

  /// No description provided for @settingsPreferredNameHelper.
  ///
  /// In es, this message translates to:
  /// **'Cómo quieres que te muestre la app. Si lo dejas vacío, se usa el nombre del paciente.'**
  String get settingsPreferredNameHelper;

  /// No description provided for @settingsConditionsLabel.
  ///
  /// In es, this message translates to:
  /// **'COMORBILIDADES / DIAGNÓSTICOS'**
  String get settingsConditionsLabel;

  /// No description provided for @settingsRelationshipLabel.
  ///
  /// In es, this message translates to:
  /// **'RELACIÓN CON ESTE PERFIL'**
  String get settingsRelationshipLabel;

  /// No description provided for @settingsLifeEventsLabel.
  ///
  /// In es, this message translates to:
  /// **'EVENTOS DE VIDA'**
  String get settingsLifeEventsLabel;

  /// No description provided for @settingsLocationLabel.
  ///
  /// In es, this message translates to:
  /// **'MI UBICACIÓN (PARA EL CLIMA)'**
  String get settingsLocationLabel;

  /// No description provided for @settingsConditionsHelper.
  ///
  /// In es, this message translates to:
  /// **'Toca la × para eliminar una condición. Para leer sobre ellas, ve a Clínica → Compendio.'**
  String get settingsConditionsHelper;

  /// No description provided for @settingsRelationshipHelper.
  ///
  /// In es, this message translates to:
  /// **'¿Para quién es este perfil? Útil si registras a alguien que cuidas.'**
  String get settingsRelationshipHelper;

  /// No description provided for @settingsLifeEventsHelper.
  ///
  /// In es, this message translates to:
  /// **'Cosas que pueden haber impactado tu cuerpo o ánimo: viajes, accidentes, mudanzas, eventos buenos o estresantes. Aparecen como puntos morados en el calendario.'**
  String get settingsLifeEventsHelper;

  /// No description provided for @settingsDataHelper.
  ///
  /// In es, this message translates to:
  /// **'Tienes derecho a acceder, exportar, importar o eliminar tus datos en cualquier momento.'**
  String get settingsDataHelper;

  /// No description provided for @settingsWipeAllHelper.
  ///
  /// In es, this message translates to:
  /// **'Esta acción borra todos los perfiles, registros y configuraciones. Irreversible.'**
  String get settingsWipeAllHelper;

  /// No description provided for @settingsRelationshipSelf.
  ///
  /// In es, this message translates to:
  /// **'Yo'**
  String get settingsRelationshipSelf;

  /// No description provided for @settingsRelationshipChild.
  ///
  /// In es, this message translates to:
  /// **'Mi hijo/a'**
  String get settingsRelationshipChild;

  /// No description provided for @settingsRelationshipPartner.
  ///
  /// In es, this message translates to:
  /// **'Mi pareja'**
  String get settingsRelationshipPartner;

  /// No description provided for @settingsRelationshipParent.
  ///
  /// In es, this message translates to:
  /// **'Mi madre/padre'**
  String get settingsRelationshipParent;

  /// No description provided for @settingsRelationshipOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get settingsRelationshipOther;

  /// No description provided for @settingsRelationshipNone.
  ///
  /// In es, this message translates to:
  /// **'— sin especificar —'**
  String get settingsRelationshipNone;

  /// No description provided for @settingsLifeEventsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay eventos registrados.'**
  String get settingsLifeEventsEmpty;

  /// No description provided for @settingsAddEventButton.
  ///
  /// In es, this message translates to:
  /// **'AÑADIR EVENTO'**
  String get settingsAddEventButton;

  /// No description provided for @settingsLocationNone.
  ///
  /// In es, this message translates to:
  /// **'Sin ubicación. Toca para añadir.'**
  String get settingsLocationNone;

  /// No description provided for @settingsLocationButtonAdd.
  ///
  /// In es, this message translates to:
  /// **'AÑADIR COORDENADAS'**
  String get settingsLocationButtonAdd;

  /// No description provided for @settingsLocationButtonEdit.
  ///
  /// In es, this message translates to:
  /// **'EDITAR COORDENADAS'**
  String get settingsLocationButtonEdit;

  /// No description provided for @settingsAddProfileButton.
  ///
  /// In es, this message translates to:
  /// **'AÑADIR NUEVO PERFIL'**
  String get settingsAddProfileButton;

  /// No description provided for @settingsDeleteProfileButton.
  ///
  /// In es, this message translates to:
  /// **'ELIMINAR ESTE PERFIL'**
  String get settingsDeleteProfileButton;

  /// No description provided for @settingsExportDataButton.
  ///
  /// In es, this message translates to:
  /// **'EXPORTAR MIS DATOS'**
  String get settingsExportDataButton;

  /// No description provided for @settingsWipeAllButton.
  ///
  /// In es, this message translates to:
  /// **'BORRAR TODO'**
  String get settingsWipeAllButton;

  /// Default name for a newly added profile. {number} is 1-indexed count after creation.
  ///
  /// In es, this message translates to:
  /// **'NUEVO PERFIL {number}'**
  String settingsNewProfileNameTemplate(int number);

  /// No description provided for @dialogWipeTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar todos los datos'**
  String get dialogWipeTitle;

  /// No description provided for @dialogWipeContent.
  ///
  /// In es, this message translates to:
  /// **'Esta acción borra TODOS los perfiles, registros, configuraciones y caché. No se puede deshacer.\n\n¿Quieres exportar primero?'**
  String get dialogWipeContent;

  /// No description provided for @dialogWipeFinalTitle.
  ///
  /// In es, this message translates to:
  /// **'Última confirmación'**
  String get dialogWipeFinalTitle;

  /// Prompt inside the typed-confirmation wipe dialog. {magicWord} is the localized confirm word the user must type — the same value provided by dialogWipeFinalMagicWord, so the prompt and the expected input stay in sync per locale.
  ///
  /// In es, this message translates to:
  /// **'Para confirmar, escribe {magicWord} abajo.'**
  String dialogWipeFinalContentTemplate(String magicWord);

  /// The exact word the user types to confirm wiping all data. Localized: Spanish=ELIMINAR, English=DELETE, zh-TW=刪除. Comparison is case-sensitive against the trimmed input, so use uppercase Latin or a single ideograph as appropriate per locale.
  ///
  /// In es, this message translates to:
  /// **'ELIMINAR'**
  String get dialogWipeFinalMagicWord;

  /// No description provided for @dialogWipeFinalButton.
  ///
  /// In es, this message translates to:
  /// **'Borrar todo'**
  String get dialogWipeFinalButton;

  /// No description provided for @dialogDeleteProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar perfil'**
  String get dialogDeleteProfileTitle;

  /// Confirmation message for deleting a profile. {name} is the profile display name.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar el perfil \"{name}\" y todos sus datos? Esta acción no se puede deshacer.'**
  String dialogDeleteProfileContentTemplate(String name);

  /// No description provided for @dialogLocationTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu ubicación'**
  String get dialogLocationTitle;

  /// No description provided for @dialogLocationContent.
  ///
  /// In es, this message translates to:
  /// **'Necesito latitud y longitud para traer el clima. Busca tu ciudad en Google Maps, click derecho → copiar coordenadas.'**
  String get dialogLocationContent;

  /// No description provided for @dialogLocationHintLat.
  ///
  /// In es, this message translates to:
  /// **'Latitud (ej. -34.61)'**
  String get dialogLocationHintLat;

  /// No description provided for @dialogLocationHintLng.
  ///
  /// In es, this message translates to:
  /// **'Longitud (ej. -58.38)'**
  String get dialogLocationHintLng;

  /// No description provided for @dialogLocationInvalidSnack.
  ///
  /// In es, this message translates to:
  /// **'Coordenadas inválidas.'**
  String get dialogLocationInvalidSnack;

  /// No description provided for @therapyHintArea.
  ///
  /// In es, this message translates to:
  /// **'Zona (ej. cervicales)'**
  String get therapyHintArea;

  /// No description provided for @therapySectionPainBefore.
  ///
  /// In es, this message translates to:
  /// **'DOLOR ANTES'**
  String get therapySectionPainBefore;

  /// No description provided for @therapySectionPainAfter.
  ///
  /// In es, this message translates to:
  /// **'DOLOR DESPUÉS'**
  String get therapySectionPainAfter;

  /// No description provided for @therapyActionMoreDetails.
  ///
  /// In es, this message translates to:
  /// **'más detalles (terapeuta, costo, nota)'**
  String get therapyActionMoreDetails;

  /// No description provided for @therapyHintTherapist.
  ///
  /// In es, this message translates to:
  /// **'Terapeuta / lugar (opcional)'**
  String get therapyHintTherapist;

  /// No description provided for @therapyHintCost.
  ///
  /// In es, this message translates to:
  /// **'Costo (opcional)'**
  String get therapyHintCost;

  /// No description provided for @therapyHintNote.
  ///
  /// In es, this message translates to:
  /// **'Nota (opcional)'**
  String get therapyHintNote;

  /// No description provided for @therapyActionSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR CAMBIOS'**
  String get therapyActionSaveChanges;

  /// No description provided for @therapyActionLog.
  ///
  /// In es, this message translates to:
  /// **'REGISTRAR'**
  String get therapyActionLog;

  /// No description provided for @compendiumSectionConditionsHeader.
  ///
  /// In es, this message translates to:
  /// **'MIS CONDICIONES'**
  String get compendiumSectionConditionsHeader;

  /// No description provided for @compendiumSectionConditionsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Toca una para leer información clínica (fuente: MedlinePlus).'**
  String get compendiumSectionConditionsSubtitle;

  /// Banner shown when user has saved articles from the research tab. ICU plural agreement on artículo/artículos.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 artículo guardado} other{{count} artículos guardados}} — ve a Investigación.'**
  String compendiumSavedArticlesTemplate(int count);

  /// No description provided for @compendiumSectionDataTitle.
  ///
  /// In es, this message translates to:
  /// **'DATOS CLÍNICOS'**
  String get compendiumSectionDataTitle;

  /// Label prefix shown before the citation of a clinical fact in the compendium. The actual citation text is appended after a space.
  ///
  /// In es, this message translates to:
  /// **'Fuente:'**
  String get compendiumFactSourceLabel;

  /// Subtitle shown under each condition's collapsible header in the Investigación tab. ICU plural on artículo/artículos.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 artículo} other{{count} artículos}}'**
  String investigationConditionArticleCountTemplate(int count);

  /// No description provided for @headacheSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de tu cefalea'**
  String get headacheSheetTitle;

  /// No description provided for @headacheSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Marca lo que aplique. Puedes saltar este paso si prefieres.'**
  String get headacheSheetSubtitle;

  /// No description provided for @actionSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get actionSkip;

  /// No description provided for @headacheActionSaveDetail.
  ///
  /// In es, this message translates to:
  /// **'Guardar detalle'**
  String get headacheActionSaveDetail;

  /// No description provided for @headacheThunderclapWarningTitle.
  ///
  /// In es, this message translates to:
  /// **'Posible emergencia'**
  String get headacheThunderclapWarningTitle;

  /// No description provided for @headacheThunderclapWarningConfirm.
  ///
  /// In es, this message translates to:
  /// **'Lo entiendo, continuar'**
  String get headacheThunderclapWarningConfirm;

  /// No description provided for @headacheAdvisoryDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Patrones a considerar'**
  String get headacheAdvisoryDialogTitle;

  /// No description provided for @headacheRedFlagCsfLeakAdvisory.
  ///
  /// In es, this message translates to:
  /// **'Tu cefalea empeora marcadamente al estar de pie. Este patrón puede sugerir una fuga de líquido cefalorraquídeo, especialmente en personas con EDS. Si se repite, considera mencionárselo a tu médico.'**
  String get headacheRedFlagCsfLeakAdvisory;

  /// No description provided for @headacheRedFlagIntracranialAdvisory.
  ///
  /// In es, this message translates to:
  /// **'Tu cefalea empeora al recostarte. Este patrón puede sugerir aumento de presión intracraneal. Si se repite o se acompaña de cambios visuales, considera evaluación médica.'**
  String get headacheRedFlagIntracranialAdvisory;

  /// No description provided for @settingsModuleHeadacheDetailLabel.
  ///
  /// In es, this message translates to:
  /// **'Detalle de cefalea'**
  String get settingsModuleHeadacheDetailLabel;

  /// No description provided for @settingsModuleHeadacheDetailDescription.
  ///
  /// In es, this message translates to:
  /// **'Captura localización, calidad y otros patrones al registrar una cefalea.'**
  String get settingsModuleHeadacheDetailDescription;

  /// Title of the modal sheet that captures structured fatigue detail.
  ///
  /// In es, this message translates to:
  /// **'Detalle de tu fatiga'**
  String get fatigueSheetTitle;

  /// Subtitle explaining why filling the optional detail helps.
  ///
  /// In es, this message translates to:
  /// **'Los detalles opcionales ayudan a identificar patrones.'**
  String get fatigueSheetSubtitle;

  /// Save button label at the bottom of the fatigue detail sheet.
  ///
  /// In es, this message translates to:
  /// **'Guardar detalle'**
  String get fatigueActionSaveDetail;

  /// Title of the advisory dialog shown after saving a fatigue log when a red flag pattern is detected.
  ///
  /// In es, this message translates to:
  /// **'Patrones detectados'**
  String get fatigueAdvisoryDialogTitle;

  /// PEM (post-exertional malaise) advisory. Surfaced when fatigue type is post-exertional AND severity is intense or higher.
  ///
  /// In es, this message translates to:
  /// **'Este patrón muestra que tu fatiga aparece 1-3 días después de un esfuerzo. Puede indicar que tu cuerpo tiene menos reservas de energía de lo habitual y necesita más días para recuperarse. Si se repite, considera mencionárselo a tu médico.'**
  String get fatigueRedFlagPemAdvisory;

  /// Orthostatic fatigue advisory. Surfaced when fatigue type is orthostatic AND severity is intense or higher.
  ///
  /// In es, this message translates to:
  /// **'Tu fatiga empeora al estar de pie o sentada erecta. Puede indicar que tu cuerpo tiene dificultad para mantener presión sanguínea o pulso estables al estar arriba. Es común en personas con EDS. Vale mencionárselo a tu médico.'**
  String get fatigueRedFlagOrthostaticAdvisory;

  /// HPA-axis / wired-but-tired advisory. Surfaced when fatigue type is hpa_wired AND severity is intense or higher.
  ///
  /// In es, this message translates to:
  /// **'Tu cuerpo se siente exhausto pero no logra descansar. Esto puede indicar que tu sistema de estrés lleva mucho tiempo activado y las hormonas que regulan el descanso están desajustadas. Vale mencionárselo a tu médico.'**
  String get fatigueRedFlagHpaAdvisory;

  /// Label of the optional fatigue detail tracker switch in settings.
  ///
  /// In es, this message translates to:
  /// **'Detalle de fatiga'**
  String get settingsModuleFatigueDetailLabel;

  /// Description under the fatigue detail switch in settings.
  ///
  /// In es, this message translates to:
  /// **'Al registrar fatiga, agrega tipo, patrón temporal y acompañantes.'**
  String get settingsModuleFatigueDetailDescription;

  /// Title of the modal sheet that captures structured abdominal detail.
  ///
  /// In es, this message translates to:
  /// **'Detalle del dolor abdominal'**
  String get abdominalSheetTitle;

  /// Subtitle explaining why filling the optional detail helps.
  ///
  /// In es, this message translates to:
  /// **'Los detalles opcionales ayudan a identificar patrones.'**
  String get abdominalSheetSubtitle;

  /// Save button label at the bottom of the abdominal detail sheet.
  ///
  /// In es, this message translates to:
  /// **'Guardar detalle'**
  String get abdominalActionSaveDetail;

  /// Title of the in-sheet emergency dialog fired when quality=tearing on save attempt (SEDv-adjacent presentation).
  ///
  /// In es, this message translates to:
  /// **'Dolor tipo desgarro'**
  String get abdominalTearingEmergencyTitle;

  /// Body of the tearing-pain emergency dialog. Advises ER visit and communication of clEDS diagnosis to paramedics. Approved by Paulina 2026-07-02.
  ///
  /// In es, this message translates to:
  /// **'El dolor de desgarro súbito y muy severo puede indicar una emergencia médica en personas con síndrome de Ehlers-Danlos. Vale la pena que vayas a urgencias ahora para descartar rotura arterial o intestinal.\n\nSi vas, informa al equipo médico tu diagnóstico de clEDS (síndrome de Ehlers-Danlos clásico-like, por mutación de TNXB).\n\nSi el dolor mejoró significativamente y ya no lo describirías como desgarro, puedes cambiar la calidad del dolor y guardar el registro normalmente.'**
  String get abdominalTearingEmergencyBody;

  /// Dialog action: return to sheet to revise the quality selection.
  ///
  /// In es, this message translates to:
  /// **'Cambiar calidad y guardar'**
  String get abdominalTearingEmergencyChangeQuality;

  /// Dialog action: acknowledge emergency and save the record as-is.
  ///
  /// In es, this message translates to:
  /// **'Guardar como está (emergencia)'**
  String get abdominalTearingEmergencySaveAsIs;

  /// Title of the advisory dialog shown after saving an abdominal log when a red flag pattern is detected.
  ///
  /// In es, this message translates to:
  /// **'Patrones detectados'**
  String get abdominalAdvisoryDialogTitle;

  /// URGENT advisory for compound bleed pattern (bloody_stool + nausea/vomiting + severity >= 3).
  ///
  /// In es, this message translates to:
  /// **'Este patrón (sangre en heces junto con náusea o vómito y dolor intenso) puede indicar un sangrado GI activo. Si el sangrado es abundante o notas mucha debilidad o mareo, ve a urgencias ahora.'**
  String get abdominalRedFlagMassiveHematocheziaUrgent;

  /// URGENT advisory when the free-text note matches hematemesis keywords.
  ///
  /// In es, this message translates to:
  /// **'En tu nota mencionaste vómito con sangre. Este síntoma indica sangrado del sistema digestivo alto y requiere evaluación en urgencias inmediatamente.'**
  String get abdominalRedFlagHematemesisUrgent;

  /// ADVISORY for nocturnal pain (timing=nocturnal + severity >= 3). Rome IV alarm criterion.
  ///
  /// In es, this message translates to:
  /// **'Tu dolor te despertó por la noche. Este patrón es un signo de alarma que vale mencionar a tu médico, especialmente si notas pérdida de peso involuntaria o fiebre.'**
  String get abdominalRedFlagNocturnalPainAdvisory;

  /// ADVISORY for gastroparesis pattern (postprandial immediate + early satiety + severity >= 2). Nelson 2015 — 25% prevalence in EDS.
  ///
  /// In es, this message translates to:
  /// **'Tu dolor aparece justo al comer y sientes saciedad temprana. Este patrón puede indicar que tu estómago se vacía más lento de lo normal. Es común en personas con EDS y disautonomía. Vale mencionárselo a tu médico.'**
  String get abdominalRedFlagGastroparesisAdvisory;

  /// Label of the optional abdominal detail tracker switch in settings.
  ///
  /// In es, this message translates to:
  /// **'Detalle de dolor abdominal'**
  String get settingsModuleAbdominalDetailLabel;

  /// Description under the abdominal detail switch in settings.
  ///
  /// In es, this message translates to:
  /// **'Al registrar dolor, hinchazón o gases, agrega ubicación, calidad, timing y acompañantes.'**
  String get settingsModuleAbdominalDetailDescription;

  /// Title of the dialog offered after saving a BowelEvent marked as accompaniedByPain, asking the user to also capture the abdominal detail.
  ///
  /// In es, this message translates to:
  /// **'¿Registrar detalle del dolor?'**
  String get bowelToAbdominalPromptTitle;

  /// Body of the bowel→abdominal integration prompt dialog.
  ///
  /// In es, this message translates to:
  /// **'Marcaste este evento como acompañado de dolor abdominal. ¿Registrar el detalle ahora para identificar patrones?'**
  String get bowelToAbdominalPromptBody;

  /// Title of the dialog offered when the user saves an abdominal detail with timing=bowelRelated and there's a recent BowelEvent.
  ///
  /// In es, this message translates to:
  /// **'¿Vinculado a una evacuación?'**
  String get abdominalToBowelPromptTitle;

  /// Body of the abdominal→bowel integration prompt dialog. {time} is the formatted time of the recent BowelEvent.
  ///
  /// In es, this message translates to:
  /// **'Marcaste este dolor como relacionado con evacuación. Registraste una evacuación a las {time}. ¿Es la misma?'**
  String abdominalToBowelPromptBody(String time);

  /// Yes button for D.2.E integration prompts.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get abdominalIntegrationYes;

  /// No button for D.2.E integration prompts.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get abdominalIntegrationNo;

  /// 'I don't know' button for D.2.E integration prompts. Treated the same as No but semantically distinct.
  ///
  /// In es, this message translates to:
  /// **'No lo sé'**
  String get abdominalIntegrationDontKnow;

  /// No description provided for @onboardingStepMedsUnitHint.
  ///
  /// In es, this message translates to:
  /// **'1'**
  String get onboardingStepMedsUnitHint;

  /// No description provided for @onboardingStepMedsStrengthHint.
  ///
  /// In es, this message translates to:
  /// **'mg'**
  String get onboardingStepMedsStrengthHint;
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
      <String>['en', 'es', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
