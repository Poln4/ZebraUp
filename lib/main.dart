import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'l10n/app_localizations.dart';
import 'screens/main_screen.dart';
import 'services/profile_io_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('zebraBox');
  await ProfileIoService.migrateBoxIfNeeded();
  await Hive.openBox('pubmed_cache');
  runApp(const ZebraUpApp());
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
            color: isDark ? Colors.white : Colors.black, fontSize: 16),
        bodyMedium: TextStyle(
            color: isDark ? Colors.white : Colors.black, fontSize: 14),
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
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(fontScale),
          ),
          child: child!,
        );
      },
      home: MainAppScreen(
        isDarkMode: isDarkMode,
        onToggleTheme: _toggleTheme,
        fontScale: fontScale,
        onScaleFont: _scaleFont,
        locale: _locale,
        onChangeLocale: _changeLocale,
      ),
    );
  }
}