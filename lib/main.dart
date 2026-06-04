import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('zebraBox');
  runApp(const ZebraUppApp());
}

class ZebraUppApp extends StatelessWidget {
  const ZebraUppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zebra Upp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
          titleLarge: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      home: const MainAppScreen(),
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

  Map<String, dynamic> toMap() => {'name': name, 'doseDetails': doseDetails, 'dailyHistory': dailyHistory};
  factory Medication.fromMap(Map<String, dynamic> map) => Medication(
    name: map['name'], doseDetails: map['doseDetails'], history: Map<String, int>.from(map['dailyHistory'] ?? {})
  );
}

class StructuralEvent {
  String zone;
  String type; 
  String dateKey;

  StructuralEvent({required this.zone, required this.type, required this.dateKey});

  Map<String, dynamic> toMap() => {'zone': zone, 'type': type, 'dateKey': dateKey};
  factory StructuralEvent.fromMap(Map<String, dynamic> map) => StructuralEvent(zone: map['zone'], type: map['type'], dateKey: map['dateKey']);
}

class Profile {
  final String id;
  String name;
  String dob;
  List<String> conditions;
  List<Medication> medications;
  Map<String, String> activeSymptoms; 
  List<String> inactiveVault;
  Set<String> pacingDays; 
  List<StructuralEvent> structuralEvents; 

