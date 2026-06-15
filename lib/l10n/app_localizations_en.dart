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

  @override
  String get actionHide => 'Hide';

  @override
  String get hintTapTip =>
      'Tip: In Symptoms, tap a container chip to log. Long press a log entry to edit.';

  @override
  String get sectionPending => 'Pending Check-ins';

  @override
  String get sectionWeather => 'TODAY\'S WEATHER';

  @override
  String get headerTodayIs => 'Today is';

  @override
  String get pacingActiveState => 'Rest day — zero expectations';

  @override
  String get pacingInactiveState => 'Mark as a rest day';

  @override
  String outcomeCardTimePrefix(String hours) {
    return '${hours}h ago you took';
  }

  @override
  String get outcomeCardForSymptom => 'for your';

  @override
  String get outcomeCardInitialState => 'It was at';

  @override
  String get outcomeCardQuestionNow => 'How is it now?';

  @override
  String get outcomeCardAttributionQuestion => 'What do you attribute this to?';

  @override
  String get outcomeActionAddFactor => 'Other factor';

  @override
  String get sectionMentalDetails => 'Mental Details';

  @override
  String get mentalIntensitySubtitle => 'Current intensity';

  @override
  String get summaryTitle => 'Your day in a nutshell';

  @override
  String get summaryEmptyPacing =>
      '🛡️ Rest day. You haven\'t recorded anything yet — that is perfectly fine.';

  @override
  String get summaryEmptyNormal =>
      'You haven\'t tracked anything yet today. How is it going?';

  @override
  String summarySymptomSingle(String name, String label) {
    return 'You logged 1 symptom: $name ($label).';
  }

  @override
  String summarySymptomPlural(int count, String name, String label) {
    return 'You logged $count symptoms — the most intense was $name ($label).';
  }

  @override
  String summaryStructuralSingle(String zone) {
    return 'You had 1 structural event in your $zone.';
  }

  @override
  String summaryStructuralPlural(int count) {
    return 'You had $count structural events today.';
  }

  @override
  String summaryDosesSentence(int totalDoses, String shown, int extraCount) {
    String _temp0 = intl.Intl.pluralLogic(
      totalDoses,
      locale: localeName,
      other: 'doses',
      one: 'dose',
    );
    String _temp1 = intl.Intl.pluralLogic(
      extraCount,
      locale: localeName,
      other: ' and $extraCount more',
      zero: '',
    );
    return 'You took $totalDoses $_temp0: $shown$_temp1.';
  }

  @override
  String summaryMoodSentence(String statesStr, String extra) {
    return 'Your logged moods and entries: $statesStr$extra.';
  }

  @override
  String get summaryPacingFooter =>
      '🛡️ You gave yourself permission to rest. That counts.';

  @override
  String get wisdomBannerTitle => '✨ Zebra Wisdom 🦓';

  @override
  String get bowelCountToday => 'last bowel movement: today';

  @override
  String get bowelCountYesterday => 'last bowel movement: yesterday';

  @override
  String bowelCountDaysAgo(int days) {
    return 'last bowel movement: $days days ago';
  }

  @override
  String distentionBannerMessage(int days) {
    return 'It has been $days days without a bowel movement — distention and abdominal pain can accumulate.';
  }

  @override
  String get distentionBannerAction => 'Go to Symptoms';

  @override
  String get severityNone => 'None';

  @override
  String get severityMild => 'Mild';

  @override
  String get severityModerate => 'Moderate';

  @override
  String get severityIntense => 'Severe';

  @override
  String get severityUnbearable => 'Unbearable';

  @override
  String get reasonNatural => 'Natural variance of symptom';

  @override
  String get reasonMedicationHelped => 'I believe this medication helped';

  @override
  String get reasonOtherTrigger => 'Other trigger (food, stress, weather...)';

  @override
  String get reasonAdditionalMed => 'Took another medication as well';

  @override
  String get reasonUnsure => 'Unsure';

  @override
  String get mentalStateMood => 'Mood';

  @override
  String get mentalStateAnxiety => 'Anxiety';

  @override
  String get mentalStateBrainFog => 'Brain Fog';

  @override
  String get mentalStateDissociation => 'Dissociation';

  @override
  String get mentalStateIrritability => 'Irritability';

  @override
  String get mentalStateEmotionalEnergy => 'Emotional Energy';

  @override
  String get outcomeCoarsePending => 'Pending';

  @override
  String get outcomeCoarseMuchBetter => 'Much better';

  @override
  String get outcomeCoarseBetter => 'Better';

  @override
  String get outcomeCoarseEqual => 'No change';

  @override
  String get outcomeCoarseWorse => 'Worse';

  @override
  String get outcomeCoarseMuchWorse => 'Much worse';

  @override
  String get pubMedNoAuthor => 'No author listed';

  @override
  String get quadrantActivatedUnpleasant => 'high activation · unpleasant';

  @override
  String get quadrantActivatedPleasant => 'high activation · pleasant';

  @override
  String get quadrantCalmUnpleasant => 'low activation · unpleasant';

  @override
  String get quadrantCalpleasant => 'calma · bienestar';

  @override
  String get quadrantTeaserActivatedUnpleasant => 'tension, anxiety';

  @override
  String get quadrantTeaserActivatedPleasant => 'energy, joy';

  @override
  String get quadrantTeaserCalmUnpleasant => 'exhaustion, sadness';

  @override
  String get quadrantTeaserCalmPleasant => 'tranquility, peace';

  @override
  String get bowelBucketConstipation => 'constipation';

  @override
  String get bowelBucketNormal => 'normal';

  @override
  String get bowelBucketDiarrea => 'diarrhea';

  @override
  String get sleepQualityBad => 'poor';

  @override
  String get sleepQualityRegular => 'fair';

  @override
  String get sleepQualityGood => 'good';

  @override
  String get sleepQualityVeryGood => 'excellent';

  @override
  String get beverageWater => 'water';

  @override
  String get beverageElectrolyte => 'electrolytes';

  @override
  String get beverageCoffee => 'coffee';

  @override
  String get beverageOther => 'other';

  @override
  String get sodiumPinch => 'pinch of salt';

  @override
  String get sodiumSachet => 'electrolyte pack';

  @override
  String get sodiumSaltySnack => 'salty snack';

  @override
  String get hrvContextMorning => 'morning';

  @override
  String get hrvContextAfternoon => 'afternoon';

  @override
  String get hrvContextEvening => 'evening';

  @override
  String get hrvContextPostExercise => 'post-exercise';

  @override
  String get hrvContextOther => 'other';

  @override
  String legacyIntensityLabel(String value) {
    return 'Previous intensity: $value/5';
  }

  @override
  String get botiquinTabTitle => 'Med Kit';

  @override
  String get botiquinActionCreate => 'Add Medication';

  @override
  String get botiquinInteractionsTitle => 'Detected Interactions';

  @override
  String get botiquinGroupsTitle => 'Medication Groups';

  @override
  String get botiquinGroupsEmptyHeadline => '🌙 Night Meds · ☀️ Morning Meds';

  @override
  String get botiquinGroupsEmptyBody =>
      'Group up medications you take at the same time. One tap logs the entire batch instantly.';

  @override
  String get botiquinActionCreateGroup => 'Create Group';

  @override
  String get botiquinNoMedsDialogTitle => 'No Medications Found';

  @override
  String get botiquinNoMedsDialogBody =>
      'Please add at least one medication to your med kit before setting up a tracking group.';

  @override
  String botiquinRowMedsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'medications',
      one: 'medication',
    );
    return '$count $_temp0';
  }

  @override
  String get botiquinActionEditTooltip => 'Edit';

  @override
  String get botiquinBatchSheetTitle => 'Log Group';

  @override
  String get botiquinBatchSheetSubtitle =>
      'The following doses will be logged:';

  @override
  String botiquinBatchOrphanWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'medications have been deleted',
      one: 'medication has been deleted',
    );
    return '⚠️ $count $_temp0 from your kit and will be skipped.';
  }

  @override
  String botiquinBatchActionSubmit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'doses',
      one: 'dose',
    );
    return 'Log $count $_temp0';
  }

  @override
  String get botiquinEmptyStateHeadline => 'No medications added yet';

  @override
  String get botiquinEmptyStateSubtitle =>
      'Create your first one using the button below.';

  @override
  String botiquinDoseLoggedTodayBadge(String qty) {
    return '$qty today';
  }

  @override
  String botiquinDeleteConfirmTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String botiquinDeleteConfirmBody(String name) {
    return 'Dose history will be preserved for your clinical metrics, but $name will be removed from your active kit layout.';
  }

  @override
  String get botiquinActionDelete => 'Delete';

  @override
  String get botiquinLogDoseSheetTitle => 'Log Dose';

  @override
  String botiquinLogDoseTotalCalculated(String total, String unit) {
    return '= $total $unit total';
  }

  @override
  String get botiquinLogDoseSymptomPrompt => 'For a specific symptom?';

  @override
  String get botiquinLogDoseSymptomNone => 'None';

  @override
  String botiquinLogDoseTrackOutcomeToggle(int hours) {
    return 'Check in ${hours}h to track efficacy';
  }

  @override
  String get botiquinDoseListTitle => 'Today\'s Doses';

  @override
  String get botiquinDoseListFootnote =>
      'Tap × to remove an incorrect entry (useful if logged under a wrong parameter).';

  @override
  String get botiquinDoseItemDeleteConfirmTitle => 'Delete This Entry';

  @override
  String botiquinDoseItemDeleteConfirmBody(String name, String time) {
    return 'Are you sure you want to delete the dose of $name logged at $time? This action is permanent.';
  }

  @override
  String botiquinTimeTodayAt(String time) {
    return 'Today at $time';
  }

  @override
  String botiquinTimePastAt(int day, int month, String time) {
    return '$day/$month at $time';
  }

  @override
  String get onboardingActionBack => 'back';

  @override
  String get onboardingActionSkip => 'skip';

  @override
  String get onboardingActionNext => 'NEXT';

  @override
  String get onboardingActionFinish => 'GET STARTED';

  @override
  String get onboardingFallbackProfileName => 'My Profile';

  @override
  String get onboardingStepWelcomeTitle => 'ZebraUp';

  @override
  String get onboardingStepWelcomeSubtitle =>
      'Your co-pilot for medical appointments.';

  @override
  String get onboardingStepWelcomeBody =>
      'Consultations are short. After a rough week, your memory is short too. ZebraUp logs your symptoms, medications, and patterns so you walk into every appointment with concrete data — not vague phrases that vanish the moment you face the doctor. And because we know you care for others, you can add family members and pets too.';

  @override
  String get onboardingStepWelcomePrivacyNote =>
      'All your data is saved locally on this device. We do not upload anything to the internet.';

  @override
  String get onboardingStepWelcomeMedicalDisclaimer =>
      'This application is not a medical device. It does not diagnose, treat, cure, or prevent any medical condition.';

  @override
  String get onboardingStepNameTitle => 'Let\'s get started.';

  @override
  String get onboardingStepNameQuestion => 'What should we call you?';

  @override
  String get onboardingStepNameFootnote =>
      'This is only used to personalize the app. You can change it later.';

  @override
  String get onboardingStepNameHint => 'Your name or nickname';

  @override
  String get onboardingStepConditionsTitle => 'Your diagnoses.';

  @override
  String get onboardingStepConditionsBody =>
      'What conditions do you manage? We use them to contextualize interactions and reports. You can add, edit, or skip this step.';

  @override
  String get onboardingStepConditionsHint => 'e.g., hEDS, POTS, MCAS...';

  @override
  String get onboardingStepConditionsEmpty =>
      'None added yet. You can safely skip this step.';

  @override
  String get onboardingStepMedsTitle => 'Your med kit.';

  @override
  String get onboardingStepMedsBody =>
      'Add the medications you take regularly. You will be able to log each dose with a single tap from the Med Kit tab.';

  @override
  String get onboardingStepMedsNameHint => 'Name';

  @override
  String get onboardingStepMedsDoseHint => 'Dose (e.g., 400mg)';

  @override
  String get onboardingStepMedsEmpty =>
      'No medications for now. You can safely skip this step.';

  @override
  String get symptomsSectionStructuralZones => 'STRUCTURAL ZONES';

  @override
  String get symptomsSectionBowelTransit => 'BOWEL TRANSIT';

  @override
  String get symptomsActionAddHemorrhoid => 'hemorrhoid';

  @override
  String get symptomsSectionTodaysLogs => 'TODAY\'S RECORDS';

  @override
  String get symptomsFootnoteLongPressEdit =>
      'Long press an entry to edit date, severity, or custom note.';

  @override
  String get symptomsSectionTrending => 'TRENDING (LAST 7 DAYS)';

  @override
  String get symptomsTrendingEmpty =>
      'No consistent symptoms logged this week.';

  @override
  String get symptomsSectionVault => 'SYMPTOM VAULT';

  @override
  String get symptomsVaultPlaceholder => '+ Add symptom to vault...';

  @override
  String symptomsModalLogHeader(String zone) {
    return 'LOG ENTRY IN: $zone';
  }

  @override
  String symptomsModalEditHeader(String zone, String type) {
    return 'EDIT: $zone / $type';
  }

  @override
  String symptomsModalEditSymptomHeader(String name) {
    return 'EDIT: $name';
  }

  @override
  String get symptomsLabelOptionalNote =>
      'Optional note (context, trigger, etc.)';

  @override
  String get symptomsLabelOptionalNoteSimple => 'Optional note';

  @override
  String get symptomsLabelSeverityGrading => 'SEVERITY';

  @override
  String get symptomsActionLogUnrated => 'Log without rating';

  @override
  String get symptomsUnratedLabelSuffix => 'unrated';

  @override
  String get symptomsUnratedInlineWarning =>
      'This entry has no severity rating assigned. Tap a dot to add one.';

  @override
  String get symptomsActionSaveChanges => 'SAVE CHANGES';

  @override
  String get symptomsActionSave => 'SAVE';

  @override
  String get zoneCervical => 'Neck/Cervical';

  @override
  String get zoneHombros => 'Shoulders';

  @override
  String get zoneMunecas => 'Wrists';

  @override
  String get zoneManos => 'Hands';

  @override
  String get zoneLumbarPelvis => 'Lower Back/Pelvis';

  @override
  String get zoneCaderas => 'Hips';

  @override
  String get zoneRodillas => '膝/Rodillas';

  @override
  String get zoneTobillos => 'Ankles';

  @override
  String get structTypeSubluxation => 'Subluxation';

  @override
  String get structTypeDislocation => 'Dislocation';

  @override
  String get structTypeInstability => 'Joint Instability';

  @override
  String get structTypeJointPain => 'Joint Pain';

  @override
  String get structTypeMyofascial => 'Myofascial Pain';

  @override
  String get structTypeNeuropathic => 'Neuropathic Pain';

  @override
  String bowelLabelBristolType(String type) {
    return 'type $type';
  }

  @override
  String get bowelLabelUrgency => 'urgency';

  @override
  String get bowelLabelBleeding => 'bleeding';

  @override
  String get bowelLabelIncomplete => 'incomplete evacuation';

  @override
  String get movementSectionPacingActive =>
      'Today is a rest day. Resting counts too.';

  @override
  String get movementSectionHistoryTitle => 'TODAY\'S ACTIVITIES & THERAPIES';

  @override
  String get movementFootnoteLongPressEdit => 'Long press an entry to edit.';

  @override
  String get movementEmptyStateHeadline =>
      'Movement and recovery are two sides of the same coin.';

  @override
  String get movementEmptyStateSubtitle =>
      'Walking, stretching, a physical therapy session, a massage — it all counts as body care.';

  @override
  String get movementSectionActivityTitle => 'ACTIVITY';

  @override
  String get movementActivityPlaceholder =>
      '+ Add activity (swimming, cycling, dancing...)';

  @override
  String get movementSectionTherapyTitle => 'THERAPY';

  @override
  String get movementTherapyPlaceholder =>
      '+ Add modality (reiki, floatation...)';

  @override
  String activityModalLogHeader(String name) {
    return 'LOG: $name';
  }

  @override
  String activityModalEditHeader(String name) {
    return 'EDIT: $name';
  }

  @override
  String get activityFieldDurationHint => 'Duration (min)';

  @override
  String get activityFieldSetsHint => 'Sets';

  @override
  String get activityFieldRepsHint => 'Reps';

  @override
  String get activityFieldHhrHint =>
      'Optional heart rate mapping (e.g., 70→110)';

  @override
  String activityLabelEffortSlider(int value) {
    return 'Effort Level: $value/10';
  }

  @override
  String activityLabelFeelingSlider(int value) {
    return 'Subjective Feeling: $value/5';
  }

  @override
  String get activityActionTogglePainRating =>
      'rate pain pre/post session (optional)';

  @override
  String get activityLabelPainBefore => 'PAIN BEFORE';

  @override
  String get activityLabelPainAfter => 'PAIN AFTER';

  @override
  String get activityActionSubmitLog => 'SAVE ACTIVITY';

  @override
  String get activityActionSubmitChanges => 'SAVE CHANGES';

  @override
  String get painLabelNone => 'none';

  @override
  String get painLabelMild => 'mild';

  @override
  String get painLabelModerate => 'moderate';

  @override
  String get painLabelIntense => 'intense';

  @override
  String get painLabelSevere => 'severe';

  @override
  String painDeltaLabelImproved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'levels',
      one: 'level',
    );
    return 'Improved by $count $_temp0';
  }

  @override
  String painDeltaLabelWorsened(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'levels',
      one: 'level',
    );
    return 'Worsened by $count $_temp0';
  }

  @override
  String get painDeltaLabelUnchanged => 'No change';

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
    return '$detail · effort $effort/10 · feel $feeling/5$painSuffix ';
  }

  @override
  String logSubtitlePainDeltaImproved(int levels) {
    return '↓$levels lvl.';
  }

  @override
  String logSubtitlePainDeltaWorsened(int levels) {
    return '↑$levels lvl.';
  }

  @override
  String get logSubtitlePainDeltaUnchanged => 'no change';

  @override
  String get feelingLabelLevel1 => '🤕 In pain / injury risk';

  @override
  String get feelingLabelLevel2 => '😟 Uncomfortable / guarded';

  @override
  String get feelingLabelLevel3 => '😐 Neutral';

  @override
  String get feelingLabelLevel4 => '😊 Relaxed';

  @override
  String get feelingLabelLevel5 => '💪 Strong and confident';

  @override
  String get onboardingHaveProfileTitle => 'I already have a saved profile';

  @override
  String get onboardingHaveProfileSubtitle => 'Import from a JSON file';

  @override
  String get onboardingImportChoiceTitle => 'How would you like to import?';

  @override
  String get onboardingImportFromFile => 'From file';

  @override
  String get onboardingImportFromPaste => 'Paste text';

  @override
  String get feverSectionTitle => 'FEVER';

  @override
  String get feverActionAddReading => '+ log temperature';

  @override
  String get feverModalLogHeader => 'LOG TEMPERATURE';

  @override
  String get feverModalEditHeader => 'EDIT READING';

  @override
  String get feverFieldSiteLabel => 'SITE';

  @override
  String get feverFieldAntipyreticLabel => 'FEVER REDUCER';

  @override
  String get feverFieldAntipyreticToggle => 'took something to lower it';

  @override
  String get feverFieldAntipyreticNameHint =>
      'name (acetaminophen, ibuprofen...)';

  @override
  String get feverHintTapToEdit => 'tap the number to edit';

  @override
  String get feverDirectEditDialogTitle => 'Edit temperature';

  @override
  String get feverDirectEditDialogHint => 'e.g., 38.7';

  @override
  String get feverLogLabelWithAntipyretic => 'with fever reducer';

  @override
  String get feverSiteAxillary => 'axillary';

  @override
  String get feverSiteOral => 'oral';

  @override
  String get feverSiteTympanic => 'tympanic';

  @override
  String get feverSiteRectal => 'rectal';

  @override
  String get feverSiteForehead => 'forehead';
}
