import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import '../services/fever_analysis.dart';
import '../services/report_trends.dart';
import '../services/profile_io_service.dart';
import '../services/interaction_engine.dart';
import '../services/pubmed_service.dart';
import '../services/weather_service.dart';
import '../services/vademecum_service.dart';
import '../widgets/condition_info_sheet.dart';
import '../widgets/life_event_form_sheet.dart';
import '../widgets/fever_form_sheet.dart';
import '../services/structural_taxonomy.dart';
import '../services/clinical_localizations.dart';
import '../services/condition_labels.dart';
import '../services/symptom_definitions_service.dart';
import '../l10n/app_localizations.dart';
import 'onboarding_screen.dart';
import 'hoy_tab.dart';
import 'botiquin_tab.dart';
import 'sintomas_tab.dart';
import 'movimiento_tab.dart';
import 'investigacion_tab.dart';
import 'timestamp_picker.dart';
import '../models/action_taken.dart';

class MainAppScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final double fontScale;
  final ValueChanged<double> onScaleFont;
  final Locale locale;
  final ValueChanged<Locale> onChangeLocale;

  const MainAppScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.fontScale,
    required this.onScaleFont,
    required this.locale,
    required this.onChangeLocale,
  });

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  // Sprint F.D — persist an updated ActionTaken
  // after the follow-up effectiveness dialog is saved.
  void _onCompleteFollowUp(ActionTaken updated) {
    final idx = _activeProfile!.actionsHistory.indexWhere(
      (a) => a.id == updated.id,
    );
    if (idx < 0) return;
    setState(() {
      _activeProfile!.actionsHistory[idx] = updated;
    });
    _saveData();
  }

  // Sprint F.E — persist a fresh ActionTaken from
  // RetroSymptomDialog. Unlike _onCompleteFollowUp (F.D),
  // this ADDS rather than updates.
  void _onSaveRetroSymptom(ActionTaken action) {
    setState(() {
      _activeProfile!.actionsHistory.add(action);
    });
    _saveData();
  }

  List<Profile> _profiles = [];
  Profile? _activeProfile;

  // Variables para la Base de Datos Clínica, de Sabiduría y Emociones (EMA)
  List<WisdomQuote> _wisdomDatabase = [];
  // _clinicalLibraryDatabase removed in C.2 — compendium now reads from
  // _wisdomDatabase, filtering entries by `source.isNotEmpty` to skip
  // the 3 hardcoded base quotes.
  Map<MoodQuadrant, List<EmaMood>> _moodDictionary =
      {}; // <--- NUEVO: Diccionario EMA

  WisdomQuote? _currentWisdom;
  final Random _random = Random();

  final ProfileIoService _profileIo = ProfileIoService();
  final PubMedService _pubmed = PubMedService();
  final MedlinePlusService _medlinePlus = MedlinePlusService();
  final WeatherService _weather = WeatherService();
  WeatherDay? _todayWeather;

  Future<void> _fetchTodayWeather() async {
    final lat = _activeProfile?.homeLatitude;
    final lng = _activeProfile?.homeLongitude;
    if (lat == null || lng == null) {
      setState(() => _todayWeather = null);
      return;
    }
    final w = await _weather.getToday(lat: lat, lng: lng);
    if (mounted) setState(() => _todayWeather = w);
  }

  int _currentNavIndex = 0;
  DateTime _selectedDate = DateTime.now();
  String _clinicaTabView = "Reporte"; // Reporte | Biblioteca | Investigación

  // PHASE 4a — Report range selector state
  // _reportRangeDays is the active preset (1, 7, or 30) when _customRange
  // is null. When _customRange is non-null, the custom range overrides
  // any preset selection and "Personalizado" is shown as selected in the
  // UI.
  int _reportRangeDays = 1;
  DateTimeRange? _customRange;

  final _profileNameController = TextEditingController();
  final _newDiagnosisController = TextEditingController();
  final _newSymptomController = TextEditingController();
  final _newMedNameController = TextEditingController();
  final _newMedDoseController = TextEditingController();

  // -------------------------------------------------------------------------
  // LIFECYCLE
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _loadUserProfiles();
    await _loadLibraries();
    await _fetchTodayWeather();
    setState(() {});
  }

  @override
  void dispose() {
    _profileNameController.dispose();
    _newDiagnosisController.dispose();
    _newSymptomController.dispose();
    _newMedNameController.dispose();
    _newMedDoseController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // DATOS Y JSON (Integración EMA + Sabiduría)
  // -------------------------------------------------------------------------

  Future<void> _loadLibraries() async {
    List<WisdomQuote> baseQuotes = [
      WisdomQuote(
        textEs:
            "Descansar no es rendirse; es una intervención médica necesaria para tu sistema nervioso.",
        textEn:
            "Resting is not giving up; it is a necessary medical intervention for your nervous system.",
        textZh: "休息不是放棄;這是你的神經系統必要的醫療介入。",
        category: "Pacing",
      ),
      WisdomQuote(
        textEs:
            "Tus síntomas son reales, incluso cuando los exámenes de rutina no los muestran.",
        textEn:
            "Your symptoms are real, even when routine tests don't show them.",
        textZh: "你的症狀是真實的,即使常規檢查沒有顯示出來。",
        category: "Validación",
      ),
      WisdomQuote(
        textEs: "El mundo es tu papa. Hoy toca reparar.",
        textEn: "The world is your potato. Today is for repairing.",
        textZh: "今天是馬鈴薯日,該修復了。",
        category: "Potato Day",
      ),
    ];

    // 1. Cargar Zebra Wisdom (Datos clínicos y validación)
    try {
      final String wisdomString = await rootBundle.loadString(
        'assets/zebra_wisdom.json',
      );
      final Map<String, dynamic> wisdomData = jsonDecode(wisdomString);
      final List<dynamic> jsonFacts = wisdomData['facts'] ?? [];

      setState(() {
        // C.2: compendium reads WisdomQuote directly (with `source` field)
        // — no parallel ClinicalArticle list anymore.
        _wisdomDatabase =
            baseQuotes +
            jsonFacts
                .map(
                  (item) => WisdomQuote.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList();
      });
    } catch (e) {
      debugPrint("Error cargando zebra_wisdom.json: $e");
      _wisdomDatabase = baseQuotes;
    }

    // 2. Cargar EMA Moods (Diccionario de emociones para el Mood Tracker)
    try {
      final String moodString = await rootBundle.loadString(
        'assets/ema_moods.json',
      );
      final Map<String, dynamic> moodData = jsonDecode(moodString);

      final Map<MoodQuadrant, List<EmaMood>> loadedMoods = {
        MoodQuadrant.activatedUnpleasant: [],
        MoodQuadrant.activatedPleasant: [],
        MoodQuadrant.calmUnpleasant: [],
        MoodQuadrant.calmPleasant: [],
      };

      for (final key in moodData.keys) {
        final quad = MoodQuadrantLabels.fromJsonCategory(key);
        final List<dynamic> list = moodData[key];
        loadedMoods[quad]!.addAll(
          list.map((m) => EmaMood.fromMap(m as Map<String, dynamic>)),
        );
      }

      setState(() {
        _moodDictionary = loadedMoods;
      });
    } catch (e) {
      debugPrint("Error cargando ema_moods.json: $e");
    }

    _restoreOrPickDailyWisdom();
  }

  void _restoreOrPickDailyWisdom() {
    if (_wisdomDatabase.isEmpty) return;
    final box = Hive.box('zebraBox');
    final todayKey = _getDateKey(DateTime.now());
    final storedDate = box.get('wisdomDateKey') as String?;
    final storedIdx = box.get('wisdomIndex') as int?;

    int idx;
    if (storedDate == todayKey &&
        storedIdx != null &&
        storedIdx >= 0 &&
        storedIdx < _wisdomDatabase.length) {
      idx = storedIdx;
    } else {
      idx = _random.nextInt(_wisdomDatabase.length);
      box.put('wisdomDateKey', todayKey);
      box.put('wisdomIndex', idx);
    }
    setState(() => _currentWisdom = _wisdomDatabase[idx]);
  }

  void _changeWisdomQuote() {
    if (_wisdomDatabase.length < 2) return;
    final box = Hive.box('zebraBox');
    int newIdx;
    int safety = 0;
    do {
      newIdx = _random.nextInt(_wisdomDatabase.length);
      safety++;
    } while (_currentWisdom != null &&
        _wisdomDatabase[newIdx].textEs == _currentWisdom!.textEs &&
        safety < 10);
    box.put('wisdomDateKey', _getDateKey(DateTime.now()));
    box.put('wisdomIndex', newIdx);
    setState(() => _currentWisdom = _wisdomDatabase[newIdx]);
  }

  // -------------------------------------------------------------------------
  // ARCO RIGHTS (Export / Import / Wipe)
  // -------------------------------------------------------------------------

  // ( ... Todo el bloque de Exportar, Importar y Wipe permanece intacto ... )
  // Reinsertando por completitud del archivo:

  Future<void> _exportActiveProfile() async {
    if (_activeProfile == null) return;
    final t = AppLocalizations.of(context)!;
    try {
      final filename = await _profileIo.exportProfile(_activeProfile!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.exportSuccess(filename)),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.exportError(e.toString()))));
    }
  }

  /// Traduce un error tipado del servicio a texto localizado para el usuario.
  String _importErrorMessage(Object e, AppLocalizations t) {
    if (e is ImportException) {
      return switch (e.code) {
        ImportErrorCode.unreadableFile => t.errImportUnreadable,
        ImportErrorCode.invalidJson => t.errImportInvalidJson,
        ImportErrorCode.notZebraUp => t.errImportNotZebra,
        ImportErrorCode.unknownSchema => t.errImportUnknownSchema,
        ImportErrorCode.schemaMismatch => t.errImportSchemaMismatch(
          e.detail ?? '?',
          ProfileIoService.schemaVersion.toString(),
        ),
        ImportErrorCode.missingProfile => t.errImportMissingProfile,
        ImportErrorCode.corruptProfile => t.errImportCorruptProfile,
      };
    }
    return e.toString();
  }

  /// Vía A: importar desde archivo (file_picker).
  Future<void> _importProfileFromFile() async {
    final t = AppLocalizations.of(context)!;
    final ImportPreview? preview;
    try {
      preview = await _profileIo.pickAndValidateImport();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.importCancelled(_importErrorMessage(e, t)))),
      );
      return;
    }
    if (preview == null || !mounted) return;
    await _confirmAndApplyImport(preview);
  }

  /// Vía B: importar pegando el JSON como texto. Sin plugins — funciona
  /// siempre, incluso en PWA de iOS o si file_picker falla.
  Future<void> _importProfileFromPaste() async {
    final t = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.pasteImportTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.pasteImportInstructions,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 6,
              autofocus: true,
              style: const TextStyle(fontSize: 11, fontFamily: 'Courier'),
              decoration: InputDecoration(
                hintText: t.pasteImportHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(t.actionImport),
          ),
        ],
      ),
    );
    if (raw == null || raw.trim().isEmpty || !mounted) return;

    final ImportPreview preview;
    try {
      preview = _profileIo.validateJsonString(raw.trim());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.importCancelled(_importErrorMessage(e, t)))),
      );
      return;
    }
    await _confirmAndApplyImport(preview);
  }

  /// Núcleo compartido: diálogo de confirmación + aplicación del perfil.
  /// Ambas vías de importación terminan aquí.
  Future<void> _confirmAndApplyImport(ImportPreview preview) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.importDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.importDialogName(preview.profile.name),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (preview.exportedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                t.importDialogExportedAt(
                  preview.exportedAt!.toLocal().toString().split('.').first,
                ),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            Text(t.importDialogContains(preview.totalEvents)),
            const SizedBox(height: 4),
            Text(
              '• ${preview.symptomCount} ${t.nounSymptoms}\n'
              '• ${preview.doseCount} ${t.nounDoses}\n'
              '• ${preview.structuralCount} ${t.nounStructural}\n'
              '• ${preview.activityCount} ${t.nounActivities}\n'
              '• ${preview.therapyCount} ${t.nounTherapies}\n'
              '• ${preview.moodCount} ${t.nounMoods}\n'
              '• ${preview.mentalCount} ${t.nounMental}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              t.importDialogFootnote,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.actionImport),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final newProfile = Profile.fromMap({
      ...preview.profile.toMap(),
      'id': '${DateTime.now().millisecondsSinceEpoch}-imported',
    });
    _profileIo.finalizeImport(preview);
    setState(() {
      _profiles.add(newProfile);
      _activeProfile = newProfile;
      _updateControllers();
      _saveData();
    });
    await _fetchTodayWeather();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.importSuccess)));
    }
  }

  // PHASE 5.1d follow-up — Onboarding import flow.
  //
  // Self-contained version of the file/paste import flow that returns
  // a Profile? for the OnboardingScreen to consume. The caller passes
  // the result to onComplete, which persists via the same path as a
  // fresh-onboarding profile. Validation logic mirrors
  // _importProfileFromFile + _importProfileFromPaste +
  // _confirmAndApplyImport, but skips the snackbar at the end (the
  // onboarding screen will dismiss itself on success).
  Future<Profile?> _onboardingImportFlow() async {
    final t = AppLocalizations.of(context)!;

    // Step 1: pick file vs paste
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(t.onboardingImportChoiceTitle),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'file'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.upload_file_outlined),
                  const SizedBox(width: 12),
                  Text(t.onboardingImportFromFile),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'paste'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.content_paste_go_outlined),
                  const SizedBox(width: 12),
                  Text(t.onboardingImportFromPaste),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return null;

    // Step 2: get ImportPreview based on chosen method
    ImportPreview? preview;
    try {
      if (choice == 'file') {
        preview = await _profileIo.pickAndValidateImport();
      } else {
        final ctrl = TextEditingController();
        final raw = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t.pasteImportTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.pasteImportInstructions,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  maxLines: 6,
                  autofocus: true,
                  style: const TextStyle(fontSize: 11, fontFamily: 'Courier'),
                  decoration: InputDecoration(
                    hintText: t.pasteImportHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(t.actionCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text),
                child: Text(t.actionImport),
              ),
            ],
          ),
        );
        if (raw == null || raw.trim().isEmpty || !mounted) return null;
        preview = _profileIo.validateJsonString(raw.trim());
      }
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.importCancelled(_importErrorMessage(e, t)))),
      );
      return null;
    }

    if (preview == null || !mounted) return null;
    final p = preview; // local alias to satisfy null-safety in dialog builder

    // Step 3: confirmation dialog with preview details
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.importDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.importDialogName(p.profile.name),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (p.exportedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                t.importDialogExportedAt(
                  p.exportedAt!.toLocal().toString().split('.').first,
                ),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            Text(t.importDialogContains(p.totalEvents)),
            const SizedBox(height: 4),
            Text(
              '• ${p.symptomCount} ${t.nounSymptoms}\n'
              '• ${p.doseCount} ${t.nounDoses}\n'
              '• ${p.structuralCount} ${t.nounStructural}\n'
              '• ${p.activityCount} ${t.nounActivities}\n'
              '• ${p.therapyCount} ${t.nounTherapies}\n'
              '• ${p.moodCount} ${t.nounMoods}\n'
              '• ${p.mentalCount} ${t.nounMental}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              t.importDialogFootnote,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.actionImport),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return null;

    _profileIo.finalizeImport(p);

    // Return Profile with fresh id. The OnboardingScreen will pass this
    // to onComplete, which handles persistence (setState + _saveData).
    return Profile.fromMap({
      ...p.profile.toMap(),
      'id': '${DateTime.now().millisecondsSinceEpoch}-imported',
    });
  }

  Future<void> _wipeAllData() async {
    final t = AppLocalizations.of(context)!;
    final magicWord = t.dialogWipeFinalMagicWord;
    final firstOk = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.dialogWipeTitle),
        content: Text(t.dialogWipeContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t.actionContinue,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (firstOk != true || !mounted) return;

    final typedCtrl = TextEditingController();
    final secondOk = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text(t.dialogWipeFinalTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.dialogWipeFinalContentTemplate(magicWord)),
              const SizedBox(height: 12),
              TextField(
                controller: typedCtrl,
                autofocus: true,
                decoration: InputDecoration(hintText: magicWord),
                onChanged: (_) => setDlg(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.actionCancel),
            ),
            TextButton(
              onPressed: typedCtrl.text.trim() == magicWord
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: Text(
                t.dialogWipeFinalButton,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
    if (secondOk != true || !mounted) return;

    await _profileIo.wipeEverything();
    setState(() {
      _profiles = [];
      _activeProfile = null;
      _todayWeather = null;
      _currentWisdom = null;
    });
  }

  // -------------------------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------------------------

  String _getDateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  DateTime _timestampForLog() {
    final now = DateTime.now();
    final sel = _selectedDate;
    final isToday =
        sel.year == now.year && sel.month == now.month && sel.day == now.day;
    if (isToday) return now;
    return DateTime(
      sel.year,
      sel.month,
      sel.day,
      now.hour,
      now.minute,
      now.second,
    );
  }

  /// C.4: True iff the active profile mentions cefalea anywhere —
  /// in the symptom vault or in the listed conditions. Used to gate
  /// the headache_detail toggle's visibility in the settings drawer
  /// so detail-layer switches that aren't relevant to the user stay
  /// hidden.
  bool _hasHeadacheRelevance() {
    final svc = SymptomDefinitionsService.instance;
    final p = _activeProfile;
    if (p == null) return false;
    for (final s in p.symptomVault) {
      if (svc.matchesSymptomKey(s, 'headache')) return true;
    }
    for (final c in p.conditions) {
      if (svc.matchesSymptomKey(c, 'headache')) return true;
    }
    return false;
  }

  /// D.1: True iff the active profile mentions fatiga anywhere —
  /// in the symptom vault or in the listed conditions. Used to gate
  /// the fatigue_detail toggle's visibility in the settings drawer
  /// so detail-layer switches that aren't relevant to the user stay
  /// hidden. Mirrors _hasHeadacheRelevance.
  bool _hasFatigueRelevance() {
    final svc = SymptomDefinitionsService.instance;
    final p = _activeProfile;
    if (p == null) return false;
    for (final s in p.symptomVault) {
      if (svc.matchesSymptomKey(s, 'fatigue')) return true;
    }
    for (final c in p.conditions) {
      if (svc.matchesSymptomKey(c, 'fatigue')) return true;
    }
    return false;
  }

  /// D.2: True iff the active profile mentions dolor abdominal
  /// (including bloating / gas variants) anywhere — in the symptom
  /// vault or in the listed conditions. Aliases include dolor
  /// abdominal, cólico, hinchazón, distensión, gases, pedos, and
  /// their en / zh equivalents. Mirrors _hasHeadacheRelevance and
  /// _hasFatigueRelevance.
  bool _hasAbdominalRelevance() {
    final svc = SymptomDefinitionsService.instance;
    final p = _activeProfile;
    if (p == null) return false;
    for (final s in p.symptomVault) {
      if (svc.matchesSymptomKey(s, 'abdominal_pain')) return true;
    }
    for (final c in p.conditions) {
      if (svc.matchesSymptomKey(c, 'abdominal_pain')) return true;
    }
    return false;
  }

  // -------------------------------------------------------------------------
  // PERSISTENCE
  // -------------------------------------------------------------------------

  void _saveData() {
    final box = Hive.box('zebraBox');
    final encoded = json.encode(_profiles.map((p) => p.toMap()).toList());
    box.put('profiles', encoded);
  }

  void _loadUserProfiles() {
    final box = Hive.box('zebraBox');
    final storedData = box.get('profiles');
    if (storedData == null) {
      _profiles = [];
      return; // OJO: ya no llamamos _saveData() aquí — no hay nada que guardar
    }
    try {
      final decoded = json.decode(storedData) as List<dynamic>;
      final loaded = <Profile>[];
      for (final x in decoded) {
        try {
          loaded.add(Profile.fromMap(Map<String, dynamic>.from(x as Map)));
        } catch (e) {
          // Un perfil corrupto no debe tumbar a los demás.
          debugPrint('Perfil omitido por error de parseo: $e');
        }
      }
      if (loaded.isEmpty && decoded.isNotEmpty) {
        // Todo falló al parsear: respaldar el blob crudo ANTES de que
        // cualquier _saveData() lo sobrescriba. Recuperable manualmente.
        box.put(
          'profiles_backup_${DateTime.now().millisecondsSinceEpoch}',
          storedData,
        );
      }
      _profiles = loaded;
    } catch (e) {
      // JSON ilegible: respaldar y partir vacío SIN sobrescribir el original.
      debugPrint('Error decodificando profiles: $e');
      box.put(
        'profiles_backup_${DateTime.now().millisecondsSinceEpoch}',
        storedData,
      );
      _profiles = [];
    }
    if (_profiles.isNotEmpty) {
      _activeProfile = _profiles.first;
      _updateControllers();
    }
  }

  void _updateControllers() {
    if (_activeProfile != null) {
      _profileNameController.text = _activeProfile!.name;
    }
  }

  // -------------------------------------------------------------------------
  // BUILD ROOT
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // B.2 fix: keep Intl's global default locale aligned with the active
    // language so bare DateFormat('pattern') calls elsewhere in the app
    // render dates in the user's language without having to thread
    // l10n.localeName through every call site.
    Intl.defaultLocale = widget.locale.toString();
    final contrastColor = widget.isDarkMode ? Colors.white : Colors.black;
    final inverseContrastColor = widget.isDarkMode
        ? Colors.black
        : Colors.white;

    if (_activeProfile == null) {
      return _buildEmptyProfileScaffold(contrastColor, inverseContrastColor);
    }

    final dueOutcomesCount = _activeProfile!.getDueOutcomes().length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: inverseContrastColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: contrastColor, height: 1.0),
        ),
        title: DropdownButton<Profile>(
          value: _activeProfile,
          dropdownColor: inverseContrastColor,
          icon: Icon(Icons.arrow_drop_down, color: contrastColor),
          style: TextStyle(
            fontSize: 20,
            color: contrastColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          underline: Container(),
          onChanged: (Profile? newProfile) {
            if (newProfile != null) {
              setState(() {
                _activeProfile = newProfile;
                _fetchTodayWeather();
                _updateControllers();
              });
            }
          },
          items: _profiles
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.name.toUpperCase()),
                ),
              )
              .toList(),
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.appBarTooltipFontSize,
            icon: Icon(Icons.text_fields, color: contrastColor),
            onPressed: () => widget.onScaleFont(
              widget.fontScale >= 1.4 ? 1.0 : widget.fontScale + 0.2,
            ),
          ),
          IconButton(
            tooltip: widget.isDarkMode
                ? AppLocalizations.of(context)!.appBarTooltipLightMode
                : AppLocalizations.of(context)!.appBarTooltipDarkMode,
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: contrastColor,
            ),
            onPressed: widget.onToggleTheme,
          ),
          Builder(
            builder: (ctx) => IconButton(
              tooltip: AppLocalizations.of(context)!.appBarTooltipSettings,
              icon: Icon(
                Icons.settings_outlined,
                color: contrastColor,
                size: 28,
              ),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildSettingsDrawer(contrastColor, inverseContrastColor),
      body: Column(
        children: [
          _buildCalendarStrip(contrastColor, inverseContrastColor),
          Expanded(
            child: _buildCurrentTab(contrastColor, inverseContrastColor),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: inverseContrastColor,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: contrastColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.wb_sunny_outlined),
            label: AppLocalizations.of(context)!.navHoy,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.accessibility_new_rounded),
            label: AppLocalizations.of(context)!.navSintomas,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.self_improvement_outlined),
            label: AppLocalizations.of(context)!.navMovimiento,
          ),
          BottomNavigationBarItem(
            icon: _buildBotiquinIcon(dueOutcomesCount, contrastColor),
            label: AppLocalizations.of(context)!.navBotiquin,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics_outlined),
            label: AppLocalizations.of(context)!.navClinica,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab(Color cc, Color ic) {
    switch (_currentNavIndex) {
      case 0:
        return HoyTab(
          profile: _activeProfile!,
          selectedDate: _selectedDate,
          wisdom:
              _currentWisdom ??
              WisdomQuote(
                textEs: "Cargando sabiduría...",
                textEn: "Loading wisdom...",
                textZh: "載入智慧中...",
                category: "Loading",
              ),
          contrastColor: cc,
          inverseContrastColor: ic,
          moodDictionary:
              _moodDictionary, // <--- NUEVO: Inyectamos el JSON dict aquí
          onTogglePacing: _togglePacing,
          onLogMental: _logMental,
          onLogMood: _logMood,
          onDeleteMood: _deleteMoodEntry,
          onAnswerOutcome: _answerOutcome,
          onChangeWisdom: _changeWisdomQuote,
          todayWeather: _todayWeather,
          showHint: _shouldShowHoyHint,
          onDismissHint: _dismissHoyHint,
          // PHASE 5.2a — wire navigation for distention banner shortcut
          onNavigate: (idx) => setState(() => _currentNavIndex = idx),
          onCompleteFollowUp: _onCompleteFollowUp,
          onSaveRetroSymptom: _onSaveRetroSymptom,
          onFlareChange: () {
            _saveData();
            setState(() {});
          },
        );
      case 1:
        return _buildSintomasTab(cc, ic);
      case 2:
        return MovimientoTab(
          profile: _activeProfile!,
          selectedDate: _selectedDate,
          contrastColor: cc,
          inverseContrastColor: ic,
          onProfileChanged: () {
            setState(() {});
            _saveData();
          },
        );
      case 3:
        return _buildBotiquinTab(cc, ic);
      case 4:
      default:
        return _buildClinicaTab(cc, ic);
    }
  }

  Widget _buildBotiquinIcon(int dueCount, Color cc) {
    if (dueCount == 0) return const Icon(Icons.medical_services_outlined);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.medical_services_outlined),
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              '$dueCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProfileScaffold(Color cc, Color ic) {
    return OnboardingScreen(
      contrastColor: cc,
      inverseContrastColor: ic,
      onComplete: (newProfile) async {
        setState(() {
          _profiles.add(newProfile);
          _activeProfile = newProfile;
          _updateControllers();
          _saveData();
        });
        await _fetchTodayWeather();
      },
      onImportFlow: _onboardingImportFlow,
      currentLocale: widget.locale,
      onChangeLocale: widget.onChangeLocale,
    );
  }

  // -------------------------------------------------------------------------
  // CALENDAR STRIP
  // -------------------------------------------------------------------------

  Widget _buildCalendarStrip(Color cc, Color ic) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cc)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        reverse: true,
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(Duration(days: index));
          final dateKey = _getDateKey(date);
          final isSelected = dateKey == _getDateKey(_selectedDate);
          final isPacing = _activeProfile!.state.pacingDays.contains(dateKey);
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? cc : Colors.transparent,
                border: Border.all(color: cc, width: isPacing ? 2 : 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? ic : cc,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      isPacing
                          ? Icon(
                              Icons.shield_outlined,
                              color: isSelected ? ic : cc,
                              size: 18,
                            )
                          : Text(
                              DateFormat('d').format(date),
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? ic : cc,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                  if (_activeProfile!.getLifeEventsForDay(date).isNotEmpty)
                    Positioned(
                      bottom: 4,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? ic : const Color(0xFF9C27B0),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // SÍNTOMAS TAB
  // -------------------------------------------------------------------------

  Widget _buildSintomasTab(Color cc, Color ic) {
    return SintomasTab(
      profile: _activeProfile!,
      selectedDate: _selectedDate,
      contrastColor: cc,
      inverseContrastColor: ic,
      onProfileChanged: () {
        setState(() {});
        _saveData();
      },
    );
  }

  // -------------------------------------------------------------------------
  // BOTIQUÍN TAB
  // -------------------------------------------------------------------------

  Widget _buildBotiquinTab(Color cc, Color ic) {
    return BotiquinTab(
      profile: _activeProfile!,
      selectedDate: _selectedDate,
      contrastColor: cc,
      inverseContrastColor: ic,
      medlineService: _medlinePlus,
      onProfileChanged: () {
        setState(() {});
        _saveData();
      },
    );
  }

  // -------------------------------------------------------------------------
  // CLÍNICA TAB (Y REPORTE)
  // -------------------------------------------------------------------------

  Widget _buildClinicaTab(Color cc, Color ic) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: _clinicaTabBtn("Reporte", "REPORTE", cc, ic)),
              const SizedBox(width: 6),
              Expanded(
                child: _clinicaTabBtn("Biblioteca", "COMPENDIO", cc, ic),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _clinicaTabBtn("Investigación", "INVESTIGACIÓN", cc, ic),
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (_clinicaTabView) {
            "Reporte" => _buildReportContent(cc, ic),
            "Biblioteca" => _buildCompendiumLibraryContent(cc, ic),
            "Investigación" => InvestigacionTab(
              profile: _activeProfile!,
              service: _pubmed,
              contrastColor: cc,
              inverseContrastColor: ic,
              onToggleSave: _toggleSavedArticle,
            ),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }

  Widget _clinicaTabBtn(String value, String label, Color cc, Color ic) {
    final selected = _clinicaTabView == value;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? cc : ic,
        side: BorderSide(color: cc),
      ),
      onPressed: () => setState(() => _clinicaTabView = value),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? ic : cc,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PHASE 4a — Range selector + custom range picker
  // -------------------------------------------------------------------------

  Widget _buildReportRangeSelector(Color cc, Color ic) {
    final l10n = AppLocalizations.of(context)!;

    Widget pill(String label, int days) {
      final selected = _customRange == null && _reportRangeDays == days;
      return InkWell(
        onTap: () => setState(() {
          _reportRangeDays = days;
          _customRange = null;
        }),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? cc : Colors.transparent,
            border: Border.all(
              color: cc.withValues(alpha: selected ? 1.0 : 0.4),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? ic : cc.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    final customSelected = _customRange != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            pill(l10n.reportRangeDay, 1),
            pill(l10n.reportRangeWeek, 7),
            pill(l10n.reportRangeMonth, 30),
            InkWell(
              onTap: _openCustomRangePicker,
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: customSelected ? cc : Colors.transparent,
                  border: Border.all(
                    color: cc.withValues(alpha: customSelected ? 1.0 : 0.4),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Tooltip(
                  message: l10n.reportRangeCustomTooltip,
                  child: Icon(
                    Icons.date_range,
                    size: 16,
                    color: customSelected ? ic : cc.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (customSelected) ...[
          const SizedBox(height: 4),
          Text(
            l10n.reportRangeCustomActiveLabel(
              DateFormat('yyyy-MM-dd').format(_customRange!.start),
              DateFormat('yyyy-MM-dd').format(_customRange!.end),
            ),
            style: TextStyle(
              color: cc.withValues(alpha: 0.65),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openCustomRangePicker() async {
    final today = DateTime.now();
    final initial =
        _customRange ??
        DateTimeRange(
          start: _selectedDate.subtract(Duration(days: _reportRangeDays - 1)),
          end: _selectedDate,
        );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: today.subtract(const Duration(days: 365 * 2)),
      lastDate: today,
      initialDateRange: initial,
    );
    if (picked != null && mounted) {
      setState(() => _customRange = picked);
    }
  }

  String _buildReportPlainText() {
    final l10n = AppLocalizations.of(context)!;
    final todaysSymptoms = _activeProfile!.getSymptomsForDay(_selectedDate);
    final todaysDoses = _activeProfile!.getDosesForDay(_selectedDate);
    final todaysStructs = _activeProfile!.getStructuralForDay(_selectedDate);
    final todaysMental = _activeProfile!.getMentalForDay(_selectedDate);
    final todaysMoods = _activeProfile!.getMoodForDay(
      _selectedDate,
    ); // <--- NUEVO
    final todaysFever = _activeProfile!.getFeverForDay(_selectedDate);
    final feverEpisodes = FeverAnalysis.detectEpisodes(
      _activeProfile!.feverHistory,
    );

    // PHASE 4a — Range + trends computation
    final rangeEnd = _customRange?.end ?? _selectedDate;
    final rangeStart =
        _customRange?.start ??
        _selectedDate.subtract(Duration(days: _reportRangeDays - 1));
    final rangeDayCount =
        DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day)
            .difference(
              DateTime(rangeStart.year, rangeStart.month, rangeStart.day),
            )
            .inDays +
        1;
    final ReportTrends? trends = rangeDayCount > 1
        ? ReportTrendsService.compute(_activeProfile!, rangeStart, rangeEnd)
        : null;

    final grouped = <String, SymptomSeverity>{};
    for (final s in todaysSymptoms) {
      final existing = grouped[s.name];
      if (existing == null || s.severity.index > existing.index) {
        grouped[s.name] = s.severity;
      }
    }

    final groupedDoses = <String, int>{};
    for (final d in todaysDoses) {
      groupedDoses[d.medicationName] =
          (groupedDoses[d.medicationName] ?? 0) + 1;
    }

    final mentalSummary = <MentalState, int>{};
    for (final m in todaysMental) {
      final cur = mentalSummary[m.state];
      if (cur == null || m.severity > cur) mentalSummary[m.state] = m.severity;
    }

    final buf = StringBuffer();
    buf.writeln("PACIENTE: ${_activeProfile!.name}");
    buf.writeln(
      "FECHA EVALUADA: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
    );
    if (trends != null) {
      buf.writeln(
        "TENDENCIAS DE: ${DateFormat('yyyy-MM-dd').format(rangeStart)} → "
        "${DateFormat('yyyy-MM-dd').format(rangeEnd)} ($rangeDayCount días)",
      );
    }
    buf.writeln("─────────────────────────────");
    buf.writeln("DIAGNÓSTICOS:");
    for (final c in _activeProfile!.conditions) {
      buf.writeln(" • $c");
    }
    buf.writeln();
    buf.writeln("TRATAMIENTO (dosis del día):");
    if (groupedDoses.isEmpty) {
      buf.writeln(" • —");
    } else {
      for (final m in groupedDoses.entries) {
        buf.writeln(" • ${m.key} — ${m.value} dosis");
      }
    }
    buf.writeln();
    buf.writeln("SÍNTOMAS:");
    if (grouped.isEmpty) {
      buf.writeln(" • —");
    } else {
      for (final s in grouped.entries) {
        buf.writeln(
          " • ${s.key} [${s.value.severityLabel(l10n).toUpperCase()}]",
        );
      }
    }

    // PHASE 5.2d.3c — FIEBRE
    if (todaysFever.isNotEmpty) {
      buf.writeln();
      buf.writeln("FIEBRE:");
      for (final r in todaysFever) {
        final timeStr = DateFormat('HH:mm').format(r.timestamp);
        final tempStr = r.temperatureC.toStringAsFixed(1);
        String line = " • [$timeStr] ${tempStr}°C (${r.site.label(l10n)})";
        if (r.antipyreticTaken) {
          final apName = r.antipyreticName?.trim();
          if (apName != null && apName.isNotEmpty) {
            line += " + antipirético: $apName";
          } else {
            line += " + antipirético";
          }
        }
        buf.writeln(line);
      }
    }

    // Episode context: find the episode (if any) overlapping _selectedDate.
    // Last match wins, so if multiple episodes touch the day we surface
    // the most recent one — important when readings are sparse and a new
    // episode starts on the same calendar day an old one ended.
    final feverStartOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final feverEndOfDayExcl = feverStartOfDay.add(const Duration(days: 1));
    FeverEpisode? relevantFeverEpisode;
    for (final ep in feverEpisodes) {
      if (ep.start.isBefore(feverEndOfDayExcl) &&
          !ep.end.isBefore(feverStartOfDay)) {
        relevantFeverEpisode = ep;
      }
    }

    if (relevantFeverEpisode != null) {
      final ep = relevantFeverEpisode;
      final totalHours = ep.duration.inHours;
      final days = totalHours ~/ 24;
      final hours = totalHours % 24;
      final String durStr;
      if (days >= 1 && hours > 0) {
        durStr = "$days ${days == 1 ? 'día' : 'días'} ${hours}h";
      } else if (days >= 1) {
        durStr = "$days ${days == 1 ? 'día' : 'días'}";
      } else if (hours >= 1) {
        durStr = "${hours}h";
      } else {
        final mins = ep.duration.inMinutes;
        durStr = mins > 0 ? "${mins}min" : "lectura única";
      }
      final title = ep.isActive ? "EPISODIO ACTIVO" : "EPISODIO RECIENTE";

      buf.writeln();
      buf.writeln("$title ($durStr):");
      buf.writeln(
        " • Inicio: ${DateFormat('yyyy-MM-dd HH:mm').format(ep.start)}",
      );
      buf.writeln(
        " • Pico: ${ep.peakTemperatureC.toStringAsFixed(1)}°C (${ep.peakSite.label(l10n)}) el ${DateFormat('yyyy-MM-dd HH:mm').format(ep.peakTimestamp)}",
      );
      buf.writeln(" • Total lecturas: ${ep.readingsCount}");
      if (ep.antipyreticDosesCount > 0) {
        final String apStr;
        if (ep.antipyreticsUsed.isNotEmpty) {
          apStr =
              "${ep.antipyreticsUsed.join(', ')} (${ep.antipyreticDosesCount} dosis totales)";
        } else {
          apStr = "${ep.antipyreticDosesCount} dosis (sin nombre registrado)";
        }
        buf.writeln(" • Antipiréticos: $apStr");
      }
    }

    if (mentalSummary.isNotEmpty) {
      buf.writeln();
      buf.writeln("NIEBLA / FATIGA (máx. del día, 1–5):");
      for (final m in mentalSummary.entries) {
        buf.writeln(" • ${m.key.mentalStateLabel(l10n)}: ${m.value}/5");
      }
    }

    // <--- NUEVO: Inclusión de los estados de ánimo EMA y notas en el reporte clínico
    if (todaysMoods.isNotEmpty) {
      buf.writeln();
      buf.writeln("ESTADOS EMA & CONTEXTO:");
      for (final entry in todaysMoods) {
        final timeStr = DateFormat('HH:mm').format(entry.timestamp);
        final notesStr = entry.notes != null && entry.notes!.isNotEmpty
            ? " | Nota: ${entry.notes}"
            : "";
        buf.writeln(" • [$timeStr] ${entry.states.join(', ')}$notesStr");
      }
    }

    if (todaysStructs.isNotEmpty) {
      buf.writeln();
      buf.writeln("EVENTOS ESTRUCTURALES:");
      for (final e in todaysStructs) {
        buf.writeln(
          " • [${DateFormat('HH:mm').format(e.timestamp)}] ${e.zone.bodyZoneLabel(l10n)}: ${e.type.structuralTypeLabel(l10n)}",
        );
      }
    }

    // PHASE 4a — TENDENCIAS section
    if (trends != null && !trends.isEmpty) {
      buf.writeln();
      buf.writeln("TENDENCIAS:");

      if (trends.symptoms.isNotEmpty) {
        buf.writeln(" Síntomas:");
        for (final t in trends.symptoms) {
          final dayLabel = t.daysAppeared == 1 ? 'día' : 'días';
          String line = "  • ${t.name} — ${t.daysAppeared} $dayLabel";
          if (t.allUnrated) {
            line += " (sin rating)";
          } else {
            line +=
                ", peor: ${t.worstSeverity.severityLabel(l10n).toUpperCase()}";
          }
          buf.writeln(line);
        }
      }

      if (trends.doseCountsByMed.isNotEmpty) {
        buf.writeln(" Dosis:");
        final sorted = trends.doseCountsByMed.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        for (final entry in sorted) {
          final perDay = (entry.value / trends.dayCount).toStringAsFixed(1);
          buf.writeln(
            "  • ${entry.key} — ${entry.value} dosis ($perDay/día prom.)",
          );
        }
      }

      if (trends.feverEpisodes.isNotEmpty) {
        buf.writeln(" Fiebre:");
        final epCount = trends.feverEpisodes.length;
        final epLabel = epCount == 1 ? 'episodio' : 'episodios';
        final dayLabel = trends.feverishDayCount == 1 ? 'día' : 'días';
        buf.writeln(
          "  • $epCount $epLabel, ${trends.feverishDayCount} $dayLabel con fiebre",
        );
        for (final ep in trends.feverEpisodes) {
          final startStr = DateFormat('yyyy-MM-dd').format(ep.start);
          final endStr = DateFormat('yyyy-MM-dd').format(ep.end);
          final activeTag = ep.isActive ? " (activo)" : "";
          buf.writeln(
            "  • $startStr → $endStr, pico ${ep.peakTemperatureC.toStringAsFixed(1)}°C$activeTag",
          );
        }
      }

      if (trends.structuralCountsByZone.isNotEmpty) {
        buf.writeln(" Estructurales:");
        final sorted = trends.structuralCountsByZone.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        for (final entry in sorted) {
          final evLabel = entry.value == 1 ? 'evento' : 'eventos';
          buf.writeln(
            "  • ${entry.key.bodyZoneLabel(l10n)} — ${entry.value} $evLabel",
          );
        }
      }

      if (trends.mentalAvgByState.isNotEmpty) {
        buf.writeln(" Mental (promedio):");
        final sorted = trends.mentalAvgByState.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        for (final entry in sorted) {
          buf.writeln(
            "  • ${entry.key.mentalStateLabel(l10n)}: ${entry.value.toStringAsFixed(1)}/5",
          );
        }
      }
    }

    final effPairs = <String>{};
    for (final o in _activeProfile!.medicationOutcomes) {
      effPairs.add('${o.medicationName}→${o.symptomName}');
    }
    if (effPairs.isNotEmpty) {
      buf.writeln();
      buf.writeln("EFECTIVIDAD (histórico):");
      for (final pair in effPairs) {
        final parts = pair.split('→');
        final eff = _activeProfile!.effectivenessFor(parts[0], parts[1]);
        if (eff != null) {
          final pct = (eff.improved / eff.total * 100).toStringAsFixed(0);
          final avg = (-eff.meanDelta).toStringAsFixed(1);
          buf.writeln(
            " • ${parts[0]} → ${parts[1]}: $pct% mejora (${eff.improved}/${eff.total}), promedio -$avg pts",
          );
        }
      }
    }
    return buf.toString();
  }

  Widget _buildReportContent(Color cc, Color ic) {
    final reportText = _buildReportPlainText();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 8),
        _buildReportRangeSelector(cc, ic),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: cc)),
          child: SelectableText(
            reportText,
            style: TextStyle(fontFamily: 'Courier', fontSize: 14, color: cc),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: cc, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: Icon(Icons.copy, color: cc),
          label: Text(
            "COPIAR AL PORTAPAPELES",
            style: TextStyle(
              color: cc,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: reportText));
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Reporte copiado."),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCompendiumLibraryContent(Color cc, Color ic) {
    final l10n = AppLocalizations.of(context)!;
    final savedCount = _activeProfile!.savedArticlePmids.length;
    final conditions = _activeProfile!.conditions;
    final localeCode = l10n.localeName;

    // Compute domains matched by user's profile conditions.
    final matchedDomains = <CompendiumDomain>{};
    for (final c in conditions) {
      matchedDomains.addAll(domainsForUserCondition(c));
    }

    // Group facts (non-base WisdomQuotes) by domain. Filter by source so
    // the 3 hardcoded base quotes (Pacing / Validación / Potato Day)
    // don't leak into the clinical compendium.
    final domainFacts = <CompendiumDomain, List<WisdomQuote>>{};
    for (final quote in _wisdomDatabase) {
      if (quote.source.isEmpty) continue;
      final domain = domainForCondition(quote.category);
      domainFacts.putIfAbsent(domain, () => []).add(quote);
    }

    // Sort: matched domains first (in enum order), then unmatched
    // alphabetically by localized label, with "Otros" always last.
    final allDomains = domainFacts.keys.toList();
    allDomains.sort((a, b) {
      if (a == CompendiumDomain.other && b != CompendiumDomain.other) return 1;
      if (b == CompendiumDomain.other && a != CompendiumDomain.other) return -1;
      final aMatched = matchedDomains.contains(a);
      final bMatched = matchedDomains.contains(b);
      if (aMatched && !bMatched) return -1;
      if (!aMatched && bMatched) return 1;
      return localizedDomainLabel(
        a,
        l10n,
      ).compareTo(localizedDomainLabel(b, l10n));
    });

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (conditions.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(border: Border.all(color: cc)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.compendiumSectionConditionsHeader,
                  style: TextStyle(
                    color: cc,
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.compendiumSectionConditionsSubtitle,
                  style: TextStyle(
                    color: cc.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: conditions
                      .map(
                        (condition) => ActionChip(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: cc),
                          avatar: Icon(
                            Icons.health_and_safety_outlined,
                            color: cc,
                            size: 14,
                          ),
                          label: Text(
                            condition,
                            style: TextStyle(color: cc, fontSize: 13),
                          ),
                          onPressed: () => showConditionInfoSheet(
                            context: context,
                            userCondition: condition,
                            contrastColor: cc,
                            inverseContrastColor: ic,
                            service: _medlinePlus,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],

        if (savedCount > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: cc)),
            child: Row(
              children: [
                Icon(Icons.bookmark, color: cc, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.compendiumSavedArticlesTemplate(savedCount),
                    style: TextStyle(color: cc, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        // C.2 — Section header for the clinical-facts library.
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 10),
          child: Text(
            l10n.compendiumSectionDataTitle,
            style: TextStyle(
              color: cc,
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // C.2 — Domain expanders. User-matched first, auto-expanded.
        ...allDomains.map((domain) {
          final facts = domainFacts[domain]!;
          final label = localizedDomainLabel(domain, l10n);
          final isMatched = matchedDomains.contains(domain);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(border: Border.all(color: cc)),
            child: ExpansionTile(
              initiallyExpanded: isMatched,
              iconColor: cc,
              collapsedIconColor: cc,
              title: Text(
                '$label (${facts.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cc,
                  fontSize: 14,
                ),
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 14),
              children: facts.map((quote) {
                final body = quote.text(localeCode);
                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: cc.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      SelectableText(
                        body,
                        style: TextStyle(height: 1.5, color: cc, fontSize: 14),
                      ),
                      if (quote.source.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SelectableText(
                          '${l10n.compendiumFactSourceLabel} ${quote.source}',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: cc.withValues(alpha: 0.6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // SETTINGS DRAWER
  // -------------------------------------------------------------------------

  Widget _buildSettingsDrawer(Color cc, Color ic) {
    return Drawer(
      backgroundColor: ic,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 40),
          Text(
            AppLocalizations.of(context)!.settingsProfileConfigTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1,
              color: cc,
            ),
          ),
          Divider(color: cc),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.settingsPatientNameLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          TextField(
            controller: _profileNameController,
            style: TextStyle(color: cc, fontSize: 16),
            onChanged: (val) => setState(() {
              _activeProfile!.name = val;
              _saveData();
            }),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.settingsConditionsLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newDiagnosisController,
                  style: TextStyle(color: cc, fontSize: 16),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: cc),
                onPressed: () {
                  if (_newDiagnosisController.text.trim().isNotEmpty) {
                    setState(() {
                      _activeProfile!.conditions.add(
                        _newDiagnosisController.text.trim(),
                      );
                      _newDiagnosisController.clear();
                      _saveData();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.settingsConditionsHelper,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _activeProfile!.conditions
                .map(
                  (condition) => InputChip(
                    label: Text(
                      condition,
                      style: TextStyle(color: ic, fontSize: 14),
                    ),
                    backgroundColor: cc,
                    onDeleted: () => setState(() {
                      _activeProfile!.conditions.remove(condition);
                      _saveData();
                    }),
                    deleteIconColor: ic,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.settingsRelationshipLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.settingsRelationshipHelper,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (ctx) {
              final t = AppLocalizations.of(ctx)!;
              // (storage value, display label) pairs. Storage values stay in
              // Spanish so existing profiles keep their relationship intact
              // across language switches.
              final relOptions = <(String?, String)>[
                (null, t.settingsRelationshipNone),
                ('Yo', t.settingsRelationshipSelf),
                ('Mi hijo/a', t.settingsRelationshipChild),
                ('Mi pareja', t.settingsRelationshipPartner),
                ('Mi madre/padre', t.settingsRelationshipParent),
                ('Otro', t.settingsRelationshipOther),
              ];
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: relOptions.map((opt) {
                  final rel = opt.$1;
                  final isSelected =
                      _activeProfile!.relationship == rel ||
                      (rel == null && _activeProfile!.relationship == null);
                  final label = opt.$2;
                  return InkWell(
                    onTap: () => setState(() {
                      _activeProfile!.relationship = rel;
                      _saveData();
                    }),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? cc : Colors.transparent,
                        border: Border.all(color: cc.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? ic : cc.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.settingsLifeEventsLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.settingsLifeEventsHelper,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          if (_activeProfile!.lifeEvents.isEmpty)
            Text(
              AppLocalizations.of(context)!.settingsLifeEventsEmpty,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
              children:
                  (_activeProfile!.lifeEvents.toList()
                        ..sort((a, b) => b.startDate.compareTo(a.startDate)))
                      .map((e) {
                        final dateLabel = e.endDate == null
                            ? DateFormat('d MMM yyyy').format(e.startDate)
                            : "${DateFormat('d MMM').format(e.startDate)} → ${DateFormat('d MMM yyyy').format(e.endDate!)}";
                        return InkWell(
                          onTap: () => _editLifeEvent(e, cc, ic),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: cc.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF9C27B0),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title,
                                        style: TextStyle(
                                          color: cc,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        e.category != null
                                            ? "$dateLabel · ${e.category}"
                                            : dateLabel,
                                        style: TextStyle(
                                          color: cc.withValues(alpha: 0.6),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => setState(() {
                                    _activeProfile!.lifeEvents.remove(e);
                                    _saveData();
                                  }),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                      .toList(),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cc),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: Icon(Icons.add, color: cc),
            label: Text(
              AppLocalizations.of(context)!.settingsAddEventButton,
              style: TextStyle(
                color: cc,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            onPressed: () => _addLifeEvent(cc, ic),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.settingsLocationLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _activeProfile!.homeLatitude == null
                ? AppLocalizations.of(context)!.settingsLocationNone
                : "lat ${_activeProfile!.homeLatitude!.toStringAsFixed(2)}, "
                      "lng ${_activeProfile!.homeLongitude!.toStringAsFixed(2)}",
            style: TextStyle(color: cc, fontSize: 13),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(side: BorderSide(color: cc)),
            icon: Icon(Icons.place_outlined, color: cc),
            label: Text(
              _activeProfile!.homeLatitude == null
                  ? AppLocalizations.of(context)!.settingsLocationButtonAdd
                  : AppLocalizations.of(context)!.settingsLocationButtonEdit,
              style: TextStyle(
                color: cc,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            onPressed: () => _editLocation(),
          ),

          // F6.a + Sleep module: optional trackers section
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.settingsOptionalModulesTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.settingsOptionalModulesBlurb,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: cc,
            title: Text(
              AppLocalizations.of(context)!.settingsModuleSleepLabel,
              style: TextStyle(
                color: cc,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.settingsModuleSleepDescription,
              style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
            ),
            value: _activeProfile!.settings.optionalTrackers['sleep'] ?? false,
            onChanged: (v) => setState(() {
              _activeProfile!.settings.optionalTrackers['sleep'] = v;
              _saveData();
            }),
          ),

          // F6.b: Hidratación toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: cc,
            title: Text(
              AppLocalizations.of(context)!.settingsModuleHydrationLabel,
              style: TextStyle(
                color: cc,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.settingsModuleHydrationDescription,
              style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
            ),
            value:
                _activeProfile!.settings.optionalTrackers['hydration'] ?? false,
            onChanged: (v) => setState(() {
              _activeProfile!.settings.optionalTrackers['hydration'] = v;
              _saveData();
            }),
          ),

          // F6.b: HRV toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: cc,
            title: Text(
              AppLocalizations.of(context)!.settingsModuleHrvLabel,
              style: TextStyle(
                color: cc,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.settingsModuleHrvDescription,
              style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
            ),
            value: _activeProfile!.settings.optionalTrackers['hrv'] ?? false,
            onChanged: (v) => setState(() {
              _activeProfile!.settings.optionalTrackers['hrv'] = v;
              _saveData();
            }),
          ),
          // C.4: headache detail layer — only visible when the profile
          // mentions cefalea (in vault or conditions). Same shape as the
          // other optional-module switches above.
          if (_hasHeadacheRelevance())
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: cc,
              title: Text(
                AppLocalizations.of(context)!.settingsModuleHeadacheDetailLabel,
                style: TextStyle(
                  color: cc,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!.settingsModuleHeadacheDetailDescription,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              value:
                  _activeProfile!
                      .settings
                      .optionalTrackers['headache_detail'] ??
                  false,
              onChanged: (v) => setState(() {
                _activeProfile!.settings.optionalTrackers['headache_detail'] =
                    v;
                _saveData();
              }),
            ),
          // D.1: fatigue detail layer — only visible when the profile
          // mentions fatiga (in vault or conditions). Same shape as the
          // headache_detail switch above.
          if (_hasFatigueRelevance())
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: cc,
              title: Text(
                AppLocalizations.of(context)!.settingsModuleFatigueDetailLabel,
                style: TextStyle(
                  color: cc,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!.settingsModuleFatigueDetailDescription,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              value:
                  _activeProfile!.settings.optionalTrackers['fatigue_detail'] ??
                  false,
              onChanged: (v) => setState(() {
                _activeProfile!.settings.optionalTrackers['fatigue_detail'] = v;
                _saveData();
              }),
            ),
          // D.2: abdominal detail layer — only visible when the profile
          // mentions dolor abdominal / hinchazón / gases (in vault or
          // conditions). Same shape as the headache and fatigue switches.
          if (_hasAbdominalRelevance())
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: cc,
              title: Text(
                AppLocalizations.of(
                  context,
                )!.settingsModuleAbdominalDetailLabel,
                style: TextStyle(
                  color: cc,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!.settingsModuleAbdominalDetailDescription,
                style: TextStyle(
                  color: cc.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              value:
                  _activeProfile!
                      .settings
                      .optionalTrackers['abdominal_detail'] ??
                  false,
              onChanged: (v) => setState(() {
                _activeProfile!.settings.optionalTrackers['abdominal_detail'] =
                    v;
                _saveData();
              }),
            ),

          // Sprint E.E — MCAS detail layer toggle.
          // When off: MCAS sheet doesn't open for reactions like
          // urticaria, hinchazón, moretones, flushing, etc.
          // Enable to explore MCAS tracking (Weiler 2019 patterns
          // + Kumskova 2023 bleeding markers). Default off —
          // exploratory feature.
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: cc,
            title: Text(
              'Detalle MCAS / alergias',
              style: TextStyle(
                color: cc,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Registra reacciones, gatillos y señales de alerta.',
              style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
            ),
            value:
                _activeProfile!.settings.optionalTrackers['mcas_detail'] ??
                false,
            onChanged: (v) => setState(() {
              _activeProfile!.settings.optionalTrackers['mcas_detail'] = v;
              _saveData();
            }),
          ),
          // Sprint F.F — action capture opt-out toggle.
          // When off: RetroSymptomBanner hides in Hoy; the proactive
          // ActionTakenSheet skips after saving bowel / hem / fever.
          // Existing pending ActionTakens with follow-ups stay
          // visible in FollowUpBanner (user consented at logging).
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: cc,
            title: Text(
              'Seguimiento de acciones',
              style: TextStyle(
                color: cc,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Pregunta qué hiciste después de registrar un síntoma o '
              'evento, y cómo funcionó. Activo por defecto.',
              style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
            ),
            value:
                _activeProfile!.settings.optionalTrackers['action_taken'] ??
                true,
            onChanged: (v) => setState(() {
              _activeProfile!.settings.optionalTrackers['action_taken'] = v;
              _saveData();
            }),
          ),
          // F3: Visualización preferences
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.settingsViewPreferencesTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: cc,
            title: Text(
              AppLocalizations.of(context)!.settingsCarefulModeLabel,
              style: TextStyle(
                color: cc,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.settingsCarefulModeDescription,
              style: TextStyle(color: cc.withValues(alpha: 0.6), fontSize: 11),
            ),
            value:
                _activeProfile!.settings.optionalTrackers['careful_mode'] ??
                false,
            onChanged: (v) => setState(() {
              _activeProfile!.settings.optionalTrackers['careful_mode'] = v;
              _saveData();
            }),
          ),

          const SizedBox(height: 40),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cc, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: Icon(Icons.person_add_alt_1_rounded, color: cc),
            label: Text(
              AppLocalizations.of(context)!.settingsAddProfileButton,
              style: TextStyle(
                color: cc,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            onPressed: () {
              _createNewProfile();
              Navigator.pop(context);
            },
          ),
          if (_profiles.length > 1) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: Text(
                AppLocalizations.of(context)!.settingsDeleteProfileButton,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onPressed: () => _confirmDeleteProfile(),
            ),
          ],
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.languageSectionTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1,
              color: cc,
            ),
          ),
          Divider(color: cc),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children:
                [
                  (const Locale('es'), 'Español'),
                  (const Locale('en'), 'English'),
                  (const Locale('zh', 'TW'), '繁體中文'),
                ].map((opt) {
                  final isSelected =
                      widget.locale.languageCode == opt.$1.languageCode;
                  return InkWell(
                    onTap: () => widget.onChangeLocale(opt.$1),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? cc : Colors.transparent,
                        border: Border.all(color: cc.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        opt.$2,
                        style: TextStyle(
                          color: isSelected ? ic : cc.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.languageFootnote,
            style: TextStyle(
              color: cc.withValues(alpha: 0.5),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.settingsMyDataTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1,
              color: cc,
            ),
          ),
          Divider(color: cc),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.settingsDataHelper,
            style: TextStyle(
              color: cc.withValues(alpha: 0.7),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cc, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(Icons.download_outlined, color: cc),
            label: Text(
              AppLocalizations.of(context)!.settingsExportDataButton,
              style: TextStyle(
                color: cc,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            onPressed: _exportActiveProfile,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cc, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(Icons.upload_file_outlined, color: cc),
            label: Text(
              AppLocalizations.of(context)!.importFileButton,
              style: TextStyle(
                color: cc,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            onPressed: _importProfileFromFile,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cc, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(Icons.content_paste_go_outlined, color: cc),
            label: Text(
              AppLocalizations.of(context)!.importPasteButton,
              style: TextStyle(
                color: cc,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            onPressed: _importProfileFromPaste,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(
              Icons.delete_forever_outlined,
              color: Colors.redAccent,
            ),
            label: Text(
              AppLocalizations.of(context)!.settingsWipeAllButton,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            onPressed: _wipeAllData,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.settingsWipeAllHelper,
            style: TextStyle(
              color: cc.withValues(alpha: 0.5),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _createNewProfile() {
    setState(() {
      final newId =
          "${DateTime.now().millisecondsSinceEpoch}-${_profiles.length + 1}";
      final newProfile = Profile(
        id: newId,
        name: AppLocalizations.of(
          context,
        )!.settingsNewProfileNameTemplate(_profiles.length + 1),
        conditions: [],
        botiquin: [],
        symptomVault: [],
      );
      _profiles.add(newProfile);
      _activeProfile = newProfile;
      _updateControllers();
      _saveData();
    });
  }

  Future<void> _confirmDeleteProfile() async {
    final t = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.dialogDeleteProfileTitle),
        content: Text(
          t.dialogDeleteProfileContentTemplate(_activeProfile!.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t.actionDelete,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() {
      _profiles.remove(_activeProfile);
      _activeProfile = _profiles.isNotEmpty ? _profiles.first : null;
      _updateControllers();
      _saveData();
    });
    if (mounted) Navigator.pop(context);
  }

  Future<void> _editLocation() async {
    final latCtrl = TextEditingController(
      text: _activeProfile!.homeLatitude?.toString() ?? '',
    );
    final lngCtrl = TextEditingController(
      text: _activeProfile!.homeLongitude?.toString() ?? '',
    );

    final t = AppLocalizations.of(context)!;
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.dialogLocationTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.dialogLocationContent, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: latCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(hintText: t.dialogLocationHintLat),
            ),
            TextField(
              controller: lngCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(hintText: t.dialogLocationHintLng),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.actionSave),
          ),
        ],
      ),
    );
    if (saved != true) return;

    final lat = double.tryParse(latCtrl.text.trim());
    final lng = double.tryParse(lngCtrl.text.trim());
    if (lat == null || lng == null || lat.abs() > 90 || lng.abs() > 180) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.dialogLocationInvalidSnack)));
      }
      return;
    }
    setState(() {
      _activeProfile!.homeLatitude = lat;
      _activeProfile!.homeLongitude = lng;
      _saveData();
    });
    await _fetchTodayWeather();
  }

  Future<void> _addLifeEvent(Color cc, Color ic) async {
    final result = await showLifeEventFormSheet(
      context: context,
      contrastColor: cc,
      inverseContrastColor: ic,
    );
    if (result == null) return;
    setState(() {
      _activeProfile!.lifeEvents.add(result);
      _saveData();
    });
  }

  Future<void> _editLifeEvent(LifeEvent existing, Color cc, Color ic) async {
    final result = await showLifeEventFormSheet(
      context: context,
      contrastColor: cc,
      inverseContrastColor: ic,
      existing: existing,
    );
    if (result == null) return;
    final idx = _activeProfile!.lifeEvents.indexOf(existing);
    if (idx >= 0) {
      setState(() {
        _activeProfile!.lifeEvents[idx] = result;
        _saveData();
      });
    }
  }

  // -------------------------------------------------------------------------
  // ACTIONS: logging, editing, outcome answering
  // -------------------------------------------------------------------------

  void _togglePacing() {
    final dateKey = _getDateKey(_selectedDate);
    setState(() {
      if (_activeProfile!.state.pacingDays.contains(dateKey)) {
        _activeProfile!.state.pacingDays.remove(dateKey);
      } else {
        _activeProfile!.state.pacingDays.add(dateKey);
      }
      _saveData();
    });
  }

  void _logMental(MentalState state, int severity, {DateTime? timestamp}) {
    setState(() {
      _activeProfile!.mentalHistory.add(
        MentalEvent(
          timestamp: timestamp ?? _timestampForLog(),
          state: state,
          severity: severity,
        ),
      );
      _saveData();
    });
  }

  // <--- NUEVO: Modificada la firma de guardado de _logMood para usar notas en vez de intensity.
  void _logMood({
    required MoodQuadrant primaryQuadrant,
    required List<String> states,
    String? notes,
  }) {
    // Creamos la entrada
    final newEntry = MoodEntry(
      timestamp: _timestampForLog(),
      primaryQuadrant: primaryQuadrant,
      states: states,
      notes: notes,
    );

    setState(() {
      // Reasignamos la lista para forzar a Flutter a detectar el cambio de estado
      _activeProfile!.moodHistory = List.from(_activeProfile!.moodHistory)
        ..add(newEntry);
    });

    // Guardamos en Hive fuera del setState por rendimiento
    _saveData();
  }

  bool get _shouldShowHoyHint {
    final box = Hive.box('zebraBox');
    if (box.get('hoyHintAcked') == true) return false;
    final firstSeen = box.get('hoyHintFirstSeen') as String?;
    if (firstSeen == null) {
      box.put('hoyHintFirstSeen', DateTime.now().toIso8601String());
      return true;
    }
    final ts = DateTime.tryParse(firstSeen);
    if (ts == null) return false;
    return DateTime.now().difference(ts).inHours <= 48;
  }

  void _dismissHoyHint() {
    Hive.box('zebraBox').put('hoyHintAcked', true);
    setState(() {});
  }

  void _deleteMoodEntry(MoodEntry entry) {
    setState(() {
      _activeProfile!.moodHistory = List.from(_activeProfile!.moodHistory)
        ..remove(entry);
    });
    _saveData();
  }

  void _answerOutcome(
    MedicationOutcome o, {
    required int severityAfter,
    OutcomeReason? reason,
  }) {
    setState(() {
      final idx = _activeProfile!.medicationOutcomes.indexOf(o);
      if (idx >= 0) {
        _activeProfile!.medicationOutcomes[idx] = o.copyWith(
          severityAfter: severityAfter,
          reason: reason,
          respondedAt: DateTime.now(),
        );
        _saveData();
      }
    });
  }

  void _toggleSavedArticle(String pmid) {
    setState(() {
      if (_activeProfile!.savedArticlePmids.contains(pmid)) {
        _activeProfile!.savedArticlePmids.remove(pmid);
      } else {
        _activeProfile!.savedArticlePmids.add(pmid);
      }
      _saveData();
    });
  }
}
