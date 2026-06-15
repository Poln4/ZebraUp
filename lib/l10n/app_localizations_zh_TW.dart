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
  String get languageSectionTitle => '語言設定 / LANGUAGE';

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
  String get quadrantCalmPleasant => '低激活 · 舒適感';

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
}
