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
  String get bowelBucketDiarrhea => 'diarrea';

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
  String get onboardingStepMedsDoseHint => 'Notas (ej. tomar con comida)';

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
    return '$detail · esfuerzo $effort/10 · sentir $feeling/5$painSuffix';
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

  @override
  String timeAgoMinutes(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String timeAgoHours(int hours) {
    return 'hace ${hours}h';
  }

  @override
  String get researchEmptyConfig =>
      'Añade un diagnóstico en configuración para ver investigación relevante.';

  @override
  String get researchTitleRecent => 'Resultados recientes de PubMed';

  @override
  String get researchDisclaimer =>
      'Desliza para actualizar. Solo informativo, no es consejo médico.';

  @override
  String get researchTooltipOffline => 'Resultados guardados (sin conexión)';

  @override
  String get researchStateNoData => 'Sin datos. Tira hacia abajo para buscar.';

  @override
  String get researchStateNoResults =>
      'No se encontraron resultados recientes.';

  @override
  String researchLastUpdated(String time) {
    return 'Actualizado: $time';
  }

  @override
  String get researchActionSaved => 'Guardado';

  @override
  String get researchActionSave => 'Guardar';

  @override
  String get researchActionOpenPubMed => 'Abrir en PubMed';

  @override
  String get researchActionCopyPmid => 'Copiar PMID';

  @override
  String researchSnackPmidCopied(String pmid) {
    return 'PMID $pmid copiado.';
  }

  @override
  String get researchLoadingAbstract => 'Cargando resumen…';

  @override
  String get researchEmptyAbstract =>
      'Resumen no disponible. Abre el artículo en PubMed para más detalles.';

  @override
  String get reportRangeDay => '1 día';

  @override
  String get reportRangeWeek => '7 días';

  @override
  String get reportRangeMonth => '30 días';

  @override
  String get reportRangeCustomTooltip => 'Rango personalizado';

  @override
  String reportRangeCustomActiveLabel(String start, String end) {
    return 'Rango: $start → $end';
  }

  @override
  String get structKindJoint => 'Articulación';

  @override
  String get structKindMuscle => 'Músculo';

  @override
  String get structKindTendon => 'Tendón';

  @override
  String get structKindLigament => 'Ligamento';

  @override
  String get structKindSoftTissue => 'Tejido blando';

  @override
  String get structKindNerve => 'Nervio';

  @override
  String get structTypeMuscleStrain => 'Tirón muscular';

  @override
  String get structTypeMuscleDistension => 'Distensión muscular';

  @override
  String get structTypeMuscleTear => 'Desgarro muscular';

  @override
  String get structTypeContracture => 'Contractura';

  @override
  String get structTypeMuscleSpasm => 'Espasmo muscular';

  @override
  String get structTypeTendinitis => 'Tendinitis';

  @override
  String get structTypeTendinosis => 'Tendinosis';

  @override
  String get structTypeBursitis => 'Bursitis';

  @override
  String get structTypeEnthesitis => 'Entesitis';

  @override
  String get structTypeTendonFissure => 'Fisura tendinosa';

  @override
  String get structTypeMildSprain => 'Esguince leve';

  @override
  String get structTypeSevereSprain => 'Esguince grave';

  @override
  String get structTypeLigamentTear => 'Desgarro ligamentario';

  @override
  String get structTypeSuperficialCut => 'Corte superficial';

  @override
  String get structTypeSkinFissure => 'Fisura cutánea';

  @override
  String get structTypeDeepWound => 'Herida profunda';

  @override
  String get structTypeHematoma => 'Hematoma';

  @override
  String get structTypeContusion => 'Contusión';

  @override
  String get structTypeBurn => 'Quemadura';

  @override
  String get structTypeAbrasion => 'Abrasión';

  @override
  String get structTypeParesthesia => 'Parestesia';

  @override
  String get sleepSectionTitle => 'SUEÑO';

  @override
  String get sleepActionAddEntry => '+ registrar sueño';

  @override
  String get sleepModalLogHeader => 'REGISTRAR SUEÑO';

  @override
  String get sleepModalEditHeader => 'EDITAR SUEÑO';

  @override
  String get sleepFieldQualityLabel => 'CALIDAD';

  @override
  String get sleepFieldDurationLabel => 'DURACIÓN';

  @override
  String get sleepFieldDurationHint => 'horas (ej. 7.5)';

  @override
  String get sleepFieldOnsetLatencyLabel => 'TIEMPO EN DORMIRSE';

  @override
  String get sleepFieldOnsetLatencyHint => 'minutos';

  @override
  String get sleepFieldWakeCountLabel => 'DESPERTARES';

  @override
  String get sleepFieldNightmareToggle => 'tuve pesadilla(s)';

  @override
  String get sleepLogLabelSlept => 'dormí';

  @override
  String sleepLogLabelHours(String hours) {
    return '${hours}h';
  }

  @override
  String sleepLogLabelWakes(int count) {
    return '$count× despertares';
  }

  @override
  String sleepLogLabelOnsetLatency(int minutes) {
    return '$minutes min para dormir';
  }

  @override
  String get sleepLogLabelWithNightmare => 'pesadilla';

  @override
  String get settingsOptionalModulesTitle => 'MÓDULOS OPCIONALES';

  @override
  String get settingsOptionalModulesBlurb =>
      'Activa solo lo que quieras trackear. Los módulos desactivados no aparecen en Síntomas.';

  @override
  String get settingsModuleSleepLabel => 'Sueño';

  @override
  String get settingsModuleSleepDescription =>
      'Calidad, duración y despertares por noche.';

  @override
  String get bodyRegionHeadNeck => 'Cabeza y cuello';

  @override
  String get bodyRegionShouldersUpperBack => 'Hombros y espalda alta';

  @override
  String get bodyRegionArms => 'Brazos';

  @override
  String get bodyRegionChestAbdomen => 'Pecho y abdomen';

  @override
  String get bodyRegionLowerBackPelvis => 'Espalda baja y pelvis';

  @override
  String get bodyRegionLegs => 'Piernas';

  @override
  String get zoneJaw => 'Mandíbula';

  @override
  String get zoneTemple => 'Sien';

  @override
  String get zoneShoulderBlades => 'Omóplatos';

  @override
  String get zoneUpperBack => 'Espalda alta';

  @override
  String get zoneUpperArm => 'Brazo';

  @override
  String get zoneElbow => 'Codo';

  @override
  String get zoneForearm => 'Antebrazo';

  @override
  String get zoneChest => 'Pecho';

  @override
  String get zoneSide => 'Costado';

  @override
  String get zoneRibs => 'Costillas';

  @override
  String get zoneAbdomen => 'Abdomen';

  @override
  String get zoneGlutes => 'Glúteos';

  @override
  String get zoneFrontThigh => 'Muslo (delante)';

  @override
  String get zoneBackThigh => 'Atrás del muslo';

  @override
  String get zoneCalf => 'Pantorrilla';

  @override
  String get zoneFeet => 'Pies';

  @override
  String get hydrationSectionTitle => 'HIDRATACIÓN';

  @override
  String get hydrationActionAddEntry => '+ registrar hidratación';

  @override
  String get hydrationModalLogHeader => 'REGISTRAR HIDRATACIÓN';

  @override
  String get hydrationModalEditHeader => 'EDITAR HIDRATACIÓN';

  @override
  String get hydrationFieldVolumeLabel => 'CANTIDAD';

  @override
  String get hydrationFieldVolumeHint => 'ml (ej. 250)';

  @override
  String get hydrationFieldBeverageLabel => 'BEBIDA';

  @override
  String get hydrationFieldSodiumLabel => 'SODIO (opcional)';

  @override
  String hydrationLogLabelVolume(String volume) {
    return '$volume ml';
  }

  @override
  String get hrvSectionTitle => 'HRV';

  @override
  String get hrvActionAddEntry => '+ registrar HRV';

  @override
  String get hrvModalLogHeader => 'REGISTRAR LECTURA HRV';

  @override
  String get hrvModalEditHeader => 'EDITAR LECTURA HRV';

  @override
  String get hrvFieldRmssdLabel => 'RMSSD';

  @override
  String get hrvFieldContextLabel => 'CONTEXTO';

  @override
  String get hrvFieldSourceLabel => 'FUENTE';

  @override
  String get hrvHintTapToEdit => 'tocá el número para editar';

  @override
  String get hrvDirectEditDialogTitle => 'Editar RMSSD';

  @override
  String get hrvDirectEditDialogHint => 'ej. 35';

  @override
  String hrvLogLabelRmssd(String value) {
    return '$value ms';
  }

  @override
  String get hrvSourceManual => 'manual';

  @override
  String get hrvSourceAppleWatch => 'Apple Watch';

  @override
  String get hrvSourceWelltory => 'Welltory';

  @override
  String get hrvSourceOther => 'otro';

  @override
  String get settingsModuleHydrationLabel => 'Hidratación';

  @override
  String get settingsModuleHydrationDescription =>
      'Volumen, bebida y aporte de sodio.';

  @override
  String get settingsModuleHrvLabel => 'HRV';

  @override
  String get settingsModuleHrvDescription =>
      'Variabilidad cardíaca por contexto y fuente.';

  @override
  String get sectionHintNoActivity => 'sin registros aún';

  @override
  String get sectionHintToday => 'último hoy';

  @override
  String get sectionHintYesterday => 'último ayer';

  @override
  String sectionHintDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return 'último hace $_temp0';
  }

  @override
  String get settingsViewPreferencesTitle => 'VISUALIZACIÓN';

  @override
  String get settingsCarefulModeLabel => 'Modo cuidadoso';

  @override
  String get settingsCarefulModeDescription =>
      'Reduce el ruido visual: las secciones empiezan colapsadas. Tap el header para expandir lo que quieras ver.';

  @override
  String get drugKindMedication => 'Medicamento';

  @override
  String get drugKindSupplement => 'Suplemento';

  @override
  String get drugKindHerbal => 'Producto herbal';

  @override
  String get drugInteractionsInBotiquinHeader => 'Interacciones en tu botiquín';

  @override
  String get drugInteractionSeverityHigh => 'Alta';

  @override
  String get drugInteractionSeverityMedium => 'Media';

  @override
  String get drugInteractionSeverityLow => 'Baja';

  @override
  String get drugNoContentSupplement =>
      'Suplemento — no regulado como medicamento. Consulta con tu equipo médico antes de combinarlo con otros tratamientos.';

  @override
  String get drugNoContentHerbal =>
      'Producto herbal — evidencia clínica limitada. Consulta con tu equipo médico antes de combinarlo con otros tratamientos.';

  @override
  String drugNoContentMedlineEmpty(String rxcui) {
    return 'MedlinePlus no devolvió información para este medicamento (RxCUI $rxcui). Puede ser un problema temporal o que la base no tenga contenido para este código.';
  }

  @override
  String get drugNoContentUnmapped =>
      'Aún no tenemos información detallada para este producto. Puedes buscarlo manualmente en medlineplus.gov/spanish.';

  @override
  String get drugNoContentGeneric => 'No se pudo cargar la información.';

  @override
  String get drugReadMoreMedlinePlus => 'Leer más en MedlinePlus';

  @override
  String get drugBrowserOpenError =>
      'No se pudo abrir el navegador. Revisa tu conexión.';

  @override
  String get drugConfidenceMediumWarning =>
      'Mapeo de confianza media — verifica con tu equipo médico si la información no coincide con tu medicamento.';

  @override
  String get drugSourceLocalCurated =>
      'Fuente: información clínica curada localmente para esta app. No reemplaza consejo médico.';

  @override
  String get drugSourceMedlinePlus =>
      'Fuente: MedlinePlus, Biblioteca Nacional de Medicina de EE.UU. No reemplaza consejo médico.';

  @override
  String get drugSourceNoInfo =>
      'Sin información clínica disponible en nuestras fuentes.';

  @override
  String get drugLoadError => 'No se pudo cargar la información.';

  @override
  String get moodQuadrantActivatedUnpleasant => 'activación · malestar';

  @override
  String get moodQuadrantActivatedPleasant => 'activación · bienestar';

  @override
  String get moodQuadrantCalmUnpleasant => 'calma · malestar';

  @override
  String get moodQuadrantCalmPleasant => 'calma · bienestar';

  @override
  String get moodTeaserActivatedUnpleasant => 'tensión, ansiedad';

  @override
  String get moodTeaserActivatedPleasant => 'energía, alegría';

  @override
  String get moodTeaserCalmUnpleasant => 'agotamiento, tristeza';

  @override
  String get moodTeaserCalmPleasant => 'tranquilidad, paz';

  @override
  String get moodSheetStep1Title => '¿CÓMO TE SIENTES?';

  @override
  String get moodSheetCancel => 'cancelar';

  @override
  String get moodSheetStep2Prompt => '¿cómo me siento?';

  @override
  String get moodSheetChangeQuadrant => 'cambiar cuadrante';

  @override
  String get moodSheetAlsoFeelingHeader => 'TAMBIÉN SIENTO…';

  @override
  String get moodSheetNotesHeader => 'CONTEXTO (OPCIONAL)';

  @override
  String get moodSheetNotesPlaceholder => 'Ej. Día con mucha niebla mental…';

  @override
  String get moodSheetSaveButton => 'GUARDAR REGISTRO';

  @override
  String get moodDefinitionDialogAction => 'Entendido';

  @override
  String get moodSectionTitle => 'CÓMO ESTOY';

  @override
  String get moodSectionPrompt => '¿Cómo te sientes?';

  @override
  String get moodSectionRegisterAnother => 'Registrar otro estado';

  @override
  String get severityFunctionalAnchorNone => 'no lo noto';

  @override
  String get severityFunctionalAnchorMild => 'lo noto, pero no me detiene';

  @override
  String get severityFunctionalAnchorModerate =>
      'me obliga a bajar el ritmo o pausar';

  @override
  String get severityFunctionalAnchorIntense =>
      'no puedo hacer lo que tenía planeado';

  @override
  String get severityFunctionalAnchorUnbearable =>
      'no puedo funcionar; necesito detenerme';

  @override
  String get outcomeReasonNatural => 'Cambio natural del síntoma';

  @override
  String get outcomeReasonMedicationHelped => 'Creo que ayudó este medicamento';

  @override
  String get outcomeReasonOtherTrigger =>
      'Otro gatillo (comida, estrés, clima…)';

  @override
  String get outcomeReasonAdditionalMed => 'Tomé otro medicamento también';

  @override
  String get outcomeReasonUnsure => 'No estoy seguro/a';

  @override
  String get medicationOutcomeCoarsePending => 'Pendiente';

  @override
  String get medicationOutcomeCoarseMuchBetter => 'Mucho mejor';

  @override
  String get medicationOutcomeCoarseBetter => 'Mejor';

  @override
  String get medicationOutcomeCoarseSame => 'Igual';

  @override
  String get medicationOutcomeCoarseWorse => 'Peor';

  @override
  String get medicationOutcomeCoarseMuchWorse => 'Mucho peor';

  @override
  String get bowelFormTitleNew => 'REGISTRAR TRÁNSITO';

  @override
  String get bowelFormTitleEdit => 'EDITAR TRÁNSITO';

  @override
  String get bowelFormBristolLabel => 'tipo Bristol';

  @override
  String bowelFormBristolLegendTemplate(
    String constipation,
    String normal,
    String diarrhea,
  ) {
    return '1-2: $constipation  ·  3-5: $normal  ·  6-7: $diarrhea';
  }

  @override
  String get bowelFormHideBristolDetail => 'ocultar detalle';

  @override
  String get bowelFormShowBristolDetail => 'más detalle (escala de Bristol)';

  @override
  String get bowelFormSectionObservations => 'OBSERVACIONES';

  @override
  String get bowelFormToggleUrgency => 'urgencia';

  @override
  String get bowelFormToggleIncompleteEvacuation => 'evacuación incompleta';

  @override
  String get bowelFormNoteHint => 'Nota opcional (contexto, gatillo, etc.)';

  @override
  String get hemorrhoidalFormTitleNew => 'REGISTRAR HEMORROIDE';

  @override
  String get hemorrhoidalFormTitleEdit => 'EDITAR HEMORROIDE';

  @override
  String get hemorrhoidalFormNoteHint => 'Nota opcional';

  @override
  String get formSectionHeaderDiscomfort => 'MOLESTIA';

  @override
  String get formToggleBleeding => 'sangrado';

  @override
  String get formButtonSave => 'GUARDAR';

  @override
  String get structuralFormFollowupHeader => 'SEGUIMIENTO';

  @override
  String get structuralFormFollowupResolvedQuestion => '¿Está resuelto?';

  @override
  String structuralFormFollowupResolvedDateTemplate(String date) {
    return 'Resuelto el $date';
  }

  @override
  String get structuralFormFollowupStillPainfulQuestion => '¿Todavía duele?';

  @override
  String get structuralFormFollowupStillPainfulSubtitle =>
      'Cerró visiblemente pero el dolor sigue';

  @override
  String bowelLogBristolTypeTemplate(int type) {
    return 'tipo $type';
  }

  @override
  String get bowelLogTagUrgency => 'urgencia';

  @override
  String get bowelLogTagBleeding => 'sangrado';

  @override
  String get bowelLogTagIncomplete => 'incompleta';

  @override
  String get hemorrhoidalLogLabel => 'hemorroide';

  @override
  String get hemorrhoidalLogTagBleeding => 'sangrado';

  @override
  String get symptomLogTagUnrated => 'sin rating';

  @override
  String get hoySectionPendingHeader => 'Pendientes';

  @override
  String get hoyOutcomeForYour => ' para tu ';

  @override
  String get hoyOutcomeHideReasons => 'Ocultar';

  @override
  String get hoyBowelCounterToday => 'última evacuación: hoy';

  @override
  String get hoyBowelCounterYesterday => 'última evacuación: ayer';

  @override
  String hoyBowelCounterDaysAgoTemplate(int days) {
    return 'última evacuación: hace $days días';
  }

  @override
  String get hoyNarrativeEmptyPacing =>
      '🛡️ Día de descanso. Aún no has registrado nada — está bien.';

  @override
  String get hoyNarrativeEmpty =>
      'Aún no has registrado nada hoy. ¿Cómo va todo?';

  @override
  String hoyNarrativeSymptomsSingleTemplate(String name, String severity) {
    return 'Registraste 1 síntoma: $name ($severity).';
  }

  @override
  String hoyNarrativeSymptomsManyTemplate(
    int count,
    String name,
    String severity,
  ) {
    return 'Registraste $count síntomas — el más fuerte fue $name ($severity).';
  }

  @override
  String hoyNarrativeStructuralSingleTemplate(String zone) {
    return 'Tuviste 1 evento estructural en $zone.';
  }

  @override
  String hoyNarrativeStructuralManyTemplate(int count) {
    return 'Tuviste $count eventos estructurales hoy.';
  }

  @override
  String hoyNarrativeDosesSingleTemplate(String meds) {
    return 'Tomaste 1 dosis: $meds.';
  }

  @override
  String hoyNarrativeDosesManyTemplate(int count, String meds) {
    return 'Tomaste $count dosis: $meds.';
  }

  @override
  String hoyNarrativeDosesAndMore(int count) {
    return ' y $count más';
  }

  @override
  String hoyNarrativeEmaStatesTemplate(String states) {
    return 'Tus estados y sensaciones registradas: $states.';
  }

  @override
  String get hoyNarrativeEmaStatesEllipsis => '...';

  @override
  String get hoyNarrativePacingTrailer =>
      '🛡️ Te diste permiso para descansar. Eso cuenta.';

  @override
  String get hoyHeaderDatePattern => 'EEEE d \'de\' MMMM';

  @override
  String movementModalTitleRegisterTemplate(String name) {
    return 'REGISTRAR: $name';
  }

  @override
  String movementModalTitleEditTemplate(String name) {
    return 'EDITAR: $name';
  }

  @override
  String get movementModalHintDuration => 'Duración (min)';

  @override
  String get movementModalHintSets => 'Sets';

  @override
  String get movementModalHintReps => 'Reps';

  @override
  String get movementModalHintHeartRate =>
      'Frecuencia cardíaca opcional (ej. 70→110)';

  @override
  String movementModalEffortLabelTemplate(int value) {
    return 'Esfuerzo: $value/10';
  }

  @override
  String movementModalFeelingLabelTemplate(int value) {
    return 'Cómo me sentí: $value/5';
  }

  @override
  String get movementFeelingPainOrInjury => '🤕 Con dolor / lesión';

  @override
  String get movementFeelingUncomfortable =>
      '😟 Con incomodidad / preocupación';

  @override
  String get movementFeelingNeutral => '😐 Neutral';

  @override
  String get movementFeelingRelaxed => '😊 Bien';

  @override
  String get movementFeelingStrongConfident => '💪 Con fuerza y seguridad';

  @override
  String get movementPainLevelNone => 'nada';

  @override
  String get movementPainLevelMild => 'leve';

  @override
  String get movementPainLevelModerate => 'moderado';

  @override
  String get movementPainLevelIntense => 'intenso';

  @override
  String get movementPainLevelSevere => 'severo';

  @override
  String movementPainDeltaImprovedTemplate(int delta) {
    String _temp0 = intl.Intl.pluralLogic(
      delta,
      locale: localeName,
      other: '$delta niveles',
      one: '1 nivel',
    );
    return 'Mejoraste $_temp0';
  }

  @override
  String movementPainDeltaWorseTemplate(int delta) {
    String _temp0 = intl.Intl.pluralLogic(
      delta,
      locale: localeName,
      other: '$delta niveles',
      one: '1 nivel',
    );
    return 'Empeoraste $_temp0';
  }

  @override
  String get movementPainDeltaUnchanged => 'Sin cambios';

  @override
  String movementLogEntryEffortTemplate(int value) {
    return 'esfuerzo $value/10';
  }

  @override
  String movementLogEntryFeelingTemplate(int value) {
    return 'sentir $value/5';
  }

  @override
  String movementLogEntryDeltaImprovedTemplate(int delta) {
    return '↓$delta niv.';
  }

  @override
  String movementLogEntryDeltaWorseTemplate(int delta) {
    return '↑$delta niv.';
  }

  @override
  String get movementLogEntryDeltaUnchanged => 'sin cambio';

  @override
  String get movementLogEntryTherapyDeltaSteady => '=';

  @override
  String get appBarTooltipFontSize => 'Tamaño de texto';

  @override
  String get appBarTooltipDarkMode => 'Modo oscuro';

  @override
  String get appBarTooltipLightMode => 'Modo claro';

  @override
  String get appBarTooltipSettings => 'Configuración';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get settingsProfileConfigTitle => 'CONFIGURACIÓN DE PERFIL';

  @override
  String get settingsMyDataTitle => 'MIS DATOS';

  @override
  String get settingsPatientNameLabel => 'NOMBRE DEL PACIENTE';

  @override
  String get settingsConditionsLabel => 'COMORBILIDADES / DIAGNÓSTICOS';

  @override
  String get settingsRelationshipLabel => 'RELACIÓN CON ESTE PERFIL';

  @override
  String get settingsLifeEventsLabel => 'EVENTOS DE VIDA';

  @override
  String get settingsLocationLabel => 'MI UBICACIÓN (PARA EL CLIMA)';

  @override
  String get settingsConditionsHelper =>
      'Toca la × para eliminar una condición. Para leer sobre ellas, ve a Clínica → Compendio.';

  @override
  String get settingsRelationshipHelper =>
      '¿Para quién es este perfil? Útil si registras a alguien que cuidas.';

  @override
  String get settingsLifeEventsHelper =>
      'Cosas que pueden haber impactado tu cuerpo o ánimo: viajes, accidentes, mudanzas, eventos buenos o estresantes. Aparecen como puntos morados en el calendario.';

  @override
  String get settingsDataHelper =>
      'Tienes derecho a acceder, exportar, importar o eliminar tus datos en cualquier momento.';

  @override
  String get settingsWipeAllHelper =>
      'Esta acción borra todos los perfiles, registros y configuraciones. Irreversible.';

  @override
  String get settingsRelationshipSelf => 'Yo';

  @override
  String get settingsRelationshipChild => 'Mi hijo/a';

  @override
  String get settingsRelationshipPartner => 'Mi pareja';

  @override
  String get settingsRelationshipParent => 'Mi madre/padre';

  @override
  String get settingsRelationshipOther => 'Otro';

  @override
  String get settingsRelationshipNone => '— sin especificar —';

  @override
  String get settingsLifeEventsEmpty => 'Aún no hay eventos registrados.';

  @override
  String get settingsAddEventButton => 'AÑADIR EVENTO';

  @override
  String get settingsLocationNone => 'Sin ubicación. Toca para añadir.';

  @override
  String get settingsLocationButtonAdd => 'AÑADIR COORDENADAS';

  @override
  String get settingsLocationButtonEdit => 'EDITAR COORDENADAS';

  @override
  String get settingsAddProfileButton => 'AÑADIR NUEVO PERFIL';

  @override
  String get settingsDeleteProfileButton => 'ELIMINAR ESTE PERFIL';

  @override
  String get settingsExportDataButton => 'EXPORTAR MIS DATOS';

  @override
  String get settingsWipeAllButton => 'BORRAR TODO';

  @override
  String settingsNewProfileNameTemplate(int number) {
    return 'NUEVO PERFIL $number';
  }

  @override
  String get dialogWipeTitle => 'Eliminar todos los datos';

  @override
  String get dialogWipeContent =>
      'Esta acción borra TODOS los perfiles, registros, configuraciones y caché. No se puede deshacer.\n\n¿Quieres exportar primero?';

  @override
  String get dialogWipeFinalTitle => 'Última confirmación';

  @override
  String dialogWipeFinalContentTemplate(String magicWord) {
    return 'Para confirmar, escribe $magicWord abajo.';
  }

  @override
  String get dialogWipeFinalMagicWord => 'ELIMINAR';

  @override
  String get dialogWipeFinalButton => 'Borrar todo';

  @override
  String get dialogDeleteProfileTitle => 'Eliminar perfil';

  @override
  String dialogDeleteProfileContentTemplate(String name) {
    return '¿Eliminar el perfil \"$name\" y todos sus datos? Esta acción no se puede deshacer.';
  }

  @override
  String get dialogLocationTitle => 'Tu ubicación';

  @override
  String get dialogLocationContent =>
      'Necesito latitud y longitud para traer el clima. Busca tu ciudad en Google Maps, click derecho → copiar coordenadas.';

  @override
  String get dialogLocationHintLat => 'Latitud (ej. -34.61)';

  @override
  String get dialogLocationHintLng => 'Longitud (ej. -58.38)';

  @override
  String get dialogLocationInvalidSnack => 'Coordenadas inválidas.';

  @override
  String get therapyHintArea => 'Zona (ej. cervicales)';

  @override
  String get therapySectionPainBefore => 'DOLOR ANTES';

  @override
  String get therapySectionPainAfter => 'DOLOR DESPUÉS';

  @override
  String get therapyActionMoreDetails =>
      'más detalles (terapeuta, costo, nota)';

  @override
  String get therapyHintTherapist => 'Terapeuta / lugar (opcional)';

  @override
  String get therapyHintCost => 'Costo (opcional)';

  @override
  String get therapyHintNote => 'Nota (opcional)';

  @override
  String get therapyActionSaveChanges => 'GUARDAR CAMBIOS';

  @override
  String get therapyActionLog => 'REGISTRAR';

  @override
  String get compendiumSectionConditionsHeader => 'MIS CONDICIONES';

  @override
  String get compendiumSectionConditionsSubtitle =>
      'Toca una para leer información clínica (fuente: MedlinePlus).';

  @override
  String compendiumSavedArticlesTemplate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos guardados',
      one: '1 artículo guardado',
    );
    return '$_temp0 — ve a Investigación.';
  }

  @override
  String get compendiumSectionDataTitle => 'DATOS CLÍNICOS';

  @override
  String get compendiumFactSourceLabel => 'Fuente:';

  @override
  String investigationConditionArticleCountTemplate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
    );
    return '$_temp0';
  }

  @override
  String get headacheSheetTitle => 'Detalle de tu cefalea';

  @override
  String get headacheSheetSubtitle =>
      'Marca lo que aplique. Puedes saltar este paso si prefieres.';

  @override
  String get actionSkip => 'Saltar';

  @override
  String get headacheActionSaveDetail => 'Guardar detalle';

  @override
  String get headacheThunderclapWarningTitle => 'Posible emergencia';

  @override
  String get headacheThunderclapWarningConfirm => 'Lo entiendo, continuar';

  @override
  String get headacheAdvisoryDialogTitle => 'Patrones a considerar';

  @override
  String get headacheRedFlagCsfLeakAdvisory =>
      'Tu cefalea empeora marcadamente al estar de pie. Este patrón puede sugerir una fuga de líquido cefalorraquídeo, especialmente en personas con EDS. Si se repite, considera mencionárselo a tu médico.';

  @override
  String get headacheRedFlagIntracranialAdvisory =>
      'Tu cefalea empeora al recostarte. Este patrón puede sugerir aumento de presión intracraneal. Si se repite o se acompaña de cambios visuales, considera evaluación médica.';

  @override
  String get settingsModuleHeadacheDetailLabel => 'Detalle de cefalea';

  @override
  String get settingsModuleHeadacheDetailDescription =>
      'Captura localización, calidad y otros patrones al registrar una cefalea.';

  @override
  String get fatigueSheetTitle => 'Detalle de tu fatiga';

  @override
  String get fatigueSheetSubtitle =>
      'Los detalles opcionales ayudan a identificar patrones.';

  @override
  String get fatigueActionSaveDetail => 'Guardar detalle';

  @override
  String get fatigueAdvisoryDialogTitle => 'Patrones detectados';

  @override
  String get fatigueRedFlagPemAdvisory =>
      'Este patrón muestra que tu fatiga aparece 1-3 días después de un esfuerzo. Puede indicar que tu cuerpo tiene menos reservas de energía de lo habitual y necesita más días para recuperarse. Si se repite, considera mencionárselo a tu médico.';

  @override
  String get fatigueRedFlagOrthostaticAdvisory =>
      'Tu fatiga empeora al estar de pie o sentada erecta. Puede indicar que tu cuerpo tiene dificultad para mantener presión sanguínea o pulso estables al estar arriba. Es común en personas con EDS. Vale mencionárselo a tu médico.';

  @override
  String get fatigueRedFlagHpaAdvisory =>
      'Tu cuerpo se siente exhausto pero no logra descansar. Esto puede indicar que tu sistema de estrés lleva mucho tiempo activado y las hormonas que regulan el descanso están desajustadas. Vale mencionárselo a tu médico.';

  @override
  String get settingsModuleFatigueDetailLabel => 'Detalle de fatiga';

  @override
  String get settingsModuleFatigueDetailDescription =>
      'Al registrar fatiga, agrega tipo, patrón temporal y acompañantes.';

  @override
  String get abdominalSheetTitle => 'Detalle del dolor abdominal';

  @override
  String get abdominalSheetSubtitle =>
      'Los detalles opcionales ayudan a identificar patrones.';

  @override
  String get abdominalActionSaveDetail => 'Guardar detalle';

  @override
  String get abdominalTearingEmergencyTitle => 'Dolor tipo desgarro';

  @override
  String get abdominalTearingEmergencyBody =>
      'El dolor de desgarro súbito y muy severo puede indicar una emergencia médica en personas con síndrome de Ehlers-Danlos. Vale la pena que vayas a urgencias ahora para descartar rotura arterial o intestinal.\n\nSi vas, informa al equipo médico tu diagnóstico de clEDS (síndrome de Ehlers-Danlos clásico-like, por mutación de TNXB).\n\nSi el dolor mejoró significativamente y ya no lo describirías como desgarro, puedes cambiar la calidad del dolor y guardar el registro normalmente.';

  @override
  String get abdominalTearingEmergencyChangeQuality =>
      'Cambiar calidad y guardar';

  @override
  String get abdominalTearingEmergencySaveAsIs =>
      'Guardar como está (emergencia)';

  @override
  String get abdominalAdvisoryDialogTitle => 'Patrones detectados';

  @override
  String get abdominalRedFlagMassiveHematocheziaUrgent =>
      'Este patrón (sangre en heces junto con náusea o vómito y dolor intenso) puede indicar un sangrado GI activo. Si el sangrado es abundante o notas mucha debilidad o mareo, ve a urgencias ahora.';

  @override
  String get abdominalRedFlagHematemesisUrgent =>
      'En tu nota mencionaste vómito con sangre. Este síntoma indica sangrado del sistema digestivo alto y requiere evaluación en urgencias inmediatamente.';

  @override
  String get abdominalRedFlagNocturnalPainAdvisory =>
      'Tu dolor te despertó por la noche. Este patrón es un signo de alarma que vale mencionar a tu médico, especialmente si notas pérdida de peso involuntaria o fiebre.';

  @override
  String get abdominalRedFlagGastroparesisAdvisory =>
      'Tu dolor aparece justo al comer y sientes saciedad temprana. Este patrón puede indicar que tu estómago se vacía más lento de lo normal. Es común en personas con EDS y disautonomía. Vale mencionárselo a tu médico.';

  @override
  String get settingsModuleAbdominalDetailLabel => 'Detalle de dolor abdominal';

  @override
  String get settingsModuleAbdominalDetailDescription =>
      'Al registrar dolor, hinchazón o gases, agrega ubicación, calidad, timing y acompañantes.';

  @override
  String get bowelToAbdominalPromptTitle => '¿Registrar detalle del dolor?';

  @override
  String get bowelToAbdominalPromptBody =>
      'Marcaste este evento como acompañado de dolor abdominal. ¿Registrar el detalle ahora para identificar patrones?';

  @override
  String get abdominalToBowelPromptTitle => '¿Vinculado a una evacuación?';

  @override
  String abdominalToBowelPromptBody(String time) {
    return 'Marcaste este dolor como relacionado con evacuación. Registraste una evacuación a las $time. ¿Es la misma?';
  }

  @override
  String get abdominalIntegrationYes => 'Sí';

  @override
  String get abdominalIntegrationNo => 'No';

  @override
  String get abdominalIntegrationDontKnow => 'No lo sé';

  @override
  String get onboardingStepMedsUnitHint => '1';

  @override
  String get onboardingStepMedsStrengthHint => 'mg';
}