  Profile({
    required this.id, required this.name, required this.dob, required this.conditions,
    required this.medications, required this.activeSymptoms, required this.inactiveVault,
    Set<String>? pacing, List<StructuralEvent>? structural,
  }) : pacingDays = pacing ?? {}, structuralEvents = structural ?? [];

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'dob': dob, 'conditions': conditions,
    'activeSymptoms': activeSymptoms, 'inactiveVault': inactiveVault, 'pacingDays': pacingDays.toList(),
    'medications': medications.map((x) => x.toMap()).toList(),
    'structuralEvents': structuralEvents.map((x) => x.toMap()).toList(),
  };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map['id'], name: map['name'], dob: map['dob'],
    conditions: List<String>.from(map['conditions'] ?? []),
    activeSymptoms: Map<String, String>.from(map['activeSymptoms'] ?? {}),
    inactiveVault: List<String>.from(map['inactiveVault'] ?? []),
    pacing: Set<String>.from(map['pacingDays'] ?? []),
    medications: List<Medication>.from((map['medications'] ?? []).map((x) => Medication.fromMap(x))),
    structural: List<StructuralEvent>.from((map['structuralEvents'] ?? []).map((x) => StructuralEvent.fromMap(x))),
  );
}

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
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  late List<Profile> _profiles;
  late Profile _activeProfile;
  
  late List<WisdomQuote> _wisdomDatabase;
  late WisdomQuote _dailyWisdom;
  late List<ClinicalArticle> _clinicalLibraryDatabase;

  int _currentNavIndex = 0; 
  DateTime _selectedDate = DateTime.now();
  String _selectedReportSpecialty = "General"; 
  String _clinicaTabView = "Reporte"; // Toggles between Reporte and Biblioteca

  final _profileNameController = TextEditingController();
  final _newDiagnosisController = TextEditingController();
  final _newSymptomController = TextEditingController();
  final _newMedNameController = TextEditingController();
  final _newMedDoseController = TextEditingController();

  String _getDateKey(DateTime date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    _loadSimulatedLibraries();
    _loadUserProfiles();
  }

  void _saveData() {
    var box = Hive.box('zebraBox');
    String encodedData = json.encode(_profiles.map((p) => p.toMap()).toList());
    box.put('profiles', encodedData);
  }

  void _loadSimulatedLibraries() {
    _wisdomDatabase = [
      WisdomQuote(text: "Descansar no es rendirse; es una intervención médica necesaria para tu sistema nervioso.", category: "Pacing"),
      WisdomQuote(text: "Tus síntomas son reales, incluso cuando los exámenes de rutina no los muestran.", category: "Validación"),
      WisdomQuote(text: "El mundo es tu papa. Hoy toca reparar.", category: "Potato Day"),
    ];
    _dailyWisdom = _wisdomDatabase[Random().nextInt(_wisdomDatabase.length)];

    _clinicalLibraryDatabase = [
      ClinicalArticle(category: "Tejido Conectivo", title: "Criterios Beighton", content: "Evaluación basada en 9 puntos de hipermovilidad articular. Implica fragilidad de tejidos blandos."),
      ClinicalArticle(category: "Disautonomía", title: "POTS e Intolerancia Ortostática", content: "Taquicardia severa al ponerse de pie acompañada de niebla mental debido al estancamiento del flujo sanguíneo.")
    ];
  }

  void _loadUserProfiles() {
    var box = Hive.box('zebraBox');
    String? storedData = box.get('profiles');

    if (storedData != null) {
      List<dynamic> decoded = json.decode(storedData);
      _profiles = decoded.map((x) => Profile.fromMap(x)).toList();
    } else {
      _profiles = [
        Profile(
          id: '1', name: 'Paulina (Me)', dob: '1991-09-04',
          conditions: ['clEDS', 'Adenomiosis', 'POTS', 'Anemia'],
          medications: [
            Medication(name: 'Hierro', doseDetails: '14mg'),
            Medication(name: 'Vitamina C', doseDetails: '1000mg'),
            Medication(name: 'Duloxetina', doseDetails: '60mg'),
            Medication(name: 'Ibuprofeno', doseDetails: '400mg (SOS)'),
          ],
          activeSymptoms: {'Fatiga crónica': 'Moderado', 'Niebla mental': 'Severo'},
          inactiveVault: ['Taquicardia ortostática', 'Mareos al pararse', 'Reflujo gástrico', 'Náuseas', 'Moratones'],
        ),
      ];
      _saveData();
    }
    _activeProfile = _profiles[0];
    _updateControllers();
  }

  void _updateControllers() {
    _profileNameController.text = _activeProfile.name;
  }

  List<Map<String, dynamic>> _generateClinicalFlags() {
    List<Map<String, dynamic>> flags = [];
    final meds = _activeProfile.medications.map((m) => m.name.toLowerCase()).toList();
    final diagnoses = _activeProfile.conditions.map((c) => c.toLowerCase()).toList();

    if (meds.any((m) => m.contains('hierro')) && meds.any((m) => m.contains('vitamina c'))) {
      flags.add({"type": "positive", "message": "💡 SINERGIA ÓPTIMA: La Vitamina C potencia la absorción del hierro."});
    }
    
    if (meds.any((m) => m.contains('duloxetina')) && meds.any((m) => m.contains('ibuprofeno'))) {
      if (diagnoses.contains('cleds') || diagnoses.contains('adenomiosis')) {
        flags.add({
          "type": "severe", 
          "message": "🚨 ALERTA HEMORRÁGICA: Duloxetina + AINEs elevan el riesgo de sangrado debido a tus diagnósticos activos (clEDS/Adenomiosis)."
        });
      }
    }
    return flags;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: Colors.white, height: 1.0)),
        title: DropdownButton<Profile>(
          value: _activeProfile,
          dropdownColor: Colors.black,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
          underline: Container(),
          onChanged: (Profile? newProfile) {
            if (newProfile != null) {
              setState(() { _activeProfile = newProfile; _updateControllers(); });
            }
          },
          items: _profiles.map<DropdownMenuItem<Profile>>((Profile profile) {
            return DropdownMenuItem<Profile>(value: profile, child: Text(profile.name.toUpperCase()));
          }).toList(),
        ),
        actions: [
          // Opens the side-drawer for settings
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildSettingsDrawer(), // Hidden Config Menu
      
      // Global Calendar + The active Tab View
      body: Column(
        children: [
          _buildCalendarStrip(),
          Expanded(
            child: _currentNavIndex == 0 ? _buildHoyTab()
                 : _currentNavIndex == 1 ? _buildSintomasTab()
                 : _currentNavIndex == 2 ? _buildBotiquinTab()
                 : _buildClinicaTab(),
          ),
        ],
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed, // Keeps all 4 icons visible
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[700],
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() { _currentNavIndex = index; }),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny_outlined), label: 'Hoy'),
          BottomNavigationBarItem(icon: Icon(Icons.accessibility_new_rounded), label: 'Síntomas'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services_outlined), label: 'Botiquín'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Clínica'),
        ],
      ),
    );
  }

  // --- 1. GLOBAL CALENDAR STRIP ---
  Widget _buildCalendarStrip() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white, width: 1))),
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
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(color: Colors.white, width: isPacing ? 2 : 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('MMM').format(date).toUpperCase(), style: TextStyle(fontSize: 10, color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  isPacing 
                      ? Icon(Icons.shield_outlined, color: isSelected ? Colors.black : Colors.white, size: 18)
                      : Text(DateFormat('d').format(date), style: TextStyle(fontSize: 14, color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 2. TAB: HOY (Main Dashboard) ---
  Widget _buildHoyTab() {
    String currentDateKey = _getDateKey(_selectedDate);
    bool isCurrentlyPacing = _activeProfile.pacingDays.contains(currentDateKey);
    List<StructuralEvent> todaysEvents = _activeProfile.structuralEvents.where((e) => e.dateKey == currentDateKey).toList();
    
    // Calculate simple metrics for the day
    int dosesTaken = _activeProfile.medications.where((m) => m.getDoseForDate(_selectedDate) > 0).length;
    int totalMeds = _activeProfile.medications.length;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // ZEBRA WISDOM
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("SABIDURÍA ZEBRA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text('"${_dailyWisdom.text}"', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // POTATO DAY TOGGLE
        InkWell(
          onTap: () => setState(() {
            isCurrentlyPacing ? _activeProfile.pacingDays.remove(currentDateKey) : _activeProfile.pacingDays.add(currentDateKey);
            _saveData();
          }),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentlyPacing ? Colors.white : Colors.transparent,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Row(
              children: [
                Icon(isCurrentlyPacing ? Icons.shield : Icons.shield_outlined, color: isCurrentlyPacing ? Colors.black : Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("POTATO DAY (RECUPERACIÓN)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isCurrentlyPacing ? Colors.black : Colors.white)),
                      Text("Validar el descanso preventivo.", style: TextStyle(fontSize: 12, color: isCurrentlyPacing ? Colors.black : Colors.grey[400])),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // DAILY SUMMARY WIDGET
        const Text("RESUMEN DEL DÍA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
          child: Column(
            children: [
              _buildSummaryRow(Icons.accessibility_new, "Eventos Estructurales:", "${todaysEvents.length} registrados"),
              const Divider(color: Colors.grey),
              _buildSummaryRow(Icons.healing, "Síntomas Activos:", "${_activeProfile.activeSymptoms.length} en seguimiento"),
              const Divider(color: Colors.grey),
              _buildSummaryRow(Icons.medical_information_outlined, "Medicación/Suplementos:", "$dosesTaken / $totalMeds tomados hoy"),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  // --- 3. TAB: SÍNTOMAS (Body Map & Vault) ---
  Widget _buildSintomasTab() {
    String currentDateKey = _getDateKey(_selectedDate);
    List<StructuralEvent> todaysEvents = _activeProfile.structuralEvents.where((e) => e.dateKey == currentDateKey).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text("MAPA DE ZONAS ESTRUCTURALES", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        const Text("TREN SUPERIOR", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ["Cervicales", "Hombros", "Muñecas", "Manos", "Lumbar/Pelvis", "Caderas", "Rodillas", "Tobillos"]
            .map((zone) => ActionChip(
              backgroundColor: Colors.transparent, side: const BorderSide(color: Colors.white),
              label: Text(zone, style: const TextStyle(color: Colors.white, fontSize: 12)),
              onPressed: () => _openStructuralMenu(zone),
            )).toList(),
        ),
        
        if (todaysEvents.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            child: Column(
              children: todaysEvents.map((event) => Row(
                children: [
                  const Icon(Icons.adjust, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text("${event.zone}: ${event.type}")),
                  IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 18), onPressed: () => setState(() { _activeProfile.structuralEvents.remove(event); _saveData(); }))
                ],
              )).toList(),
            ),
          )
        ],
        const SizedBox(height: 32),

        const Text("SÍNTOMAS ACTIVOS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _activeProfile.activeSymptoms.entries.map((entry) {
            Color chipColor = entry.value == "Leve" ? Colors.green[900]! : entry.value == "Moderado" ? Colors.orange[900]! : Colors.red[900]!;
            return InputChip(
              backgroundColor: chipColor, side: const BorderSide(color: Colors.white),
              label: Text("${entry.key} (${entry.value})"),
              onPressed: () => _openSeverityMenu(entry.key),
              onDeleted: () => setState(() { _activeProfile.activeSymptoms.remove(entry.key); _activeProfile.inactiveVault.insert(0, entry.key); _saveData(); }),
              deleteIconColor: Colors.white,
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        
        const Text("BAÚL INACTIVO (AÑADIR A HOY)", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _activeProfile.inactiveVault.map((symptom) => ActionChip(
            backgroundColor: Colors.black, side: const BorderSide(color: Colors.grey),
            label: Text(symptom, style: const TextStyle(color: Colors.grey)),
            onPressed: () => setState(() { _activeProfile.inactiveVault.remove(symptom); _activeProfile.activeSymptoms[symptom] = "Moderado"; _saveData(); }),
          )).toList(),
        ),
        
        const SizedBox(height: 24),
        TextField(
          controller: _newSymptomController,
          decoration: InputDecoration(
            hintText: "+ Añadir síntoma personalizado...", hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                if (_newSymptomController.text.trim().isNotEmpty) {
                  setState(() { _activeProfile.inactiveVault.insert(0, _newSymptomController.text.trim()); _newSymptomController.clear(); _saveData(); });
                }
              }
            )
          ),
        ),
      ],
    );
  }

  // --- 4. TAB: BOTIQUÍN (Medications & Alerts) ---
  Widget _buildBotiquinTab() {
    List<Map<String, dynamic>> activeFlags = _generateClinicalFlags();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (activeFlags.isNotEmpty) ...[
          const Text("ALERTAS DE INTERACCIÓN", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          ...activeFlags.map((flag) => Container(
                margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: flag["type"] == "severe" ? Colors.redAccent : Colors.white, width: 2)),
                child: Text(flag["message"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              )),
          const SizedBox(height: 24),
        ],

        const Text("REGISTRO DE DOSIS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        ..._activeProfile.medications.map((med) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[800]!)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                Text(med.doseDetails, style: const TextStyle(fontSize: 12, color: Colors.grey))
              ])),
              Row(children: [
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() { med.updateDose(_selectedDate, -1); _saveData(); })),
                Text("${med.getDoseForDate(_selectedDate)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() { med.updateDose(_selectedDate, 1); _saveData(); })),
              ])
            ],
          ),
        )),
        
        const SizedBox(height: 32),
        const Text("ADMINISTRAR BOTIQUÍN", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[800]!)),
          child: Column(
            children: [
              TextField(controller: _newMedNameController, decoration: const InputDecoration(hintText: "Nombre del Medicamento", hintStyle: TextStyle(color: Colors.grey))),
              Row(
                children: [
                  Expanded(child: TextField(controller: _newMedDoseController, decoration: const InputDecoration(hintText: "Dosis (Ej. 14mg)", hintStyle: TextStyle(color: Colors.grey)))),
                  IconButton(icon: const Icon(Icons.add_box_rounded, size: 32, color: Colors.white), onPressed: () {
                    if (_newMedNameController.text.trim().isNotEmpty) {
                      setState(() {
                        _activeProfile.medications.add(Medication(name: _newMedNameController.text.trim(), doseDetails: _newMedDoseController.text.trim()));
                        _newMedNameController.clear(); _newMedDoseController.clear(); _saveData();
                      });
                    }
                  }),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  // --- 5. TAB: CLÍNICA (Reports & Library) ---
  Widget _buildClinicaTab() {
    return Column(
      children: [
        // Sub-navigation toggle
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _clinicaTabView == "Reporte" ? Colors.white : Colors.black, side: const BorderSide(color: Colors.white)),
                onPressed: () => setState(() => _clinicaTabView = "Reporte"),
                child: Text("REPORTE MÉDICO", style: TextStyle(color: _clinicaTabView == "Reporte" ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
              )),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _clinicaTabView == "Biblioteca" ? Colors.white : Colors.black, side: const BorderSide(color: Colors.white)),
                onPressed: () => setState(() => _clinicaTabView = "Biblioteca"),
                child: Text("BIBLIOTECA", style: TextStyle(color: _clinicaTabView == "Biblioteca" ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
              )),
            ],
          ),
        ),
        
        Expanded(
          child: _clinicaTabView == "Reporte" 
            ? _buildReportContent() 
            : _buildCompendiumLibraryContent()
        ),
      ],
    );
  }

  Widget _buildReportContent() {
    Map<String, String> filteredSymptoms = _activeProfile.activeSymptoms;
    List<Medication> filteredMeds = _activeProfile.medications;

    if (_selectedReportSpecialty == "Ortopedia/Fisio") {
      filteredMeds = _activeProfile.medications.where((m) => m.name.contains("Ibuprofeno") || m.name.contains("Duloxetina")).toList();
      filteredSymptoms = Map.fromEntries(_activeProfile.activeSymptoms.entries.where((e) => e.key.contains("Tensión") || e.key.contains("Dolor") || e.key.contains("Fatiga")));
    } else if (_selectedReportSpecialty == "Hematología") {
      filteredMeds = _activeProfile.medications.where((m) => m.name.contains("Hierro") || m.name.contains("Vitamina C")).toList();
      filteredSymptoms = Map.fromEntries(_activeProfile.activeSymptoms.entries.where((e) => e.key.contains("Moratones") || e.key.contains("Sangrado") || e.key.contains("Fatiga")));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ["General", "Ortopedia/Fisio", "Hematología"].map((spec) => ChoiceChip(
            backgroundColor: _selectedReportSpecialty == spec ? Colors.white : Colors.transparent,
            labelStyle: TextStyle(color: _selectedReportSpecialty == spec ? Colors.black : Colors.white),
            side: const BorderSide(color: Colors.white),
            label: Text(spec),
            selected: _selectedReportSpecialty == spec,
            onSelected: (bool selected) => setState(() => _selectedReportSpecialty = spec),
          )).toList(),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("PACIENTE: ${_activeProfile.name}", style: const TextStyle(fontFamily: 'Courier', fontSize: 14)),
              Text("FECHA EVALUADA: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}", style: const TextStyle(fontFamily: 'Courier')),
              const Divider(color: Colors.white),
              const Text("DIAGNÓSTICOS CLÍNICOS ACTIVOS:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
              ..._activeProfile.conditions.map((c) => Text(" • $c", style: const TextStyle(fontFamily: 'Courier'))),
              const SizedBox(height: 12),
              const Text("TRATAMIENTO:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
              ...filteredMeds.map((m) => Text(" • ${m.name} - Tomado Hoy: ${m.getDoseForDate(_selectedDate)}", style: const TextStyle(fontFamily: 'Courier'))),
              const SizedBox(height: 12),
              const Text("SÍNTOMAS:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
              ...filteredSymptoms.entries.map((s) => Text(" • ${s.key} [${s.value.toUpperCase()}]", style: const TextStyle(fontFamily: 'Courier'))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompendiumLibraryContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: _clinicalLibraryDatabase.map((article) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
        child: ExpansionTile(
          iconColor: Colors.white, collapsedIconColor: Colors.white,
          title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          children: [Padding(padding: const EdgeInsets.all(16.0), child: Text(article.content, style: const TextStyle(height: 1.5)))],
        ),
      )).toList(),
    );
  }

  // --- 6. SETTINGS DRAWER (Hidden Menu) ---
  Widget _buildSettingsDrawer() {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 40),
          const Text("CONFIGURACIÓN DE PERFIL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
          const Divider(color: Colors.white),
          const SizedBox(height: 16),

          const Text("NOMBRE DEL PACIENTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          TextField(
            controller: _profileNameController,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => setState(() { _activeProfile.name = val; _saveData(); }),
          ),
          const SizedBox(height: 24),

          const Text("COMORBILIDADES / DIAGNÓSTICOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          Row(
            children: [
              Expanded(child: TextField(controller: _newDiagnosisController, style: const TextStyle(color: Colors.white))),
              IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () {
                if (_newDiagnosisController.text.trim().isNotEmpty) {
                  setState(() { _activeProfile.conditions.add(_newDiagnosisController.text.trim()); _newDiagnosisController.clear(); _saveData(); });
                }
              }),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 4,
            children: _activeProfile.conditions.map((condition) => InputChip(
              label: Text(condition, style: const TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              onDeleted: () => setState(() { _activeProfile.conditions.remove(condition); _saveData(); }),
              deleteIconColor: Colors.black,
            )).toList(),
          ),
          const SizedBox(height: 40),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white, width: 2), padding: const EdgeInsets.symmetric(vertical: 16)),
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
            label: const Text("CREAR NUEVO PERFIL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() {
                final newId = (_profiles.length + 1).toString();
                final newProfile = Profile(
                  id: newId, name: "NUEVO PERFIL $newId", dob: "1960-01-01",
                  conditions: [], medications: [], activeSymptoms: {}, inactiveVault: [],
                );
                _profiles.add(newProfile);
                _activeProfile = newProfile;
                _updateControllers();
                _saveData();
                Navigator.pop(context); // Closes drawer
              });
            },
          ),
        ],
      ),
    );
  }

  // Helpers for Modals
  void _openSeverityMenu(String symptom) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.black, shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 2)),
      builder: (context) {
        return Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("GRAVEDAD DE: ${symptom.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(leading: const Icon(Icons.circle, color: Colors.green), title: const Text("Leve", style: TextStyle(color: Colors.white)), onTap: () { setState(() { _activeProfile.activeSymptoms[symptom] = "Leve"; _saveData(); }); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.circle, color: Colors.orange), title: const Text("Moderado", style: TextStyle(color: Colors.white)), onTap: () { setState(() { _activeProfile.activeSymptoms[symptom] = "Moderado"; _saveData(); }); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.circle, color: Colors.red), title: const Text("Severo", style: TextStyle(color: Colors.white)), onTap: () { setState(() { _activeProfile.activeSymptoms[symptom] = "Severo"; _saveData(); }); Navigator.pop(context); }),
        ]));
      }
    );
  }

  void _openStructuralMenu(String zone) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.black, shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 2)),
      builder: (context) {
        return Container(padding: const EdgeInsets.all(20), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("REGISTRAR EN: ${zone.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...["Subluxación", "Dislocación", "Inestabilidad Articular", "Dolor Articular", "Dolor Miofascial", "Dolor Neuropático"].map((type) => ListTile(
            contentPadding: EdgeInsets.zero, leading: const Icon(Icons.warning_amber_rounded, color: Colors.white), title: Text(type, style: const TextStyle(color: Colors.white)),
            onTap: () { setState(() { _activeProfile.structuralEvents.add(StructuralEvent(zone: zone, type: type, dateKey: _getDateKey(_selectedDate))); _saveData(); }); Navigator.pop(context); },
          )),
        ])));
      }
    );
  }
}