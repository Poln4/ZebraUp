// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navHoy => '今天';

  @override
  String get navSintomas => '症狀';

  @override
  String get navMovimiento => '活動量';

  @override
  String get navBotiquin => '藥箱';

  @override
  String get navClinica => '診所';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '儲存';

  @override
  String get actionImport => '匯入';

  @override
  String get actionContinue => '繼續';

  @override
  String get actionUnderstood => '知道了';

  @override
  String get languageSectionTitle => '語言 / LANGUAGE';

  @override
  String get languageFootnote => '語言設定將套用至整個應用程式。您的資料不會改變。';

  @override
  String get myDataTitle => '我的資料';

  @override
  String get arcoRightsBlurb => '您有權隨時存取、匯出、匯入或刪除您的資料。';

  @override
  String get exportDataButton => '匯出我的資料';

  @override
  String get importFileButton => '從檔案匯入';

  @override
  String get importPasteButton => '貼上文字匯入';

  @override
  String get wipeAllButton => '清除所有資料';

  @override
  String get wipeWarningFootnote => '此操作將清除所有個人檔案、紀錄與設定。此動作無法復原。';

  @override
  String exportSuccess(String filename) {
    return '資料已匯出：$filename';
  }

  @override
  String exportError(String reason) {
    return '匯出失敗：$reason';
  }

  @override
  String importCancelled(String reason) {
    return '匯入已取消：$reason';
  }

  @override
  String get importSuccess => '個人檔案已成功匯入。';

  @override
  String get importDialogTitle => '匯入此個人檔案';

  @override
  String importDialogName(String name) {
    return '姓名：$name';
  }

  @override
  String importDialogExportedAt(String date) {
    return '匯出時間：$date';
  }

  @override
  String importDialogContains(int count) {
    return '內含 $count 筆紀錄：';
  }

  @override
  String get importDialogFootnote => '這將作為新的個人檔案新增。您目前的個人檔案不會被刪除。';

  @override
  String get nounSymptoms => '症狀';

  @override
  String get nounDoses => '劑量';

  @override
  String get nounStructural => '結構事件';

  @override
  String get nounActivities => '活動';

  @override
  String get nounTherapies => '治療';

  @override
  String get nounMoods => '情緒';

  @override
  String get nounMental => '心理紀錄';

  @override
  String get pasteImportTitle => '貼上文字匯入';

  @override
  String get pasteImportInstructions =>
      '打開您匯出的 .json 檔案（例如透過「檔案」App），選取所有文字並複製，然後貼到此處。';

  @override
  String get pasteImportHint => '請在此處貼上檔案內容...';

  @override
  String get errImportUnreadable => '無法讀取檔案。';

  @override
  String get errImportInvalidJson => '文字非有效的 JSON 格式。';

  @override
  String get errImportNotZebra => '此檔案似乎不屬於 ZebraUpp。';

  @override
  String get errImportUnknownSchema => '未知的結構版本 (Schema Version)。';

  @override
  String errImportSchemaMismatch(String found, String expected) {
    return '此檔案版本不符 (發現 v$found)。預期版本：v$expected。';
  }

  @override
  String get errImportMissingProfile => '檔案中找不到個人檔案。';

  @override
  String get errImportCorruptProfile => '個人檔案已損壞或格式異常。';

  @override
  String get actionHide => '隱藏';

  @override
  String get hintTapTip => '提示：在「症狀」中，點擊庫存中的標籤即可紀錄。長按某條紀錄可進行編輯。';

  @override
  String get sectionPending => '待辦事項';

  @override
  String get sectionWeather => '今日天氣';

  @override
  String get headerTodayIs => '今天是';

  @override
  String get pacingActiveState => '休息日 — 給自己放個假';

  @override
  String get pacingInactiveState => '標記為休息日';

  @override
  String outcomeCardTimePrefix(String hours) {
    return '$hours 小時前您服用了';
  }

  @override
  String get outcomeCardForSymptom => '以緩解您的';

  @override
  String get outcomeCardInitialState => '當時狀態為 ';

  @override
  String get outcomeCardQuestionNow => '現在感覺如何？';

  @override
  String get outcomeCardAttributionQuestion => '您認為原因是什麼？';

  @override
  String get outcomeActionAddFactor => '其他因素';

  @override
  String get sectionMentalDetails => '心理細節';

  @override
  String get mentalIntensitySubtitle => '目前的強烈程度';

  @override
  String get summaryTitle => '今日簡短總結';

  @override
  String get summaryEmptyPacing => '🛡️ 休息日。您今天還沒有紀錄任何內容 — 這很好。';

  @override
  String get summaryEmptyNormal => '您今天還沒有紀錄任何內容。一切都還好嗎？';

  @override
  String summarySymptomSingle(String name, String label) {
    return '您紀錄了 1 個症狀：$name ($label)。';
  }

  @override
  String summarySymptomPlural(int count, String name, String label) {
    return '您紀錄了 $count 個症狀 — 最強烈的是 $name ($label)。';
  }

  @override
  String summaryStructuralSingle(String zone) {
    return '您在 $zone 發生了 1 次結構事件。';
  }

  @override
  String summaryStructuralPlural(int count) {
    return '您今天發生了 $count 次結構事件。';
  }

  @override
  String summaryDosesSentence(int totalDoses, String shown, int extraCount) {
    String _temp0 = intl.Intl.pluralLogic(
      extraCount,
      locale: localeName,
      other: '，以及其他 $extraCount 次',
      zero: '',
    );
    return '您服用了 $totalDoses 次劑量：$shown$_temp0。';
  }

  @override
  String summaryMoodSentence(String statesStr, String extra) {
    return '您紀錄的心情與感受：$statesStr$extra。';
  }

  @override
  String get summaryPacingFooter => '🛡️ 您允許了自己好好休息。這也很重要。';

  @override
  String get wisdomBannerTitle => '✨ 斑馬智慧 🦓';

  @override
  String get bowelCountToday => '最近一次排便：今天';

  @override
  String get bowelCountYesterday => '最近一次排便：昨天';

  @override
  String bowelCountDaysAgo(int days) {
    return '最近一次排便：$days 天前';
  }

  @override
  String distentionBannerMessage(int days) {
    return '您已經 $days 天沒有排便了 — 腹脹與腹痛症狀可能會開始累積。';
  }

  @override
  String get distentionBannerAction => '前往「症狀」';

  @override
  String get severityNone => '無';

  @override
  String get severityMild => '輕度';

  @override
  String get severityModerate => '中度';

  @override
  String get severityIntense => '重度';

  @override
  String get severityUnbearable => '無法忍受';

  @override
  String get reasonNatural => '症狀的自然轉變';

  @override
  String get reasonMedicationHelped => '我覺得這款藥物有幫助';

  @override
  String get reasonOtherTrigger => '其他誘發因素（食物、壓力、天氣...）';

  @override
  String get reasonAdditionalMed => '我也服用了其他藥物';

  @override
  String get reasonUnsure => '無法完全確定';

  @override
  String get mentalStateMood => '情緒';

  @override
  String get mentalStateAnxiety => '焦慮';

  @override
  String get mentalStateBrainFog => '腦霧';

  @override
  String get mentalStateDissociation => '解離感';

  @override
  String get mentalStateIrritability => '易怒';

  @override
  String get mentalStateEmotionalEnergy => '情感能量';

  @override
  String get outcomeCoarsePending => '待定';

  @override
  String get outcomeCoarseMuchBetter => '好很多';

  @override
  String get outcomeCoarseBetter => '較好';

  @override
  String get outcomeCoarseEqual => '沒變化';

  @override
  String get outcomeCoarseWorse => '變差';

  @override
  String get outcomeCoarseMuchWorse => '變差很多';

  @override
  String get pubMedNoAuthor => '未登記作者';

  @override
  String get quadrantActivatedUnpleasant => '亢奮 · 不適';

  @override
  String get quadrantActivatedPleasant => '亢奮 · 舒適';

  @override
  String get quadrantCalmUnpleasant => '平靜 · 不適';

  @override
  String get quadrantCalpleasant => '平靜 · 舒適';

  @override
  String get quadrantTeaserActivatedUnpleasant => '緊繃、焦慮';

  @override
  String get quadrantTeaserActivatedPleasant => '活力、喜悅';

  @override
  String get quadrantTeaserCalmUnpleasant => '精疲力竭、沮喪';

  @override
  String get quadrantTeaserCalmPleasant => '放鬆、寧靜';

  @override
  String get bowelBucketConstipation => '便秘';

  @override
  String get bowelBucketNormal => '正常';

  @override
  String get bowelBucketDiarrhea => '腹瀉';

  @override
  String get sleepQualityBad => '差';

  @override
  String get sleepQualityRegular => '普通';

  @override
  String get sleepQualityGood => '好';

  @override
  String get sleepQualityVeryGood => '很好';

  @override
  String get beverageWater => '水';

  @override
  String get beverageElectrolyte => '電解質液';

  @override
  String get beverageCoffee => '咖啡';

  @override
  String get beverageOther => '其他';

  @override
  String get sodiumPinch => '一小撮鹽';

  @override
  String get sodiumSachet => '電解質粉包';

  @override
  String get sodiumSaltySnack => '鹹味點心';

  @override
  String get hrvContextMorning => '晨間';

  @override
  String get hrvContextAfternoon => '午後';

  @override
  String get hrvContextEvening => '晚間';

  @override
  String get hrvContextPostExercise => '運動後';

  @override
  String get hrvContextOther => '其他';

  @override
  String legacyIntensityLabel(String value) {
    return '先前的強烈程度：$value/5';
  }

  @override
  String get botiquinTabTitle => '您的藥箱';

  @override
  String get botiquinActionCreate => '新增藥物';

  @override
  String get botiquinSearchHint => '搜尋藥物...';

  @override
  String get botiquinSearchNoResults => '找不到藥物';

  @override
  String get botiquinInteractionsTitle => '偵測到藥物交互作用';

  @override
  String get botiquinGroupsTitle => '群組';

  @override
  String get botiquinGroupsEmptyHeadline => '🌙 夜間藥物 · ☀️ 晨間藥物';

  @override
  String get botiquinGroupsEmptyBody => '將您需要同時服用的藥物分組。一鍵即可同時紀錄所有劑量。';

  @override
  String get botiquinActionCreateGroup => '建立群組';

  @override
  String get botiquinNoMedsDialogTitle => '無藥物';

  @override
  String get botiquinNoMedsDialogBody => '在建立群組前，請先在藥箱中至少新增一種藥物。';

  @override
  String botiquinRowMedsCountLabel(int count) {
    return '$count 種藥物';
  }

  @override
  String get botiquinActionEditTooltip => '編輯';

  @override
  String get botiquinBatchSheetTitle => '紀錄群組藥物';

  @override
  String get botiquinBatchSheetSubtitle => '將紀錄以下劑量：';

  @override
  String botiquinBatchOrphanWarning(int count) {
    return '⚠️ 藥箱中有 $count 種藥物已被刪除 — 將會自動跳過。';
  }

  @override
  String botiquinBatchActionSubmit(int count) {
    return '紀錄 $count 次劑量';
  }

  @override
  String get botiquinEmptyStateHeadline => '您尚未新增任何藥物';

  @override
  String get botiquinEmptyStateSubtitle => '請使用下方的按鈕新增藥物。';

  @override
  String botiquinDoseLoggedTodayBadge(String qty) {
    return '今天已服用 $qty';
  }

  @override
  String botiquinDeleteConfirmTitle(String name) {
    return '刪除 $name？';
  }

  @override
  String botiquinDeleteConfirmBody(String name) {
    return '系統將會保留劑量歷史紀錄以供報告使用，但 $name 將會自您的藥箱中移除。';
  }

  @override
  String get botiquinActionDelete => '刪除';

  @override
  String get botiquinLogDoseSheetTitle => '紀錄劑量';

  @override
  String botiquinLogDoseTotalCalculated(String total, String unit) {
    return '= 總計 $total $unit';
  }

  @override
  String get botiquinLogDoseSymptomPrompt => '是為了解緩某個特定症狀嗎？';

  @override
  String get botiquinLogDoseSymptomNone => '無';

  @override
  String botiquinLogDoseTrackOutcomeToggle(int hours) {
    return '在 $hours 小時後詢問是否有效';
  }

  @override
  String get botiquinDoseListTitle => '今天的劑量紀錄';

  @override
  String get botiquinDoseListFootnote => '點擊 × 可刪除特定的劑量（若名稱紀錄錯誤時非常實用）。';

  @override
  String get botiquinDoseItemDeleteConfirmTitle => '刪除此劑量';

  @override
  String botiquinDoseItemDeleteConfirmBody(String name, String time) {
    return '確定要刪除在 $time 紀錄的 $name 劑量嗎？此操作無法撤銷。';
  }

  @override
  String botiquinTimeTodayAt(String time) {
    return '今天 $time';
  }

  @override
  String botiquinTimePastAt(int day, int month, String time) {
    return '$month/$day $time';
  }

  @override
  String get onboardingActionBack => '返回';

  @override
  String get onboardingActionSkip => '跳過';

  @override
  String get onboardingActionNext => '下一步';

  @override
  String get onboardingActionFinish => '開始使用';

  @override
  String get onboardingFallbackProfileName => '我的個人檔案';

  @override
  String get onboardingStepWelcomeTitle => 'ZebraUp';

  @override
  String get onboardingStepWelcomeSubtitle => '您的就醫看診神助手。';

  @override
  String get onboardingStepWelcomeBody =>
      '看診時間總是短暫。在度過艱難的一週後，人的記憶力也是。ZebraUp 能幫您紀錄症狀、用藥和身體規律，讓您每次看診時都能帶著具體的數據報告，而不是在坐在醫生面前後，腦袋一片空白、只剩零星片斷的模糊描述。此外，我們知道您可能還需要照顧他人，因此您也可以在此新增家人或寵物。';

  @override
  String get onboardingStepWelcomePrivacyNote =>
      '您的所有資料均儲存在本裝置中。我們不會將任何內容上傳至網路。';

  @override
  String get onboardingStepWelcomeMedicalDisclaimer =>
      '本應用程式並非醫療器材。它不具備診斷、治療、緩解、治癒或預防任何醫療狀況的功能。';

  @override
  String get onboardingStepNameTitle => '讓我們開始吧。';

  @override
  String get onboardingStepNameQuestion => '我們該如何稱呼您？';

  @override
  String get onboardingStepNameFootnote => '僅用於個人化應用程式介面。您稍後可以隨時更改。';

  @override
  String get onboardingStepNameHint => '您的名字或暱稱';

  @override
  String get onboardingStepConditionsTitle => '您的確診狀況。';

  @override
  String get onboardingStepConditionsBody =>
      '您目前有哪些疾病或健康狀況？我們將用這些資訊來輔助說明藥物交互作用和報告。您可以新增、編輯或跳過此步驟。';

  @override
  String get onboardingStepConditionsHint => '例如：hEDS、POTS、MCAS...';

  @override
  String get onboardingStepConditionsEmpty => '尚未新增任何項目。您可以跳過此步驟。';

  @override
  String get onboardingStepMedsTitle => '您的藥箱。';

  @override
  String get onboardingStepMedsBody =>
      '新增您定期服用的藥物。之後您只需在「藥箱」標籤頁中點擊一下，即可快速紀錄每次服藥劑量。';

  @override
  String get onboardingStepMedsNameHint => '藥物名稱';

  @override
  String get onboardingStepMedsDoseHint => '劑量（例如：400mg）';

  @override
  String get onboardingStepMedsEmpty => '目前沒有藥物。您可以跳過此步驟。';

  @override
  String get symptomsSectionStructuralZones => '結構區域';

  @override
  String get symptomsSectionBowelTransit => '腸道蠕動';

  @override
  String get symptomsActionAddHemorrhoid => '痔瘡';

  @override
  String get symptomsSectionTodaysLogs => '今天的紀錄';

  @override
  String get symptomsFootnoteLongPressEdit => '長按某條紀錄可編輯日期、嚴重程度或備註。';

  @override
  String get symptomsSectionTrending => '近期趨勢（過去 7 天）';

  @override
  String get symptomsTrendingEmpty => '本週沒有持續出現的症狀。';

  @override
  String get symptomsSectionVault => '症狀庫存';

  @override
  String get symptomsVaultPlaceholder => '+ 將症狀新增至庫存...';

  @override
  String symptomsModalLogHeader(String zone) {
    return '紀錄於：$zone';
  }

  @override
  String symptomsModalEditHeader(String zone, String type) {
    return '編輯：$zone / $type';
  }

  @override
  String symptomsModalEditSymptomHeader(String name) {
    return '編輯：$name';
  }

  @override
  String get symptomsLabelOptionalNote => '選填備註（情境、誘發原因等）';

  @override
  String get symptomsLabelOptionalNoteSimple => '選填備註';

  @override
  String get symptomsLabelSeverityGrading => '嚴重程度';

  @override
  String get symptomsActionLogUnrated => '不評分直接紀錄';

  @override
  String get symptomsUnratedLabelSuffix => '未評分';

  @override
  String get symptomsUnratedInlineWarning => '此紀錄尚無評分。點擊節點來指定一個級別。';

  @override
  String get symptomsActionSaveChanges => '儲存變更';

  @override
  String get symptomsActionSave => '儲存';

  @override
  String get zoneCervical => '頸椎';

  @override
  String get zoneHombros => '肩膀';

  @override
  String get zoneMunecas => '手腕';

  @override
  String get zoneManos => '手部';

  @override
  String get zoneLumbarPelvis => '腰椎/骨盆';

  @override
  String get zoneCaderas => '髖關節';

  @override
  String get zoneRodillas => '膝關節';

  @override
  String get zoneTobillos => '腳踝';

  @override
  String get structTypeSubluxation => '半脫位';

  @override
  String get structTypeDislocation => '脫位（脫臼）';

  @override
  String get structTypeInstability => '關節不穩定';

  @override
  String get structTypeJointPain => '關節疼痛';

  @override
  String get structTypeMyofascial => '肌筋膜疼痛';

  @override
  String get structTypeNeuropathic => '神經性疼痛';

  @override
  String bowelLabelBristolType(String type) {
    return '布里斯托第 $type 型';
  }

  @override
  String get bowelLabelUrgency => '急迫感';

  @override
  String get bowelLabelBleeding => '出血';

  @override
  String get bowelLabelIncomplete => '排不乾淨';

  @override
  String get movementSectionPacingActive => '今天是休息日。好好休息也是一種進展。';

  @override
  String get movementSectionHistoryTitle => '今天您做了...';

  @override
  String get movementFootnoteLongPressEdit => '長按紀錄即可進行編輯。';

  @override
  String get movementEmptyStateHeadline => '活動與復原同樣重要。';

  @override
  String get movementEmptyStateSubtitle => '散步、伸展、物理治療、按摩 — 這些都是照顧身體的一部分。';

  @override
  String get movementSectionActivityTitle => '活動';

  @override
  String get movementActivityPlaceholder => '+ 新增活動（游泳、單車、舞蹈...）';

  @override
  String get movementSectionTherapyTitle => '治療與調理';

  @override
  String get movementTherapyPlaceholder => '+ 新增項目（靈氣、漂浮舒壓...）';

  @override
  String activityModalLogHeader(String name) {
    return '紀錄：$name';
  }

  @override
  String activityModalEditHeader(String name) {
    return '編輯：$name';
  }

  @override
  String get activityFieldDurationHint => '時長（分鐘）';

  @override
  String get activityFieldSetsHint => '組數';

  @override
  String get activityFieldRepsHint => '次數';

  @override
  String get activityFieldHhrHint => '選填心率（例如：70→110）';

  @override
  String activityLabelEffortSlider(int value) {
    return '自覺強度：$value/10';
  }

  @override
  String activityLabelFeelingSlider(int value) {
    return '身體感受：$value/5';
  }

  @override
  String get activityActionTogglePainRating => '評估活動前/後疼痛（選填）';

  @override
  String get activityLabelPainBefore => '活動前疼痛';

  @override
  String get activityLabelPainAfter => '活動後疼痛';

  @override
  String get activityActionSubmitLog => '儲存活動';

  @override
  String get activityActionSubmitChanges => '儲存變更';

  @override
  String get painLabelNone => '無痛';

  @override
  String get painLabelMild => '輕微';

  @override
  String get painLabelModerate => '中度';

  @override
  String get painLabelIntense => '強烈';

  @override
  String get painLabelSevere => '嚴重';

  @override
  String painDeltaLabelImproved(int count) {
    return '您的疼痛減輕了 $count 個層級';
  }

  @override
  String painDeltaLabelWorsened(int count) {
    return '您的疼痛加劇了 $count 個層級';
  }

  @override
  String get painDeltaLabelUnchanged => '無變化';

  @override
  String logSubtitleMetricDuration(int minutes) {
    return '$minutes 分鐘';
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
    return '$detail · 強度 $effort/10 · 感受 $feeling/5$painSuffix';
  }

  @override
  String logSubtitlePainDeltaImproved(int levels) {
    return '↓$levels 級';
  }

  @override
  String logSubtitlePainDeltaWorsened(int levels) {
    return '↑$levels 級';
  }

  @override
  String get logSubtitlePainDeltaUnchanged => '無變化';

  @override
  String get feelingLabelLevel1 => '🤕 疼痛不適 / 受傷';

  @override
  String get feelingLabelLevel2 => '😟 不舒服 / 令人擔憂';

  @override
  String get feelingLabelLevel3 => '😐 平常心 / 無感';

  @override
  String get feelingLabelLevel4 => '😊 輕鬆舒適';

  @override
  String get feelingLabelLevel5 => '💪 充滿力量與安全感';

  @override
  String get onboardingHaveProfileTitle => '我已經有儲存的個人檔案';

  @override
  String get onboardingHaveProfileSubtitle => '從 JSON 檔案匯入';

  @override
  String get onboardingImportChoiceTitle => '要如何匯入？';

  @override
  String get onboardingImportFromFile => '從檔案匯入';

  @override
  String get onboardingImportFromPaste => '貼上文字';

  @override
  String get feverSectionTitle => '發燒紀錄';

  @override
  String get feverActionAddReading => '+ 量測體溫';

  @override
  String get feverModalLogHeader => '紀錄體溫';

  @override
  String get feverModalEditHeader => '編輯體溫紀錄';

  @override
  String get feverFieldSiteLabel => '量測部位';

  @override
  String get feverFieldAntipyreticLabel => '退燒藥';

  @override
  String get feverFieldAntipyreticToggle => '已服用退燒藥物';

  @override
  String get feverFieldAntipyreticNameHint => '藥物名稱（普拿疼、布洛芬等）';

  @override
  String get feverHintTapToEdit => '點擊數字即可進行編輯';

  @override
  String get feverDirectEditDialogTitle => '編輯體溫';

  @override
  String get feverDirectEditDialogHint => '例如：38.7';

  @override
  String get feverLogLabelWithAntipyretic => '含退燒藥';

  @override
  String get feverSiteAxillary => '腋溫';

  @override
  String get feverSiteOral => '口溫';

  @override
  String get feverSiteTympanic => '耳溫';

  @override
  String get feverSiteRectal => '肛溫';

  @override
  String get feverSiteForehead => '額溫';

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes 分鐘前';
  }

  @override
  String timeAgoHours(int hours) {
    return '$hours 小時前';
  }

  @override
  String get researchEmptyConfig => '請在設定中新增您的診斷狀況，以查看相關的醫學研究。';

  @override
  String get researchTitleRecent => 'PubMed 最新研究結果';

  @override
  String get researchDisclaimer => '向下滑動可重新整理。僅供參考，不構成醫療建議。';

  @override
  String get researchTooltipOffline => '已儲存的結果（離線模式）';

  @override
  String get researchStateNoData => '暫無資料。向下滑動以進行搜尋。';

  @override
  String get researchStateNoResults => '未找到近期的相關結果。';

  @override
  String researchLastUpdated(String time) {
    return '更新時間：$time';
  }

  @override
  String get researchActionSaved => '已儲存';

  @override
  String get researchActionSave => '儲存';

  @override
  String get researchActionOpenPubMed => '在 PubMed 中開啟';

  @override
  String get researchActionCopyPmid => '複製 PMID';

  @override
  String researchSnackPmidCopied(String pmid) {
    return 'PMID $pmid 已複製。';
  }

  @override
  String get researchLoadingAbstract => '正在載入摘要...';

  @override
  String get researchEmptyAbstract => '暫無摘要。請在 PubMed 中打開文章以獲取更多詳細資訊。';

  @override
  String get reportRangeDay => '1 天';

  @override
  String get reportRangeWeek => '7 天';

  @override
  String get reportRangeMonth => '30 天';

  @override
  String get reportRangeCustomTooltip => '自訂範圍';

  @override
  String reportRangeCustomActiveLabel(String start, String end) {
    return '範圍：$start → $end';
  }

  @override
  String get structKindJoint => '關節';

  @override
  String get structKindMuscle => '肌肉';

  @override
  String get structKindTendon => '肌腱';

  @override
  String get structKindLigament => '韌帶';

  @override
  String get structKindSoftTissue => '軟組織';

  @override
  String get structKindNerve => '神經';

  @override
  String get structTypeMuscleStrain => '肌肉拉傷';

  @override
  String get structTypeMuscleDistension => '肌肉挫傷';

  @override
  String get structTypeMuscleTear => '肌肉撕裂傷';

  @override
  String get structTypeContracture => '肌肉攣縮';

  @override
  String get structTypeMuscleSpasm => '肌肉痙攣（抽筋）';

  @override
  String get structTypeTendinitis => '肌腱炎';

  @override
  String get structTypeTendinosis => '肌腱變性';

  @override
  String get structTypeBursitis => '滑囊炎';

  @override
  String get structTypeEnthesitis => '附著點炎';

  @override
  String get structTypeTendonFissure => '肌腱裂傷';

  @override
  String get structTypeMildSprain => '輕度扭傷';

  @override
  String get structTypeSevereSprain => '嚴重扭傷';

  @override
  String get structTypeLigamentTear => '韌帶撕裂';

  @override
  String get structTypeSuperficialCut => '表淺割傷';

  @override
  String get structTypeSkinFissure => '皮膚裂傷';

  @override
  String get structTypeDeepWound => '深層傷口';

  @override
  String get structTypeHematoma => '血腫';

  @override
  String get structTypeContusion => '挫傷（瘀青）';

  @override
  String get structTypeBurn => '燒燙傷';

  @override
  String get structTypeAbrasion => '擦傷';

  @override
  String get structTypeParesthesia => '感覺異常（發麻）';

  @override
  String get sleepSectionTitle => '睡眠紀錄';

  @override
  String get sleepActionAddEntry => '+ 紀錄睡眠';

  @override
  String get sleepModalLogHeader => '紀錄睡眠';

  @override
  String get sleepModalEditHeader => '編輯睡眠紀錄';

  @override
  String get sleepFieldQualityLabel => '睡眠品質';

  @override
  String get sleepFieldDurationLabel => '睡眠時長';

  @override
  String get sleepFieldDurationHint => '小時（例如：7.5）';

  @override
  String get sleepFieldOnsetLatencyLabel => '入睡所需時間';

  @override
  String get sleepFieldOnsetLatencyHint => '分鐘';

  @override
  String get sleepFieldWakeCountLabel => '醒來次數';

  @override
  String get sleepFieldNightmareToggle => '做惡夢';

  @override
  String get sleepLogLabelSlept => '睡眠時間';

  @override
  String sleepLogLabelHours(String hours) {
    return '$hours 小時';
  }

  @override
  String sleepLogLabelWakes(int count) {
    return '醒來 $count 次';
  }

  @override
  String sleepLogLabelOnsetLatency(int minutes) {
    return '花費 $minutes 分鐘入睡';
  }

  @override
  String get sleepLogLabelWithNightmare => '惡夢';

  @override
  String get settingsOptionalModulesTitle => '選配功能模組';

  @override
  String get settingsOptionalModulesBlurb => '僅啟用您想要追蹤的項目。關閉的模組將不會出現在「症狀」功能中。';

  @override
  String get settingsModuleSleepLabel => '睡眠';

  @override
  String get settingsModuleSleepDescription => '追蹤每晚的睡眠品質、時長與夜醒次數。';

  @override
  String get bodyRegionHeadNeck => '頭部與頸部';

  @override
  String get bodyRegionShouldersUpperBack => '肩膀與上背部';

  @override
  String get bodyRegionArms => '手臂';

  @override
  String get bodyRegionChestAbdomen => '胸部與腹部';

  @override
  String get bodyRegionLowerBackPelvis => '下背部與骨盆';

  @override
  String get bodyRegionLegs => '腿部';

  @override
  String get zoneJaw => '下顎';

  @override
  String get zoneTemple => '太陽穴';

  @override
  String get zoneShoulderBlades => '肩胛骨';

  @override
  String get zoneUpperBack => '上背部';

  @override
  String get zoneUpperArm => '上臂';

  @override
  String get zoneElbow => '手肘';

  @override
  String get zoneForearm => '前臂';

  @override
  String get zoneChest => '胸部';

  @override
  String get zoneSide => '側腹 / 身體側邊';

  @override
  String get zoneRibs => '肋骨';

  @override
  String get zoneAbdomen => '腹部';

  @override
  String get zoneGlutes => '臀大肌';

  @override
  String get zoneFrontThigh => '大腿前側';

  @override
  String get zoneBackThigh => '大腿後側';

  @override
  String get zoneCalf => '小腿';

  @override
  String get zoneFeet => '雙腳';

  @override
  String get hydrationSectionTitle => '水分補充';

  @override
  String get hydrationActionAddEntry => '+ 紀錄水分補充';

  @override
  String get hydrationModalLogHeader => '紀錄水分補充';

  @override
  String get hydrationModalEditHeader => '編輯水分紀錄';

  @override
  String get hydrationFieldVolumeLabel => '容量';

  @override
  String get hydrationFieldVolumeHint => '毫升 ml（例如：250）';

  @override
  String get hydrationFieldBeverageLabel => '飲品類型';

  @override
  String get hydrationFieldSodiumLabel => '鈉含量（選填）';

  @override
  String hydrationLogLabelVolume(String volume) {
    return '$volume ml';
  }

  @override
  String get hrvSectionTitle => 'HRV 心率變異率';

  @override
  String get hrvActionAddEntry => '+ 紀錄 HRV';

  @override
  String get hrvModalLogHeader => '紀錄 HRV 量測值';

  @override
  String get hrvModalEditHeader => '編輯 HRV 紀錄';

  @override
  String get hrvFieldRmssdLabel => 'RMSSD';

  @override
  String get hrvFieldContextLabel => '量測情境';

  @override
  String get hrvFieldSourceLabel => '資料來源';

  @override
  String get hrvHintTapToEdit => '點擊數字即可進行編輯';

  @override
  String get hrvDirectEditDialogTitle => '編輯 RMSSD';

  @override
  String get hrvDirectEditDialogHint => '例如：35';

  @override
  String hrvLogLabelRmssd(String value) {
    return '$value ms';
  }

  @override
  String get hrvSourceManual => '手動輸入';

  @override
  String get hrvSourceAppleWatch => 'Apple Watch';

  @override
  String get hrvSourceWelltory => 'Welltory';

  @override
  String get hrvSourceOther => '其他';

  @override
  String get settingsModuleHydrationLabel => '水分補充';

  @override
  String get settingsModuleHydrationDescription => '追蹤飲水量、飲品類型與鈉攝取量。';

  @override
  String get settingsModuleHrvLabel => 'HRV 心率變異率';

  @override
  String get settingsModuleHrvDescription => '依量測情境與資料來源追蹤心率變異率。';

  @override
  String get sectionHintNoActivity => '暫無紀錄';

  @override
  String get sectionHintToday => '最新紀錄：今天';

  @override
  String get sectionHintYesterday => '最新紀錄：昨天';

  @override
  String sectionHintDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天前',
    );
    return '最新紀錄：$_temp0';
  }

  @override
  String get settingsViewPreferencesTitle => '顯示設定';

  @override
  String get settingsCarefulModeLabel => '精簡模式';

  @override
  String get settingsCarefulModeDescription =>
      '減少視覺干擾：所有區塊預設為摺疊狀態。點擊標題區塊即可展開您想查看的內容。';

  @override
  String get drugKindMedication => '藥物';

  @override
  String get drugKindSupplement => '保健食品';

  @override
  String get drugKindHerbal => '草藥產品';

  @override
  String get drugInteractionsInBotiquinHeader => '您藥箱中的交互作用';

  @override
  String get drugInteractionSeverityHigh => '高';

  @override
  String get drugInteractionSeverityMedium => '中';

  @override
  String get drugInteractionSeverityLow => '低';

  @override
  String get drugNoContentSupplement =>
      '保健食品 — 未作為藥物受到管制。在與其他治療方法結合使用前，請諮詢您的醫療團隊。';

  @override
  String get drugNoContentHerbal => '草藥產品 — 臨床證據有限。在與其他治療方法結合使用前，請諮詢您的醫療團隊。';

  @override
  String drugNoContentMedlineEmpty(String rxcui) {
    return 'MedlinePlus 未返回此藥物的資訊 (RxCUI $rxcui)。這可能是暫時性問題，或是該資料庫中沒有此代碼的內容。';
  }

  @override
  String get drugNoContentUnmapped =>
      '我們尚無此產品的詳細資訊。您可以手動在 medlineplus.gov 上搜尋。';

  @override
  String get drugNoContentGeneric => '無法載入資訊。';

  @override
  String get drugReadMoreMedlinePlus => '在 MedlinePlus 上閱讀更多';

  @override
  String get drugBrowserOpenError => '無法開啟瀏覽器。請檢查您的網路連線。';

  @override
  String get drugConfidenceMediumWarning => '中等信賴度映射 — 如果資訊與您的藥物不符，請與您的醫療團隊核實。';

  @override
  String get drugSourceLocalCurated => '來源：為此應用程式在地整理的臨床資訊。不能取代醫療建議。';

  @override
  String get drugSourceMedlinePlus => '來源：MedlinePlus，美國國家醫學圖書館。不能取代醫療建議。';

  @override
  String get drugSourceNoInfo => '我們的來源中沒有可用的臨床資訊。';

  @override
  String get drugLoadError => '無法載入資訊。';

  @override
  String get conditionSourceLocalCurated => '來源：ZebraUp 針對此病症的在地資訊。不能取代醫療建議。';

  @override
  String get conditionContentUnverifiedWarning =>
      '此摘要是根據一般醫學知識草擬，尚未經過臨床審查確認。如果內容與您的醫療團隊所說有出入，請以醫療團隊的說法為準。';

  @override
  String get conditionNoContentUnmapped =>
      '我們尚未收錄此病症。您可以手動在 medlineplus.gov 上搜尋。';

  @override
  String get conditionNoContentNoIcd10 =>
      '此病症沒有 ICD-10 代碼，因此無法查詢 MedlinePlus，我們也尚未提供在地摘要。';

  @override
  String get conditionNoContentMedlineEmpty =>
      'MedlinePlus 未能提供此病症的資訊。可能是暫時性問題，或此代碼缺乏內容。';

  @override
  String get moodQuadrantActivatedUnpleasant => '活躍 · 不快';

  @override
  String get moodQuadrantActivatedPleasant => '活躍 · 愉悅';

  @override
  String get moodQuadrantCalmUnpleasant => '平靜 · 不快';

  @override
  String get moodQuadrantCalmPleasant => '平靜 · 愉悅';

  @override
  String get moodTeaserActivatedUnpleasant => '緊張、焦慮';

  @override
  String get moodTeaserActivatedPleasant => '活力、喜悅';

  @override
  String get moodTeaserCalmUnpleasant => '疲憊、悲傷';

  @override
  String get moodTeaserCalmPleasant => '寧靜、平和';

  @override
  String get moodSheetStep1Title => '你感覺如何？';

  @override
  String get moodSheetCancel => '取消';

  @override
  String get moodSheetStep2Prompt => '我感覺如何？';

  @override
  String get moodSheetChangeQuadrant => '切換象限';

  @override
  String get moodSheetAlsoFeelingHeader => '我也感覺到…';

  @override
  String get moodSheetNotesHeader => '情境（選填）';

  @override
  String get moodSheetNotesPlaceholder => '例如：腦霧嚴重的一天…';

  @override
  String get moodSheetSaveButton => '儲存紀錄';

  @override
  String get moodDefinitionDialogAction => '了解';

  @override
  String get moodSectionTitle => '我的狀態';

  @override
  String get moodSectionPrompt => '你感覺如何？';

  @override
  String get moodSectionRegisterAnother => '記錄其他狀態';

  @override
  String get severityFunctionalAnchorNone => '我沒有感覺';

  @override
  String get severityFunctionalAnchorMild => '有感覺,但不影響我';

  @override
  String get severityFunctionalAnchorModerate => '讓我必須放慢或暫停';

  @override
  String get severityFunctionalAnchorIntense => '無法完成原本的計畫';

  @override
  String get severityFunctionalAnchorUnbearable => '無法正常運作,必須停下來';

  @override
  String get outcomeReasonNatural => '症狀的自然變化';

  @override
  String get outcomeReasonMedicationHelped => '我認為這個藥物有幫助';

  @override
  String get outcomeReasonOtherTrigger => '其他誘因(食物、壓力、天氣等)';

  @override
  String get outcomeReasonAdditionalMed => '我也服用了其他藥物';

  @override
  String get outcomeReasonUnsure => '我不確定';

  @override
  String get medicationOutcomeCoarsePending => '待回答';

  @override
  String get medicationOutcomeCoarseMuchBetter => '好很多';

  @override
  String get medicationOutcomeCoarseBetter => '比較好';

  @override
  String get medicationOutcomeCoarseSame => '一樣';

  @override
  String get medicationOutcomeCoarseWorse => '比較差';

  @override
  String get medicationOutcomeCoarseMuchWorse => '差很多';

  @override
  String get bowelFormTitleNew => '記錄排便';

  @override
  String get bowelFormTitleEdit => '編輯排便記錄';

  @override
  String get bowelFormBristolLabel => '布里斯托類型';

  @override
  String bowelFormBristolLegendTemplate(
    String constipation,
    String normal,
    String diarrhea,
  ) {
    return '1-2:$constipation  ·  3-5:$normal  ·  6-7:$diarrhea';
  }

  @override
  String get bowelFormHideBristolDetail => '隱藏細節';

  @override
  String get bowelFormShowBristolDetail => '更多細節(布里斯托量表)';

  @override
  String get bowelFormSectionObservations => '觀察';

  @override
  String get bowelFormToggleUrgency => '急迫感';

  @override
  String get bowelFormToggleIncompleteEvacuation => '排便不完全';

  @override
  String get bowelFormNoteHint => '選填備註(情境、誘因等)';

  @override
  String get hemorrhoidalFormTitleNew => '記錄痔瘡';

  @override
  String get hemorrhoidalFormTitleEdit => '編輯痔瘡記錄';

  @override
  String get hemorrhoidalFormNoteHint => '選填備註';

  @override
  String get formSectionHeaderDiscomfort => '不適';

  @override
  String get formToggleBleeding => '出血';

  @override
  String get formButtonSave => '儲存';

  @override
  String get structuralFormFollowupHeader => '追蹤';

  @override
  String get structuralFormFollowupResolvedQuestion => '已經痊癒了嗎?';

  @override
  String structuralFormFollowupResolvedDateTemplate(String date) {
    return '$date 痊癒';
  }

  @override
  String get structuralFormFollowupStillPainfulQuestion => '還在痛嗎?';

  @override
  String get structuralFormFollowupStillPainfulSubtitle => '外觀已癒合但仍會疼痛';

  @override
  String bowelLogBristolTypeTemplate(int type) {
    return '類型 $type';
  }

  @override
  String get bowelLogTagUrgency => '急迫';

  @override
  String get bowelLogTagBleeding => '出血';

  @override
  String get bowelLogTagIncomplete => '不完全';

  @override
  String get hemorrhoidalLogLabel => '痔瘡';

  @override
  String get hemorrhoidalLogTagBleeding => '出血';

  @override
  String get symptomLogTagUnrated => '未評分';

  @override
  String get hoySectionPendingHeader => '待處理';

  @override
  String get hoyOutcomeForYour => '用於你的';

  @override
  String get hoyOutcomeHideReasons => '隱藏';

  @override
  String get hoyBowelCounterToday => '上次排便:今天';

  @override
  String get hoyBowelCounterYesterday => '上次排便:昨天';

  @override
  String hoyBowelCounterDaysAgoTemplate(int days) {
    return '上次排便:$days 天前';
  }

  @override
  String get hoyNarrativeEmptyPacing => '🛡️ 休息日。今天還沒記錄任何事 — 沒關係。';

  @override
  String get hoyNarrativeEmpty => '今天還沒記錄任何事。一切還好嗎?';

  @override
  String hoyNarrativeSymptomsSingleTemplate(String name, String severity) {
    return '記錄了 1 個症狀:$name($severity)。';
  }

  @override
  String hoyNarrativeSymptomsManyTemplate(
    int count,
    String name,
    String severity,
  ) {
    return '記錄了 $count 個症狀 — 最嚴重的是 $name($severity)。';
  }

  @override
  String hoyNarrativeStructuralSingleTemplate(String zone) {
    return '在$zone有 1 個結構性事件。';
  }

  @override
  String hoyNarrativeStructuralManyTemplate(int count) {
    return '今天有 $count 個結構性事件。';
  }

  @override
  String hoyNarrativeDosesSingleTemplate(String meds) {
    return '用了 1 劑:$meds。';
  }

  @override
  String hoyNarrativeDosesManyTemplate(int count, String meds) {
    return '服用了 $count 劑:$meds。';
  }

  @override
  String hoyNarrativeDosesAndMore(int count) {
    return ',還有 $count 項';
  }

  @override
  String hoyNarrativeEmaStatesTemplate(String states) {
    return '記錄的狀態與感受:$states。';
  }

  @override
  String get hoyNarrativeEmaStatesEllipsis => '...';

  @override
  String get hoyNarrativePacingTrailer => '🛡️ 你允許自己休息。這也算數。';

  @override
  String get hoyHeaderDatePattern => 'M月d日 EEEE';

  @override
  String movementModalTitleRegisterTemplate(String name) {
    return '記錄: $name';
  }

  @override
  String movementModalTitleEditTemplate(String name) {
    return '編輯: $name';
  }

  @override
  String get movementModalHintDuration => '時長(分鐘)';

  @override
  String get movementModalHintSets => '組數';

  @override
  String get movementModalHintReps => '次數';

  @override
  String get movementModalHintHeartRate => '心率(選填,例:70→110)';

  @override
  String movementModalEffortLabelTemplate(int value) {
    return '費力程度:$value/10';
  }

  @override
  String movementModalFeelingLabelTemplate(int value) {
    return '感受:$value/5';
  }

  @override
  String get movementFeelingPainOrInjury => '🤕 疼痛/受傷';

  @override
  String get movementFeelingUncomfortable => '😟 不舒服/擔心';

  @override
  String get movementFeelingNeutral => '😐 普通';

  @override
  String get movementFeelingRelaxed => '😊 放鬆';

  @override
  String get movementFeelingStrongConfident => '💪 強壯有信心';

  @override
  String get movementPainLevelNone => '無';

  @override
  String get movementPainLevelMild => '輕微';

  @override
  String get movementPainLevelModerate => '中等';

  @override
  String get movementPainLevelIntense => '強烈';

  @override
  String get movementPainLevelSevere => '嚴重';

  @override
  String movementPainDeltaImprovedTemplate(int delta) {
    String _temp0 = intl.Intl.pluralLogic(
      delta,
      locale: localeName,
      other: '$delta 級',
    );
    return '改善了 $_temp0';
  }

  @override
  String movementPainDeltaWorseTemplate(int delta) {
    String _temp0 = intl.Intl.pluralLogic(
      delta,
      locale: localeName,
      other: '$delta 級',
    );
    return '惡化了 $_temp0';
  }

  @override
  String get movementPainDeltaUnchanged => '沒有變化';

  @override
  String movementLogEntryEffortTemplate(int value) {
    return '費力 $value/10';
  }

  @override
  String movementLogEntryFeelingTemplate(int value) {
    return '感受 $value/5';
  }

  @override
  String movementLogEntryDeltaImprovedTemplate(int delta) {
    return '↓$delta 級';
  }

  @override
  String movementLogEntryDeltaWorseTemplate(int delta) {
    return '↑$delta 級';
  }

  @override
  String get movementLogEntryDeltaUnchanged => '無變化';

  @override
  String get movementLogEntryTherapyDeltaSteady => '=';

  @override
  String get appBarTooltipFontSize => '字體大小';

  @override
  String get appBarTooltipDarkMode => '深色模式';

  @override
  String get appBarTooltipLightMode => '淺色模式';

  @override
  String get appBarTooltipSettings => '設定';

  @override
  String get actionDelete => '刪除';

  @override
  String get settingsProfileConfigTitle => '個人檔案設定';

  @override
  String get settingsMyDataTitle => '我的資料';

  @override
  String get settingsPatientNameLabel => '患者姓名';

  @override
  String get settingsConditionsLabel => '共病/診斷';

  @override
  String get settingsRelationshipLabel => '與此檔案的關係';

  @override
  String get settingsLifeEventsLabel => '生活事件';

  @override
  String get settingsLocationLabel => '我的位置(用於天氣)';

  @override
  String get settingsConditionsHelper => '點 × 移除一項條件。若要閱讀說明,請前往 臨床→指南。';

  @override
  String get settingsRelationshipHelper => '此檔案是給誰使用的?如果你在為照顧的人記錄,這很實用。';

  @override
  String get settingsLifeEventsHelper =>
      '可能影響你身體或心情的事件:旅行、意外、搬家、好的或有壓力的事件。它們會在日曆上顯示為紫色圓點。';

  @override
  String get settingsDataHelper => '你有權隨時存取、匯出、匯入或刪除你的資料。';

  @override
  String get settingsWipeAllHelper => '此操作會刪除所有檔案、記錄和設定。無法復原。';

  @override
  String get settingsRelationshipSelf => '我自己';

  @override
  String get settingsRelationshipChild => '我的小孩';

  @override
  String get settingsRelationshipPartner => '我的伴侶';

  @override
  String get settingsRelationshipParent => '我的父母';

  @override
  String get settingsRelationshipOther => '其他';

  @override
  String get settingsRelationshipNone => '— 未指定 —';

  @override
  String get settingsLifeEventsEmpty => '還沒有記錄任何事件。';

  @override
  String get settingsAddEventButton => '新增事件';

  @override
  String get settingsLocationNone => '未設定位置。點此新增。';

  @override
  String get settingsLocationButtonAdd => '新增座標';

  @override
  String get settingsLocationButtonEdit => '編輯座標';

  @override
  String get settingsAddProfileButton => '新增個人檔案';

  @override
  String get settingsDeleteProfileButton => '刪除此個人檔案';

  @override
  String get settingsExportDataButton => '匯出我的資料';

  @override
  String get settingsWipeAllButton => '全部刪除';

  @override
  String settingsNewProfileNameTemplate(int number) {
    return '新檔案 $number';
  }

  @override
  String get dialogWipeTitle => '刪除所有資料';

  @override
  String get dialogWipeContent => '此操作會刪除所有個人檔案、記錄、設定和快取。無法復原。\n\n要先匯出嗎?';

  @override
  String get dialogWipeFinalTitle => '最後確認';

  @override
  String dialogWipeFinalContentTemplate(String magicWord) {
    return '輸入 $magicWord 以確認。';
  }

  @override
  String get dialogWipeFinalMagicWord => '刪除';

  @override
  String get dialogWipeFinalButton => '全部刪除';

  @override
  String get dialogDeleteProfileTitle => '刪除個人檔案';

  @override
  String dialogDeleteProfileContentTemplate(String name) {
    return '確定要刪除個人檔案「$name」以及所有相關資料?此操作無法復原。';
  }

  @override
  String get dialogLocationTitle => '你的位置';

  @override
  String get dialogLocationContent =>
      '需要緯度和經度才能取得天氣資訊。在 Google 地圖找到你的城市,右鍵→複製座標。';

  @override
  String get dialogLocationHintLat => '緯度(例: -34.61)';

  @override
  String get dialogLocationHintLng => '經度(例: -58.38)';

  @override
  String get dialogLocationInvalidSnack => '座標無效。';

  @override
  String get therapyHintArea => '部位(例:頸部)';

  @override
  String get therapySectionPainBefore => '治療前疼痛';

  @override
  String get therapySectionPainAfter => '治療後疼痛';

  @override
  String get therapyActionMoreDetails => '多細節(治療師、費用、備註)';

  @override
  String get therapyHintTherapist => '治療師/地點(選填)';

  @override
  String get therapyHintCost => '費用(選填)';

  @override
  String get therapyHintNote => '備註(選填)';

  @override
  String get therapyActionSaveChanges => '儲存變更';

  @override
  String get therapyActionLog => '記錄';

  @override
  String get compendiumSectionConditionsHeader => '我的疾病';

  @override
  String get compendiumSectionConditionsSubtitle =>
      '點一個閱讀臨床資訊(來源:MedlinePlus)。';

  @override
  String compendiumSavedArticlesTemplate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已儲存 $count 篇文章',
    );
    return '$_temp0 — 前往研究。';
  }

  @override
  String get compendiumSectionDataTitle => '臨床資料';

  @override
  String get compendiumFactSourceLabel => '來源:';

  @override
  String investigationConditionArticleCountTemplate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 篇文章',
    );
    return '$_temp0';
  }

  @override
  String get headacheSheetTitle => '頭痛詳細資料';

  @override
  String get headacheSheetSubtitle => '標記適用的項目。如果你願意,可以跳過此步驟。';

  @override
  String get actionSkip => '跳過';

  @override
  String get headacheActionSaveDetail => '儲存詳細資料';

  @override
  String get headacheThunderclapWarningTitle => '可能的緊急情況';

  @override
  String get headacheThunderclapWarningConfirm => '我了解,繼續';

  @override
  String get headacheAdvisoryDialogTitle => '需要注意的模式';

  @override
  String get headacheRedFlagCsfLeakAdvisory =>
      '你的頭痛在站立時明顯加劇。這種模式可能表明腦脊液漏,在 EDS 患者中尤其常見。如果反覆出現,建議告知你的醫生。';

  @override
  String get headacheRedFlagIntracranialAdvisory =>
      '你的頭痛在躺下時加劇。這種模式可能表明顱內壓升高。如果反覆出現或伴隨視覺變化,建議就醫評估。';

  @override
  String get settingsModuleHeadacheDetailLabel => '頭痛詳細資料';

  @override
  String get settingsModuleHeadacheDetailDescription => '登錄頭痛時記錄位置、性質和其他模式。';

  @override
  String get fatigueSheetTitle => '疲勞細節';

  @override
  String get fatigueSheetSubtitle => '選填的細節有助於識別模式。';

  @override
  String get fatigueActionSaveDetail => '儲存細節';

  @override
  String get fatigueAdvisoryDialogTitle => '檢測到的模式';

  @override
  String get fatigueRedFlagPemAdvisory =>
      '這個模式顯示你的疲勞在勞累後1-3天出現。這可能表示你的身體能量儲備比平常少,需要更多天才能恢復。如果反覆出現,建議告知你的醫師。';

  @override
  String get fatigueRedFlagOrthostaticAdvisory =>
      '你的疲勞在站立或直坐時加劇。這可能表示你的身體在直立時難以維持穩定的血壓或脈搏。這在EDS患者中很常見。建議告知你的醫師。';

  @override
  String get fatigueRedFlagHpaAdvisory =>
      '你的身體感覺筋疲力盡但無法休息。這可能表示你的壓力系統已被啟動很長時間,調節休息的荷爾蒙失衡。建議告知你的醫師。';

  @override
  String get settingsModuleFatigueDetailLabel => '疲勞細節';

  @override
  String get settingsModuleFatigueDetailDescription => '記錄疲勞時,追蹤類型、時間模式和伴隨症狀。';

  @override
  String get abdominalSheetTitle => '腹痛細節';

  @override
  String get abdominalSheetSubtitle => '選填的細節有助於識別模式。';

  @override
  String get abdominalActionSaveDetail => '儲存細節';

  @override
  String get abdominalTearingEmergencyTitle => '撕裂型疼痛';

  @override
  String get abdominalTearingEmergencyBody =>
      '突發的極度劇烈撕裂型疼痛在Ehlers-Danlos症候群患者中可能表示醫療急症。建議你現在就去急診以排除動脈或腸道破裂。\n\n如果你去,請告知醫療團隊你的clEDS診斷(類典型Ehlers-Danlos症候群,由TNXB基因突變引起)。\n\n如果疼痛已顯著改善,你不再認為它是撕裂感,你可以更改疼痛性質並正常儲存記錄。';

  @override
  String get abdominalTearingEmergencyChangeQuality => '更改性質並儲存';

  @override
  String get abdominalTearingEmergencySaveAsIs => '照原樣儲存(急症)';

  @override
  String get abdominalAdvisoryDialogTitle => '檢測到的模式';

  @override
  String get abdominalRedFlagMassiveHematocheziaUrgent =>
      '這個模式(糞便帶血伴隨噁心或嘔吐和劇烈疼痛)可能表示活動性GI出血。若出血量多或你注意到明顯虛弱或頭暈,請立即就醫。';

  @override
  String get abdominalRedFlagHematemesisUrgent =>
      '在你的備註中提到嘔血。此症狀表示上消化道出血,需立即急診評估。';

  @override
  String get abdominalRedFlagNocturnalPainAdvisory =>
      '你的疼痛在夜間將你喚醒。這是值得告訴你的醫生的警示訊號,尤其若你注意到非自願性體重減輕或發燒。';

  @override
  String get abdominalRedFlagGastroparesisAdvisory =>
      '你的疼痛在剛進食時出現且很快感到飽足。這個模式可能表示你的胃排空比正常慢。在伴隨自主神經功能障礙的EDS患者中常見。值得告訴你的醫生。';

  @override
  String get settingsModuleAbdominalDetailLabel => '腹痛細節';

  @override
  String get settingsModuleAbdominalDetailDescription =>
      '記錄疼痛、腹脹或排氣時,追蹤位置、性質、時間關係和伴隨症狀。';

  @override
  String get bowelToAbdominalPromptTitle => '記錄疼痛細節?';

  @override
  String get bowelToAbdominalPromptBody => '你將此事件標記為伴隨腹痛。現在記錄細節以幫助識別模式?';

  @override
  String get abdominalToBowelPromptTitle => '與排便有關?';

  @override
  String abdominalToBowelPromptBody(String time) {
    return '你將此疼痛標記為與排便有關。你記錄了 $time 的一次排便。是同一次嗎?';
  }

  @override
  String get abdominalIntegrationYes => '是';

  @override
  String get abdominalIntegrationNo => '否';

  @override
  String get abdominalIntegrationDontKnow => '我不知道';

  @override
  String get onboardingStepMedsUnitHint => '1';

  @override
  String get onboardingStepMedsStrengthHint => 'mg';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get navHoy => '今天';

  @override
  String get navSintomas => '症狀';

  @override
  String get navMovimiento => '活動量';

  @override
  String get navBotiquin => '藥箱';

  @override
  String get navClinica => '診所';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '儲存';

  @override
  String get actionImport => '匯入';

  @override
  String get actionContinue => '繼續';

  @override
  String get actionUnderstood => '知道了';

  @override
  String get languageSectionTitle => '語言 / LANGUAGE';

  @override
  String get languageFootnote => '語言設定將套用至整個應用程式。您的資料不會改變。';

  @override
  String get myDataTitle => '我的資料';

  @override
  String get arcoRightsBlurb => '您有權隨時存取、匯出、匯入或刪除您的資料。';

  @override
  String get exportDataButton => '匯出我的資料';

  @override
  String get importFileButton => '從檔案匯入';

  @override
  String get importPasteButton => '貼上文字匯入';

  @override
  String get wipeAllButton => '清除所有資料';

  @override
  String get wipeWarningFootnote => '此操作將清除所有個人檔案、紀錄與設定。此動作無法復原。';

  @override
  String exportSuccess(String filename) {
    return '資料已匯出：$filename';
  }

  @override
  String exportError(String reason) {
    return '匯出失敗：$reason';
  }

  @override
  String importCancelled(String reason) {
    return '匯入已取消：$reason';
  }

  @override
  String get importSuccess => '個人檔案已成功匯入。';

  @override
  String get importDialogTitle => '匯入此個人檔案';

  @override
  String importDialogName(String name) {
    return '姓名：$name';
  }

  @override
  String importDialogExportedAt(String date) {
    return '匯出時間：$date';
  }

  @override
  String importDialogContains(int count) {
    return '內含 $count 筆紀錄：';
  }

  @override
  String get importDialogFootnote => '這將作為新的個人檔案新增。您目前的個人檔案不會被刪除。';

  @override
  String get nounSymptoms => '症狀';

  @override
  String get nounDoses => '劑量';

  @override
  String get nounStructural => '結構事件';

  @override
  String get nounActivities => '活動';

  @override
  String get nounTherapies => '治療';

  @override
  String get nounMoods => '情緒';

  @override
  String get nounMental => '心理紀錄';

  @override
  String get pasteImportTitle => '貼上文字匯入';

  @override
  String get pasteImportInstructions =>
      '打開您匯出的 .json 檔案（例如透過「檔案」App），選取所有文字並複製，然後貼到此處。';

  @override
  String get pasteImportHint => '請在此處貼上檔案內容...';

  @override
  String get errImportUnreadable => '無法讀取檔案。';

  @override
  String get errImportInvalidJson => '文字非有效的 JSON 格式。';

  @override
  String get errImportNotZebra => '此檔案似乎不屬於 ZebraUpp。';

  @override
  String get errImportUnknownSchema => '未知的結構版本 (Schema Version)。';

  @override
  String errImportSchemaMismatch(String found, String expected) {
    return '此檔案版本不符 (發現 v$found)。預期版本：v$expected。';
  }

  @override
  String get errImportMissingProfile => '檔案中找不到個人檔案。';

  @override
  String get errImportCorruptProfile => '個人檔案已損壞或格式異常。';

  @override
  String get actionHide => '隱藏';

  @override
  String get hintTapTip => '提示：在「症狀」中，點擊庫存中的標籤即可紀錄。長按某條紀錄可進行編輯。';

  @override
  String get sectionPending => '待辦事項';

  @override
  String get sectionWeather => '今日天氣';

  @override
  String get headerTodayIs => '今天是';

  @override
  String get pacingActiveState => '休息日 — 給自己放個假';

  @override
  String get pacingInactiveState => '標記為休息日';

  @override
  String outcomeCardTimePrefix(String hours) {
    return '$hours 小時前您服用了';
  }

  @override
  String get outcomeCardForSymptom => '以緩解您的';

  @override
  String get outcomeCardInitialState => '當時狀態為 ';

  @override
  String get outcomeCardQuestionNow => '現在感覺如何？';

  @override
  String get outcomeCardAttributionQuestion => '您認為原因是什麼？';

  @override
  String get outcomeActionAddFactor => '其他因素';

  @override
  String get sectionMentalDetails => '心理細節';

  @override
  String get mentalIntensitySubtitle => '目前的強烈程度';

  @override
  String get summaryTitle => '今日簡短總結';

  @override
  String get summaryEmptyPacing => '🛡️ 休息日。您今天還沒有紀錄任何內容 — 這很好。';

  @override
  String get summaryEmptyNormal => '您今天還沒有紀錄任何內容。一切都還好嗎？';

  @override
  String summarySymptomSingle(String name, String label) {
    return '您紀錄了 1 個症狀：$name ($label)。';
  }

  @override
  String summarySymptomPlural(int count, String name, String label) {
    return '您紀錄了 $count 個症狀 — 最強烈的是 $name ($label)。';
  }

  @override
  String summaryStructuralSingle(String zone) {
    return '您在 $zone 發生了 1 次結構事件。';
  }

  @override
  String summaryStructuralPlural(int count) {
    return '您今天發生了 $count 次結構事件。';
  }

  @override
  String summaryDosesSentence(int totalDoses, String shown, int extraCount) {
    String _temp0 = intl.Intl.pluralLogic(
      extraCount,
      locale: localeName,
      other: '，以及其他 $extraCount 次',
      zero: '',
    );
    return '您服用了 $totalDoses 次劑量：$shown$_temp0。';
  }

  @override
  String summaryMoodSentence(String statesStr, String extra) {
    return '您紀錄的心情與感受：$statesStr$extra。';
  }

  @override
  String get summaryPacingFooter => '🛡️ 您允許了自己好好休息。這也很重要。';

  @override
  String get wisdomBannerTitle => '✨ 斑馬智慧 🦓';

  @override
  String get bowelCountToday => '最近一次排便：今天';

  @override
  String get bowelCountYesterday => '最近一次排便：昨天';

  @override
  String bowelCountDaysAgo(int days) {
    return '最近一次排便：$days 天前';
  }

  @override
  String distentionBannerMessage(int days) {
    return '您已經 $days 天沒有排便了 — 腹脹與腹痛症狀可能會開始累積。';
  }

  @override
  String get distentionBannerAction => '前往「症狀」';

  @override
  String get severityNone => '無';

  @override
  String get severityMild => '輕度';

  @override
  String get severityModerate => '中度';

  @override
  String get severityIntense => '重度';

  @override
  String get severityUnbearable => '無法忍受';

  @override
  String get reasonNatural => '症狀的自然轉變';

  @override
  String get reasonMedicationHelped => '我覺得這款藥物有幫助';

  @override
  String get reasonOtherTrigger => '其他誘發因素（食物、壓力、天氣...）';

  @override
  String get reasonAdditionalMed => '我也服用了其他藥物';

  @override
  String get reasonUnsure => '無法完全確定';

  @override
  String get mentalStateMood => '情緒';

  @override
  String get mentalStateAnxiety => '焦慮';

  @override
  String get mentalStateBrainFog => '腦霧';

  @override
  String get mentalStateDissociation => '解離感';

  @override
  String get mentalStateIrritability => '易怒';

  @override
  String get mentalStateEmotionalEnergy => '情感能量';

  @override
  String get outcomeCoarsePending => '待定';

  @override
  String get outcomeCoarseMuchBetter => '好很多';

  @override
  String get outcomeCoarseBetter => '較好';

  @override
  String get outcomeCoarseEqual => '沒變化';

  @override
  String get outcomeCoarseWorse => '變差';

  @override
  String get outcomeCoarseMuchWorse => '變差很多';

  @override
  String get pubMedNoAuthor => '未登記作者';

  @override
  String get quadrantActivatedUnpleasant => '亢奮 · 不適';

  @override
  String get quadrantActivatedPleasant => '亢奮 · 舒適';

  @override
  String get quadrantCalmUnpleasant => '平靜 · 不適';

  @override
  String get quadrantCalpleasant => '平靜 · 舒適';

  @override
  String get quadrantTeaserActivatedUnpleasant => '緊繃、焦慮';

  @override
  String get quadrantTeaserActivatedPleasant => '活力、喜悅';

  @override
  String get quadrantTeaserCalmUnpleasant => '精疲力竭、沮喪';

  @override
  String get quadrantTeaserCalmPleasant => '放鬆、寧靜';

  @override
  String get bowelBucketConstipation => '便秘';

  @override
  String get bowelBucketNormal => '正常';

  @override
  String get bowelBucketDiarrhea => '腹瀉';

  @override
  String get sleepQualityBad => '差';

  @override
  String get sleepQualityRegular => '普通';

  @override
  String get sleepQualityGood => '好';

  @override
  String get sleepQualityVeryGood => '很好';

  @override
  String get beverageWater => '水';

  @override
  String get beverageElectrolyte => '電解質液';

  @override
  String get beverageCoffee => '咖啡';

  @override
  String get beverageOther => '其他';

  @override
  String get sodiumPinch => '一小撮鹽';

  @override
  String get sodiumSachet => '電解質粉包';

  @override
  String get sodiumSaltySnack => '鹹味點心';

  @override
  String get hrvContextMorning => '晨間';

  @override
  String get hrvContextAfternoon => '午後';

  @override
  String get hrvContextEvening => '晚間';

  @override
  String get hrvContextPostExercise => '運動後';

  @override
  String get hrvContextOther => '其他';

  @override
  String legacyIntensityLabel(String value) {
    return '先前的強烈程度：$value/5';
  }

  @override
  String get botiquinTabTitle => '您的藥箱';

  @override
  String get botiquinActionCreate => '新增藥物';

  @override
  String get botiquinSearchHint => '搜尋藥物...';

  @override
  String get botiquinSearchNoResults => '找不到藥物';

  @override
  String get botiquinInteractionsTitle => '偵測到藥物交互作用';

  @override
  String get botiquinGroupsTitle => '群組';

  @override
  String get botiquinGroupsEmptyHeadline => '🌙 夜間藥物 · ☀️ 晨間藥物';

  @override
  String get botiquinGroupsEmptyBody => '將您需要同時服用的藥物分組。一鍵即可同時紀錄所有劑量。';

  @override
  String get botiquinActionCreateGroup => '建立群組';

  @override
  String get botiquinNoMedsDialogTitle => '無藥物';

  @override
  String get botiquinNoMedsDialogBody => '在建立群組前，請先在藥箱中至少新增一種藥物。';

  @override
  String botiquinRowMedsCountLabel(int count) {
    return '$count 種藥物';
  }

  @override
  String get botiquinActionEditTooltip => '編輯';

  @override
  String get botiquinBatchSheetTitle => '紀錄群組藥物';

  @override
  String get botiquinBatchSheetSubtitle => '將紀錄以下劑量：';

  @override
  String botiquinBatchOrphanWarning(int count) {
    return '⚠️ 藥箱中有 $count 種藥物已被刪除 — 將會自動跳過。';
  }

  @override
  String botiquinBatchActionSubmit(int count) {
    return '紀錄 $count 次劑量';
  }

  @override
  String get botiquinEmptyStateHeadline => '您尚未新增任何藥物';

  @override
  String get botiquinEmptyStateSubtitle => '請使用下方的按鈕新增藥物。';

  @override
  String botiquinDoseLoggedTodayBadge(String qty) {
    return '今天已服用 $qty';
  }

  @override
  String botiquinDeleteConfirmTitle(String name) {
    return '刪除 $name？';
  }

  @override
  String botiquinDeleteConfirmBody(String name) {
    return '系統將會保留劑量歷史紀錄以供報告使用，但 $name 將會自您的藥箱中移除。';
  }

  @override
  String get botiquinActionDelete => '刪除';

  @override
  String get botiquinLogDoseSheetTitle => '紀錄劑量';

  @override
  String botiquinLogDoseTotalCalculated(String total, String unit) {
    return '= 總計 $total $unit';
  }

  @override
  String get botiquinLogDoseSymptomPrompt => '是為了解緩某個特定症狀嗎？';

  @override
  String get botiquinLogDoseSymptomNone => '無';

  @override
  String botiquinLogDoseTrackOutcomeToggle(int hours) {
    return '在 $hours 小時後詢問是否有效';
  }

  @override
  String get botiquinDoseListTitle => '今天的劑量紀錄';

  @override
  String get botiquinDoseListFootnote => '點擊 × 可刪除特定的劑量（若名稱紀錄錯誤時非常實用）。';

  @override
  String get botiquinDoseItemDeleteConfirmTitle => '刪除此劑量';

  @override
  String botiquinDoseItemDeleteConfirmBody(String name, String time) {
    return '確定要刪除在 $time 紀錄的 $name 劑量嗎？此操作無法撤銷。';
  }

  @override
  String botiquinTimeTodayAt(String time) {
    return '今天 $time';
  }

  @override
  String botiquinTimePastAt(int day, int month, String time) {
    return '$month/$day $time';
  }

  @override
  String get onboardingActionBack => '返回';

  @override
  String get onboardingActionSkip => '跳過';

  @override
  String get onboardingActionNext => '下一步';

  @override
  String get onboardingActionFinish => '開始使用';

  @override
  String get onboardingFallbackProfileName => '我的個人檔案';

  @override
  String get onboardingStepWelcomeTitle => 'ZebraUp';

  @override
  String get onboardingStepWelcomeSubtitle => '您的就醫看診神助手。';

  @override
  String get onboardingStepWelcomeBody =>
      '看診時間總是短暫。在度過艱難的一週後，人的記憶力也是。ZebraUp 能幫您紀錄症狀、用藥和身體規律，讓您每次看診時都能帶著具體的數據報告，而不是在坐在醫生面前後，腦袋一片空白、只剩零星片斷的模糊描述。此外，我們知道您可能還需要照顧他人，因此您也可以在此新增家人或寵物。';

  @override
  String get onboardingStepWelcomePrivacyNote =>
      '您的所有資料均儲存在本裝置中。我們不會將任何內容上傳至網路。';

  @override
  String get onboardingStepWelcomeMedicalDisclaimer =>
      '本應用程式並非醫療器材。它不具備診斷、治療、緩解、治癒或預防任何醫療狀況的功能。';

  @override
  String get onboardingStepNameTitle => '讓我們開始吧。';

  @override
  String get onboardingStepNameQuestion => '我們該如何稱呼您？';

  @override
  String get onboardingStepNameFootnote => '僅用於個人化應用程式介面。您稍後可以隨時更改。';

  @override
  String get onboardingStepNameHint => '您的名字或暱稱';

  @override
  String get onboardingStepConditionsTitle => '您的確診狀況。';

  @override
  String get onboardingStepConditionsBody =>
      '您目前有哪些疾病或健康狀況？我們將用這些資訊來輔助說明藥物交互作用和報告。您可以新增、編輯或跳過此步驟。';

  @override
  String get onboardingStepConditionsHint => '例如：hEDS、POTS、MCAS...';

  @override
  String get onboardingStepConditionsEmpty => '尚未新增任何項目。您可以跳過此步驟。';

  @override
  String get onboardingStepMedsTitle => '您的藥箱。';

  @override
  String get onboardingStepMedsBody =>
      '新增您定期服用的藥物。之後您只需在「藥箱」標籤頁中點擊一下，即可快速紀錄每次服藥劑量。';

  @override
  String get onboardingStepMedsNameHint => '藥物名稱';

  @override
  String get onboardingStepMedsDoseHint => '劑量（例如：400mg）';

  @override
  String get onboardingStepMedsEmpty => '目前沒有藥物。您可以跳過此步驟。';

  @override
  String get symptomsSectionStructuralZones => '結構區域';

  @override
  String get symptomsSectionBowelTransit => '腸道蠕動';

  @override
  String get symptomsActionAddHemorrhoid => '痔瘡';

  @override
  String get symptomsSectionTodaysLogs => '今天的紀錄';

  @override
  String get symptomsFootnoteLongPressEdit => '長按某條紀錄可編輯日期、嚴重程度或備註。';

  @override
  String get symptomsSectionTrending => '近期趨勢（過去 7 天）';

  @override
  String get symptomsTrendingEmpty => '本週沒有持續出現的症狀。';

  @override
  String get symptomsSectionVault => '症狀庫存';

  @override
  String get symptomsVaultPlaceholder => '+ 將症狀新增至庫存...';

  @override
  String symptomsModalLogHeader(String zone) {
    return '紀錄於：$zone';
  }

  @override
  String symptomsModalEditHeader(String zone, String type) {
    return '編輯：$zone / $type';
  }

  @override
  String symptomsModalEditSymptomHeader(String name) {
    return '編輯：$name';
  }

  @override
  String get symptomsLabelOptionalNote => '選填備註（情境、誘發原因等）';

  @override
  String get symptomsLabelOptionalNoteSimple => '選填備註';

  @override
  String get symptomsLabelSeverityGrading => '嚴重程度';

  @override
  String get symptomsActionLogUnrated => '不評分直接紀錄';

  @override
  String get symptomsUnratedLabelSuffix => '未評分';

  @override
  String get symptomsUnratedInlineWarning => '此紀錄尚無評分。點擊節點來指定一個級別。';

  @override
  String get symptomsActionSaveChanges => '儲存變更';

  @override
  String get symptomsActionSave => '儲存';

  @override
  String get zoneCervical => '頸椎';

  @override
  String get zoneHombros => '肩膀';

  @override
  String get zoneMunecas => '手腕';

  @override
  String get zoneManos => '手部';

  @override
  String get zoneLumbarPelvis => '腰椎/骨盆';

  @override
  String get zoneCaderas => '髖關節';

  @override
  String get zoneRodillas => '膝關節';

  @override
  String get zoneTobillos => '腳踝';

  @override
  String get structTypeSubluxation => '半脫位';

  @override
  String get structTypeDislocation => '脫位（脫臼）';

  @override
  String get structTypeInstability => '關節不穩定';

  @override
  String get structTypeJointPain => '關節疼痛';

  @override
  String get structTypeMyofascial => '肌筋膜疼痛';

  @override
  String get structTypeNeuropathic => '神經性疼痛';

  @override
  String bowelLabelBristolType(String type) {
    return '布里斯托第 $type 型';
  }

  @override
  String get bowelLabelUrgency => '急迫感';

  @override
  String get bowelLabelBleeding => '出血';

  @override
  String get bowelLabelIncomplete => '排不乾淨';

  @override
  String get movementSectionPacingActive => '今天是休息日。好好休息也是一種進展。';

  @override
  String get movementSectionHistoryTitle => '今天您做了...';

  @override
  String get movementFootnoteLongPressEdit => '長按紀錄即可進行編輯。';

  @override
  String get movementEmptyStateHeadline => '活動與復原同樣重要。';

  @override
  String get movementEmptyStateSubtitle => '散步、伸展、物理治療、按摩 — 這些都是照顧身體的一部分。';

  @override
  String get movementSectionActivityTitle => '活動';

  @override
  String get movementActivityPlaceholder => '+ 新增活動（游泳、單車、舞蹈...）';

  @override
  String get movementSectionTherapyTitle => '治療與調理';

  @override
  String get movementTherapyPlaceholder => '+ 新增項目（靈氣、漂浮舒壓...）';

  @override
  String activityModalLogHeader(String name) {
    return '紀錄：$name';
  }

  @override
  String activityModalEditHeader(String name) {
    return '編輯：$name';
  }

  @override
  String get activityFieldDurationHint => '時長（分鐘）';

  @override
  String get activityFieldSetsHint => '組數';

  @override
  String get activityFieldRepsHint => '次數';

  @override
  String get activityFieldHhrHint => '選填心率（例如：70→110）';

  @override
  String activityLabelEffortSlider(int value) {
    return '自覺強度：$value/10';
  }

  @override
  String activityLabelFeelingSlider(int value) {
    return '身體感受：$value/5';
  }

  @override
  String get activityActionTogglePainRating => '評估活動前/後疼痛（選填）';

  @override
  String get activityLabelPainBefore => '活動前疼痛';

  @override
  String get activityLabelPainAfter => '活動後疼痛';

  @override
  String get activityActionSubmitLog => '儲存活動';

  @override
  String get activityActionSubmitChanges => '儲存變更';

  @override
  String get painLabelNone => '無痛';

  @override
  String get painLabelMild => '輕微';

  @override
  String get painLabelModerate => '中度';

  @override
  String get painLabelIntense => '強烈';

  @override
  String get painLabelSevere => '嚴重';

  @override
  String painDeltaLabelImproved(int count) {
    return '您的疼痛減輕了 $count 個層級';
  }

  @override
  String painDeltaLabelWorsened(int count) {
    return '您的疼痛加劇了 $count 個層級';
  }

  @override
  String get painDeltaLabelUnchanged => '無變化';

  @override
  String logSubtitleMetricDuration(int minutes) {
    return '$minutes 分鐘';
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
    return '$detail · 強度 $effort/10 · 感受 $feeling/5$painSuffix';
  }

  @override
  String logSubtitlePainDeltaImproved(int levels) {
    return '↓$levels 級';
  }

  @override
  String logSubtitlePainDeltaWorsened(int levels) {
    return '↑$levels 級';
  }

  @override
  String get logSubtitlePainDeltaUnchanged => '無變化';

  @override
  String get feelingLabelLevel1 => '🤕 疼痛不適 / 受傷';

  @override
  String get feelingLabelLevel2 => '😟 不舒服 / 令人擔憂';

  @override
  String get feelingLabelLevel3 => '😐 平常心 / 無感';

  @override
  String get feelingLabelLevel4 => '😊 輕鬆舒適';

  @override
  String get feelingLabelLevel5 => '💪 充滿力量與安全感';

  @override
  String get onboardingHaveProfileTitle => '我已經有儲存的個人檔案';

  @override
  String get onboardingHaveProfileSubtitle => '從 JSON 檔案匯入';

  @override
  String get onboardingImportChoiceTitle => '要如何匯入？';

  @override
  String get onboardingImportFromFile => '從檔案匯入';

  @override
  String get onboardingImportFromPaste => '貼上文字';

  @override
  String get feverSectionTitle => '發燒紀錄';

  @override
  String get feverActionAddReading => '+ 量測體溫';

  @override
  String get feverModalLogHeader => '紀錄體溫';

  @override
  String get feverModalEditHeader => '編輯體溫紀錄';

  @override
  String get feverFieldSiteLabel => '量測部位';

  @override
  String get feverFieldAntipyreticLabel => '退燒藥';

  @override
  String get feverFieldAntipyreticToggle => '已服用退燒藥物';

  @override
  String get feverFieldAntipyreticNameHint => '藥物名稱（普拿疼、布洛芬等）';

  @override
  String get feverHintTapToEdit => '點擊數字即可進行編輯';

  @override
  String get feverDirectEditDialogTitle => '編輯體溫';

  @override
  String get feverDirectEditDialogHint => '例如：38.7';

  @override
  String get feverLogLabelWithAntipyretic => '含退燒藥';

  @override
  String get feverSiteAxillary => '腋溫';

  @override
  String get feverSiteOral => '口溫';

  @override
  String get feverSiteTympanic => '耳溫';

  @override
  String get feverSiteRectal => '肛溫';

  @override
  String get feverSiteForehead => '額溫';

  @override
  String timeAgoMinutes(int minutes) {
    return '$minutes 分鐘前';
  }

  @override
  String timeAgoHours(int hours) {
    return '$hours 小時前';
  }

  @override
  String get researchEmptyConfig => '請在設定中新增您的診斷狀況，以查看相關的醫學研究。';

  @override
  String get researchTitleRecent => 'PubMed 最新研究結果';

  @override
  String get researchDisclaimer => '向下滑動可重新整理。僅供參考，不構成醫療建議。';

  @override
  String get researchTooltipOffline => '已儲存的結果（離線模式）';

  @override
  String get researchStateNoData => '暫無資料。向下滑動以進行搜尋。';

  @override
  String get researchStateNoResults => '未找到近期的相關結果。';

  @override
  String researchLastUpdated(String time) {
    return '更新時間：$time';
  }

  @override
  String get researchActionSaved => '已儲存';

  @override
  String get researchActionSave => '儲存';

  @override
  String get researchActionOpenPubMed => '在 PubMed 中開啟';

  @override
  String get researchActionCopyPmid => '複製 PMID';

  @override
  String researchSnackPmidCopied(String pmid) {
    return 'PMID $pmid 已複製。';
  }

  @override
  String get researchLoadingAbstract => '正在載入摘要...';

  @override
  String get researchEmptyAbstract => '暫無摘要。請在 PubMed 中打開文章以獲取更多詳細資訊。';

  @override
  String get reportRangeDay => '1 天';

  @override
  String get reportRangeWeek => '7 天';

  @override
  String get reportRangeMonth => '30 天';

  @override
  String get reportRangeCustomTooltip => '自訂範圍';

  @override
  String reportRangeCustomActiveLabel(String start, String end) {
    return '範圍：$start → $end';
  }

  @override
  String get structKindJoint => '關節';

  @override
  String get structKindMuscle => '肌肉';

  @override
  String get structKindTendon => '肌腱';

  @override
  String get structKindLigament => '韌帶';

  @override
  String get structKindSoftTissue => '軟組織';

  @override
  String get structKindNerve => '神經';

  @override
  String get structTypeMuscleStrain => '肌肉拉傷';

  @override
  String get structTypeMuscleDistension => '肌肉挫傷';

  @override
  String get structTypeMuscleTear => '肌肉撕裂傷';

  @override
  String get structTypeContracture => '肌肉攣縮';

  @override
  String get structTypeMuscleSpasm => '肌肉痙攣（抽筋）';

  @override
  String get structTypeTendinitis => '肌腱炎';

  @override
  String get structTypeTendinosis => '肌腱變性';

  @override
  String get structTypeBursitis => '滑囊炎';

  @override
  String get structTypeEnthesitis => '附著點炎';

  @override
  String get structTypeTendonFissure => '肌腱裂傷';

  @override
  String get structTypeMildSprain => '輕度扭傷';

  @override
  String get structTypeSevereSprain => '嚴重扭傷';

  @override
  String get structTypeLigamentTear => '韌帶撕裂';

  @override
  String get structTypeSuperficialCut => '表淺割傷';

  @override
  String get structTypeSkinFissure => '皮膚裂傷';

  @override
  String get structTypeDeepWound => '深層傷口';

  @override
  String get structTypeHematoma => '血腫';

  @override
  String get structTypeContusion => '挫傷（瘀青）';

  @override
  String get structTypeBurn => '燒燙傷';

  @override
  String get structTypeAbrasion => '擦傷';

  @override
  String get structTypeParesthesia => '感覺異常（發麻）';

  @override
  String get sleepSectionTitle => '睡眠紀錄';

  @override
  String get sleepActionAddEntry => '+ 紀錄睡眠';

  @override
  String get sleepModalLogHeader => '紀錄睡眠';

  @override
  String get sleepModalEditHeader => '編輯睡眠紀錄';

  @override
  String get sleepFieldQualityLabel => '睡眠品質';

  @override
  String get sleepFieldDurationLabel => '睡眠時長';

  @override
  String get sleepFieldDurationHint => '小時（例如：7.5）';

  @override
  String get sleepFieldOnsetLatencyLabel => '入睡所需時間';

  @override
  String get sleepFieldOnsetLatencyHint => '分鐘';

  @override
  String get sleepFieldWakeCountLabel => '醒來次數';

  @override
  String get sleepFieldNightmareToggle => '做惡夢';

  @override
  String get sleepLogLabelSlept => '睡眠時間';

  @override
  String sleepLogLabelHours(String hours) {
    return '$hours 小時';
  }

  @override
  String sleepLogLabelWakes(int count) {
    return '醒來 $count 次';
  }

  @override
  String sleepLogLabelOnsetLatency(int minutes) {
    return '花費 $minutes 分鐘入睡';
  }

  @override
  String get sleepLogLabelWithNightmare => '惡夢';

  @override
  String get settingsOptionalModulesTitle => '選配功能模組';

  @override
  String get settingsOptionalModulesBlurb => '僅啟用您想要追蹤的項目。關閉的模組將不會出現在「症狀」功能中。';

  @override
  String get settingsModuleSleepLabel => '睡眠';

  @override
  String get settingsModuleSleepDescription => '追蹤每晚的睡眠品質、時長與夜醒次數。';

  @override
  String get bodyRegionHeadNeck => '頭部與頸部';

  @override
  String get bodyRegionShouldersUpperBack => '肩膀與上背部';

  @override
  String get bodyRegionArms => '手臂';

  @override
  String get bodyRegionChestAbdomen => '胸部與腹部';

  @override
  String get bodyRegionLowerBackPelvis => '下背部與骨盆';

  @override
  String get bodyRegionLegs => '腿部';

  @override
  String get zoneJaw => '下顎';

  @override
  String get zoneTemple => '太陽穴';

  @override
  String get zoneShoulderBlades => '肩胛骨';

  @override
  String get zoneUpperBack => '上背部';

  @override
  String get zoneUpperArm => '上臂';

  @override
  String get zoneElbow => '手肘';

  @override
  String get zoneForearm => '前臂';

  @override
  String get zoneChest => '胸部';

  @override
  String get zoneSide => '側腹 / 身體側邊';

  @override
  String get zoneRibs => '肋骨';

  @override
  String get zoneAbdomen => '腹部';

  @override
  String get zoneGlutes => '臀大肌';

  @override
  String get zoneFrontThigh => '大腿前側';

  @override
  String get zoneBackThigh => '大腿後側';

  @override
  String get zoneCalf => '小腿';

  @override
  String get zoneFeet => '雙腳';

  @override
  String get hydrationSectionTitle => '水分補充';

  @override
  String get hydrationActionAddEntry => '+ 紀錄水分補充';

  @override
  String get hydrationModalLogHeader => '紀錄水分補充';

  @override
  String get hydrationModalEditHeader => '編輯水分紀錄';

  @override
  String get hydrationFieldVolumeLabel => '容量';

  @override
  String get hydrationFieldVolumeHint => '毫升 ml（例如：250）';

  @override
  String get hydrationFieldBeverageLabel => '飲品類型';

  @override
  String get hydrationFieldSodiumLabel => '鈉含量（選填）';

  @override
  String hydrationLogLabelVolume(String volume) {
    return '$volume ml';
  }

  @override
  String get hrvSectionTitle => 'HRV 心率變異率';

  @override
  String get hrvActionAddEntry => '+ 紀錄 HRV';

  @override
  String get hrvModalLogHeader => '紀錄 HRV 量測值';

  @override
  String get hrvModalEditHeader => '編輯 HRV 紀錄';

  @override
  String get hrvFieldRmssdLabel => 'RMSSD';

  @override
  String get hrvFieldContextLabel => '量測情境';

  @override
  String get hrvFieldSourceLabel => '資料來源';

  @override
  String get hrvHintTapToEdit => '點擊數字即可進行編輯';

  @override
  String get hrvDirectEditDialogTitle => '編輯 RMSSD';

  @override
  String get hrvDirectEditDialogHint => '例如：35';

  @override
  String hrvLogLabelRmssd(String value) {
    return '$value ms';
  }

  @override
  String get hrvSourceManual => '手動輸入';

  @override
  String get hrvSourceAppleWatch => 'Apple Watch';

  @override
  String get hrvSourceWelltory => 'Welltory';

  @override
  String get hrvSourceOther => '其他';

  @override
  String get settingsModuleHydrationLabel => '水分補充';

  @override
  String get settingsModuleHydrationDescription => '追蹤飲水量、飲品類型與鈉攝取量。';

  @override
  String get settingsModuleHrvLabel => 'HRV 心率變異率';

  @override
  String get settingsModuleHrvDescription => '依量測情境與資料來源追蹤心率變異率。';

  @override
  String get sectionHintNoActivity => '暫無紀錄';

  @override
  String get sectionHintToday => '最新紀錄：今天';

  @override
  String get sectionHintYesterday => '最新紀錄：昨天';

  @override
  String sectionHintDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天前',
    );
    return '最新紀錄：$_temp0';
  }

  @override
  String get settingsViewPreferencesTitle => '顯示設定';

  @override
  String get settingsCarefulModeLabel => '精簡模式';

  @override
  String get settingsCarefulModeDescription =>
      '減少視覺干擾：所有區塊預設為摺疊狀態。點擊標題區塊即可展開您想查看的內容。';

  @override
  String get drugKindMedication => '藥物';

  @override
  String get drugKindSupplement => '保健食品';

  @override
  String get drugKindHerbal => '草藥產品';

  @override
  String get drugInteractionsInBotiquinHeader => '您藥箱中的交互作用';

  @override
  String get drugInteractionSeverityHigh => '高';

  @override
  String get drugInteractionSeverityMedium => '中';

  @override
  String get drugInteractionSeverityLow => '低';

  @override
  String get drugNoContentSupplement =>
      '保健食品 — 未作為藥物受到管制。在與其他治療方法結合使用前，請諮詢您的醫療團隊。';

  @override
  String get drugNoContentHerbal => '草藥產品 — 臨床證據有限。在與其他治療方法結合使用前，請諮詢您的醫療團隊。';

  @override
  String drugNoContentMedlineEmpty(String rxcui) {
    return 'MedlinePlus 未返回此藥物的資訊 (RxCUI $rxcui)。這可能是暫時性問題，或是該資料庫中沒有此代碼的內容。';
  }

  @override
  String get drugNoContentUnmapped =>
      '我們尚無此產品的詳細資訊。您可以手動在 medlineplus.gov 上搜尋。';

  @override
  String get drugNoContentGeneric => '無法載入資訊。';

  @override
  String get drugReadMoreMedlinePlus => '在 MedlinePlus 上閱讀更多';

  @override
  String get drugBrowserOpenError => '無法開啟瀏覽器。請檢查您的網路連線。';

  @override
  String get drugConfidenceMediumWarning => '中等信賴度映射 — 如果資訊與您的藥物不符，請與您的醫療團隊核實。';

  @override
  String get drugSourceLocalCurated => '來源：為此應用程式在地整理的臨床資訊。不能取代醫療建議。';

  @override
  String get drugSourceMedlinePlus => '來源：MedlinePlus，美國國家醫學圖書館。不能取代醫療建議。';

  @override
  String get drugSourceNoInfo => '我們的來源中沒有可用的臨床資訊。';

  @override
  String get drugLoadError => '無法載入資訊。';

  @override
  String get conditionSourceLocalCurated => '來源：ZebraUp 針對此病症的在地資訊。不能取代醫療建議。';

  @override
  String get conditionContentUnverifiedWarning =>
      '此摘要是根據一般醫學知識草擬，尚未經過臨床審查確認。如果內容與您的醫療團隊所說有出入，請以醫療團隊的說法為準。';

  @override
  String get conditionNoContentUnmapped =>
      '我們尚未收錄此病症。您可以手動在 medlineplus.gov 上搜尋。';

  @override
  String get conditionNoContentNoIcd10 =>
      '此病症沒有 ICD-10 代碼，因此無法查詢 MedlinePlus，我們也尚未提供在地摘要。';

  @override
  String get conditionNoContentMedlineEmpty =>
      'MedlinePlus 未能提供此病症的資訊。可能是暫時性問題，或此代碼缺乏內容。';

  @override
  String get moodQuadrantActivatedUnpleasant => '活躍 · 不快';

  @override
  String get moodQuadrantActivatedPleasant => '活躍 · 愉悅';

  @override
  String get moodQuadrantCalmUnpleasant => '平靜 · 不快';

  @override
  String get moodQuadrantCalmPleasant => '平靜 · 愉悅';

  @override
  String get moodTeaserActivatedUnpleasant => '緊張、焦慮';

  @override
  String get moodTeaserActivatedPleasant => '活力、喜悅';

  @override
  String get moodTeaserCalmUnpleasant => '疲憊、悲傷';

  @override
  String get moodTeaserCalmPleasant => '寧靜、平和';

  @override
  String get moodSheetStep1Title => '你感覺如何？';

  @override
  String get moodSheetCancel => '取消';

  @override
  String get moodSheetStep2Prompt => '我感覺如何？';

  @override
  String get moodSheetChangeQuadrant => '切換象限';

  @override
  String get moodSheetAlsoFeelingHeader => '我也感覺到…';

  @override
  String get moodSheetNotesHeader => '情境（選填）';

  @override
  String get moodSheetNotesPlaceholder => '例如：腦霧嚴重的一天…';

  @override
  String get moodSheetSaveButton => '儲存紀錄';

  @override
  String get moodDefinitionDialogAction => '了解';

  @override
  String get moodSectionTitle => '我的狀態';

  @override
  String get moodSectionPrompt => '你感覺如何？';

  @override
  String get moodSectionRegisterAnother => '記錄其他狀態';

  @override
  String get severityFunctionalAnchorNone => '我沒有感覺';

  @override
  String get severityFunctionalAnchorMild => '有感覺,但不影響我';

  @override
  String get severityFunctionalAnchorModerate => '讓我必須放慢或暫停';

  @override
  String get severityFunctionalAnchorIntense => '無法完成原本的計畫';

  @override
  String get severityFunctionalAnchorUnbearable => '無法正常運作,必須停下來';

  @override
  String get outcomeReasonNatural => '症狀的自然變化';

  @override
  String get outcomeReasonMedicationHelped => '我認為這個藥物有幫助';

  @override
  String get outcomeReasonOtherTrigger => '其他誘因(食物、壓力、天氣等)';

  @override
  String get outcomeReasonAdditionalMed => '我也服用了其他藥物';

  @override
  String get outcomeReasonUnsure => '我不確定';

  @override
  String get medicationOutcomeCoarsePending => '待回答';

  @override
  String get medicationOutcomeCoarseMuchBetter => '好很多';

  @override
  String get medicationOutcomeCoarseBetter => '比較好';

  @override
  String get medicationOutcomeCoarseSame => '一樣';

  @override
  String get medicationOutcomeCoarseWorse => '比較差';

  @override
  String get medicationOutcomeCoarseMuchWorse => '差很多';

  @override
  String get bowelFormTitleNew => '記錄排便';

  @override
  String get bowelFormTitleEdit => '編輯排便記錄';

  @override
  String get bowelFormBristolLabel => '布里斯托類型';

  @override
  String bowelFormBristolLegendTemplate(
    String constipation,
    String normal,
    String diarrhea,
  ) {
    return '1-2:$constipation  ·  3-5:$normal  ·  6-7:$diarrhea';
  }

  @override
  String get bowelFormHideBristolDetail => '隱藏細節';

  @override
  String get bowelFormShowBristolDetail => '更多細節(布里斯托量表)';

  @override
  String get bowelFormSectionObservations => '觀察';

  @override
  String get bowelFormToggleUrgency => '急迫感';

  @override
  String get bowelFormToggleIncompleteEvacuation => '排便不完全';

  @override
  String get bowelFormNoteHint => '選填備註(情境、誘因等)';

  @override
  String get hemorrhoidalFormTitleNew => '記錄痔瘡';

  @override
  String get hemorrhoidalFormTitleEdit => '編輯痔瘡記錄';

  @override
  String get hemorrhoidalFormNoteHint => '選填備註';

  @override
  String get formSectionHeaderDiscomfort => '不適';

  @override
  String get formToggleBleeding => '出血';

  @override
  String get formButtonSave => '儲存';

  @override
  String get structuralFormFollowupHeader => '追蹤';

  @override
  String get structuralFormFollowupResolvedQuestion => '已經痊癒了嗎?';

  @override
  String structuralFormFollowupResolvedDateTemplate(String date) {
    return '$date 痊癒';
  }

  @override
  String get structuralFormFollowupStillPainfulQuestion => '還在痛嗎?';

  @override
  String get structuralFormFollowupStillPainfulSubtitle => '外觀已癒合但仍會疼痛';

  @override
  String bowelLogBristolTypeTemplate(int type) {
    return '類型 $type';
  }

  @override
  String get bowelLogTagUrgency => '急迫';

  @override
  String get bowelLogTagBleeding => '出血';

  @override
  String get bowelLogTagIncomplete => '不完全';

  @override
  String get hemorrhoidalLogLabel => '痔瘡';

  @override
  String get hemorrhoidalLogTagBleeding => '出血';

  @override
  String get symptomLogTagUnrated => '未評分';

  @override
  String get hoySectionPendingHeader => '待處理';

  @override
  String get hoyOutcomeForYour => '用於你的';

  @override
  String get hoyOutcomeHideReasons => '隱藏';

  @override
  String get hoyBowelCounterToday => '上次排便:今天';

  @override
  String get hoyBowelCounterYesterday => '上次排便:昨天';

  @override
  String hoyBowelCounterDaysAgoTemplate(int days) {
    return '上次排便:$days 天前';
  }

  @override
  String get hoyNarrativeEmptyPacing => '🛡️ 休息日。今天還沒記錄任何事 — 沒關係。';

  @override
  String get hoyNarrativeEmpty => '今天還沒記錄任何事。一切還好嗎?';

  @override
  String hoyNarrativeSymptomsSingleTemplate(String name, String severity) {
    return '記錄了 1 個症狀:$name($severity)。';
  }

  @override
  String hoyNarrativeSymptomsManyTemplate(
    int count,
    String name,
    String severity,
  ) {
    return '記錄了 $count 個症狀 — 最嚴重的是 $name($severity)。';
  }

  @override
  String hoyNarrativeStructuralSingleTemplate(String zone) {
    return '在$zone有 1 個結構性事件。';
  }

  @override
  String hoyNarrativeStructuralManyTemplate(int count) {
    return '今天有 $count 個結構性事件。';
  }

  @override
  String hoyNarrativeDosesSingleTemplate(String meds) {
    return '用了 1 劑:$meds。';
  }

  @override
  String hoyNarrativeDosesManyTemplate(int count, String meds) {
    return '服用了 $count 劑:$meds。';
  }

  @override
  String hoyNarrativeDosesAndMore(int count) {
    return ',還有 $count 項';
  }

  @override
  String hoyNarrativeEmaStatesTemplate(String states) {
    return '記錄的狀態與感受:$states。';
  }

  @override
  String get hoyNarrativeEmaStatesEllipsis => '...';

  @override
  String get hoyNarrativePacingTrailer => '🛡️ 你允許自己休息。這也算數。';

  @override
  String get hoyHeaderDatePattern => 'M月d日 EEEE';

  @override
  String movementModalTitleRegisterTemplate(String name) {
    return '記錄: $name';
  }

  @override
  String movementModalTitleEditTemplate(String name) {
    return '編輯: $name';
  }

  @override
  String get movementModalHintDuration => '時長(分鐘)';

  @override
  String get movementModalHintSets => '組數';

  @override
  String get movementModalHintReps => '次數';

  @override
  String get movementModalHintHeartRate => '心率(選填,例:70→110)';

  @override
  String movementModalEffortLabelTemplate(int value) {
    return '費力程度:$value/10';
  }

  @override
  String movementModalFeelingLabelTemplate(int value) {
    return '感受:$value/5';
  }

  @override
  String get movementFeelingPainOrInjury => '🤕 疼痛/受傷';

  @override
  String get movementFeelingUncomfortable => '😟 不舒服/擔心';

  @override
  String get movementFeelingNeutral => '😐 普通';

  @override
  String get movementFeelingRelaxed => '😊 放鬆';

  @override
  String get movementFeelingStrongConfident => '💪 強壯有信心';

  @override
  String get movementPainLevelNone => '無';

  @override
  String get movementPainLevelMild => '輕微';

  @override
  String get movementPainLevelModerate => '中等';

  @override
  String get movementPainLevelIntense => '強烈';

  @override
  String get movementPainLevelSevere => '嚴重';

  @override
  String movementPainDeltaImprovedTemplate(int delta) {
    String _temp0 = intl.Intl.pluralLogic(
      delta,
      locale: localeName,
      other: '$delta 級',
    );
    return '改善了 $_temp0';
  }

  @override
  String movementPainDeltaWorseTemplate(int delta) {
    String _temp0 = intl.Intl.pluralLogic(
      delta,
      locale: localeName,
      other: '$delta 級',
    );
    return '惡化了 $_temp0';
  }

  @override
  String get movementPainDeltaUnchanged => '沒有變化';

  @override
  String movementLogEntryEffortTemplate(int value) {
    return '費力 $value/10';
  }

  @override
  String movementLogEntryFeelingTemplate(int value) {
    return '感受 $value/5';
  }

  @override
  String movementLogEntryDeltaImprovedTemplate(int delta) {
    return '↓$delta 級';
  }

  @override
  String movementLogEntryDeltaWorseTemplate(int delta) {
    return '↑$delta 級';
  }

  @override
  String get movementLogEntryDeltaUnchanged => '無變化';

  @override
  String get movementLogEntryTherapyDeltaSteady => '=';

  @override
  String get appBarTooltipFontSize => '字體大小';

  @override
  String get appBarTooltipDarkMode => '深色模式';

  @override
  String get appBarTooltipLightMode => '淺色模式';

  @override
  String get appBarTooltipSettings => '設定';

  @override
  String get actionDelete => '刪除';

  @override
  String get settingsProfileConfigTitle => '個人檔案設定';

  @override
  String get settingsMyDataTitle => '我的資料';

  @override
  String get settingsPatientNameLabel => '患者姓名';

  @override
  String get settingsConditionsLabel => '共病/診斷';

  @override
  String get settingsRelationshipLabel => '與此檔案的關係';

  @override
  String get settingsLifeEventsLabel => '生活事件';

  @override
  String get settingsLocationLabel => '我的位置(用於天氣)';

  @override
  String get settingsConditionsHelper => '點 × 移除一項條件。若要閱讀說明,請前往 臨床→指南。';

  @override
  String get settingsRelationshipHelper => '此檔案是給誰使用的?如果你在為照顧的人記錄,這很實用。';

  @override
  String get settingsLifeEventsHelper =>
      '可能影響你身體或心情的事件:旅行、意外、搬家、好的或有壓力的事件。它們會在日曆上顯示為紫色圓點。';

  @override
  String get settingsDataHelper => '你有權隨時存取、匯出、匯入或刪除你的資料。';

  @override
  String get settingsWipeAllHelper => '此操作會刪除所有檔案、記錄和設定。無法復原。';

  @override
  String get settingsRelationshipSelf => '我自己';

  @override
  String get settingsRelationshipChild => '我的小孩';

  @override
  String get settingsRelationshipPartner => '我的伴侶';

  @override
  String get settingsRelationshipParent => '我的父母';

  @override
  String get settingsRelationshipOther => '其他';

  @override
  String get settingsRelationshipNone => '— 未指定 —';

  @override
  String get settingsLifeEventsEmpty => '還沒有記錄任何事件。';

  @override
  String get settingsAddEventButton => '新增事件';

  @override
  String get settingsLocationNone => '未設定位置。點此新增。';

  @override
  String get settingsLocationButtonAdd => '新增座標';

  @override
  String get settingsLocationButtonEdit => '編輯座標';

  @override
  String get settingsAddProfileButton => '新增個人檔案';

  @override
  String get settingsDeleteProfileButton => '刪除此個人檔案';

  @override
  String get settingsExportDataButton => '匯出我的資料';

  @override
  String get settingsWipeAllButton => '全部刪除';

  @override
  String settingsNewProfileNameTemplate(int number) {
    return '新檔案 $number';
  }

  @override
  String get dialogWipeTitle => '刪除所有資料';

  @override
  String get dialogWipeContent => '此操作會刪除所有個人檔案、記錄、設定和快取。無法復原。\n\n要先匯出嗎?';

  @override
  String get dialogWipeFinalTitle => '最後確認';

  @override
  String dialogWipeFinalContentTemplate(String magicWord) {
    return '輸入 $magicWord 以確認。';
  }

  @override
  String get dialogWipeFinalMagicWord => '刪除';

  @override
  String get dialogWipeFinalButton => '全部刪除';

  @override
  String get dialogDeleteProfileTitle => '刪除個人檔案';

  @override
  String dialogDeleteProfileContentTemplate(String name) {
    return '確定要刪除個人檔案「$name」以及所有相關資料?此操作無法復原。';
  }

  @override
  String get dialogLocationTitle => '你的位置';

  @override
  String get dialogLocationContent =>
      '需要緯度和經度才能取得天氣資訊。在 Google 地圖找到你的城市,右鍵→複製座標。';

  @override
  String get dialogLocationHintLat => '緯度(例: -34.61)';

  @override
  String get dialogLocationHintLng => '經度(例: -58.38)';

  @override
  String get dialogLocationInvalidSnack => '座標無效。';

  @override
  String get therapyHintArea => '部位(例:頸部)';

  @override
  String get therapySectionPainBefore => '治療前疼痛';

  @override
  String get therapySectionPainAfter => '治療後疼痛';

  @override
  String get therapyActionMoreDetails => '多細節(治療師、費用、備註)';

  @override
  String get therapyHintTherapist => '治療師/地點(選填)';

  @override
  String get therapyHintCost => '費用(選填)';

  @override
  String get therapyHintNote => '備註(選填)';

  @override
  String get therapyActionSaveChanges => '儲存變更';

  @override
  String get therapyActionLog => '記錄';

  @override
  String get compendiumSectionConditionsHeader => '我的疾病';

  @override
  String get compendiumSectionConditionsSubtitle =>
      '點一個閱讀臨床資訊(來源:MedlinePlus)。';

  @override
  String compendiumSavedArticlesTemplate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已儲存 $count 篇文章',
    );
    return '$_temp0 — 前往研究。';
  }

  @override
  String get compendiumSectionDataTitle => '臨床資料';

  @override
  String get compendiumFactSourceLabel => '來源:';

  @override
  String investigationConditionArticleCountTemplate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 篇文章',
    );
    return '$_temp0';
  }

  @override
  String get headacheSheetTitle => '頭痛詳細資料';

  @override
  String get headacheSheetSubtitle => '標記適用的項目。如果你願意,可以跳過此步驟。';

  @override
  String get actionSkip => '跳過';

  @override
  String get headacheActionSaveDetail => '儲存詳細資料';

  @override
  String get headacheThunderclapWarningTitle => '可能的緊急情況';

  @override
  String get headacheThunderclapWarningConfirm => '我了解,繼續';

  @override
  String get headacheAdvisoryDialogTitle => '需要注意的模式';

  @override
  String get headacheRedFlagCsfLeakAdvisory =>
      '你的頭痛在站立時明顯加劇。這種模式可能表明腦脊液漏,在 EDS 患者中尤其常見。如果反覆出現,建議告知你的醫生。';

  @override
  String get headacheRedFlagIntracranialAdvisory =>
      '你的頭痛在躺下時加劇。這種模式可能表明顱內壓升高。如果反覆出現或伴隨視覺變化,建議就醫評估。';

  @override
  String get settingsModuleHeadacheDetailLabel => '頭痛詳細資料';

  @override
  String get settingsModuleHeadacheDetailDescription => '登錄頭痛時記錄位置、性質和其他模式。';

  @override
  String get fatigueSheetTitle => '疲勞細節';

  @override
  String get fatigueSheetSubtitle => '選填的細節有助於識別模式。';

  @override
  String get fatigueActionSaveDetail => '儲存細節';

  @override
  String get fatigueAdvisoryDialogTitle => '檢測到的模式';

  @override
  String get fatigueRedFlagPemAdvisory =>
      '這個模式顯示你的疲勞在勞累後1-3天出現。這可能表示你的身體能量儲備比平常少,需要更多天才能恢復。如果反覆出現,建議告知你的醫師。';

  @override
  String get fatigueRedFlagOrthostaticAdvisory =>
      '你的疲勞在站立或直坐時加劇。這可能表示你的身體在直立時難以維持穩定的血壓或脈搏。這在EDS患者中很常見。建議告知你的醫師。';

  @override
  String get fatigueRedFlagHpaAdvisory =>
      '你的身體感覺筋疲力盡但無法休息。這可能表示你的壓力系統已被啟動很長時間,調節休息的荷爾蒙失衡。建議告知你的醫師。';

  @override
  String get settingsModuleFatigueDetailLabel => '疲勞細節';

  @override
  String get settingsModuleFatigueDetailDescription => '記錄疲勞時,追蹤類型、時間模式和伴隨症狀。';

  @override
  String get abdominalSheetTitle => '腹痛細節';

  @override
  String get abdominalSheetSubtitle => '選填的細節有助於識別模式。';

  @override
  String get abdominalActionSaveDetail => '儲存細節';

  @override
  String get abdominalTearingEmergencyTitle => '撕裂型疼痛';

  @override
  String get abdominalTearingEmergencyBody =>
      '突發的極度劇烈撕裂型疼痛在Ehlers-Danlos症候群患者中可能表示醫療急症。建議你現在就去急診以排除動脈或腸道破裂。\n\n如果你去,請告知醫療團隊你的clEDS診斷(類典型Ehlers-Danlos症候群,由TNXB基因突變引起)。\n\n如果疼痛已顯著改善,你不再認為它是撕裂感,你可以更改疼痛性質並正常儲存記錄。';

  @override
  String get abdominalTearingEmergencyChangeQuality => '更改性質並儲存';

  @override
  String get abdominalTearingEmergencySaveAsIs => '照原樣儲存(急症)';

  @override
  String get abdominalAdvisoryDialogTitle => '檢測到的模式';

  @override
  String get abdominalRedFlagMassiveHematocheziaUrgent =>
      '這個模式(糞便帶血伴隨噁心或嘔吐和劇烈疼痛)可能表示活動性GI出血。若出血量多或你注意到明顯虛弱或頭暈,請立即就醫。';

  @override
  String get abdominalRedFlagHematemesisUrgent =>
      '在你的備註中提到嘔血。此症狀表示上消化道出血,需立即急診評估。';

  @override
  String get abdominalRedFlagNocturnalPainAdvisory =>
      '你的疼痛在夜間將你喚醒。這是值得告訴你的醫生的警示訊號,尤其若你注意到非自願性體重減輕或發燒。';

  @override
  String get abdominalRedFlagGastroparesisAdvisory =>
      '你的疼痛在剛進食時出現且很快感到飽足。這個模式可能表示你的胃排空比正常慢。在伴隨自主神經功能障礙的EDS患者中常見。值得告訴你的醫生。';

  @override
  String get settingsModuleAbdominalDetailLabel => '腹痛細節';

  @override
  String get settingsModuleAbdominalDetailDescription =>
      '記錄疼痛、腹脹或排氣時,追蹤位置、性質、時間關係和伴隨症狀。';

  @override
  String get bowelToAbdominalPromptTitle => '記錄疼痛細節?';

  @override
  String get bowelToAbdominalPromptBody => '你將此事件標記為伴隨腹痛。現在記錄細節以幫助識別模式?';

  @override
  String get abdominalToBowelPromptTitle => '與排便有關?';

  @override
  String abdominalToBowelPromptBody(String time) {
    return '你將此疼痛標記為與排便有關。你記錄了 $time 的一次排便。是同一次嗎?';
  }

  @override
  String get abdominalIntegrationYes => '是';

  @override
  String get abdominalIntegrationNo => '否';

  @override
  String get abdominalIntegrationDontKnow => '我不知道';

  @override
  String get onboardingStepMedsUnitHint => '1';

  @override
  String get onboardingStepMedsStrengthHint => 'mg';
}
