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
  String get navBotiquin => 'Med Cabinet';

  @override
  String get navClinica => 'Clinic';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionImport => 'Import';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionUnderstood => 'Understood';

  @override
  String get languageSectionTitle => 'IDIOMA / LANGUAGE';

  @override
  String get languageFootnote =>
      'The language applies to the entire app. Your data does not change.';

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
  String get wipeAllButton => 'ERASE EVERYTHING';

  @override
  String get wipeWarningFootnote =>
      'This action erases all profiles, logs, and settings. Irreversible.';

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
      'This will be added as a new profile. Your current profile will not be deleted.';

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
  String get nounMoods => 'moods';

  @override
  String get nounMental => 'mental logs';

  @override
  String get pasteImportTitle => 'Import by pasting text';

  @override
  String get pasteImportInstructions =>
      'Open your exported .json file (e.g., from the Files app), select all text, copy it, and paste it here.';

  @override
  String get pasteImportHint => 'Paste file content here...';

  @override
  String get errImportUnreadable => 'Could not read the file.';

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
      'The profile is corrupted or has an unexpected format.';

  @override
  String get actionHide => 'Hide';

  @override
  String get hintTapTip =>
      'Tip: In Symptoms, tap a chip from the vault to log it. Long press a log to edit.';

  @override
  String get sectionPending => 'Pending';

  @override
  String get sectionWeather => 'TODAY\'S WEATHER';

  @override
  String get headerTodayIs => 'Today is';

  @override
  String get pacingActiveState => 'Rest day — no expectations';

  @override
  String get pacingInactiveState => 'Mark as rest day';

  @override
  String outcomeCardTimePrefix(String hours) {
    return '${hours}h ago you took';
  }

  @override
  String get outcomeCardForSymptom => 'for your';

  @override
  String get outcomeCardInitialState => 'It was at ';

  @override
  String get outcomeCardQuestionNow => 'How is it now?';

  @override
  String get outcomeCardAttributionQuestion => 'What do you attribute it to?';

  @override
  String get outcomeActionAddFactor => 'Other factor';

  @override
  String get sectionMentalDetails => 'Mental details';

  @override
  String get mentalIntensitySubtitle => 'Intensity now';

  @override
  String get summaryTitle => 'Your day in a nutshell';

  @override
  String get summaryEmptyPacing =>
      '🛡️ Rest day. You haven\'t logged anything yet — that\'s okay.';

  @override
  String get summaryEmptyNormal =>
      'You haven\'t logged anything today yet. How is everything going?';

  @override
  String summarySymptomSingle(String name, String label) {
    return 'You logged 1 symptom: $name ($label).';
  }

  @override
  String summarySymptomPlural(int count, String name, String label) {
    return 'You logged $count symptoms — the strongest was $name ($label).';
  }

  @override
  String summaryStructuralSingle(String zone) {
    return 'You had 1 structural event in $zone.';
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
    return 'Your logged states and sensations: $statesStr$extra.';
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
    return 'You have gone $days days without a bowel movement — bloating and abdominal pain may build up.';
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
  String get reasonNatural => 'Natural symptom shift';

  @override
  String get reasonMedicationHelped => 'I think this medication helped';

  @override
  String get reasonOtherTrigger => 'Other trigger (food, stress, weather...)';

  @override
  String get reasonAdditionalMed => 'I took another medication as well';

  @override
  String get reasonUnsure => 'Not entirely sure';

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
  String get pubMedNoAuthor => 'No author registered';

  @override
  String get quadrantActivatedUnpleasant => 'activated · unpleasant';

  @override
  String get quadrantActivatedPleasant => 'activated · pleasant';

  @override
  String get quadrantCalmUnpleasant => 'calm · unpleasant';

  @override
  String get quadrantCalpleasant => 'calm · pleasant';

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
  String get bowelBucketDiarrhea => 'diarrhea';

  @override
  String get sleepQualityBad => 'poor';

  @override
  String get sleepQualityRegular => 'fair';

  @override
  String get sleepQualityGood => 'good';

  @override
  String get sleepQualityVeryGood => 'very good';

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
  String get sodiumSachet => 'electrolyte sachet';

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
  String get hrvContextAverage => 'average';

  @override
  String get hrvContextOther => 'other';

  @override
  String legacyIntensityLabel(String value) {
    return 'Previous intensity: $value/5';
  }

  @override
  String get botiquinTabTitle => 'Your Med Cabinet';

  @override
  String get botiquinActionCreate => 'Create medication';

  @override
  String get botiquinSearchHint => 'Search medication...';

  @override
  String get botiquinSearchNoResults => 'No medications found';

  @override
  String get botiquinInteractionsTitle => 'Interactions detected';

  @override
  String get botiquinGroupsTitle => 'Groups';

  @override
  String get botiquinGroupsEmptyHeadline => '🌙 Night meds · ☀️ Morning meds';

  @override
  String get botiquinGroupsEmptyBody =>
      'Group medications you take together. A single tap logs all doses at once.';

  @override
  String get botiquinActionCreateGroup => 'Create group';

  @override
  String get botiquinNoMedsDialogTitle => 'No medications';

  @override
  String get botiquinNoMedsDialogBody =>
      'Create at least one medication in your cabinet before forming a group.';

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
  String get botiquinBatchSheetTitle => 'Log group';

  @override
  String get botiquinBatchSheetSubtitle => 'These doses will be logged:';

  @override
  String botiquinBatchOrphanWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'deleted medications',
      one: 'deleted medication',
    );
    return '⚠️ $count $_temp0 from your cabinet — will be skipped.';
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
  String get botiquinEmptyStateHeadline =>
      'You haven\'t added any medications yet';

  @override
  String get botiquinEmptyStateSubtitle => 'Create one using the button below.';

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
    return 'Dose history will be kept for your reports, but $name will be removed from your cabinet.';
  }

  @override
  String get botiquinActionDelete => 'Delete';

  @override
  String get botiquinLogDoseSheetTitle => 'Log dose';

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
    return 'Ask in ${hours}h if it helped';
  }

  @override
  String get botiquinDoseListTitle => 'Today\'s doses';

  @override
  String get botiquinDoseListFootnote =>
      'Tap × to delete a specific dose (useful if logged incorrectly).';

  @override
  String get botiquinDoseItemDeleteConfirmTitle => 'Delete this dose';

  @override
  String botiquinDoseItemDeleteConfirmBody(String name, String time) {
    return 'Delete the dose of $name logged at $time? This action cannot be undone.';
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
  String get onboardingActionFinish => 'START';

  @override
  String get onboardingFallbackProfileName => 'My Profile';

  @override
  String get onboardingStepWelcomeTitle => 'ZebraUp';

  @override
  String get onboardingStepWelcomeSubtitle =>
      'Your co-pilot for medical appointments.';

  @override
  String get onboardingStepWelcomeBody =>
      'Appointments are short. Your memory, after a difficult week, is too. ZebraUp logs your symptoms, medications, and patterns so you can arrive at every appointment with concrete data — not vague phrases that you forget as soon as you sit across from the doctor. And because we know you take care of others, you can add family members and pets.';

  @override
  String get onboardingStepWelcomePrivacyNote =>
      'All your data is stored on this device. We do not upload anything to the internet.';

  @override
  String get onboardingStepWelcomeMedicalDisclaimer =>
      'This application is not a medical device. It does not diagnose, treat, cure, or prevent any medical condition.';

  @override
  String get onboardingStepNameTitle => 'Let\'s start.';

  @override
  String get onboardingStepNameQuestion => 'What should we call you?';

  @override
  String get onboardingStepNameFootnote =>
      'Only used to personalize the app. You can change it later.';

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
      'You haven\'t added any yet. You can skip this step.';

  @override
  String get onboardingStepMedsTitle => 'Your Med Cabinet.';

  @override
  String get onboardingStepMedsBody =>
      'Add the medications you take regularly. You will be able to log each dose with a tap from the Med Cabinet tab.';

  @override
  String get onboardingStepMedsNameHint => 'Name';

  @override
  String get onboardingStepMedsDoseHint => 'Dose (e.g., 400mg)';

  @override
  String get onboardingStepMedsEmpty =>
      'No medications for now. You can skip this step.';

  @override
  String get symptomsSectionStructuralZones => 'STRUCTURAL ZONES';

  @override
  String get symptomsSectionBowelTransit => 'BOWEL TRANSIT';

  @override
  String get symptomsActionAddHemorrhoid => 'hemorrhoid';

  @override
  String get symptomsSectionTodaysLogs => 'TODAY\'S LOGS';

  @override
  String get symptomsFootnoteLongPressEdit =>
      'Long press a log to edit date/severity/note.';

  @override
  String get symptomsSectionTrending => 'TRENDING (LAST 7 DAYS)';

  @override
  String get symptomsTrendingEmpty => 'No consistent symptoms this week.';

  @override
  String get symptomsSectionVault => 'SYMPTOM VAULT';

  @override
  String get symptomsVaultPlaceholder => '+ Add symptom to vault...';

  @override
  String symptomsModalLogHeader(String zone) {
    return 'LOG IN: $zone';
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
      'This log has no rating. Tap a point to assign one.';

  @override
  String get symptomsActionSaveChanges => 'SAVE CHANGES';

  @override
  String get symptomsActionSave => 'SAVE';

  @override
  String get zoneCervical => 'Cervical';

  @override
  String get zoneHombros => 'Shoulders';

  @override
  String get zoneMunecas => 'Wrists';

  @override
  String get zoneManos => 'Hands';

  @override
  String get zoneLumbarPelvis => 'Lumbar/Pelvis';

  @override
  String get zoneCaderas => 'Hips';

  @override
  String get zoneRodillas => 'Knuckles/Knees';

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
  String get bowelLabelIncomplete => 'incomplete';

  @override
  String get movementSectionPacingActive =>
      'Today is a rest day. Resting counts too.';

  @override
  String get movementSectionHistoryTitle => 'TODAY YOU DID...';

  @override
  String get movementFootnoteLongPressEdit => 'Long press a log to edit.';

  @override
  String get movementEmptyStateHeadline =>
      'Movement and recovery are the same thing.';

  @override
  String get movementEmptyStateSubtitle =>
      'Walking, stretching, a physio session, a massage — it all counts as body care.';

  @override
  String get movementSectionActivityTitle => 'ACTIVITY';

  @override
  String get movementActivityPlaceholder =>
      '+ Add activity (swimming, cycling, dancing...)';

  @override
  String get movementSectionTherapyTitle => 'THERAPY';

  @override
  String get movementTherapyPlaceholder =>
      '+ Add modality (reiki, flotation...)';

  @override
  String get movementRenameDialogTitle => 'Rename';

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
  String get activityFieldHhrHint => 'Optional heart rate (e.g., 70→110)';

  @override
  String activityLabelEffortSlider(int value) {
    return 'Effort: $value/10';
  }

  @override
  String activityLabelFeelingSlider(int value) {
    return 'How I felt: $value/5';
  }

  @override
  String get activityActionTogglePainRating =>
      'evaluate pain before/after (optional)';

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
    return 'You improved $count $_temp0';
  }

  @override
  String painDeltaLabelWorsened(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'levels',
      one: 'level',
    );
    return 'You worsened $count $_temp0';
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
    return '$detail · effort $effort/10 · feeling $feeling/5$painSuffix';
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
  String get feelingLabelLevel1 => '🤕 In pain / injured';

  @override
  String get feelingLabelLevel2 => '😟 Uncomfortable / worried';

  @override
  String get feelingLabelLevel3 => '😐 Neutral';

  @override
  String get feelingLabelLevel4 => '😊 Relaxed';

  @override
  String get feelingLabelLevel5 => '💪 Strong and secure';

  @override
  String get onboardingHaveProfileTitle => 'I already have a saved profile';

  @override
  String get onboardingHaveProfileSubtitle => 'Import from a JSON file';

  @override
  String get onboardingImportChoiceTitle => 'How to import?';

  @override
  String get onboardingImportFromFile => 'From file';

  @override
  String get onboardingImportFromPaste => 'Paste text';

  @override
  String get feverSectionTitle => 'FEVER';

  @override
  String get feverActionAddReading => '+ measure temperature';

  @override
  String get feverModalLogHeader => 'LOG TEMPERATURE';

  @override
  String get feverModalEditHeader => 'EDIT READING';

  @override
  String get feverFieldSiteLabel => 'SITE';

  @override
  String get feverFieldAntipyreticLabel => 'ANTIPYRETIC';

  @override
  String get feverFieldAntipyreticToggle => 'I took something to lower it';

  @override
  String get feverFieldAntipyreticNameHint =>
      'name (paracetamol, ibuprofen...)';

  @override
  String get feverHintTapToEdit => 'tap the number to edit';

  @override
  String get feverDirectEditDialogTitle => 'Edit temperature';

  @override
  String get feverDirectEditDialogHint => 'e.g., 38.7';

  @override
  String get feverLogLabelWithAntipyretic => 'with antipyretic';

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

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String timeAgoHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String get researchEmptyConfig =>
      'Add a diagnosis in settings to see relevant research.';

  @override
  String get researchTitleRecent => 'Recent PubMed Results';

  @override
  String get researchDisclaimer =>
      'Swipe to refresh. For informational purposes only, not medical advice.';

  @override
  String get researchTooltipOffline => 'Saved results (offline)';

  @override
  String get researchStateNoData => 'No data. Pull down to search.';

  @override
  String get researchStateNoResults => 'No recent results found.';

  @override
  String researchLastUpdated(String time) {
    return 'Updated: $time';
  }

  @override
  String get researchActionSaved => 'Saved';

  @override
  String get researchActionSave => 'Save';

  @override
  String get researchActionOpenPubMed => 'Open in PubMed';

  @override
  String get researchActionCopyPmid => 'Copy PMID';

  @override
  String researchSnackPmidCopied(String pmid) {
    return 'PMID $pmid copied.';
  }

  @override
  String get researchLoadingAbstract => 'Loading abstract...';

  @override
  String get researchEmptyAbstract =>
      'Abstract not available. Open the article in PubMed for more details.';

  @override
  String get reportRangeDay => '1 day';

  @override
  String get reportRangeWeek => '7 days';

  @override
  String get reportRangeMonth => '30 days';

  @override
  String get reportRangeCustomTooltip => 'Custom range';

  @override
  String reportRangeCustomActiveLabel(String start, String end) {
    return 'Range: $start → $end';
  }

  @override
  String get structKindJoint => 'Joint';

  @override
  String get structKindMuscle => 'Muscle';

  @override
  String get structKindTendon => 'Tendon';

  @override
  String get structKindLigament => 'Ligament';

  @override
  String get structKindSoftTissue => 'Soft tissue';

  @override
  String get structKindNerve => 'Nerve';

  @override
  String get structKindPainWithoutClearCause =>
      'Pain without a clear structural cause';

  @override
  String get structTypeMuscleStrain => 'Muscle strain';

  @override
  String get structTypeMuscleDistension => 'Muscle distension';

  @override
  String get structTypeMuscleTear => 'Muscle tear';

  @override
  String get structTypeContracture => 'Contracture';

  @override
  String get structTypeMuscleSpasm => 'Muscle spasm';

  @override
  String get structTypeTendinitis => 'Tendinitis';

  @override
  String get structTypeTendinosis => 'Tendinosis';

  @override
  String get structTypeBursitis => 'Bursitis';

  @override
  String get structTypeEnthesitis => 'Enthesitis';

  @override
  String get structTypeTendonFissure => 'Tendon tear/fissure';

  @override
  String get structTypeMildSprain => 'Mild sprain';

  @override
  String get structTypeSevereSprain => 'Severe sprain';

  @override
  String get structTypeLigamentTear => 'Ligament tear';

  @override
  String get structTypeSuperficialCut => 'Superficial cut';

  @override
  String get structTypeSkinFissure => 'Skin fissure';

  @override
  String get structTypeDeepWound => 'Deep wound';

  @override
  String get structTypeHematoma => 'Hematoma';

  @override
  String get structTypeContusion => 'Contusion';

  @override
  String get structTypeBurn => 'Burn';

  @override
  String get structTypeAbrasion => 'Abrasion';

  @override
  String get structTypeParesthesia => 'Paresthesia';

  @override
  String get structTypeUnclearCause => 'Pain without a clear structural cause';

  @override
  String get structTypeKnownConditionFlare => 'Known condition flare-up';

  @override
  String get structTypeMuscleGeneral => 'Muscle pain';

  @override
  String get structTypeTendonGeneral => 'Tendon pain';

  @override
  String get structTypeLigamentGeneral => 'Ligament pain';

  @override
  String get structTypeSoftTissueGeneral => 'Soft tissue pain';

  @override
  String get structTypeNerveGeneral => 'Nerve pain';

  @override
  String get structuralZonePickTitle => 'Which area?';

  @override
  String get structuralZonePickSubtitle =>
      'Tap the area where you feel the pain.';

  @override
  String get structuralKindPickTitle => 'What kind of pain is it?';

  @override
  String get structuralKindPickSubtitle =>
      'Pick whichever is closest. If you\'re not sure, you can pick \"no clear cause\".';

  @override
  String get structuralSheetTitle => 'Pain detail';

  @override
  String get structuralSheetSubtitle =>
      'Tell us more about this pain, in your own words.';

  @override
  String get structuralContextZoneLabel => 'Context area (optional)';

  @override
  String get structuralContextZoneHint =>
      'E.g.: the whole right side, not just this area';

  @override
  String get structuralKnownTermShortcut => 'I already know what this is';

  @override
  String structuralCheckInTitle(String zone) {
    return 'How\'s it doing: $zone?';
  }

  @override
  String structuralCheckInSubtitle(String since) {
    return 'Logged since $since. Update the status without adding a new entry.';
  }

  @override
  String get structuralCheckInSame => 'Still the same';

  @override
  String get structuralCheckInBetter => 'Better, but still hurts';

  @override
  String get structuralCheckInWorse => 'Got worse';

  @override
  String get structuralCheckInResolved => 'It\'s resolved';

  @override
  String structuralOngoingSinceTag(String date) {
    return 'ongoing since $date';
  }

  @override
  String get structuralBleedingSheetTitle => 'Bleeding or bruise detail';

  @override
  String get structuralBleedingSheetSubtitle =>
      'Tell us the origin and how severe it was.';

  @override
  String get structuralBleedingLogTitle => 'How was it this time?';

  @override
  String get structuralBleedingLogSubtitle =>
      'Origin and severity of this episode.';

  @override
  String get structuralQuickLogTitle => 'How intense is it today?';

  @override
  String get structuralQuickLogSubtitle =>
      'You already have a saved history for this zone.';

  @override
  String get structuralQuickLogNewIssueLink =>
      'Is this a new or different problem? Describe it separately';

  @override
  String get structuralComparedToUsualWorse => 'Worse than usual';

  @override
  String get structuralComparedToUsualNormal => 'Normal for me';

  @override
  String get structuralComparedToUsualBetter => 'Better than usual';

  @override
  String get structuralZoneHistoryFormTitle => 'Record zone history';

  @override
  String get structuralZoneHistoryFormEditTitle => 'Edit zone history';

  @override
  String get structuralZoneHistoryZoneLabel => 'Zone';

  @override
  String get structuralZoneHistoryKindLabel => 'Category';

  @override
  String get structuralZoneHistoryDescriptionHint =>
      'Description (e.g. post-surgical, 2 surgeries)';

  @override
  String get structuralZoneHistoryDateLabel => 'Approximate date (optional)';

  @override
  String get structuralZoneHistorySaveAction => 'Save history';

  @override
  String get structuralZoneHistoryOfferTitle =>
      'Save this as something you already know?';

  @override
  String get structuralZoneHistoryOfferBody =>
      'Next time you log pain in this zone, you can skip straight to severity.';

  @override
  String get structuralZoneHistoryOfferAccept => 'Save';

  @override
  String get structuralZoneHistoryOfferDecline => 'Not now';

  @override
  String get structuralZoneHistorySectionTitle => 'Structural history by zone';

  @override
  String get structuralZoneHistoryAddAction => 'Add history';

  @override
  String get structuralZoneHistoryEmptyState => 'No saved history yet.';

  @override
  String get sleepSectionTitle => 'SLEEP';

  @override
  String get sleepActionAddEntry => '+ log sleep';

  @override
  String get sleepModalLogHeader => 'LOG SLEEP';

  @override
  String get sleepModalEditHeader => 'EDIT SLEEP';

  @override
  String get sleepFieldQualityLabel => 'QUALITY';

  @override
  String get sleepFieldBedWakeLabel => 'FROM WHEN TO WHEN? (OPTIONAL)';

  @override
  String get sleepFieldBedTimeButton => 'Bedtime';

  @override
  String get sleepFieldWakeTimeButton => 'Wake time';

  @override
  String get sleepFieldDurationLabel => 'DURATION';

  @override
  String get sleepFieldDurationHint => 'hours (e.g., 7.5)';

  @override
  String get sleepFieldDurationHoursLabel => 'Hours';

  @override
  String get sleepFieldDurationMinutesLabel => 'Minutes';

  @override
  String get sleepFieldOnsetLatencyLabel => 'TIME TO FALL ASLEEP';

  @override
  String get sleepFieldOnsetLatencyHint => 'minutes';

  @override
  String get sleepFieldWakeCountLabel => 'AWAKENINGS';

  @override
  String get sleepFieldNightmareToggle => 'had nightmare(s)';

  @override
  String get sleepLogLabelSlept => 'slept';

  @override
  String sleepLogLabelHours(String hours) {
    return '${hours}h';
  }

  @override
  String sleepLogLabelWakes(int count) {
    return '$count× awakenings';
  }

  @override
  String sleepLogLabelOnsetLatency(int minutes) {
    return '$minutes min to fall asleep';
  }

  @override
  String get sleepLogLabelWithNightmare => 'nightmare';

  @override
  String get settingsOptionalModulesTitle => 'OPTIONAL MODULES';

  @override
  String get settingsOptionalModulesBlurb =>
      'Activate only what you want to track. Disabled modules will not appear in Symptoms.';

  @override
  String get settingsModuleSleepLabel => 'Sleep';

  @override
  String get settingsModuleSleepDescription =>
      'Quality, duration, and awakenings per night.';

  @override
  String get bodyRegionHeadNeck => 'Head and neck';

  @override
  String get bodyRegionShouldersUpperBack => 'Shoulders and upper back';

  @override
  String get bodyRegionArms => 'Arms';

  @override
  String get bodyRegionChestAbdomen => 'Chest and abdomen';

  @override
  String get bodyRegionLowerBackPelvis => 'Lower back and pelvis';

  @override
  String get bodyRegionLegs => 'Legs';

  @override
  String get zoneJaw => 'Jaw';

  @override
  String get zoneTemple => 'Temple';

  @override
  String get zoneShoulderBlades => 'Shoulder blades';

  @override
  String get zoneUpperBack => 'Upper back';

  @override
  String get zoneUpperArm => 'Upper arm';

  @override
  String get zoneElbow => 'Elbow';

  @override
  String get zoneForearm => 'Forearm';

  @override
  String get zoneChest => 'Chest';

  @override
  String get zoneSide => 'Flank / Side';

  @override
  String get zoneRibs => 'Ribs';

  @override
  String get zoneAbdomen => 'Abdomen';

  @override
  String get zoneGlutes => 'Glutes';

  @override
  String get zoneFrontThigh => 'Front thigh';

  @override
  String get zoneBackThigh => 'Back thigh';

  @override
  String get zoneCalf => 'Calf';

  @override
  String get zoneFeet => 'Feet';

  @override
  String get hydrationSectionTitle => 'HYDRATION';

  @override
  String get hydrationActionAddEntry => '+ log hydration';

  @override
  String get hydrationModalLogHeader => 'LOG HYDRATION';

  @override
  String get hydrationModalEditHeader => 'EDIT HYDRATION';

  @override
  String get hydrationFieldVolumeLabel => 'AMOUNT';

  @override
  String get hydrationFieldVolumeHint => 'ml (e.g., 250)';

  @override
  String get hydrationFieldBeverageLabel => 'BEVERAGE';

  @override
  String get hydrationBeverageAddCustomHint => '+ Add beverage (tea, juice...)';

  @override
  String get hydrationFieldSodiumLabel => 'SODIUM (optional)';

  @override
  String hydrationLogLabelVolume(String volume) {
    return '$volume ml';
  }

  @override
  String get hrvSectionTitle => 'HRV';

  @override
  String get hrvActionAddEntry => '+ log HRV';

  @override
  String get hrvModalLogHeader => 'LOG HRV READING';

  @override
  String get hrvModalEditHeader => 'EDIT HRV READING';

  @override
  String get hrvFieldRmssdLabel => 'RMSSD';

  @override
  String get hrvFieldContextLabel => 'CONTEXT';

  @override
  String get hrvFieldSourceLabel => 'SOURCE';

  @override
  String get hrvHintTapToEdit => 'tap the number to edit';

  @override
  String get hrvDirectEditDialogTitle => 'Edit RMSSD';

  @override
  String get hrvDirectEditDialogHint => 'e.g., 35';

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
  String get hrvSourceOther => 'other';

  @override
  String get settingsModuleHydrationLabel => 'Hydration';

  @override
  String get settingsModuleHydrationDescription =>
      'Volume, beverage type, and sodium intake.';

  @override
  String get settingsModuleHrvLabel => 'HRV';

  @override
  String get settingsModuleHrvDescription =>
      'Heart rate variability by context and source.';

  @override
  String get sectionHintNoActivity => 'no logs yet';

  @override
  String get sectionHintToday => 'last logged today';

  @override
  String get sectionHintYesterday => 'last logged yesterday';

  @override
  String sectionHintDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return 'last logged $_temp0';
  }

  @override
  String get settingsViewPreferencesTitle => 'DISPLAY PREFERENCES';

  @override
  String get settingsSimpleModeLabel => 'Simple mode';

  @override
  String get settingsSimpleModeDescription =>
      'Bigger text, bigger buttons, and sections that start collapsed. For profiles that prefer an easier-to-read screen.';

  @override
  String get settingsCarefulModeLabel => 'Careful mode';

  @override
  String get settingsCarefulModeDescription =>
      'Reduces visual noise: sections start collapsed. Tap the header to expand what you want to see.';

  @override
  String get drugKindMedication => 'Medication';

  @override
  String get drugKindSupplement => 'Supplement';

  @override
  String get drugKindHerbal => 'Herbal Product';

  @override
  String get drugInteractionsInBotiquinHeader =>
      'Interactions in your medicine cabinet';

  @override
  String get drugInteractionSeverityHigh => 'High';

  @override
  String get drugInteractionSeverityMedium => 'Medium';

  @override
  String get drugInteractionSeverityLow => 'Low';

  @override
  String get drugNoContentSupplement =>
      'Supplement — not regulated as a medication. Consult with your healthcare team before combining it with other treatments.';

  @override
  String get drugNoContentHerbal =>
      'Herbal product — limited clinical evidence. Consult with your healthcare team before combining it with other treatments.';

  @override
  String drugNoContentMedlineEmpty(String rxcui) {
    return 'MedlinePlus did not return information for this medication (RxCUI $rxcui). It may be a temporary issue or the database may not have content for this code.';
  }

  @override
  String get drugNoContentUnmapped =>
      'We don\'t have detailed information for this product yet. You can search for it manually on medlineplus.gov.';

  @override
  String get drugNoContentGeneric => 'Information could not be loaded.';

  @override
  String get drugReadMoreMedlinePlus => 'Read more on MedlinePlus';

  @override
  String get drugBrowserOpenError =>
      'Could not open the browser. Check your connection.';

  @override
  String get drugConfidenceMediumWarning =>
      'Medium confidence mapping — verify with your healthcare team if the information does not match your medication.';

  @override
  String get drugSourceLocalCurated =>
      'Source: clinical information curated locally for this app. Does not replace medical advice.';

  @override
  String get drugSourceMedlinePlus =>
      'Source: MedlinePlus, U.S. National Library of Medicine. Does not replace medical advice.';

  @override
  String get drugSourceNoInfo =>
      'No clinical information available in our sources.';

  @override
  String get drugLoadError => 'Information could not be loaded.';

  @override
  String get conditionSourceLocalCurated =>
      'Source: local ZebraUp information about this condition. Does not replace medical advice.';

  @override
  String get conditionContentUnverifiedWarning =>
      'This summary was drafted from general medical knowledge, not a confirmed clinical review. If anything doesn\'t match what your healthcare team has told you, trust your healthcare team.';

  @override
  String get conditionNoContentUnmapped =>
      'We don\'t have this condition mapped yet. You can search for it manually on medlineplus.gov.';

  @override
  String get conditionNoContentNoIcd10 =>
      'This condition has no ICD-10 code, so we can\'t query MedlinePlus, and we don\'t have a local summary for it yet.';

  @override
  String get conditionNoContentMedlineEmpty =>
      'MedlinePlus didn\'t return information for this condition. This could be a temporary issue or a lack of content for this code.';

  @override
  String get moodQuadrantActivatedUnpleasant => 'activated · unpleasant';

  @override
  String get moodQuadrantActivatedPleasant => 'activated · pleasant';

  @override
  String get moodQuadrantCalmUnpleasant => 'calm · unpleasant';

  @override
  String get moodQuadrantCalmPleasant => 'calm · pleasant';

  @override
  String get moodTeaserActivatedUnpleasant => 'tension, anxiety';

  @override
  String get moodTeaserActivatedPleasant => 'energy, joy';

  @override
  String get moodTeaserCalmUnpleasant => 'exhaustion, sadness';

  @override
  String get moodTeaserCalmPleasant => 'tranquility, peace';

  @override
  String get moodSheetStep1Title => 'HOW DO YOU FEEL?';

  @override
  String get moodSheetCancel => 'cancel';

  @override
  String get moodSheetStep2Prompt => 'how do I feel?';

  @override
  String get moodSheetChangeQuadrant => 'change quadrant';

  @override
  String get moodSheetAlsoFeelingHeader => 'I ALSO FEEL…';

  @override
  String get moodSheetNotesHeader => 'CONTEXT (OPTIONAL)';

  @override
  String get moodSheetNotesPlaceholder => 'e.g. A day with a lot of brain fog…';

  @override
  String get moodSheetSaveButton => 'SAVE RECORD';

  @override
  String get moodDefinitionDialogAction => 'Got it';

  @override
  String get moodSectionTitle => 'HOW I\'M DOING';

  @override
  String get moodSectionPrompt => 'How do you feel?';

  @override
  String get moodSectionRegisterAnother => 'Log another state';

  @override
  String get severityFunctionalAnchorNone => 'I don\'t notice it';

  @override
  String get severityFunctionalAnchorMild =>
      'I notice it, but it doesn\'t stop me';

  @override
  String get severityFunctionalAnchorModerate => 'makes me slow down or pause';

  @override
  String get severityFunctionalAnchorIntense =>
      'I can\'t do what I had planned';

  @override
  String get severityFunctionalAnchorUnbearable =>
      'I can\'t function; I need to stop';

  @override
  String get outcomeReasonNatural => 'Natural change in the symptom';

  @override
  String get outcomeReasonMedicationHelped => 'I think this medication helped';

  @override
  String get outcomeReasonOtherTrigger =>
      'Other trigger (food, stress, weather...)';

  @override
  String get outcomeReasonAdditionalMed => 'I also took another medication';

  @override
  String get outcomeReasonUnsure => 'I\'m not sure';

  @override
  String get medicationOutcomeCoarsePending => 'Pending';

  @override
  String get medicationOutcomeCoarseMuchBetter => 'Much better';

  @override
  String get medicationOutcomeCoarseBetter => 'Better';

  @override
  String get medicationOutcomeCoarseSame => 'Same';

  @override
  String get medicationOutcomeCoarseWorse => 'Worse';

  @override
  String get medicationOutcomeCoarseMuchWorse => 'Much worse';

  @override
  String get bowelFormTitleNew => 'LOG BOWEL MOVEMENT';

  @override
  String get bowelFormTitleEdit => 'EDIT BOWEL MOVEMENT';

  @override
  String get bowelFormBristolLabel => 'Bristol type';

  @override
  String bowelFormBristolLegendTemplate(
    String constipation,
    String normal,
    String diarrhea,
  ) {
    return '1-2: $constipation  ·  3-5: $normal  ·  6-7: $diarrhea';
  }

  @override
  String get bowelFormHideBristolDetail => 'hide detail';

  @override
  String get bowelFormShowBristolDetail => 'more detail (Bristol scale)';

  @override
  String get bowelFormSectionObservations => 'OBSERVATIONS';

  @override
  String get bowelFormToggleUrgency => 'urgency';

  @override
  String get bowelFormToggleIncompleteEvacuation => 'incomplete evacuation';

  @override
  String get bowelFormNoteHint => 'Optional note (context, trigger, etc.)';

  @override
  String get hemorrhoidalFormTitleNew => 'LOG HEMORRHOID';

  @override
  String get hemorrhoidalFormTitleEdit => 'EDIT HEMORRHOID';

  @override
  String get hemorrhoidalFormNoteHint => 'Optional note';

  @override
  String get formSectionHeaderDiscomfort => 'DISCOMFORT';

  @override
  String get formToggleBleeding => 'bleeding';

  @override
  String get formButtonSave => 'SAVE';

  @override
  String get structuralFormFollowupHeader => 'FOLLOW-UP';

  @override
  String get structuralFormFollowupResolvedQuestion => 'Is it resolved?';

  @override
  String structuralFormFollowupResolvedDateTemplate(String date) {
    return 'Resolved on $date';
  }

  @override
  String get structuralFormFollowupStillPainfulQuestion => 'Still painful?';

  @override
  String get structuralFormFollowupStillPainfulSubtitle =>
      'Visibly closed but pain remains';

  @override
  String bowelLogBristolTypeTemplate(int type) {
    return 'type $type';
  }

  @override
  String get bowelLogTagUrgency => 'urgency';

  @override
  String get bowelLogTagBleeding => 'bleeding';

  @override
  String get bowelLogTagIncomplete => 'incomplete';

  @override
  String get hemorrhoidalLogLabel => 'hemorrhoid';

  @override
  String get hemorrhoidalLogTagBleeding => 'bleeding';

  @override
  String get symptomLogTagUnrated => 'unrated';

  @override
  String get hoySectionPendingHeader => 'Pending';

  @override
  String get hoyOutcomeForYour => ' for your ';

  @override
  String get hoyOutcomeHideReasons => 'Hide';

  @override
  String get hoyBowelCounterToday => 'last bowel movement: today';

  @override
  String get hoyBowelCounterYesterday => 'last bowel movement: yesterday';

  @override
  String hoyBowelCounterDaysAgoTemplate(int days) {
    return 'last bowel movement: $days days ago';
  }

  @override
  String get hoyNarrativeEmptyPacing =>
      '🛡️ Rest day. You haven\'t logged anything yet — that\'s ok.';

  @override
  String get hoyNarrativeEmpty =>
      'You haven\'t logged anything today. How\'s it going?';

  @override
  String hoyNarrativeSymptomsSingleTemplate(String name, String severity) {
    return 'Logged 1 symptom: $name ($severity).';
  }

  @override
  String hoyNarrativeSymptomsManyTemplate(
    int count,
    String name,
    String severity,
  ) {
    return 'Logged $count symptoms — the strongest was $name ($severity).';
  }

  @override
  String hoyNarrativeStructuralSingleTemplate(String zone) {
    return 'You had 1 structural event in $zone.';
  }

  @override
  String hoyNarrativeStructuralManyTemplate(int count) {
    return 'You had $count structural events today.';
  }

  @override
  String hoyNarrativeDosesSingleTemplate(String meds) {
    return 'Took 1 dose: $meds.';
  }

  @override
  String hoyNarrativeDosesManyTemplate(int count, String meds) {
    return 'Took $count doses: $meds.';
  }

  @override
  String hoyNarrativeDosesAndMore(int count) {
    return ' and $count more';
  }

  @override
  String hoyNarrativeEmaStatesTemplate(String states) {
    return 'Your logged states and sensations: $states.';
  }

  @override
  String get hoyNarrativeEmaStatesEllipsis => '...';

  @override
  String get hoyNarrativePacingTrailer =>
      '🛡️ You gave yourself permission to rest. That counts.';

  @override
  String get hoyHeaderDatePattern => 'EEEE, MMMM d';

  @override
  String movementModalTitleRegisterTemplate(String name) {
    return 'LOG: $name';
  }

  @override
  String movementModalTitleEditTemplate(String name) {
    return 'EDIT: $name';
  }

  @override
  String get movementModalHintDuration => 'Duration (min)';

  @override
  String get movementModalHintSets => 'Sets';

  @override
  String get movementModalHintReps => 'Reps';

  @override
  String get movementModalHintHeartRate => 'Optional heart rate (ej. 70→110)';

  @override
  String movementModalEffortLabelTemplate(int value) {
    return 'Effort: $value/10';
  }

  @override
  String movementModalFeelingLabelTemplate(int value) {
    return 'How I felt: $value/5';
  }

  @override
  String get movementFeelingPainOrInjury => '🤕 In pain / injured';

  @override
  String get movementFeelingUncomfortable => '😟 Uncomfortable / worried';

  @override
  String get movementFeelingNeutral => '😐 Neutral';

  @override
  String get movementFeelingRelaxed => '😊 Relaxed';

  @override
  String get movementFeelingStrongConfident => '💪 Strong and confident';

  @override
  String get movementPainLevelNone => 'none';

  @override
  String get movementPainLevelMild => 'mild';

  @override
  String get movementPainLevelModerate => 'moderate';

  @override
  String get movementPainLevelIntense => 'intense';

  @override
  String get movementPainLevelSevere => 'severe';

  @override
  String movementPainDeltaImprovedTemplate(int delta) {
    String _temp0 = intl.Intl.pluralLogic(
      delta,
      locale: localeName,
      other: '$delta levels',
      one: '1 level',
    );
    return 'Improved $_temp0';
  }

  @override
  String movementPainDeltaWorseTemplate(int delta) {
    String _temp0 = intl.Intl.pluralLogic(
      delta,
      locale: localeName,
      other: '$delta levels',
      one: '1 level',
    );
    return 'Worsened $_temp0';
  }

  @override
  String get movementPainDeltaUnchanged => 'No change';

  @override
  String movementLogEntryEffortTemplate(int value) {
    return 'effort $value/10';
  }

  @override
  String movementLogEntryFeelingTemplate(int value) {
    return 'feeling $value/5';
  }

  @override
  String movementLogEntryDeltaImprovedTemplate(int delta) {
    return '↓$delta lvl';
  }

  @override
  String movementLogEntryDeltaWorseTemplate(int delta) {
    return '↑$delta lvl';
  }

  @override
  String get movementLogEntryDeltaUnchanged => 'no change';

  @override
  String get movementLogEntryTherapyDeltaSteady => '=';

  @override
  String get appBarTooltipFontSize => 'Text size';

  @override
  String get appBarTooltipDarkMode => 'Dark mode';

  @override
  String get appBarTooltipLightMode => 'Light mode';

  @override
  String get appBarTooltipSettings => 'Settings';

  @override
  String get actionDelete => 'Delete';

  @override
  String get settingsProfileConfigTitle => 'PROFILE CONFIGURATION';

  @override
  String get settingsMyDataTitle => 'MY DATA';

  @override
  String get settingsPatientNameLabel => 'PATIENT NAME';

  @override
  String get settingsPatientNameHelper =>
      'Full legal name. Used in the PDF for the specialist.';

  @override
  String get settingsPreferredNameLabel => 'PREFERRED NAME (OPTIONAL)';

  @override
  String get settingsPreferredNameHelper =>
      'How you want the app to show your name. If left empty, the patient name is used.';

  @override
  String get settingsConditionsLabel => 'COMORBIDITIES / DIAGNOSES';

  @override
  String get settingsRelationshipLabel => 'RELATIONSHIP TO THIS PROFILE';

  @override
  String get settingsLifeEventsLabel => 'LIFE EVENTS';

  @override
  String get settingsLocationLabel => 'MY LOCATION (FOR WEATHER)';

  @override
  String get settingsConditionsHelper =>
      'Tap the × to remove a condition. To read about them, go to Clinical → Compendium.';

  @override
  String get settingsRelationshipHelper =>
      'Who is this profile for? Useful if you\'re logging for someone you care for.';

  @override
  String get settingsLifeEventsHelper =>
      'Things that may have affected your body or mood: travel, accidents, moves, good or stressful events. They appear as purple dots in the calendar.';

  @override
  String get settingsDataHelper =>
      'You have the right to access, export, import, or delete your data at any time.';

  @override
  String get settingsWipeAllHelper =>
      'This action deletes all profiles, records, and settings. Irreversible.';

  @override
  String get settingsRelationshipSelf => 'Me';

  @override
  String get settingsRelationshipChild => 'My child';

  @override
  String get settingsRelationshipPartner => 'My partner';

  @override
  String get settingsRelationshipParent => 'My parent';

  @override
  String get settingsRelationshipOther => 'Other';

  @override
  String get settingsRelationshipNone => '— unspecified —';

  @override
  String get settingsLifeEventsEmpty => 'No events logged yet.';

  @override
  String get settingsAddEventButton => 'ADD EVENT';

  @override
  String get settingsLocationNone => 'No location. Tap to add.';

  @override
  String get settingsLocationButtonAdd => 'ADD COORDINATES';

  @override
  String get settingsLocationButtonEdit => 'EDIT COORDINATES';

  @override
  String get settingsAddProfileButton => 'ADD NEW PROFILE';

  @override
  String get settingsDeleteProfileButton => 'DELETE THIS PROFILE';

  @override
  String get settingsExportDataButton => 'EXPORT MY DATA';

  @override
  String get settingsWipeAllButton => 'DELETE EVERYTHING';

  @override
  String settingsNewProfileNameTemplate(int number) {
    return 'NEW PROFILE $number';
  }

  @override
  String get dialogWipeTitle => 'Delete all data';

  @override
  String get dialogWipeContent =>
      'This action erases ALL profiles, records, settings, and cache. It cannot be undone.\n\nWant to export first?';

  @override
  String get dialogWipeFinalTitle => 'Final confirmation';

  @override
  String dialogWipeFinalContentTemplate(String magicWord) {
    return 'To confirm, type $magicWord below.';
  }

  @override
  String get dialogWipeFinalMagicWord => 'DELETE';

  @override
  String get dialogWipeFinalButton => 'Delete everything';

  @override
  String get dialogDeleteProfileTitle => 'Delete profile';

  @override
  String dialogDeleteProfileContentTemplate(String name) {
    return 'Delete the profile \"$name\" and all its data? This action cannot be undone.';
  }

  @override
  String get dialogLocationTitle => 'Your location';

  @override
  String get dialogLocationContent =>
      'I need latitude and longitude to fetch the weather. Find your city in Google Maps, right-click → copy coordinates.';

  @override
  String get dialogLocationHintLat => 'Latitude (e.g. -34.61)';

  @override
  String get dialogLocationHintLng => 'Longitude (e.g. -58.38)';

  @override
  String get dialogLocationInvalidSnack => 'Invalid coordinates.';

  @override
  String get therapyHintArea => 'Area (e.g. cervical)';

  @override
  String get therapySectionPainBefore => 'PAIN BEFORE';

  @override
  String get therapySectionPainAfter => 'PAIN AFTER';

  @override
  String get therapyActionMoreDetails => 'more details (therapist, cost, note)';

  @override
  String get therapyHintTherapist => 'Therapist / place (optional)';

  @override
  String get therapyHintCost => 'Cost (optional)';

  @override
  String get therapyHintNote => 'Note (optional)';

  @override
  String get therapyActionSaveChanges => 'SAVE CHANGES';

  @override
  String get therapyActionLog => 'LOG';

  @override
  String get compendiumSectionConditionsHeader => 'MY CONDITION';

  @override
  String get compendiumSectionConditionsSubtitle =>
      'Tap one to read clinical information (source: MedlinePlus).';

  @override
  String compendiumSavedArticlesTemplate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved articles',
      one: '1 saved article',
    );
    return '$_temp0 — go to Research.';
  }

  @override
  String get compendiumSectionDataTitle => 'CLINICAL FACTS';

  @override
  String get compendiumFactSourceLabel => 'Source:';

  @override
  String investigationConditionArticleCountTemplate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get headacheSheetTitle => 'Headache detail';

  @override
  String get headacheSheetSubtitle =>
      'Mark what applies. You can skip this step if you prefer.';

  @override
  String get actionSkip => 'Skip';

  @override
  String get headacheActionSaveDetail => 'Save detail';

  @override
  String get headacheThunderclapWarningTitle => 'Possible emergency';

  @override
  String get headacheThunderclapWarningConfirm => 'I understand, continue';

  @override
  String get headacheAdvisoryDialogTitle => 'Patterns to consider';

  @override
  String get headacheRedFlagCsfLeakAdvisory =>
      'Your headache worsens noticeably when standing upright. This pattern can suggest a cerebrospinal fluid leak, particularly common in people with EDS. If it recurs, consider mentioning it to your doctor.';

  @override
  String get headacheRedFlagIntracranialAdvisory =>
      'Your headache worsens when lying down. This pattern can suggest increased intracranial pressure. If it recurs or is accompanied by vision changes, consider medical evaluation.';

  @override
  String get settingsModuleHeadacheDetailLabel => 'Headache detail';

  @override
  String get settingsModuleHeadacheDetailDescription =>
      'Capture location, quality, and other patterns when logging a headache.';

  @override
  String get fatigueSheetTitle => 'Fatigue detail';

  @override
  String get fatigueSheetSubtitle => 'Optional details help identify patterns.';

  @override
  String get fatigueActionSaveDetail => 'Save detail';

  @override
  String get fatigueAdvisoryDialogTitle => 'Detected patterns';

  @override
  String get fatigueRedFlagPemAdvisory =>
      'This pattern shows your fatigue appears 1-3 days after exertion. It may indicate your body has fewer energy reserves than usual and needs more days to recover. If it recurs, consider mentioning it to your doctor.';

  @override
  String get fatigueRedFlagOrthostaticAdvisory =>
      'Your fatigue worsens when standing or sitting upright. It may indicate your body has difficulty maintaining stable blood pressure or pulse when upright. It is common in people with EDS. It is worth mentioning to your doctor.';

  @override
  String get fatigueRedFlagHpaAdvisory =>
      'Your body feels exhausted but cannot rest. This may indicate your stress system has been activated for a long time and the hormones that regulate rest are out of balance. It is worth mentioning to your doctor.';

  @override
  String get settingsModuleFatigueDetailLabel => 'Fatigue detail';

  @override
  String get settingsModuleFatigueDetailDescription =>
      'When logging fatigue, add type, temporal pattern, and accompaniments.';

  @override
  String get abdominalSheetTitle => 'Abdominal detail';

  @override
  String get abdominalSheetSubtitle =>
      'Optional details help identify patterns.';

  @override
  String get abdominalActionSaveDetail => 'Save detail';

  @override
  String get abdominalTearingEmergencyTitle => 'Tearing-type pain';

  @override
  String get abdominalTearingEmergencyBody =>
      'Sudden, very severe tearing pain may indicate a medical emergency in people with Ehlers-Danlos syndrome. It is worth going to the emergency room now to rule out arterial or intestinal rupture.\n\nIf you go, inform the medical team of your clEDS diagnosis (classical-like Ehlers-Danlos syndrome, due to TNXB mutation).\n\nIf the pain improved significantly and you would no longer describe it as tearing, you can change the pain quality and save the record normally.';

  @override
  String get abdominalTearingEmergencyChangeQuality =>
      'Change quality and save';

  @override
  String get abdominalTearingEmergencySaveAsIs => 'Save as is (emergency)';

  @override
  String get abdominalAdvisoryDialogTitle => 'Detected patterns';

  @override
  String get abdominalRedFlagMassiveHematocheziaUrgent =>
      'This pattern (blood in stool together with nausea or vomiting and intense pain) may indicate active GI bleeding. If the bleeding is abundant or you notice significant weakness or dizziness, go to the emergency room now.';

  @override
  String get abdominalRedFlagHematemesisUrgent =>
      'In your note you mentioned vomiting blood. This symptom indicates upper GI bleeding and requires immediate emergency evaluation.';

  @override
  String get abdominalRedFlagNocturnalPainAdvisory =>
      'Your pain woke you up at night. This pattern is an alarm sign worth mentioning to your doctor, especially if you notice involuntary weight loss or fever.';

  @override
  String get abdominalRedFlagGastroparesisAdvisory =>
      'Your pain appears right when eating and you feel full quickly. This pattern may indicate your stomach empties more slowly than normal. It is common in people with EDS and dysautonomia. Worth mentioning to your doctor.';

  @override
  String get settingsModuleAbdominalDetailLabel => 'Abdominal detail';

  @override
  String get settingsModuleAbdominalDetailDescription =>
      'When logging pain, bloating, or gas, add location, quality, timing, and accompaniments.';

  @override
  String get bowelToAbdominalPromptTitle => 'Record pain detail?';

  @override
  String get bowelToAbdominalPromptBody =>
      'You marked this event as accompanied by abdominal pain. Record the detail now to help identify patterns?';

  @override
  String get abdominalToBowelPromptTitle => 'Linked to a bowel movement?';

  @override
  String abdominalToBowelPromptBody(String time) {
    return 'You marked this pain as related to a bowel movement. You logged a bowel movement at $time. Is it the same one?';
  }

  @override
  String get abdominalIntegrationYes => 'Yes';

  @override
  String get abdominalIntegrationNo => 'No';

  @override
  String get abdominalIntegrationDontKnow => 'I don\'t know';

  @override
  String get presyncopeSheetTitle => 'Presyncope detail';

  @override
  String get presyncopeSheetSubtitle =>
      'Optional details help identify patterns.';

  @override
  String get presyncopeActionSaveDetail => 'Save detail';

  @override
  String get presyncopeLossOfConsciousnessDialogTitle =>
      'Loss of consciousness';

  @override
  String get presyncopeLossOfConsciousnessDialogConfirm =>
      'I understand, continue';

  @override
  String get presyncopeAdvisoryDialogTitle => 'Patterns detected';

  @override
  String get presyncopeRedFlagExertionalTriggerAdvisory =>
      'Your episode appeared after physical exertion, not at rest. Worth mentioning to your doctor, especially if it repeats.';

  @override
  String get presyncopeRedFlagNoPositionChangeTriggerAdvisory =>
      'Your episode occurred without any change in position. This pattern is less typical of an orthostatic origin and may be worth discussing with your doctor.';

  @override
  String get settingsModulePresyncopeDetailLabel => 'Presyncope detail';

  @override
  String get settingsModulePresyncopeDetailDescription =>
      'When logging presyncope, add trigger, preceding symptoms, how it ended, and recovery.';

  @override
  String get pelvicPainSheetTitle => 'Pelvic pain detail';

  @override
  String get pelvicPainSheetSubtitle =>
      'Optional details help identify patterns.';

  @override
  String get pelvicPainActionSaveDetail => 'Save detail';

  @override
  String get pelvicPainSuddenOnsetEmergencyTitle => 'Sudden onset pain';

  @override
  String get pelvicPainSuddenOnsetEmergencyBody =>
      'Pelvic pain that starts suddenly and very intensely, different from what you usually have, can indicate a medical emergency such as ovarian torsion or a ruptured ectopic pregnancy. It\'s worth going to urgent care now to rule this out.\n\nIf you go, let the medical team know about your clEDS diagnosis (classical-like Ehlers-Danlos syndrome, TNXB-related).\n\nIf the pain improved significantly and you would no longer describe it as sudden and very intense, you can change the character and save the entry normally.';

  @override
  String get pelvicPainSuddenOnsetEmergencyChangeCharacter =>
      'Change character and save';

  @override
  String get pelvicPainSuddenOnsetEmergencySaveAsIs => 'Save as-is (emergency)';

  @override
  String get pelvicPainUrgentDialogTitle => 'Medical alert';

  @override
  String get pelvicPainRedFlagAbnormalBleedingUrgent =>
      'This bleeding, together with intense pain, can indicate a complication that needs prompt evaluation. If the bleeding is heavy or you notice a lot of weakness or dizziness, go to urgent care now.';

  @override
  String get pelvicPainRedFlagFeverUrgent =>
      'You logged a fever together with this pelvic pain. This combination can indicate a pelvic infection that needs prompt medical evaluation. Go to urgent care or your health center as soon as possible.';

  @override
  String get pelvicPainAdvisoryDialogTitle => 'Patterns detected';

  @override
  String get pelvicPainRedFlagBladderPatternAdvisory =>
      'Your pain is related to a full bladder or urinating. This pattern can indicate a condition known as painful bladder syndrome. Worth mentioning to your doctor.';

  @override
  String get pelvicPainRedFlagPelvicFloorTensionAdvisory =>
      'You noted muscle tension or spasm in the pelvic area. This pattern is recognized in people with hypermobility and may benefit from pelvic floor physical therapy. Worth mentioning to your doctor.';

  @override
  String get settingsModulePelvicPainDetailLabel => 'Pelvic pain detail';

  @override
  String get settingsModulePelvicPainDetailDescription =>
      'When logging pelvic pain, add location, character, relation to your cycle, context, and accompanying symptoms.';

  @override
  String get chestPainSheetTitle => 'Chest pain detail';

  @override
  String get chestPainSheetSubtitle =>
      'Optional details help identify patterns.';

  @override
  String get chestPainActionSaveDetail => 'Save detail';

  @override
  String get chestPainTearingEmergencyTitle => 'Tearing pain';

  @override
  String get chestPainTearingEmergencyBodyGeneral =>
      'Sudden, very intense tearing chest pain can indicate a medical emergency. It\'s worth going to urgent care now to rule it out, especially to evaluate cardiac or vascular causes.\n\nIf you go, let the medical team know about your clEDS diagnosis (classical-like Ehlers-Danlos syndrome, TNXB-related) or whichever EDS subtype you have.\n\nIf the pain improved significantly and you would no longer describe it as tearing, you can change the character and save the entry normally.';

  @override
  String get chestPainTearingEmergencyBodyVEDS =>
      'Sudden, very intense tearing chest pain can indicate an arterial dissection or rupture — a real emergency given your vascular EDS (vEDS) diagnosis. Go to urgent care now.\n\nLet the medical team know about your vEDS diagnosis immediately. If possible, ask them to avoid chest compressions given arterial and organ fragility. Imaging studies (MRI or CT) are crucial to rapidly identify a possible arterial rupture.\n\nIf the pain improved significantly and you would no longer describe it as tearing, you can change the character and save the entry normally.';

  @override
  String get chestPainTearingEmergencyChangeCharacter =>
      'Change character and save';

  @override
  String get chestPainTearingEmergencySaveAsIs => 'Save as-is (emergency)';

  @override
  String get chestPainUrgentDialogTitle => 'Medical alert';

  @override
  String get chestPainRedFlagCardiacPatternUrgent =>
      'This pattern (pressure or tightness in the chest along with shortness of breath, sweating, or pain radiating to your arm, jaw, or back) can indicate a cardiac cause. Go to urgent care now to rule it out.';

  @override
  String get chestPainRedFlagExertionalPatternUrgent =>
      'Your pain appeared with physical exertion along with shortness of breath or palpitations. This pattern can indicate a cardiac cause worth evaluating soon — if the pain is intense or doesn\'t improve with rest, go to urgent care now.';

  @override
  String get chestPainAdvisoryDialogTitle => 'Patterns detected';

  @override
  String get chestPainRedFlagPleuriticPatternAdvisory =>
      'Your pain is sharp and worsens with deep breathing or movement. This pattern can indicate irritation of the membranes around the lung or heart. Worth mentioning to your doctor.';

  @override
  String get chestPainRedFlagPalpitationsPatternAdvisory =>
      'You noted palpitations or a racing heart along with the pain. Worth mentioning to your doctor, especially if it repeats.';

  @override
  String get chestPainRedFlagRefluxPatternAdvisory =>
      'Your pain is burning and appears after eating or when lying down. This pattern can indicate acid reflux. Worth mentioning to your doctor if it\'s frequent.';

  @override
  String get settingsModuleChestPainDetailLabel => 'Chest pain detail';

  @override
  String get settingsModuleChestPainDetailDescription =>
      'When logging chest pain, add location, character, what triggers it, and accompanying symptoms.';

  @override
  String get onboardingStepMedsUnitHint => '1';

  @override
  String get onboardingStepMedsStrengthHint => 'mg';

  @override
  String get settingsModuleWeightTrackingLabel => 'Weight log';

  @override
  String get settingsModuleWeightTrackingDescription =>
      'Log your weight with a clinical reason (GI flare, medication change, fluid retention, appetite). No charts or goals — this is for sharing with your specialist, not daily self-monitoring.';

  @override
  String get settingsHeightLabel => 'Height';

  @override
  String get settingsHeightHint =>
      'Optional, in centimeters. No active clinical use yet.';

  @override
  String get weightEntrySectionTitle => 'Weight entries';

  @override
  String get weightEntryEmptyState => 'No weight entries yet.';

  @override
  String get weightEntryAddAction => 'Add weight entry';

  @override
  String get weightEntryFormTitle => 'New weight entry';

  @override
  String get weightEntryFormEditTitle => 'Edit weight entry';

  @override
  String get weightEntryWeightLabel => 'Weight (kg)';

  @override
  String get weightEntryReasonLabel => 'Reason for this entry';

  @override
  String get weightEntryReasonGiFlare => 'GI flare';

  @override
  String get weightEntryReasonMedicationChange => 'Medication change';

  @override
  String get weightEntryReasonFluidRetention => 'Fluid retention';

  @override
  String get weightEntryReasonAppetiteChange => 'Appetite change';

  @override
  String get weightEntryReasonOther => 'Other reason';

  @override
  String get weightEntryNoteHint => 'Optional note';

  @override
  String get weightEntryDateLabel => 'Entry date';

  @override
  String get weightEntrySaveAction => 'Save entry';

  @override
  String get aboutBlueskyLinkLabel => 'Follow us on Bluesky';

  @override
  String get bloodPressureSectionTitle => 'Blood pressure';

  @override
  String get bloodPressureActionAddEntry => 'Add blood pressure reading';

  @override
  String get bloodPressureModalLogHeader => 'New blood pressure reading';

  @override
  String get bloodPressureModalEditHeader => 'Edit blood pressure reading';

  @override
  String get bloodPressureFieldSystolicLabel => 'Systolic';

  @override
  String get bloodPressureFieldDiastolicLabel => 'Diastolic';

  @override
  String get bloodPressureFieldHeartRateLabel => 'Heart rate (optional)';

  @override
  String get bloodPressureHeartRateUnit => 'bpm';

  @override
  String get bloodPressureFieldPositionLabel => 'Position';

  @override
  String get bloodPressurePositionSitting => 'Sitting';

  @override
  String get bloodPressurePositionLying => 'Lying down';

  @override
  String get bloodPressurePositionStanding => 'Standing';

  @override
  String get settingsModuleBloodPressureLabel => 'Blood pressure';

  @override
  String get settingsModuleBloodPressureDescription =>
      'Log everyday blood pressure readings (systolic/diastolic, optional heart rate, position). No automatic interpretation or standing-test comparison.';
}
