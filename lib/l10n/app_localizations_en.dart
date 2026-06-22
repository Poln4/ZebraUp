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
  String get bowelBucketDiarrea => 'diarrhea';

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
  String get sleepFieldDurationLabel => 'DURATION';

  @override
  String get sleepFieldDurationHint => 'hours (e.g., 7.5)';

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
  String get settingsCarefulModeLabel => 'Careful mode';

  @override
  String get settingsCarefulModeDescription =>
      'Reduces visual noise: sections start collapsed. Tap the header to expand what you want to see.';
}
