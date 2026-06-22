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
  String get bowelBucketDiarrea => '腹瀉';

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
  String get bowelBucketDiarrea => '腹瀉';

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
}
