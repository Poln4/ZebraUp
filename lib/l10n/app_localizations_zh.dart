// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navHoy => '今日';

  @override
  String get navSintomas => '症狀記錄';

  @override
  String get navMovimiento => '活動動態';

  @override
  String get navBotiquin => '隨身藥箱';

  @override
  String get navClinica => '臨床數據';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '儲存';

  @override
  String get actionImport => '匯入';

  @override
  String get actionContinue => '繼續';

  @override
  String get actionUnderstood => '我知道了';

  @override
  String get languageSectionTitle => 'IDIOMA / 語言設定 ';

  @override
  String get languageFootnote => '語言變更將套用至全域應用程式，這不會影響您的既有數據。';

  @override
  String get myDataTitle => '我的數據資產';

  @override
  String get arcoRightsBlurb => '您有權隨時查閱、導出、匯入或永久刪除您的個人紀錄。';

  @override
  String get exportDataButton => '導出我的數據';

  @override
  String get importFileButton => '從檔案匯入';

  @override
  String get importPasteButton => '貼上文字匯入';

  @override
  String get wipeAllButton => '清空所有資料';

  @override
  String get wipeWarningFootnote => '此操作將清除所有使用者檔案、紀錄與設定。此清除不可逆。';

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
  String get actionHide => '隱藏';

  @override
  String get hintTapTip => '提示：在「症狀記錄」中，點擊庫存項目即可記錄。長按特定項目可進行編輯。';

  @override
  String get sectionPending => '待辦核對';

  @override
  String get sectionWeather => '今日氣象摘要';

  @override
  String get headerTodayIs => '今天是';

  @override
  String get pacingActiveState => '休息日 — 允許放空、不設預期';

  @override
  String get pacingInactiveState => '標記今日為休息日';

  @override
  String outcomeCardTimePrefix(String hours) {
    return '$hours 小時前您服用了';
  }

  @override
  String get outcomeCardForSymptom => '以緩解您的';

  @override
  String get outcomeCardInitialState => '當時嚴重度為';

  @override
  String get outcomeCardQuestionNow => '目前感覺如何？';

  @override
  String get outcomeCardAttributionQuestion => '您認為當前的轉變主要歸因於？';

  @override
  String get outcomeActionAddFactor => '其他伴隨因素';

  @override
  String get sectionMentalDetails => '心理與認知細節';

  @override
  String get mentalIntensitySubtitle => '當下的強度表現';

  @override
  String get summaryTitle => '今日狀態簡要';

  @override
  String get summaryEmptyPacing => '🛡️ 休息日。您目前尚未記錄任何內容 — 這很好，請好好放鬆。';

  @override
  String get summaryEmptyNormal => '您今天尚未登錄任何數據。目前感覺怎麼樣？';

  @override
  String summarySymptomSingle(String name, String label) {
    return '您記錄了 1 項症狀：$name （狀態：$label）。';
  }

  @override
  String summarySymptomPlural(int count, String name, String label) {
    return '您已記錄 $count 項症狀 — 其中感受最顯著的是 $name （狀態：$label）。';
  }

  @override
  String summaryStructuralSingle(String zone) {
    return '您在 $zone 發生了 1 次結構性事件。';
  }

  @override
  String summaryStructuralPlural(int count) {
    return '您今天共記錄了 $count 次結構性事件。';
  }

  @override
  String summaryDosesSentence(int totalDoses, String shown, int extraCount) {
    String _temp0 = intl.Intl.pluralLogic(
      extraCount,
      locale: localeName,
      other: ' 以及其他 $extraCount 項',
      zero: '',
    );
    return '您服用了 $totalDoses 次藥物：$shown$_temp0。';
  }

  @override
  String summaryMoodSentence(String statesStr, String extra) {
    return '您記錄的心情與體感反應：$statesStr$extra。';
  }

  @override
  String get summaryPacingFooter => '🛡️ 您已選擇適度配速並保留體能。這非常有價值。';

  @override
  String get wisdomBannerTitle => '✨ 斑馬哲思 🦓';

  @override
  String get bowelCountToday => '最近一次排便：今天';

  @override
  String get bowelCountYesterday => '最近一次排便：昨天';

  @override
  String bowelCountDaysAgo(int days) {
    return '最近一次排便： $days 天前';
  }

  @override
  String distentionBannerMessage(int days) {
    return '您已有 $days 天未進行排便 — 腹脹感與腹部不適感可能會持續累積。';
  }

  @override
  String get distentionBannerAction => '前往症狀記錄';

  @override
  String get severityNone => '無症狀';

  @override
  String get severityMild => '輕微';

  @override
  String get severityModerate => '中度顯著';

  @override
  String get severityIntense => '強烈不適';

  @override
  String get severityUnbearable => '無法忍受';

  @override
  String get reasonNatural => '症狀常態性自然轉變';

  @override
  String get reasonMedicationHelped => '我認為此藥物發揮了緩解作用';

  @override
  String get reasonOtherTrigger => '其他誘發因素（飲食、壓力、天氣等）';

  @override
  String get reasonAdditionalMed => '期間亦服用了其他伴隨藥物';

  @override
  String get reasonUnsure => '不確定確切原因';

  @override
  String get mentalStateMood => '整體心境';

  @override
  String get mentalStateAnxiety => '焦慮感';

  @override
  String get mentalStateBrainFog => '腦霧狀態';

  @override
  String get mentalStateDissociation => '解離/失神現象';

  @override
  String get mentalStateIrritability => '易怒情緒';

  @override
  String get mentalStateEmotionalEnergy => '心理能量能見度';

  @override
  String get outcomeCoarsePending => '待核對';

  @override
  String get outcomeCoarseMuchBetter => '顯著改善';

  @override
  String get outcomeCoarseBetter => '有所緩解';

  @override
  String get outcomeCoarseEqual => '不變/持平';

  @override
  String get outcomeCoarseWorse => '加劇';

  @override
  String get outcomeCoarseMuchWorse => '顯著加劇';

  @override
  String get pubMedNoAuthor => '未登載作者';

  @override
  String get quadrantActivatedUnpleasant => '高激活 · 不適感';

  @override
  String get quadrantActivatedPleasant => '高激活 · 舒適感';

  @override
  String get quadrantCalmUnpleasant => '低激活 · 不適感';

  @override
  String get quadrantCalpleasant => 'calma · bienestar';

  @override
  String get quadrantTeaserActivatedUnpleasant => '緊繃、焦慮';

  @override
  String get quadrantTeaserActivatedPleasant => '充沛活力、喜悅';

  @override
  String get quadrantTeaserCalmUnpleasant => '疲憊耗竭、低落';

  @override
  String get quadrantTeaserCalmPleasant => '平靜、祥和';

  @override
  String get bowelBucketConstipation => '便秘狀態';

  @override
  String get bowelBucketNormal => '排便正常';

  @override
  String get bowelBucketDiarrea => '腹瀉狀態';

  @override
  String get sleepQualityBad => '極差';

  @override
  String get sleepQualityRegular => '普通';

  @override
  String get sleepQualityGood => '良好';

  @override
  String get sleepQualityVeryGood => '極佳';

  @override
  String get beverageWater => '純水';

  @override
  String get beverageElectrolyte => '電解質補充飲';

  @override
  String get beverageCoffee => '咖啡';

  @override
  String get beverageOther => '其他飲品';

  @override
  String get sodiumPinch => '微量食鹽';

  @override
  String get sodiumSachet => '電解質沖泡包';

  @override
  String get sodiumSaltySnack => '高鈉鹹味點心';

  @override
  String get hrvContextMorning => '晨間測量';

  @override
  String get hrvContextAfternoon => '午後測量';

  @override
  String get hrvContextEvening => '夜間測量';

  @override
  String get hrvContextPostExercise => '運動後測量';

  @override
  String get hrvContextOther => '其他情境測量';

  @override
  String legacyIntensityLabel(String value) {
    return '既往強度紀錄：$value/5';
  }

  @override
  String get botiquinTabTitle => '隨身藥箱';

  @override
  String get botiquinActionCreate => '新增常備藥物';

  @override
  String get botiquinInteractionsTitle => '藥物/病理交互作用警示';

  @override
  String get botiquinGroupsTitle => '常備組合群組';

  @override
  String get botiquinGroupsEmptyHeadline => '🌙 夜間服藥組合 · ☀️ 晨間服藥組合';

  @override
  String get botiquinGroupsEmptyBody => '將您經常同時服用的幾種藥物歸類為同一組合。一鍵即可快速登錄全組劑量紀錄。';

  @override
  String get botiquinActionCreateGroup => '建立新組合';

  @override
  String get botiquinNoMedsDialogTitle => '藥箱目前無常備藥';

  @override
  String get botiquinNoMedsDialogBody => '在建立常備組合前，請先在您的隨身藥箱中新增至少一項藥物紀錄。';

  @override
  String botiquinRowMedsCountLabel(int count) {
    return '內含 $count 項藥物';
  }

  @override
  String get botiquinActionEditTooltip => '編輯變更';

  @override
  String get botiquinBatchSheetTitle => '批量登錄群組';

  @override
  String get botiquinBatchSheetSubtitle => '系統即將記錄以下劑量數據：';

  @override
  String botiquinBatchOrphanWarning(int count) {
    return '⚠️ 組合內包含 $count 項已自藥箱移除的藥物，系統登錄時將自動跳過。';
  }

  @override
  String botiquinBatchActionSubmit(int count) {
    return '登錄這 $count 筆劑量數據';
  }

  @override
  String get botiquinEmptyStateHeadline => '藥箱目前空空如也';

  @override
  String get botiquinEmptyStateSubtitle => '點擊下方按鈕即可建立您的第一項常用藥物。';

  @override
  String botiquinDoseLoggedTodayBadge(String qty) {
    return '今日已服 $qty';
  }

  @override
  String botiquinDeleteConfirmTitle(String name) {
    return '確認移除 $name？';
  }

  @override
  String botiquinDeleteConfirmBody(String name) {
    return '移除後系統仍會保留既往的歷史服藥紀錄以利您的臨床報告分析，但 $name 將不再出現在常用藥箱列表中。';
  }

  @override
  String get botiquinActionDelete => '確認確認移除';

  @override
  String get botiquinLogDoseSheetTitle => '登錄服藥劑量';

  @override
  String botiquinLogDoseTotalCalculated(String total, String unit) {
    return '= 當次攝入共 $total $unit';
  }

  @override
  String get botiquinLogDoseSymptomPrompt => '此劑量是否用於特定症狀？';

  @override
  String get botiquinLogDoseSymptomNone => '無對應症狀（常規服用）';

  @override
  String botiquinLogDoseTrackOutcomeToggle(int hours) {
    return '系統將於 $hours 小時後提醒追蹤此藥物的緩解成效';
  }

  @override
  String get botiquinDoseListTitle => '今日服藥紀錄';

  @override
  String get botiquinDoseListFootnote => '點擊 × 可單獨刪除某一特定時間的紀錄（這對於修正誤觸登錄非常實用）。';

  @override
  String get botiquinDoseItemDeleteConfirmTitle => '刪除此筆服藥紀錄';

  @override
  String botiquinDoseItemDeleteConfirmBody(String name, String time) {
    return '您確定要刪除在 $time 登錄的 $name 紀錄嗎？此刪除操作無法撤銷。';
  }

  @override
  String botiquinTimeTodayAt(String time) {
    return '今天 $time';
  }

  @override
  String botiquinTimePastAt(int day, int month, String time) {
    return '$day/$month 於 $time';
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
  String get onboardingFallbackProfileName => '我的檔案';

  @override
  String get onboardingStepWelcomeTitle => 'ZebraUp';

  @override
  String get onboardingStepWelcomeSubtitle => '您的就醫專屬數位夥伴。';

  @override
  String get onboardingStepWelcomeBody =>
      '門診時間往往很短。在經歷辛苦的一週後，人的記憶力也是。ZebraUp 協助您精確記錄症狀、用藥與健康趨勢，讓您在每次就診時都能提出具體數據——而不是一坐在醫生面前，原本想說的話就忘光了。此外，我們知道您也有照顧他人的需求，因此您也可以將家人或寵物納入記錄管理。';

  @override
  String get onboardingStepWelcomePrivacyNote =>
      '您的所有數據皆安全地儲存於本機裝置中，我們絕不會將任何資料上傳至網際網路。';

  @override
  String get onboardingStepWelcomeMedicalDisclaimer =>
      '本應用程式並非醫療器材。其內容不具備診斷、治療、緩解或預防任何疾病之醫療效力。';

  @override
  String get onboardingStepNameTitle => '讓我們開始吧。';

  @override
  String get onboardingStepNameQuestion => '我們該如何稱呼您？';

  @override
  String get onboardingStepNameFootnote => '此名稱僅用於個人化您的應用程式介面，您隨時可以在日後進行變更。';

  @override
  String get onboardingStepNameHint => '您的名字或暱稱';

  @override
  String get onboardingStepConditionsTitle => '既有確診診斷。';

  @override
  String get onboardingStepConditionsBody =>
      '您目前面臨哪些健康狀況？這些資訊將用於為您的交互作用與臨床報告提供脈絡。您隨時可以新增、修改或跳過此步驟。';

  @override
  String get onboardingStepConditionsHint => '例如：hEDS, POTS, MCAS...';

  @override
  String get onboardingStepConditionsEmpty => '目前尚未新增任何診斷。您可以先跳過此步驟。';

  @override
  String get onboardingStepMedsTitle => '設定常用藥箱。';

  @override
  String get onboardingStepMedsBody =>
      '在此新增您的常規服用藥物。設定完成後，您即可在「隨身藥箱」分頁中一鍵快速登錄每次的服藥劑量紀錄。';

  @override
  String get onboardingStepMedsNameHint => '藥物名稱';

  @override
  String get onboardingStepMedsDoseHint => '劑量（例如：400mg）';

  @override
  String get onboardingStepMedsEmpty => '目前尚未新增藥物。您可以先跳過此步驟。';

  @override
  String get symptomsSectionStructuralZones => '關節與結構部位';

  @override
  String get symptomsSectionBowelTransit => '腸道排空狀態';

  @override
  String get symptomsActionAddHemorrhoid => '痔瘡相關問題';

  @override
  String get symptomsSectionTodaysLogs => '今日症狀與體感紀錄';

  @override
  String get symptomsFootnoteLongPressEdit => '長按任一項目即可修正記錄時間、嚴重度或備註細節。';

  @override
  String get symptomsSectionTrending => '本週高頻趨勢（過去 7 天）';

  @override
  String get symptomsTrendingEmpty => '本週尚未累積顯著的重複症狀趨勢。';

  @override
  String get symptomsSectionVault => '個人症狀庫庫存';

  @override
  String get symptomsVaultPlaceholder => '+ 新增自訂症狀至庫存...';

  @override
  String symptomsModalLogHeader(String zone) {
    return '記錄部位：$zone';
  }

  @override
  String symptomsModalEditHeader(String zone, String type) {
    return '編輯：$zone / $type';
  }

  @override
  String symptomsModalEditSymptomHeader(String name) {
    return '編輯症狀：$name';
  }

  @override
  String get symptomsLabelOptionalNote => '選填備註（情境脈絡、潛在誘因等）';

  @override
  String get symptomsLabelOptionalNoteSimple => '選填備註';

  @override
  String get symptomsLabelSeverityGrading => '嚴重程度評級';

  @override
  String get symptomsActionLogUnrated => '僅記錄不評級';

  @override
  String get symptomsUnratedLabelSuffix => '未評級';

  @override
  String get symptomsUnratedInlineWarning => '此項目目前無嚴重度評級。點擊圓點即可為其指派權重。';

  @override
  String get symptomsActionSaveChanges => '確認修改變更';

  @override
  String get symptomsActionSave => '確認確認儲存';

  @override
  String get zoneCervical => '頸椎區域';

  @override
  String get zoneHombros => '雙肩關節';

  @override
  String get zoneMunecas => '手腕關節';

  @override
  String get zoneManos => '手部掌指';

  @override
  String get zoneLumbarPelvis => '腰椎/骨盆腔';

  @override
  String get zoneCaderas => '髖關節';

  @override
  String get zoneRodillas => '雙膝關節';

  @override
  String get zoneTobillos => '腳踝關節';

  @override
  String get structTypeSubluxation => '關節半脫位';

  @override
  String get structTypeDislocation => '關節完全脫位';

  @override
  String get structTypeInstability => '關節不穩定感';

  @override
  String get structTypeJointPain => '關節鈍痛/銳痛';

  @override
  String get structTypeMyofascial => '肌筋膜疼痛';

  @override
  String get structTypeNeuropathic => '神經源性抽痛';

  @override
  String bowelLabelBristolType(String type) {
    return '布里斯托第 $type 型';
  }

  @override
  String get bowelLabelUrgency => '伴隨急迫感';

  @override
  String get bowelLabelBleeding => '伴隨便血';

  @override
  String get bowelLabelIncomplete => '排便不完全感';

  @override
  String get movementSectionPacingActive => '今日為安排的休息日。適度休息也是體能配速的核心。';

  @override
  String get movementSectionHistoryTitle => '今日動態與恢復紀錄';

  @override
  String get movementFootnoteLongPressEdit => '長按特定歷史項目即可進行編輯修正。';

  @override
  String get movementEmptyStateHeadline => '身體活動與修復放鬆同等重要。';

  @override
  String get movementEmptyStateSubtitle => '不論是散步、拉伸、物理治療或按摩，皆是彌足珍貴的身體照顧歷程。';

  @override
  String get movementSectionActivityTitle => '自主身體活動';

  @override
  String get movementActivityPlaceholder => '+ 新增自訂活動（如：游泳、單車、舞蹈…）';

  @override
  String get movementSectionTherapyTitle => '臨床與被動治療';

  @override
  String get movementTherapyPlaceholder => '+ 新增特殊治療（如：能量療癒、漂浮…）';

  @override
  String activityModalLogHeader(String name) {
    return '記錄項目：$name';
  }

  @override
  String activityModalEditHeader(String name) {
    return '編輯項目：$name';
  }

  @override
  String get activityFieldDurationHint => '持續時間（分鐘）';

  @override
  String get activityFieldSetsHint => '組數';

  @override
  String get activityFieldRepsHint => '每組次數';

  @override
  String get activityFieldHhrHint => '選填心率區間變化（例如：70→110）';

  @override
  String activityLabelEffortSlider(int value) {
    return '自覺運動強度 (RPE)：$value/10';
  }

  @override
  String activityLabelFeelingSlider(int value) {
    return '本體心理感受：$value/5';
  }

  @override
  String get activityActionTogglePainRating => '評估運動前後的疼痛指數 e-VAS（選填）';

  @override
  String get activityLabelPainBefore => '運動前疼痛評級';

  @override
  String get activityLabelPainAfter => '運動後疼痛評級';

  @override
  String get activityActionSubmitLog => '確認儲存活動數據';

  @override
  String get activityActionSubmitChanges => '確認儲存修改變更';

  @override
  String get painLabelNone => '無痛';

  @override
  String get painLabelMild => '輕度';

  @override
  String get painLabelModerate => '中度';

  @override
  String get painLabelIntense => '劇烈';

  @override
  String get painLabelSevere => '極度嚴重';

  @override
  String painDeltaLabelImproved(int count) {
    return '疼痛指數改善了 $count 個層級';
  }

  @override
  String painDeltaLabelWorsened(int count) {
    return '疼痛指數加劇了 $count 個層級';
  }

  @override
  String get painDeltaLabelUnchanged => '疼痛指數持平';

  @override
  String logSubtitleMetricDuration(int minutes) {
    return '$minutes 分鐘';
  }

  @override
  String logSubtitleMetricSetsReps(String sets, String reps) {
    return '$sets 組 × $reps 次';
  }

  @override
  String logSubtitleActivityTemplate(
    String detail,
    int effort,
    int feeling,
    String pain,
    Object painSuffix,
  ) {
    return '細節：$detail · 自覺強度 $effort/10 · 心理體感 $feeling/5$painSuffix ';
  }

  @override
  String logSubtitlePainDeltaImproved(int levels) {
    return '疼痛 ↓$levels 級';
  }

  @override
  String logSubtitlePainDeltaWorsened(int levels) {
    return '疼痛 ↑$levels 級';
  }

  @override
  String get logSubtitlePainDeltaUnchanged => '疼痛持平';

  @override
  String get feelingLabelLevel1 => '🤕 伴隨疼痛 / 誘發受傷恐懼';

  @override
  String get feelingLabelLevel2 => '😟 感到不適 / 動作有所防禦';

  @override
  String get feelingLabelLevel3 => '😐 狀態表現持平';

  @override
  String get feelingLabelLevel4 => '😊 身體放鬆舒適';

  @override
  String get feelingLabelLevel5 => '💪 感覺強壯且充滿安全感';

  @override
  String get onboardingHaveProfileTitle => '我已經有備份的個人檔案';

  @override
  String get onboardingHaveProfileSubtitle => '從既有的 JSON 檔案匯入數據';

  @override
  String get onboardingImportChoiceTitle => '請選擇匯入方式';

  @override
  String get onboardingImportFromFile => '從檔案取回';

  @override
  String get onboardingImportFromPaste => '直接貼上文字';

  @override
  String get feverSectionTitle => '發燒記錄';

  @override
  String get feverActionAddReading => '+ 測量體溫';

  @override
  String get feverModalLogHeader => '記錄體溫';

  @override
  String get feverModalEditHeader => '編輯數值';

  @override
  String get feverFieldSiteLabel => '測量部位';

  @override
  String get feverFieldAntipyreticLabel => '退燒藥';

  @override
  String get feverFieldAntipyreticToggle => '已服用退燒藥物';

  @override
  String get feverFieldAntipyreticNameHint => '名稱（普拿疼、布洛芬...）';

  @override
  String get feverHintTapToEdit => '點擊數字即可編輯';

  @override
  String get feverDirectEditDialogTitle => '編輯體溫';

  @override
  String get feverDirectEditDialogHint => '例如：38.7';

  @override
  String get feverLogLabelWithAntipyretic => '已服退燒藥';

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
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get navHoy => '今日';

  @override
  String get navSintomas => '症狀記錄';

  @override
  String get navMovimiento => '活動動態';

  @override
  String get navBotiquin => '隨身藥箱';

  @override
  String get navClinica => '臨床數據';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '儲存';

  @override
  String get actionImport => '匯入';

  @override
  String get actionContinue => '繼續';

  @override
  String get actionUnderstood => '我知道了';

  @override
  String get languageSectionTitle => 'IDIOMA / 語言設定 ';

  @override
  String get languageFootnote => '語言變更將套用至全域應用程式，這不會影響您的既有數據。';

  @override
  String get myDataTitle => '我的數據資產';

  @override
  String get arcoRightsBlurb => '您有權隨時查閱、導出、匯入或永久刪除您的個人紀錄。';

  @override
  String get exportDataButton => '導出我的數據';

  @override
  String get importFileButton => '從檔案匯入';

  @override
  String get importPasteButton => '貼上文字匯入';

  @override
  String get wipeAllButton => '清空所有資料';

  @override
  String get wipeWarningFootnote => '此操作將清除所有使用者檔案、紀錄與設定。此清除不可逆。';

  @override
  String get actionHide => '隱藏';

  @override
  String get hintTapTip => '提示：在「症狀記錄」中，點擊庫存項目即可記錄。長按特定項目可進行編輯。';

  @override
  String get sectionPending => '待辦核對';

  @override
  String get sectionWeather => '今日氣象摘要';

  @override
  String get headerTodayIs => '今天是';

  @override
  String get pacingActiveState => '休息日 — 允許放空、不設預期';

  @override
  String get pacingInactiveState => '標記今日為休息日';

  @override
  String outcomeCardTimePrefix(String hours) {
    return '$hours 小時前您服用了';
  }

  @override
  String get outcomeCardForSymptom => '以緩解您的';

  @override
  String get outcomeCardInitialState => '當時嚴重度為';

  @override
  String get outcomeCardQuestionNow => '目前感覺如何？';

  @override
  String get outcomeCardAttributionQuestion => '您認為當前的轉變主要歸因於？';

  @override
  String get outcomeActionAddFactor => '其他伴隨因素';

  @override
  String get sectionMentalDetails => '心理與認知細節';

  @override
  String get mentalIntensitySubtitle => '當下的強度表現';

  @override
  String get summaryTitle => '今日狀態簡要';

  @override
  String get summaryEmptyPacing => '🛡️ 休息日。您目前尚未記錄任何內容 — 這很好，請好好放鬆。';

  @override
  String get summaryEmptyNormal => '您今天尚未登錄任何數據。目前感覺怎麼樣？';

  @override
  String summarySymptomSingle(String name, String label) {
    return '您記錄了 1 項症狀：$name （狀態：$label）。';
  }

  @override
  String summarySymptomPlural(int count, String name, String label) {
    return '您已記錄 $count 項症狀 — 其中感受最顯著的是 $name （狀態：$label）。';
  }

  @override
  String summaryStructuralSingle(String zone) {
    return '您在 $zone 發生了 1 次結構性事件。';
  }

  @override
  String summaryStructuralPlural(int count) {
    return '您今天共記錄了 $count 次結構性事件。';
  }

  @override
  String summaryDosesSentence(int totalDoses, String shown, int extraCount) {
    String _temp0 = intl.Intl.pluralLogic(
      extraCount,
      locale: localeName,
      other: ' 以及其他 $extraCount 項',
      zero: '',
    );
    return '您服用了 $totalDoses 次藥物：$shown$_temp0。';
  }

  @override
  String summaryMoodSentence(String statesStr, String extra) {
    return '您記錄的心情與體感反應：$statesStr$extra。';
  }

  @override
  String get summaryPacingFooter => '🛡️ 您已選擇適度配速並保留體能。這非常有價值。';

  @override
  String get wisdomBannerTitle => '✨ 斑馬哲思 🦓';

  @override
  String get bowelCountToday => '最近一次排便：今天';

  @override
  String get bowelCountYesterday => '最近一次排便：昨天';

  @override
  String bowelCountDaysAgo(int days) {
    return '最近一次排便： $days 天前';
  }

  @override
  String distentionBannerMessage(int days) {
    return '您已有 $days 天未進行排便 — 腹脹感與腹部不適感可能會持續累積。';
  }

  @override
  String get distentionBannerAction => '前往症狀記錄';

  @override
  String get severityNone => '無症狀';

  @override
  String get severityMild => '輕微';

  @override
  String get severityModerate => '中度顯著';

  @override
  String get severityIntense => '強烈不適';

  @override
  String get severityUnbearable => '無法忍受';

  @override
  String get reasonNatural => '症狀常態性自然轉變';

  @override
  String get reasonMedicationHelped => '我認為此藥物發揮了緩解作用';

  @override
  String get reasonOtherTrigger => '其他誘發因素（飲食、壓力、天氣等）';

  @override
  String get reasonAdditionalMed => '期間亦服用了其他伴隨藥物';

  @override
  String get reasonUnsure => '不確定確切原因';

  @override
  String get mentalStateMood => '整體心境';

  @override
  String get mentalStateAnxiety => '焦慮感';

  @override
  String get mentalStateBrainFog => '腦霧狀態';

  @override
  String get mentalStateDissociation => '解離/失神現象';

  @override
  String get mentalStateIrritability => '易怒情緒';

  @override
  String get mentalStateEmotionalEnergy => '心理能量能見度';

  @override
  String get outcomeCoarsePending => '待核對';

  @override
  String get outcomeCoarseMuchBetter => '顯著改善';

  @override
  String get outcomeCoarseBetter => '有所緩解';

  @override
  String get outcomeCoarseEqual => '不變/持平';

  @override
  String get outcomeCoarseWorse => '加劇';

  @override
  String get outcomeCoarseMuchWorse => '顯著加劇';

  @override
  String get pubMedNoAuthor => '未登載作者';

  @override
  String get quadrantActivatedUnpleasant => '高激活 · 不適感';

  @override
  String get quadrantActivatedPleasant => '高激活 · 舒適感';

  @override
  String get quadrantCalmUnpleasant => '低激活 · 不適感';

  @override
  String get quadrantTeaserActivatedUnpleasant => '緊繃、焦慮';

  @override
  String get quadrantTeaserActivatedPleasant => '充沛活力、喜悅';

  @override
  String get quadrantTeaserCalmUnpleasant => '疲憊耗竭、低落';

  @override
  String get quadrantTeaserCalmPleasant => '平靜、祥和';

  @override
  String get bowelBucketConstipation => '便秘狀態';

  @override
  String get bowelBucketNormal => '排便正常';

  @override
  String get bowelBucketDiarrea => '腹瀉狀態';

  @override
  String get sleepQualityBad => '極差';

  @override
  String get sleepQualityRegular => '普通';

  @override
  String get sleepQualityGood => '良好';

  @override
  String get sleepQualityVeryGood => '極佳';

  @override
  String get beverageWater => '純水';

  @override
  String get beverageElectrolyte => '電解質補充飲';

  @override
  String get beverageCoffee => '咖啡';

  @override
  String get beverageOther => '其他飲品';

  @override
  String get sodiumPinch => '微量食鹽';

  @override
  String get sodiumSachet => '電解質沖泡包';

  @override
  String get sodiumSaltySnack => '高鈉鹹味點心';

  @override
  String get hrvContextMorning => '晨間測量';

  @override
  String get hrvContextAfternoon => '午後測量';

  @override
  String get hrvContextEvening => '夜間測量';

  @override
  String get hrvContextPostExercise => '運動後測量';

  @override
  String get hrvContextOther => '其他情境測量';

  @override
  String legacyIntensityLabel(String value) {
    return '既往強度紀錄：$value/5';
  }

  @override
  String get botiquinTabTitle => '隨身藥箱';

  @override
  String get botiquinActionCreate => '新增常備藥物';

  @override
  String get botiquinInteractionsTitle => '藥物/病理交互作用警示';

  @override
  String get botiquinGroupsTitle => '常備組合群組';

  @override
  String get botiquinGroupsEmptyHeadline => '🌙 夜間服藥組合 · ☀️ 晨間服藥組合';

  @override
  String get botiquinGroupsEmptyBody => '將您經常同時服用的幾種藥物歸類為同一組合。一鍵即可快速登錄全組劑量紀錄。';

  @override
  String get botiquinActionCreateGroup => '建立新組合';

  @override
  String get botiquinNoMedsDialogTitle => '藥箱目前無常備藥';

  @override
  String get botiquinNoMedsDialogBody => '在建立常備組合前，請先在您的隨身藥箱中新增至少一項藥物紀錄。';

  @override
  String botiquinRowMedsCountLabel(int count) {
    return '內含 $count 項藥物';
  }

  @override
  String get botiquinActionEditTooltip => '編輯變更';

  @override
  String get botiquinBatchSheetTitle => '批量登錄群組';

  @override
  String get botiquinBatchSheetSubtitle => '系統即將記錄以下劑量數據：';

  @override
  String botiquinBatchOrphanWarning(int count) {
    return '⚠️ 組合內包含 $count 項已自藥箱移除的藥物，系統登錄時將自動跳過。';
  }

  @override
  String botiquinBatchActionSubmit(int count) {
    return '登錄這 $count 筆劑量數據';
  }

  @override
  String get botiquinEmptyStateHeadline => '藥箱目前空空如也';

  @override
  String get botiquinEmptyStateSubtitle => '點擊下方按鈕即可建立您的第一項常用藥物。';

  @override
  String botiquinDoseLoggedTodayBadge(String qty) {
    return '今日已服 $qty';
  }

  @override
  String botiquinDeleteConfirmTitle(String name) {
    return '確認移除 $name？';
  }

  @override
  String botiquinDeleteConfirmBody(String name) {
    return '移除後系統仍會保留既往的歷史服藥紀錄以利您的臨床報告分析，但 $name 將不再出現在常用藥箱列表中。';
  }

  @override
  String get botiquinActionDelete => '確認確認移除';

  @override
  String get botiquinLogDoseSheetTitle => '登錄服藥劑量';

  @override
  String botiquinLogDoseTotalCalculated(String total, String unit) {
    return '= 當次攝入共 $total $unit';
  }

  @override
  String get botiquinLogDoseSymptomPrompt => '此劑量是否用於特定症狀？';

  @override
  String get botiquinLogDoseSymptomNone => '無對應症狀（常規服用）';

  @override
  String botiquinLogDoseTrackOutcomeToggle(int hours) {
    return '系統將於 $hours 小時後提醒追蹤此藥物的緩解成效';
  }

  @override
  String get botiquinDoseListTitle => '今日服藥紀錄';

  @override
  String get botiquinDoseListFootnote => '點擊 × 可單獨刪除某一特定時間的紀錄（這對於修正誤觸登錄非常實用）。';

  @override
  String get botiquinDoseItemDeleteConfirmTitle => '刪除此筆服藥紀錄';

  @override
  String botiquinDoseItemDeleteConfirmBody(String name, String time) {
    return '您確定要刪除在 $time 登錄的 $name 紀錄嗎？此刪除操作無法撤銷。';
  }

  @override
  String botiquinTimeTodayAt(String time) {
    return '今天 $time';
  }

  @override
  String botiquinTimePastAt(int day, int month, String time) {
    return '$day/$month 於 $time';
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
  String get onboardingFallbackProfileName => '我的檔案';

  @override
  String get onboardingStepWelcomeTitle => 'ZebraUp';

  @override
  String get onboardingStepWelcomeSubtitle => '您的就醫專屬數位夥伴。';

  @override
  String get onboardingStepWelcomeBody =>
      '門診時間往往很短。在經歷辛苦的一週後，人的記憶力也是。ZebraUp 協助您精確記錄症狀、用藥與健康趨勢，讓您在每次就診時都能提出具體數據——而不是一坐在醫生面前，原本想說的話就忘光了。此外，我們知道您也有照顧他人的需求，因此您也可以將家人或寵物納入記錄管理。';

  @override
  String get onboardingStepWelcomePrivacyNote =>
      '您的所有數據皆安全地儲存於本機裝置中，我們絕不會將任何資料上傳至網際網路。';

  @override
  String get onboardingStepWelcomeMedicalDisclaimer =>
      '本應用程式並非醫療器材。其內容不具備診斷、治療、緩解或預防任何疾病之醫療效力。';

  @override
  String get onboardingStepNameTitle => '讓我們開始吧。';

  @override
  String get onboardingStepNameQuestion => '我們該如何稱呼您？';

  @override
  String get onboardingStepNameFootnote => '此名稱僅用於個人化您的應用程式介面，您隨時可以在日後進行變更。';

  @override
  String get onboardingStepNameHint => '您的名字或暱稱';

  @override
  String get onboardingStepConditionsTitle => '既有確診診斷。';

  @override
  String get onboardingStepConditionsBody =>
      '您目前面臨哪些健康狀況？這些資訊將用於為您的交互作用與臨床報告提供脈絡。您隨時可以新增、修改或跳過此步驟。';

  @override
  String get onboardingStepConditionsHint => '例如：hEDS, POTS, MCAS...';

  @override
  String get onboardingStepConditionsEmpty => '目前尚未新增任何診斷。您可以先跳過此步驟。';

  @override
  String get onboardingStepMedsTitle => '設定常用藥箱。';

  @override
  String get onboardingStepMedsBody =>
      '在此新增您的常規服用藥物。設定完成後，您即可在「隨身藥箱」分頁中一鍵快速登錄每次的服藥劑量紀錄。';

  @override
  String get onboardingStepMedsNameHint => '藥物名稱';

  @override
  String get onboardingStepMedsDoseHint => '劑量（例如：400mg）';

  @override
  String get onboardingStepMedsEmpty => '目前尚未新增藥物。您可以先跳過此步驟。';

  @override
  String get symptomsSectionStructuralZones => '關節與結構部位';

  @override
  String get symptomsSectionBowelTransit => '腸道排空狀態';

  @override
  String get symptomsActionAddHemorrhoid => '痔瘡相關問題';

  @override
  String get symptomsSectionTodaysLogs => '今日症狀與體感紀錄';

  @override
  String get symptomsFootnoteLongPressEdit => '長按任一項目即可修正記錄時間、嚴重度或備註細節。';

  @override
  String get symptomsSectionTrending => '本週高頻趨勢（過去 7 天）';

  @override
  String get symptomsTrendingEmpty => '本週尚未累積顯著的重複症狀趨勢。';

  @override
  String get symptomsSectionVault => '個人症狀庫庫存';

  @override
  String get symptomsVaultPlaceholder => '+ 新增自訂症狀至庫存...';

  @override
  String symptomsModalLogHeader(String zone) {
    return '記錄部位：$zone';
  }

  @override
  String symptomsModalEditHeader(String zone, String type) {
    return '編輯：$zone / $type';
  }

  @override
  String symptomsModalEditSymptomHeader(String name) {
    return '編輯症狀：$name';
  }

  @override
  String get symptomsLabelOptionalNote => '選填備註（情境脈絡、潛在誘因等）';

  @override
  String get symptomsLabelOptionalNoteSimple => '選填備註';

  @override
  String get symptomsLabelSeverityGrading => '嚴重程度評級';

  @override
  String get symptomsActionLogUnrated => '僅記錄不評級';

  @override
  String get symptomsUnratedLabelSuffix => '未評級';

  @override
  String get symptomsUnratedInlineWarning => '此項目目前無嚴重度評級。點擊圓點即可為其指派權重。';

  @override
  String get symptomsActionSaveChanges => '確認修改變更';

  @override
  String get symptomsActionSave => '確認確認儲存';

  @override
  String get zoneCervical => '頸椎區域';

  @override
  String get zoneHombros => '雙肩關節';

  @override
  String get zoneMunecas => '手腕關節';

  @override
  String get zoneManos => '手部掌指';

  @override
  String get zoneLumbarPelvis => '腰椎/骨盆腔';

  @override
  String get zoneCaderas => '髖關節';

  @override
  String get zoneRodillas => '雙膝關節';

  @override
  String get zoneTobillos => '腳踝關節';

  @override
  String get structTypeSubluxation => '關節半脫位';

  @override
  String get structTypeDislocation => '關節完全脫位';

  @override
  String get structTypeInstability => '關節不穩定感';

  @override
  String get structTypeJointPain => '關節鈍痛/銳痛';

  @override
  String get structTypeMyofascial => '肌筋膜疼痛';

  @override
  String get structTypeNeuropathic => '神經源性抽痛';

  @override
  String bowelLabelBristolType(String type) {
    return '布里斯托第 $type 型';
  }

  @override
  String get bowelLabelUrgency => '伴隨急迫感';

  @override
  String get bowelLabelBleeding => '伴隨便血';

  @override
  String get bowelLabelIncomplete => '排便不完全感';

  @override
  String get movementSectionPacingActive => '今日為安排的休息日。適度休息也是體能配速的核心。';

  @override
  String get movementSectionHistoryTitle => '今日動態與恢復紀錄';

  @override
  String get movementFootnoteLongPressEdit => '長按特定歷史項目即可進行編輯修正。';

  @override
  String get movementEmptyStateHeadline => '身體活動與修復放鬆同等重要。';

  @override
  String get movementEmptyStateSubtitle => '不論是散步、拉伸、物理治療或按摩，皆是彌足珍貴的身體照顧歷程。';

  @override
  String get movementSectionActivityTitle => '自主身體活動';

  @override
  String get movementActivityPlaceholder => '+ 新增自訂活動（如：游泳、單車、舞蹈…）';

  @override
  String get movementSectionTherapyTitle => '臨床與被動治療';

  @override
  String get movementTherapyPlaceholder => '+ 新增特殊治療（如：能量療癒、漂浮…）';

  @override
  String activityModalLogHeader(String name) {
    return '記錄項目：$name';
  }

  @override
  String activityModalEditHeader(String name) {
    return '編輯項目：$name';
  }

  @override
  String get activityFieldDurationHint => '持續時間（分鐘）';

  @override
  String get activityFieldSetsHint => '組數';

  @override
  String get activityFieldRepsHint => '每組次數';

  @override
  String get activityFieldHhrHint => '選填心率區間變化（例如：70→110）';

  @override
  String activityLabelEffortSlider(int value) {
    return '自覺運動強度 (RPE)：$value/10';
  }

  @override
  String activityLabelFeelingSlider(int value) {
    return '本體心理感受：$value/5';
  }

  @override
  String get activityActionTogglePainRating => '評估運動前後的疼痛指數 e-VAS（選填）';

  @override
  String get activityLabelPainBefore => '運動前疼痛評級';

  @override
  String get activityLabelPainAfter => '運動後疼痛評級';

  @override
  String get activityActionSubmitLog => '確認儲存活動數據';

  @override
  String get activityActionSubmitChanges => '確認儲存修改變更';

  @override
  String get painLabelNone => '無痛';

  @override
  String get painLabelMild => '輕度';

  @override
  String get painLabelModerate => '中度';

  @override
  String get painLabelIntense => '劇烈';

  @override
  String get painLabelSevere => '極度嚴重';

  @override
  String painDeltaLabelImproved(int count) {
    return '疼痛指數改善了 $count 個層級';
  }

  @override
  String painDeltaLabelWorsened(int count) {
    return '疼痛指數加劇了 $count 個層級';
  }

  @override
  String get painDeltaLabelUnchanged => '疼痛指數持平';

  @override
  String logSubtitleMetricDuration(int minutes) {
    return '$minutes 分鐘';
  }

  @override
  String logSubtitleMetricSetsReps(String sets, String reps) {
    return '$sets 組 × $reps 次';
  }

  @override
  String logSubtitleActivityTemplate(
    String detail,
    int effort,
    int feeling,
    String pain,
    Object painSuffix,
  ) {
    return '細節：$detail · 自覺強度 $effort/10 · 心理體感 $feeling/5$painSuffix ';
  }

  @override
  String logSubtitlePainDeltaImproved(int levels) {
    return '疼痛 ↓$levels 級';
  }

  @override
  String logSubtitlePainDeltaWorsened(int levels) {
    return '疼痛 ↑$levels 級';
  }

  @override
  String get logSubtitlePainDeltaUnchanged => '疼痛持平';

  @override
  String get feelingLabelLevel1 => '🤕 伴隨疼痛 / 誘發受傷恐懼';

  @override
  String get feelingLabelLevel2 => '😟 感到不適 / 動作有所防禦';

  @override
  String get feelingLabelLevel3 => '😐 狀態表現持平';

  @override
  String get feelingLabelLevel4 => '😊 身體放鬆舒適';

  @override
  String get feelingLabelLevel5 => '💪 感覺強壯且充滿安全感';

  @override
  String get onboardingHaveProfileTitle => '我已經有備份的個人檔案';

  @override
  String get onboardingHaveProfileSubtitle => '從既有的 JSON 檔案匯入數據';

  @override
  String get onboardingImportChoiceTitle => '請選擇匯入方式';

  @override
  String get onboardingImportFromFile => '從檔案取回';

  @override
  String get onboardingImportFromPaste => '直接貼上文字';

  @override
  String get feverSectionTitle => '發燒記錄';

  @override
  String get feverActionAddReading => '+ 測量體溫';

  @override
  String get feverModalLogHeader => '記錄體溫';

  @override
  String get feverModalEditHeader => '編輯數值';

  @override
  String get feverFieldSiteLabel => '測量部位';

  @override
  String get feverFieldAntipyreticLabel => '退燒藥';

  @override
  String get feverFieldAntipyreticToggle => '已服用退燒藥物';

  @override
  String get feverFieldAntipyreticNameHint => '名稱（普拿疼、布洛芬...）';

  @override
  String get feverHintTapToEdit => '點擊數字即可編輯';

  @override
  String get feverDirectEditDialogTitle => '編輯體溫';

  @override
  String get feverDirectEditDialogHint => '例如：38.7';

  @override
  String get feverLogLabelWithAntipyretic => '已服退燒藥';

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
}
