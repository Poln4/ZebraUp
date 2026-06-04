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

class Profile {
  final String id;
  String name;
  String dob;
  List<String> conditions;
  List<String> medications;
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
  bool _isEditingMode = false;

  // Text fields controllers for inputs
  final _profileNameController = TextEditingController();
  final _profileDobController = TextEditingController();
  final _newSymptomController = TextEditingController();
  final _newMedicationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activeProfile = _profiles[0];
    _updateControllers();
  }

  void _updateControllers() {
    _profileNameController.text = _activeProfile.name;
    _profileDobController.text = _activeProfile.dob;
  }

  List<String> _generateClinicalFlags() {
    List<String> flags = [];
    final meds = _activeProfile.medications;
    final symptoms = _activeProfile.activeSymptoms;

    if (meds.any((m) => m.toLowerCase().contains('alkantin')) && meds.any((m) => m.toLowerCase().contains('iron'))) {
      flags.add("⚠️ BLOQUEO DE ABSORCIÓN: Alkantin impide que tu cuerpo absorba el Hierro de forma correcta. Espacia estas tomas por al menos 2 horas.");
    }
    if (meds.any((m) => m.toLowerCase().contains('duloxetine')) && symptoms.any((s) => s.toLowerCase().contains('moratones') || s.toLowerCase().contains('hematoma') || s.toLowerCase().contains('bruis'))) {
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 1),
          underline: Container(),
          onChanged: (Profile? newProfile) {
            if (newProfile != null) {
              setState(() {
                _activeProfile = newProfile;
                _showReport = false;
                _updateControllers();
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
          // Edit Mode Toggle Button
          IconButton(
            icon: Icon(_isEditingMode ? Icons.playlist_add_check_rounded : Icons.edit_note_rounded, color: contrastColor, size: 28),
            onPressed: () {
              setState(() {
                _isEditingMode = !_isEditingMode;
                _showReport = false;
              });
            },
          ),
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
      body: _showReport 
          ? _buildReportView(contrastColor) 
          : (_isEditingMode ? _buildConfigurationView(contrastColor) : _buildMainTrackingView(contrastColor, activeFlags)),
    );
  }

  // --- STANDARD TRACKING DASHBOARD ---
  Widget _buildMainTrackingView(Color contrastColor, List<String> flags) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (flags.isNotEmpty) ...[
          Text("ALERTAS INFORMATIVAS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
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

        Text("SÍNTOMAS ACTIVOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
        const SizedBox(height: 8),
        _activeProfile.activeSymptoms.isEmpty
            ? Text("No hay síntomas activos seleccionados.", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14 * widget.fontScale))
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _activeProfile.activeSymptoms.map((symptom) {
                  return InputChip(
                    backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[200],
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

        Text("BAÚL DE SÍNTOMAS INACTIVOS (+)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
        const SizedBox(height: 8),
        _activeProfile.inactiveVault.isEmpty
            ? Text("El baúl está vacío.", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14 * widget.fontScale))
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _activeProfile.inactiveVault.map((symptom) {
                  return ActionChip(
                    backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                    side: BorderSide(color: contrastColor, width: 1),
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
        const SizedBox(height: 24),

        Text("MEDICAMENTOS Y SUPLEMENTOS ACTUALES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
        const SizedBox(height: 8),
        ..._activeProfile.medications.map((med) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.check_box_outlined, color: contrastColor),
              const SizedBox(width: 8),
              Text(med, style: TextStyle(fontSize: 15 * widget.fontScale)),
            ],
          ),
        )),

        const SizedBox(height: 40),
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

  // --- NEW: CONFIGURATION & EDIT VIEW LAYER ---
  Widget _buildConfigurationView(Color contrastColor) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text("CONFIGURACIÓN Y EDICIÓN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
        const SizedBox(height: 16),

        // Section A: Edit Active Profile Attributes
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("EDITAR PERFIL SELECCIONADO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              const SizedBox(height: 12),
              TextField(
                controller: _profileNameController,
                decoration: InputDecoration(labelText: "Nombre Completo", labelStyle: TextStyle(color: contrastColor), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: contrastColor))),
                onChanged: (val) => setState(() => _activeProfile.name = val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _profileDobController,
                decoration: InputDecoration(labelText: "Fecha de Nacimiento (AAAA-MM-DD)", labelStyle: TextStyle(color: contrastColor), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: contrastColor))),
                onChanged: (val) => setState(() => _activeProfile.dob = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section B: Add/Delete Symptoms
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("AÑADIR NUEVO SÍNTOMA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newSymptomController,
                      decoration: InputDecoration(hintText: "Ej. Migraña Cervical", hintStyle: const TextStyle(color: Colors.grey), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: contrastColor))),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_box_rounded, color: contrastColor, size: 32),
                    onPressed: () {
                      if (_newSymptomController.text.trim().isNotEmpty) {
                        setState(() {
                          _activeProfile.activeSymptoms.add(_newSymptomController.text.trim());
                          _newSymptomController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section C: Manage Medications list
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("GESTIONAR MEDICAMENTOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newMedicationController,
                      decoration: InputDecoration(hintText: "Ej. Suplemento Vitamina C", hintStyle: const TextStyle(color: Colors.grey), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: contrastColor))),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_box_rounded, color: contrastColor, size: 32),
                    onPressed: () {
                      if (_newMedicationController.text.trim().isNotEmpty) {
                        setState(() {
                          _activeProfile.medications.add(_newMedicationController.text.trim());
                          _newMedicationController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._activeProfile.medications.map((med) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(med, style: TextStyle(fontSize: 14 * widget.fontScale)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => setState(() => _activeProfile.medications.remove(med)),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section D: Create a Completely New Profile Block
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: contrastColor, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: Icon(Icons.person_add_alt_1_rounded, color: contrastColor),
          label: Text("CREAR NUEVO PERFIL DE PACIENTE", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold)),
          onPressed: () {
            setState(() {
              final newId = (_profiles.length + 1).toString();
              final newProfile = Profile(
                id: newId,
                name: "NUEVO PACIENTE $newId",
                dob: "2000-01-01",
                conditions: [],
                medications: [],
                activeSymptoms: [],
                inactiveVault: [],
              );
              _profiles.add(newProfile);
              _activeProfile = newProfile;
              _updateControllers();
            });
          },
        ),
        const SizedBox(height: 24),
        
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: contrastColor, 
            foregroundColor: widget.isDarkMode ? Colors.black : Colors.white, 
            padding: const EdgeInsets.symmetric(vertical: 16)
          ),
          onPressed: () => setState(() => _isEditingMode = false),
          child: const Text("GUARDAR CAMBIOS Y VOLVER", style: TextStyle(fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  // --- COMPACT TEXT MEDICAL REPORT VIEW ---
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
              _activeProfile.conditions.isEmpty 
                  ? Text(" • Ninguno registrado", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: _activeProfile.conditions.map((c) => Text(" • $c", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))).toList()),
              const SizedBox(height: 12),
              Text("TRATAMIENTOS Y SUPLEMENTOS:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              _activeProfile.medications.isEmpty 
                  ? Text(" • Ninguno registrado", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: _activeProfile.medications.map((m) => Text(" • $m", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))).toList()),
              const SizedBox(height: 12),
              Text("SÍNTOMAS RELEVANTES REPORTADOS:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              _activeProfile.activeSymptoms.isEmpty 
                  ? Text(" • Ninguno activo hoy", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: _activeProfile.activeSymptoms.map((s) => Text(" • $s (ACTIVO)", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))).toList()),
              const SizedBox(height: 12),
              Text("=========================================", style: TextStyle(fontFamily: 'Courier', fontSize: 12 * widget.fontScale)),
            ],
          ),
        ),
      ],
    );
  }
}