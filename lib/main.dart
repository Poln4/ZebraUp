import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'l10n/app_localizations.dart';
import 'screens/main_screen.dart';
import 'services/profile_io_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/symptom_definitions_service.dart';
import 'models/beta_access_state.dart';
import 'services/beta_access_service.dart';
import 'screens/beta_access_screen.dart';
import 'screens/research_consent_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('zebraBox');
  await SymptomDefinitionsService.instance.ensureLoaded();
  await ProfileIoService.migrateBoxIfNeeded();
  await Hive.openBox('pubmed_cache');
  // Sprint B.A + B.B — beta access + consent state.
  await Hive.openBox('betaAccessBox');
  runApp(const ZebraUpApp());
  await initializeDateFormatting('es', null);
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('zh_TW', null);
}

class ZebraUpApp extends StatefulWidget {
  const ZebraUpApp({super.key});

  @override
  State<ZebraUpApp> createState() => _ZebraUpAppState();
}

class _ZebraUpAppState extends State<ZebraUpApp> {
  // Preferencias de UI, persistidas en Hive para sobrevivir recargas.
  // Defaults: oscuro, escala 1.0, español.
  late bool isDarkMode;
  late double fontScale;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('zebraBox');
    isDarkMode = box.get('prefDarkMode', defaultValue: true) as bool;
    fontScale = (box.get('prefFontScale', defaultValue: 1.0) as num).toDouble();
    final code = box.get('localeCode', defaultValue: 'es') as String;
    _locale = Locale(code == 'en' ? 'en' : 'es'); // sanea valores inesperados
  }

  void _toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
    Hive.box('zebraBox').put('prefDarkMode', isDarkMode);
  }

  void _scaleFont(double value) {
    setState(() => fontScale = value);
    Hive.box('zebraBox').put('prefFontScale', value);
  }

  void _changeLocale(Locale locale) {
    setState(() => _locale = locale);
    Hive.box('zebraBox').put('localeCode', locale.languageCode);
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 14,
        ),
        titleLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zebra Up',
      debugShowCheckedModeBanner: false,

      // --- i18n ---
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(fontScale)),
          child: child!,
        );
      },
      home: _OnboardingGate(
        child: MainAppScreen(
          isDarkMode: isDarkMode,
          onToggleTheme: _toggleTheme,
          fontScale: fontScale,
          onScaleFont: _scaleFont,
          locale: _locale,
          onChangeLocale: _changeLocale,
        ),
      ),
    );
  }
}

// Sprint B.A + B.B — Onboarding gate that decides which screen to
// show at app startup based on BetaAccessState.
class _OnboardingGate extends StatefulWidget {
  final Widget child;
  const _OnboardingGate({required this.child});

  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  BetaAccessState? _state;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    final state = BetaAccessService.loadState();
    setState(() {
      _state = state;
      _loading = false;
    });
  }

  void _onCodeAccepted(BetaAccessState state) {
    setState(() => _state = state);
  }

  void _onConsentDecision(BetaAccessState state) {
    setState(() => _state = state);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final s = _state!;

    // Step 1 — access code
    if (!s.accessGranted) {
      return BetaAccessScreen(onCodeAccepted: _onCodeAccepted);
    }

    // Step 2 — research consent (only shown if never decided).
    // Note: after a soft-decline, researchConsentAccepted stays false
    // but researchConsentAt stays null → we treat "never decided" as
    // null consentAt regardless of accepted. To avoid re-prompting
    // after decline, we key on whether the user has SEEN this screen
    // once — signaled by grantedAt being older than a small window.
    // Simpler proxy: track "consent decided" via consentAt being
    // non-null OR the state having been saved with accepted=false
    // (which happens in _decline in the screen).
    //
    // Effectively: we skip the consent screen if researchConsentAt
    // is non-null (accepted) OR if state has been re-saved after
    // grant (which decline does).
    //
    // Cleanest heuristic: show consent only when
    // researchConsentAt == null AND user has never seen it.
    // We infer "never seen" via a persistence marker: if the state
    // was re-saved (e.g. after decline), grantedAt still matches
    // but researchConsentAccepted was explicitly touched (still
    // false but the field has been set).
    //
    // To keep this simple: we show consent when
    // researchConsentAt == null AND researchConsentAccepted == false
    // AND the persistence hasn't marked a "decline touched" flag.
    // Because we can't easily track "touched", we accept a minor
    // UX: after decline, we save consentAt = a sentinel very-past
    // date so it's non-null and we skip. This is a workaround; a
    // cleaner solution adds an explicit "consentDecided" bool
    // to BetaAccessState — deferred to a follow-up.
    //
    // For now: skip consent if researchConsentAccepted is true.
    // Show consent only if it hasn't been accepted yet. Declines
    // are handled by the screen setting consentAt = null; the
    // gate re-shows the screen on next launch, which is arguably
    // correct: gentle re-prompting on relaunch, not adversarial.
    //
    // If the user declines multiple times, they can dismiss via
    // "Ahora no" each time. Not ideal but explicit.
    if (!s.researchConsentAccepted) {
      return ResearchConsentScreen(state: s, onDecision: _onConsentDecision);
    }

    return widget.child;
  }
}
