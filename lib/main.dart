import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zebra Upp',
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
      home: MainAppScreen(
        isDarkMode: isDarkMode,
        onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
        fontScale: fontScale,
        onScaleFont: (value) => setState(() => fontScale = value),
      ),
    );
  }
}

// ---------------------------------------------------------
// DATA MODELS
// ---------------------------------------------------------
class Medication {
  String name;
  String doseDetails;
  Map<String, int> dailyHistory;

  Medication({required this.name, required this.doseDetails, Map<String, int>? history}) : dailyHistory = history ?? {};

  String _getDateKey(DateTime date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  int getDoseForDate(DateTime date) => dailyHistory[_getDateKey(date)] ?? 0;
  void updateDose(DateTime date, int delta) {
    String key = _getDateKey(date);
    int currentDose = getDoseForDate(date);
    if (currentDose + delta >= 0) dailyHistory[key] = currentDose + delta;
  }
}

class StructuralEvent {
  String zone;
  String type; 
  String dateKey;

  StructuralEvent({required this.zone, required this.type, required this.dateKey});
}

class Profile {
  final String id;
  String name;
  String dob;
  List<String> conditions;
  List<Medication> medications;
  List<String> activeSymptoms;
  List<String> inactiveVault;
  Set<String> pacingDays; 
  List<StructuralEvent> structuralEvents; 

  Profile({
    required this.id, required this.name, required this.dob, required this.conditions,
    required this.medications, required this.activeSymptoms, required this.inactiveVault,
    Set<String>? pacing, List<StructuralEvent>? structural,
  }) : pacingDays = pacing ?? {}, structuralEvents = structural ?? [];
}

// NEW: Dynamic Data Models for JSON Integration
class WisdomQuote {
  final String text;
  final String category;
  WisdomQuote({required this.text, required this.category});
}

class ClinicalArticle {
  final String category;
  final String title;
  final String content;
  ClinicalArticle({required this.category, required this.title, required this.content});
}

// ---------------------------------------------------------
// MAIN APPLICATION STATE
// ---------------------------------------------------------
class MainAppScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final double fontScale;
  final ValueChanged<double> onScaleFont;

  const MainAppScreen({
    super.key, required this.isDarkMode, required this.onToggleTheme,
    required this.fontScale, required this.onScaleFont,
  });

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  late List<Profile> _profiles;
  late Profile _activeProfile;
  
  // Dynamic Databases (Simulating JSON loading)
  late List<WisdomQuote> _wisdomDatabase;
  late WisdomQuote _dailyWisdom;
  late List<ClinicalArticle> _clinicalLibraryDatabase;

  int _currentNavIndex = 0; 
  bool _showReport = false;
  bool _isEditingMode = false;
  DateTime _selectedDate = DateTime.now();

  final _profileNameController = TextEditingController();
  final _profileDobController = TextEditingController();
  final _newSymptomController = TextEditingController();
  final _newMedNameController = TextEditingController();
  final _newMedDoseController = TextEditingController();

