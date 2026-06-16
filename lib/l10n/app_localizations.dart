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

  /// No description provided for @bowelBucketDiarrea.
  ///
  /// In es, this message translates to:
  /// **'diarrea'**
  String get bowelBucketDiarrea;

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
  /// **'Dosis (ej. 400mg)'**
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
  /// **'{detail} · esfuerzo {effort}/10 · sentir {feeling}/5{painSuffix} }'**
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
