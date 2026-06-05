import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('zebraBox');
  await Hive.openBox('pubmed_cache');
  runApp(const ZebraUppApp());
}

class ZebraUppApp extends StatefulWidget {
  const ZebraUppApp({super.key});

  @override
  State<ZebraUppApp> createState() => _ZebraUppAppState();
}

class _ZebraUppAppState extends State<ZebraUppApp> {
  bool isDarkMode = true;
  double fontScale = 1.0;

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        bodyMedium: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
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
      title: 'Zebra Upp',
      debugShowCheckedModeBanner: false,
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
        onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
        fontScale: fontScale,
        onScaleFont: (value) => setState(() => fontScale = value),
      ),
    );
  }
}