  String _getDateKey(DateTime date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    
    // Simulating loaded data from 'zebra_wisdom.json'
    _wisdomDatabase = [
      WisdomQuote(text: "Descansar no es rendirse; es una intervención médica necesaria para tu sistema nervioso.", category: "Pacing"),
      WisdomQuote(text: "Tus síntomas son reales, incluso cuando los exámenes de rutina no los muestran.", category: "Validación"),
      WisdomQuote(text: "La fatiga multisistémica requiere paciencia radical contigo misma hoy.", category: "Fatiga"),
    ];
    _dailyWisdom = _wisdomDatabase[Random().nextInt(_wisdomDatabase.length)];

    // Simulating loaded data from 'clinical_library.json'
    _clinicalLibraryDatabase = [
      ClinicalArticle(category: "Tejido Conectivo (SED/TEH)", title: "Criterios Beighton y Riesgos", content: "Evaluación basada en 9 puntos de hipermovilidad articular. Los pacientes presentan fragilidad tisular que afecta la cicatrización y respuesta a anestesia."),
      ClinicalArticle(category: "Disautonomía (POTS)", title: "Intolerancia Ortostática", content: "La taquicardia al ponerse de pie suele ir acompañada de niebla mental y fatiga extrema debido al estancamiento de sangre (blood pooling)."),
      ClinicalArticle(category: "Gastrointestinal y Nutrición", title: "Bloqueos de Absorción", content: "Inflamación crónica, dismotilidad y fármacos protectores gástricos pueden bloquear la correcta absorción de micronutrientes vitales como el hierro y B12."),
    ];

    _profiles = [
      Profile(
        id: '1', name: 'Paulina (Me)', dob: '1991-09-04',
        conditions: ['clEDS (TNXB)', 'Adenomiosis', 'POTS', 'Anemia'],
        medications: [
          Medication(name: 'Hierro', doseDetails: '14mg'),
          Medication(name: 'Vitamina C', doseDetails: '1000mg'),
          Medication(name: 'Duloxetina', doseDetails: '60mg'),
          Medication(name: 'Ibuprofeno', doseDetails: '400mg (SOS)'),
        ],
        activeSymptoms: ['Fatiga', 'Moratones', 'Niebla mental'],
        inactiveVault: ['Diarrea', 'Mareos', 'Urticaria', 'Nauseas'],
      ),
      Profile(
        id: '2', name: 'Carla (Sobrina)', dob: '2018-05-12',
        conditions: ['Control Pediátrico'],
        medications: [
          Medication(name: 'Vitamina D', doseDetails: '1 Gota (400 IU)'),
        ],
        activeSymptoms: ['Tos'],
        inactiveVault: ['Fiebre', 'Fatiga'],
      ),
    ];
    _activeProfile = _profiles[0];
    _updateControllers();
  }

  void _updateControllers() {
    _profileNameController.text = _activeProfile.name;
    _profileDobController.text = _activeProfile.dob;
  }

  List<Map<String, dynamic>> _generateClinicalFlags() {
    List<Map<String, dynamic>> flags = [];
    final meds = _activeProfile.medications.map((m) => m.name.toLowerCase()).toList();

    if (meds.any((m) => m.contains('hierro')) && meds.any((m) => m.contains('vitamina c'))) {
      flags.add({"type": "positive", "message": "💡 SINERGIA ÓPTIMA: La Vitamina C potencia la absorción del hierro."});
    }
    if (meds.any((m) => m.contains('duloxetina')) && meds.any((m) => m.contains('ibuprofeno'))) {
      flags.add({"type": "severe", "message": "🚨 ALERTA HEMORRÁGICA: Duloxetina + AINEs potencian el riesgo de diátesis hemorrágica."});
    }
    return flags;
  }

