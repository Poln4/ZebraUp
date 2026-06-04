import 'package:flutter/material.dart';

void main() {
  runApp(const ZebraTrackerApp());
}

class ZebraTrackerApp extends StatefulWidget {
  const ZebraTrackerApp({super.key});

  @override
  State<ZebraTrackerApp> createState() => _ZebraTrackerAppState();
}

class _ZebraTrackerAppState extends State<ZebraTrackerApp> {
  bool isDarkMode = true;
  double fontScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZebraTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: isDarkMode ? Colors.black : Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16 * fontScale),
          bodyMedium: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14 * fontScale),
          titleLarge: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 22 * fontScale, fontWeight: FontWeight.bold),
        ),
      ),
      home: MainTrackingScreen(
        isDarkMode: isDarkMode,
        onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
        fontScale: fontScale,
        onScaleFont: (value) => setState(() => fontScale = value),
      ),
    );
  }
}

// Simple Mock Database Representation
class Profile {
  final String id;
  final String name;
  final String dob;
  final List<String> conditions;
  final List<String> medications;
  List<String> activeSymptoms;
  List<String> inactiveVault;

  Profile({
    required this.id,
    required this.name,
    required this.dob,
    required this.conditions,
    required this.medications,
    required this.activeSymptoms,
    required this.inactiveVault,
  });
}

class MainTrackingScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final double fontScale;
  final ValueChanged<double> onScaleFont;

  const MainTrackingScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.fontScale,
    required this.onScaleFont,
  });

  @override
  State<MainTrackingScreen> createState() => _MainTrackingScreenState();
}

class _MainTrackingScreenState extends State<MainTrackingScreen> {
  // Hardcoded Data Profiles for immediate testing
  final List<Profile> _profiles = [
    Profile(
      id: '1',
      name: 'Paulina (Me)',
      dob: '1991-09-04',
      conditions: ['clEDS (TNXB)', 'Adenomyosis', 'POTS', 'Anemia'],
      medications: ['Alkantin', 'Duloxetine', 'Iron'],
      activeSymptoms: ['Fatiga', 'Dolor de cabeza', 'Moratones'],
      inactiveVault: ['Diarrea', 'Acné', 'Mareos', 'Urticaria'],
    ),
    Profile(
      id: '2',
      name: 'Carla (Niece)',
      dob: '2018-05-12',
      conditions: ['Pediatric Check Log'],
      medications: ['Vitamin D Drop'],
      activeSymptoms: ['Tos'],
      inactiveVault: ['Fiebre', 'Fatiga'],
    ),
  ];

  late Profile _activeProfile;
  bool _showReport = false;

  @override
  void initState() {
    super.initState();
    _activeProfile = _profiles[0];
  }

  // Pure logic interaction check layer
  List<String> _generateClinicalFlags() {
    List<String> flags = [];
    final meds = _activeProfile.medications;
    final symptoms = _activeProfile.activeSymptoms;

    if (meds.contains('Alkantin') && meds.contains('Iron')) {
      flags.add("⚠️ BLOQUEO DE ABSORCIÓN: Alkantin impide que tu cuerpo absorba el Hierro de forma correcta. Espacia estas tomas por al menos 2 horas.");
    }
    if (meds.contains('Duloxetine') && symptoms.contains('Moratones')) {
      flags.add("⚠️ SEGUIMIENTO CLÍNICO: La Duloxetina puede influir en la agregación de plaquetas. Monitorea si tus moratones aumentan desde que inicias o subes dosis.");
    }
    return flags;
  }

