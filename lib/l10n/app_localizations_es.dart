// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navHoy => 'Hoy';

  @override
  String get navSintomas => 'Síntomas';

  @override
  String get navMovimiento => 'Movimiento';

  @override
  String get navBotiquin => 'Botiquín';

  @override
  String get navClinica => 'Clínica';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionUnderstood => 'Entendido';

  @override
  String get languageSectionTitle => 'IDIOMA / LANGUAGE';

  @override
  String get languageFootnote =>
      'El idioma se aplica a toda la aplicación. Tus datos no cambian.';

  @override
  String get myDataTitle => 'MIS DATOS';

  @override
  String get arcoRightsBlurb =>
      'Tienes derecho a acceder, exportar, importar o eliminar tus datos en cualquier momento.';

  @override
  String get exportDataButton => 'EXPORTAR MIS DATOS';

  @override
  String get importFileButton => 'IMPORTAR DESDE ARCHIVO';

  @override
  String get importPasteButton => 'IMPORTAR PEGANDO TEXTO';

  @override
  String get wipeAllButton => 'BORRAR TODO';

  @override
  String get wipeWarningFootnote =>
      'Esta acción borra todos los perfiles, registros y configuraciones. Irreversible.';

  @override
  String exportSuccess(String filename) {
    return 'Datos exportados: $filename';
  }

  @override
  String exportError(String reason) {
    return 'Error al exportar: $reason';
  }

  @override
  String importCancelled(String reason) {
    return 'Importación cancelada: $reason';
  }

  @override
  String get importSuccess => 'Perfil importado correctamente.';

  @override
  String get importDialogTitle => 'Importar este perfil';

  @override
  String importDialogName(String name) {
    return 'Nombre: $name';
  }

  @override
  String importDialogExportedAt(String date) {
    return 'Exportado: $date';
  }

  @override
  String importDialogContains(int count) {
    return 'Contiene $count registros:';
  }

  @override
  String get importDialogFootnote =>
      'Esto se agregará como un perfil nuevo. Tu perfil actual no se borra.';

  @override
  String get nounSymptoms => 'síntomas';

  @override
  String get nounDoses => 'dosis';

  @override
  String get nounStructural => 'eventos estructurales';

  @override
  String get nounActivities => 'actividades';

  @override
  String get nounTherapies => 'terapias';

  @override
  String get nounMoods => 'estados de ánimo';

  @override
  String get nounMental => 'registros mentales';

  @override
  String get pasteImportTitle => 'Importar pegando texto';

  @override
  String get pasteImportInstructions =>
      'Abre tu archivo .json exportado (por ejemplo, desde la app Archivos), selecciona todo el texto, cópialo y pégalo aquí.';

  @override
  String get pasteImportHint => 'Pega aquí el contenido del archivo…';

  @override
  String get errImportUnreadable => 'No se pudo leer el archivo.';

  @override
  String get errImportInvalidJson => 'El texto no es JSON válido.';

  @override
  String get errImportNotZebra => 'Este archivo no parece ser de ZebraUpp.';

  @override
  String get errImportUnknownSchema => 'Versión de esquema desconocida.';

  @override
  String errImportSchemaMismatch(String found, String expected) {
    return 'Este archivo es de una versión diferente (v$found). Versión esperada: v$expected.';
  }

  @override
  String get errImportMissingProfile => 'No se encontró perfil en el archivo.';

  @override
  String get errImportCorruptProfile =>
      'El perfil está dañado o tiene un formato inesperado.';

  @override
  String get actionHide => 'Ocultar';

  @override
  String get hintTapTip =>
      'Tip: en Síntomas, toca un chip del baúl para registrar. Mantén pulsado un registro para editar.';

  @override
  String get sectionPending => 'Pendientes';

  @override
  String get sectionWeather => 'EL CLIMA HOY';

  @override
  String get headerTodayIs => 'Hoy es';

  @override
  String get pacingActiveState => 'Día de descanso — sin expectativas';

  @override
  String get pacingInactiveState => 'Marcar como día de descanso';

  @override
  String outcomeCardTimePrefix(String hours) {
    return 'Hace ${hours}h tomaste';
  }

  @override
  String get outcomeCardForSymptom => 'para tu';

  @override
  String get outcomeCardInitialState => 'Estaba en ';

  @override
  String get outcomeCardQuestionNow => '¿Cómo está ahora?';

  @override
  String get outcomeCardAttributionQuestion => '¿A qué lo atribuyes?';

  @override
  String get outcomeActionAddFactor => 'Otro factor';

  @override
  String get sectionMentalDetails => 'Detalles mentales';

  @override
  String get mentalIntensitySubtitle => 'Intensidad ahora';

  @override
  String get summaryTitle => 'Tu día en pocas palabras';

  @override
  String get summaryEmptyPacing =>
      '🛡️ Día de descanso. Aún no has registrado nada — está bien.';

  @override
  String get summaryEmptyNormal =>
      'Aún no has registrado nada hoy. ¿Cómo va todo?';

  @override
  String summarySymptomSingle(String name, String label) {
    return 'Registraste 1 síntoma: $name ($label).';
  }

  @override
  String summarySymptomPlural(int count, String name, String label) {
    return 'Registraste $count síntomas — el más fuerte fue $name ($label).';
  }

  @override
  String summaryStructuralSingle(String zone) {
    return 'Tuviste 1 evento estructural en $zone.';
  }

  @override
  String summaryStructuralPlural(int count) {
    return 'Tuviste $count eventos estructurales hoy.';
  }

  @override
  String summaryDosesSentence(int totalDoses, String shown, int extraCount) {
    String _temp0 = intl.Intl.pluralLogic(
      totalDoses,
      locale: localeName,
      other: 'dosis',
      one: 'dosis',
    );
    String _temp1 = intl.Intl.pluralLogic(
      extraCount,
      locale: localeName,
      other: ' y $extraCount más',
      zero: '',
    );
    return 'Tomaste $totalDoses $_temp0: $shown$_temp1.';
  }

  @override
  String summaryMoodSentence(String statesStr, String extra) {
    return 'Tus estados y sensaciones registradas: $statesStr$extra.';
  }

  @override
  String get summaryPacingFooter =>
      '🛡️ Te diste permiso para descansar. Eso cuenta.';

  @override
  String get wisdomBannerTitle => '✨ Sabiduría cebra 🦓';

  @override
  String get bowelCountToday => 'última evacuación: hoy';

  @override
  String get bowelCountYesterday => 'última evacuación: ayer';

  @override
  String bowelCountDaysAgo(int days) {
    return 'última evacuación: hace $days días';
  }

  @override
  String distentionBannerMessage(int days) {
    return 'Llevas $days días sin tránsito intestinal — la distensión y el dolor abdominal pueden acumularse.';
  }

  @override
  String get distentionBannerAction => 'Ir a Síntomas';

  @override
  String get severityNone => 'Ninguna';

  @override
  String get severityMild => 'Leve';

  @override
  String get severityModerate => 'Moderada';

  @override
  String get severityIntense => 'Intensa';

  @override
  String get severityUnbearable => 'Insoportable';

  @override
  String get reasonNatural => 'Cambio natural del síntoma';

  @override
  String get reasonMedicationHelped => 'Creo que ayudó este medicamento';

  @override
  String get reasonOtherTrigger => 'Otro gatillo (comida, estrés, clima…)';

  @override
  String get reasonAdditionalMed => 'Tomé otro medicamento también';

  @override
  String get reasonUnsure => 'Sin certeza absoluta';

  @override
  String get mentalStateMood => 'Ánimo';

  @override
  String get mentalStateAnxiety => 'Ansiedad';

  @override
  String get mentalStateBrainFog => 'Niebla mental';

  @override
  String get mentalStateDissociation => 'Disociación';

  @override
  String get mentalStateIrritability => 'Irritabilidad';

  @override
  String get mentalStateEmotionalEnergy => 'Energía emocional';

  @override
  String get outcomeCoarsePending => 'Pendiente';

  @override
  String get outcomeCoarseMuchBetter => 'Mucho mejor';

  @override
  String get outcomeCoarseBetter => 'Mejor';

  @override
  String get outcomeCoarseEqual => 'Igual';

  @override
  String get outcomeCoarseWorse => 'Peor';

  @override
  String get outcomeCoarseMuchWorse => 'Mucho peor';

  @override
  String get pubMedNoAuthor => 'Sin autoría registrada';

  @override
  String get quadrantActivatedUnpleasant => 'activación · malestar';

  @override
  String get quadrantActivatedPleasant => 'activación · bienestar';

  @override
  String get quadrantCalmUnpleasant => 'calma · malestar';

  @override
  String get quadrantCalpleasant => 'calma · bienestar';

  @override
  String get quadrantTeaserActivatedUnpleasant => 'tensión, ansiedad';

  @override
  String get quadrantTeaserActivatedPleasant => 'energía, alegría';

  @override
  String get quadrantTeaserCalmUnpleasant => 'agotamiento, tristeza';

  @override
  String get quadrantTeaserCalmPleasant => 'tranquilidad, paz';

  @override
  String get bowelBucketConstipation => 'estreñimiento';

  @override
  String get bowelBucketNormal => 'normal';

  @override
  String get bowelBucketDiarrea => 'diarrea';

  @override
  String get sleepQualityBad => 'mal';

  @override
  String get sleepQualityRegular => 'regular';

  @override
  String get sleepQualityGood => 'bien';

  @override
  String get sleepQualityVeryGood => 'muy bien';

  @override
  String get beverageWater => 'agua';

  @override
  String get beverageElectrolyte => 'electrolitos';

  @override
  String get beverageCoffee => 'café';

  @override
  String get beverageOther => 'otro';

  @override
  String get sodiumPinch => 'pizca de sal';

  @override
  String get sodiumSachet => 'sobre de electrolitos';

  @override
  String get sodiumSaltySnack => 'snack salado';

  @override
  String get hrvContextMorning => 'matinal';

  @override
  String get hrvContextAfternoon => 'tarde';

  @override
  String get hrvContextEvening => 'noche';

  @override
  String get hrvContextPostExercise => 'post-ejercicio';

  @override
  String get hrvContextOther => 'otro';

  @override
  String legacyIntensityLabel(String value) {
    return 'Intensidad anterior: $value/5';
  }

  @override
  String get botiquinTabTitle => 'Tu botiquín';

  @override
  String get botiquinActionCreate => 'Crear medicamento';

  @override
  String get botiquinInteractionsTitle => 'Interacciones detectadas';

  @override
  String get botiquinGroupsTitle => 'Grupos';

  @override
  String get botiquinGroupsEmptyHeadline =>
      '🌙 Meds de la noche · ☀️ Meds de la mañana';

  @override
  String get botiquinGroupsEmptyBody =>
      'Agrupa los medicamentos que tomas juntos. Un toque registra todas las dosis a la vez.';

  @override
  String get botiquinActionCreateGroup => 'Crear grupo';

  @override
  String get botiquinNoMedsDialogTitle => 'Sin medicamentos';

  @override
  String get botiquinNoMedsDialogBody =>
      'Crea al menos un medicamento en tu botiquín antes de formar un grupo.';

  @override
  String botiquinRowMedsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'medicamentos',
      one: 'medicamento',
    );
    return '$count $_temp0';
  }

  @override
  String get botiquinActionEditTooltip => 'Editar';

  @override
  String get botiquinBatchSheetTitle => 'Registrar grupo';

  @override
  String get botiquinBatchSheetSubtitle => 'Se registrarán estas dosis:';

  @override
  String botiquinBatchOrphanWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'medicamentos eliminados',
      one: 'medicamento eliminado',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'omitirán',
      one: 'omitirá',
    );
    return '⚠️ $count $_temp0 del botiquín — se $_temp1.';
  }

  @override
  String botiquinBatchActionSubmit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dosis',
      one: 'dosis',
    );
    return 'Registrar $count $_temp0';
  }

  @override
  String get botiquinEmptyStateHeadline => 'Aún no has añadido medicamentos';

  @override
  String get botiquinEmptyStateSubtitle => 'Crea uno con el botón de abajo.';

  @override
  String botiquinDoseLoggedTodayBadge(String qty) {
    return '$qty hoy';
  }

  @override
  String botiquinDeleteConfirmTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String botiquinDeleteConfirmBody(String name) {
    return 'Se conservará el historial de dosis para tus reportes, pero $name se quitará de tu botiquín.';
  }

  @override
  String get botiquinActionDelete => 'Eliminar';

  @override
  String get botiquinLogDoseSheetTitle => 'Registrar dosis';

  @override
  String botiquinLogDoseTotalCalculated(String total, String unit) {
    return '= $total $unit total';
  }

  @override
  String get botiquinLogDoseSymptomPrompt => '¿Para un síntoma específico?';

  @override
  String get botiquinLogDoseSymptomNone => 'Ninguno';

  @override
  String botiquinLogDoseTrackOutcomeToggle(int hours) {
    return 'Preguntar en ${hours}h si ayudó';
  }

  @override
  String get botiquinDoseListTitle => 'Dosis de hoy';

  @override
  String get botiquinDoseListFootnote =>
      'Toca × para eliminar una dosis específica (útil si registraste mal el nombre).';

  @override
  String get botiquinDoseItemDeleteConfirmTitle => 'Eliminar esta dosis';

  @override
  String botiquinDoseItemDeleteConfirmBody(String name, String time) {
    return '¿Eliminar la dosis de $name registrada a las $time? Esta acción no se puede deshacer.';
  }

  @override
  String botiquinTimeTodayAt(String time) {
    return 'Hoy a las $time';
  }

  @override
  String botiquinTimePastAt(int day, int month, String time) {
    return '$day/$month a las $time';
  }

  @override
  String get onboardingActionBack => 'atrás';

  @override
  String get onboardingActionSkip => 'saltar';

  @override
  String get onboardingActionNext => 'SIGUIENTE';

  @override
  String get onboardingActionFinish => 'EMPEZAR';

  @override
  String get onboardingFallbackProfileName => 'Mi perfil';

  @override
  String get onboardingStepWelcomeTitle => 'ZebraUp';

  @override
  String get onboardingStepWelcomeSubtitle =>
      'Tu copiloto para las citas médicas.';

  @override
  String get onboardingStepWelcomeBody =>
      'Las consultas son cortas. Tu memoria, después de una semana difícil, también. ZebraUp registra tus síntomas, medicamentos y patrones para que llegues a cada cita con datos concretos — no con frases sueltas que se te olvidan apenas te sientas frente al médico. Y porque sabemos que cuidas de otros, puedes agregar a tus familiares y mascotas.';

  @override
  String get onboardingStepWelcomePrivacyNote =>
      'Todos tus datos se guardan en este dispositivo. No subimos nada a internet.';

  @override
  String get onboardingStepWelcomeMedicalDisclaimer =>
      'Esta aplicación no es un dispositivo médico. No diagnostica, trata, cura ni previene ninguna condición médica.';

  @override
  String get onboardingStepNameTitle => 'Empecemos.';

  @override
  String get onboardingStepNameQuestion => '¿Cómo te llamamos?';

  @override
  String get onboardingStepNameFootnote =>
      'Solo se usa para personalizar la app. Puedes cambiarlo después.';

  @override
  String get onboardingStepNameHint => 'Tu nombre o apodo';

  @override
  String get onboardingStepConditionsTitle => 'Tus diagnósticos.';

  @override
  String get onboardingStepConditionsBody =>
      '¿Qué condiciones manejas? Las usamos para contextualizar interacciones y reportes. Puedes agregar, editar o saltar este paso.';

  @override
  String get onboardingStepConditionsHint => 'ej. hEDS, POTS, MCAS…';

  @override
  String get onboardingStepConditionsEmpty =>
      'Aún no agregaste ninguno. Puedes saltar este paso.';

  @override
  String get onboardingStepMedsTitle => 'Tu botiquín.';

  @override
  String get onboardingStepMedsBody =>
      'Agrega los medicamentos que tomas habitualmente. Vas a poder registrar cada dosis con un toque desde la pestaña Botiquín.';

  @override
  String get onboardingStepMedsNameHint => 'Nombre';

  @override
  String get onboardingStepMedsDoseHint => 'Dosis (ej. 400mg)';

  @override
  String get onboardingStepMedsEmpty =>
      'Sin medicamentos por ahora. Puedes saltar este paso.';

  @override
  String get symptomsSectionStructuralZones => 'ZONAS ESTRUCTURALES';

  @override
  String get symptomsSectionBowelTransit => 'TRÁNSITO INTESTINAL';

  @override
  String get symptomsActionAddHemorrhoid => 'hemorroide';

  @override
  String get symptomsSectionTodaysLogs => 'REGISTROS DE HOY';

  @override
  String get symptomsFootnoteLongPressEdit =>
      'Mantén presionado un registro para editar fecha/gravedad/nota.';

  @override
  String get symptomsSectionTrending => 'EN TENDENCIA (ÚLTIMOS 7 DÍAS)';

  @override
  String get symptomsTrendingEmpty =>
      'No hay síntomas consistentes esta semana.';

  @override
  String get symptomsSectionVault => 'BAÚL DE SÍNTOMAS';

  @override
  String get symptomsVaultPlaceholder => '+ Añadir síntoma al baúl...';

  @override
  String symptomsModalLogHeader(String zone) {
    return 'REGISTRAR EN: $zone';
  }

  @override
  String symptomsModalEditHeader(String zone, String type) {
    return 'EDITAR: $zone / $type';
  }

  @override
  String symptomsModalEditSymptomHeader(String name) {
    return 'EDITAR: $name';
  }

  @override
  String get symptomsLabelOptionalNote =>
      'Nota opcional (contexto, gatillo, etc.)';

  @override
  String get symptomsLabelOptionalNoteSimple => 'Nota opcional';

  @override
  String get symptomsLabelSeverityGrading => 'GRAVEDAD';

  @override
  String get symptomsActionLogUnrated => 'Registrar sin rating';

  @override
  String get symptomsUnratedLabelSuffix => 'sin rating';

  @override
  String get symptomsUnratedInlineWarning =>
      'Este registro no tiene rating. Toca un punto para asignar uno.';

  @override
  String get symptomsActionSaveChanges => 'GUARDAR CAMBIOS';

  @override
  String get symptomsActionSave => 'GUARDAR';

  @override
  String get zoneCervical => 'Cervicales';

  @override
  String get zoneHombros => 'Hombros';

  @override
  String get zoneMunecas => 'Muñecas';

  @override
  String get zoneManos => 'Manos';

  @override
  String get zoneLumbarPelvis => 'Lumbar/Pelvis';

  @override
  String get zoneCaderas => 'Caderas';

  @override
  String get zoneRodillas => 'Rodillas';

  @override
  String get zoneTobillos => 'Tobillos';

  @override
  String get structTypeSubluxation => 'Subluxación';

  @override
  String get structTypeDislocation => 'Dislocación';

  @override
  String get structTypeInstability => 'Inestabilidad Articular';

  @override
  String get structTypeJointPain => 'Dolor Articular';

  @override
  String get structTypeMyofascial => 'Dolor Miofascial';

  @override
  String get structTypeNeuropathic => 'Dolor Neuropático';

  @override
  String bowelLabelBristolType(String type) {
    return 'tipo $type';
  }

  @override
  String get bowelLabelUrgency => 'urgencia';

  @override
  String get bowelLabelBleeding => 'sangrado';

  @override
  String get bowelLabelIncomplete => 'incompleta';

  @override
  String get movementSectionPacingActive =>
      'Hoy es día de descanso. Descansar también cuenta.';

  @override
  String get movementSectionHistoryTitle => 'HOY HICISTE…';

  @override
  String get movementFootnoteLongPressEdit =>
      'Mantén presionado un registro para editar.';

  @override
  String get movementEmptyStateHeadline =>
      'Movimiento y recuperación son lo mismo.';

  @override
  String get movementEmptyStateSubtitle =>
      'Caminar, estirar, una sesión de kinesio, un masaje — todo cuenta como cuidado del cuerpo.';

  @override
  String get movementSectionActivityTitle => 'ACTIVIDAD';

  @override
  String get movementActivityPlaceholder =>
      '+ Añadir actividad (natación, bici, baile…)';

  @override
  String get movementSectionTherapyTitle => 'TERAPIA';

  @override
  String get movementTherapyPlaceholder =>
      '+ Añadir modalidad (reiki, flotación…)';

  @override
  String activityModalLogHeader(String name) {
    return 'REGISTRAR: $name';
  }

  @override
  String activityModalEditHeader(String name) {
    return 'EDITAR: $name';
  }

  @override
  String get activityFieldDurationHint => 'Duración (min)';

  @override
  String get activityFieldSetsHint => 'Sets';

  @override
  String get activityFieldRepsHint => 'Reps';

  @override
  String get activityFieldHhrHint =>
      'Frecuencia cardíaca opcional (ej. 70→110)';

  @override
  String activityLabelEffortSlider(int value) {
    return 'Esfuerzo: $value/10';
  }

  @override
  String activityLabelFeelingSlider(int value) {
    return 'Cómo me sentí: $value/5';
  }

  @override
  String get activityActionTogglePainRating =>
      'evaluar dolor antes/después (opcional)';

  @override
  String get activityLabelPainBefore => 'DOLOR ANTES';

  @override
  String get activityLabelPainAfter => 'DOLOR DESPUÉS';

  @override
  String get activityActionSubmitLog => 'GUARDAR ACTIVIDAD';

  @override
  String get activityActionSubmitChanges => 'GUARDAR CAMBIOS';

  @override
  String get painLabelNone => 'nada';

  @override
  String get painLabelMild => 'leve';

  @override
  String get painLabelModerate => 'moderado';

  @override
  String get painLabelIntense => 'intenso';

  @override
  String get painLabelSevere => 'severo';

  @override
  String painDeltaLabelImproved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'niveles',
      one: 'nivel',
    );
    return 'Mejoraste $count $_temp0';
  }

  @override
  String painDeltaLabelWorsened(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'niveles',
      one: 'nivel',
    );
    return 'Empeoraste $count $_temp0';
  }

  @override
  String get painDeltaLabelUnchanged => 'Sin cambios';

  @override
  String logSubtitleMetricDuration(int minutes) {
    return '${minutes}min';
  }

  @override
  String logSubtitleMetricSetsReps(String sets, String reps) {
    return '$sets×$reps';
  }

  @override
  String logSubtitleActivityTemplate(
    String detail,
    int effort,
    int feeling,
    String pain,
    Object painSuffix,
  ) {
    return '$detail · esfuerzo $effort/10 · sentir $feeling/5$painSuffix ';
  }

  @override
  String logSubtitlePainDeltaImproved(int levels) {
    return '↓$levels niv.';
  }

  @override
  String logSubtitlePainDeltaWorsened(int levels) {
    return '↑$levels niv.';
  }

  @override
  String get logSubtitlePainDeltaUnchanged => 'sin cambio';

  @override
  String get feelingLabelLevel1 => '🤕 En dolor / lesión';

  @override
  String get feelingLabelLevel2 => '😟 Incomodidad / preocupación';

  @override
  String get feelingLabelLevel3 => '😐 Neutralidad';

  @override
  String get feelingLabelLevel4 => '😊 Relajación';

  @override
  String get feelingLabelLevel5 => '💪 Fuerza y seguridad';

  @override
  String get onboardingHaveProfileTitle => 'Ya tengo un perfil guardado';

  @override
  String get onboardingHaveProfileSubtitle => 'Importar desde un archivo JSON';

  @override
  String get onboardingImportChoiceTitle => '¿Cómo importar?';

  @override
  String get onboardingImportFromFile => 'Desde archivo';

  @override
  String get onboardingImportFromPaste => 'Pegar texto';

  @override
  String get feverSectionTitle => 'FIEBRE';

  @override
  String get feverActionAddReading => '+ medir temperatura';

  @override
  String get feverModalLogHeader => 'REGISTRAR TEMPERATURA';

  @override
  String get feverModalEditHeader => 'EDITAR LECTURA';

  @override
  String get feverFieldSiteLabel => 'SITIO';

  @override
  String get feverFieldAntipyreticLabel => 'ANTIPIRÉTICO';

  @override
  String get feverFieldAntipyreticToggle => 'tomé algo para bajarla';

  @override
  String get feverFieldAntipyreticNameHint =>
      'nombre (paracetamol, ibuprofeno...)';

  @override
  String get feverHintTapToEdit => 'tocá el número para editar';

  @override
  String get feverDirectEditDialogTitle => 'Editar temperatura';

  @override
  String get feverDirectEditDialogHint => 'ej. 38.7';

  @override
  String get feverLogLabelWithAntipyretic => 'con antipirético';

  @override
  String get feverSiteAxillary => 'axilar';

  @override
  String get feverSiteOral => 'oral';

  @override
  String get feverSiteTympanic => 'timpánica';

  @override
  String get feverSiteRectal => 'rectal';

  @override
  String get feverSiteForehead => 'frente';
}