  @override
  Widget build(BuildContext context) {
    Color contrastColor = widget.isDarkMode ? Colors.white : Colors.black;
    Color inverseContrastColor = widget.isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: contrastColor, height: 1.0)),
        title: _currentNavIndex == 1 
            ? Text("BIBLIOTECA CLÍNICA", style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 1))
            : DropdownButton<Profile>(
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
                  return DropdownMenuItem<Profile>(value: profile, child: Text(profile.name.toUpperCase()));
                }).toList(),
              ),
        actions: [
          if (_currentNavIndex == 0)
            IconButton(
              icon: Icon(_isEditingMode ? Icons.playlist_add_check_rounded : Icons.settings_outlined, color: contrastColor, size: 28),
              onPressed: () => setState(() { _isEditingMode = !_isEditingMode; _showReport = false; }),
            ),
          IconButton(icon: Icon(Icons.text_fields, color: contrastColor), onPressed: () => widget.onScaleFont(widget.fontScale >= 1.4 ? 1.0 : widget.fontScale + 0.2)),
          IconButton(icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: contrastColor), onPressed: widget.onToggleTheme),
        ],
      ),
      body: _currentNavIndex == 0 
          ? (_showReport ? _buildReportView(contrastColor) : (_isEditingMode ? _buildConfigurationView(contrastColor, inverseContrastColor) : _buildMainTrackingView(contrastColor, inverseContrastColor)))
          : _buildCompendiumLibraryView(contrastColor),
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        selectedItemColor: contrastColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() { _currentNavIndex = index; _showReport = false; _isEditingMode = false; }),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Rastreador'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Biblioteca'),
        ],
      ),
    );
  }

  // --- CALENDAR STRIP ---
  Widget _buildCalendarStrip(Color contrastColor, Color inverseContrastColor) {
    return Container(
      height: 80,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: contrastColor, width: 1))),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        reverse: true,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().subtract(Duration(days: index));
          String dateKey = _getDateKey(date);
          bool isSelected = dateKey == _getDateKey(_selectedDate);
          bool isPacing = _activeProfile.pacingDays.contains(dateKey); 
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? contrastColor : Colors.transparent,
                border: Border.all(color: contrastColor, width: isPacing ? 2 : 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('MMM').format(date).toUpperCase(), style: TextStyle(fontSize: 10 * widget.fontScale, color: isSelected ? inverseContrastColor : contrastColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  isPacing 
                      ? Icon(Icons.shield_outlined, color: isSelected ? inverseContrastColor : contrastColor, size: 20 * widget.fontScale)
                      : Text(DateFormat('d').format(date), style: TextStyle(fontSize: 16 * widget.fontScale, color: isSelected ? inverseContrastColor : contrastColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- STRUCTURAL BODY MAP MENU ---
  void _openStructuralMenu(String zone, Color contrastColor, Color inverseContrastColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: inverseContrastColor,
      shape: RoundedRectangleBorder(side: BorderSide(color: contrastColor, width: 2)),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ZONA: ${zone.toUpperCase()}", style: TextStyle(color: contrastColor, fontSize: 16 * widget.fontScale, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildStructuralOption("Subluxación (Inestabilidad Parcial)", zone, contrastColor),
                _buildStructuralOption("Dislocación (Salida Completa)", zone, contrastColor),
                _buildStructuralOption("Inestabilidad Articular (Laxitud)", zone, contrastColor),
                _buildStructuralOption("Dolor Articular (Ache/Inflamación)", zone, contrastColor),
                _buildStructuralOption("Dolor Miofascial (Fascia/Músculo)", zone, contrastColor),
                _buildStructuralOption("Dolor Neuropático (Nervio)", zone, contrastColor),
                _buildStructuralOption("Otro evento...", zone, contrastColor),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildStructuralOption(String type, String zone, Color contrastColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.warning_amber_rounded, color: contrastColor),
      title: Text(type, style: TextStyle(color: contrastColor, fontSize: 14 * widget.fontScale)),
      onTap: () {
        setState(() {
          _activeProfile.structuralEvents.add(StructuralEvent(zone: zone, type: type, dateKey: _getDateKey(_selectedDate)));
        });
        Navigator.pop(context);
      },
    );
  }

  // --- MAIN TRACKING VIEW ---
  Widget _buildMainTrackingView(Color contrastColor, Color inverseContrastColor) {
    String currentDateKey = _getDateKey(_selectedDate);
    bool isCurrentlyPacing = _activeProfile.pacingDays.contains(currentDateKey);
    List<StructuralEvent> todaysEvents = _activeProfile.structuralEvents.where((e) => e.dateKey == currentDateKey).toList();
    List<Map<String, dynamic>> activeFlags = _generateClinicalFlags();

    return Column(
      children: [
        _buildCalendarStrip(contrastColor, inverseContrastColor),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 0. NEW: ZEBRA WISDOM CARD
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 1, style: BorderStyle.solid)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.wb_incandescent_outlined, color: contrastColor, size: 18),
                        const SizedBox(width: 8),
                        Text("SABIDURÍA ZEBRA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('"${_dailyWisdom.text}"', style: TextStyle(fontSize: 15 * widget.fontScale, fontStyle: FontStyle.italic, color: contrastColor, height: 1.4)),
                  ],
                ),
              ),

              // 1. PACING TOGGLE
              InkWell(
                onTap: () => setState(() {
                  isCurrentlyPacing ? _activeProfile.pacingDays.remove(currentDateKey) : _activeProfile.pacingDays.add(currentDateKey);
                }),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCurrentlyPacing ? contrastColor : Colors.transparent,
                    border: Border.all(color: contrastColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(isCurrentlyPacing ? Icons.shield : Icons.shield_outlined, color: isCurrentlyPacing ? inverseContrastColor : contrastColor, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("DÍA DE PACING (RECUPERACIÓN)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale, color: isCurrentlyPacing ? inverseContrastColor : contrastColor)),
                            Text("Validar el descanso como intervención.", style: TextStyle(fontSize: 12 * widget.fontScale, color: isCurrentlyPacing ? inverseContrastColor : contrastColor)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. COMPACT STRUCTURAL BODY MAP
              Text("MAPA ESTRUCTURAL (ZONAS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
              const SizedBox(height: 12),
              Text("TREN SUPERIOR", style: TextStyle(fontSize: 12 * widget.fontScale, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ["Cervicales", "Hombros", "Codos", "Muñecas", "Manos/Dedos", "Espalda Alta"]
                  .map((zone) => ActionChip(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: contrastColor, width: 1),
                    label: Text(zone, style: TextStyle(color: contrastColor, fontSize: 12 * widget.fontScale)),
                    onPressed: () => _openStructuralMenu(zone, contrastColor, inverseContrastColor),
                  )).toList(),
              ),
              const SizedBox(height: 16),
              Text("TREN INFERIOR", style: TextStyle(fontSize: 12 * widget.fontScale, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ["Lumbar/Pelvis", "Caderas", "Rodillas", "Tobillos", "Pies"]
                  .map((zone) => ActionChip(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: contrastColor, width: 1),
                    label: Text(zone, style: TextStyle(color: contrastColor, fontSize: 12 * widget.fontScale)),
                    onPressed: () => _openStructuralMenu(zone, contrastColor, inverseContrastColor),
                  )).toList(),
              ),
              
              if (todaysEvents.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: contrastColor, style: BorderStyle.solid)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: todaysEvents.map((event) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.adjust, color: contrastColor, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text("${event.zone}: ${event.type}", style: TextStyle(fontSize: 14 * widget.fontScale))),
                          IconButton(
                            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close, color: Colors.red, size: 18),
                            onPressed: () => setState(() => _activeProfile.structuralEvents.remove(event)),
                          )
                        ],
                      ),
                    )).toList(),
                  ),
                )
              ],
              const SizedBox(height: 24),

              // 3. CLINICAL FLAGS
              if (activeFlags.isNotEmpty) ...[
                Text("ANÁLISIS DE INTERACCIONES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
                const SizedBox(height: 8),
                ...activeFlags.map((flag) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: flag["type"] == "severe" ? Colors.redAccent : contrastColor, width: 2),
                        color: flag["type"] == "positive" ? Colors.green.withOpacity(0.1) : Colors.transparent,
                      ),
                      child: Text(flag["message"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
                    )),
                const Divider(thickness: 2, color: Colors.grey),
                const SizedBox(height: 12),
              ],

              // 4. ACTIVE SYMPTOMS
              Text("SÍNTOMAS ACTIVOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
              const SizedBox(height: 8),
              _activeProfile.activeSymptoms.isEmpty
                  ? Text("No hay síntomas activos seleccionados.", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14 * widget.fontScale))
                  : Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _activeProfile.activeSymptoms.map((symptom) => InputChip(
                        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey[200],
                        label: Text(symptom, style: TextStyle(fontSize: 14 * widget.fontScale)),
                        deleteIconColor: contrastColor,
                        onDeleted: () => setState(() { _activeProfile.activeSymptoms.remove(symptom); _activeProfile.inactiveVault.add(symptom); }),
                      )).toList(),
                    ),
              const SizedBox(height: 24),
              
              // 5. INACTIVE VAULT
              Text("BAÚL INACTIVO (+)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
              const SizedBox(height: 8),
              _activeProfile.inactiveVault.isEmpty
                  ? Text("El baúl está vacío.", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14 * widget.fontScale))
                  : Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _activeProfile.inactiveVault.map((symptom) => ActionChip(
                        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                        side: BorderSide(color: contrastColor, width: 1),
                        label: Text(symptom, style: TextStyle(fontSize: 14 * widget.fontScale)),
                        onPressed: () => setState(() { _activeProfile.inactiveVault.remove(symptom); _activeProfile.activeSymptoms.add(symptom); }),
                      )).toList(),
                    ),
              const SizedBox(height: 24),

              // 6. DOSAGE TRACKING
              Text("SEGUIMIENTO DE DOSIS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
              const SizedBox(height: 8),
              ..._activeProfile.medications.map((med) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: contrastColor)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(med.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * widget.fontScale)),
                          Text(med.doseDetails, style: TextStyle(fontSize: 12 * widget.fontScale, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(icon: Icon(Icons.remove_circle_outline, color: contrastColor), onPressed: () => setState(() => med.updateDose(_selectedDate, -1))),
                        Text("${med.getDoseForDate(_selectedDate)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * widget.fontScale)), 
                        IconButton(icon: Icon(Icons.add_circle_outline, color: contrastColor), onPressed: () => setState(() => med.updateDose(_selectedDate, 1))),
                      ],
                    )
                  ],
                ),
              )),
              
              const SizedBox(height: 24),
              OutlinedButton(
                style: OutlinedButton.styleFrom(side: BorderSide(color: contrastColor, width: 2), padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () => setState(() => _showReport = true),
                child: Text("GENERAR INFORME CLÍNICO", style: TextStyle(fontWeight: FontWeight.bold, color: contrastColor, fontSize: 16 * widget.fontScale)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- CONFIGURATION MENU ---
  Widget _buildConfigurationView(Color contrastColor, Color inverseContrastColor) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text("CONFIGURACIÓN Y EDICIÓN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * widget.fontScale, color: contrastColor, letterSpacing: 1)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("EDITAR PERFIL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              const SizedBox(height: 12),
              TextField(
                controller: _profileNameController,
                decoration: InputDecoration(labelText: "Nombre", labelStyle: TextStyle(color: contrastColor), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: contrastColor))),
                onChanged: (val) => setState(() => _activeProfile.name = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("AÑADIR SÍNTOMA AL BAÚL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newSymptomController,
                      decoration: InputDecoration(hintText: "Ej. Taquicardia al pararse", hintStyle: const TextStyle(color: Colors.grey), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: contrastColor))),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_box_rounded, color: contrastColor, size: 32),
                    onPressed: () {
                      if (_newSymptomController.text.trim().isNotEmpty) {
                        setState(() {
                          _activeProfile.inactiveVault.add(_newSymptomController.text.trim());
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

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("GESTIONAR MEDICAMENTOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              const SizedBox(height: 8),
              TextField(
                controller: _newMedNameController,
                decoration: InputDecoration(hintText: "Nombre (Ej. Sal/Sodio)", hintStyle: const TextStyle(color: Colors.grey), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: contrastColor))),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newMedDoseController,
                      decoration: InputDecoration(hintText: "Dosis (Ej. 1 gramo)", hintStyle: const TextStyle(color: Colors.grey), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: contrastColor))),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_box_rounded, color: contrastColor, size: 32),
                    onPressed: () {
                      if (_newMedNameController.text.trim().isNotEmpty) {
                        setState(() {
                          _activeProfile.medications.add(
                            Medication(name: _newMedNameController.text.trim(), doseDetails: _newMedDoseController.text.trim())
                          );
                          _newMedNameController.clear();
                          _newMedDoseController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._activeProfile.medications.map((med) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(med.name, style: TextStyle(fontSize: 14 * widget.fontScale, fontWeight: FontWeight.bold)),
                    subtitle: Text(med.doseDetails, style: TextStyle(fontSize: 12 * widget.fontScale, color: Colors.grey)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => setState(() => _activeProfile.medications.remove(med)),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 24),

        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: contrastColor, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: Icon(Icons.person_add_alt_1_rounded, color: contrastColor),
          label: Text("CREAR NUEVO PERFIL (EJ. MAMÁ)", style: TextStyle(color: contrastColor, fontWeight: FontWeight.bold)),
          onPressed: () {
            setState(() {
              final newId = (_profiles.length + 1).toString();
              final newProfile = Profile(
                id: newId, name: "NUEVO PERFIL $newId", dob: "1960-01-01",
                conditions: [], medications: [], activeSymptoms: [], inactiveVault: [],
              );
              _profiles.add(newProfile);
              _activeProfile = newProfile;
              _updateControllers();
            });
          },
        ),
        const SizedBox(height: 24),
        
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: contrastColor, foregroundColor: inverseContrastColor, padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: () => setState(() => _isEditingMode = false),
          child: const Text("GUARDAR CAMBIOS", style: TextStyle(fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  // --- REPORT VIEW ---
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
              Text("DIAGNÓSTICOS:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              ..._activeProfile.conditions.map((c) => Text(" • $c", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))),
              const SizedBox(height: 12),
              Text("TRATAMIENTOS:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              ..._activeProfile.medications.map((m) => Text(" • ${m.name} [${m.doseDetails}] - Dosis Hoy: ${m.getDoseForDate(_selectedDate)}", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))),
              const SizedBox(height: 12),
              Text("SÍNTOMAS ACTIVOS:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              ..._activeProfile.activeSymptoms.map((s) => Text(" • $s", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))),
              const SizedBox(height: 12),
              Text("EVENTOS ESTRUCTURALES HOY:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14 * widget.fontScale)),
              ..._activeProfile.structuralEvents.where((e) => e.dateKey == _getDateKey(_selectedDate)).map((e) => Text(" • ${e.zone}: ${e.type}", style: TextStyle(fontFamily: 'Courier', fontSize: 14 * widget.fontScale))),
              const SizedBox(height: 12),
              Text("=========================================", style: TextStyle(fontFamily: 'Courier', fontSize: 12 * widget.fontScale)),
            ],
          ),
        ),
      ],
    );
  }

  // --- NEW DYNAMIC COMPENDIUM LIBRARY ---
  Widget _buildCompendiumLibraryView(Color contrastColor) {
    // Group articles by their dynamic categories
    Map<String, List<ClinicalArticle>> groupedLibrary = {};
    for (var article in _clinicalLibraryDatabase) {
      if (!groupedLibrary.containsKey(article.category)) {
        groupedLibrary[article.category] = [];
      }
      groupedLibrary[article.category]!.add(article);
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text("BIBLIOTECA CLÍNICA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22 * widget.fontScale, color: contrastColor)),
        Text("Repositorio Dinámico de Condiciones Complejas", style: TextStyle(fontSize: 14 * widget.fontScale, color: Colors.grey)),
        const SizedBox(height: 24),
        
        ...groupedLibrary.entries.map((categoryEntry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(categoryEntry.key.toUpperCase(), style: TextStyle(fontSize: 12 * widget.fontScale, fontWeight: FontWeight.bold, letterSpacing: 1, color: contrastColor)),
              const SizedBox(height: 8),
              ...categoryEntry.value.map((article) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(border: Border.all(color: contrastColor, width: 1)),
                child: ExpansionTile(
                  iconColor: contrastColor, collapsedIconColor: contrastColor,
                  title: Text(article.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * widget.fontScale, color: contrastColor)),
                  children: [Padding(padding: const EdgeInsets.all(16.0), child: Text(article.content, style: TextStyle(fontSize: 14 * widget.fontScale, color: contrastColor, height: 1.5)))],
                ),
              )),
              const SizedBox(height: 8),
            ],
          );
        }),
      ],
    );
  }
}