  @override
  Widget build(BuildContext context) {
    Color contrastColor = widget.isDarkMode ? Colors.white : Colors.black;
    Color inverseContrastColor = widget.isDarkMode ? Colors.black : Colors.white;
    List<String> activeFlags = _generateClinicalFlags();

    return Scaffold(
      // --- LAYER 1: GLOBAL NAVIGATION & ACCESSIBILITY HEADER ---
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: contrastColor, height: 1.0),
        ),
        title: DropdownButton<Profile>(
          value: _activeProfile,
          dropdownColor: inverseContrastColor,
          icon: Icon(Icons.arrow_drop_down, color: contrastColor),
          style: Theme.of(context).textTheme.titleLarge,
          underline: Container(),
          onChanged: (Profile? newProfile) {
            if (newProfile != null) {
              setState(() {
                _activeProfile = newProfile;
                _showReport = false;
              });
            }
          },
          items: _profiles.map<DropdownMenuItem<Profile>>((Profile profile) {
            return DropdownMenuItem<Profile>(
              value: profile,
              child: Text(profile.name.toUpperCase()),
            );
          }).toList(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.text_fields, color: contrastColor),
            onPressed: () {
              double nextScale = widget.fontScale >= 1.4 ? 1.0 : widget.fontScale + 0.2;
              widget.onScaleFont(nextScale);
            },
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: contrastColor),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _showReport ? _buildReportView(contrastColor) : _buildMainTrackingView(contrastColor, activeFlags),
    );
  }

  // --- LAYER 2: THE DYNAMIC CONTENT LAYER ---
  Widget _buildMainTrackingView(Color contrastColor, List<String> flags) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Real-time clinical feedback engine flags
        if (flags.isNotEmpty) ...[
          Text("ALERTAS INFORMATIVAS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale, color: contrastColor)),
          const SizedBox(height: 8),
          ...flags.map((flag) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 2)),
                child: Text(flag, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              )),
          const Divider(thickness: 2, color: Colors.grey),
          const SizedBox(height: 12),
        ],

        // Active Symptoms
        Text("MIS SÍNTOMAS ACTIVOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, color: contrastColor)),
        const SizedBox(height: 8),
        _activeProfile.activeSymptoms.isEmpty
            ? Text("No hay síntomas activos seleccionados.", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14 * widget.fontScale))
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _activeProfile.activeSymptoms.map((symptom) {
                  return InputChip(
                    label: Text(symptom, style: TextStyle(fontSize: 14 * widget.fontScale)),
                    deleteIconColor: contrastColor,
                    onDeleted: () {
                      setState(() {
                        _activeProfile.activeSymptoms.remove(symptom);
                        _activeProfile.inactiveVault.add(symptom);
                      });
                    },
                  );
                }).toList(),
              ),
        const SizedBox(height: 24),

        // Inactive Vault
        Text("BAÚL DE SÍNTOMAS INACTIVOS (+)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, color: contrastColor)),
        const SizedBox(height: 8),
        _activeProfile.inactiveVault.isEmpty
            ? Text("El baúl está vacío.", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14 * widget.fontScale))
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _activeProfile.inactiveVault.map((symptom) {
                  return ActionChip(
                    label: Text(symptom, style: TextStyle(fontSize: 14 * widget.fontScale)),
                    onPressed: () {
                      setState(() {
                        _activeProfile.inactiveVault.remove(symptom);
                        _activeProfile.activeSymptoms.add(symptom);
                      });
                    },
                  );
                }).toList(),
              ),
        const SizedBox(height: 40),

        // Go to Report View Button
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: contrastColor, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => setState(() => _showReport = true),
          child: Text("GENERAR INFORME CLÍNICO摘要", style: TextStyle(fontWeight: FontWeight.bold, color: contrastColor, fontSize: 16 * widget.fontScale)),
        ),
      ],
    );
  }

  // --- LAYER 3: MINIMAL COMPACT REPORT VIEW ---
  Widget _buildReportView(Color contrastColor) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            IconButton(icon: Icon(Icons.arrow_back, color: contrastColor), onPressed: () => setState(() => _showReport = false)),
            Text("VISTA PREVIA DEL INFORME", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * widget.fontScale)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("=========================================", style: TextStyle(fontFamily: 'Courier', fontSize: 12 * widget.fontScale)),
              Text("        CLINICAL ABSTRACT REPORT        ", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              Text("=========================================", style: TextStyle(fontFamily: 'Courier', fontSize: 12 * widget.fontScale)),
              const SizedBox(height: 12),
              Text("PACIENTE: ${_activeProfile.name}", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale)),
              Text("FECHA DE NACIMIENTO: ${_activeProfile.dob}", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale)),
              const SizedBox(height: 12),
              Text("DIAGNÓSTICOS ACTIVOS:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              ..._activeProfile.conditions.map((c) => Text(" • $c", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))),
              const SizedBox(height: 12),
              Text("TRATAMIENTOS Y SUPLEMENTOS:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              ..._activeProfile.medications.map((m) => Text(" • $m", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))),
              const SizedBox(height: 12),
              Text("SÍNTOMAS RELEVANTES REPORTADOS:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              ..._activeProfile.activeSymptoms.map((s) => Text(" • $s (ACTIVO)", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))),
              const SizedBox(height: 12),
              Text("=========================================", style: TextStyle(fontFamily: 'Courier', fontSize: 12 * widget.fontScale)),
            ],
          ),
        ),
      ],
    );
  }